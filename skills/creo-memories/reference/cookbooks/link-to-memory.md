# Cookbook: Memory 間 link を貼る (`[title](mem_xxx)`)

> **v0.34+** memory 本文 (markdown) で他 memory を直接 link できる。 CREO-156 で導入。

## 1. なぜ

過去 memory の id を **plain text で書く** だけだと、 reader (人 / agent) は
search 画面に戻って ID 検索する必要があり friction が高い。 内部 link を
使えば 1 click で navigate、 memory 間の関係性が可視化される。

## 2. 記法

### 明示形式 (Phase 1、 v0.34 で利用可能)

```markdown
この決定は [元の議論](mem_1CZCk1Zg8cQpiLvjqqDKNA) を踏まえている。
派生元: [Phase 0 設計 spark](mem_1CaaLAtsYRhWgpPhnrvaVd)
```

- `[label](mem_xxx)` 構文 (標準 markdown link)
- `mem_xxx` は memory の **EntId 略記** (= `mem_` prefix + Base58)
- label は任意 — 「元の議論」「Phase 0 設計」 等、 文脈に合わせて
- 既存の atlas / concept ID (`atl_xxx` / `tag_xxx` 等) は **対象外** (Phase 4 で plugin 拡張検討)

### bare auto-link (Phase 1.5、 未実装)

```markdown
これは mem_xxx を参照している。  ← 将来的にこれだけで auto-link
```

未実装。 Phase 1 では `[]()` 構文必須。

## 3. 表示時の挙動 (context 別)

### creo-web 内 (logged-in)

- click → SPA navigation で `/memories/mem_xxx` に遷移
- 現タブ内、 page reload なし
- private memory でも owner なら表示

### claude.ai / 外部 MCP client 経由

- `get_memory` / `search` 等 で content を return する時、 link が
  **自動で full URL に展開** される: `[label](https://creo-memories.in/r/mem_xxx)`
- claude.ai は標準 anchor として render、 click で URL に飛ぶ
- public memory は誰でも閲覧、 private は auth gate が出る

### 標準 markdown viewer (Slack, GitHub, etc)

- MCP tool 経由で取得した content は full URL に展開済 → そのまま動く
- 本文を直接 copy-paste した場合 (storage は shorthand) → 標準 viewer では
  「link 化されていない `[label](mem_xxx)` text」 として表示される。
  この場合は手動で展開が必要

## 4. いつ使うか

### 推奨される pattern

- **派生元の明示** — `[元の議論](mem_xxx)` で根拠 memory を pin
- **continuity** — 序破離 chain (supersedes) を文中で言及する時に link
- **dogfood レポート** — bug 報告 memory から fix memory への link
- **decision record** — ADR style で 「これは X 決定 (`mem_xxx`) を更新する」

### 避けるべき pattern

- **過剰 link** — 全 ID に link を貼ると noise になる、 文脈上意味のある所だけ
- **broken link** — 削除予定の memory に link しない (forgotten 機能で死ぬ)
- **循環参照** — A→B→A の両 link は graph が複雑化、 1 方向で十分

## 5. 関連 cookbook

- [`fetch-memory-by-id.md`](./fetch-memory-by-id.md) — id から memory 取得 (workaround 不要、 v0.30+ で `read({resource:"memory", id})` 直対応)
- [`decision-record.md`](./decision-record.md) — ADR 形式で memory を残す時の流れ、 link 多用 candidate
- [`session-snapshot.md`](./session-snapshot.md) — session goal pin、 過去 snapshot に link 貼る時に活用

## 6. Future (Phase 2+)

- **Hover preview** — link 上 hover で memory snippet 表示
- **Editor autocomplete** — `mem_` typing で memory title 候補リスト
- **Backlinks** — incoming references 自動派生 (graph view)
- **Permission-aware** — private memory link は 🔒 placeholder で render
- **Other entities** — atlas / concept / todo への link (`[a](atl_xxx)` 等)、 Phase 4 で creo-ui に linkResolver prop 追加して横展開

## 7. 例: 序破離 chain と組み合わせ

```markdown
# Memory: VP Phase 6 設計決定 (2026-05-02)

## 起点

[Phase 5-D dogfooding](mem_1CaVeQEKXd8U2XHn75RD4M) で発見した課題を
踏まえ、 Phase 6 で Lane manifest を導入する。

## 設計

[初版 spark](mem_1CaYh3KnhmTvXU2NZW8cJ4) では root 1 pane で
runtime split を提案、 本 memory はそれを **supersede** する。

## 関連
- 親 epic: [VP Phase Roadmap](mem_1CaVeTysipdgVHoxwxUcPj)
- pair: [Hub Federation 仕様](mem_1CaVeTysipdgVHoxwxUcPj)
```

→ render 時、 5 つの link が click 可能になり、 reader は graph traversal で
context を素早く構築できる。

## Reference

- Linear: [CREO-156](https://linear.app/chronista/issue/CREO-156) (本機能の起点)
- 関連 PR: #368 (Phase 1 実装)
- 設計 pattern: Notion / Obsidian / Linear / GitHub の 「保存 shorthand + render expansion」
