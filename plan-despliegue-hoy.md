---
proyecto: Jaque Mate — Plan de despliegue de hoy
fecha: 2026-05-06
objetivo: 6 tenants Twenty + n8n arriba en jaqueting.com en < 60 minutos
estado: listo para ejecutar
---

# Plan de despliegue de hoy

## Lo que entrega este runbook

Al final de los 9 pasos siguientes:

- VPS Hetzner CPX21 corriendo el stack
- Twenty CRM accesible en `app.jaquemate.jaqueting.com` con multi-workspace habilitado
- 6 workspaces creados en orden: **pespro, traulog, jaqueting, fastnet, cancun, iki**
- n8n accesible en `engine.jaquemate.jaqueting.com` con basic auth
- Uptime Kuma en `monitor.jaquemate.jaqueting.com`
- Backups diarios automatizados via cron
- Health check ejecutable en cualquier momento

**Costo mensual de la infra:** US$10.71 (Hetzner CPX21 Ashburn US, Mayo 2026).

**Tiempo total estimado:** 45-60 minutos si DNS ya esta propagado, 90 min si hay que esperar DNS.

---

## Prerequisitos antes de arrancar

| Item | Como verificar | Si falta |
|---|---|---|
| Cuenta Hetzner Cloud | Login en console.hetzner.cloud | Crear (5 min) |
| Acceso DNS de `jaqueting.com` | Saber donde estan los nameservers | Trasladar a Cloudflare (recomendado) |
| Clave SSH local | `ls ~/.ssh/id_*.pub` | Generar `ssh-keygen -t ed25519` |
| Dominio `jaqueting.com` activo | `dig jaqueting.com NS` | Renovar |

---

## Paso 1 — Provisionar el VPS (10 min)

En Hetzner Cloud Console:

1. Servers → Add Server
2. Location: **Ashburn (us-east)**
3. Image: **Ubuntu 24.04**
4. Type: **CPX21** (3 vCPU AMD, 4 GB RAM, 80 GB SSD, US$10.71/mes)
5. SSH key: subir tu `~/.ssh/id_ed25519.pub`
6. Name: `jaquemate-prod-1`
7. Create & Buy

Esperar a que arranque (~30s) y anotar la IP publica del VPS.

**Por que CPX21 y no CX22 o CPX31:**
- CPX21 (4 GB) es el mínimo para correr Twenty + n8n + Postgres + Redis sin swap. CX22 (4 GB pero 2 vCPU) tiene la misma RAM pero menos CPU, lo que importa para Twenty bajo carga.
- CPX31 (8 GB) es 2x el precio (~US$20). Es el upgrade obvio cuando lleguemos a 5+ usuarios concurrentes en Twenty o n8n procese > 1k ejecuciones/dia. Hoy no.

Sacrificio elegido: 4 GB RAM puede quedar justa si todos los 6 workspaces tienen carga simultanea de IA + sync. Mitigacion: CPX31 upgrade es 1 click cuando haga falta.

---

## Paso 2 — Configurar DNS (5 min, propagacion 5-30 min)

En el panel DNS de `jaqueting.com` (Cloudflare recomendado), crear estos **9 A records** apuntando a la IP del VPS:

```
A   jaquemate            → <IP_VPS>
A   app.jaquemate        → <IP_VPS>
A   pespro.jaquemate     → <IP_VPS>
A   traulog.jaquemate    → <IP_VPS>
A   jaqueting.jaquemate  → <IP_VPS>
A   fastnet.jaquemate    → <IP_VPS>
A   cancun.jaquemate     → <IP_VPS>
A   iki.jaquemate        → <IP_VPS>
A   engine.jaquemate     → <IP_VPS>
A   monitor.jaquemate    → <IP_VPS>
```

Cloudflare: **PROXY OFF (gris, no naranja)** durante la primera obtencion de SSL. Caddy va a hacer HTTP-01 challenge y necesita ver tu IP real. Despues de SSL valido, podes prender el proxy si quieres.

