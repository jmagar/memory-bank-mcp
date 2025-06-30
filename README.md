# Memory Bank MCP Server with Supergateway

[![smithery badge](https://smithery.ai/badge/@alioshr/memory-bank-mcp)](https://smithery.ai/server/@alioshr/memory-bank-mcp)
[![npm version](https://badge.fury.io/js/%40allpepper%2Fmemory-bank-mcp.svg)](https://www.npmjs.com/package/@allpepper/memory-bank-mcp)
[![npm downloads](https://img.shields.io/npm/dm/@allpepper/memory-bank-mcp.svg)](https://www.npmjs.com/package/@allpepper/memory-bank-mcp)

<a href="https://glama.ai/mcp/servers/ir18x1tixp"><img width="380" height="200" src="https://glama.ai/mcp/servers/ir18x1tixp/badge" alt="Memory Bank Server MCP server" /></a>

A Model Context Protocol (MCP) server implementation for remote memory bank management, enhanced with [Supergateway](https://github.com/supercorp-ai/supergateway) for streamable-http transport. Inspired by [Cline Memory Bank](https://github.com/nickbaumann98/cline_docs/blob/main/prompting/custom%20instructions%20library/cline-memory-bank.md).

## Overview

The Memory Bank MCP Server transforms traditional file-based memory banks into a centralized service that:

- Provides remote access to memory bank files via MCP protocol
- **NEW**: Supports streamable-http transport via Supergateway integration
- Enables multi-project memory bank management
- Maintains consistent file structure and validation
- Ensures proper isolation between project memory banks
- **NEW**: HTTP-based remote accessibility for web clients

## Features

- **Multi-Project Support**

  - Project-specific directories
  - File structure enforcement
  - Path traversal prevention
  - Project listing capabilities
  - File listing per project

- **Remote Accessibility**

  - Full MCP protocol implementation over HTTP
  - **NEW**: Streamable-http transport via Supergateway
  - Type-safe operations
  - Proper error handling
  - Security through project isolation
  - **NEW**: Container-ready deployment

- **Core Operations**
  - Read/write/update memory bank files
  - List available projects
  - List files within projects
  - Project existence validation
  - Safe read-only operations

## Quick Start with Docker (Recommended)

The easiest way to run the Memory Bank MCP Server is using Docker with our pre-configured setup:

```bash
# Clone the repository
git clone https://github.com/jmagar/memory-bank-mcp.git
cd memory-bank-mcp

# Start the service
docker-compose up -d

# The service will be available at:
# http://localhost:8102/mcp
```

### Docker Configuration

Our Docker setup includes:
- **Supergateway integration** for streamable-http transport
- **Persistent storage** with host volume mapping
- **Health checks** for reliability monitoring
- **Port 8102** for HTTP access

```yaml
# docker-compose.yaml
services:
  memory-bank-mcp:
    build: .
    ports:
      - "8102:8102"
    volumes:
      - /mnt/cache/appdata/memory-bank-mcp:/memory-bank
    environment:
      - MEMORY_BANK_ROOT=/memory-bank
    restart: unless-stopped
```

## Supergateway Integration

This version integrates [Supergateway](https://github.com/supercorp-ai/supergateway) to convert the stdio-based MCP server to streamable-http, enabling:

- **HTTP-based remote access** to memory bank functionality
- **Web client compatibility** for browser-based AI assistants
- **Container-friendly deployment** patterns
- **Built-in health monitoring** capabilities

### Architecture

```
┌─────────────────────────────────────────┐
│              MCP Clients                │
│     (Claude, Cursor, Web Apps)          │
└─────────────────┬───────────────────────┘
                  │ HTTP/Streamable-HTTP
                  │
┌─────────────────▼───────────────────────┐
│            Supergateway                 │
│     (Transport Layer Converter)         │
│   • stdio → streamable-http             │
│   • Port 8102 (/mcp endpoint)          │
└─────────────────┬───────────────────────┘
                  │ stdio
                  │
┌─────────────────▼───────────────────────┐
│        Memory Bank MCP Server          │
│   • Multi-project support              │
│   • File-based storage                 │
└─────────────────┬───────────────────────┘
                  │ File I/O
                  │
┌─────────────────▼───────────────────────┐
│          Persistent Storage             │
│   /mnt/cache/appdata/memory-bank-mcp    │
└─────────────────────────────────────────┘
```

## Traditional Installation (stdio)

For traditional stdio-based MCP clients, you can still install via npm:

```bash
npx -y @smithery/cli install @alioshr/memory-bank-mcp --client claude
```

## Configuration for MCP Clients

### Using with HTTP Clients (Streamable-HTTP)

For clients that support streamable-http transport, connect to:
```
http://localhost:8102/mcp
```

### Using with Claude Desktop (via Supergateway proxy)

```json
{
  "mcpServers": {
    "memory-bank-supergateway": {
      "command": "npx",
      "args": [
        "-y",
        "supergateway",
        "--streamableHttp",
        "http://localhost:8102/mcp"
      ]
    }
  }
}
```

### Traditional stdio Configuration

For traditional stdio-based setups:

```json
{
  "allpepper-memory-bank": {
    "command": "npx",
    "args": ["-y", "@allpepper/memory-bank-mcp"],
    "env": {
      "MEMORY_BANK_ROOT": "<path-to-bank>"
    },
    "disabled": false,
    "autoApprove": [
      "memory_bank_read",
      "memory_bank_write",
      "memory_bank_update",
      "list_projects",
      "list_project_files"
    ]
  }
}
```

## Custom AI Instructions

This project includes comprehensive custom instructions for AI assistants. See [custom-instructions.md](custom-instructions.md) for the complete memory bank workflow and patterns.

## Development

Basic development commands:

```bash
# Install dependencies
npm install

# Build the project
npm run build

# Run tests
npm run test

# Run tests in watch mode
npm run test:watch

# Run the server directly with ts-node for quick testing
npm run dev
```

### Local Development with Docker

```bash
# Build the Docker image
docker build -t memory-bank-mcp:local .

# Run with custom storage path
docker run -i --rm \
  -p 8102:8102 \
  -e MEMORY_BANK_ROOT="/memory-bank" \
  -v /path/to/your/memory-bank:/memory-bank \
  memory-bank-mcp:local

# Test the HTTP endpoint
curl http://localhost:8102/mcp
```

## Health Monitoring

The Docker container includes built-in health checks:

```bash
# Check container health
docker-compose ps

# View health check logs
docker-compose logs memory-bank-mcp

# Manual health check
curl -f http://localhost:8102/mcp
```

## Storage Configuration

### For Unraid Systems
The default configuration is optimized for Unraid:
```yaml
volumes:
  - /mnt/cache/appdata/memory-bank-mcp:/memory-bank
```

### For Other Systems
Modify the docker-compose.yaml volume mapping:
```yaml
volumes:
  - /your/host/path:/memory-bank
```

## Troubleshooting

### Container Won't Start
- Check if port 8102 is available: `netstat -tulpn | grep 8102`
- Verify volume permissions: `ls -la /mnt/cache/appdata/memory-bank-mcp`
- Check Docker logs: `docker-compose logs memory-bank-mcp`

### Health Check Failures
- Verify supergateway is running: `docker exec memory-bank-mcp ps aux`
- Test endpoint manually: `curl http://localhost:8102/mcp`
- Check container networking: `docker network ls`

### Storage Issues
- Ensure host directory exists: `mkdir -p /mnt/cache/appdata/memory-bank-mcp`
- Check permissions: `chmod 755 /mnt/cache/appdata/memory-bank-mcp`
- Verify volume mount: `docker exec memory-bank-mcp ls -la /memory-bank`

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Use TypeScript for all new code
- Maintain type safety across the codebase
- Add tests for new features
- Update documentation as needed
- Follow existing code style and patterns
- Test Docker configurations before submitting

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- This project implements the memory bank concept originally documented in the [Cline Memory Bank](https://github.com/nickbaumann98/cline_docs/blob/main/prompting/custom%20instructions%20library/cline-memory-bank.md)
- Enhanced with [Supergateway](https://github.com/supercorp-ai/supergateway) for streamable-http transport
- Extended with multi-project support and Docker containerization
