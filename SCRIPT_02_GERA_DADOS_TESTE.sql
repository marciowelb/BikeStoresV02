/* ===========================================================
   BikeStores – Seed de Dados de Teste (SQL Server / T-SQL)
   Gera dados realistas para todas as tabelas
   =========================================================== */
USE BikeStores_v02;
GO

/* ===========================================================
   BikeStores – Seed de Dados de Teste (SQL Server / T-SQL)
   Gera dados realistas para todas as tabelas
   =========================================================== */
 
GO

SET NOCOUNT ON;

/* 1) Limpeza (ordem por dependência) ----------------------- */
IF OBJECT_ID('sales.order_items','U') IS NOT NULL DELETE FROM sales.order_items;
IF OBJECT_ID('sales.orders','U')       IS NOT NULL DELETE FROM sales.orders;
IF OBJECT_ID('production.stocks','U')  IS NOT NULL DELETE FROM production.stocks;
IF OBJECT_ID('sales.staffs','U')       IS NOT NULL DELETE FROM sales.staffs;
IF OBJECT_ID('sales.stores','U')       IS NOT NULL DELETE FROM sales.stores;
IF OBJECT_ID('sales.customers','U')    IS NOT NULL DELETE FROM sales.customers;
IF OBJECT_ID('production.products','U')IS NOT NULL DELETE FROM production.products;
IF OBJECT_ID('production.brands','U')  IS NOT NULL DELETE FROM production.brands;
IF OBJECT_ID('production.categories','U') IS NOT NULL DELETE FROM production.categories;

-- Reseed identities
IF OBJECT_ID('production.brands','U')      IS NOT NULL DBCC CHECKIDENT ('production.brands', RESEED, 0)    WITH NO_INFOMSGS;
IF OBJECT_ID('production.categories','U')  IS NOT NULL DBCC CHECKIDENT ('production.categories', RESEED, 0)WITH NO_INFOMSGS;
IF OBJECT_ID('production.products','U')    IS NOT NULL DBCC CHECKIDENT ('production.products', RESEED, 0)  WITH NO_INFOMSGS;
IF OBJECT_ID('sales.customers','U')        IS NOT NULL DBCC CHECKIDENT ('sales.customers', RESEED, 0)      WITH NO_INFOMSGS;
IF OBJECT_ID('sales.stores','U')           IS NOT NULL DBCC CHECKIDENT ('sales.stores', RESEED, 0)         WITH NO_INFOMSGS;
IF OBJECT_ID('sales.staffs','U')           IS NOT NULL DBCC CHECKIDENT ('sales.staffs', RESEED, 0)         WITH NO_INFOMSGS;
IF OBJECT_ID('sales.orders','U')           IS NOT NULL DBCC CHECKIDENT ('sales.orders', RESEED, 0)         WITH NO_INFOMSGS;
-- order_items e stocks não têm IDENTITY
GO

/* 2) Tabelas de domínio: Brands & Categories --------------- */
INSERT INTO production.brands (brand_name) VALUES
 (N'Trek'), (N'Cannondale'), (N'Specialized'), (N'Giant'),
 (N'Scott'), (N'BMC'), (N'Caloi'), (N'Audax');

INSERT INTO production.categories (category_name) VALUES
 (N'Road'), (N'Mountain'), (N'Hybrid'), (N'BMX'),
 (N'Kids'), (N'Accessories');
GO

/* 3) Products (100 produtos combinando marcas/categorias) --- */
;WITH
nums AS (
    SELECT TOP (100) ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS n
    FROM sys.all_objects
),
randset AS (
    SELECT
        n,
        -- escolhas pseudo-aleatórias estáveis por linha
        ABS(CHECKSUM(NEWID())) AS r
    FROM nums
)
INSERT INTO production.products (product_name, brand_id, category_id, model_year, list_price)
SELECT
    CONCAT(N'Product ', n, N' - ', 
           CASE (r % 4) WHEN 0 THEN N'Pro' WHEN 1 THEN N'Elite' WHEN 2 THEN N'Comp' ELSE N'Sport' END) AS product_name,
    (r % (SELECT COUNT(*) FROM production.brands)) + 1           AS brand_id,
    (r / 7 % (SELECT COUNT(*) FROM production.categories)) + 1    AS category_id,
    2018 + (r % 3)                                                AS model_year,  -- 2018..2020
    CAST( 299.00 + ((r % 250) * 37.5) AS DECIMAL(10,2))           AS list_price
FROM randset
ORDER BY n;
GO

