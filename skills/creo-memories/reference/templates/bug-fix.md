# <Bug 簡潔タイトル>

> Layer 2 cloud memory として保存。 cookbook: `../cookbooks/bug-fix.md`

## 症状

<observe された症状、 stack trace、 reproduction steps>

## 原因

<root cause、 specifically 何が壊れていたか>

## 解決策

<何を fix したか — code change の概要、 PR link>

## 再発防止

- <予防策 1: 例えば test 追加、 lint rule、 type 強化>
- <予防策 2: documentation、 review checklist 化>

## 関連

- PR: <url>
- 関連 memory: ...
- 関連 issue: <Linear ID>

---

## remember 呼び出し例

```
mcp__creo-memories__remember({
  content: <上記 markdown>,
  category: 'debug',
  status: 'done',
  atlasId: '<project>',
  conceptIds: ['bug', '<tech stack tag>']
})
+ link_external (Linear / GitHub)
```

過去類似 bug があれば:
```
remember({
  content,
  extends: ['mem_root_cause_pattern']  // 同じ root cause pattern の延長
})
```
