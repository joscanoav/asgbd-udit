# Reto 1 — Preparación de la infraestructura Oracle

## 1. Datos del alumno

| Campo | Información |
|---|---|
| Nombre | **[Nombre y apellidos]** |
| Curso | 2º ASIR |
| Módulo | Administración de Sistemas Gestores de Bases de Datos |
| Reto | Reto 1 — Infraestructura |
| Fecha | **[Fecha]** |

## 2. Objetivo del reto

Preparar y validar la infraestructura necesaria para trabajar posteriormente con Oracle Database.

Antes de instalar y administrar el SGBD, se comprueba que la máquina virtual dispone de recursos suficientes, que existe conectividad entre el equipo físico y la máquina virtual y que se puede recuperar el estado inicial mediante un snapshot.

## 3. Configuración de la máquina virtual

- CPU: **2 núcleos**
- RAM: **4–8 GB**
- Disco: **Dinámico**
- Sistema operativo: **Windows 11**

### Evidencia 1 — Recursos de VirtualBox

![Evidencia 1 - Recursos de VirtualBox](img/01_recursos_virtualbox.png)

> Sustituye esta imagen por la captura real de tu propia máquina virtual.

## 4. Configuración de red

- **Adaptador 1 — NAT:** salida a Internet.
- **Adaptador 2 — Host-Only:** comunicación aislada entre el equipo físico y la máquina virtual.

### Evidencia 2 — Configuración de red

![Evidencia 2 - Configuración NAT y Host-Only](img/02_red_nat_hostonly.png)

> Sustituye esta imagen por la captura real de tu configuración.

## 5. Comprobación de conectividad

Comando utilizado:

```cmd
ipconfig
```

Dirección IP de la máquina virtual:

```text
[Escribir aquí la IP obtenida]
```

### Evidencia 3 — IP mediante ipconfig

![Evidencia 3 - IP mediante ipconfig](img/03_ipconfig.png)

## 6. Prueba de conectividad

Desde el ordenador físico:

```cmd
ping [IP_DE_LA_VM]
```

Resultado:

```text
[Indicar el resultado]
```

### Evidencia 4 — Ping PC físico → VM

![Evidencia 4 - Prueba de conectividad](img/04_ping.png)

## 7. Firewall

Se ha comprobado que el Firewall de Windows puede impedir las comunicaciones ICMP necesarias para el ping. Se ha realizado la configuración necesaria y se ha vuelto a comprobar la conectividad.

## 8. Preparación de los archivos de Oracle

Los archivos proporcionados para el reto se han preparado en:

```text
C:\
```

## 9. Snapshot de seguridad

Con la máquina virtual apagada se ha creado:

```text
Previo Oracle
```

### Evidencia 5 — Snapshot

![Evidencia 5 - Snapshot](img/05_snapshot.png)

## 10. Resultado del reto

- [ ] Máquina virtual creada.
- [ ] 2 núcleos de CPU configurados.
- [ ] 4–8 GB de RAM configurados.
- [ ] Disco virtual configurado.
- [ ] NAT configurado.
- [ ] Host-Only configurado.
- [ ] IP comprobada.
- [ ] Ping PC físico → VM comprobado.
- [ ] Archivos de Oracle preparados.
- [ ] Snapshot **Previo Oracle** creado.
- [ ] Evidencias incorporadas al repositorio.

## 11. Repositorio

Repositorio:

**[PEGAR AQUÍ EL ENLACE AL REPOSITORIO DE GITHUB]**

## 12. Importante

Las imágenes incluidas inicialmente en este paquete son **plantillas/tutoriales visuales**. Deben sustituirse por capturas reales obtenidas durante el reto en la propia máquina virtual del alumno.

No se deben presentar imágenes de ejemplo como evidencias reales.
