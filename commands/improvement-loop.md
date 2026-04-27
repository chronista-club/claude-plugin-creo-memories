---
description: Creo Memories ecosystem の self-improvement loop を実行 (cadence 引数指定可、 default biweekly)
---

# /creo-memories:improvement-loop [cadence]

引数: `daily` | `weekly` | `biweekly` | `quarterly` | `--incident "<description>"`

省略時: `biweekly` (primary cadence)

## 実行手順

### 1. Cadence 判定 + checklist read

引数 `$1` を判定:
- `daily` → `creo-memories/reference/improvement-loop/daily.md` を読む
- `weekly` → `creo-memories/reference/improvement-loop/weekly.md`
- `biweekly` (default) → `creo-memories/reference/improvement-loop/biweekly.md`
- `quarterly` → `creo-memories/reference/improvement-loop/quarterly.md`
- `--incident` → `creo-memories/reference/improvement-loop/incident-triggered.md`

### 2. 前提 (consumes) を fetch

各 cadence は下位 cadence の output を consume:
- weekly: 直近 7 日の daily output (memory query)
- biweekly: 直近 14 日の weekly output × 2
- quarterly: 直近 90 日の biweekly output × 6 + Loop Dashboard 全 history

```typescript
// 例: biweekly が consume する weekly output を fetch
mcp__creo-memories__search({
  query: 'Weekly Loop',
  scope: 'project',
  filter: { fromDate: '14 days ago', conceptIds: ['weekly-loop'] },
  limit: 2
})
```

### 3. Checklist の各 item を順序通り実行

skip しない。 「該当無し」 でも明示的にチェックして memo。

### 4. Findings を ICE で score

各 finding を:
- Impact (1-5): 解消した時の効果
- Confidence (1-5): 改善 hypothesis の確度
- Ease (1-5): 実装コスト (高=容易)

`Score = I × C × E`

### 5. Action chain closure (mandatory)

全 finding に verdict:
- `Score >= 60` → **now** (即実装)
- `Score 25-59` → **next-cycle** (Issue / memory pending)
- `Score < 25` → **drop** (drop reason 明記)

「maybe later」 「TBD」 は **禁止**。 全 finding を mechanically closure。

### 6. User confirmation (action 実施前)

top 3 candidate を user に提示:
- now verdict 候補 (即実装) — 内容 + diff preview
- next-cycle 候補 — Issue 化 / memory pending する内容
- drop 候補 — drop reason

user confirmation で action 確定。 confirmed のみ実施。

### 7. Action 実施

- **now**: 直接 patch / PR draft / memory action
- **next-cycle**: Linear issue 起票 (`mcp__linear-chronista__save_issue`) OR memory remember (status:'todo')
- **drop**: drop reason memo (将来「なぜ drop した」 を traceable に)

### 8. Loop Dashboard 更新 (rolling)

```typescript
// dashboard を search
const dashboard = await mcp__creo-memories__search({
  query: 'Creo Memories Improvement Dashboard',
  scope: 'project',
  limit: 1
})

// rolling update (新 entry 追加、 11 件目以降 truncate)
await mcp__creo-memories__update_memory({
  id: dashboard.id,
  content: <updated body>
})
```

### 9. 詳細 memory 作成

cadence 別の详细 output memory:

```typescript
mcp__creo-memories__remember({
  content: `# {Cadence} Loop YYYY-MM-DD\n\n## Findings (ICE)\n{table}\n\n## Action chain\n- now: ...\n- next-cycle: ...\n- drop: ...\n\n## Convergence\n- prev: N, this: M, trend: ↑/↓/→\n\n## Notes\n- ...`,
  category: 'learning',
  conceptIds: ['{cadence}-loop', 'YYYY-MM-DD'],
  atlasId: '<meta-atlas>'
})
```

### 10. Dashboard ↔ detail link

```typescript
mcp__creo-memories__link({
  from: dashboard.id,
  to: detailMemory.id,
  relation: 'extends'
})
```

## 引数 examples

| Command | 動作 |
|---|---|
| `/creo-memories:improvement-loop` | default biweekly (~75 min) |
| `/creo-memories:improvement-loop daily` | daily light (~5 min) |
| `/creo-memories:improvement-loop weekly` | weekly focused (~20 min) |
| `/creo-memories:improvement-loop quarterly` | strategic + meta (~3 h) |
| `/creo-memories:improvement-loop --incident "<desc>"` | ad-hoc 緊急 (~30 min) |

## Output

- Loop Dashboard memory が rolling update
- 詳細 memory (cadence 別) が作成、 dashboard と link
- now verdict items が即実装済 (PR / memory / patch)
- next-cycle verdict items が Linear issue / memory に積まれる
- drop verdict items の drop reason が memo

## 重要

- 各 cadence の **時間制約厳守** (daily 5min / weekly 20min / biweekly 75min / quarterly 3h)
- Action chain closure **mandatory**
- ICE prioritization で「あった方が良い」 を mechanically filter
- Dashboard rolling pattern で memory noise を avoid

## 関連

- [Self-improvement loop overview](../creo-memories/reference/improvement-loop/README.md)
- [Dashboard Pattern](../creo-memories/reference/improvement-loop/dashboard-pattern.md)
- [Incident-triggered](../creo-memories/reference/improvement-loop/incident-triggered.md)
