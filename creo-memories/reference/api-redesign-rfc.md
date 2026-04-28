# API Redesign RFC v1 — 11-Tool Specification

> **Status**: RFC v1 (formal spec phase)
> **Predecessor**: `api-redesign.md` (proposal phase、 v0.23)
> **Target**: v0.24+ phased migration、 server-side implement 着手準備
> **Authors**: Claude Opus 4.7 + mako@creo-memories
> **Date**: 2026-04-28

## 0. Scope

`api-redesign.md` (proposal) で定めた **「6 core verbs + 5 named conveniences = 11 tools」** 設計を、 **JSON schema + migration matrix + test scenarios** まで spec 化する formal RFC。 Server-side implement 着手前の最終 spec lock。

非 scope:
- Implementation code (server / SDK)
- Performance benchmark (実装後 measure)
- UI / web viewer 改修

## 1. 11-Tool Spec (Formal)

### 1.1 `read` — Resource fetch

**Purpose**: id 直 fetch / filter 多 fetch / list 統一 verb。

**Input schema**:
```typescript
type ReadParams = {
  resource: ResourceType,
  id?: string,
  filter?: Filter,
  expand?: string[],     // 関連 resource を inline (e.g., ['atlas', 'concepts'])
  include?: string[],    // 含める fields (default: all)
  limit?: number,        // default: 50, max: 500
  cursor?: string,       // pagination
  sort?: SortSpec,
}

type ResourceType =
  | 'memory' | 'atlas' | 'concept' | 'todo' | 'process'
  | 'annotation' | 'work_log' | 'subscription' | 'team'
  | 'shared_context' | 'session' | 'user' | 'profile'
  | 'presence' | 'edge'

type Filter = {
  ids?: string[],
  atlasId?: string,
  conceptIds?: string[],
  status?: ('spark' | 'backlog' | 'todo' | 'in-progress' | 'in-review' | 'done' | 'cancelled' | 'reborn')[],
  category?: string[],
  type?: string[],         // for work_log type / annotation kind 等
  visibility?: 'public' | 'private',
  sender?: string,         // for work_log / annotation
  receiver?: string,
  fromDate?: string,        // ISO 8601
  toDate?: string,
  ttl?: { active?: boolean, expiringWithin?: number },
  external?: { system: string, id?: string, urlPattern?: string },
  q?: string,              // semantic query (read 内蔵 search)
}

type SortSpec = {
  field: 'created_at' | 'updated_at' | 'relevance',
  order: 'asc' | 'desc'
}
```

**Output schema**:
```typescript
type ReadResponse = {
  items: ResourceData[],
  cursor?: string,         // 次 page (limit 超過時)
  total?: number,          // 既知時のみ
}
```

**統合する legacy tools** (~25 件):
get_session, get_user, get_atlas_tree, get_process, get_provenance, get_relations, get_annotations, get_status, get_presence, get_profile, list_atlas, list_todos, list_subscriptions, list_shared_contexts, list_shared_atlas, team_list, concept_list, find_by_external, list_drafts (Gmail-like)、 等

### 1.2 `write` — Resource create / update / upsert

**Purpose**: 全 resource type の create / update / upsert を統一。 `edge` resource の write で linking もカバー。

**Input schema**:
```typescript
type WriteParams = {
  resource: ResourceType,
  payload: ResourcePayload,    // resource-specific (discriminated union)
  mode: 'create' | 'upsert' | 'update',
  id?: string,                  // update / upsert 時必須
  options?: WriteOptions,
}

type WriteOptions = {
  detectDuplicates?: boolean,  // Pre-save Detection (memory のみ default true)
  expectedVersion?: number,    // 楽観的 lock
  ttl?: number,                // ephemeral (秒)
  visibility?: 'public' | 'private',
}

// Discriminated union per resource:
type ResourcePayload =
  | MemoryPayload | AtlasPayload | ConceptPayload | TodoPayload
  | ProcessPayload | AnnotationPayload | WorkLogPayload
  | SubscriptionPayload | TeamPayload | SharedContextPayload
  | EdgePayload

type EdgePayload = {
  from: { resource: ResourceType, id: string },
  to: { resource: ResourceType, id: string },
  relation: 'supersedes' | 'extends' | 'derives' | 'derived_from'
          | 'classifies' | 'annotates' | 'references'
          | 'external_link' | 'parent_of' | 'member_of',
  metadata?: Record<string, unknown>,
}
```

**Output schema**:
```typescript
type WriteResponse = {
  id: string,
  version: number,
  duplicateCandidates?: { id: string, similarity: number }[]   // detectDuplicates true 時
}
```

