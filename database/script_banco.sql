-- =====================================================
-- Sistema de Vendas - Loja NEXUS
-- Script de Criação do Banco de Dados PostgreSQL
-- =====================================================

-- Criar banco de dados (executar separadamente se necessário)
-- CREATE DATABASE loja_nexus;

-- Conectar ao banco loja_nexus antes de executar o restante

-- =====================================================
-- TABELA: clientes
-- =====================================================

CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    telefone VARCHAR(15),
    email VARCHAR(100),
    endereco VARCHAR(200),
    ativo BOOLEAN DEFAULT TRUE,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_cpf_formato CHECK (LENGTH(cpf) >= 11)
);

-- =====================================================
-- TABELA: produtos
-- =====================================================
CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    descricao VARCHAR(150) NOT NULL,
    preco_unitario NUMERIC(10,2) NOT NULL,
    estoque INTEGER NOT NULL DEFAULT 0,
    ativo BOOLEAN DEFAULT TRUE,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_preco_positivo CHECK (preco_unitario >= 0),
    CONSTRAINT chk_estoque_positivo CHECK (estoque >= 0)
);

-- =====================================================
-- TABELA: vendas
-- =====================================================
CREATE TABLE vendas (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    produto_id INTEGER NOT NULL,
    quantidade INTEGER NOT NULL,
    valor_unitario NUMERIC(10,2) NOT NULL,
    valor_total NUMERIC(10,2) NOT NULL,
    data_venda TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_venda_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT,
    CONSTRAINT fk_venda_produto FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE RESTRICT,
    CONSTRAINT chk_quantidade_positiva CHECK (quantidade > 0),
    CONSTRAINT chk_valor_unitario_positivo CHECK (valor_unitario >= 0),
    CONSTRAINT chk_valor_total_positivo CHECK (valor_total >= 0)
);

-- =====================================================
-- ÍNDICES para melhor performance
-- =====================================================
CREATE INDEX idx_vendas_cliente ON vendas(cliente_id);
CREATE INDEX idx_vendas_produto ON vendas(produto_id);
CREATE INDEX idx_vendas_data ON vendas(data_venda);
CREATE INDEX idx_clientes_nome ON clientes(nome);
CREATE INDEX idx_produtos_descricao ON produtos(descricao);

-- =====================================================
-- DADOS DE EXEMPLO - CLIENTES
-- =====================================================
INSERT INTO clientes (nome, cpf, telefone, email, endereco) VALUES
('João Silva Santos', '123.456.789-00', '(11) 98765-4321', 'joao.silva@email.com', 'Rua das Flores, 123 - São Paulo/SP'),
('Maria Oliveira Costa', '234.567.890-11', '(21) 97654-3210', 'maria.oliveira@email.com', 'Av. Paulista, 456 - São Paulo/SP'),
('Pedro Henrique Souza', '345.678.901-22', '(31) 96543-2109', 'pedro.souza@email.com', 'Rua Minas Gerais, 789 - Belo Horizonte/MG'),
('Ana Paula Ferreira', '456.789.012-33', '(41) 95432-1098', 'ana.ferreira@email.com', 'Av. Brasil, 321 - Curitiba/PR'),
('Carlos Eduardo Lima', '567.890.123-44', '(51) 94321-0987', 'carlos.lima@email.com', 'Rua Gaúcha, 654 - Porto Alegre/RS'),
('Juliana Martins Rocha', '678.901.234-55', '(61) 93210-9876', 'juliana.rocha@email.com', 'SQN 210, Bloco A - Brasília/DF');

-- =====================================================
-- DADOS DE EXEMPLO - PRODUTOS
-- =====================================================
INSERT INTO produtos (descricao, preco_unitario, estoque) VALUES
('Notebook Dell Inspiron 15', 3500.00, 15),
('Mouse Logitech MX Master 3', 450.00, 50),
('Teclado Mecânico Keychron K2', 650.00, 30),
('Monitor LG 27" Full HD', 1200.00, 20),
('Webcam Logitech C920', 550.00, 25),
('Headset HyperX Cloud II', 480.00, 40),
('SSD Samsung 1TB NVMe', 680.00, 35),
('Cadeira Gamer DT3 Sports', 1350.00, 12);

-- =====================================================
-- DADOS DE EXEMPLO - VENDAS
-- =====================================================
INSERT INTO vendas (cliente_id, produto_id, quantidade, valor_unitario, valor_total, data_venda) VALUES
(1, 1, 1, 3500.00, 3500.00, '2024-01-15 10:30:00'),
(1, 2, 2, 450.00, 900.00, '2024-01-15 10:35:00'),
(2, 4, 1, 1200.00, 1200.00, '2024-01-16 14:20:00'),
(3, 3, 1, 650.00, 650.00, '2024-01-17 09:15:00'),
(3, 5, 1, 550.00, 550.00, '2024-01-17 09:20:00'),
(4, 6, 2, 480.00, 960.00, '2024-01-18 16:45:00'),
(5, 7, 1, 680.00, 680.00, '2024-01-19 11:00:00'),
(6, 8, 1, 1350.00, 1350.00, '2024-01-20 15:30:00');

-- =====================================================
-- VERIFICAÇÃO DOS DADOS
-- =====================================================
-- SELECT * FROM clientes;
-- SELECT * FROM produtos;
-- SELECT * FROM vendas;
