#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
print_usage() {
  printf "\n------------------------------\n"
  printf "Usage: %s -u (up)          docker compose up\n" "${0}"
  printf "       %s -d (down)        docker compose down\n" "${0}"
  printf "       %s -b (background)  docker compose up --detach\n" "${0}"
  printf "       %s -f (force)       docker compose up --build --force-recreate\n" "${0}"
  printf "       %s -k (kill)        docker compose down && rm -rf dockerfiles/postgres/pg-data/* \n" "${0}"
  printf "       %s -h (help)        print this help\n" "${0}"

}

while getopts 'ubdkfh' flag; do
  case "${flag}" in
  u)
    docker compose up
    exit 0
    ;;
  b)
    docker compose up --detach
    exit 0
    ;;

  d)
    docker compose down
    exit 0
    ;;
  f)
    docker compose up --build --force-recreate
    exit 0
    ;;
  k)
    docker compose down && rm -rf dockerfiles/postgres/pg-data/*
    exit 0
    ;;
  h)
    print_usage
    exit 0
    ;;
  *)
    print_usage
    exit 1
    ;;
  esac
done
