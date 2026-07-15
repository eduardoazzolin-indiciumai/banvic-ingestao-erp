"""
# DAG: EXP_INTERMEDIATE_ERP

**Description:**
Executes basic ELT transformations (Upserts) to move data from the Staging layer to the Intermediate layer in the Banvic Data Warehouse. 

**Mechanism:**
Dynamically reads and executes all SQL scripts located in the local `scripts/` directory against the `dw_postgres` connection.

**Data-Aware Scheduling:**
- **Triggered by (Upstream):** `banvic://banvic_dw/staging_erp`
- **Updates (Downstream):** `banvic://banvic_dw/intermediate_erp`
"""

import os
from datetime import datetime, timedelta

from airflow import DAG
from airflow.datasets import Dataset
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.operators.empty import EmptyOperator

# Define resource paths and datasets for Data-Aware Scheduling.
# The intermediate DAG listens to the staging completion and broadcasts its own success.
DAG_DIR = os.path.dirname(os.path.abspath(__file__))
BANVIC_STAGING_DATASET = Dataset("banvic://banvic_dw/staging_erp")
BANVIC_INTERMEDIATE_DATASET = Dataset("banvic://banvic_dw/intermediate_erp")

default_args = {
    'retries': 3,
    'retry_delay': timedelta(minutes=1),
}


with DAG(
    dag_id="EXP_INTERMEDIATE_ERP",
    schedule=[BANVIC_STAGING_DATASET],
    start_date=datetime(2026, 7, 8),
    default_args=default_args,
    max_active_tasks=2,
    catchup=False,
    tags=["EXT", "ERP", "intermediate", "embulk"],
    doc_md=__doc__
) as dag:
    
    # Terminal node designed to emit the dataset update event only after all transformations succeed.
    finalize_transformation = EmptyOperator(
        task_id="finalize_transformation",
        outlets=[BANVIC_INTERMEDIATE_DATASET]
    )

    # Dynamically build the DAG topology by parsing local SQL files.
    # Each script acts as an independent basic ELT (upsert) task.
    scripts_dir = os.path.join(DAG_DIR, 'scripts')

    for script_file_name in os.listdir(scripts_dir):
        script_path = os.path.join(DAG_DIR, 'scripts', script_file_name)

        transform_task = SQLExecuteQueryOperator(
            task_id=f"run_{script_file_name}",
            conn_id="dw_postgres",
            sql=os.path.join('scripts', script_file_name)
        )

        transform_task >> finalize_transformation
