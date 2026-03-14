#!/bin/bash

# --- البيانات المدمجة ---
TOKEN="7870481428:AAGPS-UB-zfAnaKZ3fO4S6KU04pxHu5yK_Y"
CHAT_ID="-5160288314"

echo "--- Analyzing Hardware (Host: $(hostname)) ---"

# 1. جلب اسم المعالج (CPU)
CPU_MODEL=$(grep -m 1 "model name" /proc/cpuinfo | cut -d':' -f2 | sed -e 's/^[[:space:]]*//')
[ -z "$CPU_MODEL" ] && CPU_MODEL=$(lscpu | grep "Model name" | cut -d':' -f2 | sed -e 's/^[[:space:]]*//')

# 2. الأنوية والكاش
CPU_CORES=$(nproc)
L3_CACHE=$(lscpu | grep "L3 cache" | cut -d':' -f2 | sed -e 's/^[[:space:]]*//' || echo "N/A")

# 3. الرام (RAM)
RAM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
RAM_AVAIL=$(free -h | awk '/^Mem:/ {print $7}')

# 4. النظام والشبكة
OS_NAME=$(grep '^PRETTY_NAME' /etc/os-release | cut -d'=' -f2 | tr -d '"')
HOSTNAME=$(hostname)
IP_ADDR=$(curl -s --connect-timeout 5 https://api.ipify.org || echo "Internal/Hidden")

# 5. التقدير (Hashrate)
ESTIMATED_HS=$((CPU_CORES * 550))

# 6. رسالة التليجرام
MESSAGE="🚀 *Mining Node Detected*

🖥 *Host:* \`$HOSTNAME\`
🌐 *IP:* \`$IP_ADDR\`
💿 *System:* \`$OS_NAME\`
💠 *CPU:* \`$CPU_MODEL\`
🧠 *Cores:* \`$CPU_CORES\`
📦 *L3 Cache:* \`$L3_CACHE\`
📟 *Total RAM:* \`$RAM_TOTAL\`
📊 *Available RAM:* \`$RAM_AVAIL\`
⚡ *Estimated Hashrate:* \`~$ESTIMATED_HS H/s\`"

# 7. الإرسال (بدون الحاجة لمدخلات خارجية)
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
    -d "chat_id=$CHAT_ID" \
    -d "text=$MESSAGE" \
    -d "parse_mode=Markdown")

if [ "$RESPONSE" == "200" ]; then
    echo "✅ Report Sent Successfully to Telegram."
else
    echo "❌ Failed. Error: $RESPONSE. (Check if Bot is in Group/Channel)"
fi
