# Cookbook: Phase / Sprint 完了

Multi-phase Epic (例: CREO-103 5-phase migration) の 1 phase が完了した時の memory 操作。

## いつ発火するか

- PR が merge された (大型 Epic の sub-phase)
- Sprint / Cycle で 1 milestone を達成
- 設計の段階確定 (Phase 0 foundation done 等)

## 一連の手順

### 1. Phase 完了 memory を作成

`/memories` scene。 cloud に project trace として保存。

```
mcp__creo-memories__remember({
  content: `# {Epic 名} Phase {N} 完了

## 実装 summary
- {成果物 1}
- {成果物 2}

## 結果 metric
- PR merged: #XXX (commit YYY)
- Test result: ✓
- 工数: {actual} (estimate: {estimate})

## 次 phase での対応事項
- {残課題}

## 関連
- Linear issue: ...
- 関連 memory: mem_xxx, mem_yyy
`,
  category: 'task',
  status: 'done',
  atlasId,
  conceptIds: [/* phase tag 等 */]
})
```

### 2. Linear と pair link

`/actions` scene。 PR と Linear ticket に memory ID 紐付け。

```
mcp__creo-memories__link_external({
  memoryId,
  externalSystem: 'linear',
  externalId: 'CREO-XXX',
  externalUrl: 'https://linear.app/.../CREO-XXX'
})
mcp__creo-memories__link_external({
  memoryId,
  externalSystem: 'github',
  externalId: 'PR-XXX',
  externalUrl: 'https://github.com/.../pull/XXX'
})
```

### 3. Process として narrative 化

`/views` scene。 phase 1 → 2 → 3 ... の chain を Process で可視化。

```
mcp__creo-memories__detect_processes()
// 候補が出たら
mcp__creo-memories__create_process({
  name: '{Epic 名}',
  memoryIds: [phase1Id, phase2Id, ...],
  description: '...'
})
```

### 4. 関連 work_log を flush

`/actions` scene。 phase 中の inter-agent comm が残っていれば persist。

```
mcp__creo-memories__record_work_log({
  type: 'progress',
  sender: 'mako',
  content: 'Phase {N} done.',
  projectId,
  relatedMemoryId
})
```

### 5. (任意) Linear ticket comment 追加

`/actions` scene 隣接。 Linear ticket に memory ID + summary を追記して trace 双方向化。

## Real example: CREO-103 Phase 1 (この session で実行)

```
Phase 1 完了:
1. PR #351 merge (commit 9b72ea9c)
2. Linear comment 追加 (本 session で実行済)
3. (本来 done すべき) cloud remember を本 cookbook 採用後に retroactively 追加可能
```

→ phase 単位で「**1 motion で完結**」する pattern が確立される。
