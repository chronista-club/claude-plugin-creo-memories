# Biweekly Improvement Loop (~75 min) — PRIMARY

ecosystem 全体 (plugin / 本体 / docs / external / skill / memory model 自身) を full review。 14 day cadence、 改善 momentum の中核。

## 前提 (consume するもの)

- 直近 2 week の Daily loop output (alert / anomaly)
- 直近 2 week の Weekly loop output (memory health / cookbook / Concept review)

これらが既に raw signal を吸い上げている前提で、 biweekly は **synthesis + cross-layer**。

## Checklist (8 セクション、 ~75 min)

### A. Plugin (claude-plugin-creo-memories) ~10 min

- [ ] `git log --since='2 weeks ago' --oneline` で commit 確認
- [ ] open PR / Issue 数 (gh)
- [ ] SKILL.md word count + tool 言及数 (proxy: navigability)
- [ ] 11-tool redesign progress (api-redesign.md update 必要か)
- [ ] cookbook drift (各 cookbook が最新 API と整合)
- [ ] templates 利用度 (memory 内で template 由来の structure 検出)

### B. 本体 (mcp.creo-memories.in) ~10 min

- [ ] `mcp__creo-memories__system_health()` で health 詳細
- [ ] open issue / PR の age 分布
- [ ] dependency drift (`bun outdated` 等)
- [ ] CI green rate (last 14 day)
- [ ] perf metric trend (latency / 5xx rate)
- [ ] new tool 追加か deprecation 進捗

### C. Documentation drift ~10 min

- [ ] SKILL.md 内 tool name で `mcp__creo-memories__*` 言及 → 全 tool 存在確認 (`tool/list` MCP)
- [ ] reference/* 内部 link 全 resolve 確認 (markdown link checker)
- [ ] README v0.X What's New section が latest と一致
- [ ] cookbook example の API call が最新 schema 準拠
- [ ] decision-tree.md / anti-patterns.md / scenes/* が陳腐化していないか

### D. External integrations ~10 min

- [ ] Linear API connectivity test (`mcp__linear-chronista__list_teams`)
- [ ] GitHub OAuth: token 有効性
- [ ] Auth0 cert: 有効期限 (>30 day 残)
- [ ] external MCP servers (claude-in-chrome / browser-use 等) status check
- [ ] webhook health (subscribe_memories の event 配信 status)

### E. Memory quality (meta) ~10 min

- [ ] Local Layer 1: file count + last modified 分布
- [ ] Cloud Layer 2: `mcp__creo-memories__memory_health()` full
- [ ] Stale ratio (>90 day not referenced)
- [ ] Type 分布 (project / feedback / user / reference の偏り)
- [ ] Atlas distribution (orphan memory or heavy concentration)
- [ ] Concept hierarchy: 重複 / inconsistency

### F. Usage / activation metrics ~10 min

- [ ] Hook fire rate (PreToolUse Write / UserPromptSubmit) — passive observation log
- [ ] accepted/ignored 比 (objective: hook が behavior change している?)
- [ ] cookbook 参照頻度 (proxy: search で cookbook 名 hit 数)
- [ ] 4-scene 別 tool 使用率 (`/memories` / `/atlas` / `/views` / `/actions`)
- [ ] under-used tool top 10 (deprecation candidate)

### G. Improvement candidates synthesis ~10 min

A-F の各 finding を **ICE prioritization** で score:

| ID | Source | Title | I | C | E | I×C×E | Verdict |
|---|---|---|---|---|---|---|---|
| imp-001 | A.SKILL.md | tool 言及数を 70 → 50 に削減 | 5 | 4 | 3 | 60 | **now** |
| imp-002 | B.dep drift | bun lock outdated | 3 | 5 | 4 | 60 | **now** |
| imp-003 | E.stale | 古い session-recap memory archive | 2 | 5 | 5 | 50 | next-cycle |
| imp-004 | F.under-used | concept_replace_for_memory 未使用 | 2 | 3 | 2 | 12 | drop (low value) |

- **Score >= 60** → now (本 session で実装)
- **Score 25-59** → next-cycle (Issue 化、 次 biweekly で再評価)
- **Score < 25** → drop (drop reason 明記)

### H. Action chain closure & Output ~5 min

- [ ] **now** verdict → 即実装 (本 loop session で patch + PR or memory action)
- [ ] **next-cycle** → Linear issue 起票 OR memory に積む
- [ ] **drop** → drop reason memo + archive

#### Output: Loop Dashboard 更新

```typescript
// 1. dashboard を search
mcp__creo-memories__search({ query: 'Creo Memories Improvement Dashboard', limit: 1 })

// 2. body rolling update + update_memory
mcp__creo-memories__update_memory({
  id: dashboard.id,
  content: <updated body with new entry, rolling 10 件保持>
})

// 3. 詳細 memory 作成
mcp__creo-memories__remember({
  content: `# Biweekly Loop YYYY-MM-DD

## Findings (ICE-ranked)
{table}

## Action chain
- now: {N items} → 実装済 / PR draft
- next-cycle: {N items} → Linear issue / memory pending
- drop: {N items} → reason memo

## Convergence
- prev: {N findings}, this: {M findings}, trend: ↑/↓/→

## Notes for next cycle
- ...
`,
  category: 'learning',
  conceptIds: ['biweekly-loop', 'YYYY-MM-DD'],
  atlasId: 'meta'
})
```

## 重要原則

- **75 min 厳守**: scope 内に収めるため、 deep dive は detail memory + next-cycle に分離
- **ICE score を必ず明示**: subjective「気になる」を許さず、 mechanical filter
- **action chain mandatory**: 全 finding に now/next/drop verdict
- **convergence trend を毎回 update**: dashboard で履歴 trace

## 関連

- [Daily loop (raw signal)](daily.md)
- [Weekly loop (focused)](weekly.md)
- [Quarterly loop (strategic + meta)](quarterly.md)
- [Dashboard Pattern](dashboard-pattern.md)
- [Cookbook: cycle-close](../cookbooks/cycle-close.md)