**統合する legacy tools** (~22 件):
remember, update_memory, create_atlas, update_atlas, concept_create, concept_update, create_todo, update_todo, annotate, reply_annotation, create_shared_context, add_to_shared_context, team_create, team_invite, link_external (edge), record_work_log, update_presence, create_process, subscribe_memories, generate_api_key, create_domain_shared_key 等

### 1.3 `remove` — Delete (soft / hard)

**Input schema**:
```typescript
type RemoveParams = {
  resource: ResourceType,
  id: string,
  mode?: 'soft' | 'hard',  // default: 'soft' (status:cancelled、 search 除外)
                            // 'hard' で物理削除
}
```

**Output schema**:
```typescript
type RemoveResponse = {
  id: string,
  removedAt: string,    // ISO 8601
  mode: 'soft' | 'hard',
}
```

**統合する legacy tools** (~10 件):
forget, delete_atlas, concept_delete, delete_todo, unsubscribe_memories, team_remove, leave_shared_context, unshare_atlas, revoke_domain_shared_key, delete_domain_shared_key

### 1.4 `query` — Semantic + structured search

**Input schema**:
```typescript
type QueryParams = {
  q?: string,                  // semantic embed query
  resource?: ResourceType,     // resource 限定 (default: 'memory')
  filter?: Filter,             // structured (read 同様)
  scope?: 'project' | 'personal' | 'all',
  sort?: SortSpec,
  limit?: number,
  cursor?: string,
  return?: 'full' | 'summary' | 'ids-only',
  threshold?: number,          // semantic 類似度 minimum (0.0-1.0、 default 0.5)
  useAtlasContext?: boolean,   // graph context augment
}
```

**Output schema**:
```typescript
type QueryResponse = {
  items: ({ score?: number } & ResourceData)[],
  cursor?: string,
  total?: number,
}
```

**統合する legacy tools** (~4 件):
search, search_logs, search_work_logs, find_by_external (filter 経由)

### 1.5 `transform` — Derived view operations

**Purpose**: LLM-augmented or computed view ops (compass / story / process detect / health 等)。

**Input schema**:
```typescript
type TransformParams = {
  source: ResourceRef | ResourceQuery,
  op: TransformOp,
  params?: Record<string, unknown>,
}

type ResourceRef = { resource: ResourceType, id: string }
type ResourceQuery = { resource?: ResourceType, filter: Filter }

type TransformOp =
  | 'compass'              // Atlas → 全体概要 (LLM)
  | 'story'                // Atlas → narrative (LLM)
  | 'process_detect'       // memory chain → Process 候補
  | 'health'               // health audit
  | 'progress'             // progress report
  | 'diagnose'             // error 診断
  | 'provenance_graph'     // 派生関係 graph (Mermaid)
  | 'relations_graph'      // typed edge graph
```

**Output schema** (op 依存):
```typescript
type TransformResponse =
  | { op: 'compass', summary: string, sections: { concept: string, body: string }[] }
  | { op: 'story', narrative: string, mermaid?: string }
  | { op: 'process_detect', candidates: { ids: string[], confidence: number }[] }
  | { op: 'health', report: HealthReport }
  | { op: 'progress', report: ProgressReport }
  | { op: 'diagnose', issues: DiagnoseIssue[] }
  | { op: 'provenance_graph' | 'relations_graph', mermaid: string, edges: Edge[] }
```

**統合する legacy tools** (~10 件):
generate_compass, generate_story, create_process (detect→create flow), detect_processes, memory_health, project_progress, diagnose, system_health, get_provenance, get_relations

### 1.6 `subscribe` — Push reactivity

**Input schema**:
```typescript
type SubscribeParams = {
  filter: Filter,
  events: ('created' | 'updated' | 'deleted' | 'linked')[],
  ttl?: number,
  channel?: 'pull' | 'webhook' | 'sse',  // default: 'pull'
  webhookUrl?: string,                     // channel='webhook' 時
}

// + 別 op via `read` (resource: 'subscription')
// + 別 op via `transform` ({ op: 'drain', source: { resource:'subscription', id }})
// もしくは独立 `drainNotifications` で抽象は分かれる
```

### 1.7 `remember` — Named convenience for memory write

**Purpose**: 慣用 verb 維持。 `write({resource:'memory', mode:'create', options:{detectDuplicates:true}})` の wrap。

```typescript
type RememberParams = MemoryPayload & WriteOptions
type RememberResponse = WriteResponse
```

### 1.8 `recall` — Named convenience for memory query

