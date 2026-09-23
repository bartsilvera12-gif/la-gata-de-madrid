-- ============================================================
-- Categorías propias
-- Dónde: Supabase → SQL Editor → New query → pegar todo → Run
-- Se puede volver a ejecutar sin romper nada.
--
-- Hasta ahora la categoría era texto libre dentro de cada producto: la tienda
-- las deducía de ahí. Eso hace que un error de tipeo cree una categoría nueva
-- ("Perfumeria" al lado de "Perfumería"), no permite crear una categoría antes
-- de tener productos, y no deja elegir ni el orden ni la foto.
-- ============================================================

-- El nombre es la clave, porque es lo que ya guarda cada producto: así no hay
-- que migrar nada. Renombrar se hace con la función de más abajo.
create table if not exists gatademadrid.categorias (
  nombre text primary key,
  orden  integer not null default 0,
  foto   text not null default '',   -- vacía: usa la foto del primer producto
  creado timestamptz not null default now()
);

create index if not exists categorias_orden_idx on gatademadrid.categorias (orden, nombre);


-- ---------- Carga inicial: las que ya están en uso ----------
-- Quedan en el mismo orden en que aparecen hoy en la tienda.
insert into gatademadrid.categorias (nombre, orden)
select categoria, (row_number() over (order by min(orden))) * 10
from gatademadrid.productos
group by categoria
on conflict (nombre) do nothing;


-- ---------- Permisos y reglas ----------
grant select                         on gatademadrid.categorias to anon;
grant select, insert, update, delete on gatademadrid.categorias to authenticated;

alter table gatademadrid.categorias enable row level security;

drop policy if exists "categorias lectura publica" on gatademadrid.categorias;
create policy "categorias lectura publica" on gatademadrid.categorias
  for select to anon using (true);

drop policy if exists "categorias admin lee" on gatademadrid.categorias;
create policy "categorias admin lee" on gatademadrid.categorias
  for select to authenticated using (true);

drop policy if exists "categorias admin inserta" on gatademadrid.categorias;
create policy "categorias admin inserta" on gatademadrid.categorias
  for insert to authenticated with check (gatademadrid.es_admin());

drop policy if exists "categorias admin edita" on gatademadrid.categorias;
create policy "categorias admin edita" on gatademadrid.categorias
  for update to authenticated
  using (gatademadrid.es_admin()) with check (gatademadrid.es_admin());

drop policy if exists "categorias admin borra" on gatademadrid.categorias;
create policy "categorias admin borra" on gatademadrid.categorias
  for delete to authenticated using (gatademadrid.es_admin());


-- ---------- Renombrar ----------
-- Cambiar el nombre toca dos lugares: la categoría y todos los productos que
-- la usan. Va en una sola función para que no pueda quedar a medias y dejar
-- productos apuntando a una categoría que ya no existe.
create or replace function gatademadrid.renombrar_categoria(vieja text, nueva text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not gatademadrid.es_admin() then
    raise exception 'Sin permiso';
  end if;

  nueva := trim(nueva);
  if nueva = '' then
    raise exception 'El nombre no puede quedar vacío';
  end if;
  if nueva = vieja then
    return;
  end if;
  if exists (select 1 from gatademadrid.categorias c where c.nombre = nueva) then
    raise exception 'Ya existe una categoría llamada %', nueva;
  end if;

  insert into gatademadrid.categorias (nombre, orden, foto)
  select nueva, c.orden, c.foto from gatademadrid.categorias c where c.nombre = vieja;

  update gatademadrid.productos p set categoria = nueva where p.categoria = vieja;

  delete from gatademadrid.categorias c where c.nombre = vieja;
end $$;

grant execute on function gatademadrid.renombrar_categoria(text, text) to authenticated;


-- ---------- Comprobación ----------
select c.nombre, c.orden,
       (select count(*) from gatademadrid.productos p where p.categoria = c.nombre) as productos
from gatademadrid.categorias c
order by c.orden, c.nombre;

notify pgrst, 'reload schema';
