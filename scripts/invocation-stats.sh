#!/usr/bin/env bash
#
# invocation-stats.sh — Plugin tool invocation 統計
#
# imp-001 (v0.26 instrumentation): PostToolUse hook が
# ~/.claude/creo-memories-invocation.log に append した invocation 履歴を
# 集計して output。 daily / weekly / biweekly / quarterly loop が consume。
#
# Usage:
#   invocation-stats.sh                    # 全期間 stats
#   invocation-stats.sh today              # 今日のみ
#   invocation-stats.sh week               # 直近 7 日
#   invocation-stats.sh month              # 直近 30 日
#   invocation-stats.sh --since YYYY-MM-DD # 任意期間
#
# Output: Markdown 表 (stdout)。 Loop dashboard / detail memory に embed 可能。

set -euo pipefail

# jaq drop-in detection (Rust port of jq、 5-10x faster startup)
JQ="${JQ:-$(command -v jaq 2>/dev/null || command -v jq)}"

LOG_FILE="${CREO_INVOCATION_LOG:-$HOME/.claude/creo-memories-invocation.log}"

if [ ! -f "$LOG_FILE" ]; then
    echo "## Plugin invocation stats"
    echo ""
    echo "_Log file not found: ${LOG_FILE}_"
    echo ""
    echo "_Hook が未動作 or session 中の invocation 0 件。 PostToolUse hook が enable されているか確認 (plugin v0.26+)_"
    exit 0
fi

# 期間 filter
period="${1:-all}"
case "$period" in
    today)
        cutoff=$(date -u +%Y-%m-%d)
        title="Today (${cutoff})"
        ;;
    week)
        cutoff=$(date -u -v-7d +%Y-%m-%d 2>/dev/null || date -u -d '7 days ago' +%Y-%m-%d)
        title="Last 7 days (since ${cutoff})"
        ;;
    month)
        cutoff=$(date -u -v-30d +%Y-%m-%d 2>/dev/null || date -u -d '30 days ago' +%Y-%m-%d)
        title="Last 30 days (since ${cutoff})"
        ;;
    --since)
        cutoff="${2:-1970-01-01}"
        title="Since ${cutoff}"
        ;;
    *)
        cutoff="1970-01-01"
        title="All time"
        ;;
esac

# 期間内 invocation 抽出
filtered=$(awk -v cutoff="$cutoff" '$1 >= cutoff' "$LOG_FILE" || true)

if [ -z "$filtered" ]; then
    echo "## Plugin invocation stats — ${title}"
    echo ""
    echo "_該当期間 invocation 0 件_"
    exit 0
fi

total=$(echo "$filtered" | wc -l | tr -d ' ')
unique_tools=$(echo "$filtered" | awk '{print $2}' | sort -u | wc -l | tr -d ' ')

echo "## Plugin invocation stats — ${title}"
echo ""
echo "- Total invocations: **${total}**"
echo "- Unique tools: **${unique_tools}**"
echo ""
echo "### Top 10 tools by frequency"
echo ""
echo "| Tool | Count | % |"
echo "|---|---:|---:|"
echo "$filtered" | awk '{print $2}' | sort | uniq -c | sort -rn | head -10 | \
    awk -v total="$total" '{ pct = ($1 / total) * 100; printf "| %s | %d | %.1f%% |\n", $2, $1, pct }'

echo ""
echo "### Daily distribution (last 14 days)"
echo ""
echo "| Date | Invocations |"
echo "|---|---:|"
echo "$filtered" | awk '{ split($1, a, "T"); print a[1] }' | sort | uniq -c | tail -14 | \
    awk '{ printf "| %s | %d |\n", $2, $1 }'

echo ""
echo "_Source: \`${LOG_FILE}\`_"
