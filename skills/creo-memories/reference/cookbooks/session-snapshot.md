# Cookbook: Session Snapshot

session 全体の goal / decisions / open questions / next-step を **1 memory に pin** して、 cross-device / cross-worktree / cross-day の continuity を保つ。 個別 event は `record_work_log`、 session 全体は本 cookbook で。

## いつ発火するか

- 長い session を中断する (lunch / 帰宅 / 別 worktree に switch)
- 重要な decision が連続して入った session の終わり (Stop hook が nudge)
- worktree A で議論 → worktree B で再開する場合
- 複数日 cross する Epic で、 1 日 1 snapshot を残したい

## 一連の手順 (save)

### 1. Capture — session 全体を構造化

session 中の以下を mental dump → headed list:

- **goal**: 1 sentence
- **judgement_axes**: 本 session で確定した axis (例: `F1=PP-3`、 `D1=design/09`)
- **open_questions**: 未解決の疑問
- **related_memories**: 関連 memory ID list
- **next_step**: 次 session で着手すべき actionable 1 文

### 2. Structure — yaml-ish content の組み立て

```
# Session Snapshot: {project} / {date}

session_id: {UUID or claude code session id}
started_at: {ISO 8601}
last_updated_at: {ISO 8601}
project: {atlas name}
branch: {git branch}
worktree: {cwd basename}
commit: {git hash}

goal: "..."

judgement_axes:
  - F1=PP-3
  - D1=design/09-...

open_questions:
  - "..."

related_memories:
  - mem_xxx ({short label})
  - mem_yyy ({short label})

next_step:
  - "..."
```

### 3. Pin — `remember` で保存

```
mcp__creo-memories__remember({
  content: `<上記 yaml-ish content>`,
  category: 'session',
  tags: ['session-snapshot', 'project={atlas}', 'branch={branch}'],
  status: 'active',
  atlasId,
  supersedes: ['mem_prev_snapshot'],  // 連続 save 時のみ、 初回は []
  visibility: 'private'
})
```

### 4. Confirm — 真の save 成否確認

`remember` の戻り値で id が返れば save 成功。 念のため verify するなら **id 直 fetch** が確実:

```
mcp__creo-memories__get_memory({
  id: '<remember 戻り値の id>'
})
```

⚠️ **注意**: `search` で metadata-only filter (query 空 + tags / category 指定) は **0 件を返す** (semantic / hybrid どちらの searchType でも実装上 query 必須、 v0.34 時点)。 search で確認したい場合は query を必ず指定:

```
mcp__creo-memories__search({
  query: 'session snapshot {project}',  // 必須
  tags: ['session-snapshot'],
  atlasId,
  category: 'session',
  limit: 1
})
```

### 5. (任意) inter-agent comm の flush

session 中の agent 間 comm が残っていれば persist:

```
mcp__creo-memories__record_work_log({
  type: 'decision',
  sender: 'mako',
  content: 'session-snapshot saved as mem_xxx',
  projectId,
  relatedMemoryId: snapshotId
})
```

## 一連の手順 (resume)

### 1. 最新 snapshot を search

⚠️ **search は query 必須** (`searchType: 'semantic'` / `'hybrid'` どちらでも、 metadata-only mode は 0 件返却、 v0.34 時点)。 必ず query を指定:

```
mcp__creo-memories__search({
  query: 'session snapshot {project}',  // 必須
  tags: ['session-snapshot'],
  atlasId,
  category: 'session',
  limit: 5
})
```

または **`read` core verb** (v0.31+、 strict filter mode は query 不要):

```
mcp__creo-memories__read({
  resource: 'memory',
  filter: {
    tags: ['session-snapshot'],
    category: 'session',
    atlasId
  }
})
```

### 2. content を read + next_step を pickup

`next_step` から再開する action を identify。

### 3. related_memories を fetch

```
mcp__creo-memories__get_memory({ id: 'mem_related' })
```

context を再構築。

### 4. open_questions を user に提示

未解決を resume 開始時に user に確認 → 1 問ずつ解消。

