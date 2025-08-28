DBA Challenge 20240802 — BikeStores (SQL Server)
================================================

Consultas e objetos SQL para gerar métricas de Marketing e Comercial a partir do modelo BikeStores. 
O projeto inclui: script de criação do banco, carga de dados de teste e views que respondem diretamente às consultas solicitadas.

Stack / Tecnologias
-------------------
- Banco / Linguagem: SQL Server · T-SQL
- Ferramentas sugeridas: SQL Server Management Studio (SSMS) ou Azure Data Studio
- Scripts principais:
  - SCRIPT_01_CRIA_OBJETOS_BANCO.sql — Cria o banco BikeStores_v02, schemas production e sales, tabelas, PKs/FKs, checks e índices.
  - SCRIPT_02_GERA_DADOS_TESTE.sql — Popula dados de teste realistas (marcas, categorias, produtos, lojas, staffs, clientes, estoques, pedidos e itens).
  - SCRIPT_03_CRIA_VIEWS.sql — Cria as views que respondem ao enunciado (clientes sem compra, produtos nunca comprados, produtos sem estoque, vendas por marca/loja, staffs sem pedidos).

Estrutura sugerida do repositório
---------------------------------
/sql
  SCRIPT_01_CRIA_OBJETOS_BANCO.sql
  SCRIPT_02_GERA_DADOS_TESTE.sql
  SCRIPT_03_CRIA_VIEWS.sql
README.txt
.gitignore

Como instalar e usar
--------------------
1) Crie/Recrie o banco
   - Abra o SCRIPT_01_CRIA_OBJETOS_BANCO.sql no SSMS/Azure Data Studio e execute.
   - O script derruba o banco BikeStores_v02 (se existir) e recria todos os objetos do diagrama.

2) Carregue os dados de teste
   - Execute o SCRIPT_02_GERA_DADOS_TESTE.sql.
   - Ele limpa as tabelas, faz reseeding das identities e insere centenas de registros coerentes (inclusive ~2.000 pedidos e itens).

3) Crie as views do enunciado
   - Execute o SCRIPT_03_CRIA_VIEWS.sql.
   - As views ficam no schema sales e podem ser consultadas diretamente.

4) Consultar os resultados (exemplos rápidos)
   - SELECT * FROM sales.vw_customers_no_orders;
   - SELECT * FROM sales.vw_products_never_purchased;
   - SELECT * FROM sales.vw_products_without_stock;
   - SELECT * FROM sales.vw_sales_by_brand_store ORDER BY revenue DESC;
   - SELECT * FROM sales.vw_staff_without_orders;

Consultas respondidas do enunciado
----------------------------------
1. Clientes que não compraram -> sales.vw_customers_no_orders
2. Produtos nunca comprados -> sales.vw_products_never_purchased
3. Produtos sem estoque -> sales.vw_products_without_stock
4. Vendas por marca e por loja -> sales.vw_sales_by_brand_store
5. Funcionários sem pedidos -> sales.vw_staff_without_orders

.gitignore sugerido
-------------------
# SO / IDE
.DS_Store
Thumbs.db
.vscode/
.idea/
*.code-workspace

# Logs / dumps / backups
*.log
*.bak
*.trn
*.tmp
*.temp

# Artefatos
/out/
/build/
/dist/

# Segredos (se houver scripts auxiliares)
.env
.env.*

Entrega e apresentação
----------------------
- Publique este repositório no seu GitHub e adicione o link da solução na plataforma do teste.
- Revise se este README cobre o que foi pedido e faça o commit final.
- Caso o teste peça apresentação em vídeo, use a tela de entrega para gravar após enviar o link do repo.
- This is a challenge by Coodesh



### Exemplo — Clientes sem compras  
`SELECT * FROM sales.vw_customers_no_orders;`

