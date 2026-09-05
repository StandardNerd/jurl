# jurl

![screenshot](./docs/image.png)

A self-hosted URL shortener built for my family and running on a private Proxmox server in my home network. It generates ultra-short, 3-character alphanumeric codes so links are effortless to remember, dictate aloud and to print — for example, sharing photo albums with other parents from my daughter's kindergarten.

<p align="center">
  <strong>High-performance, real-time, privacy-friendly URL shortener built with Elixir and Phoenix LiveView.</strong>
</p>

<p align="center">
  <a href="https://elixir-lang.org/"><img src="https://img.shields.io/badge/Elixir-1.14+-4B275F?style=flat&logo=elixir&logoColor=white" alt="Elixir Version" /></a>
  <a href="https://phoenixframework.org/"><img src="https://img.shields.io/badge/Phoenix-1.7-FD4F00?style=flat&logo=phoenixframework&logoColor=white" alt="Phoenix Version" /></a>
  <a href="https://hexdocs.pm/phoenix_live_view"><img src="https://img.shields.io/badge/Phoenix%20LiveView-1.0-orange?style=flat" alt="LiveView Version" /></a>
  <a href="https://www.postgresql.org/"><img src="https://img.shields.io/badge/PostgreSQL-16-336791?style=flat&logo=postgresql&logoColor=white" alt="PostgreSQL" /></a>
  <a href="https://www.docker.com/"><img src="https://img.shields.io/badge/Docker-Ready-2496ED?style=flat&logo=docker&logoColor=white" alt="Docker Ready" /></a>
  <a href="#running-tests"><img src="https://img.shields.io/badge/Tests-187%20passing-brightgreen?style=flat" alt="Test Suite" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=flat" alt="MIT License" /></a>
</p>

