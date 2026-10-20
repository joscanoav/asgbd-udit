# Laboratorio guiado: tablas, vistas y permisos en Oracle XE

| Dato | Información |
|---|---|
| Módulo | 0377 · Administración de sistemas gestores de bases de datos |
| Ciclo | 2.º ASIR · UDIT · Curso 2026/27 |
| Tipo | Práctica guiada no evaluable |
| Duración | 3 horas |
| Entorno | El mismo entorno del Reto 2: Oracle Database 21c XE y DBeaver |
| Cuentas | `admin_udit` y `usuario_restringido`, creadas en el Reto 2 |

## Entrega de evidencias

Guarda este archivo como `README.md`. En la misma carpeta, crea una carpeta llamada `images` para guardar tus capturas de pantalla. Usa los nombres indicados en cada apartado y añade las imágenes en los espacios señalados. Las capturas deben ser tuyas y mostrar tus propios resultados de DBeaver; no uses imágenes de ejemplo ni capturas de otros estudiantes.

Estructura de entrega:

```text
Laboratorio_Oracle/
├── README.md
└── images/
    ├── 01_conexiones.png
    ├── 02_tabla_creada.png
    ├── 03_datos_insertados.png
    ├── 04_acceso_denegado_tabla.png
    ├── 05_vista_creada_y_permiso.png
    ├── 06_consulta_vista_ok.png
    ├── 07_error_email_vista.png
    ├── 08_acceso_denegado_tabla_final.png
    └── 09_sinonimo_opcional.png
```

Si una captura corresponde a una ampliación opcional que no has realizado, indícalo en el README y no inventes el resultado. Antes de entregar, comprueba que las imágenes están en `images/` y que se ven al abrir el Markdown en un visor compatible.


## 1. Objetivo

Hoy practicaremos que:
1. Una **tabla** almacena datos.
2. Una **vista** muestra solo las columnas que elegimos.
3. `GRANT SELECT` permite consultar el objeto sobre el que se concede.
4. Un usuario puede tener permiso sobre una vista y no sobre la tabla original.
5. Un **sinónimo** es un nombre alternativo: no concede permisos por sí mismo.

Hoy no crearemos usuarios nuevos, no cambiaremos el firewall ni modificaremos la configuración de Oracle.

## 2. Distribución orientativa

| Tiempo | Actividad |
|---|---|
| 0–20 min | Comprobar conexiones y explicar conceptos |
| 20–55 min | Crear una tabla con datos ficticios |
| 55–85 min | Comprobar el acceso denegado |
| 85–95 min | Descanso |
| 95–135 min | Crear una vista y conceder permiso |
| 135–155 min | Probar consultas y errores esperados |
| 155–170 min | Sinónimo privado opcional |
| 170–180 min | Repaso y dudas |

**La prioridad es entender tabla, vista y permisos.** El sinónimo es una ampliación si queda tiempo.

## 3. Antes de empezar

### 3.1 Comprueba la conexión `admin_udit`

En DBeaver, abre la conexión del Reto 2 y ejecuta:

```sql
SELECT USER AS usuario_actual,
       SYS_CONTEXT('USERENV', 'CON_NAME') AS contenedor
FROM DUAL;
```

Debe aparecer `ADMIN_UDIT` como usuario. Anota el contenedor, pero **no cambies de contenedor**.

### 3.2 Comprueba `usuario_restringido`

Abre la conexión de ese usuario y ejecuta:

```sql
SELECT USER AS usuario_actual FROM DUAL;
```

Debe aparecer `USUARIO_RESTRINGIDO`.

**Evidencia 1:** guarda una captura donde se vea que has comprobado las dos conexiones. Archivo: `images/01_conexiones.png`.

![Evidencia 1: comprobación de conexiones](images/01_conexiones.png)

Si una conexión no funciona, no cambies contraseñas ni recrees usuarios durante la práctica. Comprueba que usas la conexión del Reto 2 y pide ayuda si sigue fallando.

**En DBeaver:** ejecuta una sentencia cada vez con `Ctrl + Enter`. Comprueba qué conexión está activa antes de ejecutar cada bloque.

## 4. Parte A: crear una tabla

**Conexión: `admin_udit`.**

La tabla se creará dentro del esquema de `admin_udit`; no necesitamos crear otro usuario.

### Paso 1. Crear la tabla

```sql
CREATE TABLE suscriptores_lab (
    id_suscriptor NUMBER(4) PRIMARY KEY,
    nombre        VARCHAR2(50) NOT NULL,
    email         VARCHAR2(80),
    ciudad        VARCHAR2(30),
    tarifa        VARCHAR2(15)
);
```

Crea una tabla con cinco columnas, inicialmente vacía.

