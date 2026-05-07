---
proyecto: Jaque Mate — Roadmap
parte_de: Portafolio Jaqueting (FastNet Engineering Atelier)
modulo: "#7 — CRM (fork de Twenty bajo AGPL)"
horizonte: 12 meses (mayo 2026 → mayo 2027)
fecha: 2026-05-06
estado: aprobado para Fase 1
---

# Jaque Mate — Roadmap completo con spin-off

## Principio rector

**Toda modificación al fork de Twenty es parte del portafolio Jaqueting.** No hay rama "personal" ni rama "futura compañía". Hasta el mes 6 inclusive, cada commit, cada pieza de IP, cada activo de marca pertenece operativa y legalmente a FastNet/Jaqueting. La decisión de spin-off, si se toma en el mes 6, define después qué se transfiere y bajo qué términos a una entidad nueva.

Esto no es burocracia. Es lo que protege contra forks paralelos no autorizados y mantiene la opción real de NO hacer spin-off si el contexto cambia.

---

## Fase 0 — Pre-arranque (HOY, 6 mayo 2026)

**Estado actual:**
- Repo `pespro-max/fastnet-web` desplegado en Vercel ✅
- Marca FastNet completa con manual de 43pp ✅
- Marca Jaque Mate definida en este kit ✅
- Stack multitenant: pendiente de levantar HOY

**Lo que se ejecuta hoy** (kit `deploy/` adjunto):
1. VPS Hetzner CPX21 Ashburn US ($10/mes) provisionado
2. DNS de `*.jaquemate.jaqueting.com` apuntando al VPS
3. Docker stack arriba: Twenty + n8n + Postgres + Redis + Caddy
4. Los 6 workspaces creados en Twenty: pespro, traulog, jaqueting, fastnet, cancun, iki
5. Dos workspaces creados en n8n con la separación tenant ↔ portfolio
6. **Registro de dominios públicos** (Cloudflare Registrar, ~$27/año total): `jaquemate.app` + `getjaquemate.com`. Park inicial sin sitio. Bloqueo del namespace antes que un squatter lo tome — el costo de no hacerlo hoy es perder el dominio o pagar premium en mes 9.

**Importante:** lo que se levanta hoy es **Twenty upstream**, no el fork Jaque Mate todavía. El fork empieza en el Mes 1. Hoy validamos que la infra multi-tenant funciona con código vanilla antes de tocar nada.

---

## Fase 1 — Embebido (Meses 1-6)

**Tesis:** Jaque Mate vive como producto interno del portafolio Jaqueting. No hay landing pública, no hay GitHub público, no hay PR. Se prueba con clientes reales del portafolio (Jaqueting es tenant-cero, dogfooding diario) antes de exponerlo.

### Mes 1 — Bifurcación y branding

**Repo y código:**
- Crear repo `pespro-max/jaquemate` (privado)
- Fork de `twentyhq/twenty` apuntando a release stable más reciente
- Configurar GitHub Actions: build + test + deploy a staging del VPS
- Documentar el procedimiento de rebase contra upstream (clave para sostenibilidad)

**Branding aplicado en código:**
- Sustituir paleta default de Twenty por tokens `--jm-*` (archivo `jaquemate-tokens.css`)
- Cargar fuentes Fraunces, Inter, JetBrains Mono desde Google Fonts en el build
- Reemplazar logo y favicon por assets de `brand/`
- Cambiar wordmark "Twenty" por "Jaque Mate" en todos los layouts

**Sacrificio:** rebase contra upstream se vuelve más caro a medida que personalizamos. Mitigación: mantener todas las customizaciones en archivos overlay (un solo `jaquemate-overrides.css`, un solo `jaquemate-theme.tsx`), nunca tocar archivos del core Twenty si se puede evitar. Cada vez que tocás core, lo documentás en `docs/core-patches.md`.

