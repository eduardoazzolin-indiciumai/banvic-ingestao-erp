import os
import base64
from datetime import datetime, timedelta
from airflow import DAG, 
from airflow.decorators import dag, task
from airflow.providers.cncf.kubernetes.operators.pod import KubernetesPodOperator
from airflow.operators.empty import EmptyOperator
import logging

DAG_DIR = os.path.dirname(os.path.abspath(__file__))

logger = logging.getLogger()

def read_file_as_base64(file_name):
    config_path = os.path.join(DAG_DIR, 'jobs', file_name)
        
    with open(config_path, "rb") as f:
        data_bytes = f.read()
        return base64.b64encode(data_bytes).decode('utf-8')


@dag(
    dag_id="EMBULK_INGEST_FROM_BANVIC_CSV"
    schedule_interval="35 4 * * *",
    start_date=datetime(2026, 7, 8),
    catchup=False,
    tags=["ingest", "banvic", "embulk"],
    retries=3,
    retry_delay:timedelta(minutes=2)
) 
def embulk_ingest_from_banvic_csv_dag():

    @task
    def list_jobs():
        jobs = []
        jobs_dir = os.path.join(DAG_DIR, 'jobs')
        for file_name in os.listdir(jobs_dir):
            if file_name.endswith('.yml'):
                jobs.append(file_name)
        logger.info(f"Found {len(jobs)} jobs: {jobs}")
        return jobs


    @task
    def run_embulk_job(job_file):
        config_b64 = read_file_as_base64(job_file)


        task_id = f"ingest_{job_file.replace('.yml', '')}"
        KubernetesPodOperator(
            task_id=task_id,
            name=f"embulk-ingest-{job_file.replace('.yml', '')}",
            namespace="airflow",
            image="embulk-ingestion:latest",
            image_pull_policy="Never",
            cmds=["/bin/sh", "-c"],
            arguments=["/entrypoint.sh"],
            env_vars={
                "EMBULK_CONFIG_B64": config_b64,
                "NOME_TABELA": job_file.replace('.yml', '')
            },
            in_cluster=True,
            is_delete_operator_pod=True,
            get_logs=True,
        )










with DAG(
    dag_id='EMBULK_INGEST_FROM_BANVIC_CSV',
    default_args=default_args,
    description='Pipeline de ingestão das tabelas do ERP BanVic para PostgreSQL usando Embulk',
    schedule_interval=None, # Configurado para execução manual conforme escopo do desafio
    catchup=False,
    tags=['banvic', 'embulk', 'ingestion'],
) as dag:

    # Tarefas Dummy apenas para organizar o visual da DAG (Start e End)
    start_pipeline = EmptyOperator(task_id='start_pipeline')
    end_pipeline = EmptyOperator(task_id='end_pipeline')

    # Lista das 7 tabelas exigidas no desafio BanVic
    tabelas = [
        'agencias', 
        'clientes', 
        'colaborador_agencia', 
        'colaboradores', 
        'contas', 
        'propostas_credito', 
        'transacoes'
    ]

    # 4. Geração dinâmica das Tasks de Ingestão
    for tabela in tabelas:
        config_b64 = carregar_config_base64(tabela)
        
        # Só cria a task se o arquivo YML existir
        if config_b64:
            ingest_task = KubernetesPodOperator(
                task_id=f'ingest_{tabela}',
                name=f'embulk-ingest-{tabela.replace("_", "-")}',
                namespace='airflow',
                image='embulk-ingestion:latest',
                image_pull_policy='Never', # Garante o uso da imagem local gerada no Minikube
                cmds=["/bin/sh", "-c"],
                arguments=["/entrypoint.sh"],
                env_vars={
                    'EMBULK_CONFIG_B64': config_b64,
                    'NOME_TABELA': tabela
                },
                in_cluster=True,
                is_delete_operator_pod=True, # Remove o Pod do Minikube após sucesso, poupando recursos
                get_logs=True, # Exibe os logs do Embulk diretamente na interface do Airflow
            )

            # Define a ordem de execução: start -> ingestão (paralela) -> end
            start_pipeline >> ingest_task >> end_pipeline