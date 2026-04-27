# ADR-<N>: <Title>

> Layer 2 cloud memory として `mcp__creo-memories__remember` で保存する template。
> 詳細 cookbook: `../cookbooks/decision-record.md`

## Status

`proposed` | `accepted` | `superseded by ADR-<X>` | `deprecated`

## Context

<なぜこの判断が必要か。 制約、 状況、 stakeholder>

## Decision

<何を採用するか。 具体的に>

## Rationale

<なぜそれを選んだか。 alternatives との比較における優位>

## Consequences

- 良い結果: <期待される positive impact>
- 悪い結果: <trade-off、 受け入れる cost>
- 影響範囲: <code / 他システム / chain>

## Alternatives Considered

- **Option A**: <内容> — pros: ... / cons: ... / 不採用理由: ...
- **Option B**: <内容> — pros: ... / cons: ... / 不採用理由: ...

## References

- 関連 memory: mem_xxx, mem_yyy
- 関連 PR / Issue: ...
- 関連 ADR: ADR-<M> (extends / supersedes)

---

## remember 呼び出し例

```
mcp__creo-memories__remember({
  content: <上記 markdown>,
  category: 'decision',
  status: 'done',  // proposed なら 'in-review'
  atlasId: '<project>',
  conceptIds: ['adr', '<domain>'],
  visibility: 'public'  // team が読める
})
```

supersede 時は:
```
mcp__creo-memories__remember({
  content: <markdown>,
  supersedes: ['mem_old_adr']
})
```
