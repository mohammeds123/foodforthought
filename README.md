# FoodForThought

Local food-bank app: React (`client/`), Express (`server/`), MySQL scripts (`db/`).

## Run

1. Start MySQL (port 3306). Homebrew MySQL is what this machine is using.
2. Copy `server/.env.example` to `server/.env` and set `DB_PASSWORD` and `SESSION_SECRET`.
3. Terminal 1: `cd server && npm run dev`
4. Terminal 2: `cd client && npm run dev`
5. App: http://localhost:5173 — health check: http://localhost:3000/api/health

## SQL scripts

Run in order, as root, against `foodforthought`:

1. `db/00_create_database.sql` (database + `fft_app` user)
2. `db/01_schema.sql` (tables — write the DDL here)
3. `db/02_procedures.sql`
4. `db/03_events.sql`
5. `db/04_seed.sql`

```bash
mysql -u root foodforthought < db/01_schema.sql
```

## SQLTools in VS Code

Install **SQLTools** and **SQLTools MySQL/MariaDB/TiDB**. This repo already has the connections in `.vscode/settings.json`.

Do not use port 3306 with the default MySQL protocol. Homebrew MySQL 26 uses `caching_sha2_password`, which SQLTools' default driver rejects. Use **X Protocol on port 33060**.

1. Open this folder in VS Code.
2. SQLTools sidebar (database icon) → Connections.
3. Connect to **FoodForThought** (root, empty password, `127.0.0.1:33060`).
4. Open `db/01_schema.sql` → Run on Active Connection.

If you create the connection by hand:

| Field | Value |
| --- | --- |
| Connection name | FoodForThought |
| Driver | MySQL |
| Server | `127.0.0.1` (not `localhost`) |
| Port | `33060` |
| Database | `foodforthought` |
| Username | `root` |
| Password | leave blank (this Homebrew install has no root password) |
| mysqlOptions.authProtocol | `xprotocol` |

The Express app user is `fft_app` / `change-me` on port 3306 (classic protocol via `mysql2`).
