# Daily Improvement Loop (~5 min)

軽い health check。 異常があれば weekly / biweekly に escalate。

## Checklist

### A. Memory 健全性 (~2 min)

- [ ] `mcp__creo-memories__memory_health()` を実行
- [ ] stale memory 件数を確認 (>10 件で escalate)
- [ ] broken external link 件数を確認 (>0 で確認 + escalate)

### B. 通知 / work_log drain (~1 min)

- [ ] `mcp__creo-memories__check_notifications({ limit: 20 })` で未読確認
- [ ] 未読 work_log の有無確認 (`search_work_logs({ receiver: 'me', fromDate: yesterday })`)

### C. Open issues (~1 min)

- [ ] `mcp__creo-memories__list_todos({ groupBy: 'priority' })` で priority:high の未完
- [ ] open Linear issue 数 (gh / linear cli or memory link 経由)

### D. 異常 detection (~1 min)

- [ ] `mcp__creo-memories__system_health()` で Plugin 本体 health
- [ ] error log の急増がないか (`search_logs({ fromDate: yesterday })`)

## 異常時 action

1. **stale memory > 10**: weekly に escalate (memory garden 必要)
2. **broken link > 0**: 即座に修正 or memory archive
3. **work_log 未読 > 5**: agent 間 comm overflow → 別 session で処理
4. **system_health red**: 緊急 issue → operator alert
5. **error log spike**: diagnose で root cause 確認

## Output

軽い summary を memory 化 (optional):
```
mcp__creo-memories__remember({
  content: '## Daily loop YYYY-MM-DD\n- stale: N\n- notifications: N\n- system: green/red',
  category: 'work_log',
  ttl: 604800  // 7 day で auto-expire (weekly loop が引き継ぐ)
})
```
