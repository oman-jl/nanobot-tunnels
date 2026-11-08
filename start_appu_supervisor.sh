#!/bin/bash
# Guardian launcher for AppuBot under supervisord.
# Supervisord direct-spawn hangs this Electron app (no window, no gateway,
# empty output). Detached launches are verified working, so we launch detached
# and babysit the child so supervisord keeps lifecycle control.
export DISPLAY=":1"
export HOME="/root"
export XDG_RUNTIME_DIR="/tmp/xdg-runtime-root"
mkdir -p "$XDG_RUNTIME_DIR" 2>/dev/null || true
chmod 700 "$XDG_RUNTIME_DIR" 2>/dev/null || true
cd /tmp/squashfs-root || exit 1

# Neutralize supervisord-inherited env vars that slow/hang Electron startup
unset SUPERVISOR_ENABLED SUPERVISOR_GROUP_NAME SUPERVISOR_PROCESS_NAME SUPERVISOR_SERVER_URL 2>/dev/null || true

# Clear any stale instance
pkill -x appubot 2>/dev/null
sleep 1

# Launch detached with a clean, known-good environment (env -i).
# Inheriting the full supervisord env slows/hangs Electron startup (1s->21s+
# and can SIGTRAP). This baseline brings the gateway up reliably in ~1s.
setsid env -i HOME=/root LANG=C.UTF-8 TERM=xterm PYTHONUNBUFFERED=1 DISPLAY=:1 \
    ./appubot --no-sandbox --disable-gpu \
    >> /var/log/appubot/electron.log 2>&1 < /dev/null &
APP=$!
echo "AppuBot launched pid $APP"

cleanup() {
    kill "$APP" 2>/dev/null || true
    wait "$APP" 2>/dev/null || true
}
trap cleanup TERM INT

while kill -0 "$APP" 2>/dev/null; do
    sleep 5
done
echo "AppuBot exited (pid $APP)"
exit 0
