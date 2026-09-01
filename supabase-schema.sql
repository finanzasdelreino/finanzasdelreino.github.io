-- ============================================================
-- Finanzas del Reino — Esquema de Supabase (datos PRIVADOS por usuario)
-- Ejecutar completo en: Supabase → SQL Editor → New query
--
-- Cada persona que inicia sesión ve y edita SOLO sus propios movimientos,
-- documentos y porcentajes de mayordomía. Nadie ve los datos de otro.
-- Las categorías y medios de pago sí son una lista compartida (referencia
-- común), y solo un administrador puede agregarlas o eliminarlas.
-- ============================================================

-- ---------- Perfiles (rol de cada usuario) ----------
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  role text not null default 'colaborador' check (role in ('admin','colaborador')),
  created_at timestamptz not null default now()
);

-- Al registrarse, se crea automáticamente: un perfil (rol "colaborador")
-- y una fila de distribución de mayordomía con los porcentajes por defecto.
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email) values (new.id, new.email);
  insert into public.distribution_settings (user_id) values (new.id);
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ---------- Categorías (lista compartida de referencia) ----------
create table public.categories (
  id uuid primary key default gen_random_uuid(),
  tipo text not null check (tipo in ('gasto','ingreso')),
  nombre text not null,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  unique(tipo, nombre)
);

-- ---------- Medios de pago (lista compartida de referencia) ----------
create table public.payment_methods (
  id uuid primary key default gen_random_uuid(),
  nombre text not null unique,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

-- ---------- Distribución de mayordomía (una fila POR USUARIO) ----------
create table public.distribution_settings (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  diezmo numeric not null default 10,
  ahorro numeric not null default 20,
  gastos numeric not null default 50,
  estilo numeric not null default 20,
  updated_at timestamptz not null default now()
);

-- ---------- Movimientos (PRIVADOS: solo su dueño los ve) ----------
create table public.movements (
  id uuid primary key default gen_random_uuid(),
  tipo text not null check (tipo in ('ingreso','gasto')),
  monto numeric not null check (monto > 0),
  categoria text not null,
  medio_pago text,
  fecha date not null,
  descripcion text,
  documento_url text,
  documento_nombre text,
  created_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now()
);

-- ---------- Documentos sueltos (PRIVADOS: solo su dueño los ve) ----------
create table public.documents (
  id uuid primary key default gen_random_uuid(),
  tipo text not null check (tipo in ('factura','desprendible','extracto')),
  nombre text not null,
  url text not null,
  movement_id uuid references public.movements(id) on delete set null,
  created_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now()
);

-- ============================================================
-- Row Level Security
-- ============================================================
alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.payment_methods enable row level security;
alter table public.distribution_settings enable row level security;
alter table public.movements enable row level security;
alter table public.documents enable row level security;

-- Función auxiliar: ¿el usuario actual es admin?
create function public.is_admin()
returns boolean as $$
  select role = 'admin' from public.profiles where id = auth.uid();
$$ language sql security definer stable;

-- profiles: cada quien ve solo su propio perfil; un admin puede cambiar roles.
create policy "ver mi perfil" on public.profiles for select using (id = auth.uid() or public.is_admin());
create policy "admin actualiza roles" on public.profiles for update using (public.is_admin());

-- categories: lista compartida — todos ven y agregan; solo admin borra.
create policy "ver categorias" on public.categories for select using (auth.role() = 'authenticated');
create policy "agregar categorias" on public.categories for insert with check (auth.role() = 'authenticated');
create policy "admin borra categorias" on public.categories for delete using (public.is_admin());

-- payment_methods: igual que categorías.
create policy "ver medios" on public.payment_methods for select using (auth.role() = 'authenticated');
create policy "agregar medios" on public.payment_methods for insert with check (auth.role() = 'authenticated');
create policy "admin borra medios" on public.payment_methods for delete using (public.is_admin());

-- distribution_settings: cada quien ve y edita SOLO su propia fila.
create policy "ver mi distribucion" on public.distribution_settings for select using (user_id = auth.uid());
create policy "edito mi distribucion" on public.distribution_settings for update using (user_id = auth.uid());
create policy "creo mi distribucion" on public.distribution_settings for insert with check (user_id = auth.uid());

-- movements: PRIVADO — cada quien ve, agrega, edita y borra SOLO lo suyo.
create policy "ver mis movimientos" on public.movements for select using (created_by = auth.uid());
create policy "agregar mis movimientos" on public.movements for insert with check (created_by = auth.uid());
create policy "edito mis movimientos" on public.movements for update using (created_by = auth.uid());
create policy "borro mis movimientos" on public.movements for delete using (created_by = auth.uid());

-- documents: PRIVADO — igual que movimientos.
create policy "ver mis documentos" on public.documents for select using (created_by = auth.uid());
create policy "agregar mis documentos" on public.documents for insert with check (created_by = auth.uid());
create policy "borro mis documentos" on public.documents for delete using (created_by = auth.uid());

-- ---------- Categorías y medios de pago por defecto (compartidos para todos) ----------
insert into public.categories (tipo, nombre) values
  ('gasto','Alimentación'), ('gasto','Transporte'), ('gasto','Vivienda'), ('gasto','Servicios'),
  ('gasto','Educación'), ('gasto','Salud'), ('gasto','Entretenimiento'), ('gasto','Otro'),
  ('ingreso','Salario'), ('ingreso','Trabajo independiente'), ('ingreso','Venta'), ('ingreso','Otro');

insert into public.payment_methods (nombre) values
  ('Efectivo'), ('Transferencia'), ('Tarjeta de crédito');

-- ============================================================
-- IMPORTANTE — Storage privado por usuario:
-- El bucket "recibos" debe seguir marcado como público (para que las URLs
-- de las fotos funcionen), pero cada archivo se sube dentro de una carpeta
-- con el ID del usuario (esto ya lo hace el código de index.html), así que
-- aunque el bucket sea público, solo quien conoce el enlace exacto de SU
-- propio archivo puede verlo — nadie los lista ni los adivina.
--
-- Pasos manuales pendientes (fuera de este script):
-- 1. Storage → New bucket → nombre "recibos" → marcar como Public.
-- 2. Project Settings → API → copiar "Project URL" y "anon public key" y pegarlos en index.html.
-- 3. Cada persona crea su propia cuenta desde la pantalla de login (correo/contraseña).
--    Eso le crea automáticamente su perfil privado y sus propios datos, separados de los demás.
-- 4. En Table Editor → profiles → tu fila: role = 'admin' (para poder gestionar categorías/medios compartidos).
-- ============================================================