**Purpose**: LLM-natural verb。 `query({scope:'project', resource:'memory', limit:5})` の wrap。

```typescript
type RecallParams = {
  q?: string,
  filter?: Pick<Filter, 'atlasId' | 'conceptIds' | 'category' | 'tags'>,
  limit?: number,    // default: 5
}
type RecallResponse = QueryResponse
```

### 1.9 `complete_with_context` — Atomic compound

**Purpose**: 完了時の 3 op を atomic transaction:
```
write(resource:'memory', mode:'update', payload:{status:'done', resultSummary})
+ write(resource:'edge', payload:{from:memoryId, to:externalUrl, relation:'external_link'})
+ optional: write(resource:'work_log', payload:{type:'progress'})
```

**Input schema**:
```typescript
type CompleteWithContextParams = {
  memoryId: string,
  resultSummary: string,
  externalUrl?: string,
  externalSystem?: string,
  externalId?: string,
  recordWorkLog?: boolean,    // default: true
}
```

### 1.10 `record_work_log` — Named convenience

**Purpose**: agent 間 comm の persist。 mandate enforcement のため named。

```typescript
type RecordWorkLogParams = {
  type: 'message' | 'question' | 'answer' | 'decision' | 'progress' | 'error' | 'review',
  sender: string,
  receiver?: string,
  content: string,
  projectId?: string,
  relatedMemoryId?: string,
}
```

### 1.11 `end_session` — Session finalization

**Purpose**: 期限切れ ttl cleanup + 未昇格 summary + summary memory 作成提案。

```typescript
type EndSessionParams = {
  sessionId?: string,    // 省略時は active session
  summarizeUnpromoted?: boolean,   // default: true
}
type EndSessionResponse = {
  cleanedTtlCount: number,
  unpromotedMemoryIds: string[],
  summarySuggestion?: string,
}
```

## 2. Migration Matrix

70 既存 tool → 11 新 tool への mapping table。

