from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

# Configurações básicas da DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
}

with DAG(
    'EMBULK_INGEST_FROM_BANVIC_CSV',  # ID único que vai aparecer na interface do Airflow
    default_args=default_args,
    description='Uma DAG simples para testar e depurar o ambiente',
    schedule_interval=None,  # "None" significa que ela só roda se você clicar no "Play" manualmente
    start_date=datetime(2023, 1, 1),
    catchup=False,
    tags=['debug', 'teste'],
) as dag:

    # Task 1: Printa a data atual
    print_date = BashOperator(
        task_id='print_date',
        bash_command='date',
    )

    # Task 2: Mensagem de sucesso
    debug_message = BashOperator(
        task_id='debug_message',
        bash_command='echo "A DAG de debug rodou com sucesso no Kubernetes!"',
    )

    # Define a ordem de execução: primeiro print_date, depois debug_message
    print_date >> debug_message