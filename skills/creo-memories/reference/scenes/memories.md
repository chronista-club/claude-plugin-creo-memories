# `/memories` Scene — Data Layer

memory 個体の CRUD + 周辺関係 (annotation / provenance / relations)。 4-scene の **data layer**。

## 主 tools

| tool | 用途 |
|---|---|
| `remember` | 新規 memory 保存。 Pre-save Detection で類似 memory を提案 |
| `search` | semantic search。 scope (project/personal/all) + filter (atlas/concept/tag/recency) |
| `update_memory` | 部分更新 (preserves ID、 content 変更時 embedding 再生成) |
| `forget` | 削除。 cancelled で hide も検討 |
| `annotate` | thread 型注釈 (comment/question/concern/suggestion/approval) |
| `get_annotations` | 注釈 thread を取得 |
| `reply_annotation` | 注釈に reply |
| `get_provenance` | 派生関係 graph (Mermaid flowchart) |
| `get_relations` | typed edge graph (derived_from / annotates / references / supersedes / extends / derives) |

## scenario 別 recipe

### A. 新しい決定を保存

```
1. Decision tree Q1/Q2 を経由 → Layer 2 (cloud) と判定
2. remember({
     content: "## 決定\n...\n## 理由\n...",
     category: 'decision',
     conceptIds: [...],
     atlasId: 'atlas:xxx',
     status: 'done',  // 決定完了なら done
     visibility: 'private' | 'public'
   })
3. Pre-save Detection が類似 memory を提案 → 既存 memory の supersede を検討
4. supersede 必要なら remember({ ..., supersedes: ['mem_xxx'] })
```

### B. 過去の決定を呼び起こす

```
1. search({ query: '...', scope: 'project', atlasId, limit: 5 })
2. 関連が薄ければ scope: 'all' で広げる
3. memory ID から get_relations で周辺記憶を一括把握
4. annotation がついていれば get_annotations でレビューコメント確認
```

### C. 既存 memory を update する

軽微な訂正:
```
update_memory({ id: 'mem_xxx', content: '...' })
```

方針変更 / supersede:
```
remember({
  content: '...',
  supersedes: ['mem_old']  // old を 破 (ha) stage に
})
```

議論残す:
```
annotate({
  memoryId: 'mem_xxx',
  kind: 'concern',
  content: '...'
})
```

### D. memory を削除 / 整理

完全削除 (decision retract):
```
forget({ id: 'mem_xxx' })
```

hide-but-preserve:
```
update_memory({ id: 'mem_xxx', status: 'cancelled' })
```

一時 memo の auto-expire:
```
remember({ content: '...', ttl: 3600 })  // 1h で自動消滅
```

## Anti-patterns (本 scene 関連)

- ❌ rewrite で破壊的に上書き → supersedes / annotate 検討
- ❌ status を `active` のまま放置 → 完了時は `done` / `cancelled` 等に明示

詳細は `reference/anti-patterns.md` 参照。

## 4-scene 連携

- 整理は `/atlas` scene で (Atlas 配置 / Concept 付与)
- summary view は `/views` scene で (`generate_compass` 等)
- 完了 / link は `/actions` scene で (`complete_with_context` / `link_external`)