/* 4) Stores ------------------------------------------------- */
INSERT INTO sales.stores (store_name, phone, email, street, city, state, zip_code) VALUES
 (N'Centro Bikes',   N'11-1111-1111', N'centro@bikestores.local',  N'Rua A, 100', N'São Paulo', N'SP', N'01000-000'),
 (N'Zona Sul Bikes', N'11-2222-2222', N'zsul@bikestores.local',    N'Rua B, 200', N'São Paulo', N'SP', N'04000-000'),
 (N'Campinas Bikes', N'19-3333-3333', N'cps@bikestores.local',     N'Av. C, 300', N'Campinas',  N'SP', N'13000-000'),
 (N'Curitiba Bikes', N'41-4444-4444', N'ctba@bikestores.local',    N'Rua D, 400', N'Curitiba',  N'PR', N'80000-000'),
 (N'Rio Bikes',      N'21-5555-5555', N'rio@bikestores.local',     N'Rua E, 500', N'Rio',       N'RJ', N'20000-000');
GO



/* 5) Staffs (1 gerente por loja + 2-5 vendedores) ---------- */
-- Gerentes
INSERT INTO sales.staffs (first_name, last_name, email, phone, active, store_id, manager_id)
SELECT
    CONCAT(N'Gerente', store_id) AS first_name,
    N'Store' AS last_name,
    CONCAT(N'gerente', store_id, N'@bikestores.local') AS email,
    CONCAT(N'55-9', RIGHT('000000000' + CAST(store_id AS varchar(9)), 9)) AS phone,
    1, store_id, NULL
FROM sales.stores;

-- Vendedores (quantidade variável por loja)
;WITH tally AS (
    SELECT TOP (20) ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS n
    FROM sys.all_objects
),
stores AS (
    SELECT s.store_id, m.staff_id AS manager_id
    FROM sales.stores s
    JOIN sales.staffs m ON m.store_id = s.store_id AND m.manager_id IS NULL
)
INSERT INTO sales.staffs (first_name, last_name, email, phone, active, store_id, manager_id)
SELECT
    CONCAT(N'Vend', s.store_id, N'-', t.n) AS first_name,
    N'Sales' AS last_name,
    CONCAT(N'vend', s.store_id, N'-', t.n, N'@bikestores.local') AS email,
    CONCAT(N'55-9', RIGHT('000000000' + CAST(ABS(CHECKSUM(NEWID())) % 1000000000 AS varchar(9)), 9)) AS phone,
    1,
    s.store_id,
    s.manager_id
FROM stores s
JOIN tally t
  ON t.n <= (2 + ABS(CHECKSUM(NEWID())) % 4);  -- 2..5 por loja
GO












/* 6) Customers (500 clientes) ------------------------------ */
;WITH tally AS (
    SELECT TOP (500) ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS n
    FROM sys.all_objects
),
rnd AS (
    SELECT n, ABS(CHECKSUM(NEWID())) AS r FROM tally
)
INSERT INTO sales.customers (first_name, last_name, phone, email, street, city, state, zip_code)
SELECT
    CONCAT(N'Cliente', n) AS first_name,
    CASE WHEN r % 2 = 0 THEN N'Silva' ELSE N'Souza' END AS last_name,
    CONCAT(N'55-9', RIGHT('000000000' + CAST(r % 1000000000 AS varchar(9)), 9)) AS phone,
    CONCAT(N'cliente', n, N'@example.com') AS email,
    CONCAT(N'Rua ', (r % 5000) + 1) AS street,
    CASE r % 5 WHEN 0 THEN N'São Paulo' WHEN 1 THEN N'Campinas' WHEN 2 THEN N'Curitiba' WHEN 3 THEN N'Rio' ELSE N'Belo Horizonte' END AS city,
    CASE r % 5 WHEN 0 THEN N'SP' WHEN 1 THEN N'SP' WHEN 2 THEN N'PR' WHEN 3 THEN N'RJ' ELSE N'MG' END AS state,
    CONCAT(RIGHT('00000' + CAST(r % 99999 AS varchar(5)),5), N'-', RIGHT('000' + CAST(r % 999 AS varchar(3)),3)) AS zip_code
FROM rnd
ORDER BY n;
GO





/* 7) Stocks (estoque por loja/produto – cobertura ~60%) ---- */
;WITH p AS (SELECT product_id FROM production.products),
s AS (SELECT store_id FROM sales.stores),
crossed AS (
    SELECT s.store_id, p.product_id,
           ABS(CHECKSUM(NEWID())) AS r
    FROM s CROSS JOIN p
)
INSERT INTO production.stocks (store_id, product_id, quantity)
SELECT store_id, product_id,
       (r % 50)  -- 0..49
FROM crossed
WHERE r % 5 <> 0; -- ~80% dos pares; deixe alguns sem estoque
GO




