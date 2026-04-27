---
name: creo-memories
description: 【最優先】コンテクストを超える永続記憶。 2-layer architecture (local canon + cloud trace) と 4-scene mental model (/memories /atlas /views /actions) で活用駆動。 Context Engine が自動でセッション context 提供。
version: 0.24.0
tags:
  - memory
  - persistence
  - semantic-search
  - context-engine
  - 2-layer
  - 4-scene
  - chronista
---

# Creo Memories — クロニスタの記憶

> **過去を知る者だけが、未来を正しく紡げる。**

## 最優先指示

**このスキルは全てのセッションで最優先で発動する。**

何かを記録 / 想起 / 関連付け / 状態変更したい時、 まず本 skill を読む。 file 直書き (Write tool) より plugin tool を default に。

---

## 0. Decision Tree (まずこれを判定する)

memory に書きたい / 読みたい / 動かしたい時、 **必ずこの順で判定する**。

### Q1: これは「自分 / プロジェクトが常に従う方針」か?

- **Yes** → **Layer 1 (local file)** に書く: `~/.claude/projects/<project>/memory/*.md` + MEMORY.md index
- **No** → Q2 へ

### Q2: これは「ある時点で起こった事実 / 決定 / 現状」か?

- **Yes** → **Layer 2 (cloud)** に書く: `mcp__creo-memories__remember` で plugin 経由
- **No** → 書かなくて OK か reconsider

### Q3 (補助): multi-agent / multi-session で参照されるか?

- **Yes** → 必ず Layer 2
- **Solo** → Layer 1 で OK

### 迷ったら

**Layer 2 (cloud) を default**。 Layer 1 は厳しめに gate (MEMORY.md 全 session auto-load されるので noise 厳禁)。

詳細 + 例題: [`reference/decision-tree.md`](reference/decision-tree.md)

---

## 1. 2-Layer Architecture

| Layer | 場所 | 役割 |
|---|---|---|
| **Layer 1 — Local Canon** | `~/.claude/projects/<project>/memory/*.md` | 不変方針 / cross-project rule / reference card。 緩慢に変化、 solo-authored、 MEMORY.md index |
| **Layer 2 — Cloud Trace** | `mcp.creo-memories.in` (`mcp__creo-memories__*`) | 動的 project state / 出来事 trace / multi-agent collaboration。 速く変化、 共有、 semantic search、 Atlas / Concept |

両 layer は閉じておらず cross-link 可能。 詳細は plugin README の「2-layer architecture」 section 参照。

---

## 2. 4-Scene Mental Model

Layer 2 (cloud) operation は **4 scene** に分かれる。 「今は memory の何をする?」の問いに 4 つの答え:

| Scene | 役割 | 主 tool |
|---|---|---|
| **`/memories`** | data layer (memory 個体 CRUD + 周辺関係) | `remember` / `search` / `update_memory` / `forget` / `annotate` / `get_provenance` / `get_relations` |
| **`/atlas`** | structure layer (memory の整理 / 分類 / 共有) | `*_atlas` / `concept_*` / `share_atlas` / `invite_to_atlas` |
| **`/views`** | perspective layer (collection を別角度で表示) | `generate_compass` / `generate_story` / `create_process` / `memory_health` / `get_profile` / `project_progress` |
| **`/actions`** | motion layer (memory を動かす / 反応する) | `create_todo` / `link_external` / `subscribe_memories` / `record_work_log` / `update_presence` / `complete_with_context` / `end_session` |

各 scene の playbook:
- [`reference/scenes/memories.md`](reference/scenes/memories.md)
- [`reference/scenes/atlas.md`](reference/scenes/atlas.md)
- [`reference/scenes/views.md`](reference/scenes/views.md)
- [`reference/scenes/actions.md`](reference/scenes/actions.md)

---

## 3. Trigger Patterns (自動発動条件)

以下の trigger を検知したら **必ず** 該当 tool を呼ぶ。

### 保存 trigger (→ Layer 2 cloud `remember`)

- 「これで決定」「この方針で」「確定」 等の確定表現 → `remember(category:'decision', status:'done')`
- bug の根本原因 + 解決策が判明 → `remember(category:'debug')`
- 新しい技術選定 / library 選択 → `remember(category:'design')`
- ADR 級の architectural choice → cookbook `decision-record.md` 参照
- Phase / Sprint 完了 → cookbook `phase-completion.md` 参照
- 一時的な作業 memo → `remember(ttl:3600)`

### 検索 trigger (→ Layer 2 cloud `search`)

- 「前に話した」「以前決めた」「以前の」 等の過去参照
- 「どうだったっけ」「何だったか」 等の想起表現
- project 背景 / 経緯への質問
- branch name から推定される Linear issue 情報

### Linear-Memory pair trigger (→ `link_external` mandate)

