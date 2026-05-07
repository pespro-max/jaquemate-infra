#!/bin/bash
# ============================================================
# JAQUEMATE — Provisioning de los 6 tenants en Twenty CRM
# Twenty 1.x con IS_MULTIWORKSPACE_ENABLED requiere creacion
# via UI (no hay endpoint CLI para multi-workspace bootstrap).
# Este script:
#   1. Imprime el procedimiento exacto a seguir
#   2. Verifica que cada subdominio responda con SSL valido
# ============================================================
set -e

cd "$(dirname "$0")/.."

# Orden LOCKED por Eddy: pespro → traulog → jaqueting → fastnet → cancun → iki
TENANTS=(
    "pespro:PesPro:Servicios profesionales multi-tenant"
    "traulog:Traulog:Fleet management"
    "jaqueting:Jaqueting:Custom jacket e-commerce + agencia"
    "fastnet:FastNet:Engineering Atelier"
    "cancun:Cancun Makes Me Happy:Inbound turismo / yates"
    "iki:IKI Pestcontrol:Control de plagas residencial bilingue"
)

echo "=========================================="
echo " Provisioning de 6 tenants en Jaque Mate"
echo "=========================================="
echo ""
echo "Procedimiento (5-7 minutos total, 1 min por workspace):"
echo ""
echo "PASO 1 — Crear el usuario admin global"
echo "  - Abrir https://app.jaquemate.jaqueting.com"
echo "  - Sign up con tu email principal (ej: eddy@fastnet.solutions)"
echo "  - Confirmar email si SMTP esta configurado"
echo ""
echo "PASO 2 — Crear cada workspace en orden"
echo "  Para cada tenant:"
echo "  a) Click en 'Create Workspace' o avatar arriba derecha"
echo "  b) Ingresar el nombre del workspace exactamente como aparece"
echo "  c) Settings → Domains → Subdomain → ingresar el slug exacto"
echo "  d) Verificar que se accede via https://<slug>.jaquemate.jaqueting.com"
echo ""
echo "Workspaces a crear (orden lockeado):"
echo ""

i=1
for entry in "${TENANTS[@]}"; do
    IFS=':' read -r slug name desc <<< "$entry"
    printf "  %d. Slug: %-12s | Nombre: %-25s | %s\n" "$i" "$slug" "$name" "$desc"
    i=$((i+1))
done

echo ""
echo "=========================================="
echo " Verificacion de subdominios"
echo "=========================================="
echo ""

ALL_OK=1
for entry in "${TENANTS[@]}"; do
    IFS=':' read -r slug name desc <<< "$entry"
    URL="https://${slug}.jaquemate.jaqueting.com"

    # Verifica que el SSL es valido y la respuesta es 200/302
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$URL" || echo "000")

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "307" ] || [ "$HTTP_CODE" = "308" ]; then
        echo "  [OK]   $URL  (HTTP $HTTP_CODE)"
    elif [ "$HTTP_CODE" = "404" ]; then
        echo "  [PEND] $URL  — workspace aun no creado en UI"
        ALL_OK=0
    else
        echo "  [FAIL] $URL  (HTTP $HTTP_CODE)  — verificar DNS y Caddy"
        ALL_OK=0
    fi
done

echo ""
if [ "$ALL_OK" -eq 1 ]; then
    echo " Todos los workspaces accesibles."
else
    echo " Hay workspaces pendientes. Crearlos por UI siguiendo el orden de arriba."
fi
echo ""
echo " Siguiente paso: bootstrap de n8n folders por tenant"
echo "   bash scripts/setup-n8n-folders.sh"
echo ""
