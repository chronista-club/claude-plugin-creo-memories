#!/usr/bin/env bash
#
# quarterly-loop.sh — Quarterly Improvement Loop wrapper (~3 hours, STRATEGIC + META)
#
# v0.28: 90-day cadence、 戦略的 review + meta-loop audit + counterfactual。
# 自動化 metric prep (90-day 集計 / convergence trend / Plugin release history)
# + 質的 review checklist (agent reasoning 中心、 script は data layer のみ)。
#
# Usage:
#   ./quarterly-loop.sh                    # default project
#   ./quarterly-loop.sh creo-memories      # project 明示
#
# Output: Markdown report scaffold (stdout)。 quarter retrospective memory
# として保存、 strategic decision を ADR 化。

set -euo pipefail

# jaq drop-in detection (v0.27)
JQ="${JQ:-$(command -v jaq 2>/dev/null || command -v jq)}"
export JQ

PROJECT="${1:-${CREO_PROJECT:-$(basename "$(pwd)")}}"
MEMORY_DIR="$HOME/.claude/projects/-Users-${USER}-repos-${PROJECT}/memory"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

today=$(date -u +%Y-%m-%d)
quarter=$(date -u +%Y-Q$(( ($(date -u +%-m) - 1) / 3 + 1 )))

echo "# Quarterly Loop — ${PROJECT} — ${today} (${quarter})"
echo ""

# Section 0: Context
echo "## 0. Context"
echo ""
atlas=$("$SCRIPT_DIR/infer-atlas.sh" 2>/dev/null || echo "(unknown)")
echo "- Suggested atlas: \`${atlas}\`"
echo "- Project: \`${PROJECT}\`"
echo "- Cycle: 90-day quarterly"
echo "- Quarter: ${quarter}"
echo ""

# Section A. Quarter retrospective (~20 min)
echo "## A. Quarter retrospective (data prep)"
echo ""

plugin_dir="$HOME/repos/claude-plugin-creo-memories"
if [ -d "$plugin_dir" ] && [ -d "$plugin_dir/.git" ]; then
    cd "$plugin_dir"

    # Plugin commits in last 90 days
    plugin_commits=$(git log --since='90 days ago' --oneline 2>/dev/null | wc -l | tr -d ' ')
    echo "- Plugin commits (last 90d): **${plugin_commits}**"

    # Plugin releases (version bumps)
    plugin_releases=$(git log --since='90 days ago' --grep='feat(v0\.' --oneline 2>/dev/null | wc -l | tr -d ' ')
    echo "- Plugin releases (last 90d): **${plugin_releases}**"

    # Latest release
    latest=$(git log -1 --grep='feat(v0\.' --pretty=format:'%h %s' 2>/dev/null | head -1)
    [ -n "$latest" ] && echo "- Latest release: \`${latest}\`"

    cd - > /dev/null
fi

# creo-memories repo commits (if exists)
creo_dir="$HOME/repos/creo-memories"
if [ -d "$creo_dir/.git" ]; then
    cd "$creo_dir"
    creo_commits=$(git log --since='90 days ago' --oneline 2>/dev/null | wc -l | tr -d ' ')
    creo_prs=$(git log --since='90 days ago' --grep='(#[0-9]\+)' --oneline 2>/dev/null | wc -l | tr -d ' ')
    echo "- creo-memories repo commits (last 90d): ${creo_commits}"
    echo "- creo-memories merged PRs (last 90d): ~${creo_prs}"
    cd - > /dev/null
fi

# Layer 1 memory creation in 90 days
if [ -d "$MEMORY_DIR" ]; then
    layer1_90d=$(find "$MEMORY_DIR" -name '*.md' -type f -newermt "90 days ago" 2>/dev/null | wc -l | tr -d ' ')
    echo "- Layer 1 memory created (last 90d): ${layer1_90d}"
fi

echo ""
echo "_Manual fill: 主要 ship / decision / incident / 達成 vs goal_"
echo ""

# Section B. Convergence trend cross-cycle (~15 min)
echo "## B. Convergence trend (cross-cycle、 6 biweekly cycles)"
echo ""
echo "_Loop Dashboard memory から history を read して trend visualize_"
echo ""
cat <<'CHECKLIST'
- [ ] mcp__creo-memories__search query='Improvement Dashboard' → dashboard memory ID
- [ ] mcp__creo-memories__get_relations memoryId=<dashboard> で extends edge を traverse
- [ ] 6 biweekly + N daily/weekly の output を集約
- [ ] Per-cycle finding count: trending up / down / steady?
- [ ] Accepted/total ratio trend
- [ ] System health: green / yellow / red

CHECKLIST
echo ""

# Section C. Architecture-level review (~20 min)
echo "## C. Architecture-level review"
echo ""
cat <<'CHECKLIST'
### 2-layer architecture audit
- [ ] Layer 1 / Layer 2 比率 (現実 ratio)
- [ ] 「迷ったら Layer 2」 default が守られているか
- [ ] federation 必要性が顕在化したか

### 4-scene mental model
- [ ] 各 scene 別 tool 使用率
- [ ] under-used scene
- [ ] missing scene 候補

### 70 → 11 tool redesign
- [ ] design phase 完了か (api-redesign-rfc.md status)
- [ ] server-side implement 計画
- [ ] migration phase 移行 timing

CHECKLIST
echo ""

# Section D. Foundational memory review (~15 min)
echo "## D. Foundational memory review"
echo ""
if [ -d "$MEMORY_DIR" ]; then
    echo "### Foundational memories (Layer 1)"
    if [ -f "$MEMORY_DIR/MEMORY.md" ]; then
        # Foundational Architecture section の entries 抽出
        awk '/^## Foundational Architecture/,/^## /' "$MEMORY_DIR/MEMORY.md" | grep '^- \[' | head -10 | sed 's/^/  /'
    fi
