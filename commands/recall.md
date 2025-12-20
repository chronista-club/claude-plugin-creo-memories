---
description: Search memories semantically
---

# Recall Memories

Search for relevant memories using semantic search.

## Usage

Use the `mcp__creo-memories__recall_relevant` tool with:

- `query` - Natural language search query
- `threshold` - Similarity threshold (0.0-1.0, default 0.7)

## When to Recall

- At session start to understand context
- Before making design decisions
- When referencing past discussions
- When continuing unfinished work

## Examples

```
recall_relevant({
  query: "authentication system design",
  threshold: 0.7
})
```
