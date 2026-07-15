import base64
import logging
import os
from datetime import datetime, timedelta

from airflow import DAG
from airflow.providers.cncf.kubernetes.operators.pod import KubernetesPodOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator


DAG_DIR = os.path.dirname(os.path.abspath(__file__))
logger = logging.getLogger(__name__)

default_args = {
    'retries': 3,
    'retry_delay': timedelta(minutes=1),
}

with DAG(
    dag_id="EMBULK_INGEST_FROM_BANVIC_CSV",
    schedule_interval="35 4 * * *",
    start_date=datetime(2026, 7, 8),
    default_args=default_args,
    catchup=False,
    tags=["ingest", "banvic", "embulk"],
) as dag:

    prepare_db = SQLExecuteQueryOperator(
        task_id="prepare_db",
        conn_id="dw_postgres",
        sql="CREATE SCHEMA IF NOT EXISTS stage; CREATE SCHEMA IF NOT EXISTS bronze; "
    )

    jobs_dir = os.path.join(DAG_DIR, 'jobs')

    for job_file_name in os.listdir(jobs_dir):
        job_path = os.path.join(DAG_DIR, 'jobs', job_file_name)
        job_name_clean = job_file_name.replace(
            ".yml", "").replace(".liquid", "")

        with open(job_path, "rb") as f:
            data_bytes = f.read()
            config_b64 = base64.b64encode(data_bytes).decode('utf-8')

        ingest_task = KubernetesPodOperator(
            task_id=f"ingest_{job_file_name}",
            name=f'embulk-ingest-{job_name_clean}',
            namespace='airflow',
            image='embulk-ingestion:latest',
            image_pull_policy='Never',
            cmds=["/bin/sh", "-c"],
            arguments=["/opt/embulk/entrypoint.sh"],
            env_vars={
                'CONFIG_BASE64': config_b64,
                # Credenciais do DW (PostgreSQL)
                'DB_HOST': '{{ conn.dw_postgres.host }}',
                'DB_USER': '{{ conn.dw_postgres.login }}',
                'DB_PASSWORD': '{{ conn.dw_postgres.password }}',
                'DB_NAME': '{{ conn.dw_postgres.schema }}',
                'DB_PORT': '{{ conn.dw_postgres.port }}',
                # Credenciais da Origem (SFTP)
                'SFTP_HOST': '{{ conn.sftp_erp.host }}',
                'SFTP_USER': '{{ conn.sftp_erp.login }}',
                'SFTP_PASSWORD': '{{ conn.sftp_erp.password }}',
            },
            in_cluster=True,
            is_delete_operator_pod=True,
            get_logs=True,
        )

        prepare_db >> ingest_task
