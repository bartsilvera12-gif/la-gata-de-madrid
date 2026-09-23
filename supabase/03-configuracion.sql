-- Carga inicial de la configuración del sitio.
-- Son los textos y datos que HOY están escritos dentro del código; se leyeron
-- de ahí, no se transcribieron a mano.
-- Si lo corrés dos veces no duplica: respeta el valor que ya tengas guardado
-- y solo actualiza las etiquetas del panel.

insert into gatademadrid.configuracion
  (clave, valor, grupo, etiqueta, ayuda, tipo, orden)
values
  ('whatsapp', '595981772872', 'Contacto', 'Número de WhatsApp', 'Solo números, con el código de país y sin espacios ni signos. Ej: 595981772872', 'tel', 10),
  ('email', 'hola@lagatademadrid.com', 'Contacto', 'Correo de contacto', '', 'email', 20),
  ('sitio_nombre', 'La Gata de Madrid', 'Marca', 'Nombre de la tienda', '', 'texto', 30),
  ('pie_descripcion', 'Perfumería, tecnología, bolsos y más. Productos originales, elegidos con ojo de gata.', 'Marca', 'Texto del pie de página', 'La frase corta que aparece abajo, junto al nombre.', 'parrafo', 40),
  ('hero_titulo', 'Elegancia', 'Portada', 'Título grande', 'Primera línea, sobre el video.', 'texto', 50),
  ('hero_subtitulo', 'con siete vidas.', 'Portada', 'Segunda línea', 'Va en cursiva, debajo del título.', 'texto', 60),
  ('banda_eyebrow', 'De dónde viene el nombre', 'Franja verde', 'Título chico de arriba', '', 'texto', 70),
  ('banda_titulo', 'Dos debilidades de la casa', 'Franja verde', 'Título', '', 'texto', 80),
  ('banda_texto', 'Los gatos y Madrid. De ahí salió el nombre, el cascabel dorado y la forma de elegir cada cosa: una por una, sin apuro.', 'Franja verde', 'Texto', '', 'parrafo', 90),
  ('banda_boton', 'Conocé la historia', 'Franja verde', 'Texto del botón', '', 'texto', 100),
  ('nosotros_titulo', 'Una gata negra, un cascabel dorado y muchas ganas de encontrar cosas lindas.', 'Nosotros', 'Título de la página', '', 'parrafo', 110),
  ('nosotros_p1', 'Empezamos buscando un bolso para uso propio y terminamos armando una tienda online. Vendemos por Instagram y WhatsApp: perfumería original, tecnología, bolsos y accesorios, cada cosa elegida una por una.', 'Nosotros', 'Primer párrafo', '', 'parrafo', 120),
  ('nosotros_p2', 'Trabajamos con pocas unidades de cada cosa: si te gusta, es tuya. El nombre viene de dos debilidades de la casa: los gatos y Madrid.', 'Nosotros', 'Segundo párrafo', '', 'parrafo', 130)
on conflict (clave) do update set
  grupo    = excluded.grupo,
  etiqueta = excluded.etiqueta,
  ayuda    = excluded.ayuda,
  tipo     = excluded.tipo,
  orden    = excluded.orden;

notify pgrst, 'reload schema';
