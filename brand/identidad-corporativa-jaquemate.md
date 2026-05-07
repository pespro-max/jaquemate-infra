---
proyecto: Jaque Mate — Identidad Corporativa
parte_de: Portafolio Jaqueting (FastNet Engineering Atelier)
modulo: "#7 — CRM"
licencia_codigo: AGPL-3.0 (heredada de Twenty CRM)
fase_actual: Embebido como tenant en infra Jaqueting (mes 0-6)
fase_spinoff: Mes 6-9 — decisión de exposición pública
estado_naming: LOCKED
fecha: 2026-05-06
autor: FastNet Engineering Atelier
---

# Jaque Mate

## El cierre de la jugada.

---

## 1. Posicionamiento dentro del portafolio Jaqueting

Jaque Mate **no es un producto independiente** todavía. Es el **módulo #7** del portafolio comercial Jaqueting, el sistema de marketing y ventas con naming basado en ajedrez que vendemos a PyMEs LATAM.

```
PORTAFOLIO JAQUETING (la marca matriz, la reina)
│
├─ #1  Gambito de Dama  — Análisis de mercado (n8n + APIs)
├─ #2  Jaque Doble       — Contenido (n8n + APIs)
├─ #3  [Torre/Fianchetto]— Ads pagos (decisión pendiente — no inventar)
├─ #4  Celada            — Captura/forms (n8n + APIs)
├─ #5  Jaque Pastor      — Email marketing (n8n + APIs)
├─ #6  Caballo           — Llamadas/voz (n8n + APIs)
└─ #7  JAQUE MATE        — CRM (Twenty fork, AGPL) ← este documento
```

**Diferencia arquitectónica clave:** los módulos #1–#6 son orquestaciones n8n + APIs externas + Postgres. Jaque Mate es un **fork de código** de Twenty CRM bajo AGPL-3.0, con su propio repo (`github.com/pespro-max/jaquemate`, privado en Fase 1) y su propio ciclo de release. Es el único módulo del portafolio que tiene base de código propia.

**Por qué Jaque Mate y no Coronación:** Jaque Mate cierra la trinidad narrativa que la PyME entiende sin curva de educación: Gambito → Doble → Mate = abrís, atacás, ganás. "Coronación" era más cerrada simbólicamente (produce la reina = produce Jaqueting), pero exige educación. Jaque Mate gana en claridad comercial.

**Sacrificio explícito:** repetimos la raíz "Jaque" tres veces en el portafolio (Jaqueting + Jaque Doble + Jaque Mate). Riesgo de confusión cuando un cliente diga "necesito Jaque". Mitigación: en toda comunicación interna y externa el módulo CRM se llama **Jaque Mate** completo, nunca "Jaque" solo.

---

## 2. Concepto de marca

**Tagline ES:** El cierre de la jugada.
**Tagline EN:** Where the deal closes.

**Atributos:**
- Definitivo (es el cierre, no el medio juego)
- Estratégico (no transaccional — un CRM no es una hoja de Excel)
- Heredado (vive bajo el portafolio Jaqueting, sastrería bajo FastNet)
- Open por origen, premium por terminación (fork AGPL + branding propio)

**Lo que Jaque Mate NO es:**
- No es Salesforce barato. No competimos en features con Salesforce.
- No es HubSpot en español. No competimos en marketing con HubSpot.
- No es "el CRM gratis". El precio en Fase 2 será explícito y justificado.

---

## 3. Sistema de naming (LOCKED)

| Elemento | Forma correcta | Forma incorrecta |
|---|---|---|
| Marca completa | Jaque Mate | JaqueMate · jaquemate · Jaque-Mate |
| En código (repo, paquete) | `jaquemate` | `jaque-mate` · `jaquemate-crm` |
| Subdominio operacional (mes 1-9) | `*.jaquemate.jaqueting.com` | `nexus.jaqueting.com` · `tablero.jaqueting.com` |
| Dominio público de marca | `jaquemate.app` | `jaquemate.io` · `jaquemate.tech` |
| Dominio defensivo (typo redirect) | `getjaquemate.com` → 301 → `jaquemate.app` | — |
| Wordmark visual | Jaque Mate | JaqueMate · JAQUEMATE |
| En texto formal | Jaque Mate by Jaqueting | Jaqueting Jaque Mate |
| Notación corta (UI) | `JM` o el símbolo `#` | `JQM` · `JM-CRM` |

