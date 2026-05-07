---
proyecto: Jaque Mate
componente: n8n (orquestador, Community Edition)
url: https://engine.jaquemate.jaqueting.com
auth: basic auth (admin / ver `deploy/.env` → `N8N_BASIC_AUTH_PASSWORD`)
fecha: 2026-05-07
---

# Convención de uso de n8n por tenant

n8n Community Edition no tiene workspaces aislados como Twenty. La separación por tenant se hace por convención estricta. Esta convención reemplaza a n8n Pro (US$24/usuario/mes × ~6 builders = ~$144/mes) sin perder claridad operativa.

## 1. Naming de workflows

Cada workflow empieza con `[<tenant_slug>]`:

```
[pespro]    Lead from Meta Ads
[traulog]   Daily fleet status report
[jaqueting] Custom order webhook → CRM
[fastnet]   Inbound contact form → email
[cancun]    WhatsApp inquiry → workspace
[iki]       Bilingual SMS reminder
[portfolio] Weekly summary del portafolio (transversal a varios tenants)
```

## 2. Tags (ya creados — confirmado en DB)

Cada workflow lleva al menos 2 tags: uno de **tenant**, uno de **tipo**.

**Tenant** (7):
- `tenant:pespro`
- `tenant:traulog`
- `tenant:jaqueting`
- `tenant:fastnet`
- `tenant:cancun`
- `tenant:iki`
- `tenant:portfolio`  *(workflows transversales que tocan varios tenants)*

**Tipo** (5):
- `tipo:trigger`  — webhook/manual/schedule entrante
- `tipo:sync`    — bidireccional con sistema externo (Twenty ↔ Meta, ↔ Stripe, etc.)
- `tipo:ai`      — invoca un LLM
- `tipo:alert`   — produce notificación (Slack, email, SMS)
- `tipo:report`  — produce documento o dashboard

Verificar en n8n: **Settings → Tags** debería listar los 12.

## 3. Credenciales

Nombrar con prefijo del tenant para que un workflow del tenant A nunca pueda usar credenciales del tenant B por error:

```
pespro_apollo_api
traulog_twilio_main
jaqueting_meta_pixel
fastnet_resend_smtp
cancun_whatsapp_business
iki_gsuite_oauth
```

**Excepción:** credenciales infra compartidas llevan prefijo `shared_` (ej: `shared_postgres_jaquemate`, `shared_twentycrm_admin`). Usarlas con criterio.

## 4. Webhooks

Path con tenant adelante:

```
/webhook/<tenant>/<evento>
```

Ejemplos:
- `/webhook/pespro/new-lead`
- `/webhook/jaqueting/order-created`
- `/webhook/cancun/wa-inbound`
- `/webhook/iki/sms-reply`

**URL completa**: `https://engine.jaquemate.jaqueting.com/webhook/<tenant>/<evento>`

## 5. Folders (cuando n8n los soporte estables en Community)

Cuando el feature salga de beta:

```
/pespro
/traulog
/jaqueting
/fastnet
/cancun
/iki
/portfolio
```

Hasta entonces, los tags + naming cumplen la función.

## 6. Backups de workflow JSON

Los workflows se exportan periódicamente como JSON al repo del kit en:

```
deploy/n8n/workflows/<tenant>/<nombre-del-workflow>.json
```

Esto da version control + rollback + portabilidad si en el futuro migramos a otra instancia.

## 7. Cómo crear el primer workflow stub por tenant

Ya creé los 12 tags base via SQL. Para que cada tenant tenga al menos un workflow visible:

1. Login en https://engine.jaquemate.jaqueting.com
2. New workflow → nombre `[pespro] Health check`
3. Activá el trigger Manual, dejá el workflow vacío
4. Tags: `tenant:pespro`, `tipo:trigger`
5. Save & Activate
6. Repetir para los otros 5 tenants

Total: 5 minutos.

## 8. Cost-benefit de esta convención vs n8n Pro

| | Community + esta convención | n8n Pro |
|---|---|---|
| Costo | $0 | ~$144/mes (6 users × $24) |
| Aislamiento técnico | No (todos los workflows visibles a todos los builders) | Sí (Projects nativos) |
| Disciplina requerida | Alta (revisión mensual de workflows sin tags) | Baja |
| Migración a Pro después | Trivial: los tags persisten, agregar Projects encima | N/A |

**Decisión bloqueada hoy**: Community + convención. Reevaluar si el equipo de builders crece a 10+ y la disciplina falla.

## 9. Mantenimiento

**Revisión mensual**:
```sql
-- Workflows sin tag de tenant (cross-tenant risk)
SELECT w.name, w.id
FROM workflow_entity w
LEFT JOIN workflows_tags wt ON wt."workflowId" = w.id
LEFT JOIN tag_entity t ON t.id = wt."tagId" AND t.name LIKE 'tenant:%'
WHERE t.id IS NULL;
```

Cero filas = todo workflow está taggeado. Si hay filas, taggear o archivar.

---

**Stack de hoy:** 6 tenants en Twenty (pespro/traulog/jaqueting/fastnet/cancun/iki) + n8n + Uptime Kuma + Caddy en `*.jaquemate.jaqueting.com`. Los 6 workspaces accesibles vía sus subdominios; n8n único en `engine.jaquemate.jaqueting.com`.
