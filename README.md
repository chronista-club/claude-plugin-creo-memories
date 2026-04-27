# Creo Memories Plugin

Persistent memory system for Claude Code. Remember context, decisions, and learnings across sessions with semantic search, automatic context delivery, and a 4-scene mental model.

## What's New in v0.26

- **Plugin tool invocation instrumentation** — `PostToolUse` hook が `mcp__*creo-memories__*` 呼び出しを log:
  - 出力先: `~/.claude/creo-memories-invocation.log`
  - dogfood で観測: 「自分が plugin tool 何回呼んだか」 を biweekly loop で trend 化可能
- **Daily loop wrapper script** — `scripts/daily-loop.sh` で Layer 1 memory health + invocation stats を 1 command で集約
- **Invocation stats utility** — `scripts/invocation-stats.sh today|week|month|--since` で期間 filter + tool ranking (Markdown 表)
- **jaq drop-in note** — `jq` の Rust 製代替 [`jaq`](https://github.com/01mf02/jaq) は hook 高頻度実行で起動 5-10x 速い、 syntax 互換、 `brew install jaq` で導入可

## What's New in v0.25

- **Self-Improvement Loop** — ecosystem (plugin / 本体 / docs / external / skill 自身) を周期的 audit する仕組み
  - 4 cadence: daily (5 min) / weekly (20 min) / **biweekly (75 min, primary)** / quarterly (3 h)
  - 設計原則 (8 axiom): hierarchical / Loop Dashboard pattern / ICE prioritization / incident-triggered ad-hoc / meta-loop / convergence / counterfactual / action chain closure
  - Slash command `/creo-memories:improvement-loop [cadence]` (manual)
  - SessionStart hook reminder (passive nudge)
  - Cron-schedulable (autonomous via `/loop` skill)
  - 詳細: [creo-memories/reference/improvement-loop/](creo-memories/reference/improvement-loop/README.md)

## What's New in v0.24

- **Active hooks** — passive echo hook → 真に動作する nudge hook へ:
  - `PreToolUse(Write)` で `*/memory/*.md` 検出時に Layer 判定 prompt
  - `UserPromptSubmit` で decision keyword (決定 / confirmed / done / merged 等) 検出 → remember 提案
  - `Stop` で session 終了前 checklist (remember / record_work_log / ttl 昇格 / complete_with_context)
- **Memory templates** — 7 scaffold (Layer 1: feedback / reference-card / project-canon、 Layer 2: decision-record / bug-fix / phase-completion / work-log)

## What's New in v0.23

- **2-layer architecture** — Local file canon (Layer 1) + Cloud trace-archive (Layer 2) の役割分担を明示
- **4-scene mental model** — `/memories /atlas /views /actions` の 4 scene で operation を整理
- **Decision tree** at skill top — どこに何を書くかが 1 query で決まる
- **Trigger patterns + Anti-patterns** で活用駆動
- **5 cookbooks** (Phase 完了 / Bug fix / Decision Record / Cycle close / Onboarding)
- **API Redesign Proposal** — 70 tool → 11 tool 将来構想 doc 化

## 2-Layer Architecture (重要)

Creo Memories は **2 layer 並立**:

| Layer | 場所 | 役割 |
|---|---|---|
| **Layer 1 — Local Canon** | `~/.claude/projects/<project>/memory/*.md` (markdown file) | **不変方針 / cross-project rule / reference card**。 緩慢に変化、 solo-authored、 MEMORY.md index で管理 |
| **Layer 2 — Cloud Trace** | `mcp.creo-memories.in` (`mcp__creo-memories__*` tools) | **動的 project state / 出来事 trace / multi-agent collaboration**。 速く変化、 共有、 semantic search、 Atlas / Concept で structure |

### どちらに書くか?

```
Q1: 「自分 / プロジェクトが常に従う方針」か?
  Yes → Layer 1 (local file)
  No → Q2

Q2: 「ある時点で起こった事実 / 決定 / 現状」か?
  Yes → Layer 2 (cloud)
  No → 書かなくて OK

Q3 (補助): multi-agent / multi-session で参照?
  Yes → Layer 2 (cloud)
  Solo → Layer 1
```

**迷ったら Layer 2**。 Layer 1 は厳しめに gate (MEMORY.md は session start で auto-load → noise 厳禁)。

詳細: [creo-memories/reference/decision-tree.md](creo-memories/reference/decision-tree.md)

## 4-Scene Mental Model

Layer 2 (cloud) の operation は 4 scene で組織化:

```
┌─────────────────┬──────────────────┐
│ /memories       │ /atlas           │
│ data layer      │ structure layer  │
│ (memory CRUD)   │ (整理 / 共有)    │
├─────────────────┼──────────────────┤
│ /views          │ /actions         │
│ perspective     │ motion layer     │
│ (compass/story) │ (todo/link/log)  │
└─────────────────┴──────────────────┘
```

各 scene の playbook:
- [/memories](creo-memories/reference/scenes/memories.md) — data
- [/atlas](creo-memories/reference/scenes/atlas.md) — structure
- [/views](creo-memories/reference/scenes/views.md) — perspective
- [/actions](creo-memories/reference/scenes/actions.md) — motion

## Quick Start Cookbook

### A. 設計決定を保存

```
remember({
  content: '# {決定内容}\n## 理由\n...',
  category: 'decision',
  status: 'done',
  conceptIds: ['{tag}'],
  atlasId: '{project}'
})
```

→ Pre-save Detection で類似 memory 提案。 supersede 必要なら同 call の `supersedes:[mem_old]`。

### B. PR / Linear と pair (mandate)

```
remember({ content, category:'task', status:'in-progress', atlasId })
+ link_external({ memoryId, externalSystem:'linear', externalId:'CREO-XXX' })
+ link_external({ memoryId, externalSystem:'github', externalId:'PR-XXX' })
完了時: complete_with_context({ memoryId, resultSummary, externalUrl })
```

### C. agent 間 comm を残す

```
record_work_log({
  type: 'decision' | 'message' | 'question' | 'progress' | 'review',
  sender, receiver, content, projectId
})
```

### D. Cycle close

```
get_profile() / project_progress(atlasId)
generate_compass(atlasId) → snapshot を remember
detect_processes() → create_process で chain narrative 化
memory_health() → stale 整理
```

詳細: [Cookbook 一覧](creo-memories/SKILL.md#5-cookbook-具体的-recipe)

## Features

- **Context Engine v3.0** — session start で過去 memory + 未完 todo 自動提供
- **Semantic Search** — 意味検索 (Qdrant + embedding)
- **Atlas + Concept** — 階層 tree + 統合分類 (categories/labels/tags)
- **Process / Compass / Story** — chain narrative + LLM 自動 summary
- **Annotation** — thread 型 review (comment/question/concern/suggestion/approval)
- **Work Log** — agent 間 comm の persist
- **Subscription** — push 型変更通知
- **Team / Shared Context** — multi-user 共有
- **2-Layer + 4-Scene** — mental model で活用駆動 (v0.23 NEW)

## Installation

### From GitHub

```bash
/install chronista-club/claude-plugin-creo-memories
```

### Manual Setup

```bash
claude mcp add --transport http creo-memories https://mcp.creo-memories.in
```

Or add to `.mcp.json`:

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

## MCP Tools (現状: ~70 tools)

各 scene 別 tool 一覧:

### `/memories` scene (data)
| Tool | Description |
|------|-------------|
| `remember` | Memory 保存 (Pre-save Detection 付き、 supersedes / extends / derives 指定可) |
| `search` | Semantic + structured search (scope / atlas / concept filter) |
| `update_memory` | 部分更新 (楽観的 lock 対応) |
| `forget` | 削除 |
| `annotate` / `get_annotations` / `reply_annotation` | Thread 型注釈 |
| `get_provenance` / `get_relations` | 関係 graph (Mermaid) |

### `/atlas` scene (structure)
| Tool | Description |
|------|-------------|
| `create_atlas` / `list_atlas` / `get_atlas_tree` / `update_atlas` / `delete_atlas` | Atlas 操作 |
| `invite_to_atlas` / `share_atlas` / `unshare_atlas` / `list_shared_atlas` | 招待 / 共有 |
| `concept_*` (8 tools) | Concept 統合分類 (categories/labels/tags) |
| `team_*` (4 tools) | Team 管理 |

### `/views` scene (perspective)
| Tool | Description |
|------|-------------|
| `generate_compass` | Atlas 全体の Concept 別 summary |
| `generate_story` | Atlas narrative 生成 |
| `create_process` / `get_process` / `detect_processes` | Memory chain を Process 化 |
| `memory_health` | Stale / broken-link / 偏り検出 |
| `get_profile` | 自分の活動 profile |
| `project_progress` | 進捗 report |
| `system_health` / `diagnose` / `search_logs` | 健全性 / log |

### `/actions` scene (motion)
| Tool | Description |
|------|-------------|
| `create_todo` / `list_todos` / `update_todo` / `complete_todo` / `delete_todo` | Todo |
| `link_external` / `complete_with_context` / `find_by_external` | External (Linear/GitHub) |
| `subscribe_memories` / `unsubscribe_memories` / `list_subscriptions` / `check_notifications` | Push 通知 |
| `record_work_log` / `search_work_logs` | Agent comm trace |
| `update_presence` / `get_presence` | Presence |
| `create_shared_context` / `list_shared_contexts` / `get_shared_context` / `add_to_shared_context` / `join_shared_context` / `leave_shared_context` | Shared context |
| `end_session` | Session 終了 |

詳細: [creo-memories/reference/mcp-tools.md](creo-memories/reference/mcp-tools.md)

### Future API (v0.24+ 予定)

70 tool → 6 core verbs + 5 named conveniences = **11 tools** へリデザイン提案中:

```
Core: read / write / remove / query / transform / subscribe
Named: remember / recall / annotate / complete_with_context / record_work_log / end_session
```

詳細: [creo-memories/reference/api-redesign.md](creo-memories/reference/api-redesign.md)

## Setup / Authentication

1. Plugin install (`/install chronista-club/claude-plugin-creo-memories`)
2. 初回利用時 OAuth (Auth0) prompt — Google / GitHub login
3. 以後 auto

API Key (programmatic):
- `generate_api_key` で発行
- `Authorization: Bearer <key>` header で使用

## Requirements

- Claude Code
- Creo Memories account (free tier)

## Links

| | URL |
|---|-----|
| MCP Endpoint | `https://mcp.creo-memories.in` |
| Web Viewer | `https://creo-memories.in` |
| GitHub | `https://github.com/chronista-club/claude-plugin-creo-memories` |

## License

MIT
