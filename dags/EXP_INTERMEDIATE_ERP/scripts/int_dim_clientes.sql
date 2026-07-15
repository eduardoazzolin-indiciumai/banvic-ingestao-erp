-- 1. CRIAR A TABELA SE NÃO EXISTIR
CREATE TABLE IF NOT EXISTS intermediate_erp.int_dim_clientes (
    cod_cliente INT PRIMARY KEY,
    primeiro_nome VARCHAR(150),
    ultimo_nome VARCHAR(150),
    nome_completo VARCHAR(300),       
    email VARCHAR(255),
    tipo_cliente CHAR(2),             
    data_inclusao TIMESTAMPTZ,        
    cpfcnpj VARCHAR(14),              
    data_nascimento DATE,             
    endereco VARCHAR(500),
    cep CHAR(8),                      
    _ingested_at_ts TIMESTAMP,
    _updated_at_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
);

COMMENT ON TABLE intermediate_erp.int_dim_clientes IS 'Tabela de dimensão descritiva contendo os dados cadastrais dos clientes na camada intermediate.';
COMMENT ON COLUMN intermediate_erp.int_dim_clientes.cod_cliente IS 'Código identificador único do cliente oriundo do ERP.';
COMMENT ON COLUMN intermediate_erp.int_dim_clientes.primeiro_nome IS 'Primeiro nome do cliente.';
COMMENT ON COLUMN intermediate_erp.int_dim_clientes.ultimo_nome IS 'Último nome ou sobrenome do cliente.';
COMMENT ON COLUMN intermediate_erp.int_dim_clientes.nome_completo IS 'Nome completo do cliente, campo calculado a partir da concatenação do primeiro e último nome.';
COMMENT ON COLUMN intermediate_erp.int_dim_clientes.email IS 'Endereço de e-mail de contato do cliente, padronizado em letras minúsculas.';
COMMENT ON COLUMN intermediate_erp.int_dim_clientes.tipo_cliente IS 'Classificação do tipo de cliente (ex: PF para Pessoa Física, PJ para Pessoa Jurídica).';
COMMENT ON COLUMN intermediate_erp.int_dim_clientes.data_inclusao IS 'Data e hora com fuso horário em que o cliente foi cadastrado no sistema de origem.';
COMMENT ON COLUMN intermediate_erp.int_dim_clientes.cpfcnpj IS 'Número de identificação fiscal do cliente (CPF ou CNPJ), contendo estritamente caracteres numéricos.';
COMMENT ON COLUMN intermediate_erp.int_dim_clientes.data_nascimento IS 'Data de nascimento (para pessoas físicas) ou fundação (para pessoas jurídicas) do cliente.';
COMMENT ON COLUMN intermediate_erp.int_dim_clientes.endereco IS 'Endereço físico de residência ou sede do cliente.';
COMMENT ON COLUMN intermediate_erp.int_dim_clientes.cep IS 'Código de Endereçamento Postal (CEP) do cliente, contendo apenas números e preenchido com zeros à esquerda se necessário.';
COMMENT ON COLUMN intermediate_erp.int_dim_clientes._ingested_at_ts IS 'Carimbo de data e hora indicando quando o registro foi extraído da origem e gravado na camada de staging.';
COMMENT ON COLUMN intermediate_erp.int_dim_clientes._updated_at_ts IS 'Carimbo de data e hora de controle interno indicando a última atualização do registro nesta tabela.';

-- 2. INSERIR OS DADOS TRANSFORMADOS COM UPSERT
INSERT INTO intermediate_erp.int_dim_clientes (
    cod_cliente,
    primeiro_nome,
    ultimo_nome,
    nome_completo,
    email,
    tipo_cliente,
    data_inclusao,
    cpfcnpj,
    data_nascimento,
    endereco,
    cep,
    _ingested_at_ts,
    _updated_at_ts
)
SELECT 
    CAST(cod_cliente AS INT),
    TRIM(CAST(primeiro_nome AS VARCHAR(150))),
    TRIM(CAST(ultimo_nome AS VARCHAR(150))),
    CONCAT(TRIM(CAST(primeiro_nome AS VARCHAR(150))), ' ', TRIM(CAST(ultimo_nome AS VARCHAR(150)))),
    LOWER(TRIM(CAST(email AS VARCHAR(255)))),
    UPPER(TRIM(CAST(tipo_cliente AS CHAR(2)))),
    CAST(data_inclusao AS TIMESTAMPTZ),
    REGEXP_REPLACE(CAST(cpfcnpj AS VARCHAR), '[^0-9]', '', 'g'),
    CAST(data_nascimento AS DATE),
    TRIM(CAST(endereco AS VARCHAR(500))),
    LPAD(REGEXP_REPLACE(CAST(cep AS VARCHAR), '[^0-9]', '', 'g'), 8, '0'),
    CAST(_ingested_at_ts AS TIMESTAMP),
    CURRENT_TIMESTAMP
FROM staging_erp.stg_clientes
ON CONFLICT (cod_cliente) 
DO UPDATE SET 
    primeiro_nome = EXCLUDED.primeiro_nome,
    ultimo_nome = EXCLUDED.ultimo_nome,
    nome_completo = EXCLUDED.nome_completo,
    email = EXCLUDED.email,
    tipo_cliente = EXCLUDED.tipo_cliente,
    data_inclusao = EXCLUDED.data_inclusao,
    cpfcnpj = EXCLUDED.cpfcnpj,
    data_nascimento = EXCLUDED.data_nascimento,
    endereco = EXCLUDED.endereco,
    cep = EXCLUDED.cep,
    _ingested_at_ts = EXCLUDED._ingested_at_ts,
    _updated_at_ts = CURRENT_TIMESTAMP;