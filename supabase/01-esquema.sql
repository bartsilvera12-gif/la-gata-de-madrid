-- ============================================================
-- La Gata de Madrid — esquema para Supabase
-- Dónde: Supabase → SQL Editor → New query → pegar todo → Run
-- Se puede volver a ejecutar sin romper nada.
-- ============================================================

-- ---------- 1) Productos ----------
create table if not exists public.productos (
  id          text primary key,              -- slug, ej: 'redmi-buds-8-pro'
  nombre      text not null,
  categoria   text not null,
  precio      bigint not null default 0,     -- en guaraníes, sin decimales
  badge       text,                          -- 'Nuevo', 'Destacado' o vacío
  desc_corta  text not null default '',
  desc_larga  text not null default '',
  fotos       text[] not null default '{}',  -- URLs; la primera es la principal
  ficha       jsonb not null default '[]',   -- [["Batería","36 h"], ...]
  stock       integer not null default 0,
  destacado   boolean not null default false,-- aparece en "Lo que más se busca"
  oculto      boolean not null default false,-- fuera de la tienda, sin borrarlo
  orden       integer not null default 0,    -- para ordenar arrastrando
  creado      timestamptz not null default now(),
  actualizado timestamptz not null default now()
);

create index if not exists productos_orden_idx on public.productos (orden, creado);

-- "actualizado" se pone al día solo
create or replace function public.tocar_actualizado()
returns trigger language plpgsql as $$
begin
  new.actualizado = now();
  return new;
end $$;

drop trigger if exists productos_actualizado on public.productos;
create trigger productos_actualizado
  before update on public.productos
  for each row execute function public.tocar_actualizado();


-- ---------- 2) Quién puede hacer qué ----------
-- Sin esto, la clave pública del sitio permitiría que cualquiera edite.
alter table public.productos enable row level security;

-- Visitantes: solo leen los productos visibles.
drop policy if exists "lectura publica" on public.productos;
create policy "lectura publica" on public.productos
  for select to anon
  using (oculto = false);

-- Administradora (sesión iniciada): ve y edita todo, incluidos los ocultos.
drop policy if exists "admin lee todo" on public.productos;
create policy "admin lee todo" on public.productos
  for select to authenticated using (true);

drop policy if exists "admin inserta" on public.productos;
create policy "admin inserta" on public.productos
  for insert to authenticated with check (true);

drop policy if exists "admin edita" on public.productos;
create policy "admin edita" on public.productos
  for update to authenticated using (true) with check (true);

drop policy if exists "admin borra" on public.productos;
create policy "admin borra" on public.productos
  for delete to authenticated using (true);


-- ---------- 3) Depósito de fotos ----------
insert into storage.buckets (id, name, public)
values ('fotos', 'fotos', true)
on conflict (id) do update set public = true;

drop policy if exists "fotos lectura publica" on storage.objects;
create policy "fotos lectura publica" on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'fotos');

drop policy if exists "fotos admin sube" on storage.objects;
create policy "fotos admin sube" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'fotos');

drop policy if exists "fotos admin edita" on storage.objects;
create policy "fotos admin edita" on storage.objects
  for update to authenticated using (bucket_id = 'fotos');

drop policy if exists "fotos admin borra" on storage.objects;
create policy "fotos admin borra" on storage.objects
  for delete to authenticated using (bucket_id = 'fotos');
