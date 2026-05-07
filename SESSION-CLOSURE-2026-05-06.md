---
proyecto: Jaque Mate Kit
fecha_inicio: 2026-05-06
fecha_cierre: 2026-05-07
duenio: FastNet Engineering Atelier / Jaqueting
---

# Cierre de sesión — Jaque Mate deploy 2026-05-06/07

## Resumen ejecutivo

Stack **operativo** en VPS Hetzner CCX13 (Ashburn). 6 workspaces de Twenty CRM activos
con sus subdominios `*.jaquemate.jaqueting.com`, n8n con basic auth, Uptime Kuma
desplegado (con setup wizard pendiente), backups diarios automáticos, certs Let's
Encrypt válidos hasta agosto 2026.

| Métrica | Estado |
|---|---|
| Containers up | 7/7 |
| Workspaces ACTIVE | 6 |
| Endpoints HTTPS verificados | 9/9 (`bash deploy/scripts/health-check.sh` → TODO OK) |
| Disco /var/lib/docker | 12% |
| Costo mensual actual | **US$20.59** (Hetzner CCX13) |
| Repo en GitHub | https://github.com/pespro-max/jaquemate-infra (privado) |

## Servicios y URLs

| Servicio | URL | Notas |
|---|---|---|
| Twenty default (login) | https://app.jaquemate.jaqueting.com | Subdomain `app` |
| Workspace PesPro | https://pespro.jaquemate.jaqueting.com | ACTIVE, vacío de seed |
| Workspace Traulog | https://traulog.jaquemate.jaqueting.com | ACTIVE, vacío de seed |
| Workspace Jaqueting | https://jaqueting.jaquemate.jaqueting.com | ACTIVE, vacío de seed |
| Workspace FastNet | https://fastnet.jaquemate.jaqueting.com | ACTIVE, vacío de seed |
| Workspace Cancun Makes Me Happy | https://cancun.jaquemate.jaqueting.com | ACTIVE, vacío de seed |
| Workspace IKI Pestcontrol | https://iki.jaquemate.jaqueting.com | ACTIVE, vacío de seed |
| n8n | https://engine.jaquemate.jaqueting.com | Basic auth (admin / pass en `.env`) |
| Uptime Kuma | https://monitor.jaquemate.jaqueting.com | **Wizard pendiente** (0 users en SQLite) |
| Apex (proxy a Twenty) | https://jaquemate.jaqueting.com | Reverse proxy, NO redir |

Owner CRM en los 6 workspaces: `eddy@fastnet.solutions`.

## Decisiones técnicas tomadas

1. **VPS Hetzner CCX13 (8 GB RAM, Ashburn)** en lugar de CPX21 (4 GB) que indicaba el
   plan original. Costo +$10/mes pero margen para los 7 containers (Twenty solo come
   ~2.5 GB en steady state).

2. **Subdominios `*.jaquemate.jaqueting.com`** como host operativo (no
   `nexus.jaqueting.com` ni `*.fastnet.solutions`). 10 A records configurados.

3. **`SERVER_URL` apuntando al apex** (`https://jaquemate.jaqueting.com`), sin el
   prefijo `app.`. El default de Twenty incluye `app.` pero eso producía URLs de
   workspace tipo `app.app.jaquemate...` y rompía el SPA. El apex se proxea a
   `server:3000`, no se redirige (un `redir` rompía API calls cross-origin).

4. **Workspaces creados via mutation `signUpInNewWorkspace`** en endpoint `/metadata`
   (NO `/graphql`), con JWT WORKSPACE_AGNOSTIC forjado usando `APP_SECRET`. La UI
   self-hosted no expone "Create Workspace" (gating heredado de Twenty Cloud) pero el
   backend está sin gate. Ver memoria `twenty_workspace_creation_via_api`.

5. **Patch a `MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY`** (5 → 100). Originalmente
   aplicado in-container con `sed` — efímero ante `docker compose pull`. Esta sesión
   se persiste vía `deploy/twenty-patched/Dockerfile`.

6. **Subdomain canónico vía SQL post-signup**: cada `signUpInNewWorkspace` con email
   `eddy@fastnet.solutions` genera subdomain `fastnet` o `fastnet-XXXX` (auto-derivado
   por Twenty). Se sobreescribe con `UPDATE core.workspace SET subdomain='<canonical>'
   WHERE id=<new>` para liberar el slot canónico.

7. **n8n tags base creados directo en `n8n.public.tag_entity`** vía SQL — el endpoint
   `/rest` rechaza basic auth en versiones recientes (gating por user-management
   session). Convención de tags por tenant en `N8N-CONVENTIONS.md`.