**Resultado esperado:** mensaje de creación correcta. Si aparece un error de permisos, detente y consulta al profesor. No intentes crear usuarios ni cambiar privilegios de sistema.

**Evidencia 2:** captura el mensaje de creación correcta de la tabla. Archivo: `images/02_tabla_creada.png`.

![Evidencia 2: tabla creada](images/02_tabla_creada.png)

### Paso 2. Insertar datos ficticios

Ejecuta las sentencias una a una:

```sql
INSERT INTO suscriptores_lab VALUES (1, 'Lucia Fernandez', 'lucia@example.com', 'Madrid', 'ESTANDAR');
INSERT INTO suscriptores_lab VALUES (2, 'Marcos Gil', 'marcos@example.com', 'Zaragoza', 'BASICO');
INSERT INTO suscriptores_lab VALUES (3, 'Irene Santos', 'irene@example.com', 'Valencia', 'PREMIUM');
INSERT INTO suscriptores_lab VALUES (4, 'Pablo Ramos', 'pablo@example.com', 'Sevilla', 'BASICO');
INSERT INTO suscriptores_lab VALUES (5, 'Noelia Campos', 'noelia@example.com', 'Madrid', 'PREMIUM');
COMMIT;
```

Comprueba el resultado:

```sql
SELECT * FROM suscriptores_lab;
```

**Resultado esperado:** cinco filas y cinco columnas.

**Evidencia 3:** captura la consulta con las cinco filas y las cinco columnas visibles. Archivo: `images/03_datos_insertados.png`.

![Evidencia 3: datos de la tabla](images/03_datos_insertados.png)

Si aparece un error indicando que la tabla ya existe, no la borres ni repitas los `INSERT`. Comprueba primero si la tabla ya contiene datos y consulta al profesor.

## 5. Parte B: comprobar el acceso restringido

Cambia a la conexión `usuario_restringido` y ejecuta:

```sql
SELECT * FROM admin_udit.suscriptores_lab;
```

**Resultado esperado:** normalmente `ORA-00942`. En esta prueba es esperado: el usuario restringido no debería tener permiso directo sobre la tabla.

**Evidencia 4:** captura el error al intentar consultar la tabla con `usuario_restringido`. Archivo: `images/04_acceso_denegado_tabla.png`.

![Evidencia 4: acceso denegado a la tabla](images/04_acceso_denegado_tabla.png)

Si aparecen los datos, comprueba que la conexión activa es realmente `USUARIO_RESTRINGIDO`. Si lo es, no continúes hasta que el profesor revise los permisos existentes.

## 6. Parte C: crear una vista y conceder acceso

Una **vista** es una consulta guardada con un nombre. Crearemos una que muestre cuatro columnas y oculte `email`.

### Paso 1. Crear la vista

Vuelve a la conexión `admin_udit` y ejecuta:

```sql
CREATE OR REPLACE VIEW v_suscriptores_soporte AS
SELECT id_suscriptor, nombre, ciudad, tarifa
FROM suscriptores_lab;
```

**Resultado esperado:** vista creada correctamente.

### Paso 2. Conceder permiso sobre la vista

En la misma conexión `admin_udit`, ejecuta:

```sql
GRANT SELECT ON v_suscriptores_soporte TO usuario_restringido;
```

Permite a `usuario_restringido` consultar la vista, pero no concede acceso directo a la tabla original.

**Resultado esperado:** concesión correcta. Si aparece `ORA-01031` (privilegios insuficientes), no pruebes comandos de administración al azar. Detén el paso y pide ayuda.

**Evidencia 5:** captura la creación de la vista y la concesión del permiso. Puedes hacer una captura por comando si no caben los dos resultados. Guarda la evidencia con el nombre `images/05_vista_creada_y_permiso.png`.

![Evidencia 5: vista creada y permiso concedido](images/05_vista_creada_y_permiso.png)

### Paso 3. Probar la vista

Cambia a `usuario_restringido` y ejecuta estas consultas **una a una**.

Primero:

```sql
SELECT * FROM admin_udit.v_suscriptores_soporte;
```

**Resultado esperado:** cinco filas y cuatro columnas: `ID_SUSCRIPTOR`, `NOMBRE`, `CIUDAD` y `TARIFA`.

**Evidencia 6:** captura el resultado correcto de la consulta a la vista. Archivo: `images/06_consulta_vista_ok.png`.

![Evidencia 6: consulta correcta de la vista](images/06_consulta_vista_ok.png)

Después:

```sql
SELECT email FROM admin_udit.v_suscriptores_soporte;
```

**Resultado esperado:** `ORA-00904`, porque `EMAIL` no forma parte de la vista.

