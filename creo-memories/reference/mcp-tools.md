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

## Ephemeral Context Layer（一時メモリ）

TTL（有効期限）付きの一時メモリ機能です。「保存するか消えるか」の二択を解消し、セッション中は一時的に保持して、価値があると判断したものだけ永続化（昇格）できます。

### コンセプト

- **一時メモリ**: `remember` 時に `ttl` を指定すると、期限付きのメモリとして保存される
- **永続メモリ**: `ttl` 未指定で従来通りの永続メモリ
- **昇格（Promote）**: `update_memory({ id, ttl: null })` で一時メモリを永続化
- **自動削除**: 期限切れの一時メモリはセッション終了時に自動クリーンアップ

### Decorator Pattern

Memory本体のデータモデルは変更なし。外部の `ephemeral` テーブルの存在で一時性を表現するDecorator Patternを採用しています。

### 検索時の挙動

- 期限切れの一時メモリは検索結果から自動除外
- 有効な一時メモリには `Ephemeral: TTL X時間, 残り Y分` のように残り時間が表示

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
  atlasId: "atlas:...",         // オプション
  ttl: 3600                     // オプション（秒、60〜2592000）
})
```

**TTL（一時メモリ）**:
- `ttl` 指定時: 一時メモリとして保存。期限切れ後は自動削除
- `ttl` 未指定: 従来通り永続メモリとして保存
- 範囲: 60秒（1分）〜 2592000秒（30日）
- 例: `3600`（1時間）, `86400`（24時間）, `604800`（7日）

**レスポンス（TTL指定時）**:
```
ephemeral: { ttl: 3600, expiresAt: "2026-02-22T13:00:00.000Z" }
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

**Ephemeral（一時メモリ）の表示**:
- 期限切れの一時メモリは検索結果から自動的に除外されます
- 有効な一時メモリの結果には以下の情報が付加されます:
```
Ephemeral: TTL 1時間, 残り 45分
```

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
  metadata: { key: "value" },   // オプション（既存にマージ）
  ttl: null                     // オプション（null | number）
})
```

**ポイント**:
- `content`が変更された場合のみ、embeddingが自動再生成される
- `forget` → `remember` での再作成が不要（IDが保持される）
- 指定しなかったフィールドは現在の値が維持される

**TTL管理**:
- `ttl: null` → 一時メモリを**永続化（昇格）**する。`promoted: true` がレスポンスに含まれる
- `ttl: 数値` → TTLを変更/設定。既存の永続メモリに対してもTTLを後付け可能
- `ttl` 省略 → TTLに変更なし

```typescript
// 昇格（一時 → 永続）
update_memory({ id: "019c72e6-...", ttl: null })
// → "メモリを永続化（昇格）しました"

// TTL延長
update_memory({ id: "019c72e6-...", ttl: 172800 })
// → "メモリのTTLを更新しました（172800秒）"
```

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

セッションを終了します。終了時に以下を自動実行します:

1. **期限切れクリーンアップ**: 期限切れの一時メモリを自動削除
2. **未昇格サマリ**: まだ有効な一時メモリの一覧を表示（昇格の判断材料として）

```typescript
mcp__creo-memories__end_session({
  sessionId: "session:..."      // 必須
})
```

**レスポンス例（一時メモリがある場合）**:
```
✅ セッションを終了しました
cleanedUpExpired: "2件の期限切れメモリを削除"

未昇格の一時メモリが 3 件あります:
1. ID: 019c72e6-... (残り 2時間)
2. ID: 019c72e7-... (残り 5日)
3. ID: 019c72e8-... (残り 30分)

永続化したいものがあれば update_memory({ id, ttl: null }) で昇格できます。
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

## メモリ関係ツール（Provenance & Relations）

メモリ間の派生関係・参照関係をMermaidダイアグラムで可視化します。

### get_provenance

メモリまたはAtlasの派生関係グラフをMermaid flowchartで取得します。

```typescript
mcp__creo-memories__get_provenance({
  memoryId: "memories:...",       // オプション（memoryIdかatlasIdのどちらか必須）
  atlasId: "atlas:...",           // オプション
  depth: 3                        // オプション（探索深度、デフォルト3）
})
```

**レスポンス**: Mermaid flowchart形式の派生関係図

### get_relations

メモリまたはAtlasの関係グラフをMermaid形式で取得します。typed edgesで関係の種類を区別。

