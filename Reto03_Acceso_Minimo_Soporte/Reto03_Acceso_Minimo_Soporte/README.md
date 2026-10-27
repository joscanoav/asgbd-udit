# RETO 03 · Acceso mínimo a los datos de soporte

**Módulo:** 0377 · Administración de Sistemas Gestores de Bases de Datos (ASGBD)  
**Ciclo:** 2.º ASIR · UDIT · Curso 2026/27  
**Tipo:** Reto evaluable individual  
**Duración orientativa:** 3 horas  
**Gestor:** Oracle Database 21c XE  
**Herramienta cliente:** DBeaver  
**Archivos entregados:** `README.md` y `incidencias_soporte.csv`

---

## 1. Situación profesional

La empresa ficticia **Soporte Norte** gestiona incidencias técnicas de sus clientes. El departamento de atención al cliente ha recopilado las incidencias en un archivo CSV y lo entrega al administrador de bases de datos para incorporarlas a Oracle.

El equipo de soporte necesita consultar el identificador de cada incidencia, su asunto, estado y prioridad. Para realizar esta tarea no necesita consultar los datos de contacto de los clientes.

La empresa quiere aplicar el principio de **mínimo privilegio**: cada usuario debe disponer únicamente de los permisos necesarios para realizar su trabajo.

Tu misión es preparar una solución que permita:

1. Revisar un archivo de datos recibido de otro departamento.
2. Crear una tabla en Oracle para almacenar las incidencias.
3. Importar los datos del CSV y comprobar que se han cargado correctamente.
4. Crear una vista que muestre solo la información necesaria para soporte.
5. Conceder al usuario restringido permiso de consulta sobre esa vista.
6. Comprobar que el usuario puede consultar la vista, pero no acceder directamente a la tabla original.
7. Documentar el proceso mediante capturas reales y responder a las preguntas de análisis.

Este reto cierra la práctica de vistas y permisos en Oracle. En una fase posterior, la documentación podrá servir para comparar cómo se realizan tareas equivalentes en MySQL. **En este reto no se instala MySQL ni se migra la base de datos.**

## 2. Objetivos de aprendizaje

Al finalizar, deberás demostrar que puedes:

- Identificar la estructura de un archivo CSV y relacionarla con una tabla relacional.
- Crear una tabla con tipos de datos y restricciones sencillas.
- Importar datos externos mediante DBeaver.
- Verificar el número de filas y la correspondencia entre columnas.
- Crear una vista con una selección explícita de columnas.
- Conceder el privilegio `SELECT` sobre una vista.
- Comprobar los permisos utilizando dos cuentas distintas.
- Interpretar errores esperados y distinguirlos de errores que requieren ayuda.
- Justificar decisiones técnicas a partir del caso empresarial.
- Elaborar evidencias claras, ordenadas y auténticas.

## 3. Entorno y condiciones de trabajo

Utiliza el mismo entorno del laboratorio anterior.

| Elemento | Valor |
|---|---|
| Sistema de la máquina virtual | Windows 11 |
| Gestor de bases de datos | Oracle Database 21c XE |
| Herramienta cliente | DBeaver en el equipo físico |
| Usuario propietario de los objetos | `admin_udit` |
| Usuario de consulta restringida | `usuario_restringido` |
| Archivo de entrada | `incidencias_soporte.csv` |
| Tabla que crearás | `incidencias_reto03` |
| Vista que crearás | `v_incidencias_consulta` |

### Reglas de seguridad

- No crees usuarios nuevos ni cambies contraseñas.
- No cambies el firewall, la red virtual ni la configuración de Oracle.
- No concedas privilegios de administración.
- No elimines objetos del laboratorio anterior.
- No ejecutes sentencias de borrado para intentar resolver errores.
- Antes de ejecutar una sentencia, comprueba qué conexión está seleccionada.
- Usa únicamente los datos ficticios proporcionados en el CSV.
- No sustituyas una captura real por una imagen de ejemplo.
- Si aparece un error que no está explicado en el README, copia el mensaje completo y consulta al profesor.

