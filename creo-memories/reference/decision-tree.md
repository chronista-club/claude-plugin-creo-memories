# Memory Decision Tree

何かを記録したくなった時、 **どこに / どう** 書くか判定する flow。

## 前提: Creo Memories は 2 layer 並立

| Layer | 場所 | 役割 |
|---|---|---|
| **Layer 1 — Local Canon** | `~/.claude/projects/<project>/memory/*.md` (markdown file) | **不変方針 / cross-project rule / reference card**。 緩慢に変化、 solo-authored、 MEMORY.md index で管理 |
| **Layer 2 — Cloud Trace** | `mcp.creo-memories.in` (`mcp__creo-memories__*` tools) | **動的 project state / 出来事 trace / multi-agent collaboration**。 速く変化、 共有、 semantic search、 Atlas / Concept で structure |

詳細は本 plugin README の「2-layer architecture」 section 参照。

## Q1: これは「自分 / プロジェクトが常に従う方針」か?

**Yes** — Layer 1 (local file `*.md`)。 例:
- workflow rule (例: 「PR は 1 motion で merge まで流す」)
- foundational principle (例: 「Email = Identity SSOT」)
- cross-project な reference card (例: Linear team UUID 一覧、 deploy URL)
- ユーザー preference (例: 「terse responses 好む」)

**No** — Q2 へ。

## Q2: これは「ある時点で起こった事実 / 決定 / 現状」か?

**Yes** — Layer 2 (cloud `remember`)。 例:
- project 進捗 (例: 「CREO-103 Phase 1 完了 PR #351」)
- bug 発見 + 解決策 (例: 「filterByRange flaky の原因は date-dep」)
- review finding (例: 「moody-blues review で 4 issue 検出」)
- inter-agent comm (`record_work_log` 併用)
- 一時的な作業 memo (`ttl: 3600` 等で auto-expire)

**No** (どちらでもない) — 書かなくて OK か reconsider。

## Q3 (補助): multi-agent / multi-session で参照されるか?

**Yes** — 必ず Layer 2 (Q1 の不変方針でも team 共有が必要なら Layer 2 にもコピー)。
**Solo / 自分だけ** — Layer 1 で OK。

## 迷ったら

**Layer 2 (cloud) を default**。 Layer 1 は厳しめに gate する。 理由: Layer 1 は MEMORY.md index にも露出し、 全 session で auto-load される。 ノイズが入ると signal が薄まる。

## 4-scene mental model 連動

Layer 2 (cloud) の operation は **4 scene** に分かれる:

| Scene | 役割 | 主 tool |
|---|---|---|
| `/memories` | data layer (memory 個体 CRUD + 関係) | `remember` / `search` / `update_memory` / `forget` / `annotate` / `get_provenance` |
| `/atlas` | structure layer (memory の整理 / 分類 / 共有) | `*_atlas` / `concept_*` / `share_atlas` / `invite_to_atlas` |
| `/views` | perspective layer (collection を別角度で表示) | `generate_compass` / `generate_story` / `create_process` / `memory_health` / `get_profile` / `project_progress` |
| `/actions` | motion layer (memory を動かす / 反応する) | `create_todo` / `link_external` / `subscribe_memories` / `record_work_log` / `update_presence` / `complete_with_context` / `end_session` |

詳細は `reference/scenes/{memories,atlas,views,actions}.md` 参照。

## 例題

| 状況 | 判定 |
|---|---|
| 「PR は 1 motion で merge まで流す」 | Q1 Yes → Layer 1 (local file)、 例 `pr-to-merge-one-motion.md` |
| 「CREO-103 Phase 1 完了 PR #351」 | Q1 No / Q2 Yes → Layer 2 cloud `remember(category:'task', status:'done', link_external)` |
| 「Discord OAuth client ID = 1496377838717108354」 | Q1 Yes (reference card) → Layer 1、 例 `discord-creo-id-identifiers.md` |
| 「session 中の試行錯誤 memo」 | Q2 Yes (一時) → Layer 2 cloud `remember(ttl:3600)` |
| 「memory model = 序破離 stage」 | Q1 Yes (foundational) → Layer 1、 例 `memory-stage-contract.md` |
| 「mito からの msg: PR review 依頼」 | Q2 Yes / Q3 Yes (multi-agent) → Layer 2 `record_work_log(type:'message')` |
| 「2026-04-26 に kdl-schema を hub に absorb」 | Q2 Yes (出来事) → Layer 2、 関連 atlas 配下 |
| 「ADR-005: tombstone + GDPR purge 採用」 | Q1 No / Q2 Yes → Layer 2 (将来 ADR type 追加で first-class) |

## Anti-pattern

詳細は `reference/anti-patterns.md`。
