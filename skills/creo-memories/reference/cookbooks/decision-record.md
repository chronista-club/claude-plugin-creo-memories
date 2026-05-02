# Cookbook: Decision Record (ADR style)

設計判断 / architectural choice を ADR 風に記録する flow。

## いつ発火するか

- 「これで決定」「この方針で行く」 確定表現
- architectural choice (DB / framework / pattern)
- 撤回不能なまでの判断 (例: data model 変更、 deploy strategy)
- multi-stakeholder 議論を経た合意

## 一連の手順

### 1. Decision tree で layer を判定

`/memories` scene。 不変方針なら Layer 1、 ある時点 (project 内 phase) の決定なら Layer 2。

ADR は「project の trace」 = Layer 2 (cloud) が default。

### 2. ADR memory 作成

```
mcp__creo-memories__remember({
  content: `# ADR-{N}: {Title}

## Status
{proposed | accepted | superseded by ADR-X | deprecated}

## Context
{なぜこの判断が必要か、 制約、 状況}

## Decision
{何を採用するか、 具体的に}

## Rationale
{なぜそれを選んだか、 alternatives との比較}

## Consequences
- 良い結果: {期待される positive impact}
- 悪い結果: {trade-off、 受け入れる cost}
- 影響範囲: {コード / chain / 他システム}

## Alternatives Considered
- Option A: {pros/cons}
- Option B: {pros/cons}

## References
- 関連 memory: ...
- 関連 PR / Issue: ...
`,
  category: 'design',
  status: 'done',
  atlasId,
  conceptIds: ['adr', '{domain tag}'],
  visibility: 'public'  // team / org で読める
})
```

### 3. supersede chain (ADR が ADR を置き換える時)

```
mcp__creo-memories__remember({
  content: '# ADR-N+1: ...',
  category: 'design',
  supersedes: ['mem_old_adr']  // ADR-N を 破 (ha) stage に
})
```

`get_relations` で supersede chain navigate 可能。

### 4. ADR file (docs/adr/) との同期

実 file (`docs/adr/ADR-005.md` 等) を持つ場合、 `link_external` で双方向 trace:

```
mcp__creo-memories__link_external({
  memoryId,
  externalSystem: 'github',
  externalId: 'docs/adr/ADR-005.md',
  externalUrl: 'https://github.com/.../blob/main/docs/adr/ADR-005-...md'
})
```

### 5. 関連 memory に annotate

ADR が既存 memory に影響するなら、 当該 memory に `annotate(kind:'concern')` で thread:

```
mcp__creo-memories__annotate({
  memoryId: 'mem_affected',
  kind: 'concern',
  content: 'ADR-{N} ({title}) で本決定が改訂されました。 mem_adr_new を参照。'
})
```

### 6. team 共有 (ADR は通常 public)

```
mcp__creo-memories__update_memory({
  id: memoryId,
  visibility: 'public'
})
mcp__creo-memories__share_atlas({
  atlasId,
  teamId,
  permission: 'read'
})
```

## Real example: chronista-hub PR #8 の ADR-005..015 (今 session で見た)

```
chronista-hub の PR #8 で 11 個 ADR (ADR-005 〜 015) が同時起票:
- ADR-005 tombstone + GDPR purge
- ADR-006 scope granularity
- ADR-007 dangling refs + vp-actor
- ...

これらは memory model 上では:
- 各 ADR を 1 memory として remember (category:'design')
- chronista-hub Atlas 配下に classify
- mem_xxx_adr_005 が PR #8 と link_external で双方向
- supersedes は無 (新規)
- ADR file (docs/adr/ADR-005-tombstone-and-gdpr.md) と link
```

## Best practice

- **status を必ず付ける** (`proposed` / `accepted` / `superseded` / `deprecated`)
- **alternatives を必ず書く** (考えた選択肢を残すと後の人が判断 trace 可能)
- **超えたら supersede chain** (rewrite で破壊しない)
- **annotate で議論を残す** (concern → 別 ADR に発展可能)

## 派生

- ADR が cycle level の意思決定 → `cookbooks/cycle-close.md` も併用
- ADR が phase 完了の一部 → `cookbooks/phase-completion.md` Process に内蔵
