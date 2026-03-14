#!/bin/bash


if [ -z "$1" ] || [ -z "$2" ]; then
    echo "❌ Usage: bash $0 <BOT_TOKEN> <CHAT_ID>"
    exit 1
fi

TOKEN=$1
CHAT_ID=$2

echo "--- Analyzing Hardware (Bare Metal) ---"

CPU_MODEL=$(lscpu | grep "Model name" | cut -d':' -f2 | sed -e 's/^[[:space:]]*//')
CPU_CORES=$(nproc)
L3_CACHE=$(lscpu | grep "L3 cache" | cut -d':' -f2 | sed -e 's/^[[:space:]]*//' || echo "N/A")

RAM_TOTAL=$(free -h | grep "Mem:" | awk '{print $2}')
RAM_AVAIL=$(free -h | grep "Mem:" | awk '{print $7}')

OS_NAME=$(grep '^PRETTY_NAME' /etc/os-release | cut -d'=' -f2 | tr -d '"')
HOSTNAME=$(hostname)

ESTIMATED_HS=$((CPU_CORES * 550))

MESSAGE="🚀 *Mining Node Detected*

🖥 *Host:* \`$HOSTNAME\`
💿 *System:* \`$OS_NAME\`
💠 *CPU:* \`$CPU_MODEL\`
🧠 *Cores:* \`$CPU_CORES\`
📦 *L3 Cache:* \`$L3_CACHE\`
📟 *Total RAM:* \`$RAM_TOTAL\`
📊 *Available RAM:* \`$RAM_AVAIL\`
⚡ *Estimated Hashrate:* \`~$ESTIMATED_HS H/s\`"

curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
    -d "chat_id=$CHAT_ID" \
    -d "text=$MESSAGE" \
    -d "parse_mode=Markdown" > /dev/null

echo "✅ Report Sent to Telegram (Host: $HOSTNAME)"
