---
proyecto: Jaque Mate Kit
fecha: 2026-05-06
duenio: FastNet Engineering Atelier / Jaqueting
licencia_codigo: AGPL-3.0 (heredado de Twenty CRM upstream)
licencia_marca: Propiedad de Jaqueting
---

# Jaque Mate Kit

Este paquete tiene **dos cosas separadas** que se ejecutan en momentos distintos.

## 1. Identidad y roadmap (`brand/`) — referencia de largo plazo

Define qué es Jaque Mate como producto. Hoy no se aplica todavía: el despliegue de hoy va con Twenty vanilla. La marca y el fork entran a partir del **Mes 1** del roadmap.

| Archivo | Para qué sirve |
|---|---|
| [`brand/identidad-corporativa-jaquemate.md`](brand/identidad-corporativa-jaquemate.md) | Manual de marca completo: naming, paleta, tipografía, lockup, tono, microcopy. Decisiones bloqueadas. |
| [`brand/jaquemate-logo.svg`](brand/jaquemate-logo.svg) | Lockup horizontal (mark + wordmark + descriptor). |
| [`brand/jaquemate-mark.svg`](brand/jaquemate-mark.svg) | Solo el cuadro 2x2 — favicon, app icon, avatar. |
| [`brand/jaquemate-mark-inverso.svg`](brand/jaquemate-mark-inverso.svg) | Variante para dark mode. |
| [`brand/jaquemate-tokens.css`](brand/jaquemate-tokens.css) | Variables CSS listas para importar al fork. |
| [`brand/roadmap-jaquemate.md`](brand/roadmap-jaquemate.md) | 12 meses con checkpoint en mes 6 y plan de spin-off. |

**Decisión bloqueada:** "Jaque Mate" en UI/marketing, "jaquemate" en código y dominios. Nunca "Nexus".

**Subdominio operacional bloqueado:** `*.jaquemate.jaqueting.com`. No `nexus.jaqueting.com` (naming previo erroneo). No `*.fastnet.solutions` (FastNet es la consultora, no el host del CRM).

**Dominios públicos bloqueados (verificados via DNS NS lookup el 2026-05-06):** `jaquemate.app` (primario, ~$14/año en Cloudflare) + `getjaquemate.com` (typo redirect 301, ~$11/año). `jaquemate.com` está parked en aftermarket ($3K-$30K) — descartado hoy, reevaluar mes 9 con revenue real.

**Hasta el mes 6 todo el código pertenece operativa y legalmente al portafolio Jaqueting/FastNet.** El spin-off (LLC propia, repo público, dual license, marketplace) sólo procede si los tres checkpoints del mes 6 dan verde. Si dan rojo, sigue siendo módulo interno y se replantea en mes 12.

## 2. Despliegue de hoy (`deploy/` + `plan-despliegue-hoy.md`) — ejecutar ya

Levanta los 6 tenants en Twenty + n8n + Uptime Kuma sobre un VPS Hetzner. Twenty es el upstream oficial sin fork. Costo: **US$10.71/mes** (CPX21 Ashburn).

### Punto de partida

**Empezar aquí → [`plan-despliegue-hoy.md`](plan-despliegue-hoy.md)**

Ese runbook tiene los 9 pasos en orden (8 de infra + 1 paralelo de registro de dominios públicos). Los archivos de `deploy/` los va a ir referenciando.

### Contenido de `deploy/`

| Ruta | Qué hace |
|---|---|
| `docker-compose.yml` | Twenty (server + worker) + Postgres 16 + Redis + n8n + Caddy + Uptime Kuma. |
| `.env.example` | Plantilla de variables. `setup.sh` la copia a `.env` y rellena los secretos. |
| `caddy/Caddyfile` | TLS automático via Let's Encrypt para los 9 subdominios. |
| `postgres/init/01-create-databases.sh` | Crea la base `n8n` junto a la `default` de Twenty en el primer arranque. |
| `scripts/setup.sh` | Master: valida deps, genera secretos, levanta el stack. |
| `scripts/provision-tenants.sh` | Documenta el procedimiento de UI para los 6 workspaces en orden. |
| `scripts/setup-n8n-folders.sh` | Convención de tags para separación por tenant en n8n Community. |
| `scripts/backup.sh` | Cron diario 2 AM, retención 30 días. |
| `scripts/health-check.sh` | Verifica contenedores, endpoints y disco. |

### Los 6 tenants en orden bloqueado

1. **pespro** — `pespro.jaquemate.jaqueting.com`
2. **traulog** — `traulog.jaquemate.jaqueting.com`
3. **jaqueting** — `jaqueting.jaquemate.jaqueting.com`
4. **fastnet** — `fastnet.jaquemate.jaqueting.com`
5. **cancun** — `cancun.jaquemate.jaqueting.com`
6. **iki** — `iki.jaquemate.jaqueting.com`

Más tres servicios compartidos: `app` (Twenty default), `engine` (n8n), `monitor` (Uptime Kuma).

## Lo que NO está en este kit (y por qué)

| Cosa | Por qué no hoy | Cuándo sí |
|---|---|---|
| El fork Jaque Mate | Hoy es Twenty vanilla. Forkear antes de tener uso real es trabajo desperdiciado. | Mes 1 del roadmap, después de 2-3 semanas usando vanilla. |
| n8n Pro Projects | $24/usuario/mes × 6 = $144/mes. La convención de tags resuelve el 95%. | Sólo si el equipo crece a 10+ y la convención falla. |
| S3 / object storage | Local hasta 5 GB de adjuntos. | Cuando se acerque al límite. |
| SMTP propio | Mail no es crítico para CRM interno hoy. | Cuando se mande email transaccional al cliente. |
| SSO / Keycloak | Overkill para 6 tenants internos. | Si Jaque Mate gana clientes externos en mes 9+. |

Cada uno de estos se justificó en cost-benefit explícito: el costo de añadirlo hoy supera el valor que entrega.

## Orden recomendado de lectura

1. `plan-despliegue-hoy.md` — qué se hace hoy, paso a paso.
2. `brand/identidad-corporativa-jaquemate.md` — qué se está construyendo a largo plazo.
3. `brand/roadmap-jaquemate.md` — cómo se llega del Twenty vanilla de hoy al Jaque Mate público del mes 9.

Los demás archivos los va llamando el runbook cuando hace falta.
