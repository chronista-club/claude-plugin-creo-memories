# Plugin Scripts

Self-improvement loop の **automate-able 部分** を bash script 化した utility 集。

## Scripts

### `invocation-stats.sh`

Plugin tool invocation の log 集計 (PostToolUse hook 由来)。

```bash
./invocation-stats.sh                    # 全期間 stats
./invocation-stats.sh today              # 今日のみ
./invocation-stats.sh week               # 直近 7 日
./invocation-stats.sh month              # 直近 30 日
./invocation-stats.sh --since 2026-01-01 # 任意期間
```

**Output**: Markdown 表 (top 10 tools / daily distribution)

**前提**: PostToolUse hook (v0.26+) が `~/.claude/creo-memories-invocation.log` を populate している

### `daily-loop.sh`

Daily Improvement Loop の自動化部分。 Layer 1 memory health + invocation stats を集約。

```bash
./daily-loop.sh                  # default project (cwd basename)
./daily-loop.sh creo-memories    # project 明示
```

**Output**: Markdown report (3 section + recommendation)

**Out of scope**: Plugin tool 必須部分 (system_health / memory_health 等) は別途 manual or claude headless で

## Cron 例

毎日 09:00 に daily loop を実行 → memory に保存:

```bash
# crontab -e
0 9 * * * /path/to/daily-loop.sh creo-memories | tee -a ~/.claude/daily-loop-$(date +\%Y\%m\%d).md
```

毎月 1 日に invocation 月次 stats:

```bash
0 9 1 * * /path/to/invocation-stats.sh month
```

## Performance: jaq (Rust jq alternative) drop-in

PostToolUse hook は **invocation 毎に発火** (高頻度)、 jq の起動 cost が累積する。 Rust 製 [`jaq`](https://github.com/01mf02/jaq) は drop-in 互換で **起動 5-10x 速い**:

```bash
brew install jaq
```

hook command や script 内で `jq` → `jaq` 置換可能 (syntax 99% 互換)。 v0.27 で hook を `command -v jaq >/dev/null && JQ=jaq || JQ=jq` 形式に refactor 検討。

代替候補:
- **jaq** — 最 jq-互換 Rust port、 推奨
- **gojq** — Go port、 同じく drop-in
- **jql** — Rust だが query 構文が違う (jq 互換 NOT)

## Cookbook 連動

- daily loop checklist: `creo-memories/reference/improvement-loop/daily.md`
- weekly: `weekly.md`
- biweekly (primary): `biweekly.md`
- quarterly: `quarterly.md`

各 cookbook の **automate-able 部分** が本 scripts/ に embed される設計。
