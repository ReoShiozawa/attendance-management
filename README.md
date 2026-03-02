# 勤怠管理システム (kinntai)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue.svg)](https://docs.docker.com/compose/)
[![Python](https://img.shields.io/badge/Python-3.11-green.svg)](https://www.python.org/)
[![ARM64](https://img.shields.io/badge/Assembly-ARM64-red.svg)](./attendance.s)

ARM64アセンブリ・FastAPI・Vanilla JSを組み合わせたフルスタック勤怠管理システムです。JWT認証、ユーザー管理機能を備え、Docker Composeで一発起動できます。

> **学習目的のプロジェクトです。** 低レイヤー（アセンブリ）から高レイヤー（Web API）まで、コンピュータの抽象化レイヤー全体を体験することをテーマに制作しました。

[English README is here](./README_EN.md)

## システム構成

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Frontend      │────▶│   Backend API    │────▶│  Assembly CLI   │
│  (Nginx + JS)   │     │  (FastAPI + JWT) │     │  (ARM64 asm)   │
│  Port: 3000     │     │  Port: 8000      │     │  (開発環境)     │
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

## 主な機能

### 🔐 認証・セキュリティ
- ✅ JWT トークンベース認証（30分有効期限）
- ✅ bcrypt によるパスワードハッシュ化
- ✅ ユーザー登録・ログイン機能
- ✅ 認証不要エンドポイントへの自動リダイレクト
- ✅ トークン検証とリフレッシュ

### 📊 勤怠管理機能
- ✅ 出勤・退勤の記録
- ✅ 勤怠履歴の閲覧
- ✅ 統計情報の表示（勤務日数、総勤務時間等）
- ✅ ユーザー別の記録管理
- ✅ リアルタイム時刻表示

### 💼 フロントエンド
- ✅ ビジネス向けプロフェッショナルUI
- ✅ レスポンシブデザイン（モバイル対応）
- ✅ リアルタイムデータ更新
- ✅ エラーハンドリングと通知機能
- ✅ アクセシビリティ対応

### 🔧 CLI ツール (アセンブリ版)
- ✅ ARM64 アセンブリ言語で実装
- ✅ メニュー駆動型インターフェース
- ✅ ファイルベースのデータ永続化
- ✅ システムコール直接利用

## 必要な環境

### 必須要件
- **Docker**: 20.10 以上
- **Docker Compose**: 2.0 以上
- **アーキテクチャ**: ARM64 (Apple Silicon Mac) または x86_64

### 開発環境
- macOS 12.0 以上（Apple Silicon推奨）
- 8GB以上のメモリ
- 5GB以上のディスク空き容量

## 🚀 クイックスタート

### 1. リポジトリのクローン

```bash
git clone https://github.com/ReoShiozawa/attendance-management.git
cd attendance-management
```

### 2. 全サービスの起動

```bash
docker-compose up --build -d
```

起動するサービス:
- `assembly`: ARM64 アセンブリ開発環境
- `api`: FastAPI バックエンド (ポート 8000)
- `frontend`: Nginx フロントエンド (ポート 3000)

### 3. アクセス方法

**フロントエンド（推奨）:**
```
http://localhost:3000
```

**APIドキュメント（開発者向け）:**
```
http://localhost:8000/docs
```

### 4. 初回ログイン

デフォルトユーザーでログイン:
- **ユーザー名**: `demo`
- **パスワード**: `demo123`

または新規ユーザー登録が可能です。


## 📁 プロジェクト構造

```
kinntai/
├── docker-compose.yml              # 全サービスのオーケストレーション
├── Dockerfile                      # アセンブリ開発環境の定義
├── Makefile                        # アセンブリビルド設定
├── attendance.s                    # ARM64アセンブリCLIツール
├── attendance.dat                  # CLI版データファイル（自動生成・gitignore推奨）
├── LICENSE                         # MITライセンス
├── README.md                       # このファイル
│
├── api/                            # バックエンドAPI
│   ├── Dockerfile                  # FastAPI用コンテナ定義
│   ├── requirements.txt            # Python依存パッケージ
│   │   ├── fastapi==0.104.1
│   │   ├── uvicorn[standard]==0.24.0
│   │   ├── python-jose[cryptography]==3.3.0
│   │   └── bcrypt==4.0.1
│   ├── app.py                      # FastAPI REST APIメイン (315行)
│   └── data/                       # データ保存ディレクトリ
│       ├── users.json              # ユーザー情報（パスワードハッシュ含む）
│       └── records.json            # 勤怠記録
│
└── frontend/                       # フロントエンド
    ├── Dockerfile                  # Nginx用コンテナ定義
    ├── nginx.conf                  # Nginx設定（SPAルーティング対応）
    ├── login.html                  # ログイン・登録ページ
    ├── login.js                    # 認証ロジック
    ├── index.html                  # メインアプリケーションページ
    ├── app.js                      # 勤怠管理ロジック (266行)
    └── style.css                   # ビジネス向けUIスタイル
```

## 🔌 API仕様

### 認証関連エンドポイント

#### POST /api/register
新規ユーザーを登録します。

**リクエスト:**
```json
{
  "username": "taro_yamada",
  "password": "SecurePass123!"
}
```

**レスポンス:**
```json
{
  "message": "ユーザー登録が完了しました",
  "username": "taro_yamada"
}
```

**エラー:**
- `400`: ユーザー名が既に存在する
- `422`: バリデーションエラー

---

#### POST /api/login
ユーザー認証を行い、JWTトークンを発行します。

**リクエスト:**
```json
{
  "username": "taro_yamada",
  "password": "SecurePass123!"
}
```

**レスポンス:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "username": "taro_yamada"
}
```

**エラー:**
- `401`: 認証失敗（ユーザー名またはパスワードが間違っている）

---

### 勤怠管理エンドポイント（要認証）

> **注意**: 以下のエンドポイントは全て `Authorization: Bearer <token>` ヘッダーが必要です。

#### POST /api/clock-in
出勤を記録します。

**ヘッダー:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**レスポンス:**
```json
{
  "message": "出勤を記録しました",
  "timestamp": "2025-10-04T09:00:00",
  "type": "IN",
  "user": "taro_yamada"
}
```

---

#### POST /api/clock-out
退勤を記録します。

**ヘッダー:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**レスポンス:**
```json
{
  "message": "退勤を記録しました",
  "timestamp": "2025-10-04T18:30:00",
  "type": "OUT",
  "user": "taro_yamada"
}
```

---

#### GET /api/records
全ての勤怠記録を取得します（全ユーザー分）。

**ヘッダー:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**レスポンス:**
```json
{
  "records": [
    {
      "timestamp": "2025-10-04T09:00:00",
      "type": "IN",
      "user": "taro_yamada"
    },
    {
      "timestamp": "2025-10-04T18:30:00",
      "type": "OUT",
      "user": "taro_yamada"
    }
  ]
}
```

---

#### GET /api/stats
統計情報を取得します（全ユーザー分）。

**ヘッダー:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**レスポンス:**
```json
{
  "total_days": 20,
  "total_hours": 160.5,
  "average_hours": 8.025
}
```

---

### エラーレスポンス

全エンドポイント共通のエラーレスポンス形式:

```json
{
  "detail": "エラーの詳細メッセージ"
}
```

**HTTPステータスコード:**
- `200`: 成功
- `400`: リクエストが不正
- `401`: 認証が必要、またはトークンが無効
- `404`: リソースが見つからない
- `422`: バリデーションエラー
- `500`: サーバーエラー


## 🛠️ 開発ガイド

### サービス別起動方法

#### すべてのサービスを起動
```bash
docker-compose up -d
```

#### 特定のサービスのみ起動
```bash
# APIサーバーのみ
docker-compose up -d api

# フロントエンドのみ
docker-compose up -d frontend

# アセンブリ開発環境のみ
docker-compose run --rm assembly
```

#### ログの確認
```bash
# 全サービスのログをリアルタイム表示
docker-compose logs -f

# 特定サービスのログ
docker-compose logs -f api
docker-compose logs -f frontend
```

### バックエンド開発 (FastAPI)

#### ローカル開発環境のセットアップ
```bash
cd api

# 仮想環境の作成
python3 -m venv venv
source venv/bin/activate  # macOS/Linux
# または
.\venv\Scripts\activate   # Windows

# 依存パッケージのインストール
pip install -r requirements.txt

# 開発サーバー起動（ホットリロード有効）
uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

#### APIテスト例
```bash
# ユーザー登録
curl -X POST http://localhost:8000/api/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test_user","password":"test123"}'

# ログイン
TOKEN=$(curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test_user","password":"test123"}' \
  | jq -r '.access_token')

# 出勤記録
curl -X POST http://localhost:8000/api/clock-in \
  -H "Authorization: Bearer $TOKEN"

# 勤怠履歴取得
curl http://localhost:8000/api/records \
  -H "Authorization: Bearer $TOKEN"

# 統計情報取得
curl http://localhost:8000/api/stats \
  -H "Authorization: Bearer $TOKEN"
```

#### JWTトークンの設定変更

`api/app.py` の以下の部分で設定可能:

```python
SECRET_KEY = "your-secret-key-change-in-production"  # 本番環境では必ず変更
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30  # トークン有効期限
```

### フロントエンド開発

#### ファイル構成
- `login.html` + `login.js`: 認証画面
- `index.html` + `app.js`: メインアプリケーション
- `style.css`: 全体のスタイル定義

#### 開発時の注意点
1. **認証状態の管理**: `localStorage` に JWT トークンを保存
2. **API呼び出し**: 全て `getAuthHeaders()` 関数でトークンを付与
3. **エラーハンドリング**: 401エラー時は自動的にログアウト

#### スタイル変更後の反映
```bash
# フロントエンドコンテナを再ビルド
docker-compose up --build -d frontend

# ブラウザのキャッシュをクリア（Cmd+Shift+R または Ctrl+Shift+R）
```

### アセンブリ開発 (ARM64)

#### コンテナに入る
```bash
docker-compose run --rm assembly
```

#### ビルドとデバッグ
```bash
# 通常ビルド
make

# クリーンビルド
make clean
make

# デバッグ情報付きビルド
make debug

# GDBでデバッグ
gdb ./attendance
(gdb) break main
(gdb) run
(gdb) step
```

#### アセンブリコードの構造

`attendance.s` は以下のセクションで構成:

1. **データセクション** (.data): 文字列定数、メッセージ
2. **BSSセクション** (.bss): 未初期化データ、バッファ
3. **テキストセクション** (.text): 実行コード

主な関数:
- `_start`: エントリポイント
- `show_menu`: メニュー表示
- `clock_in`: 出勤記録
- `clock_out`: 退勤記録
- `view_records`: 履歴表示

#### システムコール一覧
```asm
sys_read    = 63    // 標準入力から読み取り
sys_write   = 64    // 標準出力へ書き込み
sys_openat  = 56    // ファイルオープン
sys_close   = 57    // ファイルクローズ
sys_exit    = 93    // プログラム終了
```

## 🔒 セキュリティ考慮事項

### 本番環境での対策

#### 1. シークレットキーの変更
```python
# api/app.py
SECRET_KEY = os.environ.get("SECRET_KEY", "production-secure-random-key")
```

環境変数で設定:
```bash
export SECRET_KEY="$(openssl rand -hex 32)"
```

#### 2. CORS設定の厳格化
```python
# 本番環境では特定のオリジンのみ許可
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://yourdomain.com"],  # ワイルドカード禁止
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["Authorization", "Content-Type"],
)
```

#### 3. HTTPS化
```bash
# docker-compose.yml にSSL証明書を追加
# Let's Encryptなどを使用
```

#### 4. データベースの使用
現在はJSONファイルで保存していますが、本番環境では以下を推奨:
- PostgreSQL
- MySQL
- MongoDB

#### 5. パスワードポリシー
現在の実装にパスワード強度チェックを追加:
```python
# 最小8文字、大文字・小文字・数字を含む、など
```

#### 6. レート制限
ブルートフォース攻撃対策:
```python
from slowapi import Limiter
# ログインエンドポイントに制限を追加
```

## 📊 データ保存形式

### ユーザー情報 (`api/data/users.json`)
```json
{
  "demo": {
    "username": "demo",
    "hashed_password": "$2b$12$..."
  }
}
```

### 勤怠記録 (`api/data/records.json`)
```json
{
  "records": [
    {
      "user": "demo",
      "timestamp": "2025-10-04T09:00:00",
      "type": "IN"
    },
    {
      "user": "demo",
      "timestamp": "2025-10-04T18:30:00",
      "type": "OUT"
    }
  ]
}
```

### CLI版データ (`attendance.dat`)
テキスト形式:
```
2025-10-04 09:00:00 IN
2025-10-04 18:30:00 OUT
```

> **注意**: Web版とCLI版はデータを共有しません。


## 🧪 テスト

### 手動テスト手順

#### 1. システム起動確認
```bash
# 全サービスの起動
docker-compose up -d

# コンテナの状態確認
docker-compose ps
# すべて "Up" になっていることを確認

# ヘルスチェック
curl http://localhost:8000/docs  # Swagger UIが表示される
curl http://localhost:3000       # ログイン画面が表示される
```

#### 2. ユーザー登録・ログインテスト
1. ブラウザで `http://localhost:3000` にアクセス
2. 「新規登録」タブをクリック
3. ユーザー名とパスワードを入力して登録
4. ログイン画面で認証情報を入力
5. メイン画面に遷移することを確認

#### 3. 勤怠記録テスト
1. 「出勤」ボタンをクリック
2. 成功メッセージが表示されることを確認
3. 履歴に出勤記録が追加されることを確認
4. 「退勤」ボタンをクリック
5. 履歴に退勤記録が追加されることを確認

#### 4. ログアウト・再ログインテスト
1. 「ログアウト」ボタンをクリック
2. ログイン画面に遷移することを確認
3. 再度ログイン
4. 以前の記録が保持されていることを確認

### API統合テスト（curl）

```bash
#!/bin/bash
API_URL="http://localhost:8000"

# 1. ユーザー登録
echo "=== ユーザー登録 ==="
curl -X POST "$API_URL/api/register" \
  -H "Content-Type: application/json" \
  -d '{"username":"test_automation","password":"testpass123"}'
echo -e "\n"

# 2. ログイン
echo "=== ログイン ==="
TOKEN=$(curl -s -X POST "$API_URL/api/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"test_automation","password":"testpass123"}' \
  | jq -r '.access_token')
echo "Token: $TOKEN"
echo -e "\n"

# 3. 出勤記録
echo "=== 出勤 ==="
curl -X POST "$API_URL/api/clock-in" \
  -H "Authorization: Bearer $TOKEN"
echo -e "\n"

# 4. 退勤記録
echo "=== 退勤 ==="
curl -X POST "$API_URL/api/clock-out" \
  -H "Authorization: Bearer $TOKEN"
echo -e "\n"

# 5. 記録取得
echo "=== 勤怠履歴 ==="
curl -X GET "$API_URL/api/records" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.'
echo -e "\n"

# 6. 統計情報
echo "=== 統計情報 ==="
curl -X GET "$API_URL/api/stats" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.'
```

このスクリプトを `test_api.sh` として保存し、実行:
```bash
chmod +x test_api.sh
./test_api.sh
```

## 🐛 トラブルシューティング

### よくある問題と解決方法

#### 1. コンテナが起動しない

**症状**: `docker-compose up` でエラー

**確認項目**:
```bash
# Dockerが起動しているか確認
docker info

# ポートが使用されていないか確認
lsof -i :3000
lsof -i :8000

# ディスク容量を確認
df -h
```

**解決方法**:
```bash
# すべてのコンテナを停止
docker-compose down

# イメージを再ビルド
docker-compose build --no-cache

# 再起動
docker-compose up -d
```

---

#### 2. APIに接続できない

**症状**: フロントエンドから API 呼び出しが失敗

**確認項目**:
```bash
# APIコンテナのログを確認
docker-compose logs api

# APIが起動しているか確認
curl http://localhost:8000/docs
```

**解決方法**:
```bash
# APIコンテナを再起動
docker-compose restart api

# CORSエラーの場合、api/app.pyのCORS設定を確認
```

---

#### 3. ログインできない

**症状**: 認証情報が正しいのにログイン失敗

**確認項目**:
```bash
# ユーザーデータを確認
cat api/data/users.json

# APIログでエラーを確認
docker-compose logs api | grep -i error
```

**解決方法**:
```bash
# デフォルトユーザーでログイン: demo / demo123

# 新規ユーザーを登録してみる

# users.jsonを削除して初期化（全ユーザーが削除されます）
rm api/data/users.json
docker-compose restart api
```

---

#### 4. トークンが無効になる

**症状**: 操作中に突然ログアウトされる

**原因**: JWTトークンの有効期限（30分）切れ

**解決方法**:
- 再度ログインする
- トークンの有効期限を延長（`api/app.py` の `ACCESS_TOKEN_EXPIRE_MINUTES` を変更）

---

#### 5. フロントエンドの変更が反映されない

**症状**: CSS/JSを変更しても画面に反映されない

**解決方法**:
```bash
# コンテナを再ビルド
docker-compose up --build -d frontend

# ブラウザのキャッシュをクリア
# Chrome/Edge: Cmd+Shift+R (Mac) / Ctrl+Shift+R (Win)
# Safari: Cmd+Option+E → Cmd+R
```

---

#### 6. アセンブリがビルドできない

**症状**: `make` でエラー

**確認項目**:
```bash
# アーキテクチャを確認
uname -m
# arm64 または aarch64 であること

# GNU Assemblerがインストールされているか
as --version
```

**解決方法**:
```bash
# クリーンビルド
make clean
make

# Apple Silicon以外の環境では、アセンブリコードの修正が必要
# または、assembly サービスを無効化
```

---

#### 7. データが消える

**症状**: 勤怠記録が保存されない

**確認項目**:
```bash
# データファイルの存在確認
ls -la api/data/

# ファイルの権限確認
ls -l api/data/records.json
```

**解決方法**:
```bash
# dataディレクトリを作成
mkdir -p api/data

# 権限を付与
chmod 755 api/data

# コンテナを再起動
docker-compose restart api
```

---

#### 8. パフォーマンスが悪い

**症状**: 画面の読み込みが遅い

**解決方法**:
```bash
# Docker Desktopのリソース設定を確認
# メモリ: 4GB以上推奨
# CPU: 2コア以上推奨

# 不要なコンテナを削除
docker system prune -a

# ログファイルをクリア
docker-compose down
rm -rf api/data/*.log
```

## 📦 デプロイ

### 本番環境へのデプロイ手順

#### 1. 環境変数の設定

`.env` ファイルを作成:
```env
# JWT設定
SECRET_KEY=your-production-secret-key-min-32-chars
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# データベース（将来的に）
DATABASE_URL=postgresql://user:pass@localhost/kinntai

# CORS設定
ALLOWED_ORIGINS=https://yourdomain.com
```

#### 2. docker-compose.prod.yml の作成

```yaml
version: '3.8'
services:
  api:
    build: ./api
    environment:
      - SECRET_KEY=${SECRET_KEY}
      - ALLOWED_ORIGINS=${ALLOWED_ORIGINS}
    restart: always
    
  frontend:
    build: ./frontend
    restart: always
    
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    restart: always
```

#### 3. リバースプロキシ設定（Nginx）

```nginx
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name yourdomain.com;
    
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    
    location / {
        proxy_pass http://frontend:80;
    }
    
    location /api {
        proxy_pass http://api:8000;
    }
}
```

#### 4. デプロイ実行

```bash
# 本番用ビルド
docker-compose -f docker-compose.prod.yml build

# 起動
docker-compose -f docker-compose.prod.yml up -d

# ヘルスチェック
curl https://yourdomain.com
```

#### 5. 監視とログ

```bash
# ログのローテーション設定
docker-compose -f docker-compose.prod.yml logs --tail=100 -f

# Prometheusなどのモニタリングツール導入を推奨
```

## トラブルシューティング

### ポートが既に使用されている

```bash
# 使用中のポートを確認
lsof -i :5000
lsof -i :8080

# docker-compose.ymlのポート番号を変更
```

### APIサーバーに接続できない

```bash
# APIサーバーのログを確認
docker-compose logs api

# コンテナの状態を確認
docker-compose ps
```

### アセンブリのビルドエラー

```bash
# クリーンビルド
make clean
make

# アーキテクチャを確認
uname -m  # aarch64 であることを確認
```


## � 参考資料

### 公式ドキュメント
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Docker Documentation](https://docs.docker.com/)
- [ARM Assembly Reference](https://developer.arm.com/documentation/)
- [JWT Introduction](https://jwt.io/introduction)

### 関連技術
- [bcrypt Hashing](https://en.wikipedia.org/wiki/Bcrypt)
- [RESTful API Design](https://restfulapi.net/)
- [CORS in Detail](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)

## 🤝 貢献

### 開発への参加方法

1. このリポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

### コーディング規約

- **Python**: PEP 8 準拠
- **JavaScript**: セミコロンあり、2スペースインデント
- **CSS**: BEM命名規則推奨
- **Assembly**: コメントは日本語可

## 📋 今後の拡張アイデア

### 短期的な改善（1-2ヶ月）
- [ ] パスワード強度チェック機能
- [ ] 記録の編集・削除機能
- [ ] ユーザープロフィール管理
- [ ] CSV/PDFエクスポート機能
- [ ] ダークモード対応

### 中期的な改善（3-6ヶ月）
- [ ] データベース連携（PostgreSQL/MySQL）
- [ ] レート制限（API保護）
- [ ] メール通知機能
- [ ] 月次・週次レポート
- [ ] 管理者ダッシュボード

### 長期的な改善（6ヶ月以上）
- [ ] モバイルアプリ版（React Native）
- [ ] リアルタイム通知（WebSocket）
- [ ] 顔認証統合
- [ ] 位置情報記録（GPS）
- [ ] Slackボット連携
- [ ] マルチテナント対応
- [ ] Kubernetes対応

## 📄 ライセンス

MIT License

Copyright (c) 2025 勤怠管理システム開発チーム

本ソフトウェアおよび関連文書ファイル（以下「ソフトウェア」）のコピーを取得した者は、制限なしにソフトウェアを扱うことが許可されます。

## 👥 作成者・メンテナンス情報

**プロジェクト名**: 勤怠管理システム (Enterprise Edition)  
**技術スタック**: ARM64 Assembly + Python FastAPI + Vanilla JavaScript  
**開発環境**: Docker + Docker Compose  
**対応アーキテクチャ**: ARM64 (Apple Silicon), x86_64

### システム要件
- **最小要件**: Docker 20.10+, 4GB RAM, 3GB ディスク
- **推奨要件**: Docker 24.0+, 8GB RAM, 5GB ディスク
- **OS**: macOS 12+, Linux (Ubuntu 20.04+), Windows 10+ (WSL2)

### メンテナンス担当
- **アセンブリ実装**: ARM64 CLI ツール開発・保守
- **バックエンド実装**: FastAPI REST API 開発・保守
- **フロントエンド実装**: UI/UX デザイン・実装

### サポート
- バグ報告: Issue トラッカーにて受付
- 機能要望: Pull Request歓迎
- セキュリティ報告: 非公開で連絡

---

**最終更新日**: 2025年10月4日  
**ドキュメントバージョン**: 2.0  
**システムバージョン**: 1.0.0  
**ステータス**: ✅ Production Ready

### 変更履歴

#### v1.0.0 (2025-10-04)
- ✅ 初回リリース
- ✅ JWT認証実装
- ✅ ユーザー登録・ログイン機能
- ✅ 勤怠記録CRUD操作
- ✅ 統計情報表示
- ✅ ビジネス向けUIデザイン
- ✅ ARM64アセンブリCLIツール
- ✅ Docker環境完備

---

> **重要**: 本番環境にデプロイする前に、必ず「セキュリティ考慮事項」セクションを確認し、適切な対策を実施してください。特にJWTシークレットキーの変更、CORS設定の厳格化、HTTPS化は必須です。

> **後任エンジニアへ**: このREADMEには、システムの全体像から細かな実装詳細まで記載されています。不明な点があれば、まず「トラブルシューティング」セクションを確認してください。それでも解決しない場合は、各サービスのログ (`docker-compose logs`) を確認することをお勧めします。

| 項目 | 技術 | バージョン | 用途 |
|------|------|-----------|------|
| 言語 | Python | 3.11 | メイン開発言語 |
| フレームワーク | FastAPI | 0.104.1 | REST API実装 |
| ASGIサーバー | Uvicorn | 0.24.0 | 非同期サーバー |
| 認証 | python-jose | 3.3.0 | JWT生成・検証 |
| パスワード | bcrypt | 4.0.1 | ハッシュ化 |
| データ保存 | JSON | - | ファイルベース |

**特徴:**
- 非同期I/Oによる高速処理
- 自動APIドキュメント生成（Swagger UI）
- Pydanticによる型安全なバリデーション
- CORSミドルウェアによるクロスオリジン対応

### フロントエンド
| 項目 | 技術 | 説明 |
|------|------|------|
| HTML | HTML5 | セマンティックマークアップ |
| CSS | CSS3 | ビジネス向けプロフェッショナルデザイン |
| JavaScript | Vanilla JS | フレームワークレス（軽量・高速） |
| Webサーバー | Nginx Alpine | 静的ファイル配信 |

**デザイン特徴:**
- 企業向け保守的カラースキーム（青・グレー基調）
- レスポンシブデザイン（モバイル対応）
- アクセシビリティ考慮（キーボード操作対応）
- 印刷用スタイル対応

### CLI ツール（アセンブリ）
| 項目 | 技術 | 説明 |
|------|------|------|
| アーキテクチャ | ARM64 (AArch64) | Apple Silicon対応 |
| アセンブラ | GNU Assembler (as) | GCCツールチェーン |
| リンカ | ld | 静的リンク |
| デバッガ | GDB | デバッグ対応 |

**実装詳細:**
- ダイレクトシステムコール使用（libc不使用）
- メニュー駆動型インターフェース
- ファイルI/Oによるデータ永続化
- 424行の純粋なアセンブリコード

### インフラ・DevOps
| 項目 | 技術 | 用途 |
|------|------|------|
| コンテナ化 | Docker | 各サービスの隔離 |
| オーケストレーション | Docker Compose | マルチコンテナ管理 |
| ベースイメージ | Alpine Linux | 軽量イメージ |
| ネットワーク | Docker Network | サービス間通信 |

## 📐 アーキテクチャ設計

### システム構成図

```
┌─────────────────────────────────────────────────────────────┐
│                        ユーザー                                │
└────────────────────┬────────────────────────────────────────┘
                     │ HTTPS (本番環境)
                     │ HTTP:3000 (開発環境)
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                  Frontend (Nginx)                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ login.html   │  │  index.html  │  │  style.css   │     │
│  │ login.js     │  │  app.js      │  │              │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                         │                                    │
│                         │ HTTP:8000/api/*                   │
│                         ▼                                    │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                  Backend API (FastAPI)                       │
│  ┌────────────────────────────────────────────────────┐    │
│  │  認証ミドルウェア (JWT Verification)                  │    │
│  └─────────────────┬──────────────────────────────────┘    │
│                    │                                         │
│  ┌─────────────────▼──────────────────────────────────┐    │
│  │  エンドポイント                                       │    │
│  │  - POST /api/login                                  │    │
│  │  - POST /api/register                               │    │
│  │  - POST /api/clock-in    (要認証)                   │    │
│  │  - POST /api/clock-out   (要認証)                   │    │
│  │  - GET  /api/records     (要認証)                   │    │
│  │  - GET  /api/stats       (要認証)                   │    │
│  └─────────────────┬──────────────────────────────────┘    │
│                    │                                         │
│  ┌─────────────────▼──────────────────────────────────┐    │
│  │  データアクセス層                                      │    │
│  │  - users.json (ユーザー管理)                         │    │
│  │  - records.json (勤怠記録)                           │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│           CLI Tool (ARM64 Assembly) - 独立動作                │
│  ┌────────────────────────────────────────────────────┐    │
│  │  メニューシステム                                      │    │
│  │  1. 出勤  2. 退勤  3. 履歴  4. 終了                  │    │
│  └─────────────────┬──────────────────────────────────┘    │
│                    │                                         │
│  ┌─────────────────▼──────────────────────────────────┐    │
│  │  システムコール層                                      │    │
│  │  - sys_read   (入力)                                │    │
│  │  - sys_write  (出力)                                │    │
│  │  - sys_openat (ファイルオープン)                     │    │
│  │  - sys_close  (ファイルクローズ)                     │    │
│  └─────────────────┬──────────────────────────────────┘    │
│                    │                                         │
│  ┌─────────────────▼──────────────────────────────────┐    │
│  │  attendance.dat (テキストファイル)                    │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### 認証フロー

```
┌──────┐                ┌──────────┐              ┌─────────┐
│Client│                │ Frontend │              │   API   │
└──┬───┘                └────┬─────┘              └────┬────┘
   │                         │                         │
   │ 1. ユーザー情報入力      │                         │
   ├────────────────────────▶│                         │
   │                         │ 2. POST /api/login      │
   │                         ├────────────────────────▶│
   │                         │                         │
   │                         │   3. パスワード検証      │
   │                         │      (bcrypt.verify)    │
   │                         │◀────────────────────────┤
   │                         │                         │
   │                         │   4. JWT生成            │
   │                         │      (30分有効)         │
   │                         │◀────────────────────────┤
   │                         │                         │
   │  5. トークン保存         │                         │
   │     (localStorage)      │                         │
   │◀────────────────────────┤                         │
   │                         │                         │
   │  6. 出勤ボタンクリック   │                         │
   ├────────────────────────▶│                         │
   │                         │ 7. POST /api/clock-in   │
   │                         │    Header: Bearer Token │
   │                         ├────────────────────────▶│
   │                         │                         │
   │                         │   8. トークン検証        │
   │                         │◀────────────────────────┤
   │                         │                         │
   │                         │   9. 記録保存            │
   │                         │      (records.json)     │
   │                         │◀────────────────────────┤
   │                         │                         │
   │  10. 成功メッセージ表示  │                         │
   │◀────────────────────────┤                         │
```

### データフロー

```
[ユーザー操作]
     │
     ▼
[フロントエンド: login.js / app.js]
     │
     │ fetch() + Authorization Header
     ▼
[CORS Middleware] ← 許可されたオリジンか確認
     │
     ▼
[認証ミドルウェア] ← JWTトークン検証
     │                (公開エンドポイントは除外)
     ▼
[エンドポイント関数]
     │
     ▼
[ビジネスロジック]
     │ ┌─ パスワードハッシュ化 (bcrypt)
     │ ├─ タイムスタンプ生成 (datetime)
     │ └─ データ検証 (Pydantic)
     ▼
[データアクセス層]
     │
     ├─▶ users.json (読み書き)
     └─▶ records.json (読み書き)
```

## 🔄 Docker コマンドリファレンス

### 基本操作

```bash
# すべてのサービスを起動（フォアグラウンド）
docker-compose up

# すべてのサービスを起動（バックグラウンド）
docker-compose up -d

# 特定のサービスのみ起動
docker-compose up -d api
docker-compose up -d frontend

# ビルドしてから起動
docker-compose up --build

# サービスの停止
docker-compose stop

# サービスの停止と削除
docker-compose down

# ボリュームも含めて完全削除
docker-compose down -v

# サービスの再起動
docker-compose restart

# 特定サービスの再起動
docker-compose restart api
```

### ログ管理

```bash
# すべてのサービスのログを表示
docker-compose logs

# リアルタイムでログを追跡
docker-compose logs -f

# 特定サービスのログのみ
docker-compose logs -f api

# 最新100行のみ表示
docker-compose logs --tail=100

# タイムスタンプ付きでログ表示
docker-compose logs -t
```

### コンテナ管理

```bash
# 実行中のコンテナ一覧
docker-compose ps

# コンテナの詳細情報
docker-compose ps -a

# コンテナ内でコマンド実行
docker-compose exec api bash
docker-compose exec frontend sh

# 一時的にコンテナを起動してコマンド実行
docker-compose run --rm assembly bash

# コンテナの統計情報（CPU、メモリ使用量）
docker stats
```

### ビルド・クリーンアップ

```bash
# イメージを再ビルド
docker-compose build

# キャッシュを使わずにビルド
docker-compose build --no-cache

# 特定サービスのみビルド
docker-compose build api

# 未使用のイメージを削除
docker image prune

# すべての未使用リソースを削除
docker system prune -a

# ビルドキャッシュをクリア
docker builder prune
```

### ネットワーク・ボリューム

```bash
# ネットワーク一覧
docker network ls

# ボリューム一覧
docker volume ls

# 未使用ネットワークを削除
docker network prune

# 未使用ボリュームを削除
docker volume prune
```

---

## 🤝 コントリビューション

IssueやPull Requestは大歓迎です！

1. このリポジトリをForkする
2. フィーチャーブランチを作成する (`git checkout -b feature/awesome-feature`)
3. 変更をコミットする (`git commit -m 'Add awesome feature'`)
4. ブランチにプッシュする (`git push origin feature/awesome-feature`)
5. Pull Requestを作成する

### 開発時の注意事項

- `api/app.py` の `SECRET_KEY` は本番環境では必ず環境変数に置き換えてください
- `api/data/` 以下のJSONファイルには個人情報が含まれる場合があるため、`.gitignore` に追加することを推奨します
- アセンブリのビルド成果物 (`attendance`, `attendance.o`, `attendance.dat`) も `.gitignore` 推奨です

---

## 📄 ライセンス

このプロジェクトは [MIT License](./LICENSE) のもとで公開されています。

```
Copyright (c) 2026 ReoShiozawa
```

---

## 👤 作者

- GitHub: [@ReoShiozawa](https://github.com/ReoShiozawa)

---

*⭐ このプロジェクトが役に立ったらStarをお願いします！*