```typescript
mcp__creo-memories__get_relations({
  memoryId: "memories:...",       // オプション（memoryIdかatlasIdのどちらか必須）
  atlasId: "atlas:...",           // オプション
  depth: 3,                       // オプション（探索深度、デフォルト3）
  types: ["derived_from", "annotates"]  // オプション（フィルタ）
})
```

**関係タイプ**:
- `derived_from`: 派生関係
- `annotates`: 注釈関係
- `references`: 参照関係

---

## Annotationツール（注釈・コメント）

メモリにスレッド型の注釈を付与します。Agent間の非同期コミュニケーションに活用。

### annotate

メモリに注釈を付与します。注釈はメモリとして保存され、RELATIONでリンクされます。

```typescript
mcp__creo-memories__annotate({
  targetMemoryId: "memories:...", // 必須
  content: "注釈の内容",          // 必須
  annotationType: "comment",     // オプション（デフォルト: comment）
  contentType: "markdown"        // オプション（text/markdown）
})
```

**注釈タイプ**:
- `comment`: コメント（デフォルト）
- `question`: 質問
- `concern`: 懸念事項
- `suggestion`: 提案
- `approval`: 承認

### get_annotations

メモリの注釈一覧を取得します。スレッド構造対応。

```typescript
mcp__creo-memories__get_annotations({
  memoryId: "memories:...",       // 必須
  annotationType: "question",    // オプション（タイプでフィルタ）
  includeReplies: true           // オプション（デフォルト: true）
})
```

### reply_annotation

既存の注釈に返信を作成します。スレッドチェーンを形成。

```typescript
mcp__creo-memories__reply_annotation({
  annotationMemoryId: "memories:...",  // 必須（返信先の注釈メモリID）
  content: "返信内容",                  // 必須
  annotationType: "answer"             // オプション
})
```

---

## Shared Contextツール（共有作業メモリ）

複数Agentが読み書きできる一時的な共有メモリ空間です。

### create_shared_context

共有コンテキストを作成します。作成者はownerとして自動参加。

```typescript
mcp__creo-memories__create_shared_context({
  name: "設計レビュー #129",     // 必須
  description: "Collab機能の設計議論", // オプション
  ttlSeconds: 86400              // オプション（秒、デフォルト: なし）
})
```

### list_shared_contexts

参加中の共有コンテキスト一覧を取得します。

```typescript
mcp__creo-memories__list_shared_contexts()
```

### get_shared_context

共有コンテキストの詳細をメモリ一覧付きで取得します。

```typescript
mcp__creo-memories__get_shared_context({
  contextId: "shared_contexts:..."  // 必須
})
```

### add_to_shared_context

共有コンテキストにメモリを追加します。

```typescript
mcp__creo-memories__add_to_shared_context({
  contextId: "shared_contexts:...", // 必須
  memoryId: "memories:..."          // 必須
})
```

### join_shared_context

共有コンテキストに参加します。

```typescript
mcp__creo-memories__join_shared_context({
  contextId: "shared_contexts:..."  // 必須
})
```

### leave_shared_context

共有コンテキストから離脱します。

```typescript
mcp__creo-memories__leave_shared_context({
  contextId: "shared_contexts:..."  // 必須
})
```

---

## Teamツール（チーム共有）

チーム単位でAtlasノードを共有し、メンバー全員がそのAtlas配下のメモリを横断検索できます。

### team_create

チームを作成します。

```typescript
mcp__creo-memories__team_create({
  name: "creo-dev",               // 必須
  ownerId: "users:...",           // 必須（オーナーのユーザーID）
  description: "Creo開発チーム"    // オプション
})
```

### team_list

自分が所属するチーム一覧を取得します。

```typescript
mcp__creo-memories__team_list({
  userId: "users:..."              // オプション
})
```

### team_invite

チームにメンバーを招待します。

```typescript
mcp__creo-memories__team_invite({
  teamId: "teams:...",             // 必須
  userId: "users:...",             // 必須
  role: "member"                   // オプション（admin/member、デフォルト: member）
})
```

### team_remove

チームからメンバーを削除します。

```typescript
mcp__creo-memories__team_remove({
  teamId: "teams:...",             // 必須
  userId: "users:..."              // 必須
})
```

### share_atlas

Atlasノードをチームに共有します。共有すると、チームメンバーがそのAtlas配下のメモリをsearch可能になります。

```typescript
mcp__creo-memories__share_atlas({
  atlasId: "atlas:...",            // 必須
  teamId: "teams:...",             // 必須
  permission: "read",              // オプション（read/write/admin、デフォルト: read）
  inheritChildren: true,           // オプション（子孫ノードも共有、デフォルト: true）
  sharedBy: "users:..."            // オプション（共有したユーザーID）
})
```

