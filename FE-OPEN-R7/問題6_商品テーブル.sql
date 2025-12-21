-- 問題6: 商品テーブルの検証用SQL

-- 商品テーブルを作成
CREATE TABLE IF NOT EXISTS 商品 (
    商品ID VARCHAR(10) PRIMARY KEY,
    商品名称 VARCHAR(100) NOT NULL,
    仕入先ID VARCHAR(10) NOT NULL,
    単価 INT NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- データを投入
INSERT INTO 商品 (商品ID, 商品名称, 仕入先ID, 単価) VALUES
    ('S001', '冷蔵庫', 'M001', 155000),
    ('S002', '全自動洗い機', 'M002', 85000),
    ('S003', '電子レンジ', 'M003', 78000),
    ('S004', '炊飯器', 'M003', 32000),
    ('S005', 'コーヒーメーカー', 'M004', 15000),
    ('S006', 'ホットプレート', 'M004', 12000);

-- データ確認
SELECT * FROM 商品;