#!/usr/bin/env bash
#
# infer-atlas.sh — Current context から Atlas 名を推定
#
# imp-007 (v0.27): branch / cwd / package.json の signal を組み合わせて
# 「今の work が紐付くべき Atlas」 を推定。 SessionStart hook が agent に
# 提示、 mcp__creo-memories__remember 等の atlasId 引数を埋めるヒントに。
#
# Usage:
#   ./infer-atlas.sh                # auto-detect (cwd 基準)
#   ./infer-atlas.sh /path/to/repo  # path 明示
#
# Output: atlas 名 1 行 (推定 confident な場合) or 「不明」 message

set -euo pipefail

# jaq drop-in detection (Rust port of jq、 5-10x faster startup)
JQ="${JQ:-$(command -v jaq 2>/dev/null || command -v jq 2>/dev/null || true)}"

REPO_PATH="${1:-$(pwd)}"
cd "$REPO_PATH" 2>/dev/null || { echo "ERROR: invalid path: $REPO_PATH" >&2; exit 1; }

prefix_to_atlas() {
    case "$1" in
        creo) echo "creo-memories" ;;
        vp) echo "vantage-point" ;;
        ac) echo "chronista-club" ;;
        fs) echo "fleetstage" ;;
        muu) echo "muuv" ;;
        usn) echo "unison" ;;
        cpl) echo "cplp-sound-system" ;;
        gfp) echo "Go Fast Packing" ;;
        *) return 1 ;;
    esac
}

cwd_to_atlas() {
    case "$1" in
        creo-memories|claude-plugin-creo-memories) echo "creo-memories" ;;
        vantage-point) echo "vantage-point" ;;
        chronista-hub|creo-id) echo "chronista-club" ;;
        creo-ui) echo "Creo UI" ;;
        fleetstage) echo "fleetstage" ;;
        fleetflow) echo "fleetflow" ;;
        unison) echo "unison" ;;
        cplp-sound-system) echo "cplp-sound-system" ;;
        go-fast-packing) echo "Go Fast Packing" ;;
        nexus) echo "nexus" ;;
        bokeboy) echo "bokeboy" ;;
        *) return 1 ;;
    esac
}

# 1. Try git branch (Linear-style: e.g. mako/creo-103-... or mako/vp-94-...)
if branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); then
    # extract prefix between / and digit (e.g. creo from mako/creo-103-...)
    prefix=$(echo "$branch" | sed -nE 's|.*/([a-z]{2,4})-?[0-9]+.*|\1|p')
    if [ -n "$prefix" ]; then
        if atlas=$(prefix_to_atlas "$prefix"); then
            echo "$atlas"
            exit 0
        fi
    fi
fi

# 2. Fallback: cwd basename
base=$(basename "$REPO_PATH")
if atlas=$(cwd_to_atlas "$base"); then
    echo "$atlas"
    exit 0
fi

# 3. Fallback 2: package.json name field (if monorepo or npm-style)
if [ -f "$REPO_PATH/package.json" ] && [ -n "$JQ" ]; then
    pkg_name=$($JQ -r '.name // ""' "$REPO_PATH/package.json" 2>/dev/null | sed 's|^@[^/]*/||')
    if [ -n "$pkg_name" ]; then
        if atlas=$(cwd_to_atlas "$pkg_name"); then
            echo "$atlas"
            exit 0
        fi
    fi
fi

# 4. 不明: 推定不可
echo "(unknown — cwd basename: $base)"
exit 1
