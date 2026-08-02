-- ============================================================
-- MySQLで学ぶ受注管理システム開発（3）「ビューとストアドプロシージャを作ろう」
-- ビュー・ストアドプロシージャの実践例
-- 前提：01_schema.sql、02_crud.sql を実行済みであること
-- ============================================================

USE order_db;

-- ============================================================
-- 1. ビュー（VIEW）
-- ============================================================

-- 注文・顧客・商品を結合した詳細ビュー
DROP VIEW IF EXISTS order_full_details;
CREATE VIEW order_full_details AS
SELECT
    o.order_id,
    o.order_date,
    o.status,
    c.customer_id,
    c.customer_name,
    p.product_id,
    p.product_name,
    od.quantity,
    od.unit_price_at_order,
    (od.quantity * od.unit_price_at_order) AS subtotal
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id;

-- 顧客別の注文集計ビュー（キャンセルは集計から除外）
DROP VIEW IF EXISTS customer_order_summary;
CREATE VIEW customer_order_summary AS
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS order_count,
    COALESCE(SUM(od.quantity * od.unit_price_at_order), 0) AS total_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.status <> 'キャンセル'
LEFT JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.customer_id, c.customer_name;

-- 動作確認
-- SELECT * FROM order_full_details WHERE customer_id = 'C001';
-- SELECT * FROM customer_order_summary ORDER BY total_amount DESC;

-- ============================================================
-- 2. ストアドプロシージャ
-- ============================================================

-- 顧客の注文履歴を取得するプロシージャ
DROP PROCEDURE IF EXISTS GetCustomerOrders;
DELIMITER //

CREATE PROCEDURE GetCustomerOrders(IN p_customer_id VARCHAR(10))
BEGIN
    SELECT order_id, order_date, status, product_name, quantity, subtotal
    FROM order_full_details
    WHERE customer_id = p_customer_id
    ORDER BY order_date DESC;
END //

DELIMITER ;

-- 動作確認
-- CALL GetCustomerOrders('C001');

-- ------------------------------------------------------------
-- 注文登録プロシージャ
-- （注文ヘッダー登録 → 明細登録 → 在庫減算 を1つの処理にまとめる）
-- 在庫不足の場合は自動的にロールバックする
-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS CreateOrder;
DELIMITER //

CREATE PROCEDURE CreateOrder(
    IN p_order_id VARCHAR(10),
    IN p_customer_id VARCHAR(10),
    IN p_product_id VARCHAR(10),
    IN p_quantity INT
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_price DECIMAL(10, 2);

    -- エラー発生時は自動的にロールバックする
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- 在庫と単価を確認（同時実行対策として行ロックをかける）
    SELECT stock_quantity, unit_price INTO v_stock, v_price
    FROM products
    WHERE product_id = p_product_id
    FOR UPDATE;

    -- 在庫不足の場合はエラーを発生させる
    IF v_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '在庫が不足しています';
    END IF;

    -- 注文ヘッダーを登録
    INSERT INTO orders (order_id, customer_id, status)
    VALUES (p_order_id, p_customer_id, '受付');

    -- 注文明細を登録
    INSERT INTO order_details (order_id, product_id, quantity, unit_price_at_order)
    VALUES (p_order_id, p_product_id, p_quantity, v_price);

    -- 在庫を減算
    UPDATE products
    SET stock_quantity = stock_quantity - p_quantity
    WHERE product_id = p_product_id;

    COMMIT;
END //

DELIMITER ;

-- ============================================================
-- 動作確認
-- ============================================================

-- 正常系（在庫あり）
CALL CreateOrder('O005', 'C003', 'P002', 3);

-- 異常系（在庫不足 → エラーになりロールバックされる）
-- CALL CreateOrder('O006', 'C003', 'P001', 9999);

SHOW FULL TABLES IN order_db WHERE TABLE_TYPE = 'VIEW';
SHOW PROCEDURE STATUS WHERE Db = 'order_db';
