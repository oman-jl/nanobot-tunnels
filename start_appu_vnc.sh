#!/bin/bash
# AppuBot remote desktop: start Xtightvnc :1, then bring up the XFCE
# desktop session so the AppuBot Electron window has a window manager to map
# into (without a WM the app window stays unmapped/tiny).

/usr/bin/Xtightvnc :1 -desktop X -auth /root/.Xauthority -geometry 1440x900 \
  -depth 24 -rfbwait 120000 -rfbauth /root/.vnc/passwd -rfbport 5901 \
  -fp /usr/share/fonts/X11/misc/,/usr/share/fonts/X11/Type1/,/usr/share/fonts/X11/75dpi/,/usr/share/fonts/X11/100dpi/ \
  -co /etc/X11/rgb -localhost -nolisten tcp &
XVNC=$!

# Wait for the :1 display socket.
for _ in $(seq 1 30); do
  [ -S /tmp/.X11-unix/X1 ] && break
  sleep 1
done
sleep 2

# Launch the desktop session (idempotent: skip if one is already running).
if ! pgrep -f '^xfce4-session' >/dev/null; then
  DISPLAY=:1 HOME=/root nohup xfce4-session >/var/log/appubot/xfce.log 2>&1 &
fi

wait $XVNC