| customer_id | first_name | last_name | phone         | email                 | city           | state | zip_code |
|-------------|------------|-----------|---------------|-----------------------|----------------|-------|----------|
| 1           | Cliente1   | Souza     | 55-9212334031 | cliente1@example.com  | Campinas       | SP    | 46154-578|
| 51          | Cliente51  | Souza     | 55-9036885155 | cliente51@example.com | São Paulo      | SP    | 85523-077|
| 75          | Cliente75  | Silva     | 55-9042192062 | cliente75@example.com | Curitiba       | PR    | 02484-297|
| 148         | Cliente148 | Silva     | 55-9572463332 | cliente148@example.com| Curitiba       | PR    | 79056-369|
| 152         | Cliente152 | Silva     | 55-9806701024 | cliente152@example.com| Belo Horizonte | MG    | 09091-532|
| 166         | Cliente166 | Silva     | 55-9615190984 | cliente166@example.com| Belo Horizonte | MG    | 97135-790|
| 181         | Cliente181 | Silva     | 55-9664743566 | cliente181@example.com| Campinas       | SP    | 60213-975|
| 262         | Cliente262 | Silva     | 55-9567605394 | cliente262@example.com| Belo Horizonte | MG    | 11070-567|
| 284         | Cliente284 | Silva     | 55-9990093260 | cliente284@example.com| São Paulo      | SP    | 13161-345|
| 371         | Cliente371 | Souza     | 55-9690831305 | cliente371@example.com| São Paulo      | SP    | 38213-827|
| 392         | Cliente392 | Silva     | 55-9223940182 | cliente392@example.com| Curitiba       | PR    | 52421-347|


### Exemplo — Produtos nunca comprados  
`SELECT * FROM sales.vw_products_never_purchased;`

| product_id | product_name       | brand_id | category_id | model_year | list_price |
|------------|-------------------|----------|-------------|------------|------------|
| 1          | Product 1 - Sport | 8        | 6           | 2020       | 5136.50    |
| 2          | Product 2 - Pro   | 5        | 3           | 2020       | 3974.00    |
| 3          | Product 3 - Elite | 6        | 5           | 2018       | 8661.50    |
| 4          | Product 4 - Sport | 8        | 4           | 2018       | 7611.50    |
| 5          | Product 5 - Pro   | 5        | 6           | 2019       | 3524.00    |
| 6          | Product 6 - Pro   | 1        | 1           | 2019       | 824.00     |
| 7          | Product 7 - Elite | 2        | 6           | 2019       | 561.50     |
| 8          | Product 8 - Comp  | 7        | 6           | 2019       | 7799.00    |
| 9          | Product 9 - Pro   | 1        | 5           | 2019       | 6974.00    |
| 10         | Product 10 - Comp | 3        | 4           | 2019       | 449.00     |
| 11         | Product 11 - Elite| 2        | 1           | 2018       | 9036.50    |
| 12         | Product 12 - Pro  | 5        | 4           | 2018       | 9599.00    |
| 13         | Product 13 - Pro  | 5        | 1           | 2018       | 674.00     |
| 14         | Product 14 - Elite| 6        | 1           | 2019       | 6711.50    |
| 15         | Product 15 - Sport| 4        | 1           | 2018       | 711.50     |



 ### Exemplo — Vendas de uma marca por loja  
`SELECT * FROM sales.vw_sales_by_brand_store WHERE brand_id = 8;`

| store_id | store_name     | brand_id | brand_name | units_sold | revenue        | orders |
|----------|----------------|----------|------------|------------|----------------|--------|
| 1        | Centro Bikes   | 8        | Audax      | 2172       | 11644697.20    | 424    |
| 5        | Rio Bikes      | 8        | Audax      | 2005       | 10739708.90    | 384    |
| 2        | Zona Sul Bikes | 8        | Audax      | 2002       | 10725379.00    | 403    |
| 3        | Campinas Bikes | 8        | Audax      | 1941       | 10410672.35    | 396    |
| 4        | Curitiba Bikes | 8        | Audax      | 1883       | 10077226.60    | 393    |



### Exemplo — Funcionários sem pedidos  
`SELECT * FROM sales.vw_staff_without_orders;`

