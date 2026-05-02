# <Epic 名> Phase <N> 完了

> Layer 2 cloud memory として保存。 cookbook: `../cookbooks/phase-completion.md`

## 実装 summary

- <成果物 1>
- <成果物 2>
- <成果物 3>

## 結果 metric

- PR merged: #<XXX> (commit `<sha>`)
- Test result: ✓ (X passed / Y skipped / 0 fail)
- 工数: <actual> (estimate: <estimate>)
- Trade-off / known limitation: ...

## Phase 内で確定した decision

- <決定 1>: 詳細 mem_xxx
- <決定 2>: 詳細 mem_yyy

## 次 phase 対応事項

- <未着手 task 1>
- <未着手 task 2>
- 既知 issue (別 Issue 起票): <Linear-XXX>

## 関連

- Linear issue: <CREO-XXX>
- 親 Epic: <Linear-YYY>
- 関連 memory: ...

---

## remember + link_external 呼び出し例

```
mcp__creo-memories__remember({
  content: <上記 markdown>,
  category: 'task',
  status: 'done',
  atlasId: '<project>',
  conceptIds: ['phase-completion', '<phase tag>']
})

mcp__creo-memories__link_external({
  memoryId: <returned id>,
  externalSystem: 'linear',
  externalId: 'CREO-XXX',
  externalUrl: '...'
})

mcp__creo-memories__link_external({
  memoryId,
  externalSystem: 'github',
  externalId: 'PR-XXX',
  externalUrl: '...'
})
```

Process 化 (cookbook 参照):
```
mcp__creo-memories__create_process({
  name: '<Epic 名>',
  memoryIds: [phase1Id, phase2Id, ...]
})
```
