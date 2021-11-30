# Mirror Production Data to Staging

The cli.ts is a quick (and rough) wrapper around two shell scripts called dump.sh and restore.sh. Both execute pg_dump and pg_restore in a docker container. The Node.js script is for convienence (don't get me started about shell argument parsing) and setting environment variables.

**!Achtung: These scripts assume that your source and target environment have the same schema. It only dumps and restores data. No functions, no triggers.**

To setup a fresh environment take a look at [../supabase-docker-compose/README.md](../supabase-docker-compose/README.md)

## Prerequisites

- Node.js
- Docker

## Setup

```shell
cd supabase-mirror
npm ci
```

## Usage

### Command `--help`

Show the help

```shell
npm run dev -- --help

> @technologiestiftung/supabase-mirror@0.0.1 dev /some/path/to/stadtpuls-supabase/supabase-mirror
> node -r ts-node/register src/cli.ts "--help"

usage: cli.ts <command>

Commands:
  cli.ts dump     dumps some tables into custom postgres archive
  cli.ts restore  restores tables from custom postgres archive

Input/Output:
  -i, --input   input file for the custom archive
                                          [string] [default: "./stadtpuls.dump"]
  -o, --output  output file for the custom archive
                                          [string] [default: "./stadtpuls.dump"]

Environment Variables:
  -p, --pgport      postgres port                       [number] [default: 5432]
  -h, --pghost      postgres host                [string] [default: "localhost"]
  -d, --pgdatabase  postgres database             [string] [default: "postgres"]
  -u, --pguser      postgres user                 [string] [default: "postgres"]
  -W, --pgpassword  postgres password             [string] [default: "postgres"]

Options:
      --help     Show help                                             [boolean]
      --version  Show version number                                   [boolean]

All values in group "Environment Variables" can be overwritten with environment
variables prefixed by STADTPULS_e.g. STADTPULS_PGPORT
```

### Command `dump`

Dump remote postgres to local fs (in fish shell):

```fish
env STADTPULS_PGPORT=5432 \
  env STADTPULS_PGHOST="db.your-random-id-generated-by.supabase.co" \
  env STADTPULS_PGDATABASE=postgres \
  env STADTPULS_PGUSER=postgres \
  env STADTPULS_PGPASSWORD="your-super-secret-and-long-postgres-password" \
  npm run dev -- dump
```

In bash or zsh:

```bash
STADTPULS_PGPORT=5432 \
  STADTPULS_PGHOST="db.your-random-id-generated-by.supabase.co" \
  STADTPULS_PGDATABASE=postgres \
  STADTPULS_PGUSER=postgres \
  STADTPULS_PGPASSWORD="your-super-secret-and-long-postgres-password" \
  npm run dev -- dump
```

### Command `restore`

Restore dump to some local postgres host using default values (in fish shell):

```fish
env STADTPULS_PGPASSWORD="your-super-secret-and-long-postgres-password" \
  npm run dev -- restore
```

In bash or zsh:

```bash
STADTPULS_PGPASSWORD="your-super-secret-and-long-postgres-password" \
  npm run dev -- restore
```
