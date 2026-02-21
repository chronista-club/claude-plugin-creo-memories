# Creo Memories MCPツール リファレンス

## 概要

Creo MemoriesはMCP（Model Context Protocol）経由でClaude Codeと連携します。

**MCPサーバー名**: `creo-memories`
**エンドポイント**: `https://mcp.creo-memories.in`

---

## Context Engine（v3.0新機能）

Context Engineはセッション開始時に自動でコンテキストを提供する仕組みです。

### instructions自動注入

セッション開始時、以下が自動でinstructionsに含まれます：
- 直近2件の記憶
- 未完了Todo（最大2件）

### remember応答拡張

`remember`でメモリ保存した際、contentに関連する過去の記憶が自動で応答に付加されます（最大3件、類似度0.6以上）。

### MCP Resource

```
memory://context/session
```

現在のセッションコンテキストをJSON形式で取得できます。

---

## メモリ操作ツール

### remember

メモリを保存します。保存後、Context Engineが関連する過去の記憶を自動付加します。

```typescript
mcp__creo-memories__remember({
  content: "保存する内容",      // 必須
  category: "design",           // オプション
  tags: ["tag1", "tag2"],       // オプション
  labelIds: ["label:..."],      // オプション（ラベルID配列）
  metadata: { key: "value" },   // オプション
  contentType: "markdown",      // オプション（text/markdown）
  atlasId: "atlas:..."          // オプション
})
```

---

### search

セマンティック検索と構造化フィルタでメモリを検索します。

```typescript
mcp__creo-memories__search({
  query: "検索クエリ",          // オプション（セマンティック検索）
  category: "design",           // オプション
  tags: ["tag1"],               // オプション
  fromDate: "2025-01-01T...",   // オプション（ISO 8601）
  toDate: "2025-12-31T...",     // オプション
  searchType: "hybrid",         // オプション（semantic/hybrid）
  limit: 10,                    // オプション
  threshold: 0.7                // オプション
})
```

**閾値ガイド**:
- `0.9+`: 非常に関連性が高い
- `0.7-0.9`: 関連性が高い（推奨）
- `0.5-0.7`: ある程度関連

---

### update_memory

既存のメモリを部分更新します。IDと作成日時は保持されます。

```typescript
mcp__creo-memories__update_memory({
  id: "メモリID",               // 必須
  content: "更新後の内容",       // オプション（変更時embedding再生成）
  contentType: "markdown",      // オプション
  category: "learning",         // オプション
  tags: ["new-tag"],            // オプション（既存を置換）
  metadata: { key: "value" }    // オプション（既存にマージ）
})
```

**ポイント**:
- `content`が変更された場合のみ、embeddingが自動再生成される
- `forget` → `remember` での再作成が不要（IDが保持される）
- 指定しなかったフィールドは現在の値が維持される

---

### forget

メモリを削除します。

```typescript
mcp__creo-memories__forget({
  id: "メモリID",               // 必須
  confirm: true                 // 必須（安全確認）
})
```

**注意**: 削除は取り消せません。`confirm: true` が必須です。

---

## ラベル管理ツール

### label_create

ラベルを作成します。

```typescript
mcp__creo-memories__label_create({
  name: "重要",                 // 必須
  color: "#FF0000"              // オプション（HEXカラー）
})
```

### label_list

ラベル一覧を取得します。

```typescript
mcp__creo-memories__label_list()
```

### label_update

ラベルを更新します。

```typescript
mcp__creo-memories__label_update({
  id: "label:...",              // 必須
  name: "新しい名前",           // オプション
  color: "#00FF00"              // オプション
})
```

### label_delete

ラベルを削除します。

```typescript
mcp__creo-memories__label_delete({
  id: "label:..."               // 必須
})
```

### label_attach

メモリにラベルを付与します。

```typescript
mcp__creo-memories__label_attach({
  memory_id: "memory:...",      // 必須
  label_id: "label:..."         // 必須
})
```

### label_detach

メモリからラベルを解除します。

```typescript
mcp__creo-memories__label_detach({
  memory_id: "memory:...",      // 必須
  label_id: "label:..."         // 必須
})
```

### label_get_by_memory

メモリに付与されたラベル一覧を取得します。

```typescript
mcp__creo-memories__label_get_by_memory({
  memory_id: "memory:..."       // 必須
})
```

---

## カテゴリ管理ツール

### category_list

カテゴリ一覧を取得します。

```typescript
mcp__creo-memories__category_list()
```

### category_create

カテゴリを作成します。

```typescript
mcp__creo-memories__category_create({
  name: "カテゴリ名",           // 必須
  description: "説明"           // オプション
})
```

### category_update

カテゴリを更新します。

```typescript
mcp__creo-memories__category_update({
  id: "category:...",           // 必須
  name: "新しい名前",           // オプション
  description: "新しい説明"     // オプション
})
```

### category_delete

カテゴリを削除します。

```typescript
mcp__creo-memories__category_delete({
  id: "category:..."            // 必須
})
```

### category_attach

メモリにカテゴリを付与します。

```typescript
mcp__creo-memories__category_attach({
  memory_id: "memory:...",      // 必須
  category_id: "category:..."   // 必須
})
```

### category_detach

メモリからカテゴリを解除します。

```typescript
mcp__creo-memories__category_detach({
  memory_id: "memory:...",      // 必須
  category_id: "category:..."   // 必須
})
```

