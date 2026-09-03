# Agent Atlas — `/agent` と `/agent/<自分>` の使い分け

Creo Memories には project 軸の atlas (`creo-memories` `vantage-point` …) とは別に、**actor 軸**の atlas がある
(2026-09-03 開設、mako 発案。Claude / Codex / Grok が creo を使えるようになったため)。
規約の SSOT は `/agent` atlas の charter memory (slug `agent-charter`)。このファイルはその要約。

## 構造

| atlas | 誰の | 何を |
|---|---|---|
| `/agent` | 全 agent 共通 | どの agent が読んでも効く横断知識 (MCP tool の引数の罠、wire / SSOT / handoff の作法、agent 間の運用合意) |
| `/agent/claude` `/agent/codex` `/agent/grok` | その agent 専用 | 自分の癖と修正点 (self-observation)、自分だけの運用メモ、失敗した turn の post-mortem。**他 agent の atlas には書かない** (読むのは自由) |
| project atlas | project | その project の仕様・決定・todo・work log。agent 自身の都合は書かない |
| `/Personal` | mako | agent は書かない |

## どこに書くか (上から順に判定)

1. その project でしか意味が無い → **project atlas**
2. project に依らず、自分 (この agent) にだけ効く → **`/agent/claude`** (Claude の場合)
3. project に依らず、他の agent にも効く → **`/agent`**
4. mako 個人の情報・一回性の感想 → **書かない**

迷ったら `/agent/claude` に書き、後で他 agent にも効くと分かったら `/agent` に移す (supersede で置き換える)。
Layer 1 (local `~/.claude/projects/<project>/memory/*.md`) との関係: local memory は machine ローカルで
他 model / 他 machine から見えない。project 横断で残す気づきは local と `/agent/claude` の**両方**に書く。

## 読むタイミング

- project atlas: MCP server が cwd / branch から決めて「📌 直近の活動」を自動注入する (手動検索は必要になってから)
- `/agent` と `/agent/claude`: 自動注入は無い (creo-memories 側の todo)。作業に関係しそうな時に自分で読む:
  - `search({ atlasId: "agent", query: "<今の作業>" })`
  - `search({ atlasId: "claude", query: "<今の作業>" })`
  - ⚠️ `atlasId` 指定の検索は**子 atlas を含まない** (`agent` を検索しても `agent/claude` は出ない)。両方検索する

## 書き方

- tag に **`agent:claude`** を付ける (memory の user_id は mako の account で共通なので、誰が書いたかは tag でしか分からない)
- 発見日と由来 (どの session / project で気づいたか) を本文に書く
- 古い理解は `supersedes` で置き換える (削除より置換)。観察 → 原則 → 適用例は `derivedFrom` / `references` で繋ぐ
- 「今日も上手くできました」「やらかしました」だけの日記は書かない。**次に同じ局面で助かるか**だけが基準
