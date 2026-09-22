/* Catálogo compartido — La Gata de Madrid
   Los datos base viven acá. El panel de admin guarda cambios en localStorage
   (clave lgm.catalogo.v1) y todas las páginas leen la versión combinada. */
(function () {
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

  var STORE_KEY = 'lgm.catalogo.v1';
  var CART_KEY = 'lgm.cart.v1';
  var WA = '595981772872';

  function clone(list) { return JSON.parse(JSON.stringify(list)); }

  function overrides() {
    try { return JSON.parse(localStorage.getItem(STORE_KEY) || '{}') || {}; } catch (e) { return {}; }
  }

  function products() {
    var ov = overrides();
    return clone(BASE)
      .map(function (p) {
        var patch = ov[p.id];
        if (!patch) return p;
        Object.keys(patch).forEach(function (k) { p[k] = patch[k]; });
        return p;
      })
      .filter(function (p) { return !p.oculto; });
  }

  function find(id) {
    var all = products();
    for (var i = 0; i < all.length; i++) if (all[i].id === id) return all[i];
    return null;
  }

  function saveOverrides(map) {
    try { localStorage.setItem(STORE_KEY, JSON.stringify(map)); } catch (e) {}
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
    WA: WA,
    STORE_KEY: STORE_KEY,
    products: products,
    find: find,
    overrides: overrides,
    saveOverrides: saveOverrides,
    readCart: readCart,
    writeCart: writeCart,
    gs: function (n) { return 'Gs. ' + Number(n || 0).toLocaleString('es-PY'); },
    pageFor: function (id) { return './producto-' + id + '.dc.html'; }
  };
})();
