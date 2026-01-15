# Project Context

## Purpose

Agent Assistant is a system designed to extend and enhance interactions between AI agents and human users. It allows AI agents to maintain long-running, multi-turn conversations and tasks with users through a persistent web or mobile interface.

Key components:

1.  **agentassistant-mcp**: An MCP (Model Context Protocol) server that provides tools (`ask_question`, `task_finish`) for AI agents.
2.  **agentassistant-srv**: The main server handling RPC requests from the MCP server and managing WebSocket connections with user clients.
3.  **Clients**: A Web interface (Vue/Quasar) and a Flutter client (Mobile/Desktop) for user interaction.

## Tech Stack

- **Backend**: Go (1.24+), Connect-Go (RPC), Gorilla WebSocket, mark3labs/mcp-go.
- **Web Frontend**: TypeScript, Vue 3, Quasar Framework, Vite, Pinia, Protobuf-ES.
- **Mobile/Desktop Client**: Flutter (Dart), Provider, Protobuf.
- **Protocol**: Protocol Buffers (Protobuf) for both RPC and WebSocket communication.

## Project Conventions

### Code Style

- **Go**: Follow standard Go conventions. Use `slog` for logging. Run `golangci-lint` for analysis.
- **Web**: Use TypeScript. Follow ESLint and Prettier configurations.
- **Flutter**: Follow `flutter_lints` recommendations.
- **General**:
  - Use Git for version control.
  - Use UUID v7 for IDs where applicable.
  - Use UTC for timestamps.

### Architecture Patterns

- **MCP-based Interaction**: The system uses the Model Context Protocol to expose capabilities to AI agents.
- **RPC & WebSocket**:
  - `agentassistant-mcp` communicates with `agentassistant-srv` via Connect-Go RPC.
  - `agentassistant-srv` broadcasts messages to clients via WebSockets.
- **Broadcast Mechanism**: Requests from the AI (via MCP) are broadcast to all connected clients sharing the same token.

### Testing Strategy

- **Go**: `go test ./...` for backend logic.
- **Web**: Vitest for unit/component testing.
- **Flutter**: `flutter_test` for widget and unit tests.

### Git Workflow

- Commit messages should be clear and descriptive.
- Work on feature branches and merge via PRs (implied standard).

## Domain Context

- **MCP (Model Context Protocol)**: Understanding of tools, resources, and prompts within the MCP ecosystem.
- **Agentic Workflow**: The system supports "Human-in-the-loop" workflows where the Agent asks questions or reports task completion.
- **Session Management**: Token-based authentication links the MCP server, Main server, and Clients.

## Important Constraints

- **Cross-Platform**: The system must run on Linux, Windows, and macOS.
- **Real-time**: Low latency is expected for WebSocket communications.
- **Compatibility**: Web client must work in modern browsers; Flutter client must support targeted mobile/desktop platforms.

## External Dependencies

- **AI Agents**: The system is designed to be driven by AI agents (e.g., Claude, Gemini) capable of using MCP tools.
