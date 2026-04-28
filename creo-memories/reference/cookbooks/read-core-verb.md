# Cookbook: `read` core verb (RFC v2 §1.1)

v0.31 で server-side 実装された **read core verb** の使い方。 11-tool redesign の最初の core verb で、 id 直 fetch / semantic search / list を統一 entry point で扱う。

> **Status (2026-04-28〜)**: Sprint 1 完了 ─ memory (id/filter+q/list) + atlas/concept/todo (list) deployed to production。 Sprint 2 以降で write/remove/query/transform/subscribe が順次追加予定。

---

## 基本: 1 verb で 4 mode

```typescript
read({
  resource: 'memory' | 'atlas' | 'concept' | 'todo',
  id?:      string,        // 1 件 fetch (memory only)
  filter?:  Filter,        // 絞込 (semantic / structured)
  expand?:  string[],      // 関連 inline (concepts / provenance)
  limit?:   number,        // max 結果数
  sessionId?: string,      // 省略時は自動 session
})
```

resource ごとに使える mode と filter field が異なる ─ 後述の table 参照。

---

## Mode 1: id 直 fetch (memory only)

```typescript
read({ resource: 'memory', id: 'mem_1CaVnfJRgWtuRgZD9yQSoV' })
// → 単 memory の full content + metadata
```

`expand` で関連 resource も同時取得:

```typescript
read({
  resource: 'memory',
  id: 'mem_xxx',
  expand: ['concepts', 'provenance'],
})
// → memory + concepts (Concept 一覧) + provenance (派生 graph、 Mermaid)
```

**Visibility**: public は誰でも、 private は owner のみ。 mismatch なら not-found 扱い (existence leak しない)。

---

## Mode 2: semantic search (filter+q)

```typescript
read({
  resource: 'memory',
  filter: { q: 'auth bug', atlasId: 'creo' },
  limit: 10,
})
// → q を vector 検索、 atlas で絞込
```

filter に併用できる field:

| field | 効果 |
|-------|------|
| `q` | semantic search query (有 → hybrid mode) |
| `atlasId` | 所属 atlas で絞込 |
| `category` | category で絞込 |
| `tags` | tag (AND 条件) で絞込 |
| `fromDate` / `toDate` | ISO 8601 期間で絞込 |
| `threshold` | semantic similarity 下限 (0-1) |

---

## Mode 3: list mode (no-q)

q を省略すると **default scope (project)** の最近 memory を返す:

```typescript
read({ resource: 'memory' })
// → default Atlas の最近 memory list (limit 20)
```

filter で絞込しても可:

```typescript
read({
  resource: 'memory',
  filter: { atlasId: 'vantage-point', category: 'design-decision' },
  limit: 5,
})
```

**注**: list mode は内部的に `executeSearchMemories` の "no-query branch" に dispatch。 query 不要で metadata filter が走る。

---

## Mode 4: 他 resource の list

### Atlas

```typescript
read({ resource: 'atlas' })
// → user の atlas tree

read({ resource: 'atlas', filter: { parentId: 'atl_root' } })
// → 特定 atlas の子要素
```

### Concept

```typescript
read({ resource: 'concept' })
// → 全 concept

read({ resource: 'concept', filter: { kind: 'tag' } })
// → tag 種別のみ (category/label/tag のいずれか)
```

### Todo

```typescript
read({ resource: 'todo' })
// → user の todo list

read({ resource: 'todo', filter: { status: 'pending', priority: 'high' } })
```

---

## Resource × mode 対応 table

| resource | id mode | filter+q | filter only / no-q (list) |
|----------|:-------:|:--------:|:-------------------------:|
| memory | ✅ | ✅ | ✅ |
| atlas | ⬜ (follow-up) | — | ✅ |
| concept | ⬜ (follow-up) | — | ✅ |
| todo | ⬜ (follow-up) | — | ✅ |

⬜ = Sprint 2+ で追加予定。

---

## 既存 named tool との関係

`read` は既存 named tool に薄く dispatch する thin layer:

| read mode | dispatch 先 |
|-----------|-------------|
| memory id | `get_memory` |
| memory filter+q | `search` (hybrid mode) |
| memory list | `search` (no-query branch) |
| atlas list | `list_atlas` |
| concept list | `concept_list` |
| todo list | `list_todos` |

named tool は **当面残置**。 deprecate は v1.0 で migration adapter で実施予定 (RFC v2 §3, §9.7 参照)。

## いつ read を使うか / named を使うか

| ケース | 推奨 |
|-------|------|
| 新規実装 / API design redesign 思想に乗る | `read` (forward-compat) |
| 既存 code から呼んでて変える理由が薄い | named tool (`get_memory` 等) |
| filter shape が複雑 / 複数 resource を unified に扱いたい | `read` |
| 1 resource 専用で simple な fetch | named tool |

両方とも v1.0 まで動作保証。

---

## Sprint 計画 (RFC v2 §9.7)

```
✅ Sprint 1 (v0.31): read + memory/atlas/concept/todo  ← 本 cookbook
⬜ Sprint 2 (v0.32+): write + edge first-class
⬜ Sprint 3: remove + query + filter union
⬜ Sprint 4: transform + 全 op
⬜ Sprint 5: subscribe + pull channel
⬜ Sprint 6: transaction + named convenience aliases
⬜ Sprint 7: SSE + webhook channels
⬜ Sprint 8: legacy → new migration adapter
```

## 関連

- **API Redesign RFC v2**: `../api-redesign-rfc.md`
- **fetch-by-ID legacy cookbook**: `fetch-memory-by-id.md` (v0.29 era、 read 着手前の workaround、 reference 用)
- Server-side commit: chronista-club/creo-memories#354 (scaffolding) + #355 (Sprint 1 完成)
