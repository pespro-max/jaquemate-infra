#!/bin/bash
# ============================================================
# JAQUEMATE — Setup master
# Ejecutar UNA VEZ en el VPS Hetzner para levantar el stack.
# Valida prerequisitos, genera secretos si no existen, arranca.
# ============================================================
set -e

cd "$(dirname "$0")/.."
ROOT="$(pwd)"

echo "=========================================="
echo " JAQUEMATE Setup — Portafolio Jaqueting"
echo "=========================================="
echo ""

# ---------- 1. Prerequisitos ----------
echo "[1/6] Validando prerequisitos..."
command -v docker >/dev/null 2>&1 || { echo "ERROR: docker no instalado"; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "ERROR: docker compose plugin no disponible"; exit 1; }
command -v openssl >/dev/null 2>&1 || { echo "ERROR: openssl no instalado"; exit 1; }
echo "    OK"

# ---------- 2. Permisos del init script ----------
chmod +x postgres/init/01-create-databases.sh
echo "[2/6] Permisos de init script aplicados."

# ---------- 3. .env ----------
if [ ! -f .env ]; then
    echo "[3/6] .env no existe. Generandolo desde .env.example con secretos aleatorios..."

    cp .env.example .env

    PG_PASS=$(openssl rand -base64 32 | tr -d "/=+" | cut -c1-25)
    APP_SEC=$(openssl rand -base64 32)
    N8N_PASS=$(openssl rand -base64 32 | tr -d "/=+" | cut -c1-24)
    N8N_KEY=$(openssl rand -base64 32 | tr -d "/=+" | cut -c1-32)

    # Reemplazos in-place (compatible con BSD y GNU sed)
    sed -i.bak "s|REEMPLAZAR_password_postgres_25_chars_min|$PG_PASS|" .env
    sed -i.bak "s|REEMPLAZAR_app_secret_32_chars_random|$APP_SEC|" .env
    sed -i.bak "s|REEMPLAZAR_password_n8n_24_chars|$N8N_PASS|" .env
    sed -i.bak "s|REEMPLAZAR_encryption_key_32_chars_random|$N8N_KEY|" .env
    rm -f .env.bak

    echo "    .env generado. Credenciales guardadas."
    echo ""
    echo "    !!! ANOTAR ESTAS CREDENCIALES EN UN GESTOR SEGURO !!!"
    echo "    n8n admin user: $(grep N8N_BASIC_AUTH_USER .env | cut -d= -f2)"
    echo "    n8n admin pass: $N8N_PASS"
    echo ""
else
    echo "[3/6] .env ya existe. Reutilizandolo (no se generan nuevos secretos)."
fi

# ---------- 4. Verificar DNS ----------
echo "[4/6] Verificando DNS de los subdominios criticos..."
DOMAINS=(
    "app.jaquemate.jaqueting.com"
    "pespro.jaquemate.jaqueting.com"
    "traulog.jaquemate.jaqueting.com"
    "jaqueting.jaquemate.jaqueting.com"
    "fastnet.jaquemate.jaqueting.com"
    "cancun.jaquemate.jaqueting.com"
    "iki.jaquemate.jaqueting.com"
    "engine.jaquemate.jaqueting.com"
    "monitor.jaquemate.jaqueting.com"
)
DNS_FAIL=0
for d in "${DOMAINS[@]}"; do
    if ! host "$d" >/dev/null 2>&1; then
        echo "    AVISO: $d no resuelve. Crear A record en Cloudflare apuntando al VPS."
        DNS_FAIL=$((DNS_FAIL+1))
    fi
done
if [ "$DNS_FAIL" -gt 0 ]; then
    echo ""
    echo "    $DNS_FAIL subdominios no resuelven. Caddy va a fallar el SSL hasta que el DNS este listo."
    echo "    Podes continuar, pero los certificados se obtendran cuando el DNS propague."
    read -p "    Continuar igual? (s/n): " yn
    [ "$yn" != "s" ] && exit 0
else
    echo "    Todos los subdominios resuelven. OK."
fi

# ---------- 5. Levantar el stack ----------
echo "[5/6] Levantando el stack (docker compose up -d)..."
docker compose pull
docker compose up -d

# ---------- 6. Esperar a que server este healthy ----------
echo "[6/6] Esperando a que Twenty server este healthy (max 3 min)..."
TRIES=0
MAX_TRIES=36
while [ "$TRIES" -lt "$MAX_TRIES" ]; do
    STATUS=$(docker inspect --format='{{.State.Health.Status}}' jaquemate-twenty-server 2>/dev/null || echo "starting")
    if [ "$STATUS" = "healthy" ]; then
        echo "    Twenty server: HEALTHY"
        break
    fi
    sleep 5
    TRIES=$((TRIES+1))
done

if [ "$TRIES" -eq "$MAX_TRIES" ]; then
    echo "    AVISO: Twenty no esta healthy aun. Revisar logs:"
    echo "    docker compose logs server | tail -50"
fi

echo ""
echo "=========================================="
echo " Stack arriba."
echo "=========================================="
echo ""
echo " Acceso:"
echo "   Login portal:    https://app.jaquemate.jaqueting.com"
echo "   n8n:             https://engine.jaquemate.jaqueting.com"
echo "   Uptime monitor:  https://monitor.jaquemate.jaqueting.com"
echo ""
echo " Siguiente paso: crear los 6 workspaces."
echo "   bash scripts/provision-tenants.sh"
echo ""
