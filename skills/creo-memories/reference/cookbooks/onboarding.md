# Cookbook: Onboarding

新 project / 新 cycle / 新しい session 開始時の **memory ramp-up** flow。

## いつ発火するか

- 久しぶりに project に戻った
- 新 Atlas を起動 (新しい domain で work 始める)
- 別 agent / team member を invite した直後
- Phase 切替で次 phase の準備

## 一連の手順 (session resume の場合)

### 0. 前 session の session-snapshot を resume (もしあれば)

```
mcp__creo-memories__search({
  tags: ['session-snapshot'],
  atlasId,
  category: 'session',
  limit: 1
})
```

最新 snapshot が返れば content を read、 `next_step` から再開。 `open_questions` は user に提示して 1 問ずつ解消。 詳細: [`cookbooks/session-snapshot.md`](session-snapshot.md)。

### 1. Context Engine が auto 提供する内容を確認

session 開始時、 plugin が以下を auto-inject:
- 直近 memory (recent)
- 未完 todo
- atlas 候補
- profile snapshot

これらが session start instructions に含まれる。 まず読む。

### 2. branch / cwd から推定される Linear issue を確認

```
git status / git branch  // mako/creo-103-phase1-... 形式
→ issue ID 抽出 (CREO-103)
→ mcp__creo-memories__find_by_external({ externalSystem:'linear', externalId:'CREO-103' })
→ 関連 memory 一括取得
```

### 3. atlas tree を navigate

```
mcp__creo-memories__list_atlas()
// or
mcp__creo-memories__get_atlas_tree({ atlas_id })
```

current atlas の memory 配置を把握。

### 4. recall で焦点を合わせる

直前の議論 / 決定を呼び戻す:

```
mcp__creo-memories__search({
  query: '{branch keyword}',
  scope: 'project',
  atlasId,
  limit: 10
})
```

### 5. 未読 notification を drain

```
mcp__creo-memories__check_notifications({ limit: 20 })
```

push 通知に追いつく。

### 6. work_log で inter-agent comm の最新を check

```
mcp__creo-memories__search_work_logs({
  receiver: 'me',
  fromDate: last_session_end,
  type: 'message' | 'question'
})
```

別 agent からの message / question を見落とさない。

## 一連の手順 (新 project / 新 atlas の場合)

### 1. Atlas を作る

```
mcp__creo-memories__write({
  resource: 'atlas',
  payload: {
    name: '{project}',
    description: '...'
  }
})
```

(現状: `create_atlas`)

### 2. seed memory を投入

最初の数 memory を作って search base を作る:

```
remember({
  content: '# Project {name} 開始',
  category: 'design',
  atlasId,
  status: 'active'
})
```

### 3. seed concepts

```
concept_create({ name:'priority:high', kind:'label' })
concept_create({ name:'design', kind:'category' })
```

### 4. (任意) 初期 story を generate

```
mcp__creo-memories__generate_story({
  atlasId,
  // empty atlas でも seed 内容で narrative 生成
})
```

## 一連の手順 (team member invite の場合)

```
mcp__creo-memories__team_create / team_invite
mcp__creo-memories__share_atlas({
  atlasId,
  teamId,
  permission: 'read',
  inheritChildren: true
})
```

invite された相手に対して:
- Compass / Story を generate して onboarding pack 化
- key memory を pin (将来機能 / 現状 manual で memory ID list を渡す)

## Real example: 今 session の onboarding

```
1. Context Engine: creo-memories Atlas 候補 + recent activity 表示
2. branch: mako/creo-103-phase1-... → CREO-103 推定
3. CREO-103 関連 memory を search:
   - ui-foundation-migration-plan.md (Layer 1)
   - creo-ui-design-system.md (Layer 1)
   - creo-ui-editor-lock-principle.md (Layer 1)
4. recall で「token shim」関連を query
5. Phase 1 / 2 完了 comment が CREO-103 Linear に既存 → 進捗を pickup
```

## Best practice

- **onboarding は最初の 5 分で完了** させる (深堀りは後回し、 まず broad に把握)
- **branch name → Linear issue → memory** の chain で context warmup
- **Atlas が複数ある場合は multi-atlas で query** (将来 feature)
- **seed memory が薄い新 Atlas はまず write して search base を作る**

## 派生

- 久しぶり復帰 → `cookbooks/cycle-close.md` の「review 出力」 を逆引きで掴む
- 大型 Epic 着手前 → `cookbooks/decision-record.md` で前提 ADR を read
- session 終了時の保存 (resume の対 motion) → `cookbooks/session-snapshot.md`
