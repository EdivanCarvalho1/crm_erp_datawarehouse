# Catálogo de Dados da Camada Gold

## Visão Geral

A camada Gold do nosso Data Warehouse é a camada final onde os dados são refinados, agregados e preparados para análises avançadas e relatórios. Esta camada é projetada para fornecer insights acionáveis e suportar decisões estratégicas de negócios.

### 1. gold.dim_customers

Propósito: Tabela de dimensão que contém informações detalhadas sobre os clientes.

| Coluna         | Tipo de Dados | Descrição                          |
|----------------|---------------|------------------------------------|
| customer_key  | BIGINT        | Chave primária da dimensão         |
| customer_id    | INT           | Identificador único do cliente     |
| first_name     | VARCHAR(50)   | Primeiro nome do cliente           |
| last_name      | VARCHAR(50)   | Sobrenome do cliente               |
|country        | VARCHAR(50)   | País de residência do cliente      |
| marital_status | VARCHAR(20)   | Estado civil do cliente            |
| gender         | VARCHAR(10)   | Gênero do cliente                  |
| create_date    | DATE    | Data de criação do registro        |
birthdate      | DATE          | Data de nascimento do cliente      |

### 2. gold.dim_products

Propósito: Tabela de dimensão que contém informações detalhadas sobre os produtos.

| Coluna         | Tipo de Dados | Descrição                          |
|----------------|---------------|------------------------------------|
| product_key   | BIGINT        | Chave primária da dimensão         |
| product_id     | INT           | Identificador único do produto     |
| product_number | VARCHAR(50)   | Número do produto                  |
| product_name   | VARCHAR(50)  | Nome do produto                    |
category_id | VARCHAR(50)   | Categoria do produto               |
| subcategory_id | VARCHAR(50)   | Subcategoria do produto            |
| maintenance    | VARCHAR(50)   | Status de manutenção do produto    |
| cost | NUMERIC(10,2) | Custo do produto                  |
| product_line | VARCHAR(50)   | Linha do produto                   |
| start_date | TIMESTAMP WITHOUT TIME ZONE | Data de início da disponibilidade do produto |

### 3. gold.fact_sales

Propósito: Tabela de fatos que contém dados de vendas agregados.

| Coluna         | Tipo de Dados | Descrição                          |
|----------------|---------------|------------------------------------| 
order_number | BIGINT        | Número do pedido                   |
product_key | BIGINT        | Chave estrangeira para dim_products|
customer_key | BIGINT        | Chave estrangeira para dim_customers|
order_date | TIMESTAMP WITHOUT TIME ZONE | Data do pedido                     |
shipping_date | TIMESTAMP WITHOUT TIME ZONE | Data de envio                     |
due_date | TIMESTAMP WITHOUT TIME ZONE | Data de vencimento do pagamento    |
sales_amount | INT           | Valor total da venda               |
quantity | INT           | Quantidade vendida                 |
price | INT           | Preço unitário do produto          |