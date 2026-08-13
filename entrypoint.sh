#!/usr/bin/env bash
set -e

DB_HOST="${HOST:-${ODOO_DB_HOST:-db}}"
DB_PORT="${PORT:-${ODOO_DB_PORT:-5432}}"
DB_USER="${USER:-${POSTGRES_USER:-odoo}}"
DB_PASSWORD="${PASSWORD:-${POSTGRES_PASSWORD:-odoo}}"
DB_NAME="${POSTGRES_DB:-postgres}"

export PGPASSWORD="$DB_PASSWORD"

echo "Waiting for PostgreSQL at $DB_HOST:$DB_PORT..."
until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" >/dev/null 2>&1; do
  sleep 2
done
echo "PostgreSQL is ready."

echo "Checking if database '$DB_NAME' exists..."
DB_EXISTS=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -tAc \
  "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}'" 2>/dev/null || echo "0")

BASE_INSTALLED="0"
if [ "$DB_EXISTS" = "1" ]; then
  echo "Checking if Odoo base module is installed in '$DB_NAME'..."
  BASE_INSTALLED=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc \
    "SELECT 1 FROM information_schema.tables WHERE table_name='ir_module_module'" 2>/dev/null || echo "0")
fi

if [ "$DB_EXISTS" != "1" ] || [ "$BASE_INSTALLED" != "1" ]; then
  echo "Initializing Odoo database '$DB_NAME' (installing base module)..."
  odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" -i base --without-demo=all --stop-after-init
fi

echo "▶ Starting Odoo..."
if [ "$1" = "odoo" ]; then
  shift
  exec odoo -c /etc/odoo/odoo.conf "$@"
elif [ -z "$1" ]; then
  exec odoo -c /etc/odoo/odoo.conf
else
  exec "$@"
fi
