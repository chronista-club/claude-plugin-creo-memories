# Cookbook: Memory を ID で fetch する

memory ID (`mem_xxxxx`) を持っているが、 内容を取りたい時の workaround。 **専用 tool 未実装** (v0.29 時点、 server-side 実装待ち) のため、 暫定的に search 等を駆使する。

## 状況: 直 fetch tool は存在しない

検証 (2026-04-28、 dogfood session):

- `get_provenance(memoryId)` — content の冒頭 **1 行 preview のみ** (graph 用設計)
- `get_relations(memoryId)` — 同様、 関係 graph 用
- `find_by_external` — 外部 ID (Linear/GitHub) 経由の逆引き、 memory ID 直は不可
- `update_memory(id, content)` — content 入力必須、 fetch にならない

→ **API gap**、 RFC v1 で `read({resource:'memory', id})` を提案、 server-side 着手予定 (Layer 2 memory `mem_1CaVwGZxyXADC2vg3PE5Qg` 参照)

## Workaround Pattern

### Pattern A — `search` の verbose mode (推奨)

ID と memory の **概要 keyword** が分かっている場合の最 reliable な fetch:

```
mcp__creo-memories__search({
  query: '<タイトル または 特徴的な keyword>',
  scope: 'all',           // public + private 両 search
  limit: 5,
  verbose: true,          // ← 重要: full content + metadata 含めて返す
  threshold: 0.5
})

// 結果から ID match する 1 件を pick
const target = result.memories.find(m => m.id === 'mem_xxxxx')
console.log(target.content)   // ← full markdown
```

**長所**: full content + metadata + tags + atlas 全部取れる、 認証込みで private も取れる
**短所**: keyword 推測必要、 semantic 似度 0 の場合 hit しない可能性

### Pattern B — Public memory なら HTTP fetch

memory が `visibility: 'public'` の場合、 認証不要で HTTP fetch 可能:

```bash
curl -s https://mcp.creo-memories.in/api/public/r/<memory_id>
# → JSON or markdown response
```

**例**: Loop Dashboard (`mem_1CaUpvQn4ok4M1SMivYEtZ`) は public、 ブラウザで `https://mcp.creo-memories.in/api/public/r/mem_1CaUpvQn4ok4M1SMivYEtZ` を開けば本文表示。

**長所**: 認証不要、 単純 GET、 cache 可能 (CDN)
**短所**: public 限定、 private は 403

### Pattern C — `get_provenance` で preview だけで足りる時

最初の 1 行 (タイトル) 確認だけで OK な時:

```
mcp__creo-memories__get_provenance({
  memoryId: 'mem_xxxxx',
  depth: 1
})
// → { nodes: [{ id, content: '# 冒頭 1 行 preview ...', ...}], mermaid }
```

**長所**: ID 直指定、 graph context も取れる
**短所**: content は 1 行 preview のみ

### Pattern D — `concept_get_by_memory` で metadata 確認

content そのものは要らず、 「この memory の Concept は?」を知りたい時:

```
mcp__creo-memories__concept_get_by_memory({
  memory_id: 'mem_xxxxx'
})
```

## Recommendation

| 状況 | 推奨 pattern |
|---|---|
| **full content 必要 + 認証あり** | A (search verbose) |
| **full content 必要 + public** | B (HTTP fetch) |
| **タイトル / preview だけで足りる** | C (get_provenance) |
| **メタデータのみ** | D (concept_get_by_memory) |
| **外部 ID 経由 (Linear/GitHub) で逆引き** | `find_by_external` |

## 将来 (server-side 実装後)

API Redesign RFC v1 の **`read` core verb** で 1 hop fetch 可能になる:

```typescript
read({ resource: 'memory', id: 'mem_xxxxx' })
// → { id, content, atlas, concepts, ... } を 1 query で

// or convenience alias
recall('mem_xxxxx')   // ID-direct fetch
```

実装後は本 cookbook 全 pattern が legacy 化、 **`read` 1 way** に統一。

## 実装プラン (要件 memory 参照)

server-side requirement: `mem_1CaVwGZxyXADC2vg3PE5Qg`
- visibility check (public 認証不要 / private owner check)
- expand sub-resource 同時取得 (annotations / concepts / relations)
- performance: SurrealDB `SELECT * FROM memory:<id>` 1 query、 sub-100ms

## 関連

- API Redesign RFC v1: `../api-redesign-rfc.md`
- Decision tree: `../decision-tree.md` (memory に何を書くべきかの前段)
- 関連 Layer 2 memory: `mem_1CaVwGZxyXADC2vg3PE5Qg` (server-side requirement tracker)