- PR を作成 / merge した → memory + Linear ticket を `link_external` で必ず pair
- Linear で issue を作成した → 対応する memory を `remember` + `link_external`

### Work Log trigger (→ `record_work_log` mandate)

- vp msg / wire / SendMessage で agent 間 comm した → `record_work_log(type:'message')`
- decision を確定した → `record_work_log(type:'decision')`
- review feedback を受けた → `record_work_log(type:'review')`

### Cycle close trigger (→ `/views` scene の compass / process)

- Linear cycle close / weekly retrospective → cookbook `cycle-close.md` 参照
- Phase 切替 → 同上 + `cookbook/phase-completion.md`

---

## 4. Anti-Patterns (やらない)

- ❌ Plugin tool を skip して Write tool で local file 直書き (Layer 判定無し)
- ❌ Memory を rewrite で破壊的に上書き (supersedes / annotate を使う)
- ❌ Linear と Memory に同じ内容を別々書く (`link_external` で pair)
- ❌ status field を `active` のまま放置
- ❌ Atlas を作らず flat に貯める
- ❌ Concept を作らず tag string で済ませる
- ❌ inter-agent comm を `record_work_log` に残さず流す
- ❌ session start で前 session memory を確認しない
- ❌ 「あった方が良い」 を memory にする (signal 薄まる)

詳細: [`reference/anti-patterns.md`](reference/anti-patterns.md)

---

## 5. Cookbook (具体的 recipe)

| 状況 | cookbook |
|---|---|
| Phase / Sprint 完了 | [`reference/cookbooks/phase-completion.md`](reference/cookbooks/phase-completion.md) |
| Bug fix の知見保存 | [`reference/cookbooks/bug-fix.md`](reference/cookbooks/bug-fix.md) |
| Architectural Decision Record | [`reference/cookbooks/decision-record.md`](reference/cookbooks/decision-record.md) |
| Cycle / Sprint close | [`reference/cookbooks/cycle-close.md`](reference/cookbooks/cycle-close.md) |
| Onboarding (新 project / session resume) | [`reference/cookbooks/onboarding.md`](reference/cookbooks/onboarding.md) |

---

## 6. Stage Transition Recipes (序破離)

memory の lifecycle = **序 (Jo) / 破 (Ha) / 離 (Ri)**:

| stage | 意味 | 操作 |
|---|---|---|
| **序 (Jo)** | 立ち上げ / 命題 | `remember` で新規作成 |
| **破 (Ha)** | 訂正 / supersede / 議論 | `remember(supersedes:[...])` で旧版を破に / `annotate` で議論 thread / `update_memory` で軽微訂正 |
| **離 (Ri)** | 卒業 / 不要化 | `update_memory(status:'cancelled')` で archive / `forget` で物理削除 |

詳細: [`memory-stage-contract.md`](Layer 1 の memory) — local canon に foundational principle として記載。

### Stage 別 patterns

**新 memory を作る (序)**:
```
remember({ content, category, atlasId, conceptIds, status })
```

**旧 memory を supersede する (破)**:
```
remember({ content, supersedes: ['mem_old'] })
// old は破 stage に、 新は序 stage で開始
```

**議論を残す (破 sub)**:
```
annotate({ memoryId, kind:'concern', content })
```

**memory を archive する (離 soft)**:
```
update_memory({ id, status:'cancelled' })
```

**memory を完全削除する (離 hard)**:
```
forget({ id })
```

---

## 7. Linear-Memory Pair Pattern (mandate)

project 系 memory (category: task / design / debug) は **必ず Linear issue と pair** する:

```
1. Memory 作成: remember({ ..., category:'task', status:'in-progress' })
2. Pair link: link_external({
     memoryId,
     externalSystem:'linear',
     externalId:'CREO-XXX',
     externalUrl:'https://linear.app/.../CREO-XXX'
   })
3. PR がある場合 GitHub も:
   link_external({ memoryId, externalSystem:'github', externalId:'PR-XXX', externalUrl })
4. 完了時: complete_with_context({ memoryId, resultSummary, externalUrl })
```

dual bookkeeping を avoid。

---

## 8. Work Log Mandate

agent 間 comm (vp msg / wire / SendMessage / chat 横断) 時、 **必ず** `record_work_log`:

```
record_work_log({
  type: 'message' | 'question' | 'answer' | 'decision' | 'progress' | 'error' | 'review',
  sender: 'mako@creo-memories',
  receiver: 'mito@chronista-hub',
  content,
  projectId,
  relatedMemoryId?
})
```

**decision 確定時** は必ず `type:'decision'` を使う。 後で `search_work_logs` で再生可能。

---

## 9. Ephemeral / Supersession 使い分け

