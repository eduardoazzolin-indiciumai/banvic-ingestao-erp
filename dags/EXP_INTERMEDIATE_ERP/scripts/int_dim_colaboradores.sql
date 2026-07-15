-- 1. CRIAR A TABELA SE NÃO EXISTIR
CREATE TABLE IF NOT EXISTS intermediate_erp.int_dim_colaboradores (
    cod_colaborador INT PRIMARY KEY,
    primeiro_nome VARCHAR(150),
    ultimo_nome VARCHAR(150),
    nome_completo VARCHAR(300),       
    email VARCHAR(255),
    cpf VARCHAR(11),                  
    data_nascimento DATE,             
    endereco VARCHAR(500),
    cep CHAR(8),                     
    _ingested_at_ts TIMESTAMP,
    _updated_at_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
);

-- 2. INSERIR OS DADOS TRANSFORMADOS COM UPSERT
INSERT INTO intermediate_erp.int_dim_colaboradores (
    cod_colaborador,
    primeiro_nome,
    ultimo_nome,
    nome_completo,
    email,
    cpf,
    data_nascimento,
    endereco,
    cep,
    _ingested_at_ts,
    _updated_at_ts
)
SELECT 
    CAST(cod_colaborador AS INT),
    TRIM(CAST(primeiro_nome AS VARCHAR(150))),
    TRIM(CAST(ultimo_nome AS VARCHAR(150))),
    CONCAT(TRIM(CAST(primeiro_nome AS VARCHAR(150))), ' ', TRIM(CAST(ultimo_nome AS VARCHAR(150)))),
    LOWER(TRIM(CAST(email AS VARCHAR(255)))),
    REGEXP_REPLACE(CAST(cpf AS VARCHAR), '[^0-9]', '', 'g'),
    CAST(data_nascimento AS DATE),
    TRIM(CAST(endereco AS VARCHAR(500))),
    LPAD(REGEXP_REPLACE(CAST(cep AS VARCHAR), '[^0-9]', '', 'g'), 8, '0'),
    CAST(_ingested_at_ts AS TIMESTAMP),
    CURRENT_TIMESTAMP
FROM staging_erp.stg_colaboradores
ON CONFLICT (cod_colaborador) 
DO UPDATE SET 
    primeiro_nome = EXCLUDED.primeiro_nome,
    ultimo_nome = EXCLUDED.ultimo_nome,
    nome_completo = EXCLUDED.nome_completo,
    email = EXCLUDED.email,
    cpf = EXCLUDED.cpf,
    data_nascimento = EXCLUDED.data_nascimento,
    endereco = EXCLUDED.endereco,
    cep = EXCLUDED.cep,
    _ingested_at_ts = EXCLUDED._ingested_at_ts,
    _updated_at_ts = CURRENT_TIMESTAMP;