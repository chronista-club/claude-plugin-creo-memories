# API Redesign Proposal — Few-but-Composable

> **本 file は将来方向の設計提案 doc**。 v0.23 では implement されない。 v0.24+ で段階移行を想定。

## 動機

現状 plugin の tool 数 = **約 70 件**。 LLM agent (Claude Code) の navigate 容量を超えており、 多くの tool が「存在を忘れられる」 = activation gap の **upstream な原因**。

skill / cookbook / hook で「使え」と圧かけても tool 数自体を減らさないと limit に当たる。 本 doc は **「少ない core verb + curated 名付きエルゴ」** の 11-tool API への redesign を提案する。

## 棚卸し: 現状 70 tools の分布

### Memory CRUD (4)
remember / search / update_memory / forget

### Annotation (3)
annotate / get_annotations / reply_annotation

### Concept (categories/labels/tags 統合) (8)
concept_list / _create / _update / _delete / _classify / _declassify / _get_by_memory / _replace_for_memory

### Atlas (6)
create_atlas / list_atlas / get_atlas_tree / update_atlas / delete_atlas / invite_to_atlas

### Process (3)
create_process / get_process / detect_processes

### Compass / Story (2)
generate_compass / generate_story

### Todo (5)
create_todo / list_todos / update_todo / complete_todo / delete_todo

### External (4)
link_external / complete_with_context / find_by_external / project_progress

### Session / User (5)
get_session / get_status / end_session / get_user / generate_api_key

### Logs / Diagnostics (3)
diagnose / search_logs / system_health

### Provenance (2)
get_provenance / get_relations

### Shared Context (6)
create_shared_context / list_shared_contexts / get_shared_context / add_to_shared_context / join_shared_context / leave_shared_context

### Team (7)
team_create / team_list / team_invite / team_remove / share_atlas / unshare_atlas / list_shared_atlas

### Subscription (4)
subscribe_memories / unsubscribe_memories / list_subscriptions / check_notifications

### Health / Profile (2)
memory_health / get_profile

### Presence (2)
update_presence / get_presence

### Work Log (2)
record_work_log / search_work_logs

### Domain Shared Keys (legacy?) (4)
create_domain_shared_key / list / revoke / delete

### Categories / Labels (concept_* で deprecated 候補) (~10+)

**合計: ~70 tool**

## Pattern 観察

- **CRUD per resource の繰り返し**: 各 noun (memory, atlas, concept, todo, label, ...) で create / list / get / update / delete が爆発的に増殖
- **list と get の分離**: 通常 1 つの read で済む
- **specialized search**: search_logs / search_work_logs / find_by_external が個別 tool 化、 generic 検索の派生
- **compound operation の named function**: complete_with_context は write + link + write を 1 atomic に合成、 これは convenience 例

## 提案: 6 core verbs + 5 named conveniences = **11 tools**

### Core verbs (composable primitives)

**1. `read`** — resource を fetch (id 直 / filter / list)

```typescript
read({
  resource: 'memory' | 'atlas' | 'concept' | 'todo' | 'process' | 'annotation'
          | 'work_log' | 'subscription' | 'team' | 'shared_context'
          | 'session' | 'user' | 'profile' | 'presence' | 'edge',
  id?: string,           // 直 fetch
  filter?: Filter,        // 多 fetch
  expand?: string[],      // 関連 resource を inline
  include?: string[],     // field 選択
  limit?: number,
  cursor?: string
})
// 統合: get_session, get_user, get_atlas_tree, get_process, get_provenance,
//       get_relations, get_annotations, get_status, get_presence, get_profile,
//       list_atlas, list_todos, list_subscriptions, list_shared_contexts,
//       list_shared_atlas, team_list, concept_list, find_by_external 等 (~25 tool)
```

**2. `write`** — create or update (resource includes 'edge' for relations)

```typescript
write({
  resource: ResourceType,
  payload: ResourcePayload,    // resource-specific
  mode: 'create' | 'upsert' | 'update',
  id?: string,                  // update/upsert 時必須
  options?: {
    detectDuplicates?: boolean,  // Pre-save Detection
    expectedVersion?: number,    // 楽観的 lock
    ttl?: number                 // ephemeral
  }
})
// 統合: remember, update_memory, create_atlas, update_atlas, concept_create,
//       concept_update, create_todo, update_todo, annotate, reply_annotation,
//       create_shared_context, add_to_shared_context, team_create, team_invite,
//       link_external (resource:'edge'), record_work_log, update_presence,
//       create_process, subscribe_memories, generate_api_key 等 (~22 tool)
```

**3. `remove`** — delete (soft / hard)

```typescript
remove({
  resource: ResourceType,
  id: string,
  mode?: 'soft' | 'hard'  // soft = status:cancelled、 hard = 物理削除
})
// 統合: forget, delete_atlas, concept_delete, delete_todo, unsubscribe_memories,
//       team_remove, leave_shared_context, unshare_atlas, revoke_domain_shared_key 等 (~10 tool)
```

**4. `query`** — semantic + structured search

```typescript
query({
  q?: string,              // semantic embed query
  resource?: ResourceType, // resource 限定
  filter?: Filter,         // structured (atlas/concept/status/recency/sender 等)
  scope?: 'project' | 'personal' | 'all',
  sort?: SortSpec,
  limit?: number,
  cursor?: string,
  return?: 'full' | 'summary' | 'ids-only'
})
// 統合: search, search_logs, search_work_logs, find_by_external (filter 経由) (~4 tool)
```

**5. `transform`** — derived view operations (LLM-augmented or computed)

