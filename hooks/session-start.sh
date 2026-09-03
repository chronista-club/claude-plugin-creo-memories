#!/usr/bin/env bash
# SessionStart hook. Claude Code sets CLAUDE_PLUGIN_ROOT to this plugin's install dir.

atlas=$("${CLAUDE_PLUGIN_ROOT}/scripts/infer-atlas.sh" 2>/dev/null || echo "")

printf '%s\n\n%s\n' \
  "Creo Memories v3.0: Context Engine active. Session context is automatically provided via instructions." \
  "💡 Decision Tree: 記録前に creo-memories/reference/decision-tree.md を確認 (Layer 1 local canon vs Layer 2 cloud trace の判定)。"

if [ -n "$atlas" ] && ! printf '%s' "$atlas" | grep -q "^(unknown"; then
  printf '\n%s\n' "💡 Suggested Atlas (branch + cwd 由来): \"$atlas\" — mcp__creo-memories__remember 等の atlasId に活用。"
fi

printf '\n%s\n' "💡 Agent Atlas: /agent (全 agent 共通) と /agent/claude (Claude 専用) を、作業に関係しそうな時に search で読む。project の記憶は project atlas、自分の癖・修正点は /agent/claude、他 agent にも効く知識は /agent に書き、tag agent:claude を付ける。atlasId 指定の search は子 atlas を含まないので agent と claude を両方検索する。詳細: creo-memories/reference/agent-atlas.md"

printf '\n%s\n' "💡 Self-Improvement Loop: ecosystem 全体 review が overdue な場合は /creo-memories:improvement-loop で実行 (default biweekly、 ~75 min)。"
