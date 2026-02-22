# Creo Memories Plugin

Persistent memory system for Claude Code. Remember context, decisions, and learnings across sessions with semantic search and automatic context delivery.

## Features

- **Context Engine** (v3.0) - Automatically provides past memories at session start via instructions injection; related memories are attached when saving new ones
- **Semantic Search** - Find relevant memories by meaning, not just keywords
- **Labels & Categories** - Flexible organization with user-defined labels and categories
- **Atlas** - Hierarchical tree structures to organize memories by project or topic
- **Todo Management** - Create and track todos with priorities and completion
- **Session Hooks** - Automatic reminders to save important decisions at key moments

## Installation

### From GitHub

```bash
/install chronista-club/claude-plugin-creo-memories
```

### Manual Setup

```bash
claude mcp add --transport http creo-memories https://mcp.creo-memories.in
```

Or add to `.mcp.json`:

```json
{
  "mcpServers": {
    "creo-memories": {
      "type": "http",
      "url": "https://mcp.creo-memories.in"
    }
  }
}
```

## Context Engine

Introduced in v3.0, the Context Engine eliminates the need for manual memory retrieval at session start.

- **Instructions injection** - Recent memories and open todos are automatically displayed when a session begins
- **Remember response enrichment** - When saving a memory with `remember`, related past memories are automatically attached to the response
- **MCP Resource** - Access the current session context via `memory://context/session`

## MCP Tools

### Memory (Core)

| Tool | Description |
|------|-------------|
| `remember` | Save a memory (related memories auto-attached in response) |
| `search` | Semantic search with optional filters |
| `update_memory` | Partial update (preserves ID, regenerates embedding on content change) |
| `forget` | Delete a memory |

### Labels

| Tool | Description |
|------|-------------|
| `label_create` | Create a label |
| `label_list` | List all labels |
| `label_update` | Update a label |
| `label_delete` | Delete a label |
| `label_attach` | Attach a label to a memory |
| `label_detach` | Detach a label from a memory |
| `label_get_by_memory` | Get all labels for a memory |

### Categories

| Tool | Description |
|------|-------------|
| `category_list` | List all categories |
| `category_create` | Create a category |
| `category_update` | Update a category |
| `category_delete` | Delete a category |
| `category_attach` | Attach a category to a memory |
| `category_detach` | Detach a category from a memory |
| `category_get_by_memory` | Get all categories for a memory |
| `category_replace_for_memory` | Replace all categories on a memory at once |

### Atlas (Hierarchical Knowledge Structure)

Atlas provides hierarchical tree structures for organizing memories by project, topic, or any grouping.

| Tool | Description |
|------|-------------|
| `create_atlas` | Create an atlas |
| `list_atlas` | List all atlases |
| `get_atlas_tree` | Get the tree structure of an atlas |
| `update_atlas` | Update an atlas |
| `delete_atlas` | Delete an atlas |

### Todos

| Tool | Description |
|------|-------------|
| `create_todo` | Create a todo |
| `list_todos` | List all todos |
| `update_todo` | Update a todo |
| `complete_todo` | Mark a todo as complete |
| `delete_todo` | Delete a todo |

### Session & User

| Tool | Description |
|------|-------------|
| `get_session` | Get session information |
| `get_status` | Get server status |
| `end_session` | End the current session |
| `get_user` | Get user information |
| `generate_api_key` | Generate an API key for programmatic access |

### Domain Shared Keys

API-key-based shared access management.

| Tool | Description |
|------|-------------|
| `create_domain_shared_key` | Create a shared key |
| `list_domain_shared_keys` | List shared keys |
| `revoke_domain_shared_key` | Revoke a shared key |
| `delete_domain_shared_key` | Delete a shared key |

### Logs

| Tool | Description |
|------|-------------|
| `get_logs` | Retrieve logs |
| `search_logs` | Search logs |

## Setup

1. Install the plugin
2. On first use, you will be prompted to authenticate via OAuth (Auth0)
3. Sign in with your Google or GitHub account
4. Authentication is handled automatically after initial setup

## Authentication

- **OAuth** (default) - Browser-based Auth0 authentication, used by Claude Code
- **API Key** - For programmatic access; generate with `generate_api_key` and use via `Authorization: Bearer <key>` header

## Requirements

- Claude Code
- Creo Memories account (free tier available)

## Links

| | URL |
|---|-----|
| MCP Endpoint | `https://mcp.creo-memories.in` |
| Web Viewer | `https://creo-memories.in` |

## License

MIT
