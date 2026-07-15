-- 1. CRIAR A TABELA SE NÃO EXISTIR
CREATE TABLE IF NOT EXISTS intermediate_erp.int_dim_clientes (
    cod_cliente INT PRIMARY KEY,
    primeiro_nome VARCHAR(150),
    ultimo_nome VARCHAR(150),
    nome_completo VARCHAR(300),       -- Campo calculado (ótimo para BI e relatórios)
    email VARCHAR(255),
    tipo_cliente CHAR(2),             -- PF ou PJ
    data_inclusao TIMESTAMPTZ,        -- Correto: Preserva data, hora e timezone (ex: UTC)
    cpfcnpj VARCHAR(14),              -- Limpo: Apenas números (evita problemas de máscara)
    data_nascimento DATE,             -- Apenas DATE (nascimento não exige precisão de horas)
    endereco VARCHAR(500),
    cep CHAR(8),                      -- Limpo: Apenas 8 números com zeros à esquerda se faltar
    _ingested_at_ts TIMESTAMP,
    _updated_at_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Controle interno
);

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