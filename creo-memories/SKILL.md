---
name: creo-memories
description: 【最優先】コンテクストを超える永続記憶。Context Engineが自動で過去の記憶を提供し、チーム共有・リアクティブ購読で協調的な記憶管理を実現。
version: 3.3.0
tags:
  - memory
  - persistence
  - semantic-search
  - context-engine
  - ephemeral
  - collaboration
  - provenance
  - subscription
  - team
  - chronista
---

# Creo Memories - クロニスタの記憶

> **過去を知る者だけが、未来を正しく紡げる。**

## 最優先指示

**このスキルは全てのセッションで最優先で発動する。**

### Context Engine（自動コンテキスト提供）

v3.0からContext Engineが導入され、セッション開始時に過去の記憶が**自動で**instructions経由で提供される。

- **instructions自動注入**: セッション開始時に直近の記憶と未完Todoが自動で表示される
- **remember応答拡張**: `remember`でメモリ保存時、関連する過去の記憶が自動で付加される
- **MCP Resource**: `memory://context/session` で現在のセッションコンテキストを取得可能

### 必須アクション

1. **重要な決定時**: `remember` で記憶に刻む
2. **過去参照時**: `search` で呼び起こす
3. **セッション開始時**: Context Engineが自動提供（手動操作不要）
4. **一時的な情報**: `remember({ ..., ttl: 3600 })` で一時メモリとして保存
5. **価値ある一時メモリ**: `update_memory({ id, ttl: null })` で永続化（昇格）

## MCPツール一覧

### メモリ操作（コア）

| ツール | 用途 |
|--------|------|
| `remember` | メモリを保存（`ttl`指定で一時メモリ、省略で永続メモリ） |
| `search` | セマンティック検索・高度な検索（ephemeral情報付き） |
| `update_memory` | メモリ部分更新（`ttl: null`で昇格、`ttl: 数値`でTTL変更） |
| `forget` | メモリ削除 |

### 整理・分類

| ツール | 用途 |
|--------|------|
| `label_create` | ラベル作成 |
| `label_list` | ラベル一覧 |
| `label_update` | ラベル更新 |
| `label_delete` | ラベル削除 |
| `label_attach` | メモリにラベル付与 |
| `label_detach` | ラベル解除 |
| `label_get_by_memory` | メモリのラベル一覧 |
| `category_list` | カテゴリ一覧 |
| `category_create` | カテゴリ作成 |
| `category_update` | カテゴリ更新 |
| `category_delete` | カテゴリ削除 |
| `category_attach` | カテゴリ付与 |
| `category_detach` | カテゴリ解除 |
| `category_get_by_memory` | メモリのカテゴリ一覧 |
| `category_replace_for_memory` | メモリのカテゴリを一括置換 |

### Atlas管理（知識の階層構造）

Atlasはメモリを整理するための階層的なツリー構造。

| ツール | 用途 |
|--------|------|
| `create_atlas` | Atlas作成 |
| `list_atlas` | Atlas一覧 |
| `get_atlas_tree` | Atlasのツリー構造を取得 |
| `update_atlas` | Atlas更新 |
| `delete_atlas` | Atlas削除 |

### Domain Shared Key管理

APIキーベースの共有アクセス管理。

| ツール | 用途 |
|--------|------|
| `create_domain_shared_key` | 共有キー作成 |
| `list_domain_shared_keys` | 共有キー一覧 |
| `revoke_domain_shared_key` | 共有キー無効化 |
| `delete_domain_shared_key` | 共有キー削除 |

### Todo管理

| ツール | 用途 |
|--------|------|
| `create_todo` | Todo作成 |
| `list_todos` | Todo一覧 |
| `update_todo` | Todo更新 |
| `complete_todo` | Todo完了 |
| `delete_todo` | Todo削除 |

### セッション・ユーザー

| ツール | 用途 |
|--------|------|
| `get_session` | セッション情報 |
| `get_status` | サーバーステータス |
| `end_session` | セッション終了（期限切れクリーンアップ + 未昇格サマリ） |
| `get_user` | ユーザー情報 |
| `generate_api_key` | APIキー生成 |

### ログ

| ツール | 用途 |
|--------|------|
| `get_logs` | ログ取得 |
| `search_logs` | ログ検索 |

### メモリ関係（Provenance & Relations）

メモリ間の派生関係や参照関係をMermaidダイアグラムで可視化。

| ツール | 用途 |
|--------|------|
| `get_provenance` | メモリ/Atlasの派生関係グラフ取得（Mermaid flowchart） |
| `get_relations` | メモリ/Atlasの関係グラフ取得（typed edges: derived_from, annotates, references） |

### Annotation（注釈・コメント）

