-- ============================================================
-- MySQLで学ぶ受注管理システム開発（5）「パフォーマンスチューニングとバックアップ」
-- インデックス設計の実践例
-- 前提：01_schema.sql 〜 04_trigger_permission.sql を実行済みであること
--
-- 注意：mysqldumpによるバックアップ・リストアはターミナルコマンドであり、
--       SQL文ではないため、このファイルの末尾にコマンドのみ記載する。
-- ============================================================

USE order_db;

-- ============================================================
-- 1. インデックス設計
-- ============================================================

-- 変更前の実行計画を確認（フルスキャンになっていることを確認する）
-- EXPLAIN SELECT * FROM products WHERE product_name = 'ワイヤレスマウス';

-- 商品名検索用のインデックス
CREATE INDEX idx_products_product_name ON products(product_name);

-- 「特定顧客・特定ステータス」の絞り込み検索用の複合インデックス
-- （列の順序は customer_id → status。customer_idだけの検索にも有効）
CREATE INDEX idx_orders_customer_status ON orders(customer_id, status);

-- 変更後の実行計画を確認（type: ref、rowsが減っていることを確認する）
-- EXPLAIN SELECT * FROM products WHERE product_name = 'ワイヤレスマウス';
-- EXPLAIN SELECT * FROM orders WHERE customer_id = 'C001' AND status <> 'キャンセル';

-- ============================================================
-- 動作確認
-- ============================================================

SHOW INDEX FROM products;
SHOW INDEX FROM orders;

-- ============================================================
-- 2. バックアップ・リストア（ターミナルコマンド／参考）
-- ============================================================

-- 【バックアップ】データベース全体
-- mkdir -p backups
-- mysqldump -h db -u root -ppassword order_db > backups/order_db_backup.sql

-- 【バックアップ】特定のテーブルのみ
-- mysqldump -h db -u root -ppassword order_db orders order_details > backups/orders_only_backup.sql

-- 【バックアップ】構造（テーブル定義）のみ
-- mysqldump -h db -u root -ppassword --no-data order_db > backups/order_db_structure_only.sql

-- 【リストア】別データベースに復元して動作確認する
-- mysql -h db -u root -ppassword -e "CREATE DATABASE order_db_restore_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
-- mysql -h db -u root -ppassword order_db_restore_test < backups/order_db_backup.sql
-- mysql -h db -u root -ppassword order_db_restore_test -e "SELECT * FROM customer_order_summary;"

-- 【後片付け】確認用データベースの削除
-- mysql -h db -u root -ppassword -e "DROP DATABASE order_db_restore_test;"
