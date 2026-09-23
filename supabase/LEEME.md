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

Crea el esquema `gatademadrid` con la tabla `productos`, el depósito de fotos, los
permisos y las reglas de seguridad. Al final devuelve la lista de políticas:
si esa lista sale vacía, algo no se ejecutó.

Las tablas **no** van en `public`, que es el esquema que Supabase expone por
defecto y donde cualquier proyecto mira primero.

### 3. Exponer el esquema `gatademadrid` en la API

**Project Settings → API → Data API → Exposed schemas**: agregar `gatademadrid`
a la lista (junto a los que ya estén) y guardar.

Este paso no existe cuando se usa `public`, y es el que más se olvida: sin
él la base queda bien armada pero el sitio no ve ningún producto.

### 4. Cargar los productos y la configuración

Misma pantalla, nueva consulta, pegar `02-productos.sql` y **Run**. Después,
otra consulta con `03-configuracion.sql` y **Run**.

Entran los 9 productos y los 13 ajustes del sitio (WhatsApp, correo, títulos
de la portada, textos de Nosotros), tal como están hoy en el código. Ninguno
de los dos duplica si lo corrés de nuevo.

Desde ahí, cambiar el número de WhatsApp es editar un campo en el panel, y no
los cuatro lugares del código donde está escrito hoy.


### 5. Crear tu usuario de administradora

**Authentication → Users → Add user → Create new user**

- Correo: **`admin@gatademadrid.com`** y una contraseña.
- Marcá **Auto Confirm User**, así no hace falta confirmar por mail.

El correo tiene que ser exactamente ese, porque es el que quedó habilitado en
la tabla `administradores` del paso 2. Tener cuenta en el Supabase no alcanza:
esta instancia es compartida con otros proyectos, y sin ese filtro cualquier
usuario de cualquiera de ellos podría editar la tienda. Si entrás con otro
correo, el panel te lo dice y cierra la sesión.

### Cambiar o agregar administradoras

En el SQL Editor:

```sql
-- sumar otra
insert into gatademadrid.administradores (email) values ('otra@ejemplo.com');

-- sacar una
delete from gatademadrid.administradores where email = 'vieja@ejemplo.com';
```

El correo va en minúsculas. El cambio es inmediato, no hace falta tocar nada
más.

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

## Usar el panel

Está en **`tudominio.com/admin/`**.
Entrás con el correo y la contraseña del usuario que creaste en el paso 5.

**Productos.** Cada tarjeta se abre tocándola. Podés cambiar nombre, categoría,
precio, stock y etiqueta; escribir las descripciones y la ficha técnica; subir
o quitar fotos; y marcar si va en "Lo que más se busca" o si queda oculto.
Los cambios de texto quedan en borrador hasta que tocás **Guardar cambios**:
mientras tanto la tarjeta se marca en rosa. Las flechas ▲▼ cambian el orden en
que se ven en la tienda y se guardan solas. **Borrar** no se puede deshacer.

Un producto nuevo nace oculto y con precio cero, para que puedas completarlo
tranquila antes de publicarlo.

**Configuración.** Los datos y textos del sitio, agrupados. Cambiás lo que
haga falta y tocás Guardar una sola vez.

Todo lo que guardás se ve en la tienda apenas recargues: no hay que publicar
ni volver a subir nada.

## La portada

En **Configuración → Portada** elegís si arriba se ve un **video** o una
**imagen fija**, y subís el archivo desde ahí mismo.

- El video va en silencio y se repite solo. Que sea corto y liviano: el tope
  del panel son 40 MB, pero más de 10 MB ya se nota en un celular con poca
  señal.
- La imagen sirve para las dos cosas: si elegís "Imagen fija" es lo que se
  ve, y si dejás video, es lo que aparece mientras el video carga. Conviene
  que sea un cuadro del propio video, así no hay salto.
- Los archivos que subís quedan en el depósito de Supabase, no en el
  repositorio: no hace falta publicar nada después.