---

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Architecture](#architecture)
- [Database Schema (ER Diagram)](#database-schema-er-diagram)
- [Ensuring Unique Short URLs](#ensuring-unique-short-urls)
- [Quickstart with Docker](#quickstart-with-docker)
- [Local Development](#local-development)
- [Running Tests](#running-tests)
- [Configuration & Environment Variables](#configuration--environment-variables)
- [Project Structure](#project-structure)
- [Production Deployment](#production-deployment)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

**jurl** is an open-source, modern URL shortening platform that combines the concurrency of the BEAM VM with the real-time capabilities of Phoenix LiveView. 

Unlike traditional shorteners that rely on heavy database polling or external analytics pipelines, `jurl` uses in-memory **ETS caching** for sub-millisecond redirection and processes click metrics through an asynchronous **GenServer batcher**. Real-time dashboards update instantaneously via WebSockets across clients.

Designed with a **zero-friction, privacy-first** onboarding philosophy, users can create and manage shortened links immediately as anonymous visitors, with an automatic, lossless migration path to registered accounts.

---

## Key Features

- ⚡ **Sub-Millisecond Redirections**: Hot URLs are cached in an in-memory ETS table (`Jurl.Cache.URLCache`), delivering lightning-fast redirects with fallback to PostgreSQL.
- 📊 **Real-Time LiveView Analytics**: Instant click counter updates, geographic distribution, referrers, device, and browser stats streamed dynamically without page reloads.
- 👤 **Zero-Friction Anonymous Workflow**: Create links immediately without signing up. Anonymous sessions are tracked securely with rate limits and quota safeguards.
- 🔄 **Seamless Identity Migration**: Automatic link claiming and historical analytics consolidation when an anonymous visitor registers or logs in.
- 🔐 **Full Authentication Suite**: Secure account registration, session authentication, password resets, and email confirmation powered by `phx.gen.auth` and Bcrypt.
- 🖨️ **Printable QR Codes**: Built-in printable card layout (`/links/:short_code/print`) formatted for physical sharing and QR code display.
- 🌐 **Internationalization (i18n)**: Multilingual support powered by Gettext (English, German, French, Spanish, Italian, and more).
- 🐳 **Containerized & Production Ready**: Self-contained multi-stage Docker image, Docker Compose orchestration, and automated Ansible provisioning playbooks.

---

## Architecture

```mermaid
flowchart TD
    Client([HTTP Client / Visitor]) -->|GET /:short_code| Router[Phoenix Router & Bandit Server]
    Router --> Redirect[Redirect Controller]
    
    subgraph Resolution Pipeline
        Redirect -->|1. Lookup| ETS[(ETS Hot Cache)]
        ETS -.->|Cache Miss| DB[(PostgreSQL Database)]
        DB -.->|Warm Cache| ETS
    end
    
    Redirect -->|2. 302 Redirect| Client
    Redirect -->|3. Async Track| ClickProcessor[GenServer ClickProcessor]
    
    subgraph Analytics & Real-Time
        ClickProcessor -->|Batched Insert| DB
        ClickProcessor -->|Broadcast| PubSub[Phoenix PubSub]
        PubSub -->|WebSocket Push| LiveView[LiveView Analytics Dashboard]
    end
```

---

## Database Schema (ER Diagram)

`jurl` persists relational data in PostgreSQL 16 using UUID primary keys (`binary_id`), strict relational foreign key constraints, and dedicated indexes for sub-millisecond lookups.

```mermaid
erDiagram
    USERS ||--o{ USERS_TOKENS : "authenticates"
    USERS ||--o{ LINKS : "owns"
    LINKS ||--o{ CLICKS : "records"

    USERS {
        uuid id PK
        citext email UK
        string hashed_password
        string name
        string migrated_anonymous_id
        timestamp confirmed_at
        timestamp inserted_at
        timestamp updated_at
    }

    USERS_TOKENS {
        uuid id PK
        uuid user_id FK
        binary token
        string context
        string sent_to
        timestamp inserted_at
    }

    LINKS {
        uuid id PK
        uuid user_id FK "nullable"
        string anonymous_id "nullable"
        text original_url
        string short_code UK
        string custom_alias UK
        string title
        text description
        string og_image_url
        string password_hash
        timestamp expires_at
        boolean is_active
        integer click_count
        timestamp inserted_at
        timestamp updated_at
    }

    CLICKS {
        uuid id PK
        uuid link_id FK
        string ip_address
        text user_agent
        text referrer
        string country
        string city
        string region
        string device_type
        string browser
        string operating_system
        boolean is_unique
        timestamp inserted_at
    }
```

### Schema & Entity Relationships

- **`users` & `users_tokens`**: Standard secure authentication schema generated with `mix phx.gen.auth`. `citext` ensures case-insensitive uniqueness on `email`. `users_tokens` stores hashed session, password reset, and confirmation tokens with cascading deletion (`on_delete: :delete_all`).
- **`links`**: Core short link records. Supports dual ownership:
  - **Authenticated Users**: Linked via `user_id` foreign key.
  - **Anonymous Visitors**: Tracked via `anonymous_id` session token, enabling lossless migration to a user account upon registration.
- **`clicks`**: High-volume append-only event log recording visitor telemetry (IP, user-agent, geolocation country/city, device, referrer, and unique visitor flags). Cascades on link deletion.

---

## Ensuring Unique Short URLs

Guaranteeing unique, collision-free short codes and custom aliases is critical in a URL shortener to prevent routing ambiguity and URL hijacking. `jurl` achieves this through a multi-tier defense-in-depth architecture:

### 1. Database-Level Unique Indexes (ACID Guarantee)
Uniqueness is fundamentally guaranteed at the database engine level by PostgreSQL unique B-tree indexes defined in migration [`20260707150035_create_links_and_clicks.exs`](priv/repo/migrations/20260707150035_create_links_and_clicks.exs):

```elixir
create unique_index(:links, [:short_code])
create unique_index(:links, [:custom_alias])
```

- **Concurrency & Race Condition Protection**: Even if two distributed nodes or concurrent requests generate the same code at the exact same millisecond, PostgreSQL serializes transaction commits and enforces uniqueness, ensuring only one write succeeds.
- **Fast Lookups**: The B-tree index provides $O(\log n)$ search performance when routing short URLs or checking availability.

### 2. Application-Level Changeset Validation (Ecto Pipeline)
In [`Jurl.Shortener.Link`](lib/jurl/shortener/link.ex), the changeset pipeline pairs validation with constraint translation:

```elixir
def changeset(link, attrs) do
  link
  |> cast(attrs, [...])
  |> validate_required([:original_url])
  |> generate_short_code()
  |> validate_unique_short_code()
  |> unique_constraint(:short_code)
  |> unique_constraint(:custom_alias)
end

defp validate_unique_short_code(changeset) do
  unsafe_validate_unique(changeset, :short_code, Jurl.Repo)
end
```

- **Optimistic Pre-Validation (`unsafe_validate_unique/3`)**: Performs an in-memory/DB check before attempting the write, returning an immediate, user-friendly error message if a user requests an already-taken custom alias.
- **Graceful Constraint Mapping (`unique_constraint/2`)**: Catches the database engine's unique constraint violation (`PostgreSQL error code 23505`) and safely translates it into an Ecto changeset error (`{:error, changeset}`) rather than raising an unhandled database exception that crashes the process.

### 3. Collision Probability & Code Space Analysis
Short codes are generated from an alphanumeric character set (`[a-z0-9]` or Base62 `[a-zA-Z0-9]`):

| Alphabet | Code Length ($N$) | Total Available Namespace ($K = B^N$) | Collisions at 100k Links | Collisions at 1M Links |
| :--- | :---: | :---: | :---: | :---: |
| **Base36** (`[a-z0-9]`) | 6 characters | $36^6 \approx \mathbf{2.17\times 10^9}$ (~2.17 billion) | $\approx 0.23\%$ | $\approx 20.6\%$ |
| **Base36** (`[a-z0-9]`) | 7 characters | $36^7 \approx \mathbf{7.83\times 10^{10}}$ (~78.3 billion) | $< 0.006\%$ | $\approx 0.6\%$ |
| **Base62** (`[a-zA-Z0-9]`) | 6 characters | $62^6 \approx \mathbf{5.68\times 10^{10}}$ (~56.8 billion) | $< 0.009\%$ | $\approx 0.88\%$ |
| **Base62** (`[a-zA-Z0-9]`) | 7 characters | $62^7 \approx \mathbf{3.52\times 10^{12}}$ (~3.52 trillion) | Negligible ($< 10^{-4}\%$) | $\approx 0.014\%$ |

According to the Birthday Problem approximation ($p \approx 1 - e^{-n^2 / 2K}$), with Base62 at 7 characters, a system can store over 10 million links with less than a $0.014\%$ probability of encountering a random collision.

### 4. Collision Resolution & Production Strategies

To ensure 100% availability even as the keyspace fills up:

1. **Automated Collision Retry Loop**:
   If a random code generates a unique constraint violation on insert, the context catches `{:error, changeset}` and triggers an automatic regeneration retry (up to 3 attempts):
   ```elixir
   def create_link_with_retry(identity, attrs, retries_left \\ 3) do
     case create_link(identity, attrs) do
       {:error, %Ecto.Changeset{errors: [short_code: _]}} when retries_left > 0 ->
         create_link_with_retry(identity, attrs, retries_left - 1)
       result ->
         result
     end
   end
   ```
2. **Dynamic Key Length Scaling**:
   When the total link count exceeds a threshold (e.g., 50% capacity of current length $N$), the generator automatically increases code length ($N + 1$), exponentially expanding the key space without requiring database migrations.
3. **Reserved System Route Protection**:
   Custom aliases are checked against a blacklist of reserved application routes (`/links`, `/users`, `/admin`, `/api`, `/assets`, `/live`, etc.) to prevent users from overriding critical application endpoints.

---

## Quickstart with Docker

The quickest way to evaluate and run `jurl` locally is via Docker Compose:

### 1. Prerequisites
- [Docker](https://docs.docker.com/get-docker/) & **Docker Compose**

### 2. Clone and Launch
```bash
git clone https://github.com/your-username/jurl.git
cd jurl
docker compose up --build -d
```

### 3. Access the Application
- **Web App**: [http://localhost:4000](http://localhost:4000)
- **PostgreSQL**: Accessible on host port `5433` (mapped from container `5432` to avoid conflicts with any local PostgreSQL installation).

### 4. Inspect Logs
```bash
docker compose logs -f app
```

### 5. Applying Code Changes
When editing source files locally, rebuild the container release:
```bash
docker compose up -d --build app
```

### 6. Stop Services
```bash
docker compose down
```

---

## Local Development

If you prefer to run Elixir natively on your host machine:

### Prerequisites
- **Elixir**: `>= 1.14`
- **Erlang/OTP**: `>= 25`
- **PostgreSQL**: `>= 14`

### Setup Steps

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/jurl.git
   cd jurl
   ```

2. **Install dependencies and setup database**:
   ```bash
   mix setup
   ```
   *This command runs `mix deps.get`, creates and migrates the dev database, and compiles assets.*

3. **Start the Phoenix server**:
   ```bash
   mix phx.server
   ```
   *Alternatively, run inside IEx:* `iex -S mix phx.server`

4. Open your browser and navigate to [http://localhost:4000](http://localhost:4000).

---

## Running Tests

`jurl` includes an automated ExUnit test suite covering link shortening, anonymous identity tracking, authentication, LiveView pages, and analytics processing.

```bash
# Run the complete test suite
mix test

# Run tests with interactive file watcher (re-runs on change)
mix test.watch

# Run pre-commit checks (deps, compilation, and tests)
mix precommit
```

---

## Configuration & Environment Variables

In production releases, configuration is loaded at runtime via [`config/runtime.exs`](config/runtime.exs). Configure the following environment variables:

| Variable | Description | Default / Example |
| :--- | :--- | :--- |
| `DATABASE_URL` | PostgreSQL connection URI *(Required in prod)* | `ecto://user:pass@localhost:5432/jurl_prod` |
| `SECRET_KEY_BASE` | Phoenix secret key base (min. 64 characters) *(Required in prod)* | Generate via `mix phx.gen.secret` |
| `PHX_HOST` | Public host domain for URL generation | `jurl.ch` or `localhost` |
| `PORT` | HTTP listener port | `4000` |
| `POOL_SIZE` | Database connection pool size | `10` |
| `CHECK_ORIGIN` | LiveView WebSocket origin check (`false`, `true`, or comma-separated domains) | `false` |
| `PHX_SERVER` | Enable HTTP server execution | `true` |
| `ECTO_IPV6` | Enable IPv6 database socket option | `false` |

---

## Project Structure

```
jurl/
├── assets/                 # Tailwind CSS and JavaScript front-end assets
├── config/                 # Compile-time and runtime configurations
├── lib/
│   ├── jurl/               # Business logic core
│   │   ├── accounts/       # User identity, schemas, and credentials
│   │   ├── analytics/      # Click tracking & asynchronous GenServer processor
│   │   ├── anonymous/      # Session limits and ETS anonymous store
│   │   ├── cache/          # ETS hot-URL lookup cache
│   │   └── shortener/      # Base62 code generator and Link context
│   └── jurl_web/           # Phoenix web interface
│       ├── controllers/    # Redirection & session controllers
│       ├── live/           # Real-time LiveView dashboards & link builder
│       └── plugs/          # Anonymous user tracking & locale negotiation
├── priv/
│   ├── gettext/            # Internationalization translation files (.po)
│   └── repo/migrations/    # Ecto database migrations
├── ansible/                # Optional LXC / bare-metal deployment playbooks
└── test/                   # Comprehensive ExUnit test suite
```

---

## Production Deployment

### Docker Multi-Stage Build

The root [`Dockerfile`](Dockerfile) builds a lean, standalone OTP release on Debian/Ubuntu with minimal attack surface:

```bash
docker build -t jurl:latest .
docker run -d \
  -p 4000:4000 \
  -e DATABASE_URL="ecto://user:pass@db-host:5432/jurl_prod" \
  -e SECRET_KEY_BASE="$(openssl rand -base64 48)" \
  -e PHX_HOST="jurl.ch" \
  -e PHX_SERVER="true" \
  jurl:latest
```

### Ansible & Infrastructure Automation

For bare-metal or Proxmox VE LXC container deployments, an automated Ansible playbook is available in [`ansible/`](ansible/). See the [Ansible Deployment Guide](ansible/README.md) for configuration and execution steps.

For deployment diagnostics and systemd service troubleshooting, refer to [troubleshoot.md](troubleshoot.md).

---

## Contributing

Contributions are welcome and greatly appreciated! To contribute:

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/amazing-feature`).
3. Commit your changes (`git commit -m 'feat: add amazing feature'`).
4. Ensure all tests pass (`mix test`).
5. Push to the branch (`git push origin feature/amazing-feature`).
6. Open a Pull Request.

Please ensure code formatting conforms to Elixir standards and new features include test coverage.

---

## License

This project is licensed under the [MIT License](LICENSE) - feel free to use it in personal and commercial projects.
