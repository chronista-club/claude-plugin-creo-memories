# Creo Memories Plugin

Claude Code plugin for persistent memory across sessions.

## Features

- **Semantic Search** - Find relevant memories by meaning
- **Category System** - Organize memories (prd, spec, design, config, debug, learning, task, decision)
- **Todo Management** - Create and track todos with priorities
- **Session Continuity** - Maintain context across Claude Code sessions

## Installation

```bash
# From official marketplace (coming soon)
claude plugin install creo-memories@claude-plugins-official

# Or from GitHub
/plugin marketplace add chronista-club/claude-plugins
claude plugin install creo-memories@chronista-plugins
```

## Commands

| Command | Description |
|---------|-------------|
| `/creo-memories:remember` | Save context to memory |
| `/creo-memories:recall` | Search memories semantically |
| `/creo-memories:todos` | List and manage todos |

## MCP Tools

This plugin provides the following MCP tools:

| Tool | Description |
|------|-------------|
| `remember_context` | Save memory with category and tags |
| `recall_relevant` | Semantic search for memories |
| `search_memories` | Advanced search with filters |
| `list_recent_memories` | Get recent memories |
| `create_todo` | Create a new todo |
| `list_todos` | List all todos |

## Categories

| Category | Purpose |
|----------|---------|
| `prd` | Product requirements (business layer) |
| `spec` | Functional/non-functional specifications |
| `design` | Architecture, design decisions |
| `config` | Configuration, environment setup |
| `debug` | Bug causes, solutions |
| `learning` | Learnings, best practices |
| `task` | Tasks, future plans |
| `decision` | Important decisions and reasoning |

## Requirements

- Creo Memories MCP server must be running
- Authentication token for the service

## Pricing

| Plan | Price | Memory Limit |
|------|-------|--------------|
| Free | $0 | 500 memories |
| Pro | TBD/month | Unlimited |

## License

MIT
