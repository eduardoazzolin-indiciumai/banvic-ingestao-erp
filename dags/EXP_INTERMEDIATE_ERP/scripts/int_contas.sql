-- INT_DIM_CONTAS -----------------------------------
-- 1. CRIAR A TABELA SE NÃO EXISTIR
CREATE TABLE IF NOT EXISTS intermediate_erp.int_dim_contas (
    num_conta INT PRIMARY KEY,
    cod_cliente INT,
    cod_agencia INT,
    cod_colaborador INT,
    tipo_conta CHAR(2),
    data_abertura TIMESTAMPTZ,
    _ingested_at_ts TIMESTAMP,
    _updated_at_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. INSERIR OS DADOS TRANSFORMADOS COM UPSERT
INSERT INTO intermediate_erp.int_dim_contas (
    num_conta,
    cod_cliente,
    cod_agencia,
    cod_colaborador,
    tipo_conta,
    data_abertura,
    _ingested_at_ts,
    _updated_at_ts
)
SELECT 
    CAST(num_conta AS INT),
    CAST(cod_cliente AS INT),
    CAST(cod_agencia AS INT),
    CAST(cod_colaborador AS INT),
    UPPER(TRIM(CAST(tipo_conta AS CHAR(2)))),
    CAST(data_abertura AS TIMESTAMPTZ),
    CAST(_ingested_at_ts AS TIMESTAMP),
    CURRENT_TIMESTAMP
FROM staging_erp.stg_contas
ON CONFLICT (num_conta) 
DO UPDATE SET 
    cod_cliente = EXCLUDED.cod_cliente,
    cod_agencia = EXCLUDED.cod_agencia,
    cod_colaborador = EXCLUDED.cod_colaborador,
    tipo_conta = EXCLUDED.tipo_conta,
    data_abertura = EXCLUDED.data_abertura,
    _ingested_at_ts = EXCLUDED._ingested_at_ts,
    _updated_at_ts = CURRENT_TIMESTAMP;



-- INT_FACT_CONTAS -----------------------------------
-- 1. CRIAR A TABELA SE NÃO EXISTIR
CREATE TABLE IF NOT EXISTS intermediate_erp.int_fct_contas (
    num_conta INT PRIMARY KEY REFERENCES intermediate_erp.int_dim_contas(num_conta),
    saldo_total NUMERIC(18, 4),
    saldo_disponivel NUMERIC(18, 4),
    data_ultimo_lancamento TIMESTAMPTZ,
    _ingested_at_ts TIMESTAMP,
    _updated_at_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. INSERIR OS DADOS TRANSFORMADOS COM UPSERT
INSERT INTO intermediate_erp.int_fct_contas (
    num_conta,
    saldo_total,
    saldo_disponivel,
    data_ultimo_lancamento,
    _ingested_at_ts,
    _updated_at_ts
)
SELECT 
    CAST(num_conta AS INT),
    CAST(saldo_total AS NUMERIC(18, 4)),
    CAST(saldo_disponivel AS NUMERIC(18, 4)),
    CAST(data_ultimo_lancamento AS TIMESTAMPTZ),
    CAST(_ingested_at_ts AS TIMESTAMP),
    CURRENT_TIMESTAMP
FROM staging_erp.stg_contas
ON CONFLICT (num_conta) 
DO UPDATE SET 
    saldo_total = EXCLUDED.saldo_total,
    saldo_disponivel = EXCLUDED.saldo_disponivel,
    data_ultimo_lancamento = EXCLUDED.data_ultimo_lancamento,
    _ingested_at_ts = EXCLUDED._ingested_at_ts,
    _updated_at_ts = CURRENT_TIMESTAMP;
