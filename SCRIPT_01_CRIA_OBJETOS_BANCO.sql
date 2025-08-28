/* ===========================================================
   BikeStores_v02 - DDL completo (SQL Server / T-SQL)
   (DROP + CREATE database, schemas, tables, PKs, FKs, índices)
   =========================================================== */

-- 0) Reiniciar banco (drop se existir)
IF DB_ID('BikeStores_v02') IS NOT NULL
BEGIN
    ALTER DATABASE BikeStores_v02 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE BikeStores_v02;
END
GO

-- 1) Criar banco e usar
CREATE DATABASE BikeStores_v02;
GO
USE BikeStores_v02;
GO

/* 2) Schemas */
CREATE SCHEMA production;
go
CREATE SCHEMA sales;
GO

/* =================== PRODUCTION =================== */

/* =================== PRODUCTION =================== */

-- Categories
CREATE TABLE production.categories (
    category_id   INT IDENTITY(1,1) CONSTRAINT PK_categories PRIMARY KEY,
    category_name NVARCHAR(255) NOT NULL
);
GO

-- Brands
CREATE TABLE production.brands (
    brand_id   INT IDENTITY(1,1) CONSTRAINT PK_brands PRIMARY KEY,
    brand_name NVARCHAR(255) NOT NULL
);
GO

-- Products
CREATE TABLE production.products (
    product_id   INT IDENTITY(1,1) CONSTRAINT PK_products PRIMARY KEY,
    product_name NVARCHAR(255) NOT NULL,
    brand_id     INT NOT NULL,
    category_id  INT NOT NULL,
    model_year   SMALLINT NOT NULL CONSTRAINT CK_products_model_year CHECK (model_year BETWEEN 1900 AND 2100),
    list_price   DECIMAL(10,2) NOT NULL CONSTRAINT CK_products_list_price CHECK (list_price >= 0)
);
GO

-- Stocks (estoque por loja e produto)
CREATE TABLE production.stocks (
    store_id   INT NOT NULL,
    product_id INT NOT NULL,
    quantity   INT NOT NULL CONSTRAINT DF_stocks_quantity DEFAULT (0)
                    CONSTRAINT CK_stocks_quantity CHECK (quantity >= 0),
    CONSTRAINT PK_stocks PRIMARY KEY (store_id, product_id)
);
GO

/* ====================== SALES ====================== */

-- Customers
CREATE TABLE sales.customers (
    customer_id INT IDENTITY(1,1) CONSTRAINT PK_customers PRIMARY KEY,
    first_name  NVARCHAR(50)  NOT NULL,
    last_name   NVARCHAR(50)  NOT NULL,
    phone       NVARCHAR(25)  NULL,
    email       NVARCHAR(100) NULL,
    street      NVARCHAR(255) NULL,
    city        NVARCHAR(100) NULL,
    state       NVARCHAR(50)  NULL,
    zip_code    NVARCHAR(15)  NULL
);
GO

-- Stores
CREATE TABLE sales.stores (
    store_id   INT IDENTITY(1,1) CONSTRAINT PK_stores PRIMARY KEY,
    store_name NVARCHAR(255) NOT NULL,
    phone      NVARCHAR(25)  NULL,
    email      NVARCHAR(100) NULL,
    street     NVARCHAR(255) NULL,
    city       NVARCHAR(100) NULL,
    state      NVARCHAR(50)  NULL,
    zip_code   NVARCHAR(15)  NULL
);
GO

-- Staffs (com auto-relacionamento em manager_id)
CREATE TABLE sales.staffs (
    staff_id   INT IDENTITY(1,1) CONSTRAINT PK_staffs PRIMARY KEY,
    first_name NVARCHAR(50)  NOT NULL,
    last_name  NVARCHAR(50)  NOT NULL,
    email      NVARCHAR(100) NOT NULL,
    phone      NVARCHAR(25)  NULL,
    active     BIT NOT NULL CONSTRAINT DF_staffs_active DEFAULT (1),
    store_id   INT NOT NULL,
    manager_id INT NULL
);
GO