En DBeaver, normalmente puedes ejecutar la sentencia actual con **Ctrl + Enter**. Asegúrate de que el editor SQL está asociado a la conexión correcta.

## 4. Archivos proporcionados

Junto a este README se entrega el archivo:

`incidencias_soporte.csv`

El archivo contiene una cabecera y cinco registros ficticios. Las columnas son:

| Columna CSV | Significado | ¿Debe estar en la vista de soporte? |
|---|---|---|
| `id_incidencia` | Identificador de la incidencia | Sí |
| `cliente` | Nombre del cliente | No |
| `email_contacto` | Correo de contacto | No |
| `asunto` | Descripción breve del problema | Sí |
| `estado` | Estado actual | Sí |
| `prioridad` | Prioridad asignada | Sí |

El CSV es un archivo de texto delimitado por comas. La primera línea contiene los nombres de las columnas. Durante la importación tendrás que comprobar que DBeaver relaciona cada campo del archivo con la columna correcta de la tabla.

**No edites ni cambies el orden de las columnas del CSV.** Si modificas el archivo accidentalmente, vuelve a utilizar el archivo original entregado con el reto.

## 5. Plan de trabajo orientativo

| Tiempo | Actividad |
|---|---|
| 0–15 min | Comprobar conexiones y examinar el CSV |
| 15–40 min | Crear la tabla de incidencias |
| 40–75 min | Importar el CSV y validar los datos |
| 75–90 min | Probar el acceso directo como usuario restringido |
| 90–100 min | Descanso |
| 100–125 min | Crear la vista y conceder el permiso |
| 125–150 min | Realizar las tres pruebas de acceso |
| 150–170 min | Responder el análisis del caso |
| 170–180 min | Revisar evidencias y preparar el ZIP |

Los tiempos son orientativos. La prioridad es realizar las comprobaciones correctamente y entender los resultados.

---

## 6. Parte A. Comprobar las conexiones y examinar el CSV

### Paso 1. Comprobar `admin_udit`

Abre DBeaver y selecciona la conexión `admin_udit`. Ejecuta:

```sql
SELECT USER AS usuario_actual,
       SYS_CONTEXT('USERENV', 'CON_NAME') AS contenedor
FROM DUAL;
```

Comprueba que `usuario_actual` muestra `ADMIN_UDIT`. Anota el contenedor si lo necesitas, pero no cambies de contenedor.

### Paso 2. Comprobar `usuario_restringido`

Abre la conexión `usuario_restringido` y ejecuta:

```sql
SELECT USER AS usuario_actual
FROM DUAL;
```

Debe aparecer `USUARIO_RESTRINGIDO`.

Si alguna conexión no funciona, no recrees usuarios ni cambies contraseñas. Comprueba que la máquina virtual y el servicio Oracle están iniciados y pide ayuda si el problema continúa.

### Paso 3. Examinar el archivo CSV

Abre `incidencias_soporte.csv` con un editor de texto o con una hoja de cálculo. Comprueba:

- Que la primera línea contiene los nombres de las seis columnas.
- Que hay cinco registros de datos, además de la cabecera.
- Que el separador entre campos es la coma.
- Que los identificadores van del 1 al 5.
- Que el archivo no contiene datos reales de personas.

**Evidencia 01:** captura donde se vea la comprobación de las conexiones y el archivo CSV. Puedes hacer dos capturas si no cabe todo de forma legible.

Nombre: `images/01_conexiones_y_csv.png`

---

## 7. Parte B. Crear la tabla en Oracle

**Conexión obligatoria: `admin_udit`.**

La tabla debe contener las seis columnas del CSV. Los tipos de datos deben admitir los valores del archivo.

### Paso 1. Crear la tabla

Ejecuta esta sentencia:

