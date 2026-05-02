# Creo Memories セットアップガイド

## 概要

Creo MemoriesはHTTP MCP経由でClaude Codeと接続します。OAuth認証により安全にアクセスできます。

## プラグインインストール（推奨）

```bash
/install chronista-club/claude-plugin-creo-memories
```

インストール後、`.mcp.json` が自動設定されます。

## 手動セットアップ

### 1. MCPサーバーを追加

Claude Codeで以下のコマンドを実行：

```bash
claude mcp add --transport http creo-memories https://mcp.creo-memories.in
```

または、`.mcp.json` に直接追加：

```json
{
  "mcpServers": {
    "creo-memories": {
      "type": "http",
      "url": "https://mcp.creo-memories.in"
    }
  }
}
```

### 2. OAuth認証

初回接続時に認証が必要です：

1. `/mcp` でcreo-memoriesを選択
2. `Authenticate` を選択
3. ブラウザでAuth0ログイン画面が開く
4. Google/GitHubアカウントでログイン
5. 認証完了後、Claude Codeに戻る

### 3. 接続確認

```typescript
// ユーザー情報を取得
mcp__creo-memories__get_user()

// メモリを検索
mcp__creo-memories__search({ query: "テスト", limit: 5 })
```

## 認証方式

### OAuth（推奨）

ブラウザ経由でAuth0認証。Claude Codeのデフォルト方式。

### APIキー

プログラマティックアクセス用：

```typescript
// APIキーを生成（一度だけ表示）
mcp__creo-memories__generate_api_key()
```

生成されたキーは安全に保管し、`Authorization: Bearer <key>` ヘッダーで使用。

## Atlas（知識の階層構造）

### 概念

- **Atlas**: メモリを整理するための階層的なツリー構造。プロジェクト、トピック、サブトピック等を表現。

### 初期設定

```typescript
// Atlas一覧を確認
mcp__creo-memories__list_atlas()

// 新しいAtlasを作成
mcp__creo-memories__create_atlas({
  name: "プロジェクトA",
  description: "プロジェクトAに関する記憶"
})
```

## Context Engine（v3.0新機能）

Context Engineにより、セッション開始時に過去の記憶が自動で提供されます：

- **instructions自動注入**: 直近の記憶と未完Todoが自動表示
- **remember応答拡張**: 保存時に関連記憶が自動付加
- **MCP Resource**: `memory://context/session` でコンテキスト取得

手動でのセッション開始操作は不要です。

## トラブルシューティング

### 認証エラー

```
Error: Authentication required
```

**対処**:
1. `/mcp` でcreo-memoriesを選択
2. `Authenticate` で再認証

### 接続エラー

```
Error: Connection refused
```

**対処**:
1. インターネット接続を確認
2. `https://mcp.creo-memories.in/health` にアクセスできるか確認
3. MCPサーバー設定を確認

## 本番環境情報

| 項目 | 値 |
|------|-----|
| MCPエンドポイント | `https://mcp.creo-memories.in` |
| Webビューアー | `https://creo-memories.in` |
| Auth0ドメイン | `creo-memories.jp.auth0.com` |