Verificacion:
```bash
for sub in app pespro traulog jaqueting fastnet cancun iki engine monitor; do
    echo -n "$sub.jaquemate.jaqueting.com: "
    dig +short "$sub.jaquemate.jaqueting.com" | head -1
done
```

Las 9 lineas tienen que devolver la misma IP del VPS antes de seguir.

---

## Paso 3 — Setup base del VPS (5 min)

SSH al VPS:
```bash
ssh root@<IP_VPS>
```

Hardening minimo y dependencias:
```bash
# Actualizar
apt update && apt upgrade -y

# Crear usuario no-root
adduser --disabled-password --gecos "" eddy
usermod -aG sudo eddy
mkdir -p /home/eddy/.ssh
cp ~/.ssh/authorized_keys /home/eddy/.ssh/
chown -R eddy:eddy /home/eddy/.ssh
chmod 700 /home/eddy/.ssh
chmod 600 /home/eddy/.ssh/authorized_keys

# Firewall basico
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 443/udp  # HTTP/3 que usa Caddy
ufw --force enable

# Docker
curl -fsSL https://get.docker.com | sh
usermod -aG docker eddy

# Otros
apt install -y openssl curl bind9-host
```

Salir del VPS y volver a entrar como `eddy`:
```bash
exit
ssh eddy@<IP_VPS>
```

---

## Paso 4 — Subir el kit y configurar (5 min)

Desde tu maquina local, subir el kit al VPS:

```bash
# Asumiendo que clonaste o copiaste este kit a /tmp/jaquemate-kit/deploy
scp -r /tmp/jaquemate-kit/deploy eddy@<IP_VPS>:/home/eddy/jaquemate
```

O alternativamente, hacer un repo privado en GitHub `pespro-max/jaquemate-infra`, subir el contenido de `deploy/` y clonarlo en el VPS:

```bash
# En el VPS
cd /home/eddy
git clone git@github.com:pespro-max/jaquemate-infra.git jaquemate
cd jaquemate
chmod +x scripts/*.sh
chmod +x postgres/init/01-create-databases.sh
```

---

## Paso 5 — Levantar el stack (5-15 min, casi todo es download de imagenes)

```bash
cd /home/eddy/jaquemate
bash scripts/setup.sh
```

El script:
1. Valida que docker, docker compose y openssl esten
2. Genera `.env` con secretos aleatorios fuertes (Postgres, APP_SECRET, n8n encryption key, n8n admin password)
3. Verifica que los 9 subdominios resuelvan (avisa pero permite continuar si no)
4. Hace `docker compose pull` (descarga ~3 GB de imagenes la primera vez)
5. Hace `docker compose up -d`
6. Espera hasta 3 minutos a que Twenty server pase a healthy

**ANOTAR las credenciales que imprime el script** — el password de admin de n8n esta solo en este momento en pantalla y en el `.env`. Guardarlo en 1Password / Bitwarden YA.

Si algo falla:
```bash
docker compose logs -f  # ver logs de todo
docker compose ps       # estado de cada container
```

---

## Paso 6 — Crear los 6 workspaces (10 min)

```bash
bash scripts/provision-tenants.sh
```

El script imprime el procedimiento exacto. Resumen:

1. Abrir `https://app.jaquemate.jaqueting.com` en navegador
2. Sign up con tu email primario
3. Click "Create Workspace" 6 veces, una por tenant, en este orden EXACTO:

| # | Workspace name | Subdomain slug | URL final |
|---|---|---|---|
| 1 | PesPro | `pespro` | https://pespro.jaquemate.jaqueting.com |
| 2 | Traulog | `traulog` | https://traulog.jaquemate.jaqueting.com |
| 3 | Jaqueting | `jaqueting` | https://jaqueting.jaquemate.jaqueting.com |
| 4 | FastNet | `fastnet` | https://fastnet.jaquemate.jaqueting.com |
| 5 | Cancun Makes Me Happy | `cancun` | https://cancun.jaquemate.jaqueting.com |
| 6 | IKI Pestcontrol | `iki` | https://iki.jaquemate.jaqueting.com |