**Regla operativa:** en código, paquetes npm, repos, variables de entorno y URLs usamos `jaquemate` (una palabra, minúsculas). En todo lo visible al usuario usamos **Jaque Mate** (dos palabras, capitalizadas).

**Dominios bloqueados (verificados via DNS NS lookup el 2026-05-06):**
- `jaquemate.com` está parked en Namefind/GoDaddy aftermarket — adquisición premium estimada $3K-$30K. **Descartado hoy** por cost-benefit pre-checkpoint mes 6. Reevaluar mes 9 con revenue real.
- `jaquemate.app` disponible a precio retail (~$14/año en Cloudflare Registrar). Convención SaaS top-tier (Linear.app, Cron.app). HTTPS forzado por DNS — coherente con producto CRM.
- `getjaquemate.com` disponible (~$11/año). Cubre el typo de quien teclea `.com` por instinto. Redirect 301 → `jaquemate.app`.
- **Costo total dominios: ~$27/año.**

**TLDs descartados con razón:**

| TLD | Estado | Por qué no |
|---|---|---|
| `.com` | Parked premium | $3K-$30K de adquisición. Pre-checkpoint = riesgo de plata quemada. |
| `.co` `.net` `.org` `.es` `.xyz` | Tomados | Activos o parked por terceros. |
| `.io` | Disponible | Riesgo geopolítico del TLD (Chagos Islands, futuro post-2025 incierto). |
| `.ai` | Disponible | $80-200/año. Mismatch: producto es CRM con AI, no producto AI. |
| `.dev` | Disponible | Connota herramienta para developers, no CRM para CTOs. |
| `.tech` `.software` `.cloud` | Disponibles | Más largos, peor recordación que `.app`. |

---

## 4. Paleta de color

La paleta no hereda Hilo de Oro de FastNet ni el dorado/crema de Jaqueting. Es propia y evoca las casillas del ajedrez, no la sastrería ni la agencia.

| Token | Nombre interno | HEX | RGB | Uso | Proporción |
|---|---|---|---|---|---|
| `--jm-walnut` | Nogal Mate | `#3B2A1F` | 59 / 42 / 31 | Primario · UI shell · headers | 60 % |
| `--jm-ivory` | Marfil Cuadro | `#EDE3D2` | 237 / 227 / 210 | Secundario · backgrounds · cards | 30 % |
| `--jm-garnet` | Granate Mate | `#7C1D2E` | 124 / 29 / 46 | Acento · acción de cierre · "Mate" | 8 % |
| `--jm-ink` | Negro Tinta | `#0A0A0F` | 10 / 10 / 15 | Texto principal · iconos pequeños | 2 % |

**Cómo se aplican:**
- **Nogal Mate (60%)** domina la barra superior, el sidebar de Twenty y todos los headers. Es el "lado oscuro" de la pieza.
- **Marfil Cuadro (30%)** es el fondo de paneles, modals y cards. El "lado claro" de la pieza.
- **Granate Mate (8%)** se reserva para **una sola acción**: cerrar deal como ganado ("Mate"). Cualquier botón que diga "Mate" o "Mark won" es granate. Nada más es granate por defecto.
- **Negro Tinta (2%)** se hereda del sistema FastNet para mantener cohesión de portafolio en la tipografía y los iconos finos.

