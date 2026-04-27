#!/usr/bin/env bash
#
# weekly-loop.sh — Weekly Improvement Loop wrapper (~20 min)
#
# v0.27: Daily の延長で、 週次 focus の data prep + checklist scaffold。
# 自動化可能な metric 集計 + agent が埋める質的 review section。
#
# Usage:
#   ./weekly-loop.sh                    # default project (cwd basename or env)
#   ./weekly-loop.sh creo-memories      # project 明示
#
# Output: Markdown report (stdout)。 memory として保存可能。

set -euo pipefail

# jaq drop-in detection
JQ="${JQ:-$(command -v jaq 2>/dev/null || command -v jq)}"
export JQ

PROJECT="${1:-${CREO_PROJECT:-$(basename "$(pwd)")}}"
MEMORY_DIR="$HOME/.claude/projects/-Users-${USER}-repos-${PROJECT}/memory"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

today=$(date -u +%Y-%m-%d)
week_iso=$(date -u +%Y-W%V)

echo "# Weekly Loop — ${PROJECT} — ${today} (${week_iso})"
echo ""

# Section 1: Atlas inference
echo "## 1. Atlas context"
echo ""
atlas=$("$SCRIPT_DIR/infer-atlas.sh" 2>/dev/null || echo "(unknown)")
echo "- Suggested atlas: \`${atlas}\`"
echo "- Project: \`${PROJECT}\`"
echo ""

# Section 2: Layer 1 memory analysis (週次 focus)
echo "## 2. Layer 1 memory (weekly focus)"
echo ""

if [ -d "$MEMORY_DIR" ]; then
    total=$(find "$MEMORY_DIR" -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' ')
    week_modified=$(find "$MEMORY_DIR" -name '*.md' -type f -mtime -7 2>/dev/null | wc -l | tr -d ' ')
    stale_30d=$(find "$MEMORY_DIR" -name '*.md' -type f -not -newermt "30 days ago" 2>/dev/null | wc -l | tr -d ' ')

    echo "- Total: ${total} files"
    echo "- Modified last 7 days: **${week_modified}** (週次活動量)"
    echo "- Stale (>30d): ${stale_30d}"
    echo ""

    echo "### 直近 7 日 modified files (top 10)"
    echo ""
    find "$MEMORY_DIR" -name '*.md' -type f -mtime -7 2>/dev/null | \
        xargs -I{} stat -f "%m %N" {} 2>/dev/null | \
        sort -rn | head -10 | \
        awk '{
            ts=$1; $1="";
            sub(/^ /,"");
            sub(/.*\//,"");
            cmd="date -r " ts " +%Y-%m-%d";
            cmd | getline d;
            close(cmd);
            printf "- %s — %s\n", d, $0
        }'
    echo ""

    if [ "$stale_30d" -gt 50 ]; then
        echo "⚠️ Stale > 50 件、 archive batch 検討 (next biweekly に積み残し)"
        echo ""
    fi
else
    echo "_Memory dir not found_"
fi
echo ""

# Section 3: Plugin invocation (週次)
echo "## 3. Plugin invocation (last 7 days)"
echo ""
if [ -x "$SCRIPT_DIR/invocation-stats.sh" ]; then
    "$SCRIPT_DIR/invocation-stats.sh" week
fi
echo ""

# Section 4: Cookbook 利用度 (manual prompt、 agent が埋める)
echo "## 4. Cookbook / Tool 利用度 (要 agent reflection)"
echo ""
cat <<'CHECKLIST'
本 week で活用した cookbook / tool を agent が埋める:

- [ ] PreToolUse(Write) hook fire 数 + accept/ignore 比 (目視 or invocation log 上限)
- [ ] decision keyword hook fire 数 + 実 remember 化 比
- [ ] cookbook 参照頻度: phase-completion / bug-fix / decision-record / cycle-close / onboarding
- [ ] 4-scene 別 tool 使用率 (`/memories` `/atlas` `/views` `/actions`)
- [ ] under-used tool 1-2 件 identification

CHECKLIST
echo ""

# Section 5: Concept hierarchy (manual)
echo "## 5. Concept hierarchy review (要 manual)"
echo ""
cat <<'CHECKLIST'
- [ ] mcp__creo-memories__concept_list で重複 concept 検出
- [ ] 命名 inconsistency (priority:high vs high-priority 等) 整理
- [ ] kind 別バランス (label / category / tag)

CHECKLIST
echo ""

# Section 6: Process / Compass 生成 (manual)
echo "## 6. Process / Compass 生成 (要 manual or claude headless)"
echo ""
cat <<'CHECKLIST'
- [ ] 完了 chain あれば mcp__creo-memories__detect_processes → create_process
- [ ] 週末 snapshot として mcp__creo-memories__generate_compass(atlasId)

CHECKLIST
echo ""

# Section 7: Improvement candidates synthesis
echo "## 7. Improvement candidates synthesis"
echo ""
cat <<'CHECKLIST'
A-6 から「来週やる 1-2 件」 を pick + biweekly loop 候補に lift up すべき事項を memo:

- [ ] 来週 candidate 1: __________
- [ ] 来週 candidate 2: __________
- [ ] biweekly lift up: __________

CHECKLIST
echo ""

echo "---"
echo ""
echo "_Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)_"
echo "_Cookbook: \`creo-memories/reference/improvement-loop/weekly.md\`_"
echo ""
echo "## Output: memory として保存"
echo ""
cat <<'SAVE_EXAMPLE'
mcp__creo-memories__remember({
  content: <本 report の output、 完成版>,
  category: 'learning',
  conceptIds: ['weekly-loop', '<YYYY-WNN>'],
  atlasId: '<atlas>',
  ttl: 1209600  // 2 week 後 expire (biweekly が引き継ぐ)
})
SAVE_EXAMPLE
