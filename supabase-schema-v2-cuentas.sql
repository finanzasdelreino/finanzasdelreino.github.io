-- ============================================================
-- Finanzas del Reino — v2: Tarjetas de crédito y cuentas de ahorro
-- Ejecutar en: Supabase → SQL Editor → New query
-- Privado por usuario, igual que movements/documents.
-- ============================================================

create table public.accounts (
  id uuid primary key default gen_random_uuid(),
  tipo text not null check (tipo in ('tarjeta_credito','ahorros')),
  nombre text not null,
  saldo numeric not null default 0,
  dia_corte int check (dia_corte between 1 and 31),
  dia_pago int check (dia_pago between 1 and 31),
  cuotas int,
  created_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.accounts enable row level security;

create policy "ver mis cuentas" on public.accounts for select using (created_by = auth.uid());
create policy "agregar mis cuentas" on public.accounts for insert with check (created_by = auth.uid());
create policy "edito mis cuentas" on public.accounts for update using (created_by = auth.uid());
create policy "borro mis cuentas" on public.accounts for delete using (created_by = auth.uid());
