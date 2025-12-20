---
description: List and manage todos
---

# Todo Management

Create and manage todos in Creo Memories.

## List Todos

Use `mcp__creo-memories__list_todos` to see all todos.

## Create Todo

Use `mcp__creo-memories__create_todo` with:

- `content` - Todo description
- `priority` - high, medium, or low
- `tags` - Array of tags

## Examples

```
# Create a todo
create_todo({
  content: "Implement user authentication",
  priority: "high",
  tags: ["auth", "sprint-1"]
})

# List all todos
list_todos()
```
