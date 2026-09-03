# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased]

### Added
- **Agent Atlas の案内**: SessionStart hook に `/agent` (全 agent 共通) と `/agent/claude` (Claude 専用) の
  使い分けを 1 行出すようにした。project の記憶は project atlas、自分の癖・修正点は `/agent/claude`、
  他 agent にも効く知識は `/agent` (tag `agent:claude`)。`atlasId` 指定の search は子 atlas を含まない注意つき。
  規約の SSOT は `/agent` atlas の charter memory (slug `agent-charter`)、要約を
  `skills/creo-memories/reference/agent-atlas.md` に置き、SKILL.md / decision-tree.md の Decision Tree に Q2.5 を追加

## [0.53.0] - 2026-09-01

### Changed
- **ロックステップ復帰**: プロダクト (`chronista-club/creo-memories`) の `0.53.0` に版数を揃えた。
  `0.35.0` (2026-05-15) 以降 bump が止まり、プロダクトだけが進んでいたため 18 マイナー分の
  ズレが生じていた。`0.36.0`〜`0.52.0` は欠番。
- SKILL.md / RFC の tool 名・tool 数を現行実装 (72 tool) に同期 (#20)
- B-2 slug/display_name resolver を SKILL.md に反映 (#21)

### Fixed
- `0.35.0` 以降 `skills/` の中身が更新されていた (#20 / #21 で 5 ファイル 49 行) にもかかわらず
  `plugin.json` の version が据え置かれていた問題を解消。marketplace 側は version を持たず
  (chronista-plugins #10)、配布される版数は本 repo の `plugin.json` がそのまま使われるため、
  version を据え置くと「新しい版が出た」シグナルがどこにも立たない。

## [0.35.0] - 2026-05-14

### Added
- **atomic tag CRUD primitives**: 単独 tag を原子的に追加/削除/rename する 3 新 MCP tool ([CREO-174](https://linear.app/chronista/issue/CREO-174))
  - `add_tag(id, tag)` — 既存 tag なら no-op (idempotent)
  - `remove_tag(id, tag)` — 不在 tag なら no-op (idempotent)
  - `rename_tag(id, oldTag, newTag)` — oldTag 不在は `ValidationError` throw
  - dual storage 同時更新 (`tags` top-level + `metadata.tags` nested、 SurrealQL `array::distinct`/`array::complement`)
  - chain 伸長しない (in-place、 atomic tag CRUD は非意味的変更扱い)
  - concept service 連携 (classify / declassify を非 blocking で並走)
- HTTP endpoint も同型で追加: `POST/DELETE/PATCH /api/memories/:id/tags`
- 既存 `update_memory({tags: [...]})` (全置換) との **後方互換維持**、 並走で expose

### Documentation
- `mcp-tools.md`: 3 新 tool を articulate + `update_memory` の tag 操作節に使い分けガイド追記

## [0.34.2] - 2026-05-02

### Fixed
- `session-snapshot.md` cookbook の `search` 例が query 必須を明示していなかった (Phase 4 Confirm / Resume / List)。 dogfood で 0 件返却を観測 → `get_memory({id})` を主路線に変更 + query 必須を WARNING で明示
- SKILL.md frontmatter version drift (0.34.0 → 0.34.2、 plugin.json と整合)
- CHANGELOG `[0.34.0]` の Changed entry が実際は v0.34.1 内容 → v0.34.1 entry に移動

## [0.34.1] - 2026-05-02

### Changed
- Skill tree refactor: `creo-memories/SKILL.md` → `skills/creo-memories/SKILL.md` (公式 spec 準拠)
- Spec compliance: license/homepage fields, removed legacy skills.txt

## [0.34.0] - 2026-05-02

### Added
- Internal memory link `[label](mem_xxx)` syntax (Phase 1: server expand + client delegate)
- Session snapshot cookbook + onboarding step 0
