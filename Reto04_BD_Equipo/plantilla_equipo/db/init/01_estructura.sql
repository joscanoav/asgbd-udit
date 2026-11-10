-- 01_estructura.sql · Base de datos del equipo (MySQL 8.4)
-- Se ejecuta como admin_udit. Se puede repetir sin errores.
-- MODELO PROVISIONAL: se adaptará al modelo de contenidos que acuerde 2.º DAM.

CREATE DATABASE IF NOT EXISTS proyecto_udit;

CREATE TABLE IF NOT EXISTS proyecto_udit.contenidos (
  id_contenido     VARCHAR(40)  PRIMARY KEY,
  titulo           VARCHAR(120) NOT NULL,
  tipo             VARCHAR(10)  NOT NULL CHECK (tipo IN ('VIDEO','COMIC','IMAGEN','JUEGO')),
  ruta_repositorio VARCHAR(255) NOT NULL,
  fecha_alta       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS proyecto_udit.mensajes (
  id_mensaje BIGINT       AUTO_INCREMENT PRIMARY KEY,
  emisor     VARCHAR(50)  NOT NULL,
  receptor   VARCHAR(50)  NOT NULL,
  texto      VARCHAR(500) NOT NULL,
  enviado_en TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Datos de prueba ficticios (INSERT IGNORE: si ya existen, no se duplican)
INSERT IGNORE INTO proyecto_udit.contenidos (id_contenido, titulo, tipo, ruta_repositorio) VALUES
  ('vid-0001', 'Video de prueba 1',  'VIDEO',  '/contenidos/videos/vid-0001/index.m3u8'),
  ('com-0001', 'Comic de prueba 1',  'COMIC',  '/contenidos/comics/com-0001/'),
  ('img-0001', 'Imagen de prueba 1', 'IMAGEN', '/contenidos/imagenes/img-0001.jpg');