```sql
CREATE TABLE incidencias_reto03 (
    id_incidencia  NUMBER(4) PRIMARY KEY,
    cliente        VARCHAR2(50) NOT NULL,
    email_contacto VARCHAR2(80),
    asunto         VARCHAR2(80) NOT NULL,
    estado         VARCHAR2(15) NOT NULL,
    prioridad      VARCHAR2(10) NOT NULL
);
```

La clave primaria es `id_incidencia`, que identifica cada incidencia y evita que se repita el identificador. Las restricciones `NOT NULL` indican que esos campos deben contener un valor.

**Resultado esperado:** Oracle confirma que la tabla se ha creado correctamente.

### Paso 2. Verificar que la tabla existe

Puedes comprobar su estructura desde el navegador de objetos de DBeaver, actualizando el esquema `ADMIN_UDIT` y localizando la tabla `INCIDENCIAS_RETO03`.

También puedes consultar las columnas con:

```sql
SELECT column_id, column_name, data_type, nullable
FROM user_tab_columns
WHERE table_name = 'INCIDENCIAS_RETO03'
ORDER BY column_id;
```

Deben aparecer seis columnas.

**Evidencia 02:** captura del resultado de creación y/o de la estructura de la tabla.

Nombre: `images/02_tabla_creada.png`

### Si aparece un error

- `ORA-00955`: ya existe un objeto con ese nombre. No lo borres; comprueba qué objeto existe y consulta al profesor.
- `ORA-01031`: la cuenta no dispone de privilegios suficientes para el paso. Detente y consulta al profesor.
- Cualquier otro error inesperado: guarda el mensaje completo y no pruebes comandos al azar.

---

## 8. Parte C. Importar el archivo CSV con DBeaver

**Conexión obligatoria: `admin_udit`.**

En esta parte cargarás los datos del archivo `incidencias_soporte.csv` en la tabla `incidencias_reto03`.

> Los nombres de algunas opciones del asistente pueden variar ligeramente según la versión de DBeaver. Si tu pantalla no coincide exactamente, busca la acción equivalente de importar datos desde un archivo CSV.

### Paso 1. Abrir el asistente de importación

1. En el navegador de bases de datos de DBeaver, localiza `ADMIN_UDIT`.
2. Localiza la tabla `INCIDENCIAS_RETO03`.
3. Haz clic con el botón derecho sobre la tabla.
4. Selecciona **Import Data** o **Importar datos**.
5. Selecciona el origen de tipo **CSV** o **CSV file**.
6. Pulsa **Next** o **Siguiente**.
7. Selecciona el archivo `incidencias_soporte.csv` que acompaña al README.

Comprueba que has elegido el archivo correcto antes de continuar.

### Paso 2. Configurar la lectura del CSV

Revisa las opciones del asistente:

- **Encoding / Codificación:** UTF-8, si aparece la opción.
- **Delimiter / Separador:** coma `,`.
- **Header / Cabecera:** activa la opción que indica que la primera fila contiene nombres de columnas.
- **Quote / Carácter de comillas:** deja la opción predeterminada si el archivo se muestra correctamente.
- **Column mapping / Correspondencia de columnas:** comprueba que cada campo de origen se asigna a la columna con el mismo nombre.

La cabecera no debe importarse como un registro de datos. Debes cargar cinco incidencias, no seis filas.

### Paso 3. Revisar la correspondencia de columnas

Antes de ejecutar la importación, comprueba que la correspondencia es esta:

| Campo del CSV | Columna de destino |
|---|---|
| `id_incidencia` | `ID_INCIDENCIA` |
| `cliente` | `CLIENTE` |
| `email_contacto` | `EMAIL_CONTACTO` |
| `asunto` | `ASUNTO` |
| `estado` | `ESTADO` |
| `prioridad` | `PRIORIDAD` |

No continúes si ves columnas desplazadas o valores asignados al campo incorrecto. Vuelve a la configuración y corrige la correspondencia antes de iniciar la carga.

### Paso 4. Ejecutar la importación

