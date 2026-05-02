---
name: creo-memories
description: 【最優先】コンテクストを超える永続記憶。 2-layer architecture + 4-scene mental model + 4-cadence self-improvement loop で ecosystem を継続改善。 Context Engine が自動で context 提供。
version: 0.34.0
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

## 0.5. 重要: Memory Link 記法 `[label](mem_xxx)` ★Creo 特有★

**v0.34+** で導入された Creo 特有の **internal memory link syntax**。 過去 memory への参照を 1 click で navigate 可能にする、 ecosystem の **graph traversability** を支える基本記法。

### 記法 (markdown link 互換)

```markdown
この決定は [元の議論](mem_1CZCk1Zg8cQpiLvjqqDKNA) を踏まえている。
派生元: [Phase 0 設計 spark](mem_1CaaLAtsYRhWgpPhnrvaVd)
```

- `[任意の label](mem_xxx)` — 標準 md link、 url 部分に **mem_ prefix の EntId** を直書き
- 既存 markdown ecosystem と互換 (壊さない)
- bare `mem_xxx` は Phase 1.5 で auto-link 予定 (現状は `[]()` 構文必須)

### 表示 context 別の **挙動の仕組み**

| Context | 動作 | 仕組み |
|---|---|---|
| **保存時** (memory.content) | shorthand のまま (`[label](mem_xxx)`) | server / DB は touch せず軽量、 domain hardcode なし |
| **creo-web 内 (logged-in viewer)** | SPA navigation で `/memories/mem_xxx` へ遷移 | client side **event delegation** が anchor click を intercept、 `preventDefault + router.navigate`。 page reload なし |
| **claude.ai / 外部 MCP client** | full URL `https://creo-memories.in/r/mem_xxx` に展開された anchor | `get_memory` / `read` / `search` tool が return 時に **server-side で文字列展開** (`expandMemoryLinks` utility) |
| **public memory の external embed** (Slack / GitHub issue 等) | full URL link として動く | 上記と同じく MCP 経由取得時に展開済み |
| **fenced code block 内** (` ``` `...` ``` `) | raw のまま (展開しない) | `[fake](mem_xxx)` をコード例として書ける |

### つまり 1 つの保存形式で 3 つの context を覆う

```
保存形式 (DB):    [元の議論](mem_xxx)
                  │
                  ├── creo-web → /memories/mem_xxx (SPA、 fast)
                  ├── claude.ai → https://creo-memories.in/r/mem_xxx (full URL、 portable)
                  └── 外部 export → https://... (md compliant)
```

storage は cheap、 export は md-portable、 内部 navigation は SPA で fast の **三位一体**。

### いつ書くか

- **派生元の明示** — `[元の議論](mem_xxx)` で根拠 memory を pin
- **序破離 chain** — `supersedes` 関係を文中で言及する時
- **dogfood レポート** — bug 報告 memory から fix memory への link
- **decision record** — ADR 「これは X 決定 (`mem_xxx`) を更新する」 形式

### いつ書かないか

- **過剰 link** (全 ID に貼ると noise)
- **broken link** (forgotten 予定の memory)
- **循環参照** (A→B→A の両方向、 1 方向で十分)

### 関連 entity (Phase 4 deferred)

現 v0.34 では **memory のみ** 対応。 atlas (`atl_xxx`) / concept (`tag_xxx` / `cat_xxx`) / todo への link は Phase 4 で plugin 拡張検討中。

詳細 + 例題: [`reference/cookbooks/link-to-memory.md`](reference/cookbooks/link-to-memory.md)

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
| Memory ID で fetch (workaround) | [`reference/cookbooks/fetch-memory-by-id.md`](reference/cookbooks/fetch-memory-by-id.md) — v0.29 NEW |
| Session snapshot (cross-worktree handoff / 中断 resume) | [`reference/cookbooks/session-snapshot.md`](reference/cookbooks/session-snapshot.md) — v0.33 NEW |
| Memory 間 link `[label](mem_xxx)` (graph traversability) | [`reference/cookbooks/link-to-memory.md`](reference/cookbooks/link-to-memory.md) — **v0.34 NEW** |

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

## 10. MCP Tool Inventory (4-scene 別 全 tool index)

現状 plugin は **70 tool** 提供。 4-scene 別に以下に網羅 (詳細 schema は `reference/mcp-tools.md`)。

