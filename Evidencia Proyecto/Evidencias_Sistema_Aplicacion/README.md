# Evidencias de sistema: aplicación

Equipo 3: Guillermo Mora, José Montesino y Pablo Pinto.
Versión 1.0 de Buk Learning. Fecha de las evidencias: 05-11-2026. Commit de la aplicación: `d043847`.

**Código fuente:** github.com/AleisGit/buk-learning, repositorio privado (acceso por invitación).

## La versión 1.0

Reemplaza al prototipo de las iteraciones 02 y 03. La interfaz en Next.js llama a una API en FastAPI, que guarda
los datos en PostgreSQL 17:

```
Navegador ──► Next.js (frontend/) ──► API FastAPI (backend/) ──► PostgreSQL 17
```

- **Tres roles:** Soporte administra la plataforma; el administrador y el asistente de empresa ven solo la suya.
- **Registro y edición** de empresas cliente, de pólizas con sus montos por trimestre y de miembros, que se
  invitan con un enlace de un solo uso.
- **Resumen de la cartera** con gráficos: siniestralidad, pólizas sobre el umbral, comisión en riesgo, evolución
  por trimestre, niveles de riesgo y ramos. Se exporta a CSV.

La documentación técnica completa está en `Evidencia Proyecto/Evidencias_Documentacion/Documentacion_Tecnica_App.md`
y el modelo de datos en `Evidencia Proyecto/Evidencias_Sistema_Base_de_Datos`.

## Capturas

Tomadas el 05-11-2026 de la aplicación compilada para producción, con los datos de la base de desarrollo, en una
ventana de 1440 px de ancho.

| Archivo | Rol | Qué muestra |
|---|---|---|
| `01_login.png` | | Inicio de sesión |
| `02_empresas_soporte.png` | Soporte | Lista de empresas cliente |
| `03_empresa_soporte.png` | Soporte | Ficha de Transportes Andes SpA: su equipo, sus datos y sus pólizas editables, sin gráficos |
| `03b_vista_empresa.png` | Soporte | Vista empresa: el resumen tal como lo ven los usuarios de Transportes Andes SpA |
| `03c_vista_empresa_detalle.png` | Soporte | Vista empresa, detalle por póliza |
| `04_miembros.png` | Soporte | Lista de miembros |
| `05_invitar.png` | Soporte | Invitación de un asistente para Transportes Andes SpA |
| `06_miembro.png` | Soporte | Ficha de un miembro: María Rojas |
| `07_roles.png` | Soporte | Roles y matriz de permisos |
| `08_resumen_empresa.png` | Administradora de empresa | Resumen de la cartera de su empresa: 69,4 % y ninguna póliza sobre el umbral |
| `09_polizas.png` | Administradora de empresa | Pólizas de su empresa |
| `10_mi_empresa.png` | Administradora de empresa | Mi empresa: el detalle de cada póliza |

## Pruebas

| Prueba | Resultado | Archivo |
|---|---|---|
| API con pytest contra PostgreSQL: autenticación (11), cartera (14), empresas (11), miembros (15) y pólizas (10) | 61 de 61 aprobadas | `resultado_pruebas_api.txt` |
| Punta a punta con Playwright en Microsoft Edge | 8 de 8 aprobadas | `resultado_pruebas_punta_a_punta.txt` |
| Revisión estática: `ruff check` en la API, `eslint` y `tsc --noEmit` en la interfaz | Sin observaciones | |
| `alembic check`: los modelos de la API y la base coinciden | Sin diferencias | |
| Compilación de la interfaz para producción (`next build`) | Correcta | |

Los recorridos de punta a punta prueban cada rol en lo suyo:

1. El login rechaza credenciales malas.
2. Soporte entra a las empresas, sin la cartera en su menú.
3. Soporte registra una empresa e invita a su administradora, que crea su contraseña.
4. La administradora agrega una póliza a su empresa y la corrige.
5. Soporte ve la empresa como sus usuarios y corrige la póliza desde su ficha.
6. La administradora invita a una asistente, que solo ve su empresa.
7. Cambiar el rol de la asistente cierra su sesión.
8. La administradora elimina la póliza y Soporte elimina la empresa, con su equipo.

## Dónde corre

Las evidencias se tomaron en la instalación local: PostgreSQL 17 en Docker, la API con Uvicorn y la interfaz con
`next build` y `next start`. Para las revisiones del 14-10 y del 21-10 la versión 1.0 se publicó en AWS (EC2) en
una instancia temporal, que ya no está activa. El prototipo de las iteraciones 02 y 03 sigue publicado en
https://main.dxy8n76gfjww9.amplifyapp.com.
