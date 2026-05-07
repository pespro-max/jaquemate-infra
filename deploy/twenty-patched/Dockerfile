# Twenty + patch del límite de workspaces sin enterprise key.
# Ver README.md en este directorio.

ARG TWENTY_VERSION=latest
FROM twentycrm/twenty:${TWENTY_VERSION}

ARG MAX_WORKSPACES=100
ENV TWENTY_MAX_WORKSPACES_PATCH=${MAX_WORKSPACES}

USER root

# Patch idempotente: reemplaza `= 5;` por `= ${MAX_WORKSPACES};` en la constante.
# Si Twenty cambia el path o el formato, este sed no matchea y el build falla
# en la verificación posterior — entonces hay que actualizar la regla.
RUN set -eux; \
    FILE=/app/packages/twenty-server/dist/engine/core-modules/auth/constants/max-workspaces-without-enterprise-key.constants.js; \
    test -f "$FILE"; \
    sed -i "s/MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY = 5;/MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY = ${MAX_WORKSPACES};/" "$FILE"; \
    grep -q "MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY = ${MAX_WORKSPACES};" "$FILE"

USER 1000