| staff_id | first_name | last_name | email                       | phone        | active | store_id |
|----------|------------|-----------|-----------------------------|--------------|--------|----------|
| 1        | Gerente1   | Store     | gerente1@bikestores.local   | 55-9000000001| 1      | 1        |
| 2        | Gerente2   | Store     | gerente2@bikestores.local   | 55-9000000002| 1      | 2        |
| 3        | Gerente3   | Store     | gerente3@bikestores.local   | 55-9000000003| 1      | 3        |
| 4        | Gerente4   | Store     | gerente4@bikestores.local   | 55-9000000004| 1      | 4        |
| 6        | Vend1-1    | Sales     | vend1-1@bikestores.local    | 55-9543580471| 1      | 1        |
| 8        | Vend1-3    | Sales     | vend1-3@bikestores.local    | 55-9728492487| 1      | 1        |
| 10       | Vend2-2    | Sales     | vend2-2@bikestores.local    | 55-9815247039| 1      | 2        |
| 11       | Vend2-3    | Sales     | vend2-3@bikestores.local    | 55-9030032433| 1      | 2        |
| 12       | Vend3-1    | Sales     | vend3-1@bikestores.local    | 55-9800488346| 1      | 3        |
| 14       | Vend3-3    | Sales     | vend3-3@bikestores.local    | 55-9332665343| 1      | 3        |
| 15       | Vend4-1    | Sales     | vend4-1@bikestores.local    | 55-9370250255| 1      | 4        |
| 16       | Vend4-2    | Sales     | vend4-2@bikestores.local    | 55-9872309187| 1      | 4        |
| 17       | Vend4-3    | Sales     | vend4-3@bikestores.local    | 55-9281204513| 1      | 4        |
| 19       | Vend5-1    | Sales     | vend5-1@bikestores.local    | 55-9015193934| 1      | 5        |
| 20       | Vend5-2    | Sales     | vend5-2@bikestores.local    | 55-9479979380| 1      | 5        |
| 21       | Vend5-3    | Sales     | vend5-3@bikestores.local    | 55-9735351539| 1      | 5        |











||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||
||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||
||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||
||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||
 ------------------------------------------------------------------------------------------------------------------------------------------------

# DBA Challenge 20240802


## Introdução

Nesse desafio trabalharemos utilizando a base de dados da empresa Bike Stores Inc com o objetivo de obter métricas relevantes para equipe de Marketing e Comercial.

Com isso, teremos que trabalhar com várioas consultas utilizando conceitos como `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `GROUP BY` e `COUNT`.

### Antes de começar
 
- O projeto deve utilizar a Linguagem específica na avaliação. Por exempo: SQL, T-SQL, PL/SQL e PSQL;
- Considere como deadline da avaliação a partir do início do teste. Caso tenha sido convidado a realizar o teste e não seja possível concluir dentro deste período, avise a pessoa que o convidou para receber instruções sobre o que fazer.
- Documentar todo o processo de investigação para o desenvolvimento da atividade (README.md no seu repositório); os resultados destas tarefas são tão importantes do que o seu processo de pensamento e decisões à medida que as completa, por isso tente documentar e apresentar os seus hipóteses e decisões na medida do possível.
 
 

## O projeto

- Criar as consultas utilizando a linguagem escolhida;
- Entregar o código gerado do Teste.

### Modelo de Dados:

Para entender o modelo, revisar o diagrama a seguir:

![<img src="samples/model.png" height="500" alt="Modelo" title="Modelo"/>](samples/model.png)


## Selects

Construir as seguintes consultas:

- Listar todos Clientes que não tenham realizado uma compra;
- Listar os Produtos que não tenham sido comprados
- Listar os Produtos sem Estoque;
- Agrupar a quantidade de vendas que uma determinada Marca por Loja. 
- Listar os Funcionarios que não estejam relacionados a um Pedido.

## Readme do Repositório

- Deve conter o título do projeto
- Uma descrição sobre o projeto em frase
- Deve conter uma lista com linguagem, framework e/ou tecnologias usadas
- Como instalar e usar o projeto (instruções)
- Não esqueça o [.gitignore](https://www.toptal.com/developers/gitignore)
- Se está usando github pessoal, referencie que é um challenge by coodesh:  

>  This is a challenge by [Coodesh](https://coodesh.com/)

## Finalização e Instruções para a Apresentação

1. Adicione o link do repositório com a sua solução no teste
2. Verifique se o Readme está bom e faça o commit final em seu repositório;
3. Envie e aguarde as instruções para seguir. Caso o teste tenha apresentação de vídeo, dentro da tela de entrega será possível gravar após adicionar o link do repositório. Sucesso e boa sorte. =)


## Suporte

Para tirar dúvidas sobre o processo envie uma mensagem diretamente a um especialista no chat da plataforma. 
