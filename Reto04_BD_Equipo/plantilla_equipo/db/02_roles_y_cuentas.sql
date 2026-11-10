-- 02_roles_y_cuentas.sql · Roles y cuentas por función (MySQL 8.4)
-- Se ejecuta como admin_udit DESPUÉS de 01_estructura.sql.
-- IMPORTANTE: sustituye los marcadores [SUSTITUIR_...] solo en TU copia local.
-- En GitHub se sube SIEMPRE con los marcadores, nunca con contraseñas reales.

-- 1) Un rol por función
CREATE ROLE IF NOT EXISTS 'rol_api', 'rol_chat', 'rol_lectura', 'rol_admin_bd';

-- 2) Privilegios de cada rol: solo lo necesario
GRANT SELECT, INSERT, UPDATE, DELETE ON proyecto_udit.contenidos TO 'rol_api';
GRANT SELECT, INSERT ON proyecto_udit.mensajes TO 'rol_chat';
GRANT SELECT ON proyecto_udit.* TO 'rol_lectura';
GRANT ALL PRIVILEGES ON proyecto_udit.* TO 'rol_admin_bd';

-- 3) Una cuenta por función
CREATE USER IF NOT EXISTS 'api_equipo'@'%'    IDENTIFIED BY '[SUSTITUIR_CONTRASEÑA_API]';
CREATE USER IF NOT EXISTS 'chat_equipo'@'%'   IDENTIFIED BY '[SUSTITUIR_CONTRASEÑA_CHAT]';
CREATE USER IF NOT EXISTS 'lector_equipo'@'%' IDENTIFIED BY '[SUSTITUIR_CONTRASEÑA_LECTOR]';
CREATE USER IF NOT EXISTS 'admin_equipo'@'%'  IDENTIFIED BY '[SUSTITUIR_CONTRASEÑA_ADMIN]';

-- 4) Asignar cada rol a su cuenta
GRANT 'rol_api'       TO 'api_equipo'@'%';
GRANT 'rol_chat'      TO 'chat_equipo'@'%';
GRANT 'rol_lectura'   TO 'lector_equipo'@'%';
GRANT 'rol_admin_bd'  TO 'admin_equipo'@'%';

-- 5) Activar el rol al iniciar sesión (sin esto, la cuenta entra sin permisos)
SET DEFAULT ROLE 'rol_api'      TO 'api_equipo'@'%';
SET DEFAULT ROLE 'rol_chat'     TO 'chat_equipo'@'%';
SET DEFAULT ROLE 'rol_lectura'  TO 'lector_equipo'@'%';
SET DEFAULT ROLE 'rol_admin_bd' TO 'admin_equipo'@'%';

-- 6) Comprobar los privilegios de una cuenta a través de su rol
SHOW GRANTS FOR 'api_equipo'@'%' USING 'rol_api';
