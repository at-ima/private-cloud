# Home Server Docker Compose

クラウドサービスに頼らず、写真・ファイル・バックアップ・LLMをすべて自宅で完結させるDockerコンテナ構成。
プライバシーを守りながら、Google フォト・Dropbox・ChatGPT 相当の環境を月額ゼロで運用できる。
MacBook は自宅LANに繋ぐだけで Time Machine バックアップが自動で走り、何もしなくても常に最新の状態を保てる。

## サービス一覧

| サービス | ポート | 説明 |
| --- | --- | --- |
| Samba | 1139, 1445 | ファイル共有 |
| Time Machine | (host) | macOS バックアップ |
| Immich | 2283 | 写真・動画管理 |
| Nextcloud | 8080 | ファイルストレージ・ドキュメント管理 |
| Ollama + Open WebUI | 3000 | ローカルLLM |
| Netdata | 19999 | システム監視 |
| Pi-hole | 8888 (host) | DNS広告ブロック |

## ディレクトリ構成

```text
docker/
├── docker-compose.yml
└── nextcloud-custom/   # Nextcloud カスタムDockerfile
    ├── Dockerfile
    ├── upload-limit.ini
    └── hooks/
```

## セットアップ

### 1. 環境変数の設定

`.env` ファイルをプロジェクトルートに作成し、以下の変数を設定する。

```env
# Samba
SAMBA_USER=your_user
SAMBA_PASS=your_password

# Time Machine
TM_USER=your_user
TM_PASS=your_password

# Immich
IMMICH_DB_USER=immich
IMMICH_DB_PASS=your_password

# Nextcloud
NC_DB_ROOT_PASS=your_root_password
NC_DB_USER=nextcloud
NC_DB_PASS=your_password
NC_ADMIN_USER=admin
NC_ADMIN_PASS=your_password

# Pi-hole
PIHOLE_WEBPASSWORD=your_password

# サーバーIPアドレス
# メリット: IPが変わった場合にここだけ変更すれば全サービスに反映される。
#           複数環境（自宅/VPS など）でも .env を差し替えるだけで対応可能。
SERVER_IP=192.168.0.2
```

### 2. マウントポイントの準備

```bash
sudo mkdir -p /mnt/nas/share
sudo mkdir -p /mnt/nas/timemachine
sudo mkdir -p /mnt/nas/photos
sudo mkdir -p /mnt/nas/documents
```

### 3. 起動

```bash
docker compose up -d
```

### 4. 停止

```bash
docker compose down
```

## 各サービスの詳細

### Samba

**メリット:** WindowsやmacOS・Linuxから標準のファイル共有プロトコルでNASにアクセスできる。OSの標準機能で繋がるためクライアントに追加ソフト不要。

- ホストの `/mnt/nas/share` を共有
- ポートを 1139/1445 にオフセット（標準の 139/445 から変更）

### Time Machine

**メリット:** macOS 標準のバックアップ機能をNASに向けられる。Bonjour により自宅LANに繋ぐだけで MacBook が自動でバックアップを開始するため、操作不要で常に最新の状態を保てる。専用アプライアンス不要で差分バックアップが自動化される。

- ホストネットワーク使用（Bonjour/mDNS で自動検出）
- バックアップサイズ上限: 2TB

### Immich

**メリット:** Google フォトのような写真・動画管理をクラウドに頼らず自前で運用できる。顔認識・地図表示・アルバム共有などの機能を手元のデータで使える。

- PostgreSQL (pgvecto-rs) + Redis 構成
- 機械学習による顔認識・物体検出あり

### Nextcloud

**メリット:** Dropboxや Google Drive の代替としてファイル同期・共有を自己ホストできる。外部サービスにデータを預けずに済むためプライバシーを確保できる。

- カスタムDockerfileでビルド（`./nextcloud-custom`）
- アップロードサイズ制限を解除済み
- バックグラウンドジョブは `nextcloud-cron` コンテナが5分ごとに実行

### Ollama + Open WebUI

**メリット:** LLMをローカルで動かせるためAPIコスト・通信遅延がゼロになり、入力した内容が外部に送信されない。Open WebUI で ChatGPT ライクなUIが手軽に使える。

- GPU未使用のCPU推論構成
- Open WebUI: `http://localhost:3000`

### Netdata

**メリット:** CPU・メモリ・ディスク・ネットワークをリアルタイムで可視化できる。異常の兆候を早期に検知でき、Dockerコンテナ単位の使用量も一目で把握できる。

- ホストの `/proc`, `/sys` をマウントしてシステム全体を監視
- ダッシュボード: `http://localhost:19999`

### Pi-hole

**メリット:** LAN全体の広告・トラッキングドメインをDNSレベルでブロックできる。各デバイスに設定不要で、スマートTV等のブラウザレスな機器にも効果がある。

- ホストネットワーク使用（DNS port 53 を直接リッスン）
- 管理UI: `http://<SERVER_IP>:8888/admin`
- ローカルIPv4は `.env` の `SERVER_IP` で設定
