# Supabase — puesta en marcha

Acá vive la base de datos de la tienda: los productos, las fotos y el acceso
de la administradora. La tienda lee de Supabase; el panel escribe.

## Pasos, una sola vez

### 1. Crear el proyecto

En [supabase.com](https://supabase.com) → **New project**.

- **Name:** `la-gata-de-madrid`
- **Database password:** generá una y guardala en un lugar seguro. No va en el
  sitio ni en este repositorio; solo sirve si algún día hace falta entrar a la
  base por fuera del panel.
- **Region:** `South America (São Paulo)` — es la más cercana a Paraguay, así
  la tienda carga más rápido.

El plan gratuito alcanza de sobra para este catálogo.

### 2. Crear las tablas

**SQL Editor → New query**, pegar todo el contenido de `01-esquema.sql` y
**Run**. Se puede volver a ejecutar sin romper nada.

Crea el esquema `tienda` con la tabla `productos`, el depósito de fotos, los
permisos y las reglas de seguridad. Al final devuelve la lista de políticas:
si esa lista sale vacía, algo no se ejecutó.

Las tablas **no** van en `public`, que es el esquema que Supabase expone por
defecto y donde cualquier proyecto mira primero.

### 3. Exponer el esquema `tienda` en la API

**Project Settings → API → Data API → Exposed schemas**: agregar `tienda`
a la lista (junto a los que ya estén) y guardar.

Este paso no existe cuando se usa `public`, y es el que más se olvida: sin
él la base queda bien armada pero el sitio no ve ningún producto.

### 4. Cargar los productos que ya existen

Misma pantalla, nueva consulta, pegar `02-productos.sql` y **Run**.

Entran los 9 productos que hoy están en el sitio, con sus precios, fichas y
fotos. Si lo corrés dos veces no se duplican.

### 5. Crear tu usuario de administradora

**Authentication → Users → Add user → Create new user**

- Tu correo y una contraseña.
- Marcá **Auto Confirm User**, así no hace falta confirmar por mail.

Ese es el usuario con el que vas a entrar al panel. No hay registro abierto:
nadie más puede crearse una cuenta.

### 6. Pasarme las dos claves públicas

**Project Settings → API**, copiar:

- **Project URL** (algo como `https://abcdefgh.supabase.co`)
- **anon public** (una clave larga que empieza con `eyJ...`)

Con eso conecto la tienda y el panel.

## Sobre las claves

La clave **anon** es pública a propósito: va dentro del sitio, cualquiera que
mire el código la ve. Eso es normal y seguro, porque las reglas del punto 2
son las que deciden qué se puede hacer con ella — leer los productos visibles,
nada más. Para escribir hace falta iniciar sesión.

La clave **service_role** de esa misma pantalla es lo contrario: saltea todas
las reglas. **No me la pases y no la pongas en ningún archivo del sitio.**
