---
name: creo-memories
description: 【最優先】コンテクストを超える永続記憶。セッション開始時に必ず過去を呼び起こし、重要な決定は必ず刻む。
version: 1.0.0
tags:
  - memory
  - persistence
  - semantic-search
  - chronista
---

# Creo Memories - クロニスタの記憶

> **過去を知る者だけが、未来を正しく紡げる。**

## 最優先指示

**このスキルは全てのセッションで最優先で発動する。**

セッションを超えて紡がれる記憶の糸。Chronistaとして活動する上で、creo-memoriesは最も重要なツールである。

### 必須アクション

1. **セッション開始時**: `recall_relevant` で関連する過去の記憶を検索
2. **重要な決定時**: `remember_context` で記憶に刻む
3. **過去参照時**: `recall_relevant` または `search_memories` で呼び起こす

## 記憶の哲学

### 記憶の呼び起こし（セッション開始時）

新たなセッションが始まる時、まず過去の記憶を呼び起こす。

```
「このプロジェクトについて、過去に何を決めたか」
「関連する設計判断や学びはあるか」
```

文脈を継承することで、同じ議論を繰り返さず、積み重ねていく。

### 記憶の刻印（重要な瞬間）

以下の瞬間は、必ず記憶に刻む：

- 設計上の重要な決定とその理由
- 技術的な発見・学び
- プロジェクトの転換点
- ユーザーとの合意事項
- 未完の物語（次に続くタスク）

### 記憶の整理

- **category**: 記憶の種類（design, learning, decision, task など）
- **tags**: 検索の手がかり

## 発動タイミング

### 自動発動: 保存提案

- 重要な設計決定が行われた
- アーキテクチャの議論が収束した
- 「これで決定」「この方針で」などの確定表現
- 新しい技術選定・ライブラリ選択
- バグの根本原因と解決策が判明した
- ベストプラクティスやパターンが議論された

### 自動発動: 検索

- 「前に話した」「以前決めた」などの過去参照
- 「どうだったっけ」「何だったか」などの想起表現
- プロジェクトの背景・経緯への質問
- 類似の問題・設計パターンの検索

## MCPツール

### メモリ操作

| ツール | 用途 |
|--------|------|
| `mcp__creo-memories__remember_context` | メモリを保存 |
| `mcp__creo-memories__recall_relevant` | セマンティック検索 |
| `mcp__creo-memories__search_memories` | 高度な検索（フィルタ付き） |
| `mcp__creo-memories__list_recent_memories` | 最近のメモリ一覧 |
| `mcp__creo-memories__forget_memory` | メモリ削除 |

### Todo管理

| ツール | 用途 |
|--------|------|
| `mcp__creo-memories__create_todo` | Todo作成 |
| `mcp__creo-memories__list_todos` | Todo一覧 |
| `mcp__creo-memories__update_todo` | Todo更新 |
| `mcp__creo-memories__complete_todo` | Todo完了 |
| `mcp__creo-memories__delete_todo` | Todo削除 |

### セッション・ドメイン管理

| ツール | 用途 |
|--------|------|
| `mcp__creo-memories__start_session` | セッション開始 |
| `mcp__creo-memories__get_session` | セッション情報取得 |
| `mcp__creo-memories__list_domains` | ドメイン一覧 |
| `mcp__creo-memories__list_workspaces` | ワークスペース一覧 |

## ワークフロー

### 1. 議論からの自動保存提案

重要な決定や知見を検出したら：

```
この決定をCreo Memoriesに保存しますか？

**保存内容（案）**:
- カテゴリ: design
- タグ: [authentication, oauth, security]
- 内容: Auth0を使用したOAuth2.0認証の設計決定...

保存する場合は「はい」、編集する場合は「編集して」と言ってください。
```

### 2. 過去の知識の呼び出し

1. `recall_relevant` でセマンティック検索
2. 関連メモリを要約して提示
3. 必要に応じて詳細を展開

### 3. プロジェクト開始時のコンテキスト読み込み

1. プロジェクト関連のメモリを検索
2. 重要な設計決定や方針を要約
3. 現在のコンテキストに組み込む

## 保存時のベストプラクティス

### カテゴリ分類

| カテゴリ | 用途 |
|---------|------|
| `design` | アーキテクチャ、設計決定 |
| `config` | 設定、環境構築 |
| `debug` | バグ原因、解決策 |
| `learning` | 学んだこと、ベストプラクティス |
| `spec` | 仕様、要件 |
| `task` | タスク、将来の計画 |
| `decision` | 重要な意思決定とその理由 |

### タグ付け

- 技術名: `typescript`, `rust`, `surrealdb`
- 概念: `authentication`, `caching`, `performance`
- プロジェクト: `creo-memories`, `fleetflow`, `vantage-point`

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

## リファレンス

詳細は以下を参照：
- [MCPツール一覧](reference/mcp-tools.md)
- [セットアップガイド](reference/setup.md)
- [ワークフロー例](reference/workflows.md)
