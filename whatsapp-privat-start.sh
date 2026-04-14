#!/bin/bash
# Start WhatsApp Private Bridge (Port 8082)
# Only starts if not already running

BRIDGE_DIR="$HOME/Projects/02_Personal/whatsapp-mcp/whatsapp-bridge"
BRIDGE="$BRIDGE_DIR/whatsapp-bridge"
LOGFILE="$HOME/Projects/02_Personal/whatsapp-mcp/bridge.log"

if lsof -i :8082 -t &>/dev/null; then
  echo "WhatsApp Bridge already running on port 8082"
  exit 0
fi

echo "Starting WhatsApp Bridge..."
cd "$BRIDGE_DIR" && nohup "$BRIDGE" >> "$LOGFILE" 2>&1 &
echo "WhatsApp Bridge started (PID $!), log: $LOGFILE"
