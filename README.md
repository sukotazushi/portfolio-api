# Portfolio API

Rails + Docker + MySQL を用いた API ポートフォリオです。  
ローカル環境差異をなくすため、Docker Compose で開発環境を構築しています。

---

## 技術スタック

- Ruby 4.0
- Rails 8.1.2（API モード）
- MySQL
- Docker / Docker Compose
- RuboCop（rubocop-rails-omakase）

---

## 環境構築

### 前提

- Docker Desktop
- Docker Compose
- （Windows の場合）WSL2

### セットアップ手順

```bash
git clone git@github.com:sukotazushi/portfolio-api.git
cd portfolio-api
cp .env.example .env
docker compose up -d --build
```

---

## データベース作成

```bash
docker compose exec api bundle exec rails db:create
docker compose exec api bundle exec rails db:migrate
```

---

## 起動確認

Rails サーバは以下で起動します。

```bash
docker compose up -d
```

ブラウザまたは curl で確認：

```bash
curl http://localhost:8080/health
```

レスポンス例：

```json
{ "status": "ok" }
```

---

## 環境変数

`.env` ファイルで以下を設定します。

```env
DATABASE_HOST=db
DATABASE_USERNAME=root
DATABASE_PASSWORD=your_password
DATABASE_BASE_NAME=portfolio_api

MYSQL_ROOT_PASSWORD=your_password
```

※ `.env.example` を参考にしてください。

---

## コード品質

静的解析に RuboCop（rubocop-rails-omakase）を使用しています。

```bash
docker compose run --rm api bundle exec rubocop
```

---

## ドキュメント

- [認証機能の実装ガイド](docs/AUTHENTICATION_IMPLEMENTATION.md) - Rails APIモードでの認証機能実装の流れ
- [GitHubイシューの作成手順](docs/GITHUB_ISSUE_INSTRUCTIONS.md) - 認証機能実装のイシュー作成方法と準備事項
