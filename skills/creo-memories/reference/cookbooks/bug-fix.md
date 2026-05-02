# Cookbook: Bug Fix

bug の根本原因 + 解決策が確定した時の memory 操作。

## いつ発火するか

- bug の root cause を特定した
- fix の PR を出した / merge した
- regression 防止策を memory として残したい

## 一連の手順

### 1. bug 知見を memory として保存

`/memories` scene。

```
mcp__creo-memories__remember({
  content: `# {Bug 簡潔タイトル}

## 症状
{observe された症状、 stack trace、 reproduction steps}

## 原因
{root cause、 specifically 何が壊れていたか}

## 解決策
{何を fix したか}

## 再発防止
- {予防策 1: 例えば test、 lint rule}
- {予防策 2}

## 関連
- PR: ...
- 関連 memory: ...
`,
  category: 'debug',
  status: 'done',
  atlasId,
  conceptIds: ['bug', '{tech stack tag}']
})
```

### 2. Linear / GitHub link

`/actions` scene。

```
mcp__creo-memories__link_external({
  memoryId,
  externalSystem: 'linear',
  externalId: 'CREO-XXX',
  externalUrl
})
mcp__creo-memories__link_external({
  memoryId,
  externalSystem: 'github',
  externalId: 'PR-XXX',
  externalUrl
})
```

### 3. (任意) related memory に annotate

既存 memory が原因と関連していれば `annotate` で thread を作る。

```
mcp__creo-memories__annotate({
  memoryId: 'mem_related',
  kind: 'concern',  // or 'comment'
  content: 'Bug {ID} の原因がここに繋がっていた。 修正済み (mem_fix を参照)'
})
```

### 4. Pre-save Detection を信頼

`remember` 時に similar bug memory が proposal される。 過去類似事例なら supersede / extend を検討:

```
mcp__creo-memories__remember({
  content: '...',
  supersedes: ['mem_old_bug_attempt'],  // 過去 fix が不完全だった場合
  // または
  extends: ['mem_root_cause_pattern']    // 同じ根本原因 pattern の延長
})
```

## Real example: CREO-132 (filterByRange flaky test)

session 内の actual:
```
- Symptom: filterByRange("week") が 2026-04-27 以降 fail
- Root cause: fixedNow が rangeStart に渡されていない (DI chain 切れ)
- Fix: API に now? param 追加
- Linear: CREO-132 (Done、 PR #351 で同梱 fix)
- GitHub: PR #351 commit a713174f
```

本 cookbook 採用後の cloud remember:
```
remember({
  content: `# filterByRange("week") date-flaky test
  ...
  `,
  category: 'debug',
  status: 'done',
  atlasId: 'creo-memories',
  conceptIds: ['flaky-test', 'date-handling', 'DI-pattern']
})
+ link_external (Linear CREO-132, GitHub PR #351)
```

## 派生

- bug fix が ADR 級 (architectural impact) なら → `cookbooks/decision-record.md` も併用
- multi-stage bug (複数 PR で段階 fix) なら → `cookbooks/phase-completion.md` の Process 化を組合せ
