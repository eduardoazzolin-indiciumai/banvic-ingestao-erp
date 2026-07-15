-- 1. CRIAR A TABELA SE NÃO EXISTIR
CREATE TABLE IF NOT EXISTS intermediate_erp.int_brg_colaborador_agencia (
    cod_colaborador INT,
    cod_agencia INT,
    _ingested_at_ts TIMESTAMP,
    _updated_at_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (cod_colaborador, cod_agencia)
);
COMMENT ON TABLE intermediate_erp.int_brg_colaborador_agencia IS 'Tabela associativa da camada intermediate que mapeia o relacionamento de N:N entre colaboradores e agências.';
COMMENT ON COLUMN intermediate_erp.int_brg_colaborador_agencia.cod_colaborador IS 'Código identificador único do colaborador oriundo do ERP.';
COMMENT ON COLUMN intermediate_erp.int_brg_colaborador_agencia.cod_agencia IS 'Código identificador único da agência oriunda do ERP.';
COMMENT ON COLUMN intermediate_erp.int_brg_colaborador_agencia._ingested_at_ts IS 'Carimbo de data/hora indicando quando o registro foi extraído da origem e gravado na staging.';
COMMENT ON COLUMN intermediate_erp.int_brg_colaborador_agencia._updated_at_ts IS 'Carimbo de data/hora de controle interno indicando a última atualização do registro nesta tabela intermediate.';


-- 2. INSERIR OS DADOS TRANSFORMADOS COM UPSERT
INSERT INTO intermediate_erp.int_brg_colaborador_agencia (
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