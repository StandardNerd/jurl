# Ansible Provisioning & Deployment for `jurl` on Proxmox VE

This directory contains a complete, automated **Ansible playbook** to provision two unprivileged LXC containers on a Proxmox VE host (`192.168.1.19`) and deploy the **`jurl`** Elixir/Phoenix web application along with a PostgreSQL 16 database.

---

## Target Architecture

- **Proxmox Host:** `192.168.1.19` (SSH user: `root`)
- **Container 100 (`postgres-db`):** `192.168.1.20/24` (PostgreSQL 16, DB `jurl_prod`, user `jurl`)
- **Container 101 (`phoenix-app`):** `192.168.1.21/24` (Elixir/Phoenix release, Nginx reverse proxy with LiveView WebSocket support)

---

## Directory Structure

```
ansible/
├── ansible.cfg              # Ansible configuration & SSH parameters
├── inventory.ini            # Target hosts (Proxmox host, LXC IPs)
├── group_vars/
│   └── all.yml              # Variable definitions (Container specs, DB names, IPs)
├── templates/               # Jinja2 templates (configs & systemd units)
│   ├── postgresql.conf.j2
│   ├── pg_hba.conf.j2
│   ├── jurl.env.j2
│   ├── jurl.service.j2
│   └── nginx_jurl.conf.j2
└── playbook.yml             # Master automated provisioning & deployment playbook
```

---

## Execution Guide

### Prerequisites

Ensure `ansible` and `sshpass` are installed on your local machine:

```bash
# macOS (Homebrew)
brew install ansible sshpass
```

### Running the Playbook

Execute the playbook against the Proxmox host (`192.168.1.19`), passing the root SSH password (`<your-ssh-password>`):

```bash
cd ansible
ansible-playbook -i inventory.ini playbook.yml --extra-vars "ansible_ssh_pass=<your-ssh-password>"
```

### Customizing Passwords & Secrets

To override default database passwords or secret keys, pass extra variables or use Ansible Vault:

```bash
ansible-playbook -i inventory.ini playbook.yml \
  --extra-vars "ansible_ssh_pass=<your-ssh-password> db_password=<your-db-password> secret_key_base=$(mix phx.gen.secret)"
```

### Redeploying Updated Code to CT 101

To sync code changes and rebuild the Phoenix release without re-creating containers or reinstalling base packages:

```bash
ansible-playbook -i inventory.ini playbook.yml --tags redeploy --extra-vars "ansible_ssh_pass=<your-ssh-password>"
```

---

## Playbook Workflow Stages

1. **Stage 1 (Container Creation):** Downloads the Debian 12 LXC template if missing, creates CT 100 (`postgres-db`) and CT 101 (`phoenix-app`) with static networking (`vmbr0`, `/24`), and boots both containers.
2. **Stage 2 (PostgreSQL Setup):** Installs PostgreSQL 16 on CT 100, configures `postgresql.conf` (`listen_addresses = '*'`) and `pg_hba.conf` (`scram-sha-256` for `192.168.1.21/32`), and initializes `jurl_prod` database and `jurl` user.
3. **Stage 3 (Phoenix Build & Release):** Installs Elixir, Erlang, Git, and build tools on CT 101, syncs `jurl` source code, precompiles static assets (`mix assets.deploy`), packages the production release (`mix release`), sets up `/etc/jurl/jurl.env`, runs migrations via release binary `/opt/jurl/bin/migrate`, and starts `jurl.service`.
4. **Stage 4 (Nginx & WebSockets):** Provisions Nginx listening on port 80, proxying HTTP traffic and handling `/live/websocket` upgrades for Phoenix LiveView.

---

## Verification

After playbook completion, verify the deployment:

```bash
# Test HTTP response from application container
curl -I http://192.168.1.21

# Check Phoenix app systemd status via Proxmox
sshpass -p '<your-ssh-password>' ssh root@192.168.1.19 "pct exec 101 -- systemctl status jurl"

# Check PostgreSQL connection from App container to DB container
sshpass -p '<your-ssh-password>' ssh root@192.168.1.19 "pct exec 101 -- nc -zv 192.168.1.20 5432"
```
