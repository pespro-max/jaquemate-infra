#!/bin/bash
# ============================================================
# JAQUEMATE — Backup diario
# Ejecutar via cron: 0 2 * * * /opt/jaquemate/scripts/backup.sh
# Backups locales en /var/backups/jaquemate (retencion 30 dias).
# Para backup off-site agregar paso a Backblaze B2 o S3.
# ============================================================
set -e

BACKUP_DIR="${BACKUP_DIR:-/var/backups/jaquemate}"
RETENTION_DAYS=30
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

# Postgres dump (Twenty default + n8n)
docker exec jaquemate-db pg_dumpall -U postgres | gzip > "$BACKUP_DIR/postgres_${TIMESTAMP}.sql.gz"

# n8n data (workflows, credentials encrypted, settings)
docker run --rm \
    -v jaquemate_n8n_data:/source:ro \
    -v "$BACKUP_DIR":/backup \
    alpine tar czf "/backup/n8n_${TIMESTAMP}.tar.gz" -C /source .

# Uptime Kuma data
docker run --rm \
    -v jaquemate_uptime_kuma_data:/source:ro \
    -v "$BACKUP_DIR":/backup \
    alpine tar czf "/backup/uptime_${TIMESTAMP}.tar.gz" -C /source .

# Twenty local storage (uploads)
docker run --rm \
    -v jaquemate_twenty_local_data:/source:ro \
    -v "$BACKUP_DIR":/backup \
    alpine tar czf "/backup/twenty_storage_${TIMESTAMP}.tar.gz" -C /source .

# Limpieza de backups viejos
find "$BACKUP_DIR" -type f -mtime +$RETENTION_DAYS -delete

# Reporte
SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
echo "Backup completado $TIMESTAMP. Total backup dir: $SIZE"

# OPCIONAL: subir a Backblaze B2 (requiere b2 CLI configurada)
# b2 sync "$BACKUP_DIR" b2://jaquemate-backups/$(hostname)/ --replaceNewer
