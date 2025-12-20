---
description: Save context to Creo Memories
---

# Remember Context

Save important context, decisions, or learnings to persistent memory.

## Usage

Use the `mcp__creo-memories__remember_context` tool with:

- `content` - The content to remember
- `category` - Category: prd, spec, design, config, debug, learning, task, decision
- `tags` - Array of tags for organization

## When to Remember

- Design decisions and their reasoning
- Technical discoveries and learnings
- Project turning points
- Agreements with users
- Unfinished tasks (for next session)

## Examples

```
remember_context({
  content: "Decided to use Stripe for payments because...",
  category: "decision",
  tags: ["payments", "stripe", "architecture"]
})
```
