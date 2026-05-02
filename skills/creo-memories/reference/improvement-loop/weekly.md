# Weekly Improvement Loop (~20 min)

集中 review。 memory health 詳細 + cookbook 活用度 + Atlas 整理。

## Checklist

### A. Memory health 詳細 (~5 min)

- [ ] `mcp__creo-memories__memory_health()` 実行 + report 全文 review
- [ ] stale memory: 50+ ある場合は `forget` or `update_memory(status: 'cancelled')` で整理
- [ ] type 分布: project / feedback / user / reference の比率が偏っていないか
- [ ] Atlas 分布: 1 atlas に集中 / flat 化していないか

### B. 自分の活動 profile (~3 min)

- [ ] `mcp__creo-memories__get_profile()` で直近 week
- [ ] 頻繁参照 memory が真に最新か (drift していないか)
- [ ] 新規作成の type 比 (Layer 1 vs Layer 2 の作りすぎ偏り)

### C. project progress (~3 min)

- [ ] 主要 atlas で `mcp__creo-memories__project_progress({ atlasId })`
- [ ] 完了率 trend (前 week 比)
- [ ] in-progress で停滞している memory (status:in-progress 7 日以上 update なし)

### D. cookbook / 4-scene 活用度 (~3 min)

agent 視点で振り返り:

- [ ] PreToolUse(Write) hook が fire した回数 + accept/ignore 比 (目視)
- [ ] decision keyword hook が fire した回数 + 実 remember 化 比
- [ ] 各 cookbook (phase-completion / bug-fix / decision-record / cycle-close) の参照頻度
- [ ] 4-scene 別 tool 使用率 (`/memories` `/atlas` `/views` `/actions` のどれが under-used か)

### E. Concept hierarchy review (~2 min)

- [ ] `concept_list` で重複 concept を発見
- [ ] 命名 inconsistency (`priority:high` vs `high-priority`) の整理
- [ ] kind 別バランス (label / category / tag)

### F. Process / Compass 生成 (~3 min)

- [ ] 完了した chain があれば `detect_processes` → `create_process`
- [ ] week 末 snapshot として `generate_compass({ atlasId })`

### G. Improvement candidates synthesis (~1 min)

- [ ] 上記 A-F から「来 week でやる 1-2 件」を pick
- [ ] biweekly loop 候補に lift up 必要な事項を memo

## Output

```
mcp__creo-memories__remember({
  content: `# Weekly loop YYYY-WNN

## Findings
- {memory health の summary}
- {profile の summary}
- {progress の summary}

## Improvement candidates (来 week)
1. {candidate 1}
2. {candidate 2}

## Biweekly loop 引き継ぎ
- {longer-cycle item}
`,
  category: 'learning',
  conceptIds: ['weekly-loop', 'YYYY-WNN'],
  atlasId: '<creo-memories-meta>',
  ttl: 1209600  // 2 week 後 expire (biweekly loop が引き継ぐ)
})
```
