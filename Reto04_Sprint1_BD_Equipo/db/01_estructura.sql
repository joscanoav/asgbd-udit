-- 01_estructura.sql
-- Reto 4 · Sprint 1 · MySQL 8.4
-- Ejecutar con la conexión MySQL - admin_udit.
-- Modelo provisional: se ajustará al acuerdo de integración con 2.º DAM.

CREATE DATABASE IF NOT EXISTS proyecto_udit
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS proyecto_udit.contenidos (
    id_contenido     VARCHAR(40)  NOT NULL,
    titulo           VARCHAR(120) NOT NULL,
    tipo             VARCHAR(10)  NOT NULL,
    ruta_repositorio VARCHAR(255) NOT NULL,
    fecha_alta       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_contenido),
    CONSTRAINT chk_contenidos_tipo
      CHECK (tipo IN ('VIDEO', 'COMIC', 'IMAGEN', 'JUEGO'))
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

-- Datos ficticios. INSERT IGNORE evita duplicar identificadores existentes.
INSERT IGNORE INTO proyecto_udit.contenidos
    (id_contenido, titulo, tipo, ruta_repositorio)
VALUES
    ('vid-0001', 'Video de prueba 1',  'VIDEO',  'videos/vid-0001/index.m3u8'),
    ('com-0001', 'Comic de prueba 1',  'COMIC',  'comics/com-0001/'),
    ('img-0001', 'Imagen de prueba 1', 'IMAGEN', 'imagenes/img-0001.jpg');

-- Comprobaciones de estructura y datos:
SHOW TABLES FROM proyecto_udit;

SELECT id_contenido, titulo, tipo, ruta_repositorio, fecha_alta
FROM proyecto_udit.contenidos
ORDER BY id_contenido;
