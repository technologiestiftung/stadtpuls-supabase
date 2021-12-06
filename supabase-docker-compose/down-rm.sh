#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

docker compose down && rm -rf dockerfiles/postgres/pg-data/*
