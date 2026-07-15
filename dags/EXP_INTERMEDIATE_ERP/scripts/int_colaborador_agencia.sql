-- 1. CRIAR A TABELA SE NÃO EXISTIR
CREATE TABLE IF NOT EXISTS intermediate_erp.int_colaborador_agencia (
    cod_colaborador INT,
    cod_agencia INT,
    _ingested_at_ts TIMESTAMP,
    _updated_at_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (cod_colaborador, cod_agencia)
);

-- 2. INSERIR OS DADOS TRANSFORMADOS COM UPSERT
INSERT INTO intermediate_erp.int_colaborador_agencia (
    cod_colaborador,
    cod_agencia,
    _ingested_at_ts,
    _updated_at_ts
)
SELECT 
    CAST(cod_colaborador AS INT),
    CAST(cod_agencia AS INT),
    CAST(_ingested_at_ts AS TIMESTAMP),
    CURRENT_TIMESTAMP
FROM staging_erp.stg_colaborador_agencia
ON CONFLICT (cod_colaborador, cod_agencia) 
DO UPDATE SET 
    _ingested_at_ts = EXCLUDED._ingested_at_ts,
    _updated_at_ts = CURRENT_TIMESTAMP;