#!/bin/bash

###############################################################################
# 認証機能実装のGitHubイシュー作成スクリプト
#
# 使い方:
#   chmod +x scripts/create-authentication-issue.sh
#   ./scripts/create-authentication-issue.sh
#
# 前提条件:
#   - GitHub CLI (gh) がインストールされていること
#   - GitHub CLI でログイン済みであること (gh auth login)
#   - このリポジトリのルートディレクトリで実行すること
###############################################################################

set -e

# カラー出力の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 設定
REPO="sukotazushi/portfolio-api"
TITLE="[Feature] 認証機能の実装"
TEMPLATE_FILE=".github/ISSUE_TEMPLATE/authentication-implementation.md"
LABELS="enhancement,security"

echo -e "${GREEN}==================================================================${NC}"
echo -e "${GREEN}  認証機能実装のGitHubイシュー作成スクリプト${NC}"
echo -e "${GREEN}==================================================================${NC}"
echo ""

# GitHub CLIがインストールされているか確認
if ! command -v gh &> /dev/null; then
    echo -e "${RED}[エラー] GitHub CLI (gh) がインストールされていません${NC}"
    echo ""
    echo "インストール方法:"
    echo "  macOS:   brew install gh"
    echo "  Linux:   https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
    echo "  Windows: https://github.com/cli/cli/releases"
    exit 1
fi

# GitHub CLIでログインしているか確認
if ! gh auth status &> /dev/null; then
    echo -e "${RED}[エラー] GitHub CLI にログインしていません${NC}"
    echo ""
    echo "以下のコマンドでログインしてください:"
    echo "  gh auth login"
    exit 1
fi

# テンプレートファイルが存在するか確認
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo -e "${RED}[エラー] テンプレートファイルが見つかりません: $TEMPLATE_FILE${NC}"
    echo ""
    echo "このスクリプトはリポジトリのルートディレクトリで実行してください。"
    exit 1
fi

# 確認メッセージ
echo -e "${YELLOW}以下の内容でイシューを作成します:${NC}"
echo ""
echo "  リポジトリ: $REPO"
echo "  タイトル:   $TITLE"
echo "  ラベル:     $LABELS"
echo "  テンプレート: $TEMPLATE_FILE"
echo ""
read -p "作成しますか？ (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}キャンセルしました${NC}"
    exit 0
fi

# イシューを作成
echo ""
echo -e "${GREEN}イシューを作成中...${NC}"
echo ""

ISSUE_URL=$(gh issue create \
  --repo "$REPO" \
  --title "$TITLE" \
  --body-file "$TEMPLATE_FILE" \
  --label "$LABELS" \
  2>&1)

# 結果を確認
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}==================================================================${NC}"
    echo -e "${GREEN}  ✅ イシューの作成に成功しました！${NC}"
    echo -e "${GREEN}==================================================================${NC}"
    echo ""
    echo -e "イシューURL: ${GREEN}$ISSUE_URL${NC}"
    echo ""
    echo "次のステップ:"
    echo "  1. イシューの内容を確認"
    echo "  2. 必要に応じてアサインやマイルストーンを設定"
    echo "  3. 実装ガイド (docs/AUTHENTICATION_IMPLEMENTATION.md) を参照して実装開始"
    echo ""
else
    echo ""
    echo -e "${RED}==================================================================${NC}"
    echo -e "${RED}  ❌ イシューの作成に失敗しました${NC}"
    echo -e "${RED}==================================================================${NC}"
    echo ""
    echo "エラー詳細:"
    echo "$ISSUE_URL"
    echo ""
    echo "トラブルシューティング:"
    echo "  1. GitHub CLI が正しくログインしているか確認: gh auth status"
    echo "  2. リポジトリへのアクセス権限があるか確認"
    echo "  3. GitHub CLI のバージョンを確認: gh --version"
    exit 1
fi
