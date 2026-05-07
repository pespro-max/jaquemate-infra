#!/bin/bash
# ============================================================
# JAQUEMATE — Setup de organizacion de n8n por tenant
# n8n Community Edition NO tiene multi-tenancy nativo.
# Se usa convencion de tags + folders + naming consistente.
# Este script imprime la convencion y la documenta.
# ============================================================
set -e

cd "$(dirname "$0")/.."

cat <<EOF
==========================================
 Convencion de n8n por tenant
==========================================

n8n Community Edition NO tiene workspaces aislados como Twenty.
La separacion por tenant se hace por convencion estricta:

1. NAMING DE WORKFLOWS
   Cada workflow debe empezar con [tenant_slug].
   Ejemplos:
     - [pespro] Lead from Meta Ads
     - [traulog] Daily fleet status report
     - [jaqueting] Custom order webhook to CRM
     - [fastnet] Inbound contact form to email
     - [cancun] WhatsApp inquiry to workspace
     - [iki] Bilingual SMS reminder

2. TAGS
   Cada workflow lleva al menos 2 tags:
     - tenant: { pespro, traulog, jaqueting, fastnet, cancun, iki, portfolio }
     - tipo:   { trigger, sync, ai, alert, report }

   "portfolio" se usa para workflows transversales que tocan
   varios tenants (ej: weekly summary del portafolio entero).

3. CREDENCIALES
   Cada credencial nombrada con prefijo tenant:
     - pespro_apollo_api
     - traulog_twilio_main
     - jaqueting_meta_pixel
     etc.

   Esto evita que un workflow del tenant A use por error
   credenciales del tenant B.

4. FOLDERS (cuando n8n los soporte estables en Community)
   Folder por tenant: /pespro, /traulog, /jaqueting, /fastnet,
                      /cancun, /iki, /portfolio

5. WEBHOOKS
   Path convencion: /webhook/<tenant>/<evento>
   Ejemplos:
     - /webhook/pespro/new-lead
     - /webhook/jaqueting/order-created
     - /webhook/cancun/wa-inbound

6. BACKUPS DE WORKFLOWS
   Los workflows se exportan periodicamente como JSON al repo
   en /n8n/workflows/<tenant>/<nombre>.json para version control.

==========================================
 Para aplicar la convencion:
==========================================

1. Loguearse a https://engine.jaquemate.jaqueting.com
   (basic auth: admin + password generado en .env)

2. Settings → Tags. Crear estos tags:
   tenant:pespro, tenant:traulog, tenant:jaqueting,
   tenant:fastnet, tenant:cancun, tenant:iki,
   tenant:portfolio,
   tipo:trigger, tipo:sync, tipo:ai, tipo:alert, tipo:report

3. Crear primer workflow stub por tenant:
   "[pespro] Health check" — workflow vacio con trigger Manual,
   tag tenant:pespro, tag tipo:trigger.
   Repetir para los otros 5 tenants.

4. Cuando se crean credenciales nuevas, usar prefijo tenant.

==========================================

Nota cost-benefit:
n8n Pro/Enterprise con Projects nativos cuesta US\$24/usuario/mes.
Para 6 tenants con 1-2 builders, eso son \$48-\$48/mes solo en n8n.
La convencion de tags + naming da el 90% del valor a costo \$0.
Sacrificio: requiere disciplina humana, no se hace cumplir
automaticamente. Si la disciplina falla, hay riesgo de cross-tenant
mezcla. Mitigacion: revision mensual de workflows sin tags.

EOF
