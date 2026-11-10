-- 03_pruebas_admin.sql
-- Reto 4 · Sprint 1 · MySQL 8.4
-- Ejecutar cada bloque con la conexión indicada.
-- Una sentencia cada vez (Ctrl + Enter). No ejecutar todo con una única conexión.

-- =========================================================
-- BLOQUE A · Conexión: MySQL - admin_equipo
-- Debe mostrar admin_equipo@<host que reconoce MySQL>.
-- =========================================================
SELECT CURRENT_USER() AS cuenta, VERSION() AS version;

SHOW GRANTS;

SELECT *
FROM proyecto_udit.contenidos
ORDER BY id_contenido;

-- Deben funcionar ambas sentencias: el usuario administra
-- los objetos dentro de proyecto_udit.
CREATE TABLE proyecto_udit.comprobacion_admin (
    id INT PRIMARY KEY,
    nota VARCHAR(50) NOT NULL
);

DROP TABLE proyecto_udit.comprobacion_admin;

-- Debe fallar con error 1142: no tiene acceso al esquema mysql.
SELECT COUNT(*) FROM mysql.user;


-- =========================================================
-- BLOQUE B · Conexión: MySQL - usuario_restringido
-- Esta cuenta procede del escalón y no tiene permisos sobre
-- proyecto_udit. La siguiente consulta debe fallar con 1142.
-- =========================================================
SELECT CURRENT_USER() AS cuenta;

SHOW GRANTS;

SELECT *
FROM proyecto_udit.contenidos;
