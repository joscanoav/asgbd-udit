-- 03_pruebas_por_cuenta.sql · Pruebas de permisos (MySQL 8.4)
-- Cada bloque se ejecuta con SU conexión de DBeaver. Una sentencia cada vez (Ctrl + Enter).

-- ===== Conexión: api_equipo =====
SELECT CURRENT_USER() AS cuenta, CURRENT_ROLE() AS rol_activo;                          -- rol_api activo
SELECT * FROM proyecto_udit.contenidos;                                                 -- permitido
INSERT INTO proyecto_udit.contenidos (id_contenido, titulo, tipo, ruta_repositorio)
  VALUES ('vid-9999', 'Prueba API', 'VIDEO', '/contenidos/videos/vid-9999/index.m3u8'); -- permitido
DELETE FROM proyecto_udit.contenidos WHERE id_contenido = 'vid-9999';                   -- permitido
SELECT * FROM proyecto_udit.mensajes;                                                   -- DENEGADO (error 1142)

-- ===== Conexión: chat_equipo =====
SELECT CURRENT_USER() AS cuenta, CURRENT_ROLE() AS rol_activo;                          -- rol_chat activo
INSERT INTO proyecto_udit.mensajes (emisor, receptor, texto)
  VALUES ('prueba_chat', 'prueba_chat', 'mensaje de prueba');                           -- permitido
SELECT * FROM proyecto_udit.mensajes;                                                   -- permitido
SELECT * FROM proyecto_udit.contenidos;                                                 -- DENEGADO (error 1142)

-- ===== Conexión: lector_equipo =====
SELECT CURRENT_USER() AS cuenta, CURRENT_ROLE() AS rol_activo;                          -- rol_lectura activo
SELECT * FROM proyecto_udit.contenidos;                                                 -- permitido
SELECT * FROM proyecto_udit.mensajes;                                                   -- permitido
INSERT INTO proyecto_udit.mensajes (emisor, receptor, texto)
  VALUES ('prueba_lector', 'prueba_lector', 'no debe poder');                           -- DENEGADO (error 1142)

-- ===== Conexión: admin_equipo =====
SELECT CURRENT_USER() AS cuenta, CURRENT_ROLE() AS rol_activo;                          -- rol_admin_bd activo
CREATE TABLE proyecto_udit.prueba_admin (id INT);                                       -- permitido
DROP TABLE proyecto_udit.prueba_admin;                                                  -- permitido
SELECT COUNT(*) FROM mysql.user;                                                        -- DENEGADO (error 1142)
