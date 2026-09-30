# Evidencias de la aplicación, iteración 03: salida del sistema

Equipo 3: Guillermo Mora, José Montesino y Pablo Pinto.
Fecha de las evidencias: 30-09-2026. Ficha: `Evidencia Proyecto/Fichas_Iteración/Ficha_Avance_03_Proyecto_Capstone_Equipo3.docx`.

## El caso de prueba

La aplicación trabaja ahora sobre una base de datos PostgreSQL (PGlite, PostgreSQL embebido) con las tablas
`empresa`, `poliza` y `poliza_periodo`. La siniestralidad de cada trimestre la calcula la propia base, en una
columna generada: siniestros incurridos ÷ prima devengada.

La base parte con dos empresas de montos redondos. Desde la aplicación se registra una tercera y el sistema
recalcula la salida.

| Empresa | Póliza | Prima por trimestre | Siniestros 4T 2025 a 3T 2026 | 3T 2026 |
|---|---|---|---|---|
| Transportes Andes SpA | POL-1001, Salud | $4.000.000 | $2.400.000, $2.600.000, $2.600.000, $2.800.000 | 70,0 % |
| Alimentos del Sur Ltda. | POL-1002, Dental | $1.000.000 | $500.000, $550.000, $650.000, $700.000 | 70,0 % |
| Constructora Pacífico S.A. (se registra en la prueba) | POL-1003, Salud | $2.500.000 | $1.750.000, $2.000.000, $2.250.000, $2.500.000 | 100,0 % |

**Salida esperada y obtenida**

- Empresa nueva en 3T 2026: 2.500.000 ÷ 2.500.000 = 100,0 %, nivel crítico. Últimos 12 meses:
  8.500.000 ÷ 10.000.000 = 85,0 %.
- Cartera en 3T 2026: antes, (2.800.000 + 700.000) ÷ 5.000.000 = 70,0 %. Después,
  (2.800.000 + 700.000 + 2.500.000) ÷ 7.500.000 = 80,0 %, 6,7 puntos sobre el trimestre anterior.
- Pólizas sobre el umbral de 75 %: de 0 a 1. Comisión anual en riesgo: 10.000.000 × 8 % = $800.000 ($ 0,8 MM en la captura 07).

La aplicación y una consulta SQL directa a la base dan los mismos valores (ver `resultado_caso_de_prueba.txt`).

## Archivos

| Archivo | Qué muestra |
|---|---|
| `01_resumen_inicial.png` | Estado inicial: cartera en 70,0 %, 2 empresas, ninguna póliza sobre el umbral |
| `02_empresas_iniciales.png` | Las dos empresas de la base |
| `03_validacion_sin_datos.png` | Sin datos no se guarda: los 16 campos obligatorios quedan marcados |
| `04_calculo_en_vivo.png` | Registro de la empresa 3: la siniestralidad se calcula mientras se escriben los montos |
| `05_nombre_repetido.png` | Con un nombre que ya existe no se guarda, y el resto de los datos se conserva |
| `06_ficha_empresa_nueva.png` | Ficha de la empresa 3: 100,0 % en 3T 2026, nivel crítico, y 85,0 % en 12 meses |
| `07_resumen_recalculado.png` | Resumen recalculado: 80,0 % (+6,7 pp) y 1 póliza sobre el umbral |
| `08_polizas_sobre_umbral.png` | La lista filtrada muestra solo la póliza nueva, POL-1003 |
| `09_tras_reiniciar.png` | Después de reiniciar el servidor, la base conserva las 3 empresas |
| `10_video_caso_de_prueba.mp4` | La prueba completa en video (2 min 11 s, 1920x1080), con un rótulo por paso |
| `resultado_caso_de_prueba.txt` | Las 11 comprobaciones, todas aprobadas, y las consultas SQL a la base al terminar |

La prueba es automática: controla Microsoft Edge moviendo el mouse, haciendo clic y escribiendo, sobre una
base nueva en cada corrida. En el repositorio de la aplicación se ejecuta con `npm run prueba:caso`, o con
`npm run video:caso` para grabar además el video.

## Lo que falta

En la versión publicada en AWS Amplify la base vive en memoria, una por cada instancia del servidor: lo que se
registra allí no se comparte entre instancias y se pierde al reiniciar. El caso de prueba se ejecutó en la
instalación local, donde la base se guarda en disco. Para la versión publicada falta conectar un PostgreSQL
administrado, con el mismo esquema.
