# Finanzas del Reino

App de finanzas personales tipo PWA (vanilla JS, sin frameworks), con backend en Supabase (Auth + Postgres + Storage). Cada usuario ve únicamente sus propios datos (movimientos, documentos, porcentajes de mayordomía); categorías y medios de pago son una lista compartida que solo un administrador puede editar.

Para el detalle completo del producto (qué hace, diseño, decisiones) lee **`PROYECTO-FINANZAS-DEL-REINO.md`** en esta misma carpeta — ese archivo es la fuente de verdad del proyecto.

## Estructura

- `index.html` — toda la app (HTML + CSS + JS en un solo archivo). Incluye el login de Supabase Auth, las vistas (Resumen, Tarjetas y ahorros, Movimientos, Nuevo movimiento, Documentos, Reportes, Ajustes) y toda la lógica de datos.
- `supabase-schema.sql` — esquema completo original para pegar en el SQL Editor de Supabase (tablas, RLS, datos iniciales).
- `supabase-schema-v2-cuentas.sql` — migración incremental: tabla `accounts` (tarjetas de crédito y cuentas de ahorro, privada por usuario) con saldo, día de corte, día de pago y cuotas. Ejecutar solo si el proyecto de Supabase ya tenía el esquema original y aún no tiene esta tabla.
- `manifest.json`, `service-worker.js`, `icon-*.png` — lo necesario para que sea instalable como PWA.

## Estado / pendientes

Ver la sección "Pendiente" de `PROYECTO-FINANZAS-DEL-REINO.md`. En resumen, falta:
1. Crear el proyecto en Supabase y ejecutar `supabase-schema.sql`.
2. Crear el bucket de Storage `recibos` (público).
3. Pegar `Project URL` y `anon public key` reales en `index.html` (busca `SUPABASE_URL` y `SUPABASE_ANON_KEY` cerca del inicio del `<script>`).
4. Subir a Git y desplegar en Netlify.

## Cómo previsualizar en local

No hay build ni dependencias — es HTML estático. Para probarlo:

```bash
python3 -m http.server 8000
# abrir http://localhost:8000
```

(El login no funcionará hasta que `SUPABASE_URL`/`SUPABASE_ANON_KEY` tengan valores reales.)

## Convenciones del proyecto

- Todo el texto de interfaz está en español.
- Paleta: verde tinta `#1F4436`, dorado `#B8862E`, papel `#F1ECDD`, rojo `#A63D2F` (variables CSS en `:root`).
- Tipografías: Fraunces (títulos), IBM Plex Sans (texto), IBM Plex Mono (números).
- Los montos son en pesos colombianos (COP), formateados con `Intl.NumberFormat('es-CO', ...)`.
- Mantén el estilo "libro contable" (bordes, sellos, tabla tipo ledger) al agregar vistas nuevas.
- Los nombres de tablas/columnas en Supabase están en inglés (`movements`, `created_by`, etc.); el texto visible al usuario siempre en español.
