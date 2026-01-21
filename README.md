# Creo Memories Plugin

Claude Code plugin for persistent memory across sessions.

## Features

- **Semantic Search** - Find relevant memories by meaning
- **Category System** - Organize memories (prd, spec, design, config, debug, learning, task, decision)
- **Todo Management** - Create and track todos with priorities
- **Session Continuity** - Maintain context across Claude Code sessions

## Installation

### Marketplace (Recommended)

```bash
# Add marketplace
claude plugin marketplace add chronista-club/claude-plugins

# Install plugin
claude plugin install creo-memories
```

### Direct from GitHub

```bash
claude plugin install gh:chronista-club/claude-plugin-creo-memories
```

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

## Setup

1. Sign up at [creo-memories.in](https://creo-memories.in)
2. Install the plugin
3. On first use, you'll be prompted to authenticate via Auth0

## Requirements

- Creo Memories account (free tier available)

## Pricing

| Plan | Price | Memory Limit |
|------|-------|--------------|
| Free | $0 | 500 memories |
| Pro | TBD/month | Unlimited |

## License

MIT