**Evidencia 7:** captura el error al consultar `EMAIL` desde la vista. Archivo: `images/07_error_email_vista.png`.

![Evidencia 7: columna EMAIL no disponible en la vista](images/07_error_email_vista.png)

Por último:

```sql
SELECT * FROM admin_udit.suscriptores_lab;
```

**Resultado esperado:** `ORA-00942`, porque no se ha concedido acceso directo a la tabla.

**Evidencia 8:** captura el intento de consultar la tabla original como `usuario_restringido`. Archivo: `images/08_acceso_denegado_tabla_final.png`.

![Evidencia 8: acceso denegado a la tabla original](images/08_acceso_denegado_tabla_final.png)

### Qué has demostrado

- La vista permite ver las columnas que incluye.
- `EMAIL` no está disponible a través de esa vista.
- El usuario restringido puede consultar la vista, pero no la tabla original.

## 7. Ampliación opcional: sinónimo privado

Haz este apartado **solo si los pasos anteriores han funcionado**.

Un sinónimo es un nombre alternativo para un objeto. No es un permiso.

### Paso 1. Crear el sinónimo

Conéctate como `usuario_restringido` y ejecuta:

```sql
CREATE SYNONYM suscriptores_soporte
FOR admin_udit.v_suscriptores_soporte;
```

Si aparece `ORA-01031`, la cuenta no tiene permiso para crear sinónimos. **Sáltate esta ampliación**; no cambies privilegios para completar la práctica.

### Paso 2. Probarlo

Si se creó correctamente, ejecuta como `usuario_restringido`:

```sql
SELECT * FROM suscriptores_soporte;
```

Debe mostrar las mismas cinco filas y cuatro columnas. El sinónimo solo evita escribir el nombre completo de la vista; el acceso sigue dependiendo del permiso concedido sobre ella.

**Evidencia opcional 9:** si has podido crear y consultar el sinónimo, guarda una captura como `images/09_sinonimo_opcional.png`.

![Evidencia opcional 9: consulta mediante sinónimo](images/09_sinonimo_opcional.png)

**No crearemos un sinónimo público en esta sesión.** Lo dejamos para cuando se pueda preparar y comprobar ese paso.

## 8. Ejercicio breve

Responde con tus propias palabras:

1. ¿Qué diferencia hay entre una tabla y una vista?
2. ¿Por qué `usuario_restringido` puede consultar la vista, pero no la tabla?
3. ¿Por qué pedir `EMAIL` a la vista produce `ORA-00904`?
4. ¿Un sinónimo concede permisos? ¿Por qué?

## 9. Errores habituales

| Mensaje o situación | Qué significa / qué hacer |
|---|---|
| `ORA-00942` al consultar la tabla como `usuario_restringido` | Es esperado en la sección 5 y en la última prueba de la sección 6. |
| `ORA-00942` al consultar la vista | Comprueba el nombre y que se ejecutó el `GRANT`. Si sigue ocurriendo, detente y pide ayuda. |
| `ORA-00904` al consultar `EMAIL` en la vista | Es esperado: esa columna no está incluida. |
| `ORA-01031` al crear tabla/vista o conceder permisos | La cuenta no dispone de privilegios para ese paso. No intentes elevar privilegios; avisa al profesor. |
| `ORA-00955` al crear la tabla | Ya existe un objeto con ese nombre. No repitas los `INSERT` sin comprobar los datos. |
| La conexión no abre | Comprueba que usas la conexión del Reto 2 y que la VM y el servicio Oracle están iniciados. Si sigue fallando, pide ayuda. |

**Regla para toda la sesión:** si aparece un error no explicado aquí, copia el mensaje completo y detente. No borres objetos, no recrees cuentas y no cambies la configuración de Oracle para intentar solucionarlo.

## 10. Checklist final

- [ ] He comprobado las conexiones de `admin_udit` y `usuario_restringido`.
- [ ] He consultado la tabla con cinco filas como `admin_udit`.
- [ ] He comprobado el acceso denegado a la tabla como `usuario_restringido`.
- [ ] He creado la vista y concedido `SELECT`.
- [ ] He consultado la vista con cinco filas y cuatro columnas.
- [ ] He comprobado por qué `EMAIL` produce `ORA-00904`.
- [ ] Puedo explicar por qué un sinónimo no concede permisos.
- [ ] No he modificado usuarios, contraseñas ni configuración del servidor.

## Cierre

La idea principal es que **los permisos se conceden sobre los objetos**. Una vista puede ofrecer acceso limitado a determinados datos mientras la tabla original permanece protegida.

En el Reto 3 aplicarás los conceptos que correspondan según su enunciado oficial. Este laboratorio sirve para practicar los fundamentos, no para sustituir el reto.
