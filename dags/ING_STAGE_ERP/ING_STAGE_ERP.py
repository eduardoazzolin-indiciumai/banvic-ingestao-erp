"""
# DAG: ING_STAGE_ERP

**Description:**
Orchestrates the ingestion of ERP data from an external SFTP server into the Staging layer of the Banvic Data Warehouse.

**Mechanism:**
Dynamically generates extraction tasks by reading Embulk configuration files (`.yml` or `.liquid`) from the local `jobs/` directory. Each job spins up an isolated Kubernetes Pod running the Embulk engine. Configuration files are base64-encoded and injected directly into the pods alongside database and SFTP credentials securely fetched from Airflow Connections.

**Schedule & Data-Awareness:**
- **Runs:** Daily at 04:35 AM (`35 4 * * *`).
- **Emits (Downstream):** `banvic://banvic_dw/staging_erp` (Triggers intermediate transformations upon completion).
"""

import base64
import os
from datetime import datetime, timedelta

from airflow import DAG
from airflow.datasets import Dataset
from airflow.providers.cncf.kubernetes.operators.pod import KubernetesPodOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.operators.empty import EmptyOperator

# Define the downstream dataset emitted by this DAG.
# Downstream transformation DAGs should listen to this URI to start their execution.
DAG_DIR = os.path.dirname(os.path.abspath(__file__))
BANVIC_STAGING_DATASET = Dataset("banvic://banvic_dw/staging_erp")

default_args = {
    'retries': 3,
    'retry_delay': timedelta(minutes=1),
}


with DAG(
    dag_id="ING_STAGE_ERP",
    schedule_interval="35 4 * * *",
    start_date=datetime(2026, 7, 8),
    default_args=default_args,
    max_active_tasks=4,
    catchup=False,
    tags=["ING", "ERP", "staging", "embulk"],
    doc_md=__doc__
) as dag:

    # Ensures that the target schemas exist in the Data Warehouse before any ingestion attempt.
    # Prevents Embulk from failing on the first run on a fresh database.
    prepare_db = SQLExecuteQueryOperator(
        task_id="prepare_db",
        conn_id="dw_postgres",
        sql="CREATE SCHEMA IF NOT EXISTS staging_erp; CREATE SCHEMA IF NOT EXISTS intermediate_erp; "
    )

    finalize_ingestion = EmptyOperator(
        task_id="finalize_ingestion",
        outlets=[BANVIC_STAGING_DATASET]
    )

    # Iterate through Embulk job definitions to dynamically build the Kubernetes tasks.
    # The config files are base64 encoded to safely pass complex YAML/Liquid structures as environment variables.
    jobs_dir = os.path.join(DAG_DIR, 'jobs')

    for job_file_name in os.listdir(jobs_dir):
        job_path = os.path.join(DAG_DIR, 'jobs', job_file_name)
        job_name_clean = job_file_name.replace(
            ".yml", "").replace(".liquid", "")

        with open(job_path, "rb") as f:
            data_bytes = f.read()
            config_b64 = base64.b64encode(data_bytes).decode('utf-8')

        # Spins up an ephemeral Kubernetes pod for each ingestion job.
        # Credentials are automatically resolved by Airflow's Jinja templating engine using Airflow Connections.
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
                'DB_HOST': '{{ conn.dw_postgres.host }}',
                'DB_USER': '{{ conn.dw_postgres.login }}',
                'DB_PASSWORD': '{{ conn.dw_postgres.password }}',
                'DB_NAME': '{{ conn.dw_postgres.schema }}',
                'DB_PORT': '{{ conn.dw_postgres.port }}',
                'SFTP_HOST': '{{ conn.sftp_erp.host }}',
                'SFTP_USER': '{{ conn.sftp_erp.login }}',
                'SFTP_PASSWORD': '{{ conn.sftp_erp.password }}',
            },
            in_cluster=True,
            is_delete_operator_pod=True,
            get_logs=True,
        )

        prepare_db >> ingest_task >> finalize_ingestion
