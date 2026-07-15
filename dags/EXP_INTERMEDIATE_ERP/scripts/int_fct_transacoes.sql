-- 1. CRIAR A TABELA SE NÃO EXISTIR
CREATE TABLE IF NOT EXISTS intermediate_erp.int_fct_transacoes (
    cod_transacao INT PRIMARY KEY,
    num_conta INT,
    data_transacao TIMESTAMPTZ,
    nome_transacao VARCHAR(100),
    valor_transacao NUMERIC(18, 4),
    _ingested_at_ts TIMESTAMP,
    _updated_at_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. INSERIR OS DADOS TRANSFORMADOS COM UPSERT
INSERT INTO intermediate_erp.int_fct_transacoes (
    cod_transacao,
    num_conta,
    data_transacao,
    nome_transacao,
    valor_transacao,
    _ingested_at_ts,
    _updated_at_ts
)
SELECT 
    CAST(cod_transacao AS INT),
    CAST(num_conta AS INT),
    CAST(data_transacao AS TIMESTAMPTZ),
    TRIM(CAST(nome_transacao AS VARCHAR(100))),
    CAST(valor_transacao AS NUMERIC(18, 4)),
    CAST(_ingested_at_ts AS TIMESTAMP),
    CURRENT_TIMESTAMP
FROM staging_erp.stg_transacoes
ON CONFLICT (cod_transacao) 
DO UPDATE SET 
    num_conta = EXCLUDED.num_conta,
    data_transacao = EXCLUDED.data_transacao,
    nome_transacao = EXCLUDED.nome_transacao,
    valor_transacao = EXCLUDED.valor_transacao,
    _ingested_at_ts = EXCLUDED._ingested_at_ts,
    _updated_at_ts = CURRENT_TIMESTAMP;