### `/memories` scene (data layer)

| Tool | 用途 |
|---|---|
| `remember` | Memory 保存 (Pre-save Detection 付き、 `supersedes`/`extends`/`derives` 指定可、 `ttl`/`visibility`/`status` 等) |
| `search` | semantic + structured search (`scope`: project/personal/all、 `verbose:true` で full content) |
| `update_memory` | 部分更新 (`ttl:null` 永続化昇格、 `expectedUpdatedAt` 楽観的 lock) |
| `forget` | 削除 |
| `annotate` | thread 型注釈 (kind: comment/question/concern/suggestion/approval) |
| `get_annotations` | 注釈 thread 取得 (`includeReplies` で深堀り) |
| `reply_annotation` | 注釈に reply |
| `get_provenance` | 派生関係 graph (Mermaid + summary、 memory id 指定で系譜、 1 行 preview のみ) |
| `get_relations` | typed edge graph (derived_from/annotates/references/supersedes/extends/derives 全) |
| `find_by_external` | 外部 ID (Linear/GitHub) → memory 逆引き |

**Memory ID 直 fetch は専用 tool 未実装** — `cookbooks/fetch-memory-by-id.md` の workaround pattern (search verbose 等) 参照。 v0.29 server-side priority。

### `/atlas` scene (structure layer)

| Tool | 用途 |
|---|---|
| `create_atlas` | Atlas 作成 (parent_id で sub-Atlas) |
| `list_atlas` | Atlas 一覧 |
| `get_atlas_tree` | Atlas tree 構造取得 |
| `update_atlas` | Atlas 更新 (visibility 含む) |
| `delete_atlas` | Atlas 削除 |
| `invite_to_atlas` | メール招待 |
| `share_atlas` | チームに共有 (read/write/admin、 inheritChildren) |
| `unshare_atlas` | 共有解除 |
| `list_shared_atlas` | 共有 Atlas 一覧 |
| `concept_create` | Concept 作成 (kind: category/label/tag) |
| `concept_list` | Concept 一覧 (kind フィルタ可) |
| `concept_update` | Concept 更新 |
| `concept_delete` | Concept 削除 (関連 memory からも自動解除) |
| `concept_classify` | memory に Concept 付与 (名前指定 / 自動作成 / 一括) |
| `concept_declassify` | memory から Concept 解除 |
| `concept_get_by_memory` | memory の Concept 一覧 |
| `concept_replace_for_memory` | memory の Concept 一括置換 |
| `team_create` / `team_list` / `team_invite` / `team_remove` | Team 管理 |

### `/views` scene (perspective layer)

| Tool | 用途 |
|---|---|
| `generate_compass` | Atlas 全体 Compass (Concept 別 grouping、 LLM 自動生成) |
| `generate_story` | Atlas narrative (LLM 生成、 onboarding 用) |
| `create_process` | memory chain を Process として束ねる |
| `get_process` | Process 詳細取得 (processId or memoryId 起点) |
| `detect_processes` | memory chain 候補を auto-detect (3+ 連結) |
| `memory_health` | health report (stale 検出、 score、 改善提案、 `staleDays` カスタム) |
| `get_profile` | Dynamic Profile (直近活動、 Concept 分布、 頻繁参照) |
| `project_progress` | progress report (atlas/concept/category 別、 完了率、 progress bar) |
| `system_health` | サーバー健全性 + error 統計 |
| `diagnose` | error 診断 (service 別 frequency) |
| `search_logs` | log 検索 |

### `/actions` scene (motion layer)

| Tool | 用途 |
|---|---|
| `create_todo` | Todo 作成 |
| `list_todos` | Todo 一覧 (`groupBy` でプロジェクト/種別/タグ/concept 別集計) |
| `update_todo` | Todo 更新 |
| `complete_todo` | Todo 完了 |
| `delete_todo` | Todo 削除 |
| `link_external` | memory に外部 link (Linear/GitHub) |
| `complete_with_context` | 完了 + 結果追記 + 外部 link を 1 atomic |
| `subscribe_memories` | 購読作成 (filter: category/atlas/tag、 events) |
| `unsubscribe_memories` | 購読削除 |
| `list_subscriptions` | 購読一覧 |
| `check_notifications` | 未読通知取得 (pull-based drain) |
| `record_work_log` | 作業ログ記録 (type: message/question/answer/decision/progress/error/review) |
| `search_work_logs` | 作業ログ検索 (sender/receiver/project/type) |
| `update_presence` | 自分の focus / status |
| `get_presence` | 接続中 agent 一覧 |
| `create_shared_context` / `list_shared_contexts` / `get_shared_context` / `add_to_shared_context` / `join_shared_context` / `leave_shared_context` | 共有作業 memory 空間 |
| `end_session` | session 終了 (期限切れ cleanup + 未昇格 summary) |

