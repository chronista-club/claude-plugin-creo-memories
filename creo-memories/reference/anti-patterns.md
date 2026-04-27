# Creo Memories Anti-Patterns

「やってはいけない / 避けた方が良い」 patterns。 Decision tree に補足する負の事例集。

## 1. ❌ Plugin tool を skip して file 直書き

**症状**: 「memory に保存したい」と判断した時、 reflexively `Write` tool で local file に書く。

**何が悪い**:
- Layer 1 (local) と Layer 2 (cloud) の使い分けが効かない
- multi-agent / multi-session で trace 喪失
- semantic search できない

**正しい flow**: Decision tree の Q1/Q2 を経由 → 適切な layer / tool を選ぶ。

**例外 (Layer 1 が正しい場合)**:
- 不変方針 / reference card / foundational principle → これは file 直書きで正解 (`Write` tool でも `mcp__creo-memories__remember` でも、 どちらにせよ Layer 1 file が canonical)

## 2. ❌ Memory を rewrite で破壊的に上書き

**症状**: 古い情報を消して新しい内容で完全置換、 history が消える。

**何が悪い**:
- 「なぜ前はこうだった、 なぜ変わった」が trace 不能に
- supersedes chain (序破離 stage model) が機能しない
- archeology (decision archaeology) を破壊

**正しい flow**:
- 軽微な訂正 → `update_memory(id, content)` で OK
- 方針変更 / supersede → `remember(content, supersedes: [old_id])` で新 memory 作成、 old を破 (ha) stage に
- 議論残したい → `annotate(memory_id, kind:'concern' | 'comment')` で thread

## 3. ❌ Linear と Memory に同じ内容を別々書く (dual bookkeeping)

**症状**: project 進捗を Linear ticket で書いて、 memory にも別途書く (両者 link 無し)。

**何が悪い**:
- 整合性 drift (Linear update したが memory 古いまま、 vice versa)
- 「どっちが canonical?」が不明
- cross-search で 2 hop 必要

**正しい flow**: `link_external(memory_id, linear_url)` で必ず pair。 memory description に Linear URL、 Linear description に memory ID。 状態遷移は status 同期 hook で自動化 (Phase 1 で実装予定)。

## 4. ❌ status field を無視 / 全部 `active` で放置

**症状**: memory の status を初期値 `active` のまま update しない。

**何が悪い**:
- task lifecycle (spark→backlog→todo→in-progress→in-review→done) が機能しない
- `/actions` scene で「open task」を一覧できない
- `complete_todo` / `complete_with_context` の自動化と乖離

**正しい flow**:
- task 系 memory は `status` を必ず付ける
- 完了時は `complete_with_context` (status:done + 結果追記 + link_external 一発)

## 5. ❌ Atlas を作らず flat に貯める

**症状**: 全 memory を default Atlas に放り込む。

**何が悪い**:
- search で「どの project の話?」が不明
- team 共有 (`share_atlas`) のスコープを切れない
- `generate_compass` / `generate_story` が効かない (Atlas 単位で動く)

**正しい flow**: project / domain ごとに Atlas を作る。 `create_atlas` を session 開始 ritual として skill に内蔵。

## 6. ❌ Concept を作らず tag string で済ませる (legacy)

**症状**: `priority:high` / `cycle:2026-W17` 等の tag を string suffix で memory に貼る。

**何が悪い**:
- Concept (categories/labels/tags 統合システム) が活用されない
- `concept_classify` の自動 dedup / 階層化 / kind フィルタが使えない
- 検索で「priority:high な memory」 を一発で出せない (filter 不可)

**正しい flow**:
- Concept を **kind=`label`** / `category` / `tag` のどれかで `concept_create`
- `concept_classify(memory_id, concept_names)` で付与
- search で `conceptIds` filter 利用

## 7. ❌ inter-agent comm を流す (work_log に残さない)

**症状**: vp msg / wire / SendMessage で agent 間 comm したが、 trace を残さず流れる。

**何が悪い**:
- session 跨ぎで「あの時 mito 何て言った?」が辿れない
- decision の文脈が memory に蓄積されない
- multi-agent debug 時の retrospective 不能

**正しい flow**:
- agent 間 comm 時に `record_work_log(type:'message'|'question'|'answer'|'decision'|'progress'|'error'|'review', sender, receiver, content)` を mandate
- decision 確定時は `type:'decision'` を必ず使う
- 後で `search_work_logs(sender, project, type)` で再生

## 8. ❌ session start で前 session memory を確認しない

**症状**: session resume で `recent` / `MEMORY.md` を読まず、 cold-start のまま work 着手。

**何が悪い**:
- 直前の決定を忘れて重複 / 矛盾 work
- Linear ticket の latest comment を見落とす
- 未読 notification / 未完 todo を放置

**正しい flow**:
- Context Engine (v3.0) が auto-injection するが、 念押しで `list_recent_memories` + `list_todos` + `check_notifications` を session start ritual に
- branch name から推定される Linear issue の memory を先に search

## 9. ❌ memory を一切 forget しない (累積 hoarding)

**症状**: 過去の試行錯誤 memo / 陳腐化した方針 / 決定 retract 後の旧版が累積。

**何が悪い**:
- search noise が増える
- stale memory が「最新」 に見えてしまう
- `memory_health` score 低下

**正しい flow**:
- 一時 memo は `ttl` で auto-expire 設定して保存
- 陳腐化が確定したら `forget` or `update_memory(status:'cancelled')`
- 月次で `memory_health` を見て stale を整理

## 10. ❌ 「あった方が良い」 を memory にする

**症状**: 「将来 X すると良いかもしれない」 という weak hypothesis を memory にする。

**何が悪い**:
- noise:signal 比悪化
- 「これは前に決めた / 確定」と誤読される
- forget rate 低下 (誰も整理しない)

**正しい flow**: 確定 / 必要 / 強欲望のみ memory 化。 「あった方が良い」 は会話で消える方が healthy。

## まとめ

これらの anti-pattern は **「tool 不足」より「pattern 不在」が原因**。 skill / cookbook が pattern を提示することで、 同じ tool 群が活性化する。
