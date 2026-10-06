# Laboratorio Base: Operaciones Cliente-Servidor en Oracle

> **Módulo:** Administración de Sistemas Gestores de Bases de Datos (ASGBD) · ASIR
> **Tipo:** Laboratorio formativo de entrenamiento (**no evaluable**). Preparación para el Reto 2 de la semana próxima.
> **Documento:** Manual de operaciones. Se versiona en Git; los cambios se auditan por *commit*.

## Metadatos del operador

| Campo | Valor |
|---|---|
| **Alumno/a** | _Nombre y apellidos_ |
| **Usuario de GitHub** | _@usuario_ |
| **IP de la VM (Host-Only)** | `192.168.56.X` |
| **Fecha** | _dd/mm/aaaa_ |

---

## 1. Arquitectura de red

![Diagrama de arquitectura cliente-servidor](img/00_arquitectura.png)

| Rol | Equipo | Software | Red / Puerto |
|---|---|---|---|
| **Cliente** | Host físico (PC real) | DBeaver (o SQL Developer) | Adaptador Host-Only del host (`192.168.56.1`) |
| **Servidor** | Máquina virtual Windows 11 | Oracle Database 21c XE (`OracleServiceXE` + Listener) | Host-Only `192.168.56.X` · **TCP 1521** |

**Principio de operación:** un administrador no trabaja en el escritorio del servidor. El servidor se gestiona por servicios y se consulta **desde un cliente remoto**.

---

## 2. Parte 1 · Ciclo de vida del motor

> ⚠️ **ATENCIÓN:** apagar la máquina virtual sin detener antes el motor Oracle puede **corromper los ficheros de datos**. En producción el servicio siempre se detiene de forma controlada antes de tocar la máquina.

### 2.1 Localizar el servicio

En la **VM**: `Win + R` → `services.msc` → localizar **`OracleServiceXE`**.

![services.msc con OracleServiceXE en ejecución](img/01_services_msc_en_ejecucion.png)

### 2.2 Medir la RAM antes de parar

Abrir el **Administrador de tareas** (`Ctrl + Shift + Esc`) → pestaña *Rendimiento* → *Memoria*. Anotar el valor **En uso**.

![Memoria antes de detener el servicio](img/03a_task_manager_antes.png)

### 2.3 Detener el servicio

Clic derecho sobre `OracleServiceXE` → **Detener**. Equivalente por consola (PowerShell como administrador):

```powershell
Stop-Service -Name OracleServiceXE
Get-Service  -Name OracleServiceXE
```

![Servicio OracleServiceXE detenido](img/02_servicio_detenido.png)

### 2.4 Comprobar la RAM liberada

Volver al Administrador de tareas: se liberan **casi 2 GB** al instante. Es la memoria que la instancia (SGA/PGA) tenía reservada.

![Memoria tras detener el servicio](img/03b_task_manager_despues.png)

### 2.5 Volver a iniciar el servicio

Clic derecho → **Iniciar**, o por consola:

```powershell
Start-Service -Name OracleServiceXE
Get-Service  -Name OracleServiceXE
```

![Memoria tras reiniciar el servicio](img/04_servicio_reiniciado_ram.png)

---

## 3. Parte 2 · Conexión y muro de red (Troubleshooting)

### 3.1 Instalar el cliente en el PC **físico**

Descargar e instalar **DBeaver Community** desde <https://dbeaver.io/download/> en el ordenador **real** (no en la VM).

### 3.2 Verificar conectividad con la VM

Desde el **PC físico**, en PowerShell:

```powershell
ping 192.168.56.X
Test-NetConnection 192.168.56.X -Port 1521
```

![Ping y prueba del puerto 1521](img/07_ping_y_puerto.png)

| Resultado | Diagnóstico |
|---|---|
| `ping` falla | Problema de red: revisar adaptador Host-Only y la IP (`ipconfig` en la VM) |
| `ping` OK y `TcpTestSucceeded : False` | **El firewall bloquea el 1521** → ir al apartado 3.3 |
| `ping` OK y `TcpTestSucceeded : True` | Red correcta → ir al apartado 3.4 |

> 💡 El `ping` también puede estar bloqueado por el firewall de la VM. Si falla, permite el eco ICMPv4 de entrada o continúa con `Test-NetConnection`.

### 3.3 Abrir el puerto 1521 en el Firewall de Windows (en la VM)

**Vía gráfica:**

1. `Win + R` → `wf.msc` (*Firewall de Windows Defender con seguridad avanzada*).
2. **Reglas de entrada** → **Nueva regla…**
3. Tipo: **Puerto** → **TCP** → Puertos locales específicos: `1521`.
4. Acción: **Permitir la conexión**.
5. Perfil: marcar los perfiles que usa la red Host-Only (Dominio / Privado / Público).
6. Nombre: `Oracle XE Listener 1521`.