-- Orders
CREATE TABLE sales.orders (
    order_id      INT IDENTITY(1,1) CONSTRAINT PK_orders PRIMARY KEY,
    customer_id   INT NOT NULL,
    order_status  TINYINT NOT NULL,      -- 1..N (status conforme convenção)
    order_date    DATE NOT NULL,
    required_date DATE NULL,
    shipped_date  DATE NULL,
    store_id      INT NOT NULL,
    staff_id      INT NOT NULL
);
GO

-- Order Items
CREATE TABLE sales.order_items (
    order_id   INT NOT NULL,
    item_id    INT NOT NULL,
    product_id INT NOT NULL,
    quantity   INT NOT NULL CONSTRAINT DF_order_items_quantity DEFAULT (1)
                    CONSTRAINT CK_order_items_quantity CHECK (quantity > 0),
    list_price DECIMAL(10,2) NOT NULL CONSTRAINT CK_order_items_price CHECK (list_price >= 0),
    discount   DECIMAL(4,2)  NOT NULL CONSTRAINT DF_order_items_discount DEFAULT (0)
                    CONSTRAINT CK_order_items_discount CHECK (discount BETWEEN 0 AND 1),
    CONSTRAINT PK_order_items PRIMARY KEY (order_id, item_id)
);
GO

/* =================== FOREIGN KEYS ================== */

-- products -> brands/categories
ALTER TABLE production.products
  ADD CONSTRAINT FK_products_brands
      FOREIGN KEY (brand_id)    REFERENCES production.brands(brand_id),
      CONSTRAINT FK_products_categories
      FOREIGN KEY (category_id) REFERENCES production.categories(category_id);

-- stocks -> stores/products
ALTER TABLE production.stocks
  ADD CONSTRAINT FK_stocks_stores
      FOREIGN KEY (store_id)   REFERENCES sales.stores(store_id),
      CONSTRAINT FK_stocks_products
      FOREIGN KEY (product_id) REFERENCES production.products(product_id);

-- staffs -> stores/manager
ALTER TABLE sales.staffs
  ADD CONSTRAINT FK_staffs_stores
      FOREIGN KEY (store_id)   REFERENCES sales.stores(store_id),
      CONSTRAINT FK_staffs_manager
      FOREIGN KEY (manager_id) REFERENCES sales.staffs(staff_id);

-- orders -> customers/stores/staffs
ALTER TABLE sales.orders
  ADD CONSTRAINT FK_orders_customers
      FOREIGN KEY (customer_id) REFERENCES sales.customers(customer_id),
      CONSTRAINT FK_orders_stores
      FOREIGN KEY (store_id)    REFERENCES sales.stores(store_id),
      CONSTRAINT FK_orders_staffs
      FOREIGN KEY (staff_id)    REFERENCES sales.staffs(staff_id);

-- order_items -> orders/products
ALTER TABLE sales.order_items
  ADD CONSTRAINT FK_order_items_orders
      FOREIGN KEY (order_id)   REFERENCES sales.orders(order_id),
      CONSTRAINT FK_order_items_products
      FOREIGN KEY (product_id) REFERENCES production.products(product_id);
GO

/* ====================== ÍNDICES ===================== */
CREATE INDEX IX_orders_customer_id ON sales.orders(customer_id);
CREATE INDEX IX_orders_store_id    ON sales.orders(store_id);
CREATE INDEX IX_orders_staff_id    ON sales.orders(staff_id);

CREATE INDEX IX_order_items_product_id ON sales.order_items(product_id);
CREATE INDEX IX_order_items_order_id   ON sales.order_items(order_id);

CREATE INDEX IX_products_brand_id    ON production.products(brand_id);
CREATE INDEX IX_products_category_id ON production.products(category_id);

CREATE INDEX IX_stocks_store_id   ON production.stocks(store_id);
CREATE INDEX IX_stocks_product_id ON production.stocks(product_id);
GO