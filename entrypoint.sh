#!/bin/bash
set -e

echo "Starting WhatsApp Bridge..."
cd /app/whatsapp-bridge
./whatsapp-bridge &
BRIDGE_PID=$!

# Wait for bridge to be ready
for i in $(seq 1 30); do
    if curl -s http://localhost:8082/api > /dev/null 2>&1; then
        echo "WhatsApp Bridge ready on port 8082"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "WARNING: Bridge did not respond after 30s, starting MCP server anyway"
    fi
    sleep 1
done

echo "Starting MCP Server on port 8083..."
cd /app/whatsapp-mcp-server
uv run main.py &
MCP_PID=$!

# Trap signals for graceful shutdown
trap "kill $BRIDGE_PID $MCP_PID 2>/dev/null; exit 0" SIGTERM SIGINT

# Wait for either process to exit
wait -n $BRIDGE_PID $MCP_PID
echo "A process exited, shutting down..."
kill $BRIDGE_PID $MCP_PID 2>/dev/null
exit 1
