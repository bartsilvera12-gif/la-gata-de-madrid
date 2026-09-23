/* Datos de la tienda — La Gata de Madrid

   Los productos y la configuración viven en Supabase; este archivo los trae y
   avisa cuando llegan. Si la base no responde, la tienda igual abre con el
   catálogo de respaldo de abajo, en vez de quedar vacía.

   La clave de acá es la pública ("anon"): solo permite leer. Cualquier cambio
   exige iniciar sesión, y eso solo pasa en el panel. */
(function () {
  var API = 'https://api.neura.com.py';
  var ESQUEMA = 'gatademadrid';
  var CLAVE = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzc0MTAxNDYxLCJleHAiOjE5MzE3ODE0NjF9.7_wAph8IolPMXtgfpezSwS5XR62IdD__qhqCywLDp3Q';

  // ---------- Catálogo de respaldo ----------
  // Si Supabase no contesta, la tienda muestra esto.
  var BASE = [
    { id: 'redmi-buds-8-pro', cat: 'Audio', name: 'Redmi Buds 8 Pro', price: 320000, badge: 'Nuevo',
      desc: 'Bluetooth 5.3 · hasta 36 h de batería · cancelación de ruido.',
      long: 'Auriculares in-ear con cancelación activa de ruido y 4 micrófonos. Estuche de carga con hasta 36 horas de autonomía y resistencia IP54 para lluvia y polvo.',
      gallery: ['./assets/p-redmi-buds-8-pro.jpg'],
      specs: [['Conexión', 'Bluetooth 5.3'], ['Batería', 'Hasta 36 h con estuche'], ['Resistencia', 'IP54'], ['Extras', '4 micrófonos · controles táctiles']] },
    { id: 'xiaomi-17t', cat: 'Tecnología', name: 'Xiaomi 17T', price: 4250000, badge: 'Destacado',
      desc: 'Cámara co-desarrollada con Leica · Xiaomi HyperOS.',
      long: 'Xiaomi 17T con sistema de cámaras co-desarrollado con Leica y Xiaomi HyperOS. Caja sellada, incluye cable USB-C.',
      gallery: ['./assets/p-xiaomi-17t.jpg'],
      specs: [['Cámara', 'Co-desarrollada con Leica'], ['Sistema', 'Xiaomi HyperOS'], ['Incluye', 'Cable USB-C y caja original'], ['Garantía', 'A confirmar por WhatsApp']] },
    { id: 'chenson-tote', cat: 'Bolsos', name: 'Chenson Style Tote', price: 395000, badge: 'Destacado',
      desc: 'Verde oliva, herrajes dorados y bolsillo frontal.',
      long: 'Bolso tote de Chenson Paris en verde oliva. Interior amplio con cierre superior, bolsillo frontal y manijas reforzadas.',
      gallery: ['./assets/p-chenson-tote.jpg'],
      specs: [['Material', 'Nylon con detalles símil cuero'], ['Color', 'Verde oliva'], ['Herrajes', 'Dorados'], ['Detalles', 'Bolsillo frontal y cierre superior']] },
    { id: 'eternity-moment', cat: 'Perfumería', name: 'CK Eternity Moment', price: 480000, badge: null,
      desc: 'Calvin Klein · eau de parfum spray para mujer.',
      long: 'Eau de parfum floral frutal de Calvin Klein. Presentación en caja original con vaporizador.',
      gallery: ['./assets/p-eternity-moment.jpg'],
      specs: [['Tipo', 'Eau de parfum spray'], ['Familia', 'Floral frutal'], ['Marca', 'Calvin Klein'], ['Género', 'Mujer']] },
    { id: 'halloween-water-lily', cat: 'Perfumería', name: 'Halloween Water Lily', price: 395000, badge: null,
      desc: 'Eau de toilette 100 ml · floral fresco.',
      long: 'Eau de toilette floral acuática de Halloween, 100 ml. Frasco rosa con base grabada y caja original.',
      gallery: ['./assets/p-halloween-water-lily.jpg'],
      specs: [['Tipo', 'Eau de toilette'], ['Contenido', '100 ml'], ['Familia', 'Floral acuática'], ['Género', 'Mujer']] },
    { id: 'cabotine-eau-vivide', cat: 'Perfumería', name: 'Cabotine Eau Vivide', price: 310000, badge: null,
      desc: 'Parfums Grès Paris · eau de toilette 50 ml.',
      long: 'Eau de toilette fresca de Parfums Grès Paris, 50 ml, con tapa floral azul característica de la línea Cabotine.',
      gallery: ['./assets/p-cabotine-eau-vivide.jpg'],
      specs: [['Tipo', 'Eau de toilette'], ['Contenido', '50 ml'], ['Marca', 'Parfums Grès Paris'], ['Género', 'Mujer']] },
    { id: 'blue-seduction', cat: 'Perfumería', name: 'Blue Seduction for Men', price: 285000, badge: null,
      desc: 'Antonio Banderas · 87 ml · acuático fresco.',
      long: 'Eau de toilette acuática fresca de Antonio Banderas, 87 ml. Un clásico para todos los días.',
      gallery: ['./assets/p-blue-seduction.jpg'],
      specs: [['Tipo', 'Eau de toilette'], ['Contenido', '87 ml'], ['Familia', 'Acuática fresca'], ['Género', 'Hombre']] },
    { id: 'king-of-seduction', cat: 'Perfumería', name: 'King of Seduction Absolute', price: 345000, badge: null,
      desc: 'Antonio Banderas · amaderado intenso para hombre.',
      long: 'Eau de toilette amaderada intensa de Antonio Banderas, con frasco azul y detalles dorados.',
      gallery: ['./assets/p-king-of-seduction.jpg'],
      specs: [['Tipo', 'Eau de toilette'], ['Familia', 'Amaderada intensa'], ['Marca', 'Antonio Banderas'], ['Género', 'Hombre']] },
    { id: 'ck-in2u-him', cat: 'Perfumería', name: 'CK IN2U Him', price: 330000, badge: null,
      desc: 'Calvin Klein · eau de toilette spray 50 ml.',
      long: 'Eau de toilette de Calvin Klein para él, 50 ml, en frasco blanco con base azul.',
      gallery: ['./assets/p-ck-in2u-him.jpg'],
      specs: [['Tipo', 'Eau de toilette spray'], ['Contenido', '50 ml'], ['Marca', 'Calvin Klein'], ['Género', 'Hombre']] }
  ];

  var CART_KEY = 'lgm.cart.v1';

  // Valores por defecto: los mismos textos que había en el código, para que
  // el sitio se vea igual aunque la configuración todavía no haya llegado.
  var CFG_BASE = {
    whatsapp: '595981772872',
    email: 'hola@lagatademadrid.com',
    sitio_nombre: 'La Gata de Madrid',
    pie_descripcion: 'Perfumería, tecnología, bolsos y más. Productos originales, elegidos con ojo de gata.',
    hero_titulo: 'Elegancia',
    hero_subtitulo: 'con siete vidas.',
    banda_eyebrow: 'De dónde viene el nombre',
    banda_titulo: 'Dos debilidades de la casa',
    banda_texto: 'Los gatos y Madrid. De ahí salió el nombre, el cascabel dorado y la forma de elegir cada cosa: una por una, sin apuro.',
    banda_boton: 'Conocé la historia',
    nosotros_titulo: 'Una gata negra, un cascabel dorado y muchas ganas de encontrar cosas lindas.',
    nosotros_p1: 'Empezamos buscando un bolso para uso propio y terminamos armando una tienda online. Vendemos por Instagram y WhatsApp: perfumería original, tecnología, bolsos y accesorios, cada cosa elegida una por una.',
    nosotros_p2: 'Trabajamos con pocas unidades de cada cosa: si te gusta, es tuya. El nombre viene de dos debilidades de la casa: los gatos y Madrid.'
  };

  var lista = null;              // productos de la base; null = todavía no llegaron
  var cfg = {};                  // configuración de la base
  var oyentes = [];
  var estado = 'cargando';       // cargando | listo | respaldo

  function clone(x) { return JSON.parse(JSON.stringify(x)); }

  function avisar() { oyentes.forEach(function (fn) { try { fn(); } catch (e) {} }); }

  // De los nombres de la base a los que usa la tienda.
  function mapear(r) {
    return {
      id: r.id,
      name: r.nombre,
      cat: r.categoria,
      price: Number(r.precio) || 0,
      badge: r.badge || null,
      desc: r.desc_corta || '',
      long: r.desc_larga || '',
      gallery: Array.isArray(r.fotos) ? r.fotos : [],
      specs: Array.isArray(r.ficha) ? r.ficha : [],
      stock: Number(r.stock) || 0,
      destacado: !!r.destacado,
      orden: Number(r.orden) || 0
    };
  }

  function pedir(tabla, consulta) {
    return fetch(API + '/rest/v1/' + tabla + '?' + consulta, {
      headers: { apikey: CLAVE, Authorization: 'Bearer ' + CLAVE, 'Accept-Profile': ESQUEMA }
    }).then(function (r) {
      if (!r.ok) throw new Error(tabla + ': HTTP ' + r.status);
      return r.json();
    });
  }

  function cargar() {
    var pProd = pedir('productos', 'select=*&order=orden.asc,creado.asc');
    // Si falta la tabla de configuración, la tienda sigue con los valores por
    // defecto en vez de caerse entera.
    var pCfg = pedir('configuracion', 'select=clave,valor').catch(function () { return []; });

    return Promise.all([pProd, pCfg]).then(function (res) {
      lista = res[0].map(mapear);
      res[1].forEach(function (f) { cfg[f.clave] = f.valor; });
      estado = 'listo';
      avisar();
    }).catch(function (e) {
      estado = 'respaldo';
      if (window.console) console.warn('[LGM] No se pudo leer Supabase, uso el catálogo de respaldo:', e.message);
      avisar();
    });
  }

  function products() {
    if (lista) return clone(lista);
    return clone(BASE).map(function (p) { p.stock = 1; p.destacado = false; return p; });
  }

  function find(id) {
    var all = products();
    for (var i = 0; i < all.length; i++) if (all[i].id === id) return all[i];
    return null;
  }

  function readCart() {
    try {
      var c = JSON.parse(localStorage.getItem(CART_KEY) || '{}');
      return c && typeof c === 'object' ? c : {};
    } catch (e) { return {}; }
  }

  function writeCart(cart) {
    try { localStorage.setItem(CART_KEY, JSON.stringify(cart)); } catch (e) {}
  }

  window.LGM = {
    BASE: BASE,
    products: products,
    find: find,
    readCart: readCart,
    writeCart: writeCart,
    // Un ajuste del sitio, con el valor de fábrica como respaldo.
    cfg: function (clave) {
      var v = cfg[clave];
      return (v === undefined || v === null || v === '') ? (CFG_BASE[clave] || '') : v;
    },
    get WA() { return this.cfg('whatsapp'); },
    estado: function () { return estado; },
    alCargar: function (fn) { oyentes.push(fn); },
    gs: function (n) { return 'Gs. ' + Number(n || 0).toLocaleString('es-PY'); }
  };

  cargar();
})();
