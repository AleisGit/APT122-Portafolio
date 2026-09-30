# Evidencias de la aplicación, iteración 02

Equipo 3: Guillermo Mora, José Montesino y Pablo Pinto.
Fecha de las evidencias: 23-09-2026; el video es del 30-09-2026.

**Aplicación publicada:** https://main.dxy8n76gfjww9.amplifyapp.com

Acceso: el formulario de inicio de sesión viene con credenciales cargadas; basta con elegir un rol y presionar
Iniciar sesión.

**Código fuente:** github.com/AleisGit/buk-learning-dss, repositorio privado como define la Fase 1 (acceso por
invitación).

## Estado al 23-09-2026

- **Publicado:** la interfaz del DSS completa, con datos sintéticos de 142 empresas, 189 pólizas y 11 trimestres
  de historia. Tienen la misma estructura póliza por trimestre que tendrá la base de datos.
- **En curso:** la conexión con PostgreSQL, el formulario para ingresar el registro D y el proceso de cálculo al
  guardar, que son el foco de la iteración 02. El detalle está en la ficha de avance 02, en
  `Evidencia Proyecto/Fichas_Iteración`.

## Capturas

Tomadas desde la aplicación publicada, en una ventana de 1440 px de ancho y en un celular de 390 px.

| Archivo | Qué muestra |
|---|---|
| `01_portada.png` | Portada pública: el problema, cómo funciona y los resguardos de datos |
| `02_inicio_de_sesion.png` | Inicio de sesión con selección de uno de los cuatro roles |
| `03_recuperar_acceso.png` | Recuperación de contraseña, que responde igual exista o no la cuenta |
| `04_resumen_cartera.png` | Resumen de la cartera: siniestralidad de 67,6 %, 25 pólizas sobre el umbral, comisión en riesgo, evolución por trimestre, niveles de riesgo, ramos y pólizas que requieren atención |
| `05_polizas.png` | Lista de pólizas con búsqueda, filtros, orden por columna y páginas |
| `06_polizas_sobre_el_umbral.png` | La misma lista filtrada: 25 pólizas, las mismas que cuenta el resumen |
| `07_ficha_poliza_POL-5777.png` | Ficha de una póliza: 11 trimestres contra el umbral de 75 %, datos de la póliza y detalle por trimestre |
| `08_empresas_cliente.png` | Lista de empresas cliente con filtros por rubro, región y nivel |
| `09_ficha_empresa_EMP-0097.png` | Ficha de una empresa con tres pólizas: la siniestralidad de cada una y su detalle |
| `10_acceso_denegado_403.png` | Pantalla de acceso denegado por rol |
| `11_resumen_celular.png` y `12_polizas_celular.png` | Vista en celular |

## Video

`13_video_prueba_interfaz.mp4` (3 min 14 s, 1920x1080): la prueba guiada de la interfaz, grabada el 30-09-2026 con
la aplicación al cierre de la iteración 03, compilada para producción en un servidor local y con una base de datos
nueva. Recorre 16 pasos con mouse y teclado, muestra un rótulo por paso con la marca de cada comprobación y termina
con 15 de 15 comprobaciones aprobadas:

- Inicio de sesión: una contraseña inválida no deja entrar y las credenciales válidas entran al resumen.
- La base parte con dos empresas y la cartera en 70,0 %. Desde el formulario se registra una tercera, Constructora
  Pacífico S.A., con el cálculo en vivo de cada trimestre (70,0 %, 80,0 %, 90,0 % y 100,0 %), y aparece en la
  lista como EMP-0003.
- El resumen sube a 80,0 % (+6,7 pp) con una póliza sobre el umbral; la lista filtrada y el CSV muestran la misma.
- Búsqueda sin tildes, orden por prima anual, ficha de póliza, filtro por región, cierre de sesión y recuperación
  de acceso.

Reemplaza al video anterior, que recorría la versión con datos sintéticos.

## Pruebas

`pruebas_en_produccion.txt`: 29 comprobaciones automáticas ejecutadas en un navegador real contra la URL
publicada, todas aprobadas. Cubren la redirección sin sesión, la validación de la contraseña, el cierre de sesión,
el bloqueo de redirecciones a otros sitios, los filtros, la búsqueda sin tildes, el orden, las páginas, las fichas,
el error 404, la exportación y la recuperación de acceso.

## Exportación

`polizas_sobre_umbral_3T-2026.csv`: exportación desde la lista de pólizas filtrada por "sobre el umbral" y ordenada
por fecha de renovación. Tiene 25 filas, las mismas que cuenta el indicador del resumen, y se abre directo en Excel.

## Despliegue en AWS Amplify

| Build | Fecha | Commit | Resultado |
|---|---|---|---|
| 1 | 23-09-2026 19:11 | `c15628d` | Fallido: `npm ci` rechazó el lockfile, generado con npm 11, porque Amplify usa npm 10 |
| 2 | 23-09-2026 19:16 | `cdfdee6` | Exitoso: se fijó npm 11.6.2 en `amplify.yml`; build, despliegue y verificación correctos |
| 3 | 23-09-2026 19:24 | `816726e` | Exitoso: documentación del despliegue. Es la versión publicada |

Cada push a la rama `main` del repositorio de la aplicación publica una versión nueva.
