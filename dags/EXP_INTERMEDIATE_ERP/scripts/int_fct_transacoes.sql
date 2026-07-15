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

COMMENT ON TABLE intermediate_erp.int_fct_transacoes IS 'Tabela de fatos contendo os registros de transações ou movimentações financeiras na camada intermediate.';
COMMENT ON COLUMN intermediate_erp.int_fct_transacoes.cod_transacao IS 'Código identificador único da transação financeira oriunda do ERP.';
COMMENT ON COLUMN intermediate_erp.int_fct_transacoes.num_conta IS 'Número identificador da conta bancária associada à transação.';
COMMENT ON COLUMN intermediate_erp.int_fct_transacoes.data_transacao IS 'Data e hora com fuso horário em que a transação foi efetivamente realizada.';
COMMENT ON COLUMN intermediate_erp.int_fct_transacoes.nome_transacao IS 'Nome ou descrição do tipo de transação realizada (ex: Saque, Depósito).';
COMMENT ON COLUMN intermediate_erp.int_fct_transacoes.valor_transacao IS 'Valor monetário da transação financeira (positivo para entradas, negativo para saídas).';
COMMENT ON COLUMN intermediate_erp.int_fct_transacoes._ingested_at_ts IS 'Carimbo de data e hora indicando quando o registro foi extraído da origem e gravado na camada de staging.';
COMMENT ON COLUMN intermediate_erp.int_fct_transacoes._updated_at_ts IS 'Carimbo de data e hora de controle interno indicando a última atualização do registro nesta tabela.';

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