**Equipo Jaqueting empieza dogfooding en mes 1, no mes 2.** Aunque el fork esté con apenas branding, Jaqueting (la agencia) usa ese workspace para sus propios leads desde el día 1. Es la única manera de detectar fricción real.

### Mes 2 — Apps Framework + Conector Jaqueting

**Decisión técnica clave de este mes:** Twenty 0.x lanzó el Apps Framework. Todas las customizaciones del portafolio se construyen como apps, no como patches al core. Esto reduce el costo de rebase de "alto" a "casi cero".

**Apps a construir (en orden):**

1. **`@jaquemate/jaqueting-connector`** — Webhooks bidireccionales con Jaqueting.com (custom jacket e-commerce). Cada order de Jaqueting genera un Contact + Opportunity en Jaque Mate.

2. **`@jaquemate/portfolio-sync`** — El pegamento del portafolio. Recibe eventos de los módulos #1-#6 (Gambito de Dama, Jaque Doble, Celada, Jaque Pastor, Caballo) vía n8n y crea/actualiza registros en Jaque Mate. Sin esto, Jaque Mate es CRM aislado. Con esto, Jaque Mate es **el registro central de todo lo que el portafolio toca**.

**Stack de las apps:** Component React + logic function NestJS + custom objects de Twenty.

### Mes 3 — IA básica

**App: `@jaquemate/ai-assistant` v0**

Funcionalidad mínima:
- Botón "AI" en cada Lead/Contact/Opportunity
- Acciones: redactar email de seguimiento, calificar lead, resumir conversación
- Chat lateral contextual sobre el registro actual

**Stack:** Claude Sonnet 4.6 vía API. Costo inicial estimado: ~$50/mes con 5 usuarios activos en Jaqueting + Traulog.

**Por qué no antes:** sin volumen de datos en Jaque Mate (mínimo 200-300 leads históricos), la IA da resultados pobres. El mes 1-2 acumula data; el mes 3 la usa.

### Mes 4 — WhatsApp Inbox

**App: `@jaquemate/whatsapp`**

- Aplicación a Meta Cloud API (puede tomar 2-4 semanas, por eso arranca trámite mes 4)
- Mientras Meta aprueba: construir el panel UI con webhook sandbox
- Lanzamiento real cuando Meta apruebe (probablemente mes 5)

**Por qué importa:** PesPro y IKI Pestcontrol operan principalmente vía WhatsApp con clientes residenciales LATAM. Sin WhatsApp en el CRM, Jaque Mate es inútil para ellos.

### Mes 5 — Plantillas + IA avanzada

**App: `@jaquemate/templates`**

Wizard al crear workspace que aplica plantilla pre-armada:
- E-commerce custom (template de Jaqueting)
- Logística (template de Traulog)
- Servicios profesionales (template de PesPro)
- Control de plagas (template de IKI)
- Renta de yates / inbound turismo (template de Cancun)
- Supermercado/Retail (template Corporación Torres futuro)

**Cada plantilla incluye:**
- Custom objects pre-configurados
- Pipelines con etapas correctas para esa industria
- Vistas y filtros típicos
- Prompts de IA específicos del rubro
- Workflows n8n preinstalados

**IA avanzada:**
- Lead scoring con Claude Sonnet
- Búsqueda semántica con Voyage embeddings + pgvector
- Recomendación de "leads similares" basada en deals históricos cerrados

### Mes 6 — Decisión de exposición pública (CHECKPOINT CRÍTICO)

**Antes de cualquier decisión, evaluación honesta de tres preguntas:**

1. **¿Jaque Mate es estable?** Métrica: cero downtime no planificado en últimos 30 días. Cero pérdida de datos. Tiempos de respuesta < 500ms p95.

2. **¿El portafolio funciona como sistema?** Métrica: al menos 3 de los 6 tenants generan deals cerrados con flujo Gambito → Mate operando end-to-end. Si solo Jaqueting (dogfooding) lo usa de verdad, no hay validación.

