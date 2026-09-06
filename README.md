# claude-plugin-creo-memories

Claude Code plugin for **creo-memories** — the external brain. Your context is finite and the session ends; creo is where the continuation lives, shared with the next you, other agents (codex / grok), and people.

## What it gives Claude

- **MCP server** `https://mcp.creo-memories.in/` (75 tools; tool descriptions are the source of truth)
- **Skill** `creo-memories` — purpose, the shape of the world (3 lineages × 16 kinds, marks, labels, lock, proposals, briefing, sender), the judgment for *what to write / where / when to read*, how to work with others, and the non-obvious traps. ≤ 120 lines. No mandates: the mechanical rules are enforced by the server
- **Hooks** (4, one line each)
  - `SessionStart` — the atlas hint for this repo (the server does not know your cwd)
  - `PreCompact` — before the context shrinks: write the handoff
  - `Stop` — decisions / learnings / unfinished todos go to creo
  - `PreToolUse(Write */memory/*.md)` — local memory is a cache; the canonical copy is `/agent/claude`

## Layout

```
skills/creo-memories/
  SKILL.md                 A purpose / B world / C judgment / D with others / E traps
  reference/model.md       spec 25 summary (lineages, kinds, marks, label, lock, proposals, briefing, self & cache)
  reference/tools-map.md   intent → tool (all 75; verified by creo-memories CI)
  reference/recipes.md     6 scenes: start / handoff / decision / incident / todo / with others
  reference/agent-atlas.md /agent and /agent/claude, local as cache
hooks/                     hooks.json, session-start.sh, pre-compact.sh
scripts/infer-atlas.sh     cwd / git remote → atlas slug
```

## Install

```
/plugin marketplace add chronista-club/chronista-plugins
/plugin install creo-memories@chronista-plugins
```

Authentication: the MCP server uses OAuth (Creo ID). On first use Claude Code opens the login.

## Companion

The plugin mirrors the MCP server's tool list, argument names and atlas names. The mirror is verified by `apps/creo-mcp-server/src/plugin-contract.test.ts` in the (private) `creo-memories` repo (CI job `plugin-contract`, clones this repo's `main`). Changes to tools on the server side come paired with a PR here; PR numbers reference each other. Spec: creo-memories `docs/spec/25-memory-classification.md`, design doc 39.

## Changelog

See [CHANGELOG.md](CHANGELOG.md). 0.55.0 is the rewrite for the spec-25 world (2026-09-06).

## License

MIT
