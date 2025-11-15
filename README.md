# MySQL学習環境

GitHub Codespacesで動作するMySQL学習用リポジトリです。社員表と部署表を使ってSQLの基本操作を学習できます。

## 📋 テーブル構成

### 部署表（departments）
| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| department_id | INT | PRIMARY KEY | 部署番号 |
| department_name | VARCHAR(100) | NOT NULL | 部署名 |

### 社員表（employees）
| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| employee_id | INT | PRIMARY KEY | 社員番号 |
| name | VARCHAR(100) | NOT NULL | 氏名 |
| gender | ENUM | NOT NULL | 性別（男/女/その他） |
| birth_date | DATE | NOT NULL | 生年月日 |
| salary | DECIMAL(10,2) | NOT NULL | 給与 |
| department_id | INT | FOREIGN KEY | 部署番号 |

## 🚀 セットアップ

### 1. Codespacesを起動

1. このリポジトリで「Code」ボタンをクリック
2. 「Codespaces」タブを選択
3. 「Create codespace on main」をクリック
4. 起動を待つ（数分かかります）

### 2. MySQLクライアントをインストール

ターミナルで以下のコマンドを実行：

```bash
sudo apt-get update && sudo apt-get install -y mysql-client
```

### 3. MySQLの起動を確認

```bash
# MySQLが起動するまで待つ（準備ができるとエラーが出なくなります）
mysql -h db -u root -ppassword -e "SELECT 1"
```

### 4. データベースとテーブルを作成

MySQLに接続：

```bash
mysql -h db -u root -ppassword
```

以下のSQLを実行：

```sql
-- データベース作成
CREATE DATABASE company_db;
USE company_db;

-- 部署表
CREATE TABLE departments (
    department_id VARCHAR(10) PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 社員表
CREATE TABLE employees (
    employee_id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    gender ENUM('男', '女') NOT NULL,
    birth_date DATE NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    department_id VARCHAR(10) NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 部署データ
INSERT INTO departments (department_id, department_name) VALUES 
    ('001', '総務部'),
    ('002', '経理部'),
    ('003', '営業部');

-- 社員データ
INSERT INTO employees (employee_id, name, gender, birth_date, salary, department_id) VALUES 
    ('0001', '佐藤一郎', '男', '1951-01-01', 450000, '002'),
    ('0002', '鈴木二郎', '男', '1962-02-02', 400000, '003'),
    ('0003', '高橋花子', '女', '1973-03-03', 350000, '001'),
    ('0004', '田中四郎', '男', '1984-04-04', 300000, '001'),
    ('0005', '渡辺良子', '女', '1995-05-05', 250000, '003');

-- MySQLから抜ける
EXIT;
```

### 5. 動作確認

```bash
# MySQLに接続（データベースを指定）
mysql -h db -u root -ppassword company_db
```

MySQLプロンプト内で：

```sql
-- テーブル確認
SHOW TABLES;

-- データ確認
SELECT * FROM employees;
SELECT * FROM departments;
```

**注意:** データベースを指定せずに接続した場合は、以下を実行してください：

```sql
USE company_db;
```

## 💡 基本的な使い方

### MySQLへの接続

```bash
# データベースを指定して接続（推奨）
mysql -h db -u root -ppassword company_db
```

または

```bash
# データベースを指定せずに接続
mysql -h db -u root -ppassword

# MySQLプロンプト内でデータベースを選択
USE company_db;
```

### テーブル確認

```sql
-- テーブル一覧
SHOW TABLES;

-- 社員データを表示
SELECT * FROM employees;

-- 部署データを表示
SELECT * FROM departments;
```

### データ検索

```sql
-- 給与が35万円以上の社員
SELECT * FROM employees WHERE salary >= 350000;

-- 開発部の社員
SELECT e.* 
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE d.department_name = '開発部';

-- 名前に「田」を含む社員
SELECT * FROM employees WHERE name LIKE '%田%';
```

### データ集計

```sql
-- 部署別の社員数
SELECT 
    d.department_name,
    COUNT(e.employee_id) as employee_count
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name;

-- 部署別の平均給与
SELECT 
    d.department_name,
    AVG(e.salary) as average_salary,
    MIN(e.salary) as min_salary,
    MAX(e.salary) as max_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name;
```

### 結合クエリ

```sql
-- 社員と部署を結合して表示
SELECT 
    e.employee_id,
    e.name,
    e.gender,
    e.birth_date,
    e.salary,
    d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id;
```

### 並び替え

```sql
-- 性別で分けて、各性別内で生年月日順
SELECT gender, name, birth_date 
FROM employees 
ORDER BY FIELD(gender, '男', '女'), birth_date ASC;
```

## 📝 練習問題

### 初級
1. 全社員の名前と給与を表示してください
2. 営業部の社員を表示してください
3. 給与が40万円以上の社員を表示してください

### 中級
4. 各部署の平均給与を計算してください
5. 最も給与が高い社員を表示してください
6. 1990年以降生まれの社員を表示してください

### 上級
7. 部署ごとの給与合計を降順で表示してください
8. 各部署で最も給与が高い社員を表示してください
9. 社員がいない部署を表示してください

## 🛠️ ターミナルから直接実行

MySQLプロンプトに入らずに、ターミナルから直接SQLを実行することもできます：

```bash
# テーブル一覧（データベース名を指定）
mysql -h db -u root -ppassword company_db -e "SHOW TABLES;"

# 全社員表示
mysql -h db -u root -ppassword company_db -e "SELECT * FROM employees;"

# 複雑なクエリも実行可能
mysql -h db -u root -ppassword company_db -e "
SELECT d.department_name, COUNT(*) as count
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name;"
```

**重要:** ターミナルから実行する場合は、必ず `-e` オプションの前にデータベース名 `company_db` を指定してください。

## 📚 学習リソース

- [MySQL公式ドキュメント](https://dev.mysql.com/doc/)
- [SQL基礎文法](https://www.w3schools.com/sql/)

## 🔧 接続情報

- **ホスト**: db
- **ユーザー**: root
- **パスワード**: password
- **データベース**: company_db
- **ポート**: 3306

## 📂 ファイル構成

```
mysql-learning/
├── .devcontainer/
│   ├── devcontainer.json    # Codespaces設定
│   └── docker-compose.yml   # Docker構成
└── README.md                # このファイル
```

## 🔄 次回以降の起動

Codespacesを再起動した場合：

1. Codespacesを開く
2. データは保持されているので、すぐに使えます
3. MySQLに接続：

```bash
mysql -h db -u root -ppassword company_db
```

**注意:** Codespacesを削除すると、データベースの内容も削除されます。その場合は手順4から再度実行してください。

## ⚠️ 注意事項

- このリポジトリは学習用です。本番環境では使用しないでください
- パスワードは簡易的なものです。実際の開発では安全なパスワードを使用してください
- Codespacesを停止すると、データは保持されますが、削除すると全てリセットされます

## 📄 ライセンス

このプロジェクトは学習目的で自由に使用できます。
