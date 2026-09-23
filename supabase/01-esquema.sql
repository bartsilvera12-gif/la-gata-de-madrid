-- ============================================================
-- La Gata de Madrid — esquema para Supabase
-- Dónde: Supabase → SQL Editor → New query → pegar todo → Run
-- Se puede volver a ejecutar sin romper nada.
--
-- Las tablas NO van en "public": viven en el esquema "tienda".
-- Ojo: después de correr esto hay que exponer "tienda" en
-- Project Settings → API → Exposed schemas, o la tienda no ve nada.
-- ============================================================

create schema if not exists tienda;


-- ---------- 1) Productos ----------
create table if not exists tienda.productos (
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

create index if not exists productos_orden_idx on tienda.productos (orden, creado);

-- "actualizado" se pone al día solo.
-- search_path vacío y nombres completos: así la función no puede ser
-- desviada hacia otra tabla con el mismo nombre.
create or replace function tienda.tocar_actualizado()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.actualizado = now();
  return new;
end $$;

drop trigger if exists productos_actualizado on tienda.productos;
create trigger productos_actualizado
  before update on tienda.productos
  for each row execute function tienda.tocar_actualizado();


-- ---------- 2) Permisos de rol ----------
-- En "public" Supabase los da solos; en un esquema propio hay que darlos.
-- Es el portón: sin esto, ni siquiera se llega a las reglas por fila.
grant usage on schema tienda to anon, authenticated;

grant select                         on tienda.productos to anon;
grant select, insert, update, delete on tienda.productos to authenticated;

-- Para las tablas que se creen más adelante en este esquema
alter default privileges in schema tienda
  grant select on tables to anon;
alter default privileges in schema tienda
  grant select, insert, update, delete on tables to authenticated;


-- ---------- 3) Quién puede hacer qué, fila por fila ----------
alter table tienda.productos enable row level security;

-- Visitantes: solo leen los productos visibles.
drop policy if exists "lectura publica" on tienda.productos;
create policy "lectura publica" on tienda.productos
  for select to anon
  using (oculto = false);

-- Administradora (sesión iniciada): ve y edita todo, incluidos los ocultos.
drop policy if exists "admin lee todo" on tienda.productos;
create policy "admin lee todo" on tienda.productos
  for select to authenticated using (true);

drop policy if exists "admin inserta" on tienda.productos;
create policy "admin inserta" on tienda.productos
  for insert to authenticated with check (true);

drop policy if exists "admin edita" on tienda.productos;
create policy "admin edita" on tienda.productos
  for update to authenticated using (true) with check (true);

drop policy if exists "admin borra" on tienda.productos;
create policy "admin borra" on tienda.productos
  for delete to authenticated using (true);

-- No hay política de insert/update/delete para "anon": con RLS activado,
-- lo que no está permitido queda denegado. La clave pública solo lee.


-- ---------- 4) Depósito de fotos ----------
-- Storage vive en el esquema "storage", que es de Supabase y no se mueve.
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


-- ---------- 5) Comprobación ----------
-- Debe devolver una fila por política. Si sale vacío, algo no corrió.
select schemaname, tablename, policyname, roles, cmd
from pg_policies
where schemaname = 'tienda'
order by policyname;
