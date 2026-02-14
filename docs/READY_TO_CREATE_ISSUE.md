# 認証機能実装の準備完了

## ✅ 完了事項

以下のドキュメントとテンプレートが準備されました：

### 1. 認証機能の実装ガイド
**ファイル**: `docs/AUTHENTICATION_IMPLEMENTATION.md`

- Rails APIモードでの認証機能の実装手順（564行）
- `bin/rails generate authentication` の問題点の説明
- 手動実装の詳細なステップ（11ステップ）
- セキュリティ考慮事項（11項目）
- 完全なコード例とテスト例

### 2. GitHubイシュー作成手順
**ファイル**: `docs/GITHUB_ISSUE_INSTRUCTIONS.md`

- GitHubでイシューを作成する3つの方法
- 実装前に準備が必要な項目
- イシュー作成後の作業フロー
- トラブルシューティング

### 3. GitHubイシューテンプレート
**ファイル**: `.github/ISSUE_TEMPLATE/authentication-implementation.md`

- 認証機能実装用のイシューテンプレート
- 実装チェックリスト（6カテゴリ、31項目）
- API仕様の定義
- セキュリティ要件
- 完了条件

---

## 📝 次のステップ：GitHubイシューの作成

### 方法1: GitHubのWebインターフェースを使用（最も簡単）

1. https://github.com/sukotazushi/portfolio-api/issues/new/choose にアクセス
2. 「認証機能の実装」テンプレートの「Get started」をクリック
3. 内容を確認して「Submit new issue」をクリック

### 方法2: GitHub CLIを使用

```bash
cd /home/runner/work/portfolio-api/portfolio-api
gh issue create \
  --title "[Feature] 認証機能の実装" \
  --body-file .github/ISSUE_TEMPLATE/authentication-implementation.md \
  --label "enhancement,security"
```

### 方法3: 手動作成

詳細は `docs/GITHUB_ISSUE_INSTRUCTIONS.md` を参照してください。

---

## 🔧 準備が必要なもの

実装を開始する前に、以下を準備してください：

### 必須項目

1. **開発環境**
   ```bash
   # 既にクローン済みの場合はスキップ
   git clone git@github.com:sukotazushi/portfolio-api.git
   cd portfolio-api
   
   # 環境変数の設定
   cp .env.example .env
   # .envファイルを編集
   
   # Dockerコンテナの起動
   docker compose up -d --build
   
   # データベースの作成
   docker compose exec api bundle exec rails db:create
   ```

2. **ブランチの作成**
   ```bash
   git checkout -b feature/authentication
   ```

3. **実装ガイドの確認**
   - `docs/AUTHENTICATION_IMPLEMENTATION.md` を熟読

### オプション項目

- GitHub CLIのインストール（`gh` コマンド）
- レビュアーとの事前相談
- CI/CDの設定確認

---

## 📋 実装チェックリスト（概要）

イシューを作成すると、以下のチェックリストが含まれます：

### 1. 依存関係の追加
- bcrypt gemの追加
- bundle install

### 2. モデルの作成
- Userモデル（email, password_digest）
- Sessionモデル（token, ip_address, user_agent, expires_at）
- Currentモデル（現在のユーザー管理）

### 3. 認証機能の実装
- Authentication concern
- SessionsController
- ルーティング設定

### 4. テストの作成
- Userモデルのテスト
- Sessionモデルのテスト
- SessionsControllerのテスト

### 5. セキュリティ対策
- パスワードの検証
- トークンの有効期限
- タイミング攻撃対策
- レート制限
- HTTPS強制
- CORS設定
- ログフィルタリング

### 6. 動作確認
- ユーザー登録
- ログイン
- 認証エンドポイント
- ログアウト
- トークン有効期限

---

## 🔐 セキュリティ重要事項

以下のセキュリティ対策が実装ガイドに含まれています：

1. **パスワード**: bcryptでハッシュ化、最小8文字
2. **トークン**: SecureRandom.urlsafe_base64(32)、30日間有効
3. **タイミング攻撃**: 常に同じ処理時間を確保
4. **レート制限**: ログイン試行を5回/分に制限
5. **HTTPS**: 本番環境で強制
6. **CORS**: 許可するオリジンを制限
7. **SQL インジェクション**: プレースホルダーを使用
8. **マスアサインメント**: Strong Parametersを使用
9. **セッション固定**: ログイン時に新しいトークンを生成
10. **XSS**: JSONレスポンスの自動エスケープ
11. **ログ出力**: パスワード・トークンをフィルタリング

---

## 📚 参考資料

- [Rails Security Guide (日本語)](https://railsguides.jp/security.html)
- [bcrypt gem](https://github.com/bcrypt-ruby/bcrypt-ruby)
- [has_secure_password](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html)
- [rack-attack](https://github.com/rack/rack-attack)

---

## 🎯 実装後の流れ

1. **イシューを作成** ← 次はこれ！
2. **実装ガイドに従って開発**
3. **テストを書いて動作確認**
4. **プルリクエストを作成**
5. **レビュー・マージ**

---

## ❓ 質問・サポート

- 実装中の質問: GitHubイシューにコメント
- 一般的な質問: GitHub Discussions
- 緊急の相談: チームに直接連絡

---

## 📊 進捗状況

- ✅ 実装ガイドの作成完了
- ✅ イシューテンプレートの作成完了
- ✅ 作成手順書の準備完了
- ⏳ GitHubイシューの作成待ち ← **次のステップ**
- ⏳ 実装作業
- ⏳ テスト・レビュー
- ⏳ マージ

---

これで認証機能の実装を開始する準備が完全に整いました！  
次は GitHub でイシューを作成してください。
