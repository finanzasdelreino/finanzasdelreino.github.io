# Prompt del proyecto — Finanzas del Reino

App de finanzas personales tipo PWA (Progressive Web App), construida sobre la misma base técnica del proyecto "Mi Tienda" (CMB Florestajovenes): Supabase multiusuario con roles, Git, Netlify.

## Qué hace la app

- Registro de ingresos y gastos: monto, categoría, medio de pago (efectivo, transferencia, tarjeta de crédito), fecha, descripción.
- Categorías y medios de pago editables (agregar/eliminar).
- Foto o PDF de respaldo por movimiento (factura, desprendible de pago, extracto bancario), subido a Supabase Storage.
- Documentos sueltos (sin ligar a un movimiento) para archivar desprendibles y extractos.
- **Distribución de mayordomía**: al registrar un ingreso, calcula automáticamente cuánto corresponde a Diezmo (10%), Ahorro/fondo de oportunidades (20%), Gastos necesarios (50%) y Estilo de vida (20%) — porcentajes **privados y editables por cada persona** para sus propios ingresos.
- Reportes por periodo con gráfica de ingresos vs. gastos por mes, descarga como PDF (impresión del navegador) y resumen compartible por WhatsApp.
- **Datos privados por persona:** cada quien crea su propia cuenta y solo ve sus propios movimientos, documentos y porcentajes — nadie más los ve, ni siquiera el administrador. Categorías y medios de pago sí son una lista compartida entre todos (para no repetir el trabajo de crearlas), y solo un **Administrador** puede agregarlas o eliminarlas de esa lista compartida.

## Estado técnico actual

- **Frontend:** un solo archivo `index.html` (vanilla JS, sin frameworks), con `manifest.json`, `service-worker.js` y 3 íconos (192px, 512px, 512px maskable) para que sea instalable como PWA.
- **Backend:** Supabase (Auth por correo/contraseña + Postgres con Row Level Security por rol).
- **Storage:** bucket `recibos` para las fotos de facturas, desprendibles y extractos.
- **Diseño:** estética de libro contable — verde tinta (`#1F4436`), dorado sello (`#B8862E`), papel (`#F1ECDD`); tipografías Fraunces (títulos), IBM Plex Sans (texto) e IBM Plex Mono (números).
- **Service worker:** cachea solo el cascarón de la app (para que abra instalada sin conexión); los datos financieros requieren conexión porque viven en Supabase, no en el dispositivo.

## Ya hecho

- [x] Esquema SQL completo (`supabase-schema.sql`): tablas `profiles`, `categories`, `payment_methods`, `distribution_settings`, `movements`, `documents`, con Row Level Security y políticas por rol.
- [x] Frontend (`index.html`) reescrito con login de Supabase Auth, roles, y todas las funciones conectadas a las tablas.
- [x] `manifest.json`, `service-worker.js` e íconos generados.

## Pendiente

- [ ] Crear el proyecto en Supabase (si aún no existe) y ejecutar `supabase-schema.sql` completo en el SQL Editor.
- [ ] Crear el bucket de Storage llamado `recibos`, marcado como **público**.
- [ ] Obtener el `Project URL` y el `anon public key` desde Project Settings → API, y pegarlos en las primeras líneas de `index.html` (`SUPABASE_URL` y `SUPABASE_ANON_KEY`).
- [ ] Crear tu cuenta desde la pantalla de login de la app (te crea automáticamente un perfil con rol `colaborador` y tus propios datos privados).
- [ ] En Supabase → Table Editor → `profiles`, cambiar tu fila: `role = 'admin'`.
- [ ] Compartir el link de Netlify con quien quieras: cada persona crea su propia cuenta y ve únicamente sus propios movimientos y documentos.
- [ ] Subir el proyecto a un repositorio Git y conectarlo a Netlify (igual que `tiendacmbflorestajovenes.netlify.app`), verificando que la protección de acceso esté desactivada en Site configuration → Visitor access.
- [ ] Una vez publicada la URL de Netlify, empaquetarla como `.apk` con PWABuilder (pwabuilder.com) si se quiere instalar como app en Android.

## Cómo seguir

Si retomas esto en una nueva conversación con Claude (u otro asistente), comparte este documento junto con el `Project URL` y `anon public key` de Supabase reales, y pide que verifique la conexión y ajuste lo que haga falta.