```typescript
transform({
  source: ResourceRef | ResourceQuery,
  op: 'compass' | 'story' | 'process_detect' | 'health' | 'progress'
    | 'diagnose' | 'provenance_graph' | 'relations_graph',
  params?: any
})
// 統合: generate_compass, generate_story, create_process (detect→create flow),
//       detect_processes, memory_health, project_progress, diagnose,
//       system_health, get_provenance, get_relations (~10 tool)
```

**6. `subscribe`** — push reactivity (subscription + drain)

```typescript
subscribe({
  filter: Filter,
  events: ('created' | 'updated' | 'deleted' | 'linked')[],
  ttl?: number
})
// + 別 op: drainNotifications({ subscriptionId? })
// 統合: subscribe_memories, unsubscribe_memories, check_notifications (~3 tool)
```

### Named conveniences (LLM-friendly aliases for high-frequency)

**7. `remember`** — `write({resource:'memory', mode:'create', options:{detectDuplicates:true}})` の wrap (慣用 verb 維持)

**8. `recall`** — `query({scope:'project', resource:'memory', limit:5})` の wrap (LLM-natural)

**9. `complete_with_context`** — atomic compound:
```
write({resource:'memory', mode:'update', payload:{status:'done', resultSummary}})
+ write({resource:'edge', payload:{from:memoryId, to:externalUrl, relation:'external_link'}})
+ optional: write({resource:'work_log', payload:{type:'progress'}})
```
1 trip で 3 op、 transactional に。

**10. `record_work_log`** — `write({resource:'work_log'})` の wrap (mandate enforcement のため named)

**11. `end_session`** — finalization (cleanup ttl-expired + 未昇格 summary + summary memory 作成提案)

### 合計 11 tools (現状 70 → -84%)

## 設計的整合性

### Resource model

統一された resource 集合:
```
memory / atlas / concept / todo / process / annotation
work_log / subscription / team / shared_context
session / user / profile / presence
edge (= 関係 = link、 first-class record)
```

`edge` を first-class にすることで `link` 専用 verb 不要 (write resource:'edge' で表現)。

### Filter syntax

統一 filter (read / query / transform で共通):
```typescript
type Filter = {
  resource?: ResourceType,
  ids?: string[],
  atlasId?: string,
  conceptIds?: string[],
  status?: Status[],
  category?: string[],
  type?: string[],         // for work_log type 等
  visibility?: Visibility,
  sender?: string,
  receiver?: string,
  fromDate?: ISODate,
  toDate?: ISODate,
  ttl?: { active?: bool, expiringWithin?: number },
  external?: { system, id?, urlPattern? },
  q?: string,              // semantic 併用
  expand?: string[]
}
```

### Edge predicates (統一)

```
supersedes / extends / derives / derived_from
classifies / annotates / references
external_link / parent_of / member_of
```

## Migration path (3 phase、 v0.23 → v0.25)

### v0.24: 並立 phase (compatibility)

新 11 tool を **追加** (addition only)、 既存 70 tool は維持。 Skill が新 tool を default 推奨、 既存 tool は legacy として残す。

### v0.25: deprecation phase

既存 70 tool を **deprecated** marker、 invocation 時に warning log。 Skill から legacy 記述削除、 cookbook 全面新 tool 化。

### v0.26: removal phase (major version)

legacy 70 tool 削除。 v0.26 = breaking change major。 残 11 tool が canonical。

## メリット (期待される impact)

1. **LLM activation 向上**: 11 tool は普通に navigate 可能、 「忘れる」 が起きにくい
2. **Compositional creativity**: `transform({source:{filter:{atlasId,status:'done'}}, op:'compass'})` のように、 「done memory の Compass」が 1 op で natural に書ける。 現状は generate_compass + 内部 atlas filter で曖昧
3. **Schema discipline**: 全 resource が同 filter / payload schema を共有、 学習コスト 1/N
4. **Documentation 簡素化**: 70 tool 個別 description → 11 tool 深掘り。 reference doc サイズ縮減

## デメリット / リスク

1. **Schema 複雑化**: payload は resource ごとに違う、 discriminated union が必須
2. **migration cost**: 既存 hook / script / 他 plugin が legacy 名で呼んでいたら全 update 必要
3. **LLM 学習 transition**: 旧名で覚えた agent (= 私) が新名に慣れる時間
4. **specialized op の loss 懸念**: complete_with_context のような atomic compound は core で表現困難 → named convenience で吸収必要

## 提案 implement 優先度

| 優先度 | 内容 | release |
|---|---|---|
| 🔴 high | 11-tool API spec を formal 化 (本 doc) | v0.23 (本 doc commit) |
| 🟡 medium | 新 tool implement (server-side 改修要) | v0.24 |
| 🟡 medium | Skill / cookbook 新 tool 化 | v0.24 |
| 🟢 low | legacy deprecation warning | v0.25 |
| 🟢 low | legacy removal | v0.26 |

## 議論を残したい論点

1. **`edge` を first-class にするか、 `link` verb に分けるか** — graph DB native (SurrealDB) なら first-class が自然、 ただし API 側で expose する粒度は別
2. **`transform` の op 集合をどこまで pluggable にするか** — server-side LLM 呼び出し系 (compass / story) と pure compute (health / progress) を 1 verb に混ぜる是非
3. **Pre-save Detection を `write` の option にするか専用 hook にするか** — 現状 remember 内蔵、 generic write でも維持するか
4. **batch / transaction support** — 複数 write を atomic に。 現状 complete_with_context が compound だが、 generic batch op も検討
5. **subscription を SSE / WebSocket native に** — pull-based drain は polling 風、 push 真の reactivity を支える transport