| Legacy tool | New tool | Translation |
|---|---|---|
| `remember(content, ...)` | `remember(content, ...)` | identical (alias 維持) |
| `update_memory(id, ...)` | `write({resource:'memory', mode:'update', id, payload:...})` |
| `forget(id)` | `remove({resource:'memory', id})` |
| `search(query, ...)` | `query({q:query, resource:'memory', ...})` |
| `recall_relevant(...)` | `recall(...)` |
| `annotate(memId, kind, content)` | `write({resource:'annotation', mode:'create', payload:{memoryId, kind, content}})` |
| `get_annotations(memId)` | `read({resource:'annotation', filter:{memoryId}})` |
| `reply_annotation(parentId, ...)` | `write({resource:'annotation', mode:'create', payload:{parentId, ...}})` |
| `concept_create(name, kind)` | `write({resource:'concept', mode:'create', payload:{name, kind}})` |
| `concept_classify(memId, names)` | `write({resource:'edge', payload:{from:{resource:'memory',id:memId}, to:{resource:'concept',id:...}, relation:'classifies'}})` |
| `concept_list({kind})` | `read({resource:'concept', filter:{kind}})` |
| `create_atlas(name, parentId?)` | `write({resource:'atlas', mode:'create', payload:{name, parentId}})` |
| `get_atlas_tree(atlasId?)` | `read({resource:'atlas', id:atlasId, expand:['children']})` |
| `share_atlas(atlasId, teamId, perm)` | `write({resource:'edge', payload:{from:atlas, to:team, relation:'shared_with', metadata:{permission:perm}}})` |
| `create_process(name, memIds)` | `write({resource:'process', mode:'create', payload:{name, memoryIds}})` |
| `detect_processes()` | `transform({source:{filter:{}}, op:'process_detect'})` |
| `generate_compass(atlasId)` | `transform({source:{resource:'atlas', id:atlasId}, op:'compass'})` |
| `generate_story(atlasId, conceptId?)` | `transform({source:{resource:'atlas', id:atlasId}, op:'story', params:{conceptId}})` |
| `memory_health()` | `transform({source:{filter:{}}, op:'health'})` |
| `get_profile()` | `read({resource:'profile'})` |
| `project_progress(atlasId)` | `transform({source:{resource:'atlas', id:atlasId}, op:'progress'})` |
| `diagnose()` | `transform({source:{filter:{}}, op:'diagnose'})` |
| `system_health()` | `transform({source:{filter:{}}, op:'health', params:{scope:'system'}})` |
| `get_provenance(memId)` | `transform({source:{resource:'memory', id:memId}, op:'provenance_graph'})` |
| `get_relations(memId)` | `transform({source:{resource:'memory', id:memId}, op:'relations_graph'})` |
| `create_todo(...)` | `write({resource:'todo', mode:'create', payload:...})` |
| `list_todos({groupBy?})` | `read({resource:'todo', expand:[groupBy]})` |
| `update_todo(id, ...)` | `write({resource:'todo', mode:'update', id, payload:...})` |
| `complete_todo(id)` | `write({resource:'todo', mode:'update', id, payload:{status:'done'}})` |
| `delete_todo(id)` | `remove({resource:'todo', id})` |
| `link_external(memId, system, extId, url)` | `write({resource:'edge', payload:{from:{resource:'memory',id:memId}, to:{resource:'external'}, relation:'external_link', metadata:{system, extId, url}}})` |
| `complete_with_context(...)` | `complete_with_context(...)` (named alias 維持) |
| `find_by_external(system, extId)` | `query({filter:{external:{system, id:extId}}})` |
| `subscribe_memories({filter, events})` | `subscribe({filter, events, channel:'pull'})` |
| `unsubscribe_memories(subId)` | `remove({resource:'subscription', id:subId})` |
| `list_subscriptions()` | `read({resource:'subscription'})` |
| `check_notifications({limit})` | `transform({source:{resource:'subscription'}, op:'drain', params:{limit}})` |
| `record_work_log(...)` | `record_work_log(...)` (named alias 維持) |
| `search_work_logs(...)` | `query({resource:'work_log', filter:{...}})` |
| `team_create(...)` | `write({resource:'team', mode:'create', payload:...})` |
| `team_invite(teamId, userId)` | `write({resource:'edge', payload:{from:team, to:user, relation:'member_of'}})` |
| `team_remove(teamId, userId)` | `remove({resource:'edge', id:edgeId})` |
| `team_list()` | `read({resource:'team'})` |
| `update_presence(...)` | `write({resource:'presence', mode:'upsert', payload:...})` |
| `get_presence()` | `read({resource:'presence'})` |
| `get_session()` / `get_user()` / `get_status()` | `read({resource:'session'/'user'/'status'})` |
| `end_session()` | `end_session()` (named alias 維持) |
| `generate_api_key()` | `write({resource:'api_key', mode:'create'})` |
| `create_domain_shared_key(...)` | `write({resource:'shared_key', mode:'create', payload:...})` |
| `list_domain_shared_keys()` | `read({resource:'shared_key'})` |
| `revoke_domain_shared_key(id)` | `write({resource:'shared_key', mode:'update', id, payload:{revoked:true}})` |
| `delete_domain_shared_key(id)` | `remove({resource:'shared_key', id})` |
| `create_shared_context(...)` | `write({resource:'shared_context', mode:'create', payload:...})` |
| `join_shared_context(ctxId)` | `write({resource:'edge', payload:{from:user, to:ctx, relation:'member_of'}})` |
| `leave_shared_context(ctxId)` | `remove({resource:'edge', id:edgeId})` |
| `add_to_shared_context(ctxId, memId)` | `write({resource:'edge', payload:{from:ctx, to:memory, relation:'contains'}})` |

## 3. Backward Compatibility (Phase 移行)

### v0.24 (並立 phase)

新 11 tool を **追加** (addition only)。 既存 70 tool は **維持** (deprecation warning なし)。 SKILL.md が新 tool を default 推奨、 既存 tool は legacy として残す。

server-side: 新 tool router + adapter (新 tool が legacy tool を内部呼び出し or 直接実装)。

### v0.25 (deprecation phase)

既存 70 tool を **deprecated** marker、 invocation 時に warning log。 SKILL.md から legacy 記述削除、 cookbook 全面新 tool 化。

server-side: deprecated tool は warning log + 同じ動作維持。

### v0.26 (removal phase, major version = v1.0.0)

legacy 70 tool 削除。 v1.0.0 = breaking change major release。 残 11 tool が canonical。

server-side: legacy router removal、 schema migration (もし schema 変更があれば)。

## 4. Test Scenarios (各 tool 最低 5 件)

### 4.1 read

- T1: `read({resource:'memory', id:'mem_xxx'})` → 単 memory fetch
- T2: `read({resource:'memory', filter:{atlasId:'creo'}, limit:10})` → atlas 内 memory
- T3: `read({resource:'memory', expand:['atlas','concepts']})` → 関連 inline
- T4: `read({resource:'memory'})` → default scope (project)、 default limit 50
- T5: `read({resource:'memory', filter:{q:'auth'}})` → semantic + structured

### 4.2 write

