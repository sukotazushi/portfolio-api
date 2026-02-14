# GitHubイシューの作成手順

## 概要

認証機能の実装についてのGitHubイシューを作成する手順を説明します。

---

## 方法1: GitHubのWebインターフェースを使用（推奨）

### 手順

1. **リポジトリのIssuesページに移動**
   - https://github.com/sukotazushi/portfolio-api/issues にアクセス

2. **New issueボタンをクリック**
   - 緑色の「New issue」ボタンをクリック

3. **テンプレートを選択**
   - 「認証機能の実装」テンプレートが表示されます
   - 「Get started」ボタンをクリック

4. **内容を確認して作成**
   - タイトル: `[Feature] 認証機能の実装`
   - ラベル: `enhancement`, `security` を追加
   - 必要に応じてAssigneesを設定
   - 「Submit new issue」ボタンをクリック

---

## 方法2: GitHub CLIを使用

GitHub CLIがインストールされている場合、以下のコマンドで作成できます：

```bash
gh issue create \
  --title "[Feature] 認証機能の実装" \
  --body-file .github/ISSUE_TEMPLATE/authentication-implementation.md \
  --label "enhancement,security"
```

---

## 方法3: 手動でイシューを作成

テンプレートを使用せず、手動で作成する場合：

1. https://github.com/sukotazushi/portfolio-api/issues/new にアクセス

2. 以下の内容をコピー＆ペースト：

```markdown
## 概要

Rails 8.1 APIモードでトークンベースの認証機能を実装します。

## 背景

- 本プロジェクトはAPIモード（`config.api_only = true`）で構築されています
- Rails 8.0の`bin/rails generate authentication`はView付きアプリ向けのため、不要なファイルが生成されます
- APIモードに最適化された認証機能を手動で実装する必要があります

## 実装ガイド

詳細は以下のドキュメントを参照してください：
- [認証機能の実装ガイド](docs/AUTHENTICATION_IMPLEMENTATION.md)

## 実装内容

### 1. 依存関係の追加
- [ ] `bcrypt` gemをGemfileに追加
- [ ] `bundle install`を実行

### 2. モデルの作成
- [ ] Userモデルを作成（email, password_digest）
- [ ] Sessionモデルを作成（token, ip_address, user_agent, expires_at）
- [ ] Currentモデルを作成（現在のユーザー管理）
- [ ] マイグレーションを実行

### 3. 認証機能の実装
- [ ] `app/controllers/concerns/authentication.rb` を作成
- [ ] `app/controllers/sessions_controller.rb` を作成
- [ ] `ApplicationController`にAuthenticationをinclude
- [ ] ルーティングを設定（`/sessions`, `/login`, `/logout`）
- [ ] `HealthController`に`allow_unauthenticated_access`を追加

### 4. テストの作成
- [ ] Userモデルのテスト
- [ ] Sessionモデルのテスト
- [ ] SessionsControllerのテスト
- [ ] すべてのテストが通ることを確認

### 5. セキュリティ対策
- [ ] パスワードの検証（最小8文字）
- [ ] トークンの有効期限設定
- [ ] タイミング攻撃対策の実装
- [ ] レート制限の検討（rack-attack）
- [ ] HTTPS強制（本番環境）
- [ ] CORS設定の見直し
- [ ] ログフィルタリングの設定

### 6. 動作確認
- [ ] ユーザー登録のテスト
- [ ] ログイン（POST /sessions）のテスト
- [ ] 認証が必要なエンドポイントのテスト
- [ ] ログアウト（DELETE /sessions/:token）のテスト
- [ ] トークン有効期限のテスト

## API仕様

### ログイン
```http
POST /sessions
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**レスポンス（成功時）:**
```json
{
  "token": "xxxxx",
  "expires_at": "2026-03-16T07:51:44.103Z",
  "user": {
    "id": 1,
    "email": "user@example.com"
  }
}
```

### ログアウト
```http
DELETE /sessions/:token
Authorization: Bearer xxxxx
```

### 認証が必要なエンドポイント
```http
GET /api/protected-resource
Authorization: Bearer xxxxx
```

## セキュリティ考慮事項

