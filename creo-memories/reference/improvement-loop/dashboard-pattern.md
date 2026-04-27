# Loop Dashboard Pattern

全 cadence の output を **1 つの rolling memory** に集約する pattern。 散発 memo は noise 化、 single rolling state は navigate 容易。

## Memory schema

```yaml
title: Creo Memories Improvement Dashboard
type: project (Layer 2)
visibility: public
atlas: <meta-atlas>
concepts:
  - kind:'category', name:'meta'
  - kind:'tag', name:'improvement-loop'
status: active  # 永続 rolling、 dropしない
```

## Body structure

```markdown
# Creo Memories Improvement Dashboard

> Last updated: YYYY-MM-DD HH:MM (TZ)
> Next biweekly loop due: YYYY-MM-DD

---

## Latest snapshot

### Cadence run history (rolling、 過去 10 件)

| Date | Cadence | Findings | Now | Next | Drop | Score median |
|---|---|---|---|---|---|---|
| 2026-04-28 | biweekly | 7 | 2 | 4 | 1 | 45 |
| 2026-04-21 | biweekly | 9 | 3 | 5 | 1 | 50 |
| ... | | | | | | |

### Convergence trend

- Findings/cycle: 7 → 9 → 8 → 7 (trending steady)
- Accepted ratio: 86%, 89%, 87% (healthy)
- → System health: green

### Active candidates (next-cycle に積み残し)

| ID | Cadence | Title | I × C × E | Status |
|---|---|---|---|---|
| imp-001 | biweekly-2026-04-28 | Atlas auto-inference impl | 5×4×3=60 | next-cycle |
| imp-002 | weekly-2026-04-25 | concept_classify 利用率 boost | 4×3×4=48 | next-cycle |

### Dropped candidates (latest 5)

| ID | Cadence | Title | Drop reason |
|---|---|---|---|
| imp-099 | weekly-2026-04-18 | RSS feed | scope 外、 demand 低 |

---

## Per-layer status

### Plugin (claude-plugin-creo-memories)

- Latest: v0.25.0 (2026-04-28)
- Open PR: 0
- SKILL.md tool count: 70 (target: 11、 v0.25 で v0.24+ proposal doc 化済)
- Hook fire rate (passive observation): N/A (instrumentation 未実装)

### 本体 (mcp.creo-memories.in)

- Health: green
- Open issue: N
- Latest API version: ...
- 11-tool redesign progress: design phase

### Documentation

- Reference link 整合性: ✓
- SKILL.md drift: 0 件
- README v0.X 整合: ✓

### External integrations

- Linear: green (last connectivity test: YYYY-MM-DD)
- GitHub OAuth: valid (expires YYYY-MM-DD)
- Auth0 cert: valid (expires YYYY-MM-DD)
- Discord MCP: setup placeholder のみ (token 待ち)

### Memory quality (meta)

- Local Layer 1 file count: 60+
- Cloud Layer 2 stats: (sample query 結果)
- Stale memory ratio: ~10% (healthy)
- Type 分布: project 40% / feedback 25% / user 15% / reference 20%

---

## Last quarterly retrospective (90-day)

- Quarter: 2026-Q2
- Top breakthrough: 2-layer architecture confirmed
- Biggest miss: API redesign timing 遅延
- Loop self-evaluation: biweekly worth keeping、 weekly drop 検討中
- Counterfactual: 「もし Q1 で hook 強化していたら、 Layer 判定 nudge が早く効いた」

詳細: mem_xxx (latest quarterly memory link)

---

## Operational notes

- Dashboard は rolling update (新 cycle 毎に追記、 古い entry を rolling 10 件で truncate)
- 各 cycle 詳細は **separate memory** + dashboard から link (deep dive 用)
- dashboard 自体は **永続 active**、 status:cancelled しない
```

## Update operation

各 cadence の loop 完了時:

```typescript
// 1. dashboard を fetch
const dashboard = await mcp__creo-memories__search({
  query: 'Creo Memories Improvement Dashboard',
  scope: 'project',
  limit: 1
})

// 2. body を rolling update (新 entry 追加、 11 件目以降 truncate)
const newBody = updateRolling(dashboard.content, newEntry)

// 3. update_memory
await mcp__creo-memories__update_memory({
  id: dashboard.id,
  content: newBody
})

// 4. 詳細 memory を別途作成
const detailMemory = await mcp__creo-memories__remember({
  content: <full loop output>,
  category: 'learning',
  conceptIds: ['improvement-loop', '<cadence>'],
  atlasId: '<meta-atlas>'
})

// 5. dashboard と link
await mcp__creo-memories__link({
  from: dashboard.id,
  to: detailMemory.id,
  relation: 'extends'
})
```

## なぜ rolling か (anti-pattern との対比)

❌ **Anti-pattern**: 各 loop で独立 memory 作成 → 1 quarter で 50+ 件の loop memory が散在 → 「最新がどれ」「trend どう?」 が見えない

✅ **Pattern**: 1 dashboard memory + N detail memory (link)
- dashboard = navigate 起点 (1 件 read で state 把握)
- detail = deep dive 用 (必要時のみ open)

## 関連

- [Self-improvement loop](README.md)
- [Cookbook: cycle-close](../cookbooks/cycle-close.md) — 類似 rolling pattern
