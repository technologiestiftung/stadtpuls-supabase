#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

curl http://localhost:8000/rest/v1/ -H apikey: "$SUPABASE_ANON_KEY"