1. Avanza hasta la pantalla de confirmación.
2. Comprueba que el destino es `ADMIN_UDIT.INCIDENCIAS_RETO03`.
3. Inicia la importación.
4. Espera a que DBeaver muestre el resultado.
5. Si la importación termina correctamente, confirma los cambios si DBeaver lo solicita.

No repitas la importación si no sabes si la primera ejecución insertó filas. Primero comprueba el contenido de la tabla.

### Paso 5. Verificar los datos importados

Ejecuta en la conexión `admin_udit`:

```sql
SELECT *
FROM incidencias_reto03
ORDER BY id_incidencia;
```

El resultado correcto debe contener **cinco filas y seis columnas**, con identificadores del 1 al 5.

Para comprobar el número de registros, ejecuta también:

```sql
SELECT COUNT(*) AS total_incidencias
FROM incidencias_reto03;
```

El resultado esperado es `5`.

Puedes revisar los identificadores con:

```sql
SELECT id_incidencia
FROM incidencias_reto03
ORDER BY id_incidencia;
```

Deben aparecer los identificadores 1, 2, 3, 4 y 5.

**Evidencia 03:** captura de la tabla con las cinco incidencias visibles.

Nombre: `images/03_datos_importados.png`

**Evidencia 04:** captura de la consulta `COUNT(*)` que demuestra que hay cinco registros.

Nombre: `images/04_conteo_registros.png`

### Si la importación falla

No borres la tabla ni vuelvas a importar automáticamente. Revisa:

- Que el archivo seleccionado es `incidencias_soporte.csv`.
- Que la coma está seleccionada como separador.
- Que la cabecera se reconoce como nombres de columna.
- Que la tabla de destino es `INCIDENCIAS_RETO03`.
- Que la correspondencia de las seis columnas es correcta.
- Que no se han insertado ya registros en un intento anterior.

Si la tabla contiene datos parciales o aparecen identificadores duplicados, detente y consulta al profesor. No ejecutes sentencias `DELETE` para intentar dejar la tabla vacía.

---

## 9. Parte D. Comprobar el acceso directo a la tabla

En una empresa, no todos los usuarios necesitan acceder a todas las tablas. Primero comprobarás el comportamiento del usuario restringido antes de concederle acceso a la vista.

### Paso 1. Cambiar a `usuario_restringido`

Selecciona esa conexión y confirma el usuario activo:

```sql
SELECT USER AS usuario_actual
FROM DUAL;
```

Debe aparecer `USUARIO_RESTRINGIDO`.

### Paso 2. Intentar consultar la tabla original

Ejecuta:

```sql
SELECT *
FROM admin_udit.incidencias_reto03;
```

Si el usuario no tiene permiso directo, la consulta debe rechazarse. Es habitual que Oracle muestre `ORA-00942`.

En este punto, el rechazo es el resultado esperado.

**Evidencia 05:** captura donde se vea la consulta y el error.

Nombre: `images/05_acceso_denegado_tabla.png`

Si la consulta devuelve datos, comprueba que la conexión activa es realmente `USUARIO_RESTRINGIDO`. Si lo es, no continúes hasta que el profesor revise los permisos existentes.

---

## 10. Parte E. Crear una vista para el equipo de soporte

La empresa quiere que el equipo consulte únicamente los campos necesarios para gestionar las incidencias.

### Paso 1. Volver a `admin_udit`

Selecciona la conexión `admin_udit`.

Crea la vista:

```sql
CREATE OR REPLACE VIEW v_incidencias_consulta AS
SELECT id_incidencia,
       asunto,
       estado,
       prioridad
FROM incidencias_reto03;
```

La vista incluye cuatro columnas y excluye `cliente` y `email_contacto`.

**Evidencia 06:** captura del resultado correcto de la creación de la vista.

Nombre: `images/06_vista_creada.png`

### Paso 2. Conceder el permiso de consulta

En la misma conexión, ejecuta:

