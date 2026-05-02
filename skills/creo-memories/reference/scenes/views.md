# `/views` Scene — Perspective Layer

memory の **collection を別角度で表示** する layer。 memory 個体 (`/memories`) や 構造 (`/atlas`) の **lens**。

## 主 tools

| tool | 用途 |
|---|---|
| `generate_compass` | Atlas 全体の Compass (羅針盤) を LLM 自動生成 — Concept 別グルーピング + 全体概要 |
| `generate_story` | Atlas 内の特定 Concept (or 全体) のストーリーを生成 |
| `create_process` | memory の連鎖を Process として束ねる (技術的決定の経緯 / debug 追跡 path) |
| `get_process` | Process の全 step 取得 (memory 内容含む) |
| `detect_processes` | memory 間 edge chain から Process 候補を自動検出 (3 件以上の連結) |
| `memory_health` | health report (stale / broken / type 分布 / 改善提案) |
| `get_profile` | Dynamic Profile (直近活動 / Concept 分布 / 頻繁参照 memory) |
| `project_progress` | progress report (atlas/concept/category 別集計、 完了率、 progress bar) |
| `system_health` | LogSink 健全性 + error 統計 |
| `diagnose` | error 診断 (service 別 frequency + 詳細) |
| `search_logs` | log 検索 |

## scenario 別 recipe

### A. Phase / Cycle 完了時の narrative 化

```
1. detect_processes()
   → 関連 memory chain 候補が出る
2. create_process({
     name: 'CREO-103 Phase 1 Token Shim',
     memoryIds: ['mem_a', 'mem_b', 'mem_c', ...],
     description: '...'
   })
3. get_process(processId) で確認
4. generate_story({ atlasId, conceptId? }) で narrative 化 (onboarding / docs 用)
```

### B. 週次 / Cycle close レビュー

```
1. project_progress({ atlasId })
   → 完了率 / progress bar / open task 数
2. generate_compass({ atlasId })
   → Concept 別グルーピング、 LLM 概要
3. get_profile()
   → 自分の直近活動 / 頻繁参照 memory
4. memory_health()
   → stale / broken-link surfacing
```

### C. 健全性 audit

```
1. memory_health()
   - stale memory (referenced 無し N day)
   - broken external link
   - type 分布偏り
   - 改善提案
2. system_health() でサーバー側健全性
3. diagnose() で error log 確認
```

### D. onboarding (新参加者向け narrative)

```
1. list_atlas() で Atlas 候補確認
2. generate_compass({ atlasId }) で全体概要
3. generate_story({ atlasId }) で経緯 narrative
4. detect_processes() で重要 process 提示
```

## scenario 横断 best practice

- **Cycle close ごとに `generate_compass` を実行** して memory 状態を確定 snapshot
- **新規 Atlas 起動時に `generate_story` を空 Atlas に対して run** で seed narrative 用意
- **stale 検出は `memory_health` を月次** で run

## 4-scene 連携

- memory 個体追求は `/memories` scene
- Atlas / Concept 整理は `/atlas` scene
- todo / 通知 / work_log の操作は `/actions` scene