**Decisiones rechazadas y por qué:**
- **Verde fieltro de torneo** (#2D5043): rechazado por exceso de cliché ajedrecístico ("casino chess club") y porque colisiona con la paleta corporativa de PesPro.
- **Dorado/oro saturado**: rechazado por colisión directa con FastNet (#C9A876) y Jaqueting (#8B6914). El portafolio ya tiene dos doraos; un tercero no diferencia.
- **Cobalto SaaS estándar** (#3B82F6): rechazado por completo. Toda la categoría CRM usa cobalto. Diferenciarse del monocultivo cobalto es ventaja de marca.
- **Blanco puro + negro puro**: rechazado por estéril, no transmite la calidez del portafolio Jaqueting.

**Sacrificio de la paleta elegida:** Granate Mate lee como "vino tinto" o "estudio jurídico" para parte de la audiencia tech. Para PyME LATAM lee como "sello premium" — gana ahí. Si en mes 9 la decisión de spin-off requiere apuntar a tech buyers globales, evaluamos rotar Granate por algo más neutro.

---

## 5. Tipografía

Hereda el stack del portafolio Jaqueting/FastNet pero invierte la jerarquía visual:

| Familia | Uso en FastNet | Uso en Jaque Mate |
|---|---|---|
| **Fraunces** (display) | Headlines · marca | Wordmark del logo · titulares de marketing del CRM |
| **Inter** (UI/body) | Texto largo · UI | **Default UI del producto** (jerarquía dominante) |
| **JetBrains Mono** | Code · eyebrows | Notación de jugada · IDs · valores numéricos en UI |

**Por qué la inversión:** un CRM se mide en pantallas/día por el usuario. Inter tiene mejor legibilidad a 13–14px en tablas densas. Fraunces se queda para momentos de marca (login, marketing, brand corners), no para listar 500 deals.

**Stack CSS:**
```css
--jm-font-display: 'Fraunces', Georgia, serif;
--jm-font-ui: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
--jm-font-mono: 'JetBrains Mono', 'Fira Code', monospace;
```

**Pesos lockeados:**
- Wordmark: Fraunces 600
- Headers de UI: Inter 600
- Body de UI: Inter 400
- Notación de mate: JetBrains Mono 500

---

## 6. Sistema de logo

### 6.1 La marca primaria

El logo combina un **mark cuadrado 2×2** (cuatro casillas de ajedrez, dos nogal y dos marfil) con un **símbolo `#`** sobre la casilla inferior derecha. El `#` es la notación oficial de mate en ajedrez ("Qh5#"). Esto codifica autoridad técnica para quien sabe ajedrez y simplemente lee como "símbolo distintivo" para quien no.

El wordmark "Jaque Mate" en Fraunces 600 acompaña el mark con espaciado controlado.

**El SVG completo está en:** `brand/jaquemate-logo.svg` (lockup horizontal)
**Mark solo:** `brand/jaquemate-mark.svg` (cuadrado, para favicon, app icon, social avatar)

### 6.2 Lockups oficiales

| Variante | Cuándo usar |
|---|---|
| Mark + wordmark horizontal | Headers, login, materiales de marketing |
| Mark solo (cuadrado) | Favicon, app icon, social avatar, signature |
| Wordmark solo | Footer minimalista, watermarks |
| Mark inverso (sobre nogal) | Backgrounds oscuros, dark mode |

### 6.3 Reglas de aplicación

**Espacio libre mínimo:** equivalente a la altura de una casilla del mark en cualquier dirección.

**Tamaño mínimo:**
- Mark: 24px (digital) · 12mm (impreso)
- Lockup horizontal: 120px de ancho (digital) · 40mm (impreso)

**Prohibiciones:**
- No estirar, sesgar ni rotar
- No cambiar la posición del `#` a otra casilla
- No reemplazar la paleta nogal/marfil (incluso para ocasiones especiales)
- No agregar drop shadow ni gradientes
- No usar el mark sin el `#` (es la firma del módulo)

---

## 7. Voz y tono

**Audiencia primaria (Fase 1):** dueños/operadores de PyMEs LATAM que ya consumen otros módulos del portafolio Jaqueting. Asumimos contexto, no explicamos qué es un CRM.

**Audiencia secundaria (Fase 2 spin-off):** CTOs y founders técnicos que evalúan alternativas a Salesforce/HubSpot y quieren AGPL self-host.

**Reglas de voz:**
- Hablamos en español rioplatense neutro o español LATAM neutro según canal. Nunca "tú" + "vos" mezclados.
- Usamos analogías de ajedrez con criterio, no compulsivamente. "Mate" para cerrar deal = sí. "Enroque" para cualquier cosa = no.
- Nunca usamos "movida estratégica" cuando alcanza con "movida". Heredamos del manifiesto Jaqueting pero sin su carga.
- Evitamos jerga SaaS gratuita: nada de "supercharge", "unlock", "leverage", "synergize".

**Microcopy LOCKED para acciones críticas:**

| Acción del usuario | Microcopy ES | Microcopy EN |
|---|---|---|
| Marcar deal como ganado | **Mate** | **Checkmate** |
| Marcar deal como perdido | Tablas | Draw |
| Crear nuevo deal | Abrir partida | New game |
| Etapa "lead nuevo" | Apertura | Opening |
| Etapa "negociación" | Medio juego | Middlegame |
| Etapa "propuesta" | Final | Endgame |
| Convertir lead a oportunidad | Gambito | Gambit |

**Nota:** estos microcopy son **opcionales como tema seleccionable**. Por default Jaque Mate usa terminología CRM estándar (Won, Lost, New, Negotiation, Proposal). El "tema ajedrez" es un toggle en preferencias del workspace. Esto evita que clientes que no usan analogía de ajedrez se sientan forzados.

---

## 8. Tokens UI

```css
/* Spacing — escala 4px */
--jm-space-1: 4px;
--jm-space-2: 8px;
--jm-space-3: 12px;
--jm-space-4: 16px;
--jm-space-6: 24px;
--jm-space-8: 32px;

/* Border radius — más pronunciado que Twenty default para suavizar madera */
--jm-radius-sm: 6px;
--jm-radius-md: 10px;
--jm-radius-lg: 14px;

/* Sombras — cálidas, no grises neutros */
--jm-shadow-sm: 0 1px 2px rgba(59, 42, 31, 0.08);
--jm-shadow-md: 0 4px 12px rgba(59, 42, 31, 0.12);
--jm-shadow-lg: 0 12px 32px rgba(59, 42, 31, 0.16);

/* Motion */
--jm-ease: cubic-bezier(0.4, 0, 0.2, 1);
--jm-duration-fast: 150ms;
--jm-duration-base: 250ms;

/* Estados */
--jm-success: var(--jm-garnet);   /* sí, granate = ganaste, es la idea */
--jm-warning: #C9A876;            /* hilo de oro de FastNet, único caso de cruce */
--jm-error: #8B1A2A;              /* granate más oscuro */
--jm-info: var(--jm-walnut);
```

**Decisión deliberada:** el color de éxito ES el granate. Cuando un usuario gana un deal, ve granate. No verde. No "thumbs up emoji". Granate. Esto refuerza la marca cada vez que sucede el momento que más importa al usuario.

---

## 9. Aplicaciones de referencia

### 9.1 Login screen
- Background: marfil cuadro
- Card central: blanco puro con borde nogal 1px y radius 14
- Logo lockup horizontal centrado arriba
- Inputs con borde nogal 1px, focus en granate
- Botón primario "Entrar" en nogal con texto marfil

### 9.2 Header del workspace (Twenty customizado)
- Background: nogal mate
- Texto: marfil cuadro
- Switcher de workspace muestra el nombre del tenant + el mark de su producto (PesPro mark, Traulog mark, etc.)
- Notificaciones: indicador granate solo cuando hay un "Mate" pendiente de revisión

### 9.3 Email signature
```
[mark.svg 32×32]  Eddy López
                  Engineering Atelier · FastNet
                  Via Jaque Mate by Jaqueting
                  jaquemate.jaqueting.com
```

---

## 10. Herencia desde el portafolio

Jaque Mate hereda y adapta:

| Elemento | Heredado de | Adaptación en Jaque Mate |
|---|---|---|
| Tipografía display | FastNet | Sí (Fraunces) |
| Tipografía UI | FastNet | Sí (Inter) |
| Negro Tinta | FastNet | Sí (#0A0A0F) |
| Hilo de Oro | FastNet | NO — solo aparece en estado "warning" |
| Crema Pergamino | FastNet | NO — reemplazado por Marfil Cuadro |
| Stitching pattern | FastNet | Solo en marketing materials, no en producto |
| Naming "ajedrez" | Jaqueting | Sí (Mate, Gambito, etc.) |
| Voz cercana LATAM | Jaqueting | Sí pero más sobrio |

Lo que **no se hereda** y es propio de Jaque Mate:
- Paleta nogal/marfil/granate
- Mark de cuadricula 2×2 con `#`
- Microcopy ajedrecístico (toggleable)
- Inversión jerárquica de tipografía (Inter domina, no Fraunces)

---

## 11. Implementación técnica de la identidad

**Tailwind config (extracto):**
```js
// tailwind.config.js para el fork de Jaque Mate
module.exports = {
  theme: {
    extend: {
      colors: {
        walnut: '#3B2A1F',
        ivory:  '#EDE3D2',
        garnet: '#7C1D2E',
        ink:    '#0A0A0F',
      },
      fontFamily: {
        display: ['Fraunces', 'Georgia', 'serif'],
        ui:      ['Inter', 'system-ui', 'sans-serif'],
        mono:    ['"JetBrains Mono"', 'monospace'],
      },
      borderRadius: {
        DEFAULT: '10px',
      },
    },
  },
};
```

**Variables CSS globales:** archivo `brand/jaquemate-tokens.css` (incluido en este kit).

**Override de Twenty:** Twenty CRM expone variables CSS en su tema. El fork sobreescribe `--theme-color-primary`, `--theme-color-background`, etc. con los tokens `--jm-*`. Documentado en el repo del fork bajo `docs/branding-override.md` (a crear en mes 1).

---

## 12. Activos generados en este kit

| Archivo | Qué es | Dónde se usa |
|---|---|---|
| `jaquemate-logo.svg` | Lockup horizontal completo | Marketing, login, headers |
| `jaquemate-mark.svg` | Mark cuadrado solo | Favicon, app icon, signature |
| `jaquemate-mark-inverso.svg` | Mark sobre fondo oscuro | Dark mode, headers nogal |
| `jaquemate-tokens.css` | Variables CSS de la paleta | Importable en el fork |

---

## 13. Qué NO se decide en este documento

Hay cosas deliberadamente fuera de scope porque son del manual de marca futuro (Fase 2 spin-off, mes 6+):

- Sistema completo de iconografía custom (hoy usamos los iconos de Twenty + Lucide)
- Ilustraciones de marca (estilo "blueprint" de FastNet no aplica)
- Brand patterns para print
- Ad creatives para campañas de adquisición pública
- Naming oficial de la entidad legal del spin-off (¿"Jaque Mate Inc."? ¿"Mate Software LLC"?)
- Política de licencia comercial paralela a AGPL (Enterprise tier)

Estos se abren cuando la Fase 2 se confirme en el mes 6.

---

## 14. Resumen ejecutivo de decisiones LOCKED

1. **Naming:** Jaque Mate (dos palabras, capitalizadas en UI; `jaquemate` en código).
2. **Paleta:** Nogal #3B2A1F + Marfil #EDE3D2 + Granate #7C1D2E + Tinta #0A0A0F. Proporción 60/30/8/2.
3. **Tipografía:** Inter domina UI, Fraunces solo wordmark y marketing, JetBrains Mono para notación.
4. **Logo:** Mark cuadrado 2×2 con `#` en casilla inferior derecha + wordmark Fraunces 600.
5. **Subdominio raíz:** `jaquemate.jaqueting.com` (NO fastnet.solutions, NO nexus).
6. **Repo:** `github.com/pespro-max/jaquemate` (privado en Fase 1).
7. **Licencia:** AGPL-3.0 heredada de Twenty.
8. **Posición en portafolio:** módulo #7 de Jaqueting. NO producto independiente hasta mes 6+.
9. **Microcopy ajedrecístico:** opcional como tema toggleable, no default.
10. **Color de éxito:** granate, no verde. Deliberado.
