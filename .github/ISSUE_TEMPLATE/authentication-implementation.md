---
name: 認証機能の実装
about: Rails APIモードでトークンベース認証機能を実装する
title: '[Feature] 認証機能の実装'
labels: enhancement, security
assignees: ''
---

## 概要

Rails 8.1 APIモードでトークンベースの認証機能を実装します。

## 背景

- 本プロジェクトはAPIモード（`config.api_only = true`）で構築されています
- Rails 8.0の`bin/rails generate authentication`はView付きアプリ向けのため、不要なファイルが生成されます
- APIモードに最適化された認証機能を手動で実装する必要があります

## 実装ガイド

詳細は以下のドキュメントを参照してください：
- [認証機能の実装ガイド](../../../docs/AUTHENTICATION_IMPLEMENTATION.md)

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
