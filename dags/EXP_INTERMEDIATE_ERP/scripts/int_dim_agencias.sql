-- 1. CRIAR A TABELA SE NÃO EXISTIR
CREATE TABLE IF NOT EXISTS intermediate_erp.int_dim_agencias (
    cod_agencia INT primary key,
    nome VARCHAR(255),
    endereco VARCHAR(500),
    cidade VARCHAR(100),
    uf CHAR(2),
    data_abertura TIMESTAMP, 
    tipo_agencia VARCHAR(50),
    _ingested_at_ts TIMESTAMP,
    _updated_at_ts TIMESTAMP default CURRENT_TIMESTAMP 
);

-- 2. INSERIR OS DADOS TRANSFORMADOS COM UPSERT
INSERT INTO intermediate_erp.int_dim_agencias (
    cod_agencia,
    nome,
    endereco,
    cidade,
    uf,
    data_abertura,
    tipo_agencia,
    _ingested_at_ts,
    _updated_at_ts
)
SELECT 
    CAST(cod_agencia AS INT),
    TRIM(CAST(nome AS VARCHAR(255))),
    TRIM(CAST(endereco AS VARCHAR(500))),
    TRIM(CAST(cidade AS VARCHAR(100))),
    UPPER(TRIM(CAST(uf AS CHAR(2)))),     
    CAST(data_abertura AS TIMESTAMP),    
    TRIM(CAST(tipo_agencia AS VARCHAR(50))),
    CAST(_ingested_at_ts AS TIMESTAMP),
    CURRENT_TIMESTAMP
FROM staging_erp.stg_agencias
ON CONFLICT (cod_agencia) 
DO UPDATE SET 
    nome = EXCLUDED.nome,
    endereco = EXCLUDED.endereco,
    cidade = EXCLUDED.cidade,
    uf = EXCLUDED.uf,
    data_abertura = EXCLUDED.data_abertura, 
    tipo_agencia = EXCLUDED.tipo_agencia,
    _ingested_at_ts = EXCLUDED._ingested_at_ts,
    _updated_at_ts = CURRENT_TIMESTAMP;