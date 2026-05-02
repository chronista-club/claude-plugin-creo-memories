# Cookbook: Memory を ID で fetch する

memory ID (`mem_xxxxx`) を持っている時に、 content + metadata を直接取得する手順。

> **🎉 v0.30 (2026-04-28〜) で `get_memory` native tool が利用可能**。 以下は legacy reference (workaround) として残置 — v0.29 以前の plugin 利用者向け。

---

## 推奨: `get_memory` (v0.30+)

```
mcp__creo-memories__get_memory({
  id: 'mem_xxxxx',
  expand: ['concepts']   // 任意 — 'concepts' / 'provenance' を選択可
})
// → { id, content, contentType, visibility, createdAt, updatedAt,
//      atlasId, stage, metadata, concepts: [...] }
```

**特徴**:
- **1 query で full content + metadata** 取得
- **visibility check 内蔵**: public は誰でも、 private は owner のみ (mismatch = not found 扱いで存在 leak しない)
- **expand option**: `concepts` (Concept 一覧) / `provenance` (派生関係 graph、 Mermaid 含む)
- **EntId / UUID 両対応**: `mem_xxxxx` 形式も raw UUID v7 形式も OK

エラー時の hint:
- `not found`: id 不在 もしくは private で非 owner
- session 不在: `sessionId` 省略時に CC session が無効。 通常 session id は自動付与

---

## Legacy Reference (v0.29 以前 / fallback)

> 以下は v0.30 native tool が無かった時代の workaround。 v0.30+ では `get_memory` を使うべき。 ただし「 native tool が落ちている時の fallback」 として知っておくと有用。

### Pattern A — `search` の verbose mode

ID と memory の **概要 keyword** が分かっている場合:

```
mcp__creo-memories__search({
  query: '<タイトル または 特徴的な keyword>',
  scope: 'all',           // public + private 両 search
  limit: 5,
  verbose: true,          // ← 重要: full content + metadata 含めて返す
  threshold: 0.5
})

const target = result.memories.find(m => m.id === 'mem_xxxxx')
console.log(target.content)
```

**短所**: keyword 推測必要、 semantic 似度 0 の場合 hit しない可能性

### Pattern B — Public memory の HTTP fetch

`visibility: 'public'` の memory は認証不要で HTTP fetch 可能:

```bash
curl -s https://mcp.creo-memories.in/api/public/r/<memory_id>
```

**短所**: public 限定、 private は 403

### Pattern C — `get_provenance` の preview

content の最初の 1 行 (タイトル) だけで OK な時:

```
mcp__creo-memories__get_provenance({
  memoryId: 'mem_xxxxx',
  depth: 1
})
// → { nodes: [{ id, content: '# 冒頭 1 行 preview', ...}], mermaid }
```

**短所**: content は 1 行 preview のみ

### Pattern D — `concept_get_by_memory`

metadata (Concept) のみで足りる時:

```
mcp__creo-memories__concept_get_by_memory({ memory_id: 'mem_xxxxx' })
```

### Recommendation table (legacy)

| 状況 | 推奨 pattern |
|---|---|
| **full content 必要** | A (search verbose) |
| **public memory** | B (HTTP fetch) |
| **タイトルのみ** | C (get_provenance) |
| **Concept のみ** | D (concept_get_by_memory) |
| **外部 ID 経由 (Linear/GitHub)** | `find_by_external` |

---

## 実装履歴 (v0.30 release)

| 段階 | 日付 | 内容 |
|------|------|------|
| API gap 表面化 | 2026-04-28 朝 | dogfood session で `get_memory` 不在を発見、 server-side requirement memory `mem_1CaVwGZxyXADC2vg3PE5Qg` 起票 |
| Cookbook v0.29 documentation | 2026-04-28 朝 | 本 file 初版 (workaround pattern A-D) |
| Plugin RFC v1 priority bump | 2026-04-28 朝 | `read` core verb を server-side 最優先 task として位置付け |
| Server-side 実装 + production deploy | 2026-04-28 夜 | PR [#353](https://github.com/chronista-club/creo-memories/pull/353) commit `9bb34c63` で `get_memory` MCP tool 追加 (visibility check + expand 含む)、 production deploy 完了 |
| Cookbook v0.30 update | 2026-04-28 夜 | 本 file lead 注記更新 (legacy reference 化) |

5 段の dogfood arc が **約 14 時間で full cycle** 完結 ─ API gap → cookbook → RFC → impl → deploy → cookbook 更新。

## 関連

- **API Redesign RFC v2**: `../api-redesign-rfc.md` (Section 9 で v2 amendments、 Sprint 1 で `memory.read` core verb 実装予定)
- Decision tree: `../decision-tree.md`
- Server-side requirement memory: `mem_1CaVwGZxyXADC2vg3PE5Qg` (status: implemented)