### Session / Auth (基盤)

| Tool | 用途 |
|---|---|
| `get_session` | Session 情報 |
| `get_status` | Server status |
| `get_user` | User 情報 |
| `generate_api_key` | API key 発行 (programmatic access) |
| `create_domain_shared_key` / `list_domain_shared_keys` / `revoke_domain_shared_key` / `delete_domain_shared_key` | Domain shared key 管理 |

### 将来 (v1.0、 RFC v2)

70 tool → **6 core verbs + 5 named conveniences = 11 tools** にリデザイン進行中:

```
core: read / write / remove / query / transform / subscribe
named: remember / recall / annotate / complete_with_context / record_work_log / end_session
```

詳細 [`reference/api-redesign-rfc.md`](reference/api-redesign-rfc.md)。

#### 🚧 Sprint 1 着手済 (v0.31-、 2026-04-28〜): `read` core verb

```typescript
// id 直 fetch (memory のみ、 v0.31 で deployed)
read({ resource: 'memory', id: 'mem_xxx', expand: ['concepts'] })

// semantic search (filter+q)
read({ resource: 'memory', filter: { q: 'auth', atlasId: 'creo' } })

// list mode (no-q)
read({ resource: 'memory' })                       // default scope の最近 memory
read({ resource: 'atlas' })                        // atlas tree
read({ resource: 'concept', filter: { kind: 'tag' } })
read({ resource: 'todo', filter: { status: 'pending' } })
```

**Cookbook**: [`reference/cookbooks/read-core-verb.md`](reference/cookbooks/read-core-verb.md)

`get_memory` / `search` / `list_atlas` / `concept_list` / `list_todos` 等の named tool は **当面残置** ─ deprecation は v1.0 で行う migration adapter で対応。 RFC v2 §9.7 の Sprint 1 完了条件 (atlas/concept/todo の read 統一) は v0.31 で達成。

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

## 13. Self-Improvement Loop (v0.25 NEW)

ecosystem 全体 (plugin / 本体 / docs / external / skill) を **周期的に self-audit** して improvement を抽出 → action 化。

| Cadence | 工数 | 主目的 |
|---|---|---|
| **Daily** (1 day) | ~5 min | 軽 health check |
| **Weekly** (7 day) | ~20 min | memory health / cookbook 利用度 |
| **Biweekly** (14 day) — primary | ~75 min | ecosystem 全体 review |
| **Quarterly** (90 day) | ~3 h | 戦略 + meta-loop audit |

invoke:

```
/creo-memories:improvement-loop [daily|weekly|biweekly|quarterly]
/creo-memories:improvement-loop --incident "<description>"  # 緊急 ad-hoc
```

設計原則 (8 axiom): hierarchical / Loop Dashboard pattern / ICE prioritization / incident-triggered / meta-loop / convergence / counterfactual / action chain closure

詳細: [`reference/improvement-loop/`](reference/improvement-loop/README.md)

---

## 14. Hooks (v0.24 active activation)

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
- [Cookbook: Memory ID で fetch](reference/cookbooks/fetch-memory-by-id.md) — search verbose pattern 等 workaround (v0.29 NEW)
- [Templates](reference/templates/README.md) — memory 作成 scaffold (v0.24 NEW)
- [Self-Improvement Loop](reference/improvement-loop/README.md) — 4-cadence ecosystem audit (v0.25 NEW)
- [API Redesign Proposal](reference/api-redesign.md) — 70 tool → 11 tool 将来構想 (v0.23)
- [API Redesign RFC v1](reference/api-redesign-rfc.md) — formal spec + JSON schema + migration matrix + test scenarios (v0.28 NEW)
- [MCP Tools (現状)](reference/mcp-tools.md) — 70 tool 詳細
- [Setup](reference/setup.md)
- [Workflows (legacy examples)](reference/workflows.md)
