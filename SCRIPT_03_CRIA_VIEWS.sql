USE BikeStores_v02;
GO

/* ===========================================================
   1) Clientes que NÃO realizaram nenhuma compra
   =========================================================== */
IF OBJECT_ID('sales.vw_customers_no_orders','V') IS NOT NULL
    DROP VIEW sales.vw_customers_no_orders;
GO
CREATE VIEW sales.vw_customers_no_orders
AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.phone,
    c.email,
    c.city,
    c.state,
    c.zip_code
FROM sales.customers AS c
LEFT JOIN sales.orders AS o
       ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;
GO


/* ===========================================================
   2) Produtos que NUNCA foram comprados
   =========================================================== */
IF OBJECT_ID('sales.vw_products_never_purchased','V') IS NOT NULL
    DROP VIEW sales.vw_products_never_purchased;
GO
CREATE VIEW sales.vw_products_never_purchased
AS
SELECT 
    p.product_id,
    p.product_name,
    p.brand_id,
    p.category_id,
    p.model_year,
    p.list_price
FROM production.products AS p
LEFT JOIN sales.order_items AS oi
       ON oi.product_id = p.product_id
WHERE oi.product_id IS NULL;
GO


/* ===========================================================
   3) Produtos SEM estoque (somando todas as lojas)
   =========================================================== */
IF OBJECT_ID('sales.vw_products_without_stock','V') IS NOT NULL
    DROP VIEW sales.vw_products_without_stock;
GO
CREATE VIEW sales.vw_products_without_stock
AS
SELECT 
    p.product_id,
    p.product_name,
    p.brand_id,
    p.category_id
FROM production.products AS p
LEFT JOIN production.stocks AS s
       ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.brand_id, p.category_id
HAVING COALESCE(SUM(s.quantity), 0) = 0;
GO
-- (Se quiser por loja específica, filtre por store_id ao consultar:
--   SELECT * FROM sales.vw_products_without_stock pw
--   JOIN production.stocks s ON s.product_id = pw.product_id
--   WHERE s.store_id = 1 )


/* ===========================================================
   4) Vendas (unidades e receita) POR MARCA e POR LOJA
   =========================================================== */
IF OBJECT_ID('sales.vw_sales_by_brand_store','V') IS NOT NULL
    DROP VIEW sales.vw_sales_by_brand_store;
GO
CREATE VIEW sales.vw_sales_by_brand_store
AS
SELECT
    st.store_id,
    st.store_name,
    b.brand_id,
    b.brand_name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.list_price * (1 - ISNULL(oi.discount,0))) AS revenue,
    COUNT(DISTINCT o.order_id) AS orders
FROM sales.orders        AS o
JOIN sales.order_items   AS oi ON oi.order_id   = o.order_id
JOIN production.products AS p  ON p.product_id  = oi.product_id
JOIN production.brands   AS b  ON b.brand_id    = p.brand_id
JOIN sales.stores        AS st ON st.store_id   = o.store_id
GROUP BY st.store_id, st.store_name, b.brand_id, b.brand_name;
GO
-- Ex.: uma marca específica (brand_id = 3)
-- SELECT * FROM sales.vw_sales_by_brand_store WHERE brand_id = 3 ORDER BY revenue DESC;


/* ===========================================================
   5) Funcionários SEM pedidos relacionados
   =========================================================== */
IF OBJECT_ID('sales.vw_staff_without_orders','V') IS NOT NULL
    DROP VIEW sales.vw_staff_without_orders;
GO
CREATE VIEW sales.vw_staff_without_orders
AS
SELECT 
    s.staff_id,
    s.first_name,
    s.last_name,
    s.email,
    s.phone,
    s.active,
    s.store_id
FROM sales.staffs AS s
LEFT JOIN sales.orders AS o
       ON o.staff_id = s.staff_id
WHERE o.order_id IS NULL;
GO