## 一連の手順 (list / history)

session-snapshot history を編年的に辿る (search は **query 必須**):

```
mcp__creo-memories__search({
  query: 'session snapshot {project}',  // 必須
  tags: ['session-snapshot'],
  atlasId,
  category: 'session',
  includeSuperseded: true,
  limit: 50
})
```

`includeSuperseded: true` で supersede chain 全体を列挙可能。 query を渡さない場合は `read` core verb (filter strict、 query 不要):

```
mcp__creo-memories__read({
  resource: 'memory',
  filter: {
    tags: ['session-snapshot'],
    category: 'session',
    atlasId,
    includeSuperseded: true
  }
})
```

## metadata 設計 (まとめ)

| field | value | 役割 |
|---|---|---|
| `category` | `'session'` | session 専用 category (search filter) |
| `tags[0]` | `'session-snapshot'` | tag root (他 session 系 memory との識別) |
| `tags[1]` | `'project={atlas}'` | project filter |
| `tags[2]` | `'branch={git-branch}'` | branch filter |
| `status` | `'active'` | 進行中 session、 終了は `'done'` |
| `supersedes` | `[前 snapshot id]` | 連続 save の chain |
| `atlasId` | project Atlas | scope 確定 |
| `visibility` | `'private'` | 個人 session、 team 共有は `'public'` 昇格 |

## Real example: D11 議論 cross-worktree handoff (本 cookbook 起点)

```
session 1 (worktree: vantage-point-sub, branch: mako/sub):
  - D11 Pane Revival foundation v2 確定 (mem_1CabQF199...)
  - 次 step: docs/design/09-stand-pane-lane.md 起こし

save:
  remember({
    content: '# Session Snapshot: vantage-point / 2026-05-01\n\ngoal: D11 foundation v2 確定 → design doc 起こしへ\n\njudgement_axes:\n  - D11-A/B/... (Phase 7 → D11 改名)\nrelated_memories:\n  - mem_1CabQF199... (D11 v2)\nnext_step:\n  - docs/design/09-stand-pane-lane.md 起こし',
    category: 'session',
    tags: ['session-snapshot', 'project=vantage-point', 'branch=mako/sub'],
    atlasId: 'vantage-point',
    supersedes: []
  })

session 2 (worktree: vantage-point, branch: mako/sub に attach):
  search({ query:'session snapshot vantage-point', tags:['session-snapshot'], atlasId:'vantage-point', limit:1 })
    → 最新 snapshot fetch
  next_step pickup → docs/design/09-... 起こし開始
```

## Best practice

- **session が短い (< 1h) / 議論なし なら snapshot 不要** — recent memory + work_log で十分
- **worktree 切替 / 中断 / day-end が主 trigger** — Stop hook が nudge する
- **初回 save は `supersedes: []`、 連続 save は前 id で chain 化** — history 保持
- **judgement_axes は key 5〜10 件のみ** — 全網羅ではなく決定の core
- **next_step は actionable 1 文** — 「考える」 ではなく 「edit X file」 等

## Anti-patterns

- ❌ session-snapshot を毎 turn 上書き保存 (= supersede chain で history、 turn 単位は work_log)
- ❌ 全 memory ID を related_memories に列挙 (= key 関連のみ、 noise を持ち込まない)
- ❌ visibility を最初から public (= snapshot は個人 trace、 共有時に昇格)
- ❌ `record_work_log` (event 単位) と二重記録 (= session 全体は snapshot、 個別 event は work_log で粒度分離)

## 派生

- session 開始時の resume flow → [`cookbooks/onboarding.md`](onboarding.md) の「前 session resume」 chapter
- 同 session 内の event 単位 trace → `mcp__creo-memories__record_work_log` (粒度: event 1 個)
- 大型 Epic の phase 単位 → [`cookbooks/phase-completion.md`](phase-completion.md) (粒度: phase 全体)
- ADR と pair (= snapshot で議論経緯、 ADR で確定判断) → [`cookbooks/decision-record.md`](decision-record.md)
