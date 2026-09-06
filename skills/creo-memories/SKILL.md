---
name: creo-memories
description: creo-memories = 外部脳。context が尽きても、session / machine / model / 人をまたいで続きができる場所。書くのは「次に拾う誰かのため」、読むのは「自分が始めた気になる前」。
version: 0.55.0
tags:
  - memory
  - external-brain
  - collaboration
  - chronista
---

# creo-memories — 外部脳

## A. 目的

あなたの context は有限で、session は終わる。続きを拾うのは次の自分、codex や grok、mako や waki。
**creo は全員が同じものを読む外部脳**であり、記録 (todo / spec / 決定 / 引き継ぎ) の SSOT でもある。

- **書く**のは「次に拾う誰かのため」。決めた / 学んだ / 壊れた / 渡す / 後で自分が探す、のどれかなら書く。会話の写しは書かない
- **読む**のは「自分が始めた気になる前」。session 開始の「今日の脳」は自動で入る。過去の決定を前提にする前に `search`
- 機械的な規則 (lock、行為者、提案の門、種類の列挙、label は人だけ) は **server が守る**。ここに「必ず」は無い。判断はあなたがする

## B. 世界の形 (詳細: [model.md](reference/model.md))

- 記憶は **出来事 / 考え / やること** の 3 系統。終わり方で決まる (出来事は終わらない、考えは置き換わる、やることは片付く)。系統は種類 (`kind`、16 値) から導出
- 状態は系統ごとに **1 つの印** (`completed_at` / `superseded_by` / `archived_at`)。`status` 列は無い
- 語彙は **種類 + label**。自由 tag は無い。label は**人が作る**、agent は付けるか提案する
- **未整理 (kind 無し) は一級の状態**。急ぐ時は kind 無しで速記してよい。後で `propose` か人が付ける
- **lock** = 消えない・隠れない・本文と状態が変わらない。移動 / label / 関係 / 再生成は通る。lock も unlock も人だけ
- **誰が書いたか (`sender`) は server が決める**。名乗らなくてよい。あなたが書いた記憶は `agents:claude` として人にも他 agent にも見える
- **提案 (`propose`)** が agent の「整える」手段。受け入れは人

## C. 判断の基準

### 書く
- `remember({ content, kind, atlasId })`。1 行目は題。結論が先。id や生 SQL や長い log は本文に貼らない (人が web / iOS で読む)
- **context が半分を超えたら handoff を 1 本** (`kind: 'handoff'`): 次の一手 / 止まっている理由 / 見ている file / 決めたこと。compaction の前の hook が思い出させる
- 既存の記憶に足すなら `annotate({ targetMemoryId, content })`。本文を書き換えるのは自分が書いた記憶の訂正だけ
- 古い理解を新しい理解で置き換えたら `remember({ content, supersedes: ['mem_…'] })` か `supersede_memory({ id, supersededBy })`。消さない

### どこへ
- project のことは **project の atlas** (session 開始の hook が手がかりを出す。無ければ `read({ resource: 'atlas' })`)
- 自分の癖・訂正・失敗の post-mortem は **`/agent/claude`** (正本はこちら、local の `~/.claude/projects/<p>/memory/` は写し)。他 agent にも効く知識は `/agent`。詳細: [agent-atlas.md](reference/agent-atlas.md)
- mako 個人の情報や一回性の感想は書かない

### 読む
- 「今日の脳」(やること / 考え / 出来事 / 提案 / lock 中) は instructions に自動で入る。途中で `briefing({ atlasId })`
- 前提にする前に `search({ query, atlasId })`。`atlasId` は子 atlas を含まない (`/agent` と `/agent/claude` は両方引く)
- todo を始める前に `read({ resource: 'todo' })`。終えたら `complete_todo({ id })`

### 整える (提案する)
- 種類が違う / label を足したい / 2 つが同じ / 矛盾している → `propose({ kind, target, change, reason })`。判断は人
- label は `label_list()` から選んで `label_attach({ memoryId, labelIds })`。無い label は**頼む** (`label_create` は人だけ)
- 要らない記憶は `forget` より archive や supersede。lock 中は 409 — unlock は人に頼む

### 人だけができること
label を作る / lock と unlock / review 段の提案の受け入れ。agent は頼む・提案する。

## D. 他者と

- 記憶は **人が web / iOS で読み、codex や grok も同じ atlas を読む**。題を 1 行目に、結論を先に、前提と根拠を短く
- 他 agent への引き継ぎは **todo + annotation** (creo が SSOT。wire や chat は通知)。相手の `/agent/<name>` には書かない (読むのは自由)
- 規約の正本は `/agent` の charter (agent 共通)。この skill はその Claude 向けの写し + Claude Code の hook
- 「今日も上手くできました」の日記は書かない。**次に同じ局面で助かるか**だけが基準

## E. 罠 (tool の説明文が SSOT。ここは非自明なものだけ)

- `annotate` は `targetMemoryId`、`get_annotations` は `memoryId`
- `create_todo` に title は無い (content の 1 行目)。`priority` は `low | medium | high`
- `read` の filter は strict (未知 key はエラー)。`resource` は `memory | atlas | todo`
- `category` / `tags` は deprecated。渡しても黙って未整理に入る。`kind` と `labelIds` を使う
- `remember` の `labelIds` に無い label を渡すとエラー (作れるのは人だけ)
- `update_memory` / `forget` / `supersede` は lock 中に 409。`generate_story` / `generate_compass` の再生成は lock を見ずに上書き
- `search({ atlasId })` は子 atlas を含まない

recipes: [recipes.md](reference/recipes.md) / 地図: [tools-map.md](reference/tools-map.md)
