-- 1. CRIAR A TABELA SE NÃO EXISTIR
CREATE TABLE IF NOT EXISTS intermediate_erp.int_fct_propostas_credito (
    cod_proposta INT PRIMARY KEY,
    cod_cliente INT,
    cod_colaborador INT,
    data_entrada_proposta TIMESTAMPTZ,
    taxa_juros_mensal NUMERIC(10, 4),
    valor_proposta NUMERIC(18, 4),
    valor_financiamento NUMERIC(18, 4),
    valor_entrada NUMERIC(18, 4),
    valor_prestacao NUMERIC(18, 4),
    quantidade_parcelas INT,
    carencia INT,
    status_proposta VARCHAR(50),
    _ingested_at_ts TIMESTAMP,
    _updated_at_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. INSERIR OS DADOS TRANSFORMADOS COM UPSERT
INSERT INTO intermediate_erp.int_fct_propostas_credito (
    cod_proposta,
    cod_cliente,
    cod_colaborador,
    data_entrada_proposta,
    taxa_juros_mensal,
    valor_proposta,
    valor_financiamento,
    valor_entrada,
    valor_prestacao,
    quantidade_parcelas,
    carencia,
    status_proposta,
    _ingested_at_ts,
    _updated_at_ts
)
SELECT 
    CAST(cod_proposta AS INT),
    CAST(cod_cliente AS INT),
    CAST(cod_colaborador AS INT),
    CAST(data_entrada_proposta AS TIMESTAMPTZ),
    CAST(taxa_juros_mensal AS NUMERIC(10, 4)),
    CAST(valor_proposta AS NUMERIC(18, 4)),
    CAST(valor_financiamento AS NUMERIC(18, 4)),
    CAST(valor_entrada AS NUMERIC(18, 4)),
    CAST(valor_prestacao AS NUMERIC(18, 4)),
    CAST(quantidade_parcelas AS INT),
    CAST(carencia AS INT),
    TRIM(CAST(status_proposta AS VARCHAR(50))),
    CAST(_ingested_at_ts AS TIMESTAMP),
    CURRENT_TIMESTAMP
FROM staging_erp.stg_propostas_credito
ON CONFLICT (cod_proposta) 
DO UPDATE SET 
    cod_cliente = EXCLUDED.cod_cliente,
    cod_colaborador = EXCLUDED.cod_colaborador,
    data_entrada_proposta = EXCLUDED.data_entrada_proposta,
    taxa_juros_mensal = EXCLUDED.taxa_juros_mensal,
    valor_proposta = EXCLUDED.valor_proposta,
    valor_financiamento = EXCLUDED.valor_financiamento,
    valor_entrada = EXCLUDED.valor_entrada,
    valor_prestacao = EXCLUDED.valor_prestacao,
    quantidade_parcelas = EXCLUDED.quantidade_parcelas,
    carencia = EXCLUDED.carencia,
    status_proposta = EXCLUDED.status_proposta,
    _ingested_at_ts = EXCLUDED._ingested_at_ts,
    _updated_at_ts = CURRENT_TIMESTAMP;