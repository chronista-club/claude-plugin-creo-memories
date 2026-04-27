# Incident-triggered Ad-hoc Loop

production critical event / 重大 bug / 大 migration が発生した時、 時間 trigger を待たず即 fire する **緊急 loop**。

## 発火 trigger

- production downtime / 5xx spike
- data loss / corruption の suspect
- security incident (token leak / 不正 access)
- 大規模 migration の failure / partial-apply
- 主要 external integration の outage (Linear / Auth0 等)

## 起動方法

```
/creo-memories:improvement-loop --incident "<event description>"
```

例:
```
/creo-memories:improvement-loop --incident "Auth0 cert expired, login down 2026-04-28 14:30"
```

## Checklist (~30 min、 scope は biweekly の subset + 緊急 specific)

### A. Incident scope ~5 min

- [ ] 影響範囲: どの component (plugin / 本体 / external) が affected?
- [ ] 影響期間: 開始時刻、 検知時刻、 解消時刻 (rolling 中なら未確定)
- [ ] 影響規模: user 数、 session 数、 data 損失有無
- [ ] severity: P0 (data loss) / P1 (downtime) / P2 (degradation) / P3 (cosmetic)

### B. Root cause ~10 min

- [ ] 最近の変更 (deploy / config change / dependency update) 棚卸し
- [ ] log analysis (`mcp__creo-memories__search_logs` / `diagnose`)
- [ ] reproduction の再現性確認
- [ ] root cause 確定

### C. Containment + fix ~10 min

- [ ] 即 fix possible? → 実施
- [ ] rollback 必要? → revert 検討
- [ ] workaround の document 化
- [ ] migration 中なら maintenance mode 突入の検討

### D. Memory + trace ~5 min

- [ ] **postmortem memory** 起票 (Layer 2):
```
mcp__creo-memories__remember({
  content: `# Incident YYYY-MM-DD: {title}

## 概要
- severity: P0/P1/P2/P3
- 影響範囲: ...
- 期間: HH:MM 〜 HH:MM

## Symptom
{observation}

## Root cause
{cause}

## Fix
{action taken}

## Re-prevention
- {short-term: monitoring / alert 追加}
- {long-term: architecture / test 追加}

## Loop integration
- {次 biweekly loop での確認 item}
- {新 trigger 追加 candidate}
`,
  category: 'debug',
  status: 'done',
  atlasId: '<project>',
  conceptIds: ['incident', '<severity>', '{date}'],
  visibility: 'public'
})
```

- [ ] Linear / GitHub link で双方向 trace
- [ ] 関連 ADR 起票 (architectural fix なら)
- [ ] Loop Dashboard incident section 追加

### E. Loop signal feedback ~時間外

- 本 incident が「earlier loop で detect 可能だったか?」 を quarterly counterfactual で評価
- 検出可能なら loop signal 追加 (例: cert 有効期限を daily で check 等)
- 検出不可能なら incident-triggered protocol 改善

## 重要原則

- **fix を最優先**、 trace は二の次 (まず止血)
- **postmortem は必ず memory 化** (organizational learning)
- **loop signal feedback** で次回検出可能性向上
- severity 高い incident は **Quarterly retrospective** 必須 review item

## Anti-patterns

- ❌ 「忙しいから後で」 で memory 起票せず → 教訓喪失
- ❌ root cause 不明のまま fix のみ → 再発確実
- ❌ Loop Dashboard に記録せず → quarterly で見えない

## 関連

- [Self-improvement loop](README.md)
- [Cookbook: bug-fix](../cookbooks/bug-fix.md) — incident は通常 bug-fix の重大版
- [Cookbook: decision-record](../cookbooks/decision-record.md) — architectural fix は ADR 化