El subdomain slug se setea en cada workspace en **Settings → Domains → Subdomain**.

Despues de crearlos, re-correr el script para verificar que los 6 responden:
```bash
bash scripts/provision-tenants.sh
```

Las 6 lineas tienen que decir `[OK]`.

---

## Paso 7 — Configurar n8n (5 min)

```bash
bash scripts/setup-n8n-folders.sh
```

Esto imprime la convencion de tags + naming que organiza n8n por tenant **sin pagar la version Pro** ($24/usuario/mes). Aplicarla manualmente:

1. Login en `https://engine.jaquemate.jaqueting.com` con admin + password de `.env`
2. Settings → Tags → crear: `tenant:pespro`, `tenant:traulog`, `tenant:jaqueting`, `tenant:fastnet`, `tenant:cancun`, `tenant:iki`, `tenant:portfolio`
3. Tambien: `tipo:trigger`, `tipo:sync`, `tipo:ai`, `tipo:alert`, `tipo:report`
4. Crear 6 workflows stub (uno por tenant) con nombre `[<slug>] Health check` y los 2 tags correspondientes

---

## Paso 8 — Backups + monitoring (5 min)

Crontab del usuario `eddy` para backup diario a las 2 AM:
```bash
crontab -e

# Agregar:
0 2 * * * /home/eddy/jaquemate/scripts/backup.sh >> /home/eddy/jaquemate/backup.log 2>&1
```

Configurar Uptime Kuma en `https://monitor.jaquemate.jaqueting.com`:
1. Crear usuario admin (primera vez)
2. Add New Monitor por cada uno de los 9 subdominios
3. Type: HTTPS, interval: 60s
4. Notifications: configurar email o webhook

---

## Paso 9 — Registro de dominios públicos (5 min, en paralelo, $27)

**Esto NO bloquea el despliegue. Se hace en paralelo en otra pestaña mientras el VPS está corriendo.**

Verificado por DNS NS lookup el 2026-05-06: `jaquemate.app` y `getjaquemate.com` disponibles a precio retail.

1. Abrir Cloudflare Registrar en `https://dash.cloudflare.com/?to=/:account/domains/register`
2. Registrar **`jaquemate.app`** (~$14/año a precio costo)
3. Registrar **`getjaquemate.com`** (~$11/año a precio costo)
4. En `getjaquemate.com` configurar **Page Rule** o **Bulk Redirect**: `*.getjaquemate.com/*` → `https://jaquemate.app/$1` con código 301 permanente
5. En `jaquemate.app` dejar landing temporal: o bien parking page de Cloudflare, o redirect 302 a `fastnet.solutions/jaquemate` si querés un placeholder con marca

**Por qué hoy y no después:**
- Costo de no hacerlo: alguien puede registrar `jaquemate.app` en cualquier momento y volverse squatter o competidor con tu nombre.
- Costo de hacerlo: $27/año.
- Cost-benefit positivo aún si Jaque Mate nunca se hace público — los dos dominios siguen siendo defensivos para el portafolio.

**Por qué Cloudflare Registrar y no Namecheap/GoDaddy:**
- Cloudflare vende a precio costo de la TLD (sin markup).
- Sobre los 5 años de uso típico: ahorra ~$50 vs GoDaddy.
- DNS, SSL y CDN integrados sin mover nameservers.

**Por qué NO comprar `jaquemate.com` hoy:**
- Está parked en Namefind/GoDaddy aftermarket.
- Precio estimado: $3K-$30K. Quien pone precio es la reseller, no hay piso fijo.
- Pre-checkpoint mes 6: si Jaque Mate no se vuelve producto público, esa plata queda enterrada.
- Decisión bloqueada: reevaluar adquisición premium en mes 9 con revenue real en mano.

---

## Verificacion final

