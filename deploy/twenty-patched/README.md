# twenty-patched

Imagen Docker que extiende `twentycrm/twenty` para superar el límite de **5 workspaces**
hard-coded en la edición Community (sin enterprise key).

## Por qué existe este patch

Twenty self-hosted Community (verificado en versión 2.2.0, mayo 2026) incluye un guard en
`AuthService.assertWorkspaceCountWithinLimit()`:

```js
if (this.enterprisePlanService.isValid()) return;
if (workspaceCount < MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY) return;
throw new AuthException(`Cannot create more than ${...} workspaces without a valid enterprise key`);
```

La constante por defecto vale `5`. Al intentar crear el 6.º workspace via la mutation
`signUpInNewWorkspace`, Twenty responde `FORBIDDEN_EXCEPTION`.

Jaque Mate hostea **6 marcas** (pespro, traulog, jaqueting, fastnet, cancun, iki) más
el workspace `app` por convención, así que necesitamos el límite elevado.

## Qué hace el `sed`

Reemplaza, dentro del archivo compilado de la imagen, exactamente esta línea:

```js
const MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY = 5;
```

por

```js
const MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY = 100;
```

Path completo del archivo dentro del container:

```
/app/packages/twenty-server/dist/engine/core-modules/auth/constants/max-workspaces-without-enterprise-key.constants.js
```

El `RUN` del Dockerfile incluye un `grep` que verifica que la sustitución se aplicó. Si
Twenty cambia el archivo o el formato en una versión futura, el `grep` falla y el `docker
build` aborta — eso es la señal para revisar la regla.

## Cómo se usa

`docker-compose.yml` ya apunta `server` y `worker` a `build: ./twenty-patched`. Para
re-construir contra una versión nueva de Twenty:

```bash
cd deploy
TWENTY_TAG=v2.3.0 docker compose build server worker
docker compose up -d server worker
```

`TWENTY_TAG` se pasa como build-arg `TWENTY_VERSION` y como tag de la imagen resultante
(`jaquemate/twenty-patched:<tag>`).

## Cuándo evaluar reemplazo

Quitar este patch cuando se cumpla **alguna** de estas condiciones:

1. **Twenty libera workspace creation público** sin gating por enterprise key (issue a
   trackear en su repo). En ese caso, volver a `image: twentycrm/twenty:<tag>` directo.

2. **Compramos enterprise license** de Twenty. Setear `TWENTY_ENTERPRISE_KEY=...` en
   `deploy/.env`; el guard `enterprisePlanService.isValid()` la valida y skipea el
   límite.

3. **Migramos a otra plataforma de CRM**. El patch desaparece junto con todo el stack.

## Gotcha histórico

Este patch reemplaza el approach **in-container** que usábamos antes (sed contra el
container vivo + `restart server worker`). Aquel approach NO persistía: cualquier
`docker compose pull` o reset de la imagen volvía a `= 5`. Los workspaces ya creados
quedaban intactos (la constante sólo se chequea en CREATE), pero crear un workspace
nuevo requería re-aplicar el patch a mano. Con el Dockerfile, la imagen local
(`jaquemate/twenty-patched`) se reconstruye automáticamente en cada `docker compose
build` y el patch persiste.
