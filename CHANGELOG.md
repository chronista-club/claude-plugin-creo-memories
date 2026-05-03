# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


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
