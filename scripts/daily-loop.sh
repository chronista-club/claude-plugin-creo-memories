#!/usr/bin/env bash
#
# daily-loop.sh — Daily Improvement Loop wrapper script
#
# imp-004 (v0.26): daily checklist の自動化部分を script 化。
# Plugin tool (system_health 等) を要する部分は claude headless mode を
# 経由するか、 manual 補完。
#
# 本 script で扱う:
# - Layer 1 memory dir の light scan (file count / 最終更新分布 / stale 候補)
# - invocation-stats.sh の today summary
# - Markdown report を stdout 出力
#
# Plugin tool (system_health / memory_health / list_todos / check_notifications)
# は別途 claude headless or manual 実行 (本 script の OUT-OF-SCOPE)
#
# Usage:
#   daily-loop.sh                    # default project (cwd basename or env)
#   daily-loop.sh creo-memories      # project name 明示
#
# Output: Markdown report (stdout)。 memory として保存可能。

set -euo pipefail

# jaq drop-in detection (Rust port of jq、 5-10x faster startup)
JQ="${JQ:-$(command -v jaq 2>/dev/null || command -v jq)}"
export JQ  # 内包 invocation-stats.sh も継承

PROJECT="${1:-${CREO_PROJECT:-$(basename "$(pwd)")}}"
MEMORY_DIR="$HOME/.claude/projects/-Users-${USER}-repos-${PROJECT}/memory"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

today=$(date -u +%Y-%m-%d)

echo "# Daily Loop — ${PROJECT} — ${today}"
echo ""

# Section 1: Layer 1 memory health
echo "## 1. Layer 1 memory (local file canon)"
echo ""

if [ -d "$MEMORY_DIR" ]; then
    total_count=$(find "$MEMORY_DIR" -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' ')
    today_modified=$(find "$MEMORY_DIR" -name '*.md' -type f -mtime -1 2>/dev/null | wc -l | tr -d ' ')
    week_modified=$(find "$MEMORY_DIR" -name '*.md' -type f -mtime -7 2>/dev/null | wc -l | tr -d ' ')
    stale_30d=$(find "$MEMORY_DIR" -name '*.md' -type f -not -newermt "30 days ago" 2>/dev/null | wc -l | tr -d ' ')
    stale_90d=$(find "$MEMORY_DIR" -name '*.md' -type f -not -newermt "90 days ago" 2>/dev/null | wc -l | tr -d ' ')

    echo "- Total memory files: **${total_count}**"
    echo "- Modified today: ${today_modified}"
    echo "- Modified last 7 days: ${week_modified}"
    echo "- Stale (>30d not modified): ${stale_30d}"
    if [ "${stale_90d}" -gt 0 ]; then
        echo "- Stale (>90d not modified): **${stale_90d}** ⚠️"
    else
        echo "- Stale (>90d not modified): 0"
    fi
    echo ""

    if [ "$stale_90d" -gt 30 ]; then
        echo "⚠️ Stale memory > 30 件、 weekly loop で archive / forget 検討"
        echo ""
    fi

    # MEMORY.md index 整合性 (簡易)
    if [ -f "$MEMORY_DIR/MEMORY.md" ]; then
        index_entries=$(grep -cE '^\- \[' "$MEMORY_DIR/MEMORY.md" || echo 0)
        echo "- MEMORY.md index entries: ${index_entries} (vs files: ${total_count})"
        if [ "$index_entries" -lt $((total_count - 5)) ]; then
            echo "  ⚠️ index drift 疑い (file 多い vs index 少ない)、 weekly で同期 review"
        fi
    fi
else
    echo "_Memory dir not found: $MEMORY_DIR_"
fi
echo ""

# Section 2: Plugin invocation stats (今日)
echo "## 2. Plugin invocation (today)"
echo ""
if [ -x "$SCRIPT_DIR/invocation-stats.sh" ]; then
    "$SCRIPT_DIR/invocation-stats.sh" today
else
    echo "_invocation-stats.sh not executable_"
fi
echo ""

# Section 3: Layer 2 cloud check (manual prompt)
echo "## 3. Layer 2 cloud (要 manual / claude headless)"
echo ""
echo "以下を別途実行:"
echo ""
echo "\`\`\`"
echo "# Plugin 本体 health"
echo "mcp__creo-memories__system_health"
echo ""
echo "# Memory garden 状態"
echo "mcp__creo-memories__memory_health"
echo ""
echo "# 未読 notification drain"
echo "mcp__creo-memories__check_notifications limit:20"
echo ""
echo "# Open todos (priority:high のみ)"
echo "mcp__creo-memories__list_todos groupBy:priority"
echo "\`\`\`"
echo ""

# Section 4: Recommendation
echo "## 4. Recommendation"
echo ""
echo "- 異常 detect されたら weekly loop に escalate"
echo "- stale > 30 件なら次 weekly で archive batch"
echo "- biweekly loop の next due date を Loop Dashboard memory で確認"
echo ""
echo "---"
echo ""
echo "_Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)_"
echo "_Cookbook: \`creo-memories/reference/improvement-loop/daily.md\`_"
