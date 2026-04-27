#!/usr/bin/env bash
#
# biweekly-loop.sh — Biweekly Improvement Loop wrapper (~75 min, PRIMARY)
#
# v0.27: 14 day cadence、 ecosystem 全体 review。 自動化 metric prep +
# 質的 review checklist。 ICE prioritization 結果を agent が record。
#
# Usage:
#   ./biweekly-loop.sh                    # default project
#   ./biweekly-loop.sh creo-memories      # project 明示
#
# Output: Markdown report scaffold (stdout)。 agent が findings + ICE 埋めて
# Loop Dashboard memory + detail memory として保存。

set -euo pipefail

# jaq drop-in detection
JQ="${JQ:-$(command -v jaq 2>/dev/null || command -v jq)}"
export JQ

PROJECT="${1:-${CREO_PROJECT:-$(basename "$(pwd)")}}"
MEMORY_DIR="$HOME/.claude/projects/-Users-${USER}-repos-${PROJECT}/memory"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

today=$(date -u +%Y-%m-%d)

echo "# Biweekly Loop — ${PROJECT} — ${today}"
echo ""

# Section 0: Atlas + repo context
echo "## 0. Context"
echo ""
atlas=$("$SCRIPT_DIR/infer-atlas.sh" 2>/dev/null || echo "(unknown)")
echo "- Suggested atlas: \`${atlas}\`"
echo "- Project: \`${PROJECT}\`"
echo "- Cycle: 14-day biweekly"
echo ""

# Section A. Plugin (claude-plugin-creo-memories) — もし plugin repo cwd
echo "## A. Plugin metadata"
echo ""
plugin_dir="$HOME/repos/claude-plugin-creo-memories"
if [ -d "$plugin_dir" ]; then
    if [ -f "$plugin_dir/.claude-plugin/plugin.json" ]; then
        version=$($JQ -r '.version' "$plugin_dir/.claude-plugin/plugin.json")
        echo "- Plugin version: **${version}**"
    fi
    if [ -d "$plugin_dir/.git" ]; then
        commits_14d=$(cd "$plugin_dir" && git log --since='14 days ago' --oneline 2>/dev/null | wc -l | tr -d ' ')
        echo "- Plugin commits (last 14 days): ${commits_14d}"
    fi
    skill_lines=$(wc -l < "$plugin_dir/creo-memories/SKILL.md" 2>/dev/null | tr -d ' ' || echo 0)
    echo "- SKILL.md lines: ${skill_lines}"
    open_pr=$(cd "$plugin_dir" && gh pr list --state open 2>/dev/null | wc -l | tr -d ' ' || echo 0)
    echo "- Open PRs: ${open_pr}"
fi
echo ""

# Section B. 本体 (mcp.creo-memories.in) — 要 plugin tool
echo "## B. 本体 (mcp.creo-memories.in)"
echo ""
echo "_要 plugin tool: 別途 invoke_"
echo ""
cat <<'CHECKLIST'
- [ ] mcp__creo-memories__system_health
- [ ] dependency drift (`bun outdated` 等)
- [ ] CI green rate (last 14 day)
- [ ] perf metric trend (latency / 5xx rate)

CHECKLIST
echo ""

# Section C. Documentation drift
echo "## C. Documentation drift (auto-check)"
echo ""
if [ -d "$plugin_dir" ]; then
    # Internal markdown link の broken check (簡易)
    cd "$plugin_dir"
    broken=0
    for f in $(find creo-memories/reference -name '*.md' 2>/dev/null); do
        for link in $(grep -ohE '\([./a-zA-Z0-9_-]+\.md[^)]*\)' "$f" | sed 's/[()]//g; s/#.*//'); do
            target_path="$(dirname "$f")/$link"
            target_path=$(realpath "$target_path" 2>/dev/null || echo "")
            if [ -n "$target_path" ] && [ ! -f "$target_path" ]; then
                broken=$((broken + 1))
            fi
        done
    done
    if [ "$broken" -eq 0 ]; then
        echo "- ✅ Internal markdown link: broken 0 件"
    else
        echo "- ⚠️ Internal markdown link broken: ${broken} 件"
    fi
    cd - > /dev/null
