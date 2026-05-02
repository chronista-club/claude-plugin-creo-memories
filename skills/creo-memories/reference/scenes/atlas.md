# `/atlas` Scene — Structure Layer

memory の **整理 / 分類 / 共有設定**。 4-scene の **structure layer**。

## 主 tools

### Atlas (階層 tree)

| tool | 用途 |
|---|---|
| `create_atlas` | Atlas 作成 (parent_id で sub-Atlas) |
| `list_atlas` | Atlas 一覧 |
| `get_atlas_tree` | tree 構造取得 (atlas_id 省略で全 root forest) |
| `update_atlas` | Atlas 更新 (visibility 変更可) |
| `delete_atlas` | Atlas 削除 |
| `invite_to_atlas` | メンバー招待 (mail、 Accept/Decline 通知) |
| `share_atlas` | チームに共有 (read/write/admin) |
| `unshare_atlas` | 共有解除 |
| `list_shared_atlas` | 共有 Atlas 一覧 |

### Concept (categories / labels / tags 統合)

`concept_*` は categories / labels / tags を 1 つに統合した分類層。 memory との紐付けは `classified` RELATION。

| tool | 用途 |
|---|---|
| `concept_list` | Concept 一覧 (kind で category/label/tag 絞り込み) |
| `concept_create` | Concept 作成 (key + name + kind 必須) |
| `concept_update` | Concept 更新 |
| `concept_delete` | Concept 削除 (関連 memory からも自動解除) |
| `concept_classify` | memory に Concept 付与 (名前指定・自動作成・一括) |
| `concept_declassify` | memory から Concept 解除 |
| `concept_get_by_memory` | memory の Concept 一覧 |
| `concept_replace_for_memory` | memory の Concept 一括置換 (kind 指定で部分置換) |

## scenario 別 recipe

### A. 新規 project の Atlas を初期化

```
1. create_atlas({ name: 'creo-memories', description: '...' })
2. 必要に応じ sub-Atlas:
   create_atlas({ name: 'design', parent_id: 'atlas:xxx' })
   create_atlas({ name: 'infra', parent_id: 'atlas:xxx' })
3. Concept を kind 別に整理:
   concept_create({ name: 'priority:high', kind: 'label' })
   concept_create({ name: 'design', kind: 'category' })
   concept_create({ name: 'auth0', kind: 'tag' })
4. team 共有なら share_atlas
```

### B. memory を Atlas + Concept で classify

```
1. remember({ content, atlasId: 'atlas:xxx', conceptIds: [...] })
   または
2. 既存 memory に追加分類:
   concept_classify({ memoryId, conceptNames: ['auth0', 'priority:high'] })
   (Concept 未存在なら kind 推定で自動作成可)
```

### C. Atlas tree を navigate

```
1. get_atlas_tree({ atlas_id: 'atlas:xxx' })
   → tree 構造 + 各 atlas の memory count
2. get_atlas_tree() (atlas_id 省略) → 全 root forest
```

### D. team で共有

```
1. team_create / team_invite
2. share_atlas({ atlasId, teamId, permission: 'read'|'write'|'admin', inheritChildren: true })
3. メンバーが search すると共有 Atlas 配下も結果に含まれる
```

## Anti-patterns

- ❌ 全 memory を default Atlas に flat に貯める
- ❌ Concept を作らず tag string で済ませる (legacy `priority:high` を string で書く等)

詳細は `reference/anti-patterns.md` 参照。

## 4-scene 連携

- memory の CRUD は `/memories` scene
- Atlas summary は `/views` scene の `generate_compass`
- 共有 invitation の通知は `/actions` scene
