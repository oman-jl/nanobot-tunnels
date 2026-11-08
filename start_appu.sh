#!/bin/bash
# Launcher for AppuBot under supervisor.
# Sets a sane environment explicitly because supervisor's minimal env
# breaks Electron's X11 window creation.
export DISPLAY=":1"
export HOME="/root"
export XDG_RUNTIME_DIR="/tmp/xdg-runtime-root"
mkdir -p "$XDG_RUNTIME_DIR" 2>/dev/null || true
chmod 700 "$XDG_RUNTIME_DIR" 2>/dev/null || true
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
cd /tmp/squashfs-root || exit 1
env > /tmp/appu_env_dump.txt 2>/dev/null
exec ./appubot --no-sandbox --disable-gpu