/* 8) Orders (? 2.000 pedidos entre 2018 e 2020) ------------ */
;WITH tally AS (
    SELECT TOP (2000) ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS n
    FROM sys.all_objects
),
randrow AS (
    SELECT n,
           ABS(CHECKSUM(NEWID())) AS r
    FROM tally
),
base_order AS (
    SELECT
        n,
        ((r % (SELECT COUNT(*) FROM sales.customers)) + 1) AS customer_id,
        ((r / 7 % (SELECT COUNT(*) FROM sales.stores)) + 1) AS store_id,
        CAST(DATEADD(DAY, r % 1096, '2018-01-01') AS date)  AS order_date,  -- dentro de 2018..2020
        (r % 4) + 1 AS order_status,
        r
    FROM randrow
),
order_with_staff AS (
    SELECT
        b.n, b.customer_id, b.store_id, b.order_date, b.order_status, b.r,
        (SELECT TOP 1 staff_id
         FROM sales.staffs st
         WHERE st.store_id = b.store_id
         ORDER BY NEWID()) AS staff_id
    FROM base_order b
)
INSERT INTO sales.orders (customer_id, order_status, order_date, required_date, shipped_date, store_id, staff_id)
SELECT
    customer_id,
    order_status,
    order_date,
    DATEADD(DAY, 5 + (r % 6), order_date) AS required_date,      -- +5..+10 dias
    CASE WHEN r % 10 = 0
         THEN NULL                                             -- ~10% ainda não enviados
         ELSE DATEADD(DAY, 1 + (r % 7), order_date)            -- +1..+7 dias
    END AS shipped_date,
    store_id,
    staff_id
FROM order_with_staff
ORDER BY n;
GO





/* 9) Order Items (1..4 itens por pedido) — versão robusta */
;WITH orders AS (
    SELECT o.order_id, o.store_id
    FROM sales.orders o
),
item_counts AS (  -- quantidade de itens por pedido
    SELECT order_id,
           1 + ABS(CHECKSUM(NEWID())) % 4 AS item_count  -- 1..4
    FROM orders
),
expanded AS (     -- gera linhas i=1..item_count por pedido
    SELECT ic.order_id, o.store_id, v.i
    FROM item_counts ic
    JOIN orders o ON o.order_id = ic.order_id
    CROSS APPLY (VALUES (1),(2),(3),(4)) AS v(i)
    WHERE v.i <= ic.item_count
),
pick_products AS (
    SELECT e.order_id, e.store_id, e.i,
           (SELECT TOP 1 p.product_id
            FROM production.products p
            ORDER BY NEWID()) AS product_id
    FROM expanded e
),
priced AS (
    SELECT pp.order_id, pp.store_id, pp.i, pp.product_id,
           pr.list_price,
           1 + ABS(CHECKSUM(NEWID())) % 3 AS qty,                 -- 1..3
           CASE ABS(CHECKSUM(NEWID())) % 5
                WHEN 0 THEN 0.10
                WHEN 1 THEN 0.05
                ELSE 0.00
           END AS discount
    FROM pick_products pp
    JOIN production.products pr ON pr.product_id = pp.product_id
)
INSERT INTO sales.order_items (order_id, item_id, product_id, quantity, list_price, discount)
SELECT
    order_id,
    ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY i) AS item_id,
    product_id,
    qty,
    list_price,
    discount
FROM priced
ORDER BY order_id, item_id;
GO



/* 10) Sanidade rápida -------------------------------------- */

-- Quantitativos
SELECT
  (SELECT COUNT(*) FROM production.brands)      AS brands,
  (SELECT COUNT(*) FROM production.categories)  AS categories,
  (SELECT COUNT(*) FROM production.products)    AS products,
  (SELECT COUNT(*) FROM sales.stores)           AS stores,
  (SELECT COUNT(*) FROM sales.staffs)           AS staffs,
  (SELECT COUNT(*) FROM sales.customers)        AS customers,
  (SELECT COUNT(*) FROM production.stocks)      AS stocks,
  (SELECT COUNT(*) FROM sales.orders)           AS orders,
  (SELECT COUNT(*) FROM sales.order_items)      AS order_items;

-- Receita total gerada (para conferir)
SELECT
  SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS revenue_total
FROM sales.order_items oi;

-- Top 5 lojas por receita
SELECT TOP (5)
  o.store_id, s.store_name,
  SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS revenue
FROM sales.orders o
JOIN sales.order_items oi ON oi.order_id = o.order_id
JOIN sales.stores s ON s.store_id = o.store_id
GROUP BY o.store_id, s.store_name
ORDER BY revenue DESC;
GO
