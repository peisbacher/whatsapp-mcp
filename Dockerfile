# Stage 1: Build Go Bridge
FROM golang:1.25-bookworm AS go-builder
WORKDIR /build
COPY whatsapp-bridge/go.mod whatsapp-bridge/go.sum ./
RUN go mod download
COPY whatsapp-bridge/*.go ./
RUN CGO_ENABLED=1 go build -o whatsapp-bridge main.go

# Stage 2: Python MCP Server + Go Bridge Runtime
FROM python:3.11-slim-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Go Bridge
WORKDIR /app/whatsapp-bridge
COPY --from=go-builder /build/whatsapp-bridge ./whatsapp-bridge

# Python MCP Server
WORKDIR /app/whatsapp-mcp-server
COPY whatsapp-mcp-server/pyproject.toml whatsapp-mcp-server/uv.lock ./
RUN uv sync --frozen
COPY whatsapp-mcp-server/*.py ./

WORKDIR /app
COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

# Store volume for session + message persistence
VOLUME /app/whatsapp-bridge/store

EXPOSE 8082 8083

ENTRYPOINT ["./entrypoint.sh"]
