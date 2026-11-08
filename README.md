# Cloudflare Tunnel Stack (nginx + noVNC)

Reusable reference setup for exposing local services publicly via **Cloudflare quick tunnels** behind **nginx** with Basic Auth — designed for containers without systemd.

TL;DR chain: `cloudflared` (443) → `nginx` (local listener, Basic Auth) → upstream (websockify/noVNC, web app, or API gateway).

## Contents
- `nginx/` — sample nginx site configs for the different tunnel fronts:
  - `cursor_tunnel.nginx.conf` — protect a local web app (Cursor web chat → 8795).
  - `nb_tunnel.nginx.conf` — protect the nanobot gateway (→ 8765).
  - `demo.nginx.conf` — desktop + demo combo (noVNC 6080 + demo 8000).
  - `demo_orgo.nginx.conf` — proxy out to https://www.orgo.ai.
  - `demo_appubot.nginx.conf` — AppuBot noVNC with auto-connect (`${VNC_PASS}` placeholder).
- `start_appu.sh`, `start_appu_vnc.sh`, `start_appu_supervisor.sh` — guardian launchers (clean env via `env -i`, detached via `setsid`) for Electron desktop apps under a containerized supervisor.

## Pattern / gotchas
- **Auth:** use `auth_basic` + `auth_basic_user_file` with an `.htpasswd` file generated locally (`.htpasswd` is never committed). Generate with `htpasswd -c .htpasswd admin` (or `openssl passwd -apr1`).
- **Redirects:** use `absolute_redirect off` to strip the upstream port from `Location` redirects.
- **`return` bypasses auth** — the rewrite phase runs before htpasswd; use `location` + `auth_basic` instead of `return` when you need protection.
- **No systemd:** run background services with `nohup`/`setsid` and log to files.
- **Quick tunnels change URL on restart** — re-read the latest URL from the tunnel log (`cloudflared tunnel --url <local-listener>` log).
- **Caddy note:** this build's Caddy does not recognize `basic_auth`; use nginx for Basic Auth.

## Example
```bash
# start cloudflared pointing at an nginx listener
cloudflared tunnel --url http://127.0.0.1:8090 &> tunnel.log &

# nginx config (see nginx/*.conf), then
nginx -c /path/to/nginx.conf -t
nginx -c /path/to/nginx.conf
```