**Vía PowerShell (como administrador), equivalente:**

```powershell
New-NetFirewallRule -DisplayName "Oracle XE Listener 1521" `
  -Direction Inbound -Protocol TCP -LocalPort 1521 -Action Allow
```

![Regla de entrada TCP 1521](img/08_firewall_regla_1521.png)

Repetir `Test-NetConnection 192.168.56.X -Port 1521` hasta obtener `TcpTestSucceeded : True`.

### 3.4 Crear la conexión en DBeaver

| Parámetro | Valor |
|---|---|
| **Host** | `192.168.56.X` (IP de la VM, adaptador Host-Only) |
| **Puerto** | `1521` |
| **Service Name** | `XE` |
| **Usuario** | `SYSTEM` |
| **Contraseña** | La configurada en la sesión anterior |

![Configuración de la conexión en DBeaver](img/05_dbeaver_configuracion.png)

Pulsar **Probar conexión** y después **Finalizar**. Comprobar con un script SQL:

```sql
SELECT BANNER FROM V$VERSION;
SELECT INSTANCE_NAME, HOST_NAME, STATUS FROM V$INSTANCE;
```

![DBeaver conectado desde el PC físico](img/06_dbeaver_conectado.png)

### 3.5 Errores frecuentes

| Error | Causa probable | Solución |
|---|---|---|
| `ORA-12541: no listener` | Listener parado | Iniciar el servicio del Listener o ejecutar `lsnrctl start` |
| `ORA-12514` | *Service Name* incorrecto | Usar `XE` como **Service Name**, no como SID |
| `ORA-12560: TNS protocol adapter error` | `OracleServiceXE` detenido | Iniciarlo en `services.msc` |
| Timeout de conexión | Firewall bloqueando el 1521 | Apartado 3.3 |

---

## 4. Parte 3 · Seguridad básica: usuario de explotación

Usar el superusuario `SYSTEM` para el trabajo diario es una **negligencia grave de seguridad**: concentra el máximo privilegio y no permite trazabilidad individual. Se crea un administrador propio y `SYSTEM` queda reservado para emergencias.

En DBeaver: **Editor SQL → Nuevo script** y ejecutar:

```sql
-- Necesario en 21c XE al trabajar en el contenedor raíz (CDB$ROOT)
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;

CREATE USER admin_udit IDENTIFIED BY clave123;
GRANT DBA TO admin_udit;
GRANT CREATE SESSION TO admin_udit;

-- Verificación
SELECT USERNAME, ACCOUNT_STATUS, CREATED
  FROM DBA_USERS
 WHERE USERNAME = 'ADMIN_UDIT';
```

![Creación del usuario admin_udit](img/09_creacion_usuario_admin.png)

> 🔐 `clave123` es una contraseña **de laboratorio**. En un entorno real se usa una contraseña robusta y **nunca** se publica en un repositorio.

---

## 5. Checklist de evidencias (entrenamiento)

Este laboratorio **no se evalúa**, pero el Reto 2 sí. Practica hoy el proceso completo para dominarlo. Toma estas capturas con **tus propios datos**:

- [ ] `services.msc` con `OracleServiceXE` **detenido**
- [ ] Administrador de tareas con la **RAM liberada** tras detener el servicio
- [ ] `services.msc` con `OracleServiceXE` **iniciado de nuevo**
- [ ] `ping` y `Test-NetConnection` al puerto 1521 desde el PC físico
- [ ] **Regla de entrada** del puerto 1521 en el Firewall de Windows
- [ ] **DBeaver conectado** desde el PC físico a la IP de la VM
- [ ] Script SQL de creación de `admin_udit` ejecutado sin errores

> Guarda las capturas en `img/` y enlázalas desde este `README.md`. Haz `git commit` con un mensaje descriptivo, por ejemplo: `Lab base: conexión DBeaver y usuario admin_udit`.

---

## Estructura del repositorio

```text
Laboratorio_Base_Oracle/
├── README.md
└── img/
    ├── 00_arquitectura.png
    ├── 01_services_msc_en_ejecucion.png
    ├── 02_servicio_detenido.png
    ├── 03a_task_manager_antes.png
    ├── 03b_task_manager_despues.png
    ├── 04_servicio_reiniciado_ram.png
    ├── 05_dbeaver_configuracion.png
    ├── 06_dbeaver_conectado.png
    ├── 07_ping_y_puerto.png
    ├── 08_firewall_regla_1521.png
    └── 09_creacion_usuario_admin.png
```