8. **Cron de backup en eddy crontab, no root**: `sudo` requiere password en este host
   y queríamos autonomía. Convertible a root crontab si se setea NOPASSWD.

## Bugs encontrados y resueltos

- `app.app.jaquemate...` URL bug → fix `SERVER_URL=apex` + Caddyfile sin redir.
- 6.º workspace bloqueado por `FORBIDDEN_EXCEPTION` → patch
  `MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY = 100`.
- Health-check daba FAIL post-reboot frío → `wait_for_starting` con grace 90s
  (commit `28a247a`). Esta sesión se extiende a estado `unhealthy` también, y se
  aplica a `db`, `redis`, `twenty-server`.
- Bind mount inode gotcha al editar `Caddyfile` con atomic write → restart container
  para re-mapear inode. Memoria `docker_bind_mount_inode_gotcha`.
- n8n REST 401 con basic auth → bypass al insertar tags vía SQL.

## Pendientes diferidos (con prioridad)

| Prio | Pendiente | Cuándo |
|---|---|---|
| **Alta — esta semana** | Registrar dominios `jaquemate.app` (~$14/año) y `getjaquemate.com` (~$11/año, typo redirect). | 2026-05-08/09 |
| **Alta — esta semana** | Setup wizard de Uptime Kuma (UI manual): crear admin + 9 monitors HTTPS. | 2026-05-08 |
| **Alta — al volver** | Eddy debe archivar `deploy/.env` en gestor de password (n8n admin pass, postgres pass, APP_SECRET, N8N_ENCRYPTION_KEY). | Inmediato |
| **Media — kernel** | Reboot manual para subir kernel 6.8.0-90 → 6.8.0-111 (sudo en server pide password, no NOPASSWD). | Próxima ventana de mantenimiento |
| **Media — cuando se necesite** | SMTP real (vars ya commented en `docker-compose.yml`). Hoy mail no es crítico. | Cuando se mande email transaccional |
| **Media — mes 1** | Empezar fork Jaque Mate sobre Twenty (roadmap mes 1). Hoy es Twenty vanilla. | Mes 1 |
| **Baja — mes 3-6** | Decisión escalado a 1000 tenants: pasar de single-VPS a multi-region o Kubernetes. Depende de demand signals. | Checkpoint mes 6 |
| **Baja — mes 6** | Spin-off Jaque Mate (LLC, repo público, dual license, marketplace) sólo si los 3 checkpoints del roadmap dan verde. | Mes 6 |

## Comandos clave para retomar mañana

```bash
# Conectar al VPS
ssh eddy@5.161.43.84

# Lanzar Claude Code en el repo del kit
cd ~/jaquemate && claude

# Ver estado del stack
docker compose -f ~/jaquemate/deploy/docker-compose.yml ps

# Health check completo (containers + endpoints + disco)
bash ~/jaquemate/deploy/scripts/health-check.sh

# Logs del server o worker
docker compose -f ~/jaquemate/deploy/docker-compose.yml logs server --tail 100
docker compose -f ~/jaquemate/deploy/docker-compose.yml logs worker --tail 100

# Backup manual on-demand
bash ~/jaquemate/deploy/scripts/backup.sh

# Re-construir imagen patcheada (ej. tras cambio en twenty-patched/Dockerfile)
cd ~/jaquemate/deploy && docker compose build server worker && docker compose up -d server worker
```

## Costos actuales mensuales

| Concepto | USD/mes |
|---|---|
| Hetzner CCX13 (Ashburn, 8 GB / 80 GB SSD / 20 TB tráfico) | 20.59 |
| **Total infra** | **20.59** |

Costos próximos esperados (no comprometidos):
- `jaquemate.app` + `getjaquemate.com` registro: ~$25/año amortizado.
- SMTP cuando entre en juego: $0 (resend.com free tier hasta 3k/mes) → ~$10/mes a partir de 50k/mes.

## Estado del repo

- **GitHub:** https://github.com/pespro-max/jaquemate-infra (privado)
- **Branch:** `main`
- **Último commit antes de esta sesión:** `28a247a — health-check: esperar containers
  en estado 'starting' post-reboot`
- **Cambios de esta sesión** (a commitear en PASO 5): health-check extendido a
  `unhealthy`, `deploy/twenty-patched/{Dockerfile,README.md}`, docker-compose con
  build, este SESSION-CLOSURE, README de raíz actualizado.
