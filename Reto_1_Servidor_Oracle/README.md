# Reto — Despliegue y Operación de un Servidor Oracle Aislado

## 1. Datos del alumno

| Campo | Información |
|---|---|
| Nombre | [Nombre y apellidos] |
| Curso | 2º ASIR |
| Módulo | 0377 · Administración de Sistemas Gestores de Bases de Datos |
| Reto | Despliegue y operación de un servidor Oracle aislado |
| Fecha | [Fecha] |

## 2. Objetivo del reto

Desplegar Oracle Database 21c XE sobre Windows 11 (VirtualBox) y operarlo como un administrador de sistemas: **desplegar, verificar, diagnosticar una caída, recuperar, habilitar acceso controlado por red y documentar**.

La máquina virtual actúa como **servidor** y el PC físico como **cliente**.

## 3. Arquitectura Cliente/Servidor

![Arquitectura cliente/servidor](img/arquitectura.png)

- **Motor**: ejecuta la base de datos.
- **Listener**: recibe las conexiones de red (TCP 1521).
- **Firewall**: decide si ese puerto es accesible desde fuera.

## 4. Snapshot previo

Antes de modificar el servidor se creó el snapshot `S1_Oracle_Previa` para poder volver atrás.

## 5. Instalación de Oracle 21c XE

`setup.exe` → botón derecho → **Ejecutar como administrador** (Oracle registra servicios y modifica el sistema).

Durante el asistente se configuraron la ruta de instalación (Oracle Home), el puerto del Listener (`TCP 1521`) y las credenciales administrativas (`SYS` / `SYSTEM`).

> Las contraseñas **no se publican** en este repositorio. Solo se documenta que fueron configuradas.

### Evidencia 1 — Servicios Oracle tras la instalación

![Evidencia 1 - Instalación](img/evidencia_01_instalacion.png)

## 6. Incidencia 1 — Caída local (ORA-12560)

Método: **observar → formular hipótesis → comprobar → solucionar → verificar**.

1. Se abre `services.msc` y se **detiene** `OracleServiceXE`.
2. Se intenta conectar con SQL*Plus y aparece `ORA-12560: TNS:protocol adapter error`.
3. Hipótesis: el servicio de la instancia no está en ejecución.
4. Comprobación: en `services.msc`, `OracleServiceXE` aparece detenido.
5. Solución: se **inicia** de nuevo el servicio.
6. Verificación: se repite la conexión con SQL*Plus y funciona.

### Evidencia 2 — Servicio detenido

![Evidencia 2 - Servicio detenido](img/evidencia_02_servicio_detenido.png)

### Evidencia 3 — Error ORA-12560

![Evidencia 3 - ORA-12560](img/evidencia_03_ora12560.png)

## 7. Incidencia 2 — El muro de red

Desde el PC físico:

```powershell
ping 192.168.56.X
Test-NetConnection 192.168.56.X -Port 1521
```

Resultado: el `ping` responde pero el puerto 1521 falla → **conectividad IP no significa disponibilidad del servicio**. Oracle funciona, pero el Firewall bloquea la entrada.

### Evidencia 4 — Ping correcto y puerto bloqueado

![Evidencia 4 - Puerto bloqueado](img/evidencia_04_puerto_bloqueado.png)

## 8. Solución — Regla de Firewall TCP 1521

No se desactiva el Firewall: se crea **una excepción concreta**.

1. Firewall de Windows Defender con seguridad avanzada.
2. Reglas de entrada → Nueva regla → Puerto.
3. TCP → puerto local específico `1521`.
4. Permitir la conexión → aplicar al perfil de red correspondiente → asignar nombre.

### Evidencia 5 — Regla de Firewall

![Evidencia 5 - Regla de Firewall](img/evidencia_05_regla_firewall.png)

### Evidencia 6 — Acceso desde el cliente funcionando

![Evidencia 6 - Puerto abierto](img/evidencia_06_puerto_abierto.png)

## 9. Snapshot final

Con la VM apagada correctamente se creó `S3_Oracle_Servidor_Red_OK`.

### Evidencia 7 — Snapshot

![Evidencia 7 - Snapshot](img/evidencia_07_snapshot.png)

## 10. Resultado del reto

- [ ] Snapshot `S1_Oracle_Previa` creado.
- [ ] Oracle 21c XE instalado como administrador.
- [ ] Credenciales configuradas (sin publicarlas).
- [ ] Servicio `OracleServiceXE` operativo.
- [ ] Incidencia ORA-12560 provocada, diagnosticada y resuelta.
- [ ] Bloqueo de red diagnosticado.
- [ ] Regla de Firewall TCP 1521 creada.
- [ ] Acceso cliente → servidor comprobado.
- [ ] Snapshot `S3_Oracle_Servidor_Red_OK` creado.
- [ ] README y evidencias subidos al repositorio.

## 11. Repositorio

[PEGAR AQUÍ EL ENLACE AL REPOSITORIO DE GITHUB]

## 12. Importante

Las imágenes incluidas inicialmente son **plantillas**. Sustitúyelas por capturas reales conservando el mismo nombre de archivo. No presentes imágenes de ejemplo como evidencias reales.
