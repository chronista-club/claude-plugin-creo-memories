# Self-Improvement Loop

Creo Memories ecosystem (plugin / 本体 mcp.creo-memories.in / docs / CLI / API / external integrations / agent skill 自身) を **周期的に self-audit** して improvement candidate を抽出 → action item 化する仕組み。

## 設計原則 (8 axiom)

1. **Hierarchical cadence**: daily → weekly → biweekly → quarterly の各 cadence は **下位 cadence の output を consume** する。 single 段で run すると cost が scale しない
2. **Loop Dashboard pattern**: 1 つの rolling memory で全 cadence の output を集約 (散発 memo は noise 化、 rolling state の方が navigate 可能) — [pattern 詳細](dashboard-pattern.md)
3. **ICE prioritization**: 全 finding を Impact × Confidence × Ease で score (各 1-5)、 「あった方が良い」を mechanically filter
4. **Incident-triggered ad-hoc**: production critical event / 重大 bug / 大 migration は時間 trigger 待たず即 fire
5. **Meta-loop**: 価値出していない loop は drop。 quarterly で loop 自身を audit (anti-pattern: ritual without value)
6. **Convergence behavior 観測**: 「per-loop 検出数」 trending up = system degrading、 down = healthy or scope 過狭 → 戦略 adjust
7. **Counterfactual retrospective**: quarterly で「あの時こう loop 走らせていたら何が違ったか?」 sanity check
8. **Action chain closure**: 全 candidate に **now / next-cycle / drop** verdict mandatory。 「maybe later」 を許さない

## 4 cadences (粒度の異なる observation)

| Cadence | 工数 | 主目的 | Consumes | Outputs |
|---|---|---|---|---|
| **Daily** (1 day) | ~5 min | 軽い health check | (raw signal) | 異常 alert |
| **Weekly** (7 day) | ~20 min | 集中 review (memory health / cookbook 利用度) | daily の week 分 | weekly summary memory |
| **Biweekly** (14 day) — **primary** | ~75 min | ecosystem 全体 review | weekly × 2 + raw | improvement candidates ranked |
| **Quarterly** (90 day) | ~3 h | 戦略的 review + meta-loop audit | biweekly × 6 | breaking change planning + loop adjust |

詳細 checklist:
- [Daily](daily.md)
- [Weekly](weekly.md)
- [Biweekly (primary)](biweekly.md)
- [Quarterly](quarterly.md)
- [Dashboard Pattern](dashboard-pattern.md) — 全 cadence 共通の output 集約 pattern
- [Incident-triggered protocol](incident-triggered.md) — 緊急 ad-hoc loop

## Trigger 機構 (4 way)

### 1. Manual via slash command

```
/creo-memories:improvement-loop [cadence]
```

ユーザーが任意のタイミングで invoke。 cadence 引数省略時は biweekly default。

### 2. SessionStart hook reminder (passive nudge)

session 開始時、 Loop Dashboard を check して経過日数判定:
- 14 day 超 → 「Biweekly improvement loop が overdue」 nudge
- 7 day 超 → Weekly loop nudge
- 1 day 超 → Daily loop nudge (optional)

実装は `hooks/hooks.json` の `SessionStart` で memory query → 判定。

### 3. Cron schedule (autonomous)

Claude Code の `/loop` or `schedule` skill で定期 invoke:

```
schedule: every 14 days at 09:00 → /creo-memories:improvement-loop biweekly
schedule: every 1 day at 06:00 → /creo-memories:improvement-loop daily
```

agent が無人で実行 → Loop Dashboard memory 更新 → 次回 user session で確認。

### 4. Incident-triggered (ad-hoc)

production critical event / 重大 bug / 大 migration が発生 → 時間 trigger 待たず:

```
/creo-memories:improvement-loop --incident "<event description>"
```

Daily / Weekly / Biweekly / Quarterly の混合 checklist (重要 item のみ pick) で即 audit。 詳細 [`incident-triggered.md`](incident-triggered.md)。

## ICE Prioritization (全 cadence 共通)

各 improvement candidate を 1-5 score:

| Axis | 意味 |
|---|---|
| **Impact** | 解消した時の効果 (高=ecosystem 全体に benefit、 低=局所 fix) |
| **Confidence** | この改善で実際に効果が出ると確信できるか (高=実証済 pattern、 低=hypothesis) |
| **Ease** | 実装コスト (高=1h で完結、 低=major refactor) |

`Score = I × C × E` (max 125、 min 1)

- **Score >= 60** → now (即実装)
- **Score 25-59** → next-cycle (次 cadence で実施)
- **Score < 25** → drop or defer to quarterly

各 cadence の output で必ず ICE 表を含める。

## Convergence 観測

各 cadence で **発見数 / accepted action 数** を memory に記録、 trend 分析:

- 発見数 trending up over 3 cycle → ecosystem degrading or scope drift。 quarterly で fundamental review
- 発見数 trending down → healthy or loop scope 過狭。 scope 拡大 OR 安心して cadence 緩和
- accepted/total 比 < 30% → loop が noise 生成、 quality bar 上げる
- accepted/total 比 > 80% → quality 高い、 維持

## Action chain closure (mandatory)

全 finding に必ず verdict:

1. **now** — 本 loop session 中に即修正 (typo / link / small fix)
2. **next-cycle** — 次 cadence の loop で実施 (memory or Linear issue 化)
3. **drop** — 価値小 / 陳腐化 / 不要、 archive 確定 (drop reason を必ず明記)

「maybe later」 「TBD」 等は **明確に禁止**。 「next-cycle」 と「drop」 は明示的選択。

## Output: Loop Dashboard

各 loop 実行で **Loop Dashboard memory** を rolling update:

```
Title: Creo Memories Improvement Dashboard
Atlas: meta
Type: project (Layer 2)
Visibility: public
```

詳細 structure: [`dashboard-pattern.md`](dashboard-pattern.md)

これにより:
- 「最新の loop 結果」が 1 memory で見える
- cadence 別 history が単一 timeline で navigate 可能
- convergence trend が memory 内で trace 可能
- session start で「dashboard 1 件 read」 だけで状態把握

## 関連

- [Slash command `/creo-memories:improvement-loop`](../../../commands/improvement-loop.md)
- [skill `cookbooks/cycle-close.md`](../cookbooks/cycle-close.md) — biweekly loop と類似の cycle 末 action
- (Layer 1 memory) `creo-memories-self-improvement-loop.md` — 本機能の design decision (本 plugin の root rationale)
