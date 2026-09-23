-- Carga inicial: los 9 productos que ya estaban en el sitio.
-- Generado desde catalogo.js, no escrito a mano.
-- Si lo corrés dos veces no duplica nada: actualiza por id.

insert into gatademadrid.productos
  (id, nombre, categoria, precio, badge, desc_corta, desc_larga, fotos, ficha, stock, destacado, oculto, orden)
values
  ('redmi-buds-8-pro', 'Redmi Buds 8 Pro', 'Audio', 320000, 'Nuevo', 'Bluetooth 5.3 · hasta 36 h de batería · cancelación de ruido.', 'Auriculares in-ear con cancelación activa de ruido y 4 micrófonos. Estuche de carga con hasta 36 horas de autonomía y resistencia IP54 para lluvia y polvo.', array['./assets/p-redmi-buds-8-pro.jpg']::text[], '[["Conexión","Bluetooth 5.3"],["Batería","Hasta 36 h con estuche"],["Resistencia","IP54"],["Extras","4 micrófonos · controles táctiles"]]'::jsonb, 1, true, false, 10),
  ('xiaomi-17t', 'Xiaomi 17T', 'Tecnología', 4250000, 'Destacado', 'Cámara co-desarrollada con Leica · Xiaomi HyperOS.', 'Xiaomi 17T con sistema de cámaras co-desarrollado con Leica y Xiaomi HyperOS. Caja sellada, incluye cable USB-C.', array['./assets/p-xiaomi-17t.jpg']::text[], '[["Cámara","Co-desarrollada con Leica"],["Sistema","Xiaomi HyperOS"],["Incluye","Cable USB-C y caja original"],["Garantía","A confirmar por WhatsApp"]]'::jsonb, 1, true, false, 20),
  ('chenson-tote', 'Chenson Style Tote', 'Bolsos', 395000, 'Destacado', 'Verde oliva, herrajes dorados y bolsillo frontal.', 'Bolso tote de Chenson Paris en verde oliva. Interior amplio con cierre superior, bolsillo frontal y manijas reforzadas.', array['./assets/p-chenson-tote.jpg']::text[], '[["Material","Nylon con detalles símil cuero"],["Color","Verde oliva"],["Herrajes","Dorados"],["Detalles","Bolsillo frontal y cierre superior"]]'::jsonb, 1, true, false, 30),
  ('eternity-moment', 'CK Eternity Moment', 'Perfumería', 480000, null, 'Calvin Klein · eau de parfum spray para mujer.', 'Eau de parfum floral frutal de Calvin Klein. Presentación en caja original con vaporizador.', array['./assets/p-eternity-moment.jpg']::text[], '[["Tipo","Eau de parfum spray"],["Familia","Floral frutal"],["Marca","Calvin Klein"],["Género","Mujer"]]'::jsonb, 1, true, false, 40),
  ('halloween-water-lily', 'Halloween Water Lily', 'Perfumería', 395000, null, 'Eau de toilette 100 ml · floral fresco.', 'Eau de toilette floral acuática de Halloween, 100 ml. Frasco rosa con base grabada y caja original.', array['./assets/p-halloween-water-lily.jpg']::text[], '[["Tipo","Eau de toilette"],["Contenido","100 ml"],["Familia","Floral acuática"],["Género","Mujer"]]'::jsonb, 1, false, false, 50),
  ('cabotine-eau-vivide', 'Cabotine Eau Vivide', 'Perfumería', 310000, null, 'Parfums Grès Paris · eau de toilette 50 ml.', 'Eau de toilette fresca de Parfums Grès Paris, 50 ml, con tapa floral azul característica de la línea Cabotine.', array['./assets/p-cabotine-eau-vivide.jpg']::text[], '[["Tipo","Eau de toilette"],["Contenido","50 ml"],["Marca","Parfums Grès Paris"],["Género","Mujer"]]'::jsonb, 1, false, false, 60),
  ('blue-seduction', 'Blue Seduction for Men', 'Perfumería', 285000, null, 'Antonio Banderas · 87 ml · acuático fresco.', 'Eau de toilette acuática fresca de Antonio Banderas, 87 ml. Un clásico para todos los días.', array['./assets/p-blue-seduction.jpg']::text[], '[["Tipo","Eau de toilette"],["Contenido","87 ml"],["Familia","Acuática fresca"],["Género","Hombre"]]'::jsonb, 1, false, false, 70),
  ('king-of-seduction', 'King of Seduction Absolute', 'Perfumería', 345000, null, 'Antonio Banderas · amaderado intenso para hombre.', 'Eau de toilette amaderada intensa de Antonio Banderas, con frasco azul y detalles dorados.', array['./assets/p-king-of-seduction.jpg']::text[], '[["Tipo","Eau de toilette"],["Familia","Amaderada intensa"],["Marca","Antonio Banderas"],["Género","Hombre"]]'::jsonb, 1, false, false, 80),
  ('ck-in2u-him', 'CK IN2U Him', 'Perfumería', 330000, null, 'Calvin Klein · eau de toilette spray 50 ml.', 'Eau de toilette de Calvin Klein para él, 50 ml, en frasco blanco con base azul.', array['./assets/p-ck-in2u-him.jpg']::text[], '[["Tipo","Eau de toilette spray"],["Contenido","50 ml"],["Marca","Calvin Klein"],["Género","Hombre"]]'::jsonb, 1, false, false, 90)
on conflict (id) do update set
  nombre      = excluded.nombre,
  categoria   = excluded.categoria,
  precio      = excluded.precio,
  badge       = excluded.badge,
  desc_corta  = excluded.desc_corta,
  desc_larga  = excluded.desc_larga,
  fotos       = excluded.fotos,
  ficha       = excluded.ficha,
  orden       = excluded.orden;
