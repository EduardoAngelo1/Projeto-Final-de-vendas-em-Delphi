# Sistema de Vendas - Loja NEXUS

### Passo 1: Criar o Banco de Dados

```sql
CREATE DATABASE loja_nexus;
```

### Passo 2: Executar o Script de Criação

1. Conecte-se ao banco `loja_nexus`
2. Abra o arquivo `database/script_banco.sql` contido na pasta atual
3. Execute todo o conteúdo do script

O script irá:
- Criar as tabelas: `clientes`, `produtos`, `vendas`
- Criar índices para melhor performance
- Inserir dados de exemplo (6 clientes, 8 produtos, 8 vendas)

### Passo 3: Verificar a Instalação

Execute no PostgreSQL:

```sql
SELECT * FROM clientes;
SELECT * FROM produtos;
SELECT * FROM vendas;
```

Você deve ver os dados de exemplo carregados.

---

## ⚙️ Configuração do Projeto

### 1. Configurar a Conexão com o Banco

Abra o arquivo `src\DataModule\uDataModule.pas` e localize o método `ConfigurarConexao`:


**Possiveis ajustes de parâmetros:**
- `Port=5433` → Sua porta do PostgreSQL (padrão: 5432, no meu caso: 5433)
- `Password=1234` → Sua senha do PostgreSQL

