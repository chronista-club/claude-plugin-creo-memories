#!/usr/bin/env bash
# SessionStart hook. Claude Code sets CLAUDE_PLUGIN_ROOT to this plugin's install dir.
# server は cwd / branch を知らない (atlas は認証の既定 atlas)。「今どの project か」の手がかりは plugin だけが出せる。

atlas=$("${CLAUDE_PLUGIN_ROOT}/scripts/infer-atlas.sh" 2>/dev/null || echo "")

if [ -n "$atlas" ]; then
  printf '%s\n' "creo: この repo の atlas の手がかり = \"$atlas\" (cwd / git remote 由来。remember / search の atlasId に)。「今日の脳」は MCP の instructions に入っている。"
else
  printf '%s\n' "creo: atlas は read({ resource: 'atlas' }) で選ぶ。「今日の脳」は MCP の instructions に入っている。"
fi