### unshare_atlas

Atlasノードのチーム共有を解除します。

```typescript
mcp__creo-memories__unshare_atlas({
  atlasId: "atlas:...",            // 必須
  teamId: "teams:..."              // 必須
})
```

### list_shared_atlas

自分に共有されているAtlas一覧を取得します。

```typescript
mcp__creo-memories__list_shared_atlas({
  userId: "users:..."              // オプション
})
```

**レスポンス**:
```json
{
  "atlas": [
    {
      "atlasId": "atlas:...",
      "permission": "read",
      "source": "team",
      "teamId": "teams:...",
      "teamName": "creo-dev"
    }
  ]
}
```

---

## Subscriptionツール（リアクティブ購読）

メモリ変更のプッシュ型購読。条件に合致したメモリ変更がプッシュ通知されます。フィルタ条件はAND条件（tagsのみOR）。

### subscribe_memories

メモリ変更の購読を作成します。

```typescript
mcp__creo-memories__subscribe_memories({
  name: "設計変更の監視",           // オプション（識別用）
  filter: {                        // オプション（AND条件）
    category: "design",            //   カテゴリフィルタ
    atlasId: "atlas:...",          //   Atlas IDフィルタ
    tags: ["architecture"]         //   タグフィルタ（OR条件）
  },
  events: [                        // オプション
    "memory:created",
    "memory:updated",
    "memory:deleted"
  ],
  channel: "mcp"                   // オプション（websocket/mcp、デフォルト: mcp）
})
```

**チャネル**:
- `mcp`: pull-based。`check_notifications`で取得（デフォルト）
- `websocket`: 即時配信（WebSocket接続時）

### unsubscribe_memories

購読を削除します。

```typescript
mcp__creo-memories__unsubscribe_memories({
  subscriptionId: "subscriptions:..."  // 必須
})
```

### list_subscriptions

自分の購読一覧を取得します。

```typescript
mcp__creo-memories__list_subscriptions()
```

### check_notifications

未読のメモリ通知を取得します（drain方式: 取得した通知はバッファから削除）。

```typescript
mcp__creo-memories__check_notifications({
  limit: 50                        // オプション（デフォルト: 50）
})
```

---

## Presenceツール（接続状態）

リアルタイムのAgent接続状態を管理します。WebSocket経由で自動broadcast。

### update_presence

自分のフォーカスやステータスを更新します。

```typescript
mcp__creo-memories__update_presence({
  currentFocus: {                  // オプション
    type: "memory",                // 必須（memory/atlas/search/idle）
    targetId: "memories:...",      // オプション
    description: "設計レビュー中"   // オプション
  },
  status: "active",                // オプション（active/idle/busy）
  displayName: "creo-lead"         // オプション
})
```

### get_presence

接続中のAgent一覧を取得します。

```typescript
mcp__creo-memories__get_presence({
  userId: "users:..."              // オプション（指定時はそのユーザーの接続のみ）
})
```

---

## Work Logツール（作業ログ）

Agent間のやり取りを永続化し、セッション横断でrecall可能にします。

### record_work_log

作業ログを記録します。内部的にmemoryとして保存（category: work_log）。

```typescript
mcp__creo-memories__record_work_log({
  content: "DB設計について質問",    // 必須
  workLogType: "question",         // 必須
  sender: "creo-w1",               // 必須
  receiver: "creo-lead",           // オプション
  threadId: "thread-123",          // オプション
  project: "creo-memories",        // オプション
  issueRef: "#129",                // オプション
  sharedContextId: "shared_contexts:...",  // オプション
  contentType: "markdown"          // オプション
})
```

**workLogType**:
- `message`: 一般的なメッセージ
- `question`: 質問
- `answer`: 回答
- `decision`: 決定事項
- `progress`: 進捗報告
- `error`: エラー報告
- `review`: レビュー

### search_work_logs

作業ログを検索します。メタデータフィルタ対応。

```typescript
mcp__creo-memories__search_work_logs({
  query: "DB設計",                 // オプション（セマンティック検索）
  sender: "creo-w1",               // オプション
  receiver: "creo-lead",           // オプション
  project: "creo-memories",        // オプション
  workLogType: "question",         // オプション
  threadId: "thread-123",          // オプション
  limit: 20                        // オプション
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
| `work_log` | 作業ログ | Agent間通信、進捗、Q&A |
