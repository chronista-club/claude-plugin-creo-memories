# Quarterly Improvement Loop (~3 hours) — STRATEGIC + META

90-day 単位の **戦略的 review** + **loop 自身の audit** (meta-loop)。 biweekly loops の output を集約 → fundamental directions decide。

## 前提 (consume するもの)

- 直近 quarter の biweekly loop output × 6 件 (= ~12 weeks)
- Loop Dashboard 全 history
- 主要 Linear cycle / GitHub release history

## Checklist (10 セクション、 ~3 hours)

### A. Quarter retrospective ~20 min

- [ ] 主要 release: 何が ship したか (plugin / 本体 / docs)
- [ ] 主要 decision: ADR / foundational memory が何件、 内容
- [ ] 主要 incident: production issue / 大規模 migration の有無
- [ ] 達成 vs goal: quarter の冒頭で立てた目標と実態

### B. Convergence trend (cross-cycle) ~15 min

biweekly Loop Dashboard の history を visualize:

- [ ] Findings/cycle: 6 cycle の trend
- [ ] Accepted/total ratio: trend
- [ ] Cadence 別 health (daily が無音続き = 深刻 OR scope 過狭)
- [ ] Convergence behavior:
  - trending up: ecosystem degrading → fundamental review needed
  - trending down: healthy or scope narrow → 拡大 OR 緩和
  - oscillating: 課題 surface↔fix を繰り返している、 要 root cause

### C. Architecture-level review ~20 min

- [ ] **2-layer architecture** が想定通り機能しているか?
  - Layer 1 / Layer 2 比率
  - 「迷ったら Layer 2」 default が守られているか
  - federation 必要性が顕在化したか
- [ ] **4-scene mental model** の効果?
  - 各 scene 別 tool 使用率
  - under-used scene
  - missing scene 候補
- [ ] **70 → 11 tool redesign** progress
  - design phase 完了か
  - server-side implement 計画
  - migration phase 移行 timing

### D. Foundational memory review ~15 min

- [ ] Layer 1 foundational memory (memory-stage-contract / 2-layer-architecture / etc.) が陳腐化していないか
- [ ] 過去 quarter で superseded すべき principle が無いか
- [ ] 新規 foundational principle (今 quarter で確立) が必要か

### E. External ecosystem review ~20 min

- [ ] Linear / GitHub / Auth0 / Discord MCP 等の health
- [ ] 新 external integration の opportunity (Slack / Notion / Calendar 等の検討)
- [ ] deprecate すべき integration

### F. **Meta-loop audit** ~30 min

loop 自身を loop で audit。 重要 section。

- [ ] 各 cadence (daily / weekly / biweekly / quarterly) の **value 評価**:
  - daily: 平均何件 alert したか、 そのうち true positive 比?
  - weekly: 発見した improvement candidate のうち next-cycle accept された比
  - biweekly: action chain closure 率 (drop verdict 含む)
  - quarterly: 本 quarterly 自体の effort vs benefit
- [ ] **Drop 候補** (価値出していない loop):
  - daily が 90 day alert 0 件 → drop or scope 広げる
  - weekly が biweekly に吸収可能なら廃止
- [ ] **Cadence adjust 候補**:
  - 14 day → 7 day or 30 day で十分?
  - 1 day → 3 day で sufficient?
- [ ] **新 cadence 追加** 候補:
  - monthly retrospective (30 day) を biweekly と quarterly の間に挟む?
  - hourly / on-demand monitor (continuous) 必要?

### G. Counterfactual retrospective ~15 min

「あの時こう loop 走らせていたら何が違ったか?」 で loop 感度 sanity check:

- [ ] 過去 quarter で起きた surprise / unexpected outcome を 3 件 list
- [ ] それぞれについて: 「earlier loop で detect 可能だったか?」 yes/no/partial
- [ ] yes → loop に signal 追加
- [ ] no → loop の限界、 別 mechanism (incident-triggered ad-hoc) で補完

### H. Strategic direction ~30 min

- [ ] Next quarter の theme 設定 (e.g. 「Performance & Activation」)
- [ ] Major version planning (v0.X → v0.Y で何を ship、 v1.0 timing)
- [ ] Breaking change candidate (deprecate / removal の planning)
- [ ] Foundational decision pending (ADR 起票 timing)

### I. Loop self-improvement (meta-meta) ~10 min

- [ ] 本 quarterly checklist 自体が cumbersome / scope 過大なら scope 縮小
- [ ] 新 section 追加候補
- [ ] 削除 section 候補

### J. Action chain closure & Output ~5 min

- [ ] **now** verdict → 即実装 / PR draft
- [ ] **next-cycle** → next quarterly に持ち越し OR Linear epic 起票
- [ ] **drop** → reason memo + archive
- [ ] **Strategic decision** → ADR memory 起票 (`cookbook/decision-record.md` 参照)

#### Output

1. **Loop Dashboard** quarterly section 更新
2. **Quarter retrospective memory**:
```
mcp__creo-memories__remember({
  content: `# Quarterly Loop YYYY-QN

## Retrospective
- 主要 ship: ...
- 主要 decision: ...
- 主要 incident: ...
- 達成 vs goal: ...

## Convergence (cross-cycle)
{trend chart description}

## Architecture review
- 2-layer: ...
- 4-scene: ...
- 70→11: ...

## Meta-loop audit
- daily value: ...
- weekly value: ...
- biweekly value: ...
- adjust: ...

## Counterfactual
- {surprise 1} → could have detected? {analysis}

## Next quarter strategic direction
- Theme: ...
- Major version target: ...
- Foundational decisions: ...
`,
  category: 'learning',
  conceptIds: ['quarterly-loop', 'retrospective', 'YYYY-QN'],
  atlasId: 'meta',
  visibility: 'public'
})
```
3. **ADR memories** for any architectural decisions
4. **Linear epic** for next quarter theme

## 重要原則

- **3-hour 厳守**: 厳しい時間制約、 deep dive は別 session に分離
- **meta-loop 必須**: loop 自身が「ritual without value」化していないか毎 quarter audit
- **counterfactual** で sanity check: 検出感度の health チェック
- **strategic decision は ADR 化**: quarterly で決まる方向性は memory に焼く

## 関連

- [Self-improvement loop](README.md)
- [Biweekly loop (consumed by this)](biweekly.md)
- [Dashboard Pattern](dashboard-pattern.md)
- [Cookbook: decision-record](../cookbooks/decision-record.md)
