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

COMMENT ON TABLE intermediate_erp.int_fct_propostas_credito IS 'Tabela de fatos contendo as métricas e informações transacionais das propostas de crédito na camada intermediate.';
COMMENT ON COLUMN intermediate_erp.int_fct_propostas_credito.cod_proposta IS 'Código identificador único da proposta de crédito oriunda do ERP.';
COMMENT ON COLUMN intermediate_erp.int_fct_propostas_credito.cod_cliente IS 'Código identificador único do cliente associado à proposta de crédito.';
COMMENT ON COLUMN intermediate_erp.int_fct_propostas_credito.cod_colaborador IS 'Código identificador único do colaborador responsável pela proposta de crédito.';
COMMENT ON COLUMN intermediate_erp.int_fct_propostas_credito.data_entrada_proposta IS 'Data e hora com fuso horário em que a proposta de crédito foi registrada no sistema.';
COMMENT ON COLUMN intermediate_erp.int_fct_propostas_credito.taxa_juros_mensal IS 'Taxa de juros mensal aplicada ao financiamento da proposta de crédito.';
COMMENT ON COLUMN intermediate_erp.int_fct_propostas_credito.valor_proposta IS 'Valor monetário total negociado ou avaliado na proposta de crédito.';
COMMENT ON COLUMN intermediate_erp.int_fct_propostas_credito.valor_financiamento IS 'Valor monetário efetivamente financiado (valor da proposta subtraído o valor de entrada).';
COMMENT ON COLUMN intermediate_erp.int_fct_propostas_credito.valor_entrada IS 'Valor monetário pago como entrada pelo cliente na negociação.';
COMMENT ON COLUMN intermediate_erp.int_fct_propostas_credito.valor_prestacao IS 'Valor monetário fixo de cada prestação/parcela do financiamento.';
COMMENT ON COLUMN intermediate_erp.int_fct_propostas_credito.quantidade_parcelas IS 'Número total de parcelas acordadas para o pagamento do financiamento.';
COMMENT ON COLUMN intermediate_erp.int_fct_propostas_credito.carencia IS 'Período de carência (geralmente em meses) concedido antes do início do pagamento das parcelas.';
COMMENT ON COLUMN intermediate_erp.int_fct_propostas_credito.status_proposta IS 'Situação atual ou estágio da proposta de crédito no fluxo de aprovação (ex: Enviada).';
COMMENT ON COLUMN intermediate_erp.int_fct_propostas_credito._ingested_at_ts IS 'Carimbo de data e hora indicando quando o registro foi extraído da origem e gravado na camada de staging.';
COMMENT ON COLUMN intermediate_erp.int_fct_propostas_credito._updated_at_ts IS 'Carimbo de data e hora de controle interno indicando a última atualização do registro nesta tabela.';

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