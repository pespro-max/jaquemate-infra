#!/bin/bash
# ============================================================
# JAQUEMATE — Health check
# Verifica todos los componentes del stack y reporta estado.
# Salida: 0 si todo OK, 1 si hay problemas.
# ============================================================
set +e

cd "$(dirname "$0")/.."

echo "=========================================="
echo " Jaque Mate — Health Check"
echo " $(date)"
echo "=========================================="

EXIT_CODE=0
check() {
    local label="$1"
    local cmd="$2"
    if eval "$cmd" >/dev/null 2>&1; then
        echo "  [OK]   $label"
    else
        echo "  [FAIL] $label"
        EXIT_CODE=1
    fi
}

# Grace period post-reboot: si twenty-server está "starting", esperar hasta
# 90s antes de evaluar. Twenty (Nest) tarda ~60s en mapear rutas y pasar de
# starting → healthy, lo que produce falsos FAIL tras un reboot frío.
wait_for_starting() {
    local container="$1"
    local max_wait=90
    local waited=0
    local status
    while [ "$waited" -lt "$max_wait" ]; do
        status=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null)
        if [ "$status" != "starting" ]; then
            return 0
        fi
        if [ "$waited" -eq 0 ]; then
            echo "  [WAIT] $container en 'starting' — esperando hasta ${max_wait}s..."
        fi
        sleep 5
        waited=$((waited + 5))
    done
}

wait_for_starting jaquemate-twenty-server
wait_for_starting jaquemate-db

echo ""
echo "Containers:"
check "postgres healthy"        "docker inspect --format='{{.State.Health.Status}}' jaquemate-db | grep -q healthy"
check "redis healthy"           "docker inspect --format='{{.State.Health.Status}}' jaquemate-redis | grep -q healthy"
check "twenty server healthy"   "docker inspect --format='{{.State.Health.Status}}' jaquemate-twenty-server | grep -q healthy"
check "twenty worker running"   "docker inspect --format='{{.State.Status}}' jaquemate-twenty-worker | grep -q running"
check "n8n running"             "docker inspect --format='{{.State.Status}}' jaquemate-n8n | grep -q running"
check "caddy running"           "docker inspect --format='{{.State.Status}}' jaquemate-caddy | grep -q running"
check "uptime-kuma running"     "docker inspect --format='{{.State.Status}}' jaquemate-uptime | grep -q running"

echo ""
echo "Endpoints:"
check "app.jaquemate.          HTTPS"   "curl -sf -o /dev/null https://app.jaquemate.jaqueting.com"
check "pespro.jaquemate.       HTTPS"   "curl -sf -o /dev/null https://pespro.jaquemate.jaqueting.com"
check "traulog.jaquemate.      HTTPS"   "curl -sf -o /dev/null https://traulog.jaquemate.jaqueting.com"
check "jaqueting.jaquemate.    HTTPS"   "curl -sf -o /dev/null https://jaqueting.jaquemate.jaqueting.com"
check "fastnet.jaquemate.      HTTPS"   "curl -sf -o /dev/null https://fastnet.jaquemate.jaqueting.com"
check "cancun.jaquemate.       HTTPS"   "curl -sf -o /dev/null https://cancun.jaquemate.jaqueting.com"
check "iki.jaquemate.          HTTPS"   "curl -sf -o /dev/null https://iki.jaquemate.jaqueting.com"
check "engine.jaquemate.       HTTPS"   "curl -sf -o /dev/null https://engine.jaquemate.jaqueting.com"
check "monitor.jaquemate.      HTTPS"   "curl -sf -o /dev/null https://monitor.jaquemate.jaqueting.com"

echo ""
echo "Disco:"
DISK_PCT=$(df -h /var/lib/docker | awk 'NR==2 {print $5}' | tr -d '%')
if [ "$DISK_PCT" -lt 80 ]; then
    echo "  [OK]   /var/lib/docker en ${DISK_PCT}%"
else
    echo "  [WARN] /var/lib/docker en ${DISK_PCT}% — limpiar imagenes viejas: docker image prune -a"
    EXIT_CODE=1
fi

echo ""
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "Resultado: TODO OK"
else
    echo "Resultado: HAY ALERTAS — revisar logs: docker compose logs -f"
fi

exit $EXIT_CODE
