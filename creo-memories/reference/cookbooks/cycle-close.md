# Cookbook: Cycle Close (週次 / sprint 終了)

Linear cycle / scrum sprint / 1 週間 / 月次の **節目** で memory を整理する flow。

## いつ発火するか

- Linear cycle の close (週次)
- Sprint review / retrospective の前
- 月次の振り返り
- Quarter / Phase 切替

## 一連の手順

### 1. 期間内の活動 review

`/views` scene。

```
mcp__creo-memories__get_profile()
// → 直近活動 / Concept 分布 / 頻繁参照 memory

mcp__creo-memories__project_progress({ atlasId })
// → 完了率 / 進捗 bar / open task

mcp__creo-memories__list_todos({ groupBy: 'status' })
// → done / in-progress / open
```

### 2. Compass を auto-generate

Atlas 全体の summary を LLM 生成:

```
mcp__creo-memories__generate_compass({ atlasId })
// → Concept 別グルーピング + 全体概要
```

これが cycle close の **canonical snapshot**。 memory として残す:

```
mcp__creo-memories__remember({
  content: `# {Atlas 名} Compass — {YYYY-WNN}

{generate_compass output}

## Highlights
- 完了 phase: ...
- 未完 task: ...
- 新規追加 concept: ...
`,
  category: 'learning',
  conceptIds: ['cycle-close', '{cycle id}'],
  atlasId
})
```

### 3. 完了 task / phase の Process 化

`/views` scene。 cycle 内で完了した chain を Process として束ねる:

```
mcp__creo-memories__detect_processes()
// 候補が出る (3 件以上の連結 chain)

mcp__creo-memories__create_process({
  name: '{cycle 名} 完了 process',
  memoryIds: [...],
  description: '...'
})
```

### 4. health audit

`/views` scene。

```
mcp__creo-memories__memory_health()
// → stale / broken-link / 偏り
```

stale memory が出たら:
- 不要 → `remove({ resource:'memory', id, mode:'soft' })` で status:cancelled
- 価値 → 内容 update / supersede

### 5. 未昇格 ephemeral memory の処遇

session 中の ttl memory で価値あるものを昇格:

```
mcp__creo-memories__update_memory({
  id: 'mem_xxx',
  ttl: null  // 永続化
})
```

### 6. team 同期 (該当時)

```
mcp__creo-memories__list_subscriptions()
mcp__creo-memories__check_notifications({ limit: 50 })  // drain
```

team 共有 atlas の最新を取り込む。

### 7. work_log review

`/actions` scene。 cycle 内の inter-agent comm を review:

```
mcp__creo-memories__search_work_logs({
  fromDate: cycle_start,
  toDate: cycle_end
})
```

decision に格上げすべき log を memory 化。

## 出力物

cycle close で生成する artifact:

| artifact | 種類 |
|---|---|
| Compass memory (cycle snapshot) | Layer 2 cloud |
| Process memory (completed chains) | Layer 2 cloud |
| 健全性 report | (transient、 必要なら memory 化) |
| 未昇格 promotion | 既存 memory の ttl: null |

## Real example: 2026-W17 cycle close (想定)

```
- get_profile + project_progress で「Phase 1+2 完了」確認
- generate_compass で chronista-club Atlas snapshot
- create_process で「CREO-103 phase 1→2」chain 化
- memory_health で stale 5 件発見、 3 件 cancel / 2 件 update
- work_log review で「mito の review feedback」を decision memory に格上げ
```

## Best practice

- **cycle close は memory 化を必ず行う** — 後で「何が達成された?」 を 1 query で出せる
- **Process 化で物語を作る** — 単独 memory より narrative 化された Process の方が後の人に伝わる
- **stale 整理は cycle 終わりに** — daily に追わず、 weekly batch で

## 派生

- cycle で大きな決定 → `cookbooks/decision-record.md` 併用
- cycle 末の bug fix → `cookbooks/bug-fix.md` 併用
- 新 cycle 開始時の onboarding → `cookbooks/onboarding.md` 連動
