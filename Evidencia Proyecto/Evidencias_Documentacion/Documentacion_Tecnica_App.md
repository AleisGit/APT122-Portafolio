> Copia del README del repositorio de la aplicación (github.com/AleisGit/buk-learning, privado), commit `d043847`, del 05-11-2026.
> Se omitió la contraseña de las cuentas de prueba.

# Buk Learning

DSS de siniestralidad de la cartera de seguros intermediada por Buk. Proyecto
APT122, Duoc UC, grupo 3: Guillermo Mora, José Montesino y Pablo Pinto.

```
Navegador ──► Next.js (frontend/) ──► API FastAPI (backend/) ──► PostgreSQL 17
              páginas, acciones del      /api/v1, JWT, reglas       la base calcula
              servidor, sesión NextAuth  y permisos                 la siniestralidad
```

El navegador nunca habla con la API: el servidor de Next.js la llama con el
token de la sesión, que viaja cifrado en una cookie `httpOnly`.

## Arquitectura

**`backend/`**: FastAPI, SQLAlchemy 2, Alembic y PostgreSQL. Se organiza por
dominio, y cada módulo tiene sus modelos, esquemas, servicio y rutas:

| Módulo | Qué hace |
|---|---|
| `app/auth` | Login (OAuth2 con contraseña), sesión, recuperación de acceso, roles y permisos |
| `app/miembros` | Personas con acceso: invitar, editar, desactivar, quitar y enlaces de un solo uso |
| `app/empresas` | Empresas cliente (con RUT validado) y su equipo, para administrarlas |
| `app/polizas` | Pólizas y la prima y los siniestros de cada trimestre; exportación a CSV |
| `app/cartera` | Lectura de la cartera de cada empresa: indicadores, series, niveles de riesgo, búsqueda y orden |
| `app/catalogos` | Listas y parámetros que usan los formularios (ramos, regiones, umbral, trimestres) |
| `app/core` | Configuración, base de datos, seguridad, errores y correo |

- **Capas:** las rutas solo traducen HTTP. Las reglas viven en los servicios, que
  lanzan errores propios (`NoEncontrado`, `Conflicto`, `ReglaIncumplida`…). Un
  manejador único los responde siempre con la misma forma:
  `{codigo, mensaje, campos}`.
- **La siniestralidad la calcula la base**, en una columna generada (siniestros ÷
  prima). Los agregados por póliza, empresa y cartera están en
  `app/cartera/calculos.py`, como funciones puras y con pruebas.
- **Migraciones:** el esquema se crea con Alembic, no con `create_all`.
  `alembic check` confirma que los modelos y la base coinciden.

**`frontend/`**: Next.js 16 (App Router, Cache Components), TypeScript,
Tailwind 4, Plotly y NextAuth v5. Conserva el diseño del prototipo.

- **Capa de acceso a datos:** las pantallas leen solo a través de
  `src/lib/dal.ts`. Cada lectura va a la API con el token de la sesión, y la API
  filtra según el rol.
- **Tipos generados:** salen del OpenAPI de la API con `npm run api:tipos`. Si
  la API cambia, TypeScript avisa dónde hay que ajustar el frontend.
- **Cache Components:** el marco de cada pantalla se prerenderiza y los datos
  llegan dentro de un límite de carga (`loading.tsx` o `<Suspense>`).
- **Escritura:** las acciones del servidor llaman a la API y devuelven los
  errores de cada campo al formulario.

## Roles y miembros

Las personas con acceso se llaman **miembros**, no "usuarios" ni
"colaboradores". En Buk, "colaboradores" son los trabajadores de la empresa
cliente, es decir, los asegurados, y usar esa palabra se prestaría a confusión.

| Permiso | Soporte | Administrador de empresa | Asistente de empresa |
|---|:-:|:-:|:-:|
| Ver los datos de las empresas | todas | la suya | la suya |
| Registrar y eliminar empresas | ✓ | | |
| Editar los datos de la empresa | ✓ | ✓ | |
| Ver el resumen, los gráficos y las pólizas | todas | la suya | la suya |
| Agregar y editar pólizas y montos | ✓ | ✓ | ✓ |
| Eliminar pólizas | ✓ | ✓ | |
| Ver y gestionar miembros | todos | los de su empresa | |
| Gestionar las cuentas de soporte | ✓ | | |

- **Cada rol, sus pantallas:** soporte tiene todos los permisos, pero sus
  pantallas son de administración. Entra a *Empresas cliente*, y en la ficha de
  cada empresa mantiene sus datos, su equipo y sus pólizas, sin gráficos. Para
  ver los gráficos abre *Vista empresa*, que muestra la empresa como la ven sus
  usuarios. Los roles de empresa entran al resumen de su cartera, y en *Mi
  empresa* ven el detalle de cada póliza.
- **Una sola fuente:** la matriz vive en `backend/app/auth/permisos.py`. Los
  servicios preguntan por permisos, nunca por roles.
- **Alcance por empresa:** lo de otra empresa responde 404, como si no existiera.
- **Invitar a un miembro** crea su cuenta sin contraseña y entrega un enlace de un
  solo uso (vence en 72 horas) para que la defina. A una empresa nueva, soporte
  le invita primero a su administrador desde la ficha, y él agrega las pólizas y
  al resto del equipo. Mientras no hay servidor de correo, quien invita copia el
  enlace desde la pantalla y la API escribe el correo en su registro.
