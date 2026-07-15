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

COMMENT ON TABLE intermediate_erp.int_dim_agencias IS 'Tabela de dimensão descritiva contendo os dados cadastrais das agências na camada intermediate.';
COMMENT ON COLUMN intermediate_erp.int_dim_agencias.cod_agencia IS 'Código identificador único da agência oriunda do ERP.';
COMMENT ON COLUMN intermediate_erp.int_dim_agencias.nome IS 'Nome de fantasia ou identificação da agência.';
COMMENT ON COLUMN intermediate_erp.int_dim_agencias.endereco IS 'Endereço físico completo de localização da agência.';
COMMENT ON COLUMN intermediate_erp.int_dim_agencias.cidade IS 'Cidade onde a agência está localizada.';
COMMENT ON COLUMN intermediate_erp.int_dim_agencias.uf IS 'Sigla da Unidade Federativa (estado) onde a agência está localizada.';
COMMENT ON COLUMN intermediate_erp.int_dim_agencias.data_abertura IS 'Data e hora do momento exato de abertura ou inauguração da agência no sistema.';
COMMENT ON COLUMN intermediate_erp.int_dim_agencias.tipo_agencia IS 'Classificação do modelo de atendimento da agência (ex: Física, Digital).';
COMMENT ON COLUMN intermediate_erp.int_dim_agencias._ingested_at_ts IS 'Carimbo de data e hora indicando quando o registro foi extraído da origem e gravado na camada de staging.';
COMMENT ON COLUMN intermediate_erp.int_dim_agencias._updated_at_ts IS 'Carimbo de data e hora de controle interno indicando a última atualização do registro nesta tabela.';

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