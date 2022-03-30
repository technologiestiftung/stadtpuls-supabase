# stadtpuls.com Supabse

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

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://fabianmoronzirfas.me/"><img src="https://avatars.githubusercontent.com/u/315106?v=4?s=64" width="64px;" alt=""/><br /><sub><b>Fabian Morón Zirfas</b></sub></a><br /><a href="https://github.com/technologiestiftung/stadtpuls-supabase/commits?author=ff6347" title="Code">💻</a> <a href="https://github.com/technologiestiftung/stadtpuls-supabase/commits?author=ff6347" title="Documentation">📖</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!

## Credits

  <table>
    <tr>
      <td>
        <a src="https://citylab-berlin.org/en/start/">
          <br />
          <br />
          <img width="200" src="https://logos.citylab-berlin.org/logo-citylab-berlin.svg" />
        </a>
      </td>
      <td>
        A project by: <a src="https://www.technologiestiftung-berlin.de/en/">
          <br />
          <br />
          <img width="150" src="https://logos.citylab-berlin.org/logo-technologiestiftung-berlin-en.svg" />
        </a>
      </td>
      <td>
        Supported by: <a src="https://www.berlin.de/rbmskzl/en/">
          <br />
          <br />
          <img width="80" src="https://logos.citylab-berlin.org/logo-berlin-senatskanzelei-en.svg" />
        </a>
      </td>
    </tr>
  </table>