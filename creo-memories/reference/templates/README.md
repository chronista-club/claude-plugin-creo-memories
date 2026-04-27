# Memory Templates

Memory 作成時の **scaffold**。 各 template は frontmatter + body の structure を提供。 cookbook と組み合わせて使う。

## Layer 別 templates

### Layer 1 (Local file canon) — `~/.claude/projects/<project>/memory/*.md`

不変方針 / cross-project rule / reference card 用。 Write tool で markdown 直書き。

| Template | 用途 |
|---|---|
| [`feedback.md`](feedback.md) | ユーザー方針 / preference / 「これは常にこう」 rule |
| [`reference-card.md`](reference-card.md) | URL / ID / 設定値などの参照表 |
| [`project-canon.md`](project-canon.md) | project 固有の不変 fact (アーキテクチャ等) |

### Layer 2 (Cloud trace) — `mcp__creo-memories__remember`

動的 project state / 出来事 trace / multi-agent 用。 plugin 経由 cloud に保存。

| Template | 用途 | Cookbook |
|---|---|---|
| [`decision-record.md`](decision-record.md) | ADR 風 architectural decision | [decision-record](../cookbooks/decision-record.md) |
| [`bug-fix.md`](bug-fix.md) | bug の root cause + 解決策 | [bug-fix](../cookbooks/bug-fix.md) |
| [`phase-completion.md`](phase-completion.md) | Phase / Sprint 完了 trace | [phase-completion](../cookbooks/phase-completion.md) |
| [`work-log.md`](work-log.md) | agent 間 comm の persist | (各 cookbook 内蔵) |

## 使い方

### Layer 1 の場合

```bash
cp ~/.claude/plugins/creo-memories/reference/templates/feedback.md \
  ~/.claude/projects/<project>/memory/<slug>.md
# 中身を埋める → MEMORY.md index に行追加
```

### Layer 2 の場合 (LLM agent から)

```
1. template 内容を read (この dir 配下)
2. placeholder を実コンテンツに置換
3. mcp__creo-memories__remember({ content: <置換済 markdown>, ...metadata })
```

## Decision tree との連動

template を選ぶ前に必ず `creo-memories/reference/decision-tree.md` で Layer 判定。 迷ったら Layer 2 default。
