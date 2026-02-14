# 認証機能の実装ガイド

このドキュメントは、Rails APIモードでの認証機能実装の流れを説明します。  
Rails Security Guide（https://railsguides.jp/security.html）を参考にしています。

---

## 目次

1. [概要](#概要)
2. [bin/rails generate authentication について](#binrails-generate-authentication-について)
3. [APIモードでの注意点](#apiモードでの注意点)
4. [推奨実装フロー](#推奨実装フロー)
5. [実装手順](#実装手順)
6. [セキュリティ考慮事項](#セキュリティ考慮事項)

---

## 概要

Rails 8.0以降では、`bin/rails generate authentication` コマンドが導入され、基本的な認証機能を自動生成できるようになりました。しかし、このジェネレータは標準のRailsアプリケーション（ViewとControllerを含む）向けに設計されており、**APIモードのプロジェクトでは不要なファイルが生成される**可能性があります。

本プロジェクトはAPIモード（`config.api_only = true`）で構築されているため、必要なファイルのみを生成・編集する必要があります。

---

## bin/rails generate authentication について

### 生成されるファイル（標準モード）

`bin/rails generate authentication` を実行すると、以下のファイルが生成されます：

```
create  app/models/user.rb
create  app/models/session.rb
create  app/models/current.rb
create  app/controllers/sessions_controller.rb
create  app/controllers/concerns/authentication.rb
create  app/views/sessions/new.html.erb
create  db/migrate/XXXXXX_create_users.rb
create  db/migrate/XXXXXX_create_sessions.rb
create  test/models/user_test.rb
create  test/controllers/sessions_controller_test.rb
route   resources :sessions, only: [:new, :create, :destroy]
```

### APIモードで不要なファイル

APIモードでは、以下のファイルは**不要**です：

- ❌ `app/views/sessions/new.html.erb` - HTMLビューは不要
- ❌ ビュー関連のヘルパーやアセット

### APIモードで必要なファイル

- ✅ `app/models/user.rb` - ユーザーモデル
- ✅ `app/models/session.rb` - セッションモデル
- ✅ `app/models/current.rb` - 現在のユーザー管理
- ✅ `app/controllers/sessions_controller.rb` - 認証用コントローラー（API用に修正）
- ✅ `app/controllers/concerns/authentication.rb` - 認証用Concern
- ✅ マイグレーションファイル
- ✅ テストファイル

---

## APIモードでの注意点

### 1. セッション管理

APIモードでは、通常のCookieベースのセッション管理ではなく、以下のいずれかを使用します：

- **トークンベース認証**（JWT、APIキーなど）
- **HTTPベーシック認証**
- **OAuth 2.0**

### 2. CORS設定

クロスオリジンリクエストを許可する必要があります（`config/initializers/cors.rb`）。

### 3. レスポンス形式

すべてのレスポンスはJSON形式で返します。

---

## 推奨実装フロー

APIモードでの認証機能実装は、以下の流れで行うことを推奨します：

### フロー1: 手動実装（推奨）

1. ✅ Userモデルを手動で作成
2. ✅ パスワードハッシュ化に `bcrypt` gemを使用
3. ✅ トークンベースの認証機能を実装
4. ✅ 認証用のコントローラーとConcernを作成
5. ✅ テストを作成
6. ✅ セキュリティ対策を実施

### フロー2: ジェネレータ使用後に修正

1. ⚠️ `bin/rails generate authentication` を実行
2. ⚠️ 不要なビューファイルを削除
3. ⚠️ コントローラーをAPI用に修正
4. ⚠️ ルーティングを調整
5. ⚠️ テストを修正

**フロー1（手動実装）を推奨します。** より柔軟で、APIモードに最適化された実装が可能です。

---

## 実装手順

### ステップ1: Gemfileにbcryptを追加

パスワードのハッシュ化に `bcrypt` gemが必要です。

```ruby
# Gemfile
gem 'bcrypt', '~> 3.1.7'
```

インストール：

```bash
docker compose run --rm api bundle install
```

### ステップ2: Userモデルの作成

```bash
docker compose run --rm api bundle exec rails generate model User email:string:uniq password_digest:string
docker compose run --rm api bundle exec rails db:migrate
```

生成されたマイグレーションファイルを確認・編集：

```ruby
# db/migrate/XXXXXX_create_users.rb
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false

      t.timestamps
    end
    
    add_index :users, :email, unique: true
  end
end
```

Userモデルを編集：

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  
  normalizes :email, with: -> { _1.strip.downcase }
end
```

### ステップ3: トークンベースの認証機能

セッション管理にトークンを使用する場合、Sessionモデルを作成します：

```bash
docker compose run --rm api bundle exec rails generate model Session user:references token:string:uniq ip_address:string user_agent:string expires_at:datetime
docker compose run --rm api bundle exec rails db:migrate
```

Sessionモデル：

```ruby
# app/models/session.rb
class Session < ApplicationRecord
  belongs_to :user
  
  before_create :generate_token
  
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
  
  scope :active, -> { where("expires_at > ?", Time.current) }
  
  def active?
    expires_at > Time.current
  end
  
  def expired?
    !active?
  end
  
  private
  
  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
    self.expires_at = 30.days.from_now
  end
end
```

### ステップ4: Currentモデル（現在のユーザー管理）

```ruby
# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :session
  
  def user
    session&.user
  end
end
```

### ステップ5: 認証用Concern

```ruby
# app/controllers/concerns/authentication.rb
module Authentication
  extend ActiveSupport::Concern
  
  included do
    before_action :require_authentication
  end
  
  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end
  
  private
  
  def require_authentication
    resume_session || request_authentication
  end
  
  def resume_session
    if session = Session.active.find_by(token: token_from_header)
      Current.session = session
    end
  end
  
  def request_authentication
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
  
  def token_from_header
    request.headers['Authorization']&.split(' ')&.last
  end
end
```

### ステップ6: SessionsController（認証API）

```ruby
# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  allow_unauthenticated_access
  
  # POST /sessions
  def create
    user = User.find_by(email: params[:email])
    
    if user&.authenticate(params[:password])
      session = user.sessions.create!(
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )
      
      render json: {
        token: session.token,
        expires_at: session.expires_at,
        user: {
          id: user.id,
          email: user.email
        }
      }, status: :created
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end
  
  # DELETE /sessions/:token
  def destroy
    session = Session.find_by(token: params[:id])
    session&.destroy
    
    head :no_content
  end
end
```

### ステップ7: ApplicationControllerに認証を追加

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  include Authentication
end
```

### ステップ8: ルーティング設定

```ruby
# config/routes.rb
Rails.application.routes.draw do
  get "/health", to: "health#index"
  
  # 認証関連のエンドポイント
  resources :sessions, only: [:create, :destroy]
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
end
```

### ステップ9: HealthControllerに認証除外設定

```ruby
# app/controllers/health_controller.rb
class HealthController < ApplicationController
  allow_unauthenticated_access
  
  def index
    render json: { status: 'ok' }
  end
end
```

### ステップ10: テストの作成

```ruby
# test/models/user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should not save user without email" do
    user = User.new(password: 'password123')
    assert_not user.save
  end
  
  test "should not save user with invalid email" do
    user = User.new(email: 'invalid', password: 'password123')
    assert_not user.save
  end
  
  test "should save user with valid attributes" do
    user = User.new(email: 'test@example.com', password: 'password123')
    assert user.save
  end
  
  test "should authenticate with correct password" do
    user = User.create!(email: 'test@example.com', password: 'password123')
    assert user.authenticate('password123')
  end
  
  test "should not authenticate with incorrect password" do
    user = User.create!(email: 'test@example.com', password: 'password123')
    assert_not user.authenticate('wrongpassword')
  end
end
```

```ruby
# test/controllers/sessions_controller_test.rb
require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should create session with valid credentials" do
    user = User.create!(email: 'test@example.com', password: 'password123')
    
    post sessions_url, params: { email: 'test@example.com', password: 'password123' }, as: :json
    
    assert_response :created
    assert_not_nil JSON.parse(response.body)['token']
  end
  
  test "should not create session with invalid credentials" do
    post sessions_url, params: { email: 'test@example.com', password: 'wrongpassword' }, as: :json
    
    assert_response :unauthorized
  end
  
  test "should destroy session" do
    user = User.create!(email: 'test@example.com', password: 'password123')
    session = user.sessions.create!
    
    delete session_url(session.token)
    
    assert_response :no_content
    assert_nil Session.find_by(token: session.token)
  end
end
```

### ステップ11: テストの実行

```bash
docker compose run --rm api bundle exec rails test
```

---

## セキュリティ考慮事項

Rails Security Guideを参照し、以下のセキュリティ対策を実施してください：

### 1. パスワードのセキュリティ

- ✅ `bcrypt` を使用してパスワードをハッシュ化（`has_secure_password`）
- ✅ 最小文字数の検証（8文字以上推奨）
- ✅ パスワードの複雑性要件（必要に応じて）

### 2. トークンのセキュリティ

- ✅ セキュアなトークン生成（`SecureRandom.urlsafe_base64`）
- ✅ トークンの有効期限設定
- ✅ トークンの一意性保証

### 3. レート制限

ブルートフォース攻撃を防ぐため、ログイン試行回数を制限します：

```ruby
# Gemfile
gem 'rack-attack'
```

```ruby
# config/initializers/rack_attack.rb
class Rack::Attack
  # ログイン試行を5回/分に制限
  throttle('sessions/ip', limit: 5, period: 1.minute) do |req|
    if req.path == '/sessions' && req.post?
      req.ip
    end
  end
end
```

### 4. HTTPS通信

本番環境では必ずHTTPS通信を使用します：

```ruby
# config/environments/production.rb
config.force_ssl = true
```

### 5. CORS設定

必要な場合のみCORSを有効化し、許可するオリジンを制限します：

```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'https://your-frontend-domain.com'
    
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
```

### 6. SQLインジェクション対策

- ✅ プレースホルダーを使用（`User.find_by(email: params[:email])`）
- ❌ 文字列連結を避ける（`User.where("email = '#{params[:email]}'")`）

### 7. マスアサインメント対策

Strong Parametersを使用：

```ruby
def user_params
  params.require(:user).permit(:email, :password, :password_confirmation)
end
```

### 8. セッション固定攻撃対策

ログイン成功時にセッションIDを再生成します（トークンベース認証では新しいトークンを生成）。

### 9. クロスサイトスクリプティング（XSS）対策

APIモードではHTMLを返さないため、XSSのリスクは低いですが、JSONレスポンスのエスケープは自動で行われます。

### 10. ログ出力の注意

パスワードやトークンをログに出力しないようにします：

```ruby
# config/initializers/filter_parameter_logging.rb
Rails.application.config.filter_parameters += [
  :passw, :email, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
]
```

---

## まとめ

このガイドでは、Rails APIモードでの認証機能実装の流れを説明しました。

**重要なポイント：**

1. ❌ `bin/rails generate authentication` はAPIモード向けではない
2. ✅ 手動実装でAPIに最適化された認証機能を構築
3. ✅ トークンベースの認証を使用
4. ✅ セキュリティ対策を徹底
5. ✅ テストを作成して動作確認

本ガイドに従って実装することで、セキュアで保守性の高い認証機能を構築できます。

---

## 参考資料

- [Rails Security Guide](https://railsguides.jp/security.html)
- [Rails API Documentation](https://api.rubyonrails.org/)
- [bcrypt gem](https://github.com/bcrypt-ruby/bcrypt-ruby)
- [has_secure_password](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html)
