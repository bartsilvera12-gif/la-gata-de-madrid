-- ============================================================
-- La Gata de Madrid — esquema para Supabase
-- Dónde: Supabase → SQL Editor → New query → pegar todo → Run
-- Se puede volver a ejecutar sin romper nada.
--
-- Las tablas NO van en "public": viven en el esquema "gatademadrid".
-- Ese esquema tiene que estar expuesto en la API, o la tienda no ve nada:
--   · Supabase Cloud: Project Settings → API → Exposed schemas
--   · Autoalojado (api.neura.com.py): variable PGRST_DB_SCHEMAS del
--     contenedor de PostgREST. En esta instancia ya está hecho.
-- ============================================================

create schema if not exists gatademadrid;


-- ---------- 1) Productos ----------
create table if not exists gatademadrid.productos (
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

create index if not exists productos_orden_idx on gatademadrid.productos (orden, creado);

-- "actualizado" se pone al día solo.
-- search_path vacío y nombres completos: así la función no puede ser
-- desviada hacia otra tabla con el mismo nombre.
create or replace function gatademadrid.tocar_actualizado()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.actualizado = now();
  return new;
end $$;

drop trigger if exists productos_actualizado on gatademadrid.productos;
create trigger productos_actualizado
  before update on gatademadrid.productos
  for each row execute function gatademadrid.tocar_actualizado();


-- ---------- 2) Configuración del sitio ----------
-- Los datos y textos que antes estaban escritos dentro del código: el número
-- de WhatsApp, el correo, los títulos de la portada. Cada fila es un campo
-- del panel; "grupo", "etiqueta", "ayuda" y "tipo" son los que arman el
-- formulario solo, así agregar un ajuste nuevo es agregar una fila.
create table if not exists gatademadrid.configuracion (
  clave       text primary key,              -- ej: 'whatsapp'
  valor       text not null default '',
  grupo       text not null default 'General',
  etiqueta    text not null,                 -- lo que se lee en el panel
  ayuda       text not null default '',
  tipo        text not null default 'texto', -- texto | parrafo | tel | email
  orden       integer not null default 0,
  actualizado timestamptz not null default now()
);

drop trigger if exists configuracion_actualizada on gatademadrid.configuracion;
create trigger configuracion_actualizada
  before update on gatademadrid.configuracion
  for each row execute function gatademadrid.tocar_actualizado();


-- ---------- 3) Quién es administradora ----------
-- Esta instancia es compartida con otros proyectos. Sin este filtro, cualquier
-- usuario registrado en cualquiera de ellos tendría el rol "authenticated" y
-- podría editar este catálogo. Acá se define quién es, de verdad.
create table if not exists gatademadrid.administradores (
  email  text primary key,
  creado timestamptz not null default now()
);

insert into gatademadrid.administradores (email)
values ('admin@gatademadrid.com')
on conflict (email) do nothing;

-- Nadie la lee desde la API: ni siquiera se puede averiguar quiénes son.
revoke all on gatademadrid.administradores from anon, authenticated;
alter table gatademadrid.administradores enable row level security;
-- (sin políticas: con RLS activado y sin permisos, queda cerrada)

-- Devuelve si quien está pidiendo es administradora.
-- security definer para que pueda mirar la tabla cerrada de arriba;
-- search_path vacío y nombres completos para que no pueda ser desviada.
create or replace function gatademadrid.es_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from gatademadrid.administradores a
    where a.email = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;

-- El panel la usa para avisar si la cuenta no tiene permiso.
grant execute on function gatademadrid.es_admin() to authenticated;


-- ---------- 4) Permisos de rol ----------
-- En "public" Supabase los da solos; en un esquema propio hay que darlos.
-- Es el portón: sin esto, ni siquiera se llega a las reglas por fila.
grant usage on schema gatademadrid to anon, authenticated;

grant select                         on gatademadrid.productos to anon;
grant select, insert, update, delete on gatademadrid.productos to authenticated;

grant select                 on gatademadrid.configuracion to anon;
grant select, update, insert on gatademadrid.configuracion to authenticated;

-- Para las tablas que se creen más adelante en este esquema
alter default privileges in schema gatademadrid
  grant select on tables to anon;
alter default privileges in schema gatademadrid
  grant select, insert, update, delete on tables to authenticated;


-- ---------- 5) Quién puede hacer qué, fila por fila ----------
alter table gatademadrid.productos enable row level security;
alter table gatademadrid.configuracion enable row level security;

-- Configuración: la lee cualquiera, porque la tienda necesita el WhatsApp y
-- los títulos para funcionar. Solo la administradora la cambia, y nadie puede
-- crear ni borrar ajustes: esos los define el esquema.
drop policy if exists "config lectura publica" on gatademadrid.configuracion;
create policy "config lectura publica" on gatademadrid.configuracion
  for select to anon using (true);

drop policy if exists "config admin lee" on gatademadrid.configuracion;
create policy "config admin lee" on gatademadrid.configuracion
  for select to authenticated using (true);

drop policy if exists "config admin edita" on gatademadrid.configuracion;
create policy "config admin edita" on gatademadrid.configuracion
  for update to authenticated
  using (gatademadrid.es_admin()) with check (gatademadrid.es_admin());

-- Visitantes: solo los productos visibles.
drop policy if exists "lectura publica" on gatademadrid.productos;
create policy "lectura publica" on gatademadrid.productos
  for select to anon
  using (oculto = false);

-- Con sesión iniciada: los ocultos solo los ve la administradora. Un usuario
-- de otro proyecto de la instancia ve lo mismo que un visitante cualquiera.
drop policy if exists "admin lee todo" on gatademadrid.productos;
create policy "admin lee todo" on gatademadrid.productos
  for select to authenticated
  using (oculto = false or gatademadrid.es_admin());

-- Escribir, solo la administradora.
drop policy if exists "admin inserta" on gatademadrid.productos;
create policy "admin inserta" on gatademadrid.productos
  for insert to authenticated with check (gatademadrid.es_admin());

drop policy if exists "admin edita" on gatademadrid.productos;
create policy "admin edita" on gatademadrid.productos
  for update to authenticated
  using (gatademadrid.es_admin()) with check (gatademadrid.es_admin());

drop policy if exists "admin borra" on gatademadrid.productos;
create policy "admin borra" on gatademadrid.productos
  for delete to authenticated using (gatademadrid.es_admin());

-- No hay política de insert/update/delete para "anon": con RLS activado,
-- lo que no está permitido queda denegado. La clave pública solo lee.


-- ---------- 6) Depósito de fotos ----------
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
  with check (bucket_id = 'fotos' and gatademadrid.es_admin());

drop policy if exists "fotos admin edita" on storage.objects;
create policy "fotos admin edita" on storage.objects
  for update to authenticated using (bucket_id = 'fotos' and gatademadrid.es_admin());

drop policy if exists "fotos admin borra" on storage.objects;
create policy "fotos admin borra" on storage.objects
  for delete to authenticated using (bucket_id = 'fotos' and gatademadrid.es_admin());


-- ---------- 7) Comprobación ----------
-- Debe devolver una fila por política. Si sale vacío, algo no corrió.
select schemaname, tablename, policyname, roles, cmd
from pg_policies
where schemaname = 'gatademadrid'
order by policyname;

-- Y quién quedó habilitada para entrar al panel.
select email from gatademadrid.administradores order by email;


-- ---------- 8) Avisar a PostgREST ----------
-- En Supabase autoalojado la caché de esquema no se entera sola de las tablas
-- nuevas: sin esto, la API responde "Could not find the table in the schema
-- cache" aunque la tabla exista.
notify pgrst, 'reload schema';
