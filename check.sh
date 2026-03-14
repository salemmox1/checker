#!/bin/bash

# التحقق من المدخلات
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "❌ Usage: bash $0 <BOT_TOKEN> <CHAT_ID>"
    exit 1
fi

TOKEN=$1
CHAT_ID=$2

echo "--- Analyzing Hardware (Multi-Distro Support) ---"

# 1. جلب اسم المعالج بطريقة مضمونة
CPU_MODEL=$(grep -m 1 "model name" /proc/cpuinfo | cut -d':' -f2 | sed -e 's/^[[:space:]]*//')
[ -z "$CPU_MODEL" ] && CPU_MODEL=$(lscpu | grep "Model name" | cut -d':' -f2 | sed -e 's/^[[:space:]]*//')

# 2. عدد الأنوية
CPU_CORES=$(nproc)

# 3. حجم الكاش (L3)
L3_CACHE=$(lscpu | grep "L3 cache" | cut -d':' -f2 | sed -e 's/^[[:space:]]*//' || echo "N/A")

# 4. الرام (RAM) - استخدام awk بشكل أدق
RAM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
RAM_AVAIL=$(free -h | awk '/^Mem:/ {print $7}')

# 5. النظام والـ IP
OS_NAME=$(grep '^PRETTY_NAME' /etc/os-release | cut -d'=' -f2 | tr -d '"')
HOSTNAME=$(hostname)
IP_ADDR=$(curl -s https://api.ipify.org || echo "Internal Only")

# 6. حسبة الهاش ريت التقديرية
ESTIMATED_HS=$((CPU_CORES * 550))

# 7. تجهيز الرسالة
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

# 8. الإرسال مع فحص حالة الإرسال
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
    -d "chat_id=$CHAT_ID" \
    -d "text=$MESSAGE" \
    -d "parse_mode=Markdown")

if [ "$RESPONSE" == "200" ]; then
    echo "✅ Report Sent Successfully to Telegram."
else
    echo "❌ Failed to send. Error Code: $RESPONSE (Check Token/ChatID)"
fi