```bash
bash scripts/health-check.sh
```

Tiene que devolver:
```
Containers:
  [OK]   postgres healthy
  [OK]   redis healthy
  [OK]   twenty server healthy
  [OK]   twenty worker running
  [OK]   n8n running
  [OK]   caddy running
  [OK]   uptime-kuma running

Endpoints:
  [OK]   app.jaquemate...           HTTPS
  [OK]   pespro.jaquemate...        HTTPS
  [OK]   traulog.jaquemate...       HTTPS
  [OK]   jaqueting.jaquemate...     HTTPS
  [OK]   fastnet.jaquemate...       HTTPS
  [OK]   cancun.jaquemate...        HTTPS
  [OK]   iki.jaquemate...           HTTPS
  [OK]   engine.jaquemate...        HTTPS
  [OK]   monitor.jaquemate...       HTTPS

Disco:
  [OK]   /var/lib/docker en X%

Resultado: TODO OK
```

Si todo da OK, **fin del despliegue de hoy**.

---

## Lo que NO se hace hoy (deliberado)

- **El fork Jaque Mate**: hoy es Twenty upstream con branding default. El fork con paleta nogal/marfil/granate empieza en el Mes 1 del roadmap. Hoy validamos que la infra multi-tenant funciona con codigo vanilla.
- **Apps custom de Jaque Mate**: ninguna. Eso son los meses 2-5 del roadmap.
- **n8n Projects/Workspaces nativos**: requieren licencia Pro/Enterprise. Hoy usamos convencion de tags. Cost-benefit: $0 vs $144/mes (6 users × $24).
- **S3 storage para Twenty**: hoy local storage. Cuando un tenant supere 5 GB de uploads, migrar a Backblaze B2 ($6/TB/mes).
- **SMTP / email outbound**: comentado en el compose. Activar cuando tengamos credenciales SES o SMTP relay configuradas.
- **SSO / Keycloak**: no hace falta para 6 tenants y 1-3 usuarios cada uno.
- **CDN delante de Twenty**: no aporta a este volumen.

Cualquiera de estos se incorpora en su momento sin replantear la base.

---

## Si algo sale mal

| Sintoma | Causa probable | Fix |
|---|---|---|
| Caddy no obtiene SSL | Cloudflare proxy ON antes de issue | Apagar proxy (icono gris), esperar 5 min |
| Twenty da "New workspace setup is disabled" | `IS_MULTIWORKSPACE_ENABLED` no aplico | Verificar en `docker compose exec server env` |
| Subdominio devuelve 502 | DNS no propago aun | `dig <sub>.jaquemate.jaqueting.com` debe dar la IP del VPS |
| n8n no levanta | DB `n8n` no se creo | `docker exec jaquemate-db psql -U postgres -c "CREATE DATABASE n8n;"` |
| OOM kills random | RAM justa | `free -h`, considerar swap o upgrade a CPX31 |

---

## Checklist final (imprimir y tachar)

- [ ] VPS Hetzner CPX21 Ashburn provisionado
- [ ] 9 A records DNS creados y verificados con dig
- [ ] Docker + docker compose instalados
- [ ] Kit clonado en `/home/eddy/jaquemate`
- [ ] `bash scripts/setup.sh` corrio sin errores
- [ ] Credenciales de `.env` guardadas en gestor de password
- [ ] Twenty server healthy
- [ ] 6 workspaces creados en orden: pespro, traulog, jaqueting, fastnet, cancun, iki
- [ ] Cada workspace accesible via su subdominio
- [ ] n8n accesible y tags creados
- [ ] Uptime Kuma configurado con los 9 monitors
- [ ] Cron de backup configurado
- [ ] `bash scripts/health-check.sh` devuelve "TODO OK"
- [ ] **`jaquemate.app` registrado en Cloudflare**
- [ ] **`getjaquemate.com` registrado y redirigiendo 301 → `jaquemate.app`**

Cuando los 12 esten tachados: el stack esta arriba y operativo.
