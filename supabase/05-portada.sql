-- ============================================================
-- La portada, editable desde el panel
-- Dónde: Supabase → SQL Editor → New query → pegar todo → Run
-- Se puede volver a ejecutar sin romper nada.
--
-- Hasta ahora el video de la portada estaba escrito dentro del código: para
-- cambiarlo había que tocar el sitio. Pasa a ser configuración, y además se
-- puede elegir entre un video o una imagen fija.
-- ============================================================

insert into gatademadrid.configuracion
  (clave, valor, grupo, etiqueta, ayuda, tipo, orden)
values
  ('portada_tipo', 'video', 'Portada', 'Qué se muestra arriba',
   'El video llama más la atención; la imagen carga más rápido en celulares con poca señal.',
   'opcion:video=Video|imagen=Imagen fija', 41),

  ('portada_video', './assets/hero-cibeles.mp4', 'Portada', 'Video de la portada',
   'Va en silencio y se repite solo. Que sea corto y liviano: más de 10 MB tarda en cargar.',
   'archivo:video', 42),

  ('portada_imagen', './assets/hero-cibeles.jpg', 'Portada', 'Imagen de la portada',
   'Si elegís "Imagen fija" es lo que se ve. Con video, es lo que aparece mientras carga.',
   'archivo:imagen', 43)
on conflict (clave) do update set
  grupo    = excluded.grupo,
  etiqueta = excluded.etiqueta,
  ayuda    = excluded.ayuda,
  tipo     = excluded.tipo,
  orden    = excluded.orden;

-- Los títulos de la portada quedan después de la imagen, para que el grupo
-- se lea en el orden en que se ven las cosas.
update gatademadrid.configuracion set orden = 44 where clave = 'hero_titulo';
update gatademadrid.configuracion set orden = 45 where clave = 'hero_subtitulo';

select clave, valor, tipo, orden
from gatademadrid.configuracion
where grupo = 'Portada'
order by orden;

notify pgrst, 'reload schema';
