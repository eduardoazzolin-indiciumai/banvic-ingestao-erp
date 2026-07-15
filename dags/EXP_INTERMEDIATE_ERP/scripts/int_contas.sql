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

COMMENT ON TABLE intermediate_erp.int_dim_contas IS 'Tabela de dimensão descritiva contendo os dados cadastrais das contas bancárias na camada intermediate.';
COMMENT ON COLUMN intermediate_erp.int_dim_contas.num_conta IS 'Número identificador único da conta bancária oriunda do ERP.';
COMMENT ON COLUMN intermediate_erp.int_dim_contas.cod_cliente IS 'Código identificador único do cliente associado à conta.';
COMMENT ON COLUMN intermediate_erp.int_dim_contas.cod_agencia IS 'Código identificador único da agência de vínculo da conta.';
COMMENT ON COLUMN intermediate_erp.int_dim_contas.cod_colaborador IS 'Código identificador único do colaborador responsável ou associado à conta.';
COMMENT ON COLUMN intermediate_erp.int_dim_contas.tipo_conta IS 'Classificação do tipo de conta (ex: PF para Pessoa Física, PJ para Pessoa Jurídica).';
COMMENT ON COLUMN intermediate_erp.int_dim_contas.data_abertura IS 'Data e hora com fuso horário do momento exato de abertura da conta no sistema de origem.';
COMMENT ON COLUMN intermediate_erp.int_dim_contas._ingested_at_ts IS 'Carimbo de data e hora indicando quando o registro foi extraído da origem e gravado na camada de staging.';
COMMENT ON COLUMN intermediate_erp.int_dim_contas._updated_at_ts IS 'Carimbo de data e hora de controle interno indicando a última atualização do registro nesta tabela.';

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

COMMENT ON TABLE intermediate_erp.int_fct_contas IS 'Tabela de fatos contendo as métricas mutáveis e saldos das contas bancárias na camada intermediate.';
COMMENT ON COLUMN intermediate_erp.int_fct_contas.num_conta IS 'Número identificador único da conta bancária, atuando como chave primária e chave estrangeira para a dimensão de contas.';
COMMENT ON COLUMN intermediate_erp.int_fct_contas.saldo_total IS 'Valor monetário representando o saldo total atual da conta.';
COMMENT ON COLUMN intermediate_erp.int_fct_contas.saldo_disponivel IS 'Valor monetário representando o saldo disponível para uso na conta.';
COMMENT ON COLUMN intermediate_erp.int_fct_contas.data_ultimo_lancamento IS 'Data e hora com fuso horário do último lançamento ou movimentação financeira realizada na conta.';
COMMENT ON COLUMN intermediate_erp.int_fct_contas._ingested_at_ts IS 'Carimbo de data e hora indicando quando o registro foi extraído da origem e gravado na camada de staging.';
COMMENT ON COLUMN intermediate_erp.int_fct_contas._updated_at_ts IS 'Carimbo de data e hora de controle interno indicando a última atualização do registro nesta tabela.';

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
