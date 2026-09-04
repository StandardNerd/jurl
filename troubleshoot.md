# Proxmox LXC Container Troubleshooting & Deployment Guide (CT 101 & CT 102)

## Executive Summary

This document details the diagnosis, resolution steps, and architectural rationale for establishing connectivity and service stability between LXC container **101** (`phoenix-app`) and LXC container **102** (`postgres-db`) on the Proxmox host (`192.168.1.19`).

---

## 1. System Architecture & Component Mapping

| Container ID | Hostname | IP Address | Primary Role | Core Services |
| :--- | :--- | :--- | :--- | :--- |
| **CT 102** | `postgres-db` | `192.168.1.20` | Database Layer | PostgreSQL 15 (port 5432) |
| **CT 101** | `phoenix-app` | `192.168.1.21` | Application Layer | Phoenix 1.7 Release (`jurl.service` on port 4000), Nginx Proxy (port 80) |

---

## 2. Diagnostics & Root Cause Analysis

### Initial Status Inspection
- Both LXC containers (`101` and `102`) were in a `running` state in Proxmox (`pct list`).
- Network bridge `vmbr0` provided proper ICMP reachability (`ping 192.168.1.20` from CT 101 succeeded).

### Findings in LXC 102 (`postgres-db`)
- PostgreSQL 15 was running and listening on `0.0.0.0:5432`.
- Database `jurl_prod` and user `jurl` were present.
- `pg_hba.conf` contained authorization rules for IP `192.168.1.21/32`.

### Findings in LXC 101 (`phoenix-app`)
- The Phoenix application was not running; `/opt/jurl`, `/etc/jurl/jurl.env`, and `/etc/systemd/system/jurl.service` were completely missing.
- Rebuilding the application inside LXC 101 exposed three build-time environment deficiencies:
  1. **Elixir Version Incompatibility**: The default Debian package installed Elixir 1.14.0, which caused compilation failures in `:hpax` (requires Elixir `>= 1.15`).
  2. **Missing Erlang C Headers**: Compiling `:bcrypt_elixir` failed due to missing `erl_nif.h` (`erlang-dev` package missing).
  3. **Missing Erlang XML Header**: Compiling `:swoosh` failed due to missing `xmerl.hrl` (`erlang-xmerl` package missing).

---

## 3. Step-by-Step Resolution & Rationale

### Step 3.1: PostgreSQL Configuration & User Credentials (CT 102)
- **Action**: Verified `listen_addresses = '*'` in `postgresql.conf` and explicitly reset user `jurl` password to match production environment settings (`jurl_prod_secret_pass_2026`).
- **Rationale**: Ensures the database server accepts external connections from CT 101 and guarantees password authentication parity with the application connection URI.

### Step 3.2: Application Build Environment Upgrade (CT 101)
- **Action**:
  1. Installed `erlang-dev` and `erlang-xmerl` packages via `apt-get`.
  2. Downloaded and unpacked precompiled Elixir 1.15.7 (built for OTP 25) into `/usr/local` and updated system binaries.
- **Rationale**: Provides required native C/Erlang development headers for NIF compilation and fulfills language syntax requirements for modern Hex dependencies.

### Step 3.3: Code Transfer, Dependency Compilation & Asset Deployment (CT 101)
- **Action**:
  1. Packed host codebase `/root/heuristicsyndicate/projects/jurl` into `/tmp/jurl-src.tar.gz` and pushed it into CT 101 via `pct push`.
  2. Extracted source to `/tmp/jurl-build`.
  3. Executed `MIX_ENV=prod mix deps.compile`.
  4. Executed `MIX_ENV=prod mix assets.deploy` (compiled Tailwind CSS and Esbuild assets).
  5. Built production release to path `/opt/jurl` (`MIX_ENV=prod mix release --path /opt/jurl --overwrite`).
- **Rationale**: Building a self-contained OTP release isolates runtime dependencies, eliminates the need for compilation tools in production startup, and improves startup times.

### Step 3.4: System Integration & Database Migrations (CT 101)
- **Action**:
  1. Created dedicated unprivileged system user `phoenix`.
  2. Provisioned `/etc/jurl/jurl.env` containing production environment variables (`DATABASE_URL`, `SECRET_KEY_BASE`, `PHX_SERVER=true`, `PORT=4000`).
  3. Ran Ecto database migrations via the release binary (`/opt/jurl/bin/migrate`).
  4. Created Systemd service unit `/etc/systemd/system/jurl.service` and enabled it via `systemctl enable --now jurl`.
- **Rationale**:
  - Running under a dedicated `phoenix` system user follows the principle of least privilege.
  - Storing secrets outside the application directory (`/etc/jurl/jurl.env` with `0600` permissions) prevents secret leakage.
  - Executing migrations via the release binary ensures database schemas (`users`, `links`, `clicks`) are updated before service startup.