```sql
GRANT SELECT
ON v_incidencias_consulta
TO usuario_restringido;
```

Esta sentencia permite al usuario restringido consultar la vista. No le concede por sí misma acceso directo a la tabla original.

**Evidencia 07:** captura del resultado de la concesión del permiso.

Nombre: `images/07_permiso_concedido.png`

Si aparece `ORA-01031`, detente y consulta al profesor. No concedas privilegios adicionales ni cambies la configuración del servidor.

---

## 11. Parte F. Realizar las pruebas de acceso

Realiza las siguientes pruebas usando la conexión `usuario_restringido`. Comprueba la conexión activa antes de ejecutar cada consulta.

### Prueba 1. Consultar la vista

Ejecuta:

```sql
SELECT *
FROM admin_udit.v_incidencias_consulta
ORDER BY id_incidencia;
```

**Resultado esperado:** cinco filas y cuatro columnas:

- `ID_INCIDENCIA`
- `ASUNTO`
- `ESTADO`
- `PRIORIDAD`

La consulta debe mostrar las incidencias sin incluir los datos de contacto.

**Evidencia 08:** captura de la consulta y sus cinco filas.

Nombre: `images/08_consulta_vista_correcta.png`

### Prueba 2. Intentar consultar el correo desde la vista

Ejecuta:

```sql
SELECT email_contacto
FROM admin_udit.v_incidencias_consulta;
```

Oracle debe rechazar la consulta porque `EMAIL_CONTACTO` no forma parte de la vista. Habitualmente aparecerá `ORA-00904`.

Este error es esperado. No significa que la columna no exista en la tabla original: significa que no está expuesta por la vista.

**Evidencia 09:** captura de la consulta y del error.

Nombre: `images/09_email_no_disponible.png`

### Prueba 3. Repetir el intento de acceso directo a la tabla

Ejecuta:

```sql
SELECT *
FROM admin_udit.incidencias_reto03;
```

Si no se han concedido permisos directos sobre la tabla, el acceso debe seguir rechazándose, habitualmente con `ORA-00942`.

**Evidencia 10:** captura del intento de acceso denegado.

Nombre: `images/10_tabla_original_denegada.png`

### Qué debes haber demostrado

Al finalizar estas pruebas, debes poder explicar que:

- El usuario restringido puede consultar la vista porque se le ha concedido `SELECT` sobre ella.
- La vista solo muestra las cuatro columnas definidas en su consulta.
- `EMAIL_CONTACTO` no puede consultarse a través de esa vista.
- La concesión sobre la vista no equivale a conceder acceso directo a la tabla original.

Si los resultados son diferentes, comprueba primero el usuario activo y el nombre del objeto. Si el problema continúa, guarda la evidencia y consulta al profesor; no cambies los permisos por tu cuenta.

---

## 12. Análisis del caso empresarial

Responde con tus propias palabras. Relaciona las respuestas con las acciones y los resultados que has observado. No basta con copiar definiciones.

### Pregunta 1. Origen de los datos

¿Qué archivo has recibido y qué pasos has seguido para incorporar sus registros a Oracle?

### Pregunta 2. Integridad de los datos

¿Cómo has comprobado que se han importado los cinco registros? ¿Por qué es importante verificar el número de filas después de una importación?

### Pregunta 3. Diseño de la vista

¿Qué cuatro columnas muestra `v_incidencias_consulta`? ¿Por qué has dejado fuera `cliente` y `email_contacto`?

### Pregunta 4. Permisos

¿Por qué `usuario_restringido` puede consultar la vista, pero no debería poder consultar directamente la tabla original?

### Pregunta 5. Interpretación de errores

¿Qué demuestra el error al intentar consultar `email_contacto` desde la vista? ¿Significa que esa columna no existe en la tabla original?

### Pregunta 6. Mínimo privilegio

¿Qué riesgos podría tener una empresa si todos los usuarios tuvieran acceso directo a todas las tablas, aunque no necesitaran todos sus datos?

