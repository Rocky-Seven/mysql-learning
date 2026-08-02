-- ============================================================
-- MySQLで学ぶ受注管理システム開発（4）「トリガーとユーザー権限管理」
-- トリガー・ユーザー権限管理の実践例
-- 前提：01_schema.sql、02_crud.sql、03_view_procedure.sql を実行済みであること
-- ============================================================

USE order_db;

-- ============================================================
-- 1. トリガー
-- ============================================================

-- 注文ステータス変更履歴を記録するログ表
CREATE TABLE IF NOT EXISTS order_status_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(10) NOT NULL,
    old_status VARCHAR(20) NOT NULL,
    new_status VARCHAR(20) NOT NULL,
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ステータス変更を自動的にログへ記録するトリガー
DROP TRIGGER IF EXISTS trg_orders_status_log;
DELIMITER //

CREATE TRIGGER trg_orders_status_log
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO order_status_log (order_id, old_status, new_status)
        VALUES (NEW.order_id, OLD.status, NEW.status);
    END IF;
END //

DELIMITER ;

-- 在庫不足時のINSERTを防ぐトリガー（テーブルレベルでの多層防御）
DROP TRIGGER IF EXISTS trg_order_details_stock_check;
DELIMITER //

CREATE TRIGGER trg_order_details_stock_check
BEFORE INSERT ON order_details
FOR EACH ROW
BEGIN
    DECLARE v_stock INT;

    SELECT stock_quantity INTO v_stock
    FROM products
    WHERE product_id = NEW.product_id;

    IF v_stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '在庫が不足しているため登録できません';
    END IF;
END //

DELIMITER ;

-- 動作確認
-- UPDATE orders SET status = '出荷済' WHERE order_id = 'O005';
-- SELECT * FROM order_status_log;

-- ============================================================
-- 2. ユーザー権限管理
-- ============================================================

-- 閲覧専用ユーザー（レポート担当者向け）
CREATE USER IF NOT EXISTS 'report_viewer'@'%' IDENTIFIED BY 'ViewOnly2026!';
GRANT SELECT ON order_db.* TO 'report_viewer'@'%';

-- 登録担当者ユーザー（受注登録担当者向け）
CREATE USER IF NOT EXISTS 'order_staff'@'%' IDENTIFIED BY 'OrderStaff2026!';
GRANT SELECT, INSERT, UPDATE ON order_db.orders TO 'order_staff'@'%';
GRANT SELECT, INSERT, UPDATE ON order_db.order_details TO 'order_staff'@'%';
GRANT SELECT ON order_db.customers TO 'order_staff'@'%';
GRANT SELECT ON order_db.products TO 'order_staff'@'%';
GRANT EXECUTE ON PROCEDURE order_db.CreateOrder TO 'order_staff'@'%';

FLUSH PRIVILEGES;

-- 権限のはく奪の例（担当替え時などに使用）
-- REVOKE UPDATE ON order_db.orders FROM 'order_staff'@'%';
-- FLUSH PRIVILEGES;

-- ============================================================
-- 動作確認
-- ============================================================

SHOW TRIGGERS IN order_db;
SHOW GRANTS FOR 'report_viewer'@'%';
SHOW GRANTS FOR 'order_staff'@'%';
SELECT User, Host FROM mysql.user WHERE User IN ('report_viewer', 'order_staff');