1. **パスワード**: bcryptでハッシュ化、最小8文字
2. **トークン**: SecureRandom.urlsafe_base64(32)で生成、30日間有効
3. **タイミング攻撃**: 常に同じ処理時間を確保
4. **レート制限**: ログイン試行を5回/分に制限
5. **HTTPS**: 本番環境で強制
6. **CORS**: 許可するオリジンを制限
7. **SQL インジェクション**: プレースホルダーを使用
8. **マスアサインメント**: Strong Parametersを使用
9. **セッション固定**: ログイン時に新しいトークンを生成
10. **ログ出力**: パスワード・トークンをフィルタリング

## 参考資料

- [Rails Security Guide](https://railsguides.jp/security.html)
- [bcrypt gem](https://github.com/bcrypt-ruby/bcrypt-ruby)
- [has_secure_password](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html)
- [rack-attack](https://github.com/rack/rack-attack)

## 完了条件

- [ ] すべての実装タスクが完了
- [ ] すべてのテストがパス
- [ ] RuboCopのチェックがパス
- [ ] 動作確認が完了
- [ ] ドキュメントが更新されている
```

3. タイトルに `[Feature] 認証機能の実装` を入力

4. ラベルに `enhancement` と `security` を追加

5. 「Submit new issue」をクリック

---

## 準備が必要なもの

認証機能を実装する前に、以下の準備が必要です：

### 1. 開発環境の準備

```bash
# リポジトリをクローン（既に完了している場合はスキップ）
git clone git@github.com:sukotazushi/portfolio-api.git
cd portfolio-api

# 環境変数の設定
cp .env.example .env
# .envファイルを編集して、必要な値を設定

# Dockerコンテナの起動
docker compose up -d --build

# データベースの作成
docker compose exec api bundle exec rails db:create
```

### 2. ブランチの作成

```bash
# 認証機能実装用のブランチを作成
git checkout -b feature/authentication
```

### 3. 実装ガイドの確認

- [docs/AUTHENTICATION_IMPLEMENTATION.md](../docs/AUTHENTICATION_IMPLEMENTATION.md) を熟読
- セキュリティ考慮事項を理解
- 実装の流れを把握

### 4. 必要な知識の確認

以下の知識があると実装がスムーズです：

- Rails APIモードの基本
- bcryptによるパスワードハッシュ化
- トークンベース認証の仕組み
- Railsのテスト（Minitest）
- セキュリティベストプラクティス

### 5. オプション：レビュー環境の準備

- レビュアーがいる場合は事前に相談
- コードレビューの方針を確認
- CI/CDの設定確認

---

## イシュー作成後の流れ

1. **イシューが作成されたら**
   - イシュー番号を確認（例: #123）
   - ブランチ名を `feature/authentication-#123` に変更（オプション）

2. **実装を開始**
   - 実装ガイドに従って順番に実装
   - 各ステップでcommitを作成
   - テストを書いて動作確認

3. **プルリクエストの作成**
   - 実装が完了したらPRを作成
   - イシュー番号を本文に記載（`Closes #123`）
   - レビューを依頼

4. **マージ**
   - レビューが完了したらmain/masterブランチにマージ
   - イシューが自動的にクローズ

---

## トラブルシューティング

### テンプレートが表示されない場合

- `.github/ISSUE_TEMPLATE/authentication-implementation.md` が正しくコミット・プッシュされているか確認
- GitHubが変更を認識するまで数分かかる場合があります

### GitHub CLIでエラーが出る場合

```bash
# GitHub CLIにログイン
gh auth login

# リポジトリが正しく認識されているか確認
gh repo view
```

---

## 質問・サポート

実装中に質問がある場合は：

1. [実装ガイド](../docs/AUTHENTICATION_IMPLEMENTATION.md)を確認
2. GitHubイシューにコメントで質問
3. 必要に応じてDiscussionsで議論

---

## まとめ

✅ GitHubイシューのテンプレートが準備されました  
✅ イシューを作成する3つの方法を説明しました  
✅ 実装前の準備項目をリストアップしました  
✅ イシュー作成後の流れを説明しました

これで認証機能の実装を開始する準備が整いました！
