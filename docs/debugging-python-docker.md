# Debugging Python in Docker

Remote-attach debugging with [nvim-dap](https://github.com/mfussenegger/nvim-dap).
`debugpy` runs **inside** the container; Neovim attaches over a published port.
Nothing debug-related is installed on the host.

## How it works

```
┌─ host ──────────────┐        ┌─ container ─────────────────┐
│ nvim-dap            │ attach │ python -m debugpy --listen  │
│ localhost:5678 ─────┼───────▶│ 0.0.0.0:5678  (your app)    │
│ source = cwd        │  TCP   │ source = /app  (volume)     │
└─────────────────────┘        └─────────────────────────────┘
```

Breakpoints bind only if the host source (`localRoot` = cwd) and the container
source (`remoteRoot`, default `/app`) are the same tree — keep them on a volume
mount.

## Prerequisites

Add `debugpy` to the image, then rebuild:

```
# requirements.txt
debugpy
```

```sh
docker compose build
```

## Generic Python

`docker-compose.yml`:

```yaml
services:
  app:
    build: .
    command: python -m debugpy --listen 0.0.0.0:5678 --wait-for-client -m yourapp
    ports:
      - "5678:5678"     # debugpy → host
    volumes:
      - .:/app          # host source == container /app
    working_dir: /app
```

- `--listen 0.0.0.0:5678` — bind all interfaces (not `127.0.0.1`, or the host
  can't reach it).
- `--wait-for-client` — the process blocks until Neovim attaches, so no early
  breakpoints are missed.

## Django

Django's autoreloader spawns a child process; debugpy attaches to the parent,
so breakpoints in the child never hit. Run with `--noreload`.

```yaml
services:
  web:
    build: .
    command: >
      python -m debugpy --listen 0.0.0.0:5678 --wait-for-client
      manage.py runserver 0.0.0.0:8000 --noreload
    ports:
      - "8000:8000"     # Django
      - "5678:5678"     # debugpy
    volumes:
      - .:/app
    working_dir: /app
```

Tradeoff: no hot-reload while debugging — restart the container after code
changes, or keep a second non-debug service for daily work (see below).

### Management commands

```sh
docker compose run --rm -p 5678:5678 web \
  python -m debugpy --listen 0.0.0.0:5678 --wait-for-client manage.py mycommand
```

### Migrations

Run migrations separately, not under the debug command, unless you are
debugging the migration itself:

```sh
docker compose run --rm web manage.py migrate
```

### Two-service pattern (recommended for daily dev)

Keep a normal service for everyday work and a debug variant you start only when
needed:

```yaml
services:
  web:
    build: .
    command: manage.py runserver 0.0.0.0:8000
    ports: ["8000:8000"]
    volumes: [".:/app"]
    working_dir: /app

  web-debug:
    extends: web
    command: >
      python -m debugpy --listen 0.0.0.0:5678 --wait-for-client
      manage.py runserver 0.0.0.0:8000 --noreload
    ports:
      - "8000:8000"
      - "5678:5678"
```

```sh
docker compose up web         # normal, hot-reload
docker compose up web-debug   # debugging
```

## Attaching from Neovim

Run from the project whose source is mounted into the container (cwd ==
`localRoot`).

1. Start the container — it hangs at "waiting for client" (that's debugpy).
   ```sh
   docker compose up web-debug
   ```
2. Set a breakpoint: `<leader>db` on the line.
3. `<leader>dc` → pick **"Python: Attach to Docker (debugpy)"**.
4. Enter port (`5678`) and `remoteRoot` (`/app`).
5. The app unblocks and runs; trigger the code path (load the URL) → it stops
   at the breakpoint, dap-ui opens.

### Keymaps

| Key          | Action               |
|--------------|----------------------|
| `<leader>db` | toggle breakpoint    |
| `<leader>dc` | continue / attach    |
| `<leader>di` | step into            |
| `<leader>do` | step over            |
| `<leader>dO` | step out             |
| `<leader>du` | toggle dap-ui        |
| `<leader>dt` | terminate            |

## Gotchas

- **Path mapping mismatch** — if your source mounts somewhere other than `/app`
  (e.g. `/code`), enter that as `remoteRoot`. Mismatch = breakpoints never bind.
- **`--wait-for-client` blocks boot** — drop it if you want the app to start
  normally and attach only when needed. debugpy keeps listening; attach anytime.
  Downside: breakpoints during boot (`AppConfig.ready`, import time) won't catch.
- **`--listen 127.0.0.1`** — unreachable from the host. Always `0.0.0.0`.
- **Port already in use** — change both the container listen port and the
  published mapping, then enter the new port when attaching.