### Step 3.5: Nginx Reverse Proxy Setup (CT 101)
- **Action**:
  1. Created Nginx site configuration `/etc/nginx/sites-available/jurl` mapping port 80 to `http://127.0.0.1:4000` with WebSocket support (`/live/websocket`).
  2. Enabled the site and reloaded Nginx (`systemctl reload nginx`).
- **Rationale**: Provides standard HTTP/HTTPS ingress on port 80 and handles Phoenix LiveView WebSocket upgrades smoothly.

### Step 3.6: Phoenix WebSocket Origin Check Configuration (`check_origin`)
- **Action**: Configured `check_origin` handling in `config/runtime.exs` so Phoenix accepts LiveView socket connections from external domains (e.g. `https://jurl.ch` or custom hostnames/IPs).
- **Rationale**: Phoenix LiveView enforces origin checks on WebSocket/longpoll transports by default. When accessing via custom domain names, mismatched origins caused socket connection rejections resulting in the WebUI error banner (`Something went wrong`). Setting `check_origin` dynamically resolves transport errors and establishes stable LiveView socket sessions.

### Step 3.7: URL Shortening Form Submission & Identity Handler Fix
- **Action**:
  1. Updated `get_identity/1` pattern matching in [lib/jurl/shortener.ex](file:///root/heuristicsyndicate/projects/jurl/lib/jurl/shortener.ex#L8-L28) to fallback to valid identity structs when `:identity` is missing from socket or conn assigns.
  2. Updated `handle_event("shorten")` in [lib/jurl_web/live/link_builder_live.ex](file:///root/heuristicsyndicate/projects/jurl/lib/jurl_web/live/link_builder_live.ex#L152-L210) to sanitize input params, ensure valid identity assigns (`ensure_identity/2`), and handle all error return tuples without unhandled clause crashes.
- **Rationale**: Previously, form submission caused a `FunctionClauseError` crash when extracting identity from LiveView sockets without pre-populated identity assigns, causing the LiveView process to terminate instead of shortening the URL. Robust pattern matching ensures seamless URL shortening for both anonymous and authenticated sessions.

### Step 3.8: Shortened URL Domain Hostname Configuration
- **Action**: Set `PHX_HOST=jurl.ch` in `/etc/jurl/jurl.env` on LXC 101 and updated `phx_host: "jurl.ch"` in [ansible/group_vars/all.yml](file:///root/heuristicsyndicate/projects/jurl/ansible/group_vars/all.yml#L35).
- **Rationale**: Configures `JurlWeb.Endpoint.url()` to generate shortened URL output links with domain `https://jurl.ch/<short_code>` rather than the internal container IP address (`192.168.1.21`).

---

## 4. Verification & Validation Results

1. **Database Schema Verification**:
   - Migration logs confirmed creation of tables `users`, `users_tokens`, `links`, and `clicks`, alongside the `citext` PostgreSQL extension in `jurl_prod`.
2. **Service Health Check**:
   - `systemctl status jurl` confirmed status `active (running)`.
3. **HTTP Response Check**:
   - `curl -i http://192.168.1.21` from the host returned `HTTP/1.1 200 OK` with full HTML output and session cookies (`_jurl_key`).
4. **Proxmox Log Integrity**:
   - Host system logs (`journalctl -u pve-container@101` and `journalctl -u pve-container@102`) show normal operation without crashes or container restarts.

---

## 5. How to Deploy Updated Code to LXC Container 101 (`phoenix-app`)

Whenever application code is updated, deploy the changes to CT 101 using one of the two methods below:

### Method A: Automated Ansible Redeployment (Recommended)
From your control machine or workspace:
```bash
cd ansible
ansible-playbook -i inventory.ini playbook.yml --tags redeploy --extra-vars "ansible_ssh_pass=dexter33143"
```

### Method B: Direct Proxmox Host CLI Deployment
If executing directly on the Proxmox host (`192.168.1.19`):
```bash
# 1. Archive local code (excluding build artifacts and git repository)
tar -czf /tmp/jurl-src.tar.gz -C /root/heuristicsyndicate/projects/jurl --exclude="_build" --exclude="deps" --exclude=".git" .

# 2. Push code archive into CT 101 and extract
pct push 101 /tmp/jurl-src.tar.gz /tmp/jurl-src.tar.gz
pct exec 101 -- bash -c "mkdir -p /tmp/jurl-build && tar -xzf /tmp/jurl-src.tar.gz -C /tmp/jurl-build"

# 3. Fetch dependencies, compile assets, assemble release, run migrations, and restart service
pct exec 101 -- bash -c "cd /tmp/jurl-build && export LANG=C.UTF-8 && \
  MIX_ENV=prod mix deps.get --only prod && \
  MIX_ENV=prod mix assets.deploy && \
  MIX_ENV=prod mix release --path /opt/jurl --overwrite && \
  chown -R phoenix:phoenix /opt/jurl && \
  export \$(cat /etc/jurl/jurl.env | xargs) && /opt/jurl/bin/migrate && \
  systemctl restart jurl"
```