- T1: `write({resource:'memory', mode:'create', payload:{content:...}})` → remember 等価
- T2: `write({resource:'memory', mode:'update', id, payload:{status:'done'}})` → status change
- T3: `write({resource:'memory', mode:'create', payload:..., options:{detectDuplicates:true}})` → Pre-save 候補返却
- T4: `write({resource:'edge', payload:{from, to, relation:'supersedes'}})` → linking
- T5: `write({resource:'memory', mode:'create', payload, options:{ttl:3600}})` → ephemeral

### 4.3 query

- T1: `query({q:'authentication', limit:5})` → semantic top 5
- T2: `query({filter:{conceptIds:['adr']}})` → structured filter
- T3: `query({q:'design', filter:{atlasId:'creo'}, threshold:0.7})` → hybrid
- T4: `query({resource:'work_log', filter:{type:'decision', sender:'mako'}})` → cross-resource
- T5: `query({useAtlasContext:true, q:'security'})` → graph augmented

### 4.4 transform

- T1: `transform({source:{resource:'atlas',id:'creo'}, op:'compass'})` → atlas summary
- T2: `transform({source:{resource:'memory',id:'mem_xxx'}, op:'provenance_graph'})` → Mermaid
- T3: `transform({source:{filter:{status:'in-progress'}}, op:'progress'})` → progress report
- T4: `transform({source:{filter:{atlasId:'creo'}}, op:'health'})` → atlas-scoped health
- T5: `transform({source:{filter:{}}, op:'process_detect'})` → chain candidates

### 4.5 + others

省略 (各 5+ 件、 implement phase で充実)。

## 5. Performance Considerations

- `read` は通常 single SurrealDB query で完結すべき (sub-100ms)
- `query` semantic search は Qdrant call、 hybrid mode で <500ms 目標
- `transform` LLM-augmented (compass / story) は async、 cache 推奨
- `write` Pre-save Detection は best-effort、 timeout で skip 可

## 6. Error Handling

統一 error structure:
```typescript
type ApiError = {
  code: 'INVALID_PARAMS' | 'NOT_FOUND' | 'CONFLICT' | 'PERMISSION_DENIED'
      | 'RATE_LIMIT' | 'INTERNAL' | 'TIMEOUT',
  message: string,
  details?: Record<string, unknown>,
  retryable: boolean,
}
```

## 7. Open Questions (RFC v1 → v2 で決定)

1. **`edge` を first-class resource にするか、 `link` verb で抽象**するか?
   - 現案: `edge` first-class (`write({resource:'edge'})`)
   - 代案: `link({from, to, relation})` 専用 verb 復活 (`write` から分離)
2. **batch / transaction support** — `write([...])` で複数 atomic? もしくは `transaction({ ops })` 専用 op?
3. **subscribe channel**: pull / webhook / SSE のどれが server-side で実装可能?
4. **Pre-save Detection** を `write` の option ではなく専用 hook (`detect_duplicates(content)`) に分離する?
5. **`recall` を `query` の sub-case とするか別 tool として残すか** — convenience 度合いの判断

### 7.5 (v0.29 で部分 answer): fetch-by-ID priority

**Q5 派生**: 「`recall(id)` で memory ID 直 fetch 可能にすべきか?」

**Answer (2026-04-28)**: **YES、 highest priority**。 dogfood で API gap が表面化、 server-side 着手最優先 task に位置付け。

実装形式 (採用):
- `read({resource:'memory', id})` を canonical (RFC v1 統一)
- `recall(id)` は convenience alias として併設 (id 1 引数 case のみ short-cut)
- visibility check: private は owner、 public は誰でも (HTTP `/api/public/r/<id>` と等価動作)

詳細 requirement: Layer 2 memory `mem_1CaVwGZxyXADC2vg3PE5Qg` (server-side tracker)
Plugin workaround: `cookbooks/fetch-memory-by-id.md` (search verbose pattern 等)

## 8. Next Steps

1. Server-side team review → RFC v1 feedback
2. **🔥 v0.29 priority: `read({resource:'memory', id})` server-side implement** — dogfood で API gap 確認、 最優先 task
3. RFC v2: 残 open questions (1-4) に answer + breaking change inventory
4. Implementation plan: server-side migration を sprint 単位で
5. v0.24 (並立 phase) へ着手

## 関連

- `api-redesign.md` — proposal phase (v0.23)
- `mcp-tools.md` — 現状 70 tool 詳細
- (Layer 1 memory) `creo-memories-2-layer-architecture.md` — 2 layer 設計、 本 RFC は Layer 2 cloud の API 設計
