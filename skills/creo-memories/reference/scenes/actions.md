# `/actions` Scene — Motion Layer

memory を **動かす / 反応する** layer。 todo / notification / work_log / external link / presence。

## 主 tools

### Todo (短期 task)

| tool | 用途 |
|---|---|
| `create_todo` | Todo 作成 |
| `list_todos` | Todo 一覧 (`groupBy` でプロジェクト/種別/タグ/concept 別集計) |
| `update_todo` | Todo 更新 |
| `complete_todo` | Todo 完了 |
| `delete_todo` | Todo 削除 |

### Memory ↔ External (Linear / GitHub) 連携

| tool | 用途 |
|---|---|
| `link_external` | memory に外部 link を紐付け |
| `complete_with_context` | 完了 + 結果追記 + 外部 link を 1 発 |
| `find_by_external` | 外部 ID から memory 逆引き |

### 通知 / 購読

| tool | 用途 |
|---|---|
| `subscribe_memories` | 購読作成 (filter: category/atlas/tag) |
| `unsubscribe_memories` | 購読削除 |
| `list_subscriptions` | 購読一覧 |
| `check_notifications` | 未読通知取得 (pull-based drain) |

### Work Log (agent 間 comm の persist)

| tool | 用途 |
|---|---|
| `record_work_log` | 作業ログ記録 (type: message/question/answer/decision/progress/error/review) |
| `search_work_logs` | 作業ログ検索 (sender/receiver/project/type 指定可) |

### Presence

| tool | 用途 |
|---|---|
| `update_presence` | 自分の focus / status を update |
| `get_presence` | 接続中 agent 一覧 |

### Session

| tool | 用途 |
|---|---|
| `end_session` | session 明示終了 (期限切れ cleanup + 未昇格 summary) |

## scenario 別 recipe

### A. PR / Issue を Memory と pair (mandate)

```
1. PR 作成時に memory を remember:
   remember({
     content: 'PR #351 ...',
     category: 'task',
     status: 'in-review',
     atlasId
   })
2. link_external({
     memoryId,
     externalSystem: 'github',
     externalId: 'PR-351',
     externalUrl: 'https://github.com/...'
   })
3. (Linear 同期も可)
   link_external({
     memoryId,
     externalSystem: 'linear',
     externalId: 'CREO-103',
     externalUrl: 'https://linear.app/...'
   })
4. PR merged 時:
   complete_with_context({
     memoryId,
     resultSummary: 'merged in commit ...',
     externalUrl
   })
```

### B. agent 間 comm を必ず work_log に残す (mandate)

```
agent comm (vp msg / wire / SendMessage) 時:

record_work_log({
  type: 'message' | 'question' | 'answer' | 'decision' | 'progress' | 'error' | 'review',
  sender: 'mako@creo-memories',
  receiver: 'mito@chronista-hub',
  content: '...',
  projectId: 'creo-memories',
  relatedMemoryId?: 'mem_xxx'
})
```

decision 確定時は **必ず** `type:'decision'` を使う。

cross-session で再生:
```
search_work_logs({ sender, receiver, project, type, query })
```

### C. Todo の lifecycle

```
1. create_todo({
     title: '...',
     priority: 'high'|'medium'|'low',
     concepts: [...],
     atlasId
   })
2. 作業中: update_todo({ id, status: 'in_progress' })
3. 完了: complete_todo({ id, resultSummary, externalUrl? })
   → 自動で memory にも反映 (status:done)
```

### D. push 型通知 (subscription)

```
1. 重要 category を subscribe:
   subscribe_memories({
     name: '設計変更監視',
     filter: { category: 'design', atlasId },
     events: ['memory:created', 'memory:updated']
   })
2. session 中に check_notifications({ limit: 20 }) で drain
3. 不要になったら unsubscribe_memories
```

### E. session 終了 ritual

```
1. 未保存の作業 memo を Layer 2 にflush (record_work_log + remember)
2. 未完 todo を確認 (list_todos)
3. end_session({ sessionId })
   → 期限切れ ttl cleanup + 未昇格 summary
```

## Anti-patterns (本 scene 関連)

- ❌ Linear と Memory を別々書く (link_external skip)
- ❌ agent 間 comm を work_log に残さない (流れて消える)
- ❌ status field を初期 `active` のまま放置

詳細は `reference/anti-patterns.md` 参照。

## 4-scene 連携

- memory 内容変更は `/memories` scene の update_memory
- 整理 / Concept 付与は `/atlas` scene
- progress / health 確認は `/views` scene の project_progress / memory_health
