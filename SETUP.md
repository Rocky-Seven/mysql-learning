# SETUP.md - GitHub初心者向けセットアップガイド

このガイドでは、GitHubアカウントの作成からCodespacesの起動、変更のコミット＆プッシュまでの手順を説明します。

## 📋 目次

1. [GitHubアカウントの作成](#1-githubアカウントの作成)
2. [リポジトリの作成](#2-リポジトリの作成)
3. [必要なファイルの作成](#3-必要なファイルの作成)
4. [Codespacesの起動](#4-codespacesの起動)
5. [MySQLのセットアップ](#5-mysqlのセットアップ)
6. [変更をコミット＆プッシュ](#6-変更をコミットプッシュ)
7. [よくある質問](#7-よくある質問)

---

## 1. GitHubアカウントの作成

### 手順

1. [GitHub公式サイト](https://github.com/)にアクセス
2. 右上の「Sign up」をクリック
3. メールアドレスを入力
4. パスワードを設定
5. ユーザー名を入力（半角英数字、ハイフン、アンダースコアのみ）
6. メール認証を完了

**💡 ポイント:** 
- ユーザー名は後から変更できますが、URLに使われるので慎重に選びましょう
- 学生の場合は[GitHub Student Developer Pack](https://education.github.com/pack)に申請すると特典があります

---

## 2. リポジトリの作成

### 手順

1. GitHubにログイン
2. 右上の「+」アイコンをクリック
3. 「New repository」を選択
4. リポジトリの情報を入力：
   - **Repository name**: `mysql-learning`（任意の名前でOK）
   - **Description**: `MySQL学習用リポジトリ`（任意）
   - **Public / Private**: どちらでもOK
     - Public: 誰でも見られる
     - Private: 自分だけ、または招待した人だけ見られる
   - ☑️ **Add a README file**: チェックを入れる（推奨）
5. 「Create repository」をクリック

**💡 ポイント:**
- リポジトリ名は後から変更可能
- 学習用なので、Publicでも問題ありません

---

## 3. 必要なファイルの作成

### 3-1. `.devcontainer/devcontainer.json` を作成

1. リポジトリのページで「Add file」→「Create new file」をクリック
2. ファイル名に `.devcontainer/devcontainer.json` と入力
   - スラッシュ（`/`）を入れると自動的にフォルダが作成されます
3. 以下の内容をコピー＆ペースト：

```json
{
  "name": "MySQL Learning Environment",
  "dockerComposeFile": "docker-compose.yml",
  "service": "app",
  "workspaceFolder": "/workspace"
}
```

4. 下にスクロールして「Commit changes」をクリック
5. そのまま「Commit changes」をクリック（コミットメッセージはデフォルトでOK）

### 3-2. `.devcontainer/docker-compose.yml` を作成

1. 「Add file」→「Create new file」をクリック
2. ファイル名に `.devcontainer/docker-compose.yml` と入力
※すでに.devcontainer/が表示されている場合、docker-compose.yml` と入力すること。
3. 以下の内容をコピー＆ペースト：

```yaml
version: '3.8'

services:
  app:
    image: mcr.microsoft.com/devcontainers/base:ubuntu
    volumes:
      - ..:/workspace:cached
    command: sleep infinity
    network_mode: service:db
    depends_on:
      - db

  db:
    image: mysql:8.0
    restart: unless-stopped
    command: --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
    environment:
      MYSQL_ROOT_PASSWORD: password

volumes:
  mysql-data:
```

4. 「Commit changes」をクリック

### 3-3. README.md を作成（既にある場合はスキップ）

1. リポジトリのトップページに戻る
2. README.mdが既にある場合は、鉛筆マーク（Edit）をクリックして編集
3. [README.mdの内容](./README.md)を参照してコピー＆ペースト
4. 「Commit changes」をクリック

**💡 ポイント:**
- YAMLファイル（.yml）はインデント（字下げ）が重要です
- スペース2個または4個でインデントし、タブは使わないでください

---

## 4. Codespacesの起動

### 手順

1. リポジトリのページで緑色の「Code」ボタンをクリック
2. 「Codespaces」タブを選択
3. 「Create codespace on main」をクリック
4. 新しいタブが開き、Codespacesが起動します（初回は5〜10分かかります）

**画面の見方:**
- **左側**: ファイルエクスプローラー（ファイル一覧）
- **中央**: エディター（ファイルを編集する場所）
- **下部**: ターミナル（コマンドを実行する場所）

**💡 ポイント:**
- Codespacesは一定時間操作しないと自動的に停止します
- 停止したCodespacesは「Code」→「Codespaces」から再開できます
- データは保持されるので、続きから作業できます

---

## 5. MySQLのセットアップ

Codespacesが起動したら、MySQLのインストールとデータベースのセットアップを行います。

**👉 詳しい手順は [README.md](./README.md) の「セットアップ」セクションを参照してください。**

以下の作業を行います：
1. MySQLクライアントのインストール
2. MySQLの起動確認
3. データベースとテーブルの作成
4. サンプルデータの投入

---

## 6. 変更をコミット＆プッシュ

Codespacesで作業した内容をGitHubに保存（プッシュ）する方法を説明します。

### 6-1. 変更を確認

ターミナルで以下のコマンドを実行：

```bash
git status
```

**表示される情報:**
- 変更されたファイル（赤色で表示）
- 新規作成されたファイル

### 6-2. 変更をステージングに追加

```bash
# すべての変更を追加
git add .

# 特定のファイルだけ追加する場合
git add ファイル名
```

**💡 ポイント:** `.`（ドット）は「すべてのファイル」を意味します

### 6-3. コミット（変更を記録）

```bash
git commit -m "コミットメッセージ"
```

**コミットメッセージの例:**
- `git commit -m "練習用クエリを追加"`
- `git commit -m "VIEWを作成"`
- `git commit -m "README修正"`

**💡 ポイント:**
- コミットメッセージは何を変更したか分かるように書きましょう
- 日本語でOKです

### 6-4. プッシュ（GitHubに送信）

```bash
git push
```

**成功すると:**
```
Enumerating objects: 5, done.
...
To https://github.com/ユーザー名/mysql-learning
   abc1234..def5678  main -> main
```

### 6-5. GitHubで確認

1. ブラウザでリポジトリのページを開く
2. ファイルが更新されていることを確認
3. コミット履歴を見るには「commits」をクリック

---

## 7. よくある質問

### Q1. エラー「failed to push some refs」が出ました

**原因:** GitHubの内容とCodespacesの内容が異なっている

**解決方法:**
```bash
# リモートの変更を取り込む
git pull --rebase

# 問題なければプッシュ
git push
```

### Q2. エラー「Need to specify how to reconcile divergent branches」が出ました

**解決方法:**
```bash
git pull --rebase
git push
```

### Q3. コミットメッセージを間違えました

**直前のコミットなら修正可能:**
```bash
git commit --amend -m "正しいメッセージ"
git push --force
```

**⚠️ 注意:** `--force`は慎重に使用してください

### Q4. Codespacesが起動しません

**確認事項:**
1. `.devcontainer/devcontainer.json`が正しく作成されているか
2. `.devcontainer/docker-compose.yml`が正しく作成されているか
3. ファイルの内容にタイプミスがないか

**解決方法:**
- Codespacesを削除して再作成
- リポジトリの「Actions」タブでエラーログを確認

### Q5. MySQLに接続できません

**確認事項:**
```bash
# MySQLコンテナが起動しているか確認
docker ps

# MySQLの起動を待つ
sleep 30
mysql -h db -u root -ppassword -e "SELECT 1"
```

**詳細は [README.md](./README.md) を参照してください。**

### Q6. Codespacesの使用時間に制限はありますか？

**無料プランの場合:**
- 月120時間まで無料
- 停止中のCodespacesは時間にカウントされません
- 使わない時は停止しておきましょう

**停止方法:**
- GitHubの「Code」→「Codespaces」→「...」→「Stop codespace」

### Q7. ファイルを削除してしまいました

**Gitで管理されているファイルなら復元可能:**
```bash
# 直前のコミットの状態に戻す
git checkout ファイル名

# すべてのファイルを戻す
git checkout .
```

---

## 🎓 次のステップ

1. [README.md](./README.md)を読んでMySQLの操作を学習
2. 練習問題に挑戦
3. 自分でクエリを書いてみる
4. VIEWやサブクエリなど、より高度なSQLを学習

---

## 📚 参考リンク

- [GitHub公式ドキュメント](https://docs.github.com/ja)
- [GitHub Codespaces公式ドキュメント](https://docs.github.com/ja/codespaces)
- [Git入門](https://git-scm.com/book/ja/v2)
- [MySQL公式ドキュメント](https://dev.mysql.com/doc/)

---

## 💡 Tips

### Codespacesのショートカット

- `Ctrl + `` `: ターミナルの表示/非表示
- `Ctrl + Shift + P`: コマンドパレット
- `Ctrl + S`: ファイルを保存
- `Ctrl + /`: コメントのトグル

### よく使うGitコマンド

```bash
# 状態確認
git status

# 変更を追加
git add .

# コミット
git commit -m "メッセージ"

# プッシュ
git push

# プル（リモートの変更を取得）
git pull

# ログ確認
git log --oneline
```

### MySQLによく使うコマンド

```bash
# MySQLに接続
mysql -h db -u root -ppassword company_db

# MySQLから抜ける
EXIT;

# またはCtrl+D
```

---

## ⚠️ 注意事項

- パスワード `password` は学習用です。実際の開発では安全なパスワードを使用してください
- Privateリポジトリにしても、コミット履歴には注意しましょう
- Codespacesを削除すると、データベースの内容も削除されます
- 重要なデータは必ずバックアップを取りましょう

---

## 🆘 困ったときは

1. エラーメッセージをよく読む
2. [README.md](./README.md)のトラブルシューティングを確認
3. GitHubの「Issues」で質問する
4. Google検索で「エラーメッセージ」+「GitHub Codespaces」または「MySQL」で検索

---

**Happy Learning! 🎉**