### Pregunta 7. Preparación para un cambio de gestor

¿Por qué resulta útil documentar la estructura de la tabla, las columnas de la vista y los permisos antes de comparar esta solución con otra base de datos, como MySQL?

---

## 13. Entrega

Entrega un archivo ZIP con tu README cumplimentado y las capturas reales de tu trabajo.

La estructura será:

```text
Reto03_ApellidoNombre/
├── README.md
├── incidencias_soporte.csv
└── images/
    ├── 01_conexiones_y_csv.png
    ├── 02_tabla_creada.png
    ├── 03_datos_importados.png
    ├── 04_conteo_registros.png
    ├── 05_acceso_denegado_tabla.png
    ├── 06_vista_creada.png
    ├── 07_permiso_concedido.png
    ├── 08_consulta_vista_correcta.png
    ├── 09_email_no_disponible.png
    └── 10_tabla_original_denegada.png
```

El CSV debe estar incluido para que la entrega conserve el archivo de entrada utilizado. No es necesario modificarlo.

Antes de entregar:

- Comprueba que las diez evidencias están incluidas.
- Asegúrate de que las capturas son tuyas y muestran resultados reales de DBeaver.
- Comprueba que las consultas, los resultados y los errores se leen claramente.
- Responde las siete preguntas del análisis.
- Explica cualquier incidencia que te haya impedido completar una prueba.
- No inventes resultados ni sustituyas capturas reales por ejemplos.

**Nombre del archivo ZIP:** `Reto03_ApellidoNombre.zip`

---

## 14. Rúbrica de evaluación

La puntuación máxima es de **10 puntos**.

| Criterio | Puntuación |
|---|---:|
| Comprobación de las conexiones y uso correcto de los usuarios | 1 punto |
| Creación correcta de la tabla y definición de columnas | 1 punto |
| Importación del CSV y comprobación de los cinco registros | 2 puntos |
| Creación de la vista con las cuatro columnas solicitadas | 1,5 puntos |
| Concesión del permiso `SELECT` sobre la vista | 1 punto |
| Pruebas de acceso: vista disponible, correo no disponible y tabla original protegida | 1,5 puntos |
| Respuestas razonadas y relacionadas con el caso empresarial | 1 punto |
| Organización, claridad y autenticidad de las evidencias | 1 punto |
| **TOTAL** | **10 puntos** |

Se valorará tanto el resultado como la comprensión del procedimiento. Si una prueba falla por un problema del entorno, documentar el error y explicar lo sucedido es mejor que alterar permisos o inventar una captura.

---

## 15. Checklist final

- [ ] He comprobado las conexiones `admin_udit` y `usuario_restringido`.
- [ ] He examinado el archivo `incidencias_soporte.csv`.
- [ ] He creado la tabla `incidencias_reto03`.
- [ ] He importado los cinco registros con DBeaver.
- [ ] He comprobado el número de filas y los identificadores.
- [ ] He probado el acceso directo a la tabla con el usuario restringido.
- [ ] He creado `v_incidencias_consulta`.
- [ ] He concedido `SELECT` sobre la vista.
- [ ] He consultado la vista con el usuario restringido.
- [ ] He comprobado que `email_contacto` no está disponible desde la vista.
- [ ] He repetido la prueba de acceso directo a la tabla.
- [ ] He respondido las preguntas de análisis.
- [ ] He incluido las diez evidencias reales.
- [ ] He preparado el ZIP con el README, el CSV y la carpeta `images`.

## Cierre

En este reto has trabajado con un flujo habitual en una empresa: recibir datos externos, incorporarlos a una base de datos, seleccionar la información que necesita un equipo y limitar el acceso mediante permisos.

La idea principal es que **cada usuario debe disponer de los datos y privilegios necesarios para su trabajo, sin obtener acceso innecesario al resto de la información**.

La solución documentada podrá servir como base para comparar posteriormente cómo se realizan tareas equivalentes en MySQL.
