![](https://img.shields.io/badge/Build%20with%20%E2%9D%A4%EF%B8%8F-at%20Technologiesitftung%20Berlin-blue)

# Stadtpuls.com Supabse

Configuration for running supabase locally and remote

## Supabase with supabase cli

- TBD

See https://github.com/supabase/cli/

## Migrations

TBD

## Supabase with Docker

Run Supabase locally.

### Configuration

Add your passwords to the `.env` file.
For better customization and security, please read the [self-hosting guide](https://supabase.io/docs/guides/self-hosting#running-supabase).

### Run via `docker-compose`

- Move into the folder `cd supabase-docker-compose`
- Starting all services: `docker compose up`
- Stopping all services: `docker compose down`

## Troubleshooting

If your setup is broken or you want to start fresh run:

```bash
docker compose down && rm -rf dockerfiles/postgres/pg-data/* && mkdir dockerfiles/postgres/pg-data && docker rm supabase-db
```

## Usage

### Accessing the services directly

- Kong: http://localhost:8000
  - GoTrue: http://localhost:8000/auth/v1/?apikey=<anon-apikey-from-kong.yml>
  - PostgREST: http://localhost:8000/rest/v1/?apikey=<anon-apikey-from-kong.yml>
  - Realtime: http://localhost:8000/realtime/v1/?apikey=<anon-apikey-from-kong.yml>
  - Storage: http://localhost:8000/storage/v1/?apikey=<anon-apikey-from-kong.yml>
- Postgres: http://localhost:5432

### With Javascript

```js
import { createClient } from "@supabase/supabase-js";

const SUPABASE_URL = "http://localhost:8000";
const SUPABASE_KEY = "<anon-apikey-from-kong.yml>";

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);
```