fi
echo ""
cat <<'CHECKLIST'
- [ ] 各 foundational principle が陳腐化していないか
- [ ] supersede すべき principle が無いか
- [ ] 新規 foundational principle (今 quarter で確立) が必要か

CHECKLIST
echo ""

# Section E. External ecosystem (~20 min)
echo "## E. External ecosystem review"
echo ""
gh_check=$(gh auth status 2>&1 | grep -q "Logged in" && echo "✓" || echo "?")
echo "- GitHub auth: ${gh_check}"
echo ""
cat <<'CHECKLIST'
- [ ] Linear / GitHub / Auth0 / Discord MCP 健全性
- [ ] 新 external integration 候補 (Slack / Notion / Calendar)
- [ ] deprecate すべき integration

CHECKLIST
echo ""

# Section F. Meta-loop audit (~30 min) **重要**
echo "## F. Meta-loop audit (loop 自身を audit)"
echo ""
echo "_最重要 section — loop が「ritual without value」化していないか_"
echo ""
echo "### Cadence value 評価"
echo ""

# invocation-stats.sh で 90-day 集計 を data prep として
if [ -x "$SCRIPT_DIR/invocation-stats.sh" ]; then
    echo "#### 90-day invocation stats"
    echo ""
    "$SCRIPT_DIR/invocation-stats.sh" --since "$(date -u -v-90d +%Y-%m-%d 2>/dev/null || date -u -d '90 days ago' +%Y-%m-%d)"
fi
echo ""

cat <<'CHECKLIST'
### Cadence 別 value 評価

- [ ] **Daily**: 平均何件 alert したか、 true positive 比?
  - 90 day で alert 0 件続き → drop or scope 拡大
  - alert 多発 → fundamental incident、 quarterly で root cause
- [ ] **Weekly**: 発見 candidate のうち next-cycle accept された比
  - <30% → loop が noise 生成、 quality bar 上げる
  - >80% → quality 高い、 維持
- [ ] **Biweekly**: action chain closure 率
- [ ] **Quarterly**: 本 quarterly 自体の effort vs benefit (recursive!)

### Drop 候補 (価値出していない loop)

- [ ] daily が 90 day alert 0 件 → drop or scope 広げる
- [ ] weekly が biweekly に吸収可能なら廃止
- [ ] 新 cadence 追加候補: monthly (30 day) / continuous monitor

CHECKLIST
echo ""

# Section G. Counterfactual retrospective (~15 min)
echo "## G. Counterfactual retrospective"
echo ""
cat <<'CHECKLIST'
「あの時こう loop 走らせていたら何が違ったか?」 で loop 感度 sanity check:

- [ ] 過去 quarter で起きた surprise / unexpected outcome を 3 件 list
- [ ] それぞれ: 「earlier loop で detect 可能だったか?」 yes/no/partial
- [ ] yes → loop signal 追加 (例: cert 有効期限を daily check 等)
- [ ] no → loop の限界、 別 mechanism (incident-triggered ad-hoc) で補完

CHECKLIST
echo ""

# Section H. Strategic direction (~30 min)
echo "## H. Strategic direction (next quarter)"
echo ""
cat <<'CHECKLIST'
- [ ] Next quarter の **theme** 設定 (例: 「Performance & Activation」)
- [ ] **Major version** planning (v0.X → v0.Y で何を ship、 v1.0 timing)
- [ ] **Breaking change** candidate (deprecate / removal の planning)
- [ ] **Foundational decision** pending (ADR 起票 timing)
- [ ] **Resource allocation** (どの layer に時間投資)

CHECKLIST
echo ""

# Section I. Loop self-improvement (meta-meta) (~10 min)
echo "## I. Loop self-improvement (meta-meta)"
echo ""
cat <<'CHECKLIST'
本 quarterly checklist 自体を audit:

- [ ] 本 quarterly checklist が cumbersome / scope 過大なら scope 縮小
- [ ] 新 section 追加候補
- [ ] 削除 section 候補
- [ ] script 化 (本 file) の補完が必要な section

CHECKLIST
echo ""

# Section J. Action chain closure & Output (~5 min)
echo "## J. Action chain closure & Output"
echo ""
cat <<'CHECKLIST'
全 finding に verdict mandatory:

- [ ] **now** verdict → 即実装 / PR draft
- [ ] **next-cycle** → next quarterly に持ち越し OR Linear epic 起票
- [ ] **drop** → reason memo + archive
- [ ] **Strategic decision** → ADR memory 起票 (cookbook/decision-record.md)

### Output 1: Loop Dashboard quarterly section 更新

mcp__creo-memories__update_memory({ id: '<dashboard>', content: <updated with quarterly retro> })

### Output 2: Quarter retrospective memory

mcp__creo-memories__remember({
  content: <本 report 完成版>,
  category: 'learning',
  conceptIds: ['quarterly-loop', 'retrospective', '<YYYY-QN>'],
  atlasId: 'meta',
  visibility: 'public'
})

### Output 3: ADR memories

任意の architectural decision を:
mcp__creo-memories__remember({ category: 'design', conceptIds: ['adr', ...], ... })

### Output 4: Linear epic for next quarter theme

mcp__linear-chronista__save_issue({ title: '<theme>', team: 'Creo Memories' })

CHECKLIST
echo ""

echo "---"
echo ""
echo "_Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)_"
echo "_Cookbook: \`creo-memories/reference/improvement-loop/quarterly.md\`_"
echo "_Dashboard pattern: \`improvement-loop/dashboard-pattern.md\`_"