fi
echo ""
echo "_要 manual_"
echo ""
cat <<'CHECKLIST'
- [ ] SKILL.md 内 mcp__creo-memories__* 言及 → 全 tool 存在確認
- [ ] README v0.X What's New section が latest と一致
- [ ] cookbook example の API call が最新 schema 準拠

CHECKLIST
echo ""

# Section D. External integrations (manual + 簡易 check)
echo "## D. External integrations"
echo ""
linear_check=$(gh auth status 2>&1 | grep -q "Logged in" && echo "✓" || echo "?")
echo "- GitHub auth: ${linear_check}"
echo ""
cat <<'CHECKLIST'
- [ ] Linear API: mcp__linear-chronista__list_teams で connectivity test
- [ ] Auth0 cert 残期間 (>30 day)
- [ ] external MCP (claude-in-chrome / browser-use) status

CHECKLIST
echo ""

# Section E. Memory quality
echo "## E. Memory quality"
echo ""
if [ -d "$MEMORY_DIR" ]; then
    total=$(find "$MEMORY_DIR" -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' ')
    stale_90d=$(find "$MEMORY_DIR" -name '*.md' -type f -not -newermt "90 days ago" 2>/dev/null | wc -l | tr -d ' ')
    week_modified=$(find "$MEMORY_DIR" -name '*.md' -type f -mtime -14 2>/dev/null | wc -l | tr -d ' ')

    echo "- Total Layer 1: ${total}"
    echo "- Modified last 14 days: ${week_modified}"
    echo "- Stale >90d: ${stale_90d}"
fi
echo ""
echo "_Cloud Layer 2 (要 manual)_"
echo ""
cat <<'CHECKLIST'
- [ ] mcp__creo-memories__memory_health で full audit
- [ ] type 分布 (project / feedback / user / reference)
- [ ] Atlas distribution (orphan / 偏在)
- [ ] Concept hierarchy 重複

CHECKLIST
echo ""

# Section F. Usage / activation
echo "## F. Activation metrics"
echo ""
if [ -x "$SCRIPT_DIR/invocation-stats.sh" ]; then
    "$SCRIPT_DIR/invocation-stats.sh" --since "$(date -u -v-14d +%Y-%m-%d 2>/dev/null || date -u -d '14 days ago' +%Y-%m-%d)"
fi
echo ""

# Section G. ICE-ranked findings (agent fills)
echo "## G. Improvement candidates (ICE-ranked、 agent 埋め)"
echo ""
cat <<'CHECKLIST'
A-F の各 finding を ICE で score:

| ID | Source | Title | I | C | E | I×C×E | Verdict |
|---|---|---|---|---|---|---|---|
| imp-N | <section> | <title> | _ | _ | _ | _ | now/next-cycle/drop |

- Score >= 60 → **now** (本 session で実装)
- Score 25-59 → **next-cycle** (Linear / memory pending)
- Score < 25 → **drop** (drop reason 明記)

CHECKLIST
echo ""

# Section H. Action chain closure
echo "## H. Action chain closure & Output"
echo ""
cat <<'CHECKLIST'
全 finding に verdict mandatory:

- [ ] now verdict items → 本 session で実装 (PR draft / memory 操作)
- [ ] next-cycle items → Linear issue or memory pending
- [ ] drop items → drop reason memo

### Output: Loop Dashboard 更新

1. mcp__creo-memories__update_memory({ id: '<dashboard ID>', content: <updated> })
2. mcp__creo-memories__remember({ content: <本 report 完成版>, category: 'learning', conceptIds: ['biweekly-loop', '<date>'], atlasId, extends: ['<dashboard ID>'] })

### Convergence trend

- prev cycle findings: __
- this cycle findings: __
- trend: ↑ (degrading) / ↓ (healthy or scope narrow) / → (steady)

CHECKLIST
echo ""

echo "---"
echo ""
echo "_Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)_"
echo "_Cookbook: \`creo-memories/reference/improvement-loop/biweekly.md\`_"
echo "_Dashboard pattern: \`improvement-loop/dashboard-pattern.md\`_"