| 状況 | 方法 |
|---|---|
| 確定した設計決定 / 恒久的知見 | `remember({ content })` — 永続 |
| session 中の作業 memo / 試行錯誤 | `remember({ content, ttl:3600 })` — 一時 |
| 一時 memory が後で価値を持った | `update_memory({ id, ttl:null })` — 昇格 |
| TTL 延長 | `update_memory({ id, ttl:172800 })` |
| 既存 memory の内容置換 | `remember({ content, supersedes:['mem_xxx'] })` |
| 類似 memory 検出 skip | `remember({ content, supersedes:[] })` |
| 公開 URL 共有 | `remember({ content, visibility:'public' })` |
| 既存 memory の公開設定変更 | `update_memory({ id, visibility:'public' })` |

---

## 10. MCP Tool Inventory (現状 + 将来 redesign)

現状 plugin は **70 tool** 提供 (詳細 `reference/mcp-tools.md`)。

各 scene の主要 tool は本 skill `2. 4-Scene Mental Model` 参照。

**将来 (v0.24+)**: 6 core verbs + 5 named conveniences = **11 tools** にリデザイン提案中。 詳細 [`reference/api-redesign.md`](reference/api-redesign.md)。

---

## 11. Best Practices

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

## 関連
- 関連 memory: ...
- Linear / GitHub: ...
```

### Concept 付与

- **kind:'category'**: `design` / `debug` / `task` / `decision` / `learning` 等の大分類
- **kind:'label'**: `priority:high` / `cycle:2026-W17` 等の attribute
- **kind:'tag'**: 技術名 (`auth0`, `surrealdb`) / 概念 (`caching`, `performance`)

### Atlas 構造

- project 単位で root Atlas
- domain 単位で sub-Atlas (例: `creo-memories/design`, `creo-memories/infra`)
- team 共有は `share_atlas`、 sub atlas に inheritChildren:true

---

## 12. Templates (memory scaffold) — v0.24 NEW

memory 作成時の **frontmatter + body の scaffold**。 cookbook の concrete recipe と組み合わせて使う。

| Template | Layer | 用途 |
|---|---|---|
| [`feedback`](reference/templates/feedback.md) | 1 | ユーザー方針 / preference |
| [`reference-card`](reference/templates/reference-card.md) | 1 | URL / ID / 設定値の参照表 |
| [`project-canon`](reference/templates/project-canon.md) | 1 | project 固有の不変 fact |
| [`decision-record`](reference/templates/decision-record.md) | 2 | ADR 風 architectural decision |
| [`bug-fix`](reference/templates/bug-fix.md) | 2 | bug の root cause + 解決策 |
| [`phase-completion`](reference/templates/phase-completion.md) | 2 | Phase / Sprint 完了 trace |
| [`work-log`](reference/templates/work-log.md) | 2 | agent 間 comm の persist (record_work_log) |

詳細: [`reference/templates/README.md`](reference/templates/README.md)

---

## 13. Hooks (v0.24 active activation)

plugin v0.24 から hooks が **真に活動** する形に強化:

| Hook | 動作 |
|---|---|
| `SessionStart` | Context Engine 起動 + Decision tree への navigation 案内 |
| `Stop` | Session 終了前 checklist (remember / record_work_log / ttl 昇格 / complete_with_context) |
| `PreToolUse(Write)` | `*/memory/*.md` への Write 検出時、 Layer 判定 prompt (Layer 2 cloud に書くべきか問い直す) |
| `UserPromptSubmit` | decision keyword (決定 / confirmed / done / merged 等) 検出時、 remember 提案 |

Hook は **強制 block ではなく nudge**。 agent が判定して進めるか変更するかを decide できる。

---

## リファレンス

- [Decision Tree](reference/decision-tree.md) — Layer 判定 / scene mapping
- [Anti-Patterns](reference/anti-patterns.md) — 10 個のやらないこと
- [/memories scene](reference/scenes/memories.md) — data layer playbook
- [/atlas scene](reference/scenes/atlas.md) — structure layer playbook
- [/views scene](reference/scenes/views.md) — perspective layer playbook
- [/actions scene](reference/scenes/actions.md) — motion layer playbook
- [Cookbook: Phase 完了](reference/cookbooks/phase-completion.md)
- [Cookbook: Bug Fix](reference/cookbooks/bug-fix.md)
- [Cookbook: Decision Record](reference/cookbooks/decision-record.md)
- [Cookbook: Cycle Close](reference/cookbooks/cycle-close.md)
- [Cookbook: Onboarding](reference/cookbooks/onboarding.md)
- [Templates](reference/templates/README.md) — memory 作成 scaffold (v0.24 NEW)
- [API Redesign Proposal](reference/api-redesign.md) — 70 tool → 11 tool 将来構想
- [MCP Tools (現状)](reference/mcp-tools.md) — 70 tool 詳細
- [Setup](reference/setup.md)
- [Workflows (legacy examples)](reference/workflows.md)
