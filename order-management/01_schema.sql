-- ============================================================
-- 実践MySQL（1）「テーブル設計とER図を描こう」
-- 受注管理システム：スキーマ定義とサンプルデータ
-- ============================================================

-- データベース作成（前回のcompany_dbとは別に作成する）
CREATE DATABASE order_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE order_db;

-- 顧客表
CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 商品表
CREATE TABLE products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    CHECK (unit_price >= 0),
    CHECK (stock_quantity >= 0)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 注文表
CREATE TABLE orders (
    order_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10) NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('受付', '出荷済', 'キャンセル') NOT NULL DEFAULT '受付',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 注文明細表
CREATE TABLE order_details (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(10) NOT NULL,
    product_id VARCHAR(10) NOT NULL,
    quantity INT NOT NULL,
    unit_price_at_order DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    CHECK (quantity > 0)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================================
-- サンプルデータ
-- ============================================================

-- 顧客データ
INSERT INTO customers (customer_id, customer_name, email, phone) VALUES
    ('C001', '山田太郎', 'yamada@example.com', '090-1111-1111'),
    ('C002', '佐藤花子', 'sato@example.com', '090-2222-2222'),
    ('C003', '鈴木一郎', 'suzuki@example.com', '090-3333-3333');

-- 商品データ
INSERT INTO products (product_id, product_name, unit_price, stock_quantity) VALUES
    ('P001', 'ノートパソコン', 98000.00, 15),
    ('P002', 'ワイヤレスマウス', 2500.00, 50),
    ('P003', 'USBメモリ 64GB', 1200.00, 100);

-- 注文データ
INSERT INTO orders (order_id, customer_id, status) VALUES
    ('O001', 'C001', '出荷済'),
    ('O002', 'C002', '受付'),
    ('O003', 'C001', '受付');

-- 注文明細データ
INSERT INTO order_details (order_id, product_id, quantity, unit_price_at_order) VALUES
    ('O001', 'P001', 1, 98000.00),
    ('O001', 'P002', 2, 2500.00),
    ('O002', 'P003', 5, 1200.00),
    ('O003', 'P002', 1, 2500.00);

-- ============================================================
-- 動作確認用クエリ
-- ============================================================

SHOW TABLES;

SELECT
    o.order_id,
    c.customer_name,
    p.product_name,
    od.quantity,
    od.unit_price_at_order,
    (od.quantity * od.unit_price_at_order) AS subtotal
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
ORDER BY o.order_id;