3. **¿Existe demanda externa?** Métrica: al menos 5 conversaciones de inbound (CTOs, founders) preguntando si pueden usar Jaque Mate. Sin demanda externa, lanzar es publicidad sin cliente.

**Si las tres respuestas son sí → Fase 2A (spin-off público).**

**Si dos o menos son sí → Fase 2B (sigue interno, replanteo a 12 meses).**

---

## Fase 2A — Spin-off público (Meses 7-9)

**Solo si el checkpoint del mes 6 da verde.**

### Mes 7 — Preparación legal y de marca

**Decisiones que hay que cerrar este mes:**

1. **Entidad legal del spin-off.** Recomendación firme cuando el momento llegue: LLC en Delaware con FastNet como holder mayoritario inicial. Coste: ~$300 + agente registrado anual. Sacrificio: complejidad fiscal cross-state. Alternativa rechazada (entidad en LATAM): peor para fundraising y para proteger AGPL compliance frente a auditorías.

2. **Naming oficial.** "Jaque Mate" funciona como producto. Como entidad legal puede colisionar (búsqueda USPTO pendiente). Si colisiona, alternativa: **"Mate Software LLC"**. Producto sigue siendo Jaque Mate.

3. **Estrategia de licencia dual.** AGPL-3.0 para self-host gratuito + commercial license para empresas que no quieren el copyleft. Modelo Penpot/Lago. Precio enterprise: $99/usuario/mes (referencia Twenty Enterprise).

4. **Marca pública.** Manual de 43pp tipo FastNet. Dominios ya bloqueados desde hoy: **`jaquemate.app`** (primario) + **`getjaquemate.com`** (typo redirect 301). Site público en Next.js similar a fastnet-web, alojado en `jaquemate.app` raíz. `cloud.jaquemate.app` reservado para Fase 3. `jaquemate.com` premium ($3K-$30K aftermarket) se reevalúa este mes con revenue real en mano — si los 10 clientes pagantes están firmes, justifica la compra; si no, queda como redirect dormido.

### Mes 8 — Lanzamiento de comunidad

- Repo público en `github.com/jaquemate/jaquemate` (transferido desde pespro-max)
- README orientado a CTOs: por qué fork, qué agrega, cómo correrlo
- Docker compose y guía "30 minutos hasta tu primer workspace"
- Discord/Slack de comunidad (Discord para tech-savvy LATAM, Slack si target es US)
- Lanzamiento coordinado en Hacker News + Reddit r/selfhosted + Show HN

**Crítico:** comunicar a Twenty (la empresa upstream) **antes** del lanzamiento público. Twenty es Y Combinator backed y agresivo. Riesgo medio de fricción cuando se haga público el spin-off. Mitigación: email cordial al equipo Twenty 2 semanas antes del launch, ofreciendo coordinar y respetar marca.

### Mes 9 — Primeros clientes pagos

Métrica de éxito: 10 clientes pagando enterprise license + 100 GitHub stars + 3 contributors externos.

Si no se llega: pivote a Fase 2B sin estigma. La AGPL community sigue, pero el modelo enterprise se replantea.

---

## Fase 2B — Permanencia interna (Meses 7-18)

**Solo si el checkpoint del mes 6 NO da verde.**

Jaque Mate sigue siendo módulo interno del portafolio Jaqueting. Sin landing pública. Sin marketing externo. Su valor para FastNet/Jaqueting es operativo: el CRM sobre el que corren los 6 tenants reales.

**Se sigue desarrollando:**
- Bug fixes y rebase contra upstream (cada 3 meses)
- Nuevas apps según necesidad de los tenants
- Mejoras de IA si los tenants las pagan

**Se NO desarrolla:**
- Features que solo serían valiosas para mercado externo
- Documentación pública
- Marketing site

