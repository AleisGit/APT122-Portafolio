# Endpoints de la API

Generado desde la especificación OpenAPI de la API (versión 1.0.0), el 05-11-2026. Son 29 operaciones.

Todas piden el token de la sesión, salvo cinco: el inicio de sesión, la recuperación de acceso, las dos que funcionan con un enlace de contraseña (`/auth/enlaces/{token}` y `/auth/clave`) y `/health`. La API revisa el permiso y el alcance por empresa en cada petición.

## Autenticación

| Método | Ruta | Qué hace |
|---|---|---|
| POST | `/api/v1/auth/token` | Iniciar sesión |
| GET | `/api/v1/auth/yo` | Miembro de la sesión, con sus permisos |
| POST | `/api/v1/auth/recuperar` | Pedir un enlace para recuperar el acceso |
| GET | `/api/v1/auth/enlaces/{token}` | A quién corresponde un enlace de contraseña |
| POST | `/api/v1/auth/clave` | Fijar la contraseña con un enlace |
| POST | `/api/v1/auth/cambiar-clave` | Cambiar la propia contraseña |

## Cartera

| Método | Ruta | Qué hace |
|---|---|---|
| GET | `/api/v1/cartera/resumen` | Indicadores, series y pólizas que requieren atención |
| GET | `/api/v1/cartera/empresas/{codigo}` | La siniestralidad de una empresa y de cada una de sus pólizas |

## Catálogos

| Método | Ruta | Qué hace |
|---|---|---|
| GET | `/api/v1/catalogos` | Listas y parámetros que usan los formularios y las pantallas |

## Empresas

| Método | Ruta | Qué hace |
|---|---|---|
| GET | `/api/v1/empresas` | Empresas cliente y su equipo, con búsqueda, filtros y orden |
| POST | `/api/v1/empresas` | Registrar una empresa |
| GET | `/api/v1/empresas/opciones` | Código y nombre de las empresas, para los selectores |
| GET | `/api/v1/empresas/{codigo}` | Ficha de una empresa: sus datos y su equipo |
| PUT | `/api/v1/empresas/{codigo}` | Editar una empresa |
| DELETE | `/api/v1/empresas/{codigo}` | Eliminar una empresa |

## Pólizas

| Método | Ruta | Qué hace |
|---|---|---|
| GET | `/api/v1/polizas` | Pólizas, con búsqueda, filtros y orden |
| POST | `/api/v1/polizas` | Agregar una póliza |
| GET | `/api/v1/polizas/exportar` | La lista en CSV, con los mismos filtros y orden |
| GET | `/api/v1/polizas/{numero}` | Ficha de una póliza, con sus trimestres |
| PUT | `/api/v1/polizas/{numero}` | Editar una póliza y los montos de sus trimestres |
| DELETE | `/api/v1/polizas/{numero}` | Eliminar una póliza |

## Miembros

| Método | Ruta | Qué hace |
|---|---|---|
| GET | `/api/v1/miembros` | Miembros, con búsqueda y filtros |
| POST | `/api/v1/miembros` | Invitar a un miembro |
| GET | `/api/v1/miembros/{miembro_id}` | Un miembro |
| PATCH | `/api/v1/miembros/{miembro_id}` | Editar un miembro |
| DELETE | `/api/v1/miembros/{miembro_id}` | Quitar a un miembro |
| POST | `/api/v1/miembros/{miembro_id}/enlace` | Generar un enlace de acceso nuevo |
| GET | `/api/v1/roles` | Roles, con sus permisos y cuántos miembros tiene cada uno |

## Estado

| Método | Ruta | Qué hace |
|---|---|---|
| GET | `/health` | La API está arriba |