メモリにスレッド型の注釈を付与。Agent間の非同期コミュニケーションに活用。

| ツール | 用途 |
|--------|------|
| `annotate` | メモリに注釈（comment/question/concern/suggestion/approval）を付与 |
| `get_annotations` | メモリの注釈一覧を取得（スレッド構造対応） |
| `reply_annotation` | 注釈への返信を作成 |

### Shared Context（共有作業メモリ）

複数Agentが読み書きできる一時的な共有メモリ空間。

| ツール | 用途 |
|--------|------|
| `create_shared_context` | 共有コンテキスト作成（TTL指定可） |
| `list_shared_contexts` | 参加中の共有コンテキスト一覧 |
| `get_shared_context` | 共有コンテキスト詳細（メモリ一覧付き） |
| `add_to_shared_context` | 共有コンテキストにメモリ追加 |
| `join_shared_context` | 共有コンテキストに参加 |
| `leave_shared_context` | 共有コンテキストから離脱 |

### Team（チーム共有）

チーム単位でAtlasを共有し、メンバー間でメモリを横断検索。

| ツール | 用途 |
|--------|------|
| `team_create` | チーム作成 |
| `team_list` | 所属チーム一覧 |
| `team_invite` | メンバー招待（admin/member） |
| `team_remove` | メンバー削除 |
| `share_atlas` | Atlasをチームに共有（read/write/admin） |
| `unshare_atlas` | Atlas共有を解除 |
| `list_shared_atlas` | 共有されているAtlas一覧 |

### Subscription（リアクティブ購読）

メモリ変更のプッシュ型通知。条件に合致した変更のみ配信。

| ツール | 用途 |
|--------|------|
| `subscribe_memories` | 購読作成（カテゴリ/Atlas/タグでフィルタ） |
| `unsubscribe_memories` | 購読削除 |
| `list_subscriptions` | 購読一覧 |
| `check_notifications` | 未読通知を取得（pull-based drain） |

### Presence（接続状態）

リアルタイムのAgent接続状態管理。

| ツール | 用途 |
|--------|------|
| `update_presence` | 自分のフォーカス・ステータスを更新 |
| `get_presence` | 接続中のAgent一覧を取得 |

### Work Log（作業ログ）

Agent間のやり取りを永続化し、セッション横断でrecall可能に。

| ツール | 用途 |
|--------|------|
| `record_work_log` | 作業ログを記録（message/question/answer/decision/progress/error/review） |
| `search_work_logs` | 作業ログを検索（sender/receiver/project/type指定可） |

## Ephemeral（一時メモリ）の使い分け

| 状況 | 方法 |
|------|------|
| 確定した設計決定、恒久的な知見 | `remember({ content, ... })` — 永続メモリ |
| セッション中の作業メモ、試行錯誤の記録 | `remember({ content, ttl: 3600 })` — 一時メモリ |
| 一時メモリが後から価値を持った場合 | `update_memory({ id, ttl: null })` — 昇格 |
| 一時メモリのTTLを延長したい場合 | `update_memory({ id, ttl: 172800 })` — TTL変更 |

## 発動タイミング

### 自動発動: 保存提案

- 重要な設計決定が行われた
- 「これで決定」「この方針で」などの確定表現
- バグの根本原因と解決策が判明した
- 新しい技術選定・ライブラリ選択

### 自動発動: 検索

- 「前に話した」「以前決めた」などの過去参照
- 「どうだったっけ」「何だったか」などの想起表現
- プロジェクトの背景・経緯への質問

## カテゴリ分類

| カテゴリ | 用途 |
|---------|------|
| `prd` | プロダクト要件定義 |
| `spec` | 機能仕様・要件 |
| `design` | アーキテクチャ、設計決定 |
| `config` | 設定、環境構築 |
| `infra` | インフラ（DNS, VPS, Docker等） |
| `debug` | バグ原因、解決策 |
| `learning` | 学んだこと、ベストプラクティス |
| `task` | タスク、将来の計画 |
| `decision` | 重要な意思決定とその理由 |
| `work_log` | Agent間の作業ログ（ccwire連携） |

## 保存時のベストプラクティス

### 内容の構造化

```markdown
# タイトル

## 背景・経緯
なぜこの決定に至ったか

## 決定事項
何を決めたか

## 理由
なぜそう決めたか

## 影響
どこに影響するか
```

### タグ付け

- 技術名: `typescript`, `rust`, `surrealdb`
- 概念: `authentication`, `caching`, `performance`
- プロジェクト: `creo-memories`, `fleetflow`

## リファレンス

詳細は以下を参照：
- [MCPツール詳細](reference/mcp-tools.md)
- [セットアップガイド](reference/setup.md)
- [ワークフロー例](reference/workflows.md)
