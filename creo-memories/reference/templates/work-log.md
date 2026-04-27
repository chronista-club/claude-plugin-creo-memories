# Work Log Template

> Layer 2 cloud。 `mcp__creo-memories__record_work_log` で保存する work log entry の structure。

## record_work_log 呼び出し template

```typescript
mcp__creo-memories__record_work_log({
  type: 'message' | 'question' | 'answer' | 'decision' | 'progress' | 'error' | 'review',
  sender: '<agent-id>@<project>',  // 例: 'mako@creo-memories'
  receiver: '<agent-id>@<project>', // 例: 'mito@chronista-hub'
  content: '<本文>',                // 1-3 行で要点
  projectId: '<project>',           // 検索 filter 用
  relatedMemoryId: '<mem_xxx>'?     // 関連 memory がある場合
})
```

## type 別 content guideline

### `message`
agent 間 1-way 通知 / status update。 reply 期待しない。

```
content: 'PR #351 を merge しました。 next phase 着手可能。'
```

### `question`
回答を期待する問い合わせ。 reply 必要。

```
content: 'CREO-103 Phase 3 の Tabler 移管、 creo-ui-web 側で受け入れ可能ですか?'
```

### `answer`
question への回答。

```
content: '受け入れ可能。 PR を creo-ui repo に出してください。'
```

### `decision`
**確定した決定**。 必ず使う (後で `search_work_logs` で再生する重要 type)。

```
content: 'Phase 2 scope を reality-adjusted で 1 PR に縮小すると確定。 元 spec の 1200+ rename 想定が実態と乖離。'
```

### `progress`
進捗 update。 完了 / 中間結果 / blocker。

```
content: 'Phase 1 token shim 実装完了、 typecheck pass、 dev server 起動確認済。'
```

### `error`
失敗 / 例外 / blocker の record。

```
content: 'CI lint fail (Biome formatter)、 useTheme.ts line 97 multi-line 折り返し要求。 auto-fix で解消。'
```

### `review`
review feedback の record。

```
content: 'moody-blues review で 4 issue 検出。 Issue 1 (initTheme FOUC) は merge 前に必須 fix、 残り 2 件は Phase 2 / 別 issue。'
```

## 検索 / 再生

```
mcp__creo-memories__search_work_logs({
  sender: '<agent>',
  receiver: '<agent>',
  projectId: '<project>',
  type: 'decision',
  query: '<keyword>',
  fromDate, toDate
})
```

decision を全件:
```
search_work_logs({ projectId, type: 'decision' })
```

## Cookbook で活用

- 各 cookbook (phase-completion / decision-record / bug-fix / cycle-close) で work_log を内蔵 step として
- multi-agent comm の自動 trace 化 (Anti-pattern #7 解消)
