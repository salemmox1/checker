#!/bin/bash

# --- البيانات المدمجة (تم التأكد منها) ---
TOKEN="7870481428:AAGPS-UB-zfAnaKZ3fO4S6KU04pxHu5yK_Y"
CHAT_ID="-5160288314"

# 1. جمع معلومات الهاردوير
CPU_MODEL=$(grep -m 1 "model name" /proc/cpuinfo | cut -d':' -f2 | sed -e 's/^[[:space:]]*//')
[ -z "$CPU_MODEL" ] && CPU_MODEL=$(lscpu | grep "Model name" | cut -d':' -f2 | sed -e 's/^[[:space:]]*//')
CPU_CORES=$(nproc)
L3_CACHE=$(lscpu | grep "L3 cache" | cut -d':' -f2 | sed -e 's/^[[:space:]]*//' || echo "N/A")
RAM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
RAM_AVAIL=$(free -h | awk '/^Mem:/ {print $7}')
OS_NAME=$(grep '^PRETTY_NAME' /etc/os-release | cut -d'=' -f2 | tr -d '"')
HOSTNAME=$(hostname)
IP_ADDR=$(curl -s --connect-timeout 5 https://api.ipify.org || echo "Internal/Hidden")

# 2. حسبة الهاش ريت
ESTIMATED_HS=$((CPU_CORES * 550))

# 3. تجهيز الرسالة بتنسيق نظيف
MESSAGE="🚀 *Mining Node Detected*

🖥 *Host:* $HOSTNAME
🌐 *IP:* $IP_ADDR
💿 *System:* $OS_NAME
💠 *CPU:* $CPU_MODEL
🧠 *Cores:* $CPU_CORES
📦 *L3 Cache:* $L3_CACHE
📟 *Total RAM:* $RAM_TOTAL
📊 *Available RAM:* $RAM_AVAIL
⚡ *Estimated Hashrate:* ~$ESTIMATED_HS H/s"

# 4. الإرسال باستخدام طريقة JSON (أكثر استقراراً وتجنباً لخطأ 400)
curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
     -H "Content-Type: application/json" \
     -d "{\"chat_id\": \"$CHAT_ID\", \"text\": \"$MESSAGE\", \"parse_mode\": \"Markdown\"}" > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ Success: Report sent to Telegram."
else
    echo "❌ Error: Failed to send report."
fi