### category_get_by_memory

メモリに付与されたカテゴリ一覧を取得します。

```typescript
mcp__creo-memories__category_get_by_memory({
  memory_id: "memory:..."       // 必須
})
```

### category_replace_for_memory

メモリのカテゴリを一括置換します。

```typescript
mcp__creo-memories__category_replace_for_memory({
  memory_id: "memory:...",      // 必須
  category_ids: ["category:...", "category:..."]  // 必須
})
```

---

## Atlas管理ツール

Atlasはメモリを整理するための階層的なツリー構造です。

### create_atlas

Atlasを作成します。

```typescript
mcp__creo-memories__create_atlas({
  name: "プロジェクトA",        // 必須
  description: "説明",          // オプション
  parent_id: "atlas:...",       // オプション（子Atlasの場合）
  metadata: {}                  // オプション
})
```

### list_atlas

Atlas一覧を取得します。

```typescript
mcp__creo-memories__list_atlas({
  parent_id: "atlas:..."        // オプション（特定の親の子を取得）
})
```

### get_atlas_tree

Atlasのツリー構造を取得します。

```typescript
mcp__creo-memories__get_atlas_tree({
  atlas_id: "atlas:..."         // 必須
})
```

### update_atlas

Atlasを更新します。

```typescript
mcp__creo-memories__update_atlas({
  id: "atlas:...",              // 必須
  name: "新しい名前",           // オプション
  description: "新しい説明"     // オプション
})
```

### delete_atlas

Atlasを削除します。

```typescript
mcp__creo-memories__delete_atlas({
  id: "atlas:..."               // 必須
})
```

---

## Domain Shared Key管理ツール

APIキーベースの共有アクセスを管理します。

### create_domain_shared_key

共有キーを作成します。

```typescript
mcp__creo-memories__create_domain_shared_key({
  name: "キー名",              // 必須
  atlas_id: "atlas:..."        // オプション
})
```

### list_domain_shared_keys

共有キー一覧を取得します。

```typescript
mcp__creo-memories__list_domain_shared_keys()
```

### revoke_domain_shared_key

共有キーを無効化します。

```typescript
mcp__creo-memories__revoke_domain_shared_key({
  id: "domain_shared_key:..."   // 必須
})
```

### delete_domain_shared_key

共有キーを削除します。

```typescript
mcp__creo-memories__delete_domain_shared_key({
  id: "domain_shared_key:..."   // 必須
})
```

---

## セッション管理ツール

### get_session

セッション情報を取得します。

```typescript
mcp__creo-memories__get_session({
  sessionId: "session:..."      // 必須
})
```

### get_status

サーバーステータスを取得します。

```typescript
mcp__creo-memories__get_status()
```

### end_session

セッションを終了します。

```typescript
mcp__creo-memories__end_session({
  sessionId: "session:..."      // 必須
})
```

---

## ユーザー管理ツール

### get_user

認証済みユーザーの情報を取得します。

```typescript
mcp__creo-memories__get_user()
```

### generate_api_key

APIキーを生成します（一度だけ表示）。

```typescript
mcp__creo-memories__generate_api_key()
```

---

## ログツール

### get_logs

ログを取得します。

```typescript
mcp__creo-memories__get_logs({
  limit: 50,                    // オプション
  level: "info"                 // オプション
})
```

### search_logs

ログを検索します。

```typescript
mcp__creo-memories__search_logs({
  query: "検索クエリ",          // 必須
  limit: 50                     // オプション
})
```

---

## Todo管理ツール

### create_todo

Todoを作成します。

```typescript
mcp__creo-memories__create_todo({
  content: "タスク内容",        // 必須
  priority: "high",             // オプション（low/medium/high）
  dueDate: "2025-12-31T...",    // オプション
  tags: ["work"]                // オプション
})
```

### list_todos

Todo一覧を取得します。

```typescript
mcp__creo-memories__list_todos({
  status: "pending",            // オプション（pending/in_progress/completed）
  priority: "high",             // オプション
  tags: ["work"],               // オプション
  limit: 20                     // オプション
})
```

### update_todo

Todoを更新します。

```typescript
mcp__creo-memories__update_todo({
  id: "todo:...",               // 必須
  content: "更新後の内容",       // オプション
  priority: "medium",           // オプション
  status: "in_progress"         // オプション
})
```

### complete_todo

Todoを完了としてマークします。

```typescript
mcp__creo-memories__complete_todo({
  id: "todo:..."                // 必須
})
```

### delete_todo

Todoを削除します。

```typescript
mcp__creo-memories__delete_todo({
  id: "todo:..."                // 必須
})
```

---

## カテゴリ一覧

| カテゴリ | 用途 | 例 |
|---------|------|-----|
| `prd` | プロダクト要件 | ビジネス要件、ゴール |
| `spec` | 仕様・要件 | 機能要件、制約 |
| `design` | 設計・アーキテクチャ | システム設計、API設計 |
| `config` | 設定・構成 | 環境変数、サービス設定 |
| `infra` | インフラ | サーバー、デプロイ、DNS |
| `debug` | デバッグ | バグ原因、解決策 |
| `learning` | 学習・知見 | ベストプラクティス、TIL |
| `task` | タスク・計画 | 将来の実装、改善案 |
| `decision` | 意思決定 | 重要な決定と理由 |