- **Reglas de las cuentas:** nadie cambia su propio rol, empresa ni acceso, ni
  borra su propia cuenta. Siempre queda al menos una cuenta de soporte.

## Cómo levantarlo

Requiere Docker, Python 3.12 o superior y Node.js 20.9 o superior.

```bash
# 1. base de datos (PostgreSQL 17 en el puerto 55432)
docker compose up -d db

# 2. API
cd backend
python -m venv .venv
.venv\Scripts\activate              # Windows (en macOS / Linux: source .venv/bin/activate)
pip install -r requirements-dev.txt
copy .env.example .env              # y cambiar JWT_SECRETO
alembic upgrade head
python -m app.semilla               # datos iniciales: solo si la base está vacía
uvicorn app.main:app --port 8000    # documentación en http://localhost:8000/docs

# 3. interfaz
cd frontend
npm install
copy .env.example .env.local        # y poner un AUTH_SECRET aleatorio
npm run dev                         # http://localhost:3000
```

En Windows con Python 3.14, `uvicorn --reload` a veces deja escuchando el
proceso anterior y los cambios no se ven: en ese caso, reinicia la API.

**Cuentas de la semilla.** Todas usan la contraseña que fija `SEMILLA_CLAVE` en el
`.env` de la API:

| Correo | Rol |
|---|---|
| soporte@buklearning.cl | Soporte |
| maria.rojas@transportesandes.cl | Administrador de empresa, Transportes Andes SpA |
| diego.fuentes@transportesandes.cl | Asistente de empresa, Transportes Andes SpA |
| carla.munoz@alimentosdelsur.cl | Administrador de empresa, Alimentos del Sur Ltda. |

Los montos de la semilla son redondos para comprobar cada cálculo a mano: la
cartera parte en 70,0 %.

## Despliegue

`despliegue/` tiene todo lo necesario para correr la aplicación en una sola
máquina con Docker: la base, la API, la interfaz y Caddy, que se encarga del
HTTPS. Hacia afuera solo quedan abiertos los puertos 80 y 443. Sin dominio
propio, sirve la IP pública con sslip.io (por ejemplo, `54-221-120-171.sslip.io`).

```bash
cd despliegue
cp .env.example .env        # dominio, secretos aleatorios y contraseña inicial
docker compose up -d --build
```

Al arrancar, la API aplica las migraciones y carga los datos iniciales si la
base está vacía.

## Pruebas

```bash
cd backend && pytest        # API contra PostgreSQL de verdad (base buk_learning_test)
cd frontend && npm run e2e  # punta a punta en Microsoft Edge, con la API y la interfaz corriendo
```

- **Pruebas de la API:** crean y migran su propia base. Cada prueba corre en una
  transacción que se deshace al terminar.
- **Pruebas de punta a punta:** recorren el flujo completo, con cada rol en lo
  suyo. Soporte registra una empresa e invita a su administradora, que crea su
  contraseña, agrega una póliza y la corrige. Soporte ve la empresa como sus
  usuarios y corrige la póliza desde su ficha. La administradora invita a una
  asistente, que solo ve su empresa, y al cambiarle el rol se cierra su sesión.
  Al final la administradora elimina la póliza y soporte, la empresa. Cada
  corrida crea sus datos y los borra.
- **Revisión de estilo:** `npm run lint`, `npm run typecheck` y, en el backend,
  `ruff check .`.

## Seguridad

- **Contraseñas:** Argon2id. Al menos 8 caracteres, con letras y números.
- **Tokens:** JWT firmados que duran 8 horas. Cambiar el rol, la empresa, el
  acceso o la contraseña invalida los tokens emitidos antes.
- **Intentos fallidos:** cinco seguidos bloquean el login durante 15 minutos.
- **Respuestas que no revelan cuentas:** el login responde igual exista o no la
  cuenta, y la recuperación de acceso también.
- **Enlaces de contraseña:** son de un solo uso y solo se guarda su huella
  SHA-256. Vencen en 72 horas (invitación) o en 30 minutos (recuperación).
- **Autorización en la API:** se revisan el permiso y el alcance en cada
  petición. La interfaz solo decide qué mostrar.
- **Sesión del frontend:** la cookie va cifrada (NextAuth). La ruta `/api/auth`
  no se monta, así que la sesión no se puede leer desde el navegador.
- **Exportación a CSV:** un texto que empieza con `=`, `+`, `-` o `@` se
  antepone con un apóstrofo, para que Excel no lo ejecute como fórmula.

## Decisiones que conviene conocer

- **Plotly**, como dice el documento de la Fase 1. El prototipo usaba Recharts.
  Las tendencias chicas de los indicadores son SVG propio, para no cargar
  Plotly por cuatro puntos.
- **Next.js conserva ocultas las páginas visitadas** (para volver atrás sin
  perder el estado). Por eso cada formulario genera ids únicos con `useId`, y
  las pruebas buscan los campos visibles por su nombre.
- **El trimestre de corte es fijo** (`FECHA_CORTE`, 30-09-2026), para que los
  plazos no cambien entre visitas. La ventana del análisis son los cuatro
  trimestres cerrados hasta ahí.