**Replanteo en mes 12:** se reabre el checkpoint de exposición. Si las condiciones mejoraron (ej: más clientes vienen pidiendo el sistema), Fase 2A se ejecuta con 6 meses más de madurez.

---

## Fase 3 — Crecimiento (Meses 10-12, solo si Fase 2A se ejecutó)

### Mes 10 — Producto SaaS hosteado

Lanzar `cloud.jaquemate.app` como alternativa al self-host:
- $39/usuario/mes hostado (mitad del precio enterprise self-host)
- Onboarding en 5 minutos sin Docker
- Target: PyMEs LATAM que no quieren manejar VPS

**Sacrificio:** mantener un SaaS multi-tenant de verdad (no el "multi-tenant" simple de Twenty workspaces) requiere infra más cara. Empezar con AWS RDS multi-AZ + ECS Fargate. Coste base ~$200/mes hasta primer cliente.

### Mes 11-12 — Apps marketplace

Abrir el Apps Framework de Jaque Mate a third-party developers. Repositorio comunitario. Revenue sharing 70/30 a favor del developer.

**Métrica de éxito al cierre de mes 12:**
- 50 clientes pagando (mix self-host + cloud)
- $5k MRR
- 3 apps third-party publicadas
- 500+ GitHub stars

---

## Riesgos identificados y mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Hacerlo solo (sin equipo) | Alta | Crítico | Buscar 1 contractor part-time desde mes 4 (no mes 6 como plan original) |
| Twenty upstream se enoja por el fork público | Media | Alto | Comunicación cordial y temprana en mes 7 |
| AGPL no espanta empresas pero los abogados sí | Media | Medio | Licencia comercial paralela desde día 1 público |
| Comunidad open-source no aparece en 6 meses | Alta | Medio | Beta cerrada con 5-10 CTOs amigos en mes 3 (antes del público) |
| Costos de IA escalan con uso | Media | Medio | Cap por workspace + tier "AI off" gratis |
| Rebase de Twenty se vuelve doloroso | Media | Alto | Toda customización en apps, no en core. Tomar deuda de no rebasear si hace falta. |

---

## Compromisos NO negociables del roadmap

1. **Hasta el mes 6, todo es portafolio Jaqueting.** No hay marca paralela, no hay sitio público propio, no hay tweets sobre "mi nuevo proyecto Jaque Mate".

2. **El fork mantiene compatibilidad con Twenty upstream.** Si Twenty hace una breaking change en el Apps Framework, nosotros nos adaptamos, no forkeamos el framework.

3. **AGPL se respeta literalmente.** Si distribuimos binarios, el código está en GitHub. No hay "versión privada con extras" sin licencia comercial paralela formal.

4. **Dogfooding diario obligatorio.** Si Jaqueting (la agencia) deja de usar Jaque Mate por 7 días seguidos, eso es un alerta crítica de producto. Significa que estamos construyendo algo que ni nosotros queremos usar.

5. **El checkpoint del mes 6 es serio.** Si las métricas no dan, la decisión correcta es Fase 2B y replantear, no forzar el spin-off por orgullo.

---

## Resumen ejecutivo

| Mes | Hito | Modo |
|---|---|---|
| 0 | Twenty + n8n multi-tenant arriba con 6 workspaces | Validación infra |
| 1 | Fork con branding Jaque Mate aplicado | Embebido |
| 2 | Conector Jaqueting + Portfolio Sync | Embebido |
| 3 | IA básica | Embebido |
| 4 | WhatsApp (mes 5 lanzamiento real) | Embebido |
| 5 | Plantillas + IA avanzada | Embebido |
| 6 | **CHECKPOINT** | Decisión |
| 7-9 | Spin-off público (si checkpoint verde) | Público |
| 7-18 | Permanencia interna (si checkpoint rojo) | Interno |
| 10-12 | Cloud + Marketplace (si Fase 2A) | Crecimiento |

Toda esta tabla es **revocable** en cualquier checkpoint. El roadmap es plan, no contrato.
