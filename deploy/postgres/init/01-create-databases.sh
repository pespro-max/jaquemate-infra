#!/bin/bash
# ============================================================
# JAQUEMATE — Init de Postgres
# Se ejecuta UNA SOLA VEZ cuando el volumen db_data esta vacio.
# Crea la base de datos para n8n. La de Twenty (default) ya
# la crea POSTGRES_DB del docker-compose.
# ============================================================
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" <<-EOSQL
    CREATE DATABASE n8n;
    GRANT ALL PRIVILEGES ON DATABASE n8n TO $POSTGRES_USER;
EOSQL

echo "Jaque Mate init: base de datos n8n creada."
