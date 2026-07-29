-- ============================================================
-- MySQLで学ぶ受注管理システム開発（2）「CRUD操作を極めよう」
-- CRUD操作とトランザクションの実践例
-- 前提：01_schema.sql を実行済みであること
-- ============================================================

USE order_db;

-- ============================================================
-- 1. 新規登録（INSERT）
-- ============================================================

-- 新規顧客の登録
INSERT INTO customers (customer_id, customer_name, email, phone) VALUES
    ('C004', '高橋健太', 'takahashi@example.com', '090-4444-4444');

-- 新規商品の登録
INSERT INTO products (product_id, product_name, unit_price, stock_quantity) VALUES
    ('P004', 'ワイヤレスキーボード', 3800.00, 30);

-- ------------------------------------------------------------
-- 注文をトランザクションでまとめて登録する
-- （注文ヘッダー → 注文明細 → 在庫減算 の3処理を一括で確定させる）
-- ------------------------------------------------------------

START TRANSACTION;

-- 1. 注文ヘッダーを登録
INSERT INTO orders (order_id, customer_id, status) VALUES
    ('O004', 'C004', '受付');

-- 2. 注文明細を登録（ワイヤレスキーボードを2個注文）
INSERT INTO order_details (order_id, product_id, quantity, unit_price_at_order) VALUES
    ('O004', 'P004', 2, 3800.00);

-- 3. 在庫数を減算
UPDATE products
SET stock_quantity = stock_quantity - 2
WHERE product_id = 'P004';

-- ここまでの処理をすべて確定させる
COMMIT;

-- ------------------------------------------------------------
-- 在庫不足時のROLLBACK例
-- （P001の在庫は15個しかないため、100個の注文には対応できない想定）
-- ------------------------------------------------------------

START TRANSACTION;

-- 在庫を確認する（15個 → 100個の注文には対応できないと判断）
SELECT stock_quantity FROM products WHERE product_id = 'P001';

-- 在庫不足のため、ここまでの処理をすべて取り消す
ROLLBACK;

-- ============================================================
-- 2. 更新（UPDATE）
-- ============================================================

-- 注文ステータスの更新（O002を出荷済みに）
UPDATE orders
SET status = '出荷済'
WHERE order_id = 'O002';

-- 複数列をまとめて更新（価格と在庫を同時に更新）
UPDATE products
SET unit_price = 2300.00,
    stock_quantity = stock_quantity + 20
WHERE product_id = 'P003';

-- ============================================================
-- 3. 削除（DELETE）
-- ============================================================

-- 外部キー制約により、子レコード（注文明細）が残ったままでは
-- 親レコード（注文）を削除できない（下記はエラーになる例）
--
-- DELETE FROM orders WHERE order_id = 'O001';
-- → ERROR 1451 (23000): Cannot delete or update a parent row:
--    a foreign key constraint fails

-- 正しい削除手順：先に子テーブル、その後に親テーブル
DELETE FROM order_details WHERE order_id = 'O001';
DELETE FROM orders WHERE order_id = 'O001';

-- 論理削除（物理削除の代わりにステータスを変更する）
UPDATE orders
SET status = 'キャンセル'
WHERE order_id = 'O003';

-- ============================================================
-- 動作確認
-- ============================================================

SELECT order_id, customer_id, status FROM orders ORDER BY order_id;