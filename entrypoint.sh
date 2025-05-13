#!/bin/sh
set -e

until pg_isready -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME"; do
  echo "Waiting for Postgres at $DB_HOST..."
  sleep 2
done

export DB_DSN="postgres://$DB_USER:$DB_PASS@$DB_HOST:$DB_PORT/$DB_NAME?sslmode=$DB_SSLMODE"

case "$1" in
migrate)
  echo "Running migrations..."
  goose -dir backend/db/migrations postgres "$DB_DSN" up
  ;;

server)
  echo "Starting Server & Collections scheduler with air"
  exec air
  ;;

*)
  echo "unknown command: $1"
  exec "$@"
  ;;
esac
