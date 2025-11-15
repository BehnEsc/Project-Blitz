-- Creación de la base de datos y uso de la misma.
CREATE DATABASE IF NOT EXISTS Project;
USE Project;

-- ====================================
-- TABLAS PRINCIPALES
-- ====================================

-- Tabla de Usuarios.
-- Cada usuario contiene su identificador único, nombre de usuario que se utiliza como "login", correo electrónico y atributos de seguridad y rol.
CREATE TABLE Usuarios (
    IdUsuario INT PRIMARY KEY AUTO_INCREMENT,
    NombreUsuario VARCHAR(16) UNIQUE NOT NULL,
    Correo VARCHAR(64) NOT NULL,
    HashContraseña VARCHAR(128) NOT NULL,
    FechaRegistro DATETIME NOT NULL,
    EstadoCuenta VARCHAR(20) NOT NULL,
    TipoUsuario VARCHAR(20) NOT NULL,
    PreferenciasPrivacidad VARCHAR(20) NOT NULL
);

-- Tabla de Perfil (relación 1:1 con Usuarios; IdPerfil = IdUsuario).
-- La información del perfil puede contener foto, biografía y enlaces, es opcional respecto a la existencia de un Usuario.
CREATE TABLE Perfil (
    IdPerfil INT PRIMARY KEY,
    FotoPerfil VARCHAR(256),
    Biografia VARCHAR(512),
    EnlacesSociales VARCHAR(256),
    EnlacePersonal VARCHAR(256),
    FOREIGN KEY (IdPerfil) REFERENCES Usuarios(IdUsuario)
);

-- Tabla de Contenido (relación 1:N con Usuarios).
-- Un usuario (creador) puede crear varios contenidos.
CREATE TABLE Contenido (
    IdContenido INT PRIMARY KEY AUTO_INCREMENT,
    IdAutor INT NOT NULL,
    Titulo VARCHAR(64) NOT NULL,
    Descripcion VARCHAR(2048),
    TipoContenido VARCHAR(32),
    UrlContenido VARCHAR(256) NOT NULL,
    FechaCreacion DATETIME NOT NULL,
    EstadoContenido VARCHAR(20) NOT NULL,
    FOREIGN KEY (IdAutor) REFERENCES Usuarios(IdUsuario)
);

-- Tabla de Suscripcion (relación N:1, doble relación a Usuarios).
-- Permite gestionar suscriptores y creadores, incluyendo la información del pago.
CREATE TABLE Suscripcion (
    IdSuscripcion INT PRIMARY KEY AUTO_INCREMENT,
    IdSuscriptor INT NOT NULL,
    IdCreador INT NOT NULL,
    Monto DECIMAL(10,2) NOT NULL,
    FechaPago DATETIME NOT NULL,    
    EstadoPago VARCHAR(20) NOT NULL,
    FOREIGN KEY (IdSuscriptor) REFERENCES Usuarios(IdUsuario),
    FOREIGN KEY (IdCreador) REFERENCES Usuarios(IdUsuario)
); 

-- Tabla de Pago (relación N:1, doble relación a Usuarios).
-- Registra los pagos realizados entre usuarios, permitiendo diferentes métodos y emisor.
CREATE TABLE Pago (
    IdPago INT PRIMARY KEY AUTO_INCREMENT,
    IdPagador INT NOT NULL,
    IdReceptor INT NOT NULL,
    Monto DECIMAL(10,2) NOT NULL,
    FechaPago DATETIME NOT NULL,
    EstadoPago VARCHAR(20) NOT NULL,
    MetodoPago VARCHAR(32) NOT NULL,
    IdEmisor INT,
    FOREIGN KEY (IdPagador) REFERENCES Usuarios(IdUsuario),
    FOREIGN KEY (IdReceptor) REFERENCES Usuarios(IdUsuario)
);

-- Tabla de Mensaje (relación N:1, doble relación a Usuarios).
-- Maneja el sistema de mensajería entre usuarios, permitiendo mensajes bidireccionales.
CREATE TABLE Mensaje (
    IdMensaje INT PRIMARY KEY AUTO_INCREMENT,
    IdEmisor INT NOT NULL,
    IdReceptor INT NOT NULL,
    ContenidoMensaje VARCHAR(1024) NOT NULL,
    FechaMensaje DATETIME NOT NULL,
    EstadoMensaje VARCHAR(20) NOT NULL,
    FOREIGN KEY (IdEmisor) REFERENCES Usuarios(IdUsuario),
    FOREIGN KEY (IdReceptor) REFERENCES Usuarios(IdUsuario)
);

-- ====================================
-- VISTAS Y FUNCIONES PARA ROLES Y PERMISOS
-- ====================================

-- Vista Roles: mapea el tipo de usuario a su rol funcional dentro del sistema.
CREATE OR REPLACE VIEW Roles AS
SELECT
    IdUsuario,
    NombreUsuario,
    TipoUsuario,
    CASE
        WHEN TipoUsuario = 'Creador' THEN 'creador de contenido'
        WHEN TipoUsuario = 'Suscriptor' THEN 'cliente'
        ELSE 'administrador'
    END AS Rol
FROM Usuarios;

-- RolePermissions: define los permisos asociados a cada rol.
CREATE OR REPLACE VIEW RolePermissions AS
SELECT 'cliente' AS Rol,
       1 AS can_view_content,
       0 AS can_create_content,
       0 AS can_manage_users,
       0 AS can_manage_site,
       1 AS can_pay,
       1 AS can_message
UNION ALL
SELECT 'creador de contenido',
       1,
       1,
       0,
       0,
       1,
       1
UNION ALL
SELECT 'administrador',
       1,
       1,
       1,
       1,
       1,
       1;

-- UserPermissions: combina cada usuario con los permisos correspondientes a su rol.
CREATE OR REPLACE VIEW UserPermissions AS
SELECT R.IdUsuario,
       R.NombreUsuario,
       R.TipoUsuario,
       RP.Rol,
       RP.can_view_content,
       RP.can_create_content,
       RP.can_manage_users,
       RP.can_manage_site,
       RP.can_pay,
       RP.can_message
FROM Roles R
LEFT JOIN RolePermissions RP ON R.Rol = RP.Rol;

-- Función HasPermission(userId, permisoClave): devuelve 1 si el usuario tiene el permiso solicitado para la clave, 0 en caso contrario.
-- Permisos válidos: 'view','create','manage_users','manage_site','pay','message'
DELIMITER //
CREATE FUNCTION HasPermission(pUserId INT, pPerm VARCHAR(64))
RETURNS TINYINT(1)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_result TINYINT(1) DEFAULT 0;
    SELECT
      CASE pPerm
        WHEN 'view' THEN UP.can_view_content
        WHEN 'create' THEN UP.can_create_content
        WHEN 'manage_users' THEN UP.can_manage_users
        WHEN 'manage_site' THEN UP.can_manage_site
        WHEN 'pay' THEN UP.can_pay
        WHEN 'message' THEN UP.can_message
        ELSE 0
      END
    INTO v_result
    FROM UserPermissions UP
    WHERE UP.IdUsuario = pUserId
    LIMIT 1;

    RETURN IFNULL(v_result, 0);
END//
DELIMITER ;

-- =========================================
-- PROCEDIMIENTOS, TRIGGERS Y EVENTOS UTILES
-- =========================================

DELIMITER //

-- Procedimiento almacenado para dar de baja lógica a un usuario (no borrado físico).
-- Cambia el estado de la cuenta a 'Inactivo'. Puede auditarse en una tabla de auditorías si se desea registrar motivos.
CREATE PROCEDURE DeactivateUser(IN pUserId INT, IN pReason VARCHAR(512))
BEGIN
    UPDATE Usuarios
    SET EstadoCuenta = 'Inactivo'
    WHERE IdUsuario = pUserId;
    -- Registro de la baja puede implementarse en tabla de auditoría separada, si se requiere para histórico.
END//

-- Trigger preventivo para evitar el borrado físico de usuarios.
-- Se exige la baja lógica por procedimiento almacenado.
CREATE TRIGGER Usuarios_prevent_delete
BEFORE DELETE ON Usuarios
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'DELETE no permitido en Usuarios. Use CALL DeactivateUser(id, motivo) para desactivar la cuenta.';
END//

-- Evento para caducar suscripciones pagadas hace más de un año.
-- Debe estar habilitado el scheduler de eventos (SET GLOBAL event_scheduler = ON).
CREATE EVENT IF NOT EXISTS ExpireOldSubscriptions
ON SCHEDULE EVERY 1 DAY
DO
  UPDATE Suscripcion
  SET EstadoPago = 'Expirado'
  WHERE EstadoPago = 'Pagado'
    AND FechaPago < DATE_SUB(NOW(), INTERVAL 1 YEAR);

DELIMITER ;

-- ====================================
-- DATOS DE PRUEBA (INSERTS)
-- ====================================

-- Ejemplo de alta de usuarios, perfiles, contenidos, suscripciones, pagos y mensajes.

-- Usuarios base de prueba (20 registros).
INSERT INTO Usuarios (NombreUsuario, Correo, HashContraseña, FechaRegistro, EstadoCuenta, TipoUsuario, PreferenciasPrivacidad) VALUES 
('Alice', 'alice@email.com', SHA2('passA', 256), '2025-09-01', 'Activo', 'Creador', 'Privado'),
('Bob', 'bob@email.com', SHA2('passB', 256), '2025-09-02', 'Activo', 'Suscriptor', 'Publico'),
('Carla', 'carla@email.com', SHA2('passC', 256), '2025-09-03', 'Activo', 'Creador', 'Privado'),
('Daniel', 'daniel@email.com', SHA2('passD', 256), '2025-09-04', 'Suspendido', 'Suscriptor', 'Privado'),
('Eva', 'eva@email.com', SHA2('passE', 256), '2025-09-05', 'Activo', 'Creador', 'Publico'),
('Frank', 'frank@email.com', SHA2('passF', 256), '2025-09-06', 'Activo', 'Suscriptor', 'Privado'),
('Gina', 'gina@email.com', SHA2('passG', 256), '2025-09-07', 'Activo', 'Creador', 'Privado'),
('Hector', 'hector@email.com', SHA2('passH', 256), '2025-09-08', 'Activo', 'Suscriptor', 'Publico'),
('Irene', 'irene@email.com', SHA2('passI', 256), '2025-09-09', 'Activo', 'Creador', 'Privado'),
('Juan', 'juan@email.com', SHA2('passJ', 256), '2025-09-10', 'Activo', 'Suscriptor', 'Privado'),
('Karla', 'karla@email.com', SHA2('passK', 256), '2025-09-11', 'Activo', 'Creador', 'Publico'),
('Luis', 'luis@email.com', SHA2('passL', 256), '2025-09-12', 'Activo', 'Suscriptor', 'Privado'),
('Marina', 'marina@email.com', SHA2('passM', 256), '2025-09-13', 'Activo', 'Creador', 'Privado'),
('Nicolas', 'nicolas@email.com', SHA2('passN', 256), '2025-09-14', 'Activo', 'Suscriptor', 'Publico'),
('Olga', 'olga@email.com', SHA2('passO', 256), '2025-09-15', 'Activo', 'Creador', 'Privado'),
('Pablo', 'pablo@email.com', SHA2('passP', 256), '2025-09-16', 'Activo', 'Suscriptor', 'Privado'),
('Quique', 'quique@email.com', SHA2('passQ', 256), '2025-09-17', 'Activo', 'Creador', 'Publico'),
('Rosa', 'rosa@email.com', SHA2('passR', 256), '2025-09-18', 'Activo', 'Suscriptor', 'Privado'),
('Samuel', 'samuel@email.com', SHA2('passS', 256), '2025-09-19', 'Activo', 'Creador', 'Privado'),
('Tania', 'tania@email.com', SHA2('passT', 256), '2025-09-20', 'Activo', 'Suscriptor', 'Publico');

-- Perfiles asociados.
INSERT INTO Perfil (IdPerfil, FotoPerfil, Biografia, EnlacesSociales, EnlacePersonal) VALUES
(1, 'alice.jpg', 'Fotógrafa profesional', 'https://instagram.com/alice', 'https://alice.com'),
(2, 'bob.jpg', 'Amante de la tecnología', 'https://twitter.com/bob', NULL),
(3, 'carla.jpg', 'Escritora y bloguera', 'https://facebook.com/carla', 'https://carla.com'),
(4, 'daniel.jpg', 'Fan de los videojuegos', NULL, NULL),
(5, 'eva.jpg', 'Creadora de contenido fitness', 'https://instagram.com/eva', 'https://eva.com'),
(6, 'frank.jpg', 'Músico aficionado', 'https://soundcloud.com/frank', NULL),
(7, 'gina.jpg', 'Chef y repostera', 'https://youtube.com/gina', 'https://gina.com'),
(8, 'hector.jpg', 'Estudiante de ingeniería', NULL, NULL),
(9, 'irene.jpg', 'Diseñadora gráfica', 'https://behance.net/irene', 'https://irene.com'),
(10, 'juan.jpg', 'Coleccionista de cómics', NULL, NULL),
(11, 'karla.jpg', 'Streamer de videojuegos', 'https://twitch.tv/karla', 'https://karla.com'),
(12, 'luis.jpg', 'Creador de podcasts', 'https://spotify.com/luis', NULL),
(13, 'marina.jpg', 'Artista digital', 'https://deviantart.com/marina', 'https://marina.com'),
(14, 'nicolas.jpg', 'Fotógrafo amateur', NULL, NULL),
(15, 'olga.jpg', 'Creadora de tutoriales', 'https://youtube.com/olga', 'https://olga.com'),
(16, 'pablo.jpg', 'Fan de la ciencia ficción', NULL, NULL),
(17, 'quique.jpg', 'Creador de memes', 'https://twitter.com/quique', 'https://quique.com'),
(18, 'rosa.jpg', 'Estudiante de medicina', NULL, NULL),
(19, 'samuel.jpg', 'Creador de contenido educativo', 'https://youtube.com/samuel', 'https://samuel.com'),
(20, 'tania.jpg', 'Amante de los animales', NULL, NULL);

-- Ejemplo de contenidos.
INSERT INTO Contenido (IdAutor, Titulo, Descripcion, TipoContenido, UrlContenido, FechaCreacion, EstadoContenido) VALUES
(1, 'Fotografía de paisaje', 'Paisaje natural al amanecer', 'Imagen', 'https://alice.com/paisaje', '2025-09-01', 'Publicado'),
(3, 'Artículo sobre escritura', 'Consejos para escritores', 'Artículo', 'https://carla.com/escritura', '2025-09-03', 'Publicado'),
(5, 'Rutina de ejercicios', 'Entrenamiento para principiantes', 'Video', 'https://eva.com/ejercicio', '2025-09-05', 'Publicado'),
(7, 'Receta de pastel', 'Cómo hacer pastel de chocolate', 'Video', 'https://gina.com/pastel', '2025-09-07', 'Publicado'),
(9, 'Diseño de logo', 'Logo para empresa ficticia', 'Imagen', 'https://irene.com/logo', '2025-09-09', 'Publicado'),
(11, 'Stream de juego', 'Jugando Minecraft en vivo', 'Video', 'https://karla.com/minecraft', '2025-09-11', 'Publicado'),
(13, 'Ilustración digital', 'Arte conceptual', 'Imagen', 'https://marina.com/arte', '2025-09-13', 'Publicado'),
(15, 'Tutorial de Excel', 'Cómo usar fórmulas', 'Video', 'https://olga.com/excel', '2025-09-15', 'Publicado'),
(17, 'Meme viral', 'Meme sobre exámenes', 'Imagen', 'https://quique.com/meme', '2025-09-17', 'Publicado'),
(19, 'Video educativo', 'Historia de México', 'Video', 'https://samuel.com/historia', '2025-09-19', 'Publicado'),
(1, 'Retrato artístico', 'Retrato en blanco y negro', 'Imagen', 'https://alice.com/retrato', '2025-09-02', 'Publicado'),
(5, 'Consejos de nutrición', 'Alimentación saludable', 'Artículo', 'https://eva.com/nutricion', '2025-09-06', 'Publicado'),
(7, 'Receta de galletas', 'Galletas de avena', 'Video', 'https://gina.com/galletas', '2025-09-08', 'Publicado'),
(11, 'Stream de Fortnite', 'Jugando Fortnite en vivo', 'Video', 'https://karla.com/fortnite', '2025-09-12', 'Publicado'),
(13, 'Animación digital', 'Animación de personaje', 'Video', 'https://marina.com/animacion', '2025-09-14', 'Publicado');

-- Ejemplo de suscripciones.
INSERT INTO Suscripcion (IdSuscriptor, IdCreador, Monto, FechaPago, EstadoPago) VALUES
(2, 1, 50.00, '2025-09-02', 'Pagado'),
(4, 3, 30.00, '2025-09-04', 'Pagado'),
(6, 5, 40.00, '2025-09-06', 'Pagado'),
(8, 7, 25.00, '2025-09-08', 'Pagado'),
(10, 9, 35.00, '2025-09-10', 'Pagado'),
(12, 11, 45.00, '2025-09-12', 'Pagado'),
(14, 13, 55.00, '2025-09-14', 'Pagado'),
(16, 15, 60.00, '2025-09-16', 'Pagado'),
(18, 17, 20.00, '2025-09-18', 'Pagado'),
(20, 19, 70.00, '2025-09-20', 'Pagado');

-- Ejemplo de pagos.
INSERT INTO Pago (IdPagador, IdReceptor, Monto, FechaPago, EstadoPago, MetodoPago, IdEmisor) VALUES
(2, 1, 50.00, '2025-09-02', 'Completado', 'Tarjeta', 2),
(4, 3, 30.00, '2025-09-04', 'Completado', 'Paypal', 4),
(6, 5, 40.00, '2025-09-06', 'Completado', 'Tarjeta', 6),
(8, 7, 25.00, '2025-09-08', 'Completado', 'Paypal', 8),
(10, 9, 35.00, '2025-09-10', 'Completado', 'Tarjeta', 10),
(12, 11, 45.00, '2025-09-12', 'Completado', 'Paypal', 12),
(14, 13, 55.00, '2025-09-14', 'Completado', 'Tarjeta', 14),
(16, 15, 60.00, '2025-09-16', 'Completado', 'Paypal', 16),
(18, 17, 20.00, '2025-09-18', 'Completado', 'Tarjeta', 18),
(20, 19, 70.00, '2025-09-20', 'Completado', 'Paypal', 20);

-- Ejemplo de mensajes privados.
INSERT INTO Mensaje (IdEmisor, IdReceptor, ContenidoMensaje, FechaMensaje, EstadoMensaje) VALUES
(2, 1, 'Hola Alice, me gusta tu trabajo!', '2025-09-02 10:00', 'Leido'),
(4, 3, 'Carla, ¿cuándo publicas nuevo artículo?', '2025-09-04 11:00', 'Leido'),
(6, 5, 'Eva, ¿tienes rutinas para principiantes?', '2025-09-06 12:00', 'Leido'),
(8, 7, 'Gina, tu receta fue un éxito!', '2025-09-08 13:00', 'Leido'),
(10, 9, 'Irene, ¿aceptas encargos?', '2025-09-10 14:00', 'Leido'),
(12, 11, 'Karla, ¿harás stream hoy?', '2025-09-12 15:00', 'Leido'),
(14, 13, 'Marina, tu arte es genial!', '2025-09-14 16:00', 'Leido'),
(16, 15, 'Olga, ¿más tutoriales pronto?', '2025-09-16 17:00', 'Leido'),
(18, 17, 'Quique, tus memes son los mejores!', '2025-09-18 18:00', 'Leido'),
(20, 19, 'Samuel, ¿qué tema será el próximo video?', '2025-09-20 19:00', 'Leido'),
(1, 2, 'Gracias por tu apoyo, Bob!', '2025-09-02 20:00', 'Leido'),
(3, 4, '¡Pronto publicaré más!', '2025-09-04 21:00', 'Leido'),
(5, 6, 'Sí, tengo rutinas para todos.', '2025-09-06 22:00', 'Leido'),
(7, 8, 'Me alegra que te gustara!', '2025-09-08 23:00', 'Leido'),
(9, 10, 'Claro, mándame detalles.', '2025-09-10 09:00', 'Leido'),
(11, 12, 'Sí, a las 8pm!', '2025-09-12 08:00', 'Leido'),
(13, 14, '¡Gracias por tu comentario!', '2025-09-14 07:00', 'Leido'),
(15, 16, 'Sí, pronto más tutoriales.', '2025-09-16 06:00', 'Leido'),
(17, 18, '¡Gracias por seguirme!', '2025-09-18 05:00', 'Leido'),
(19, 20, 'Será sobre historia universal.', '2025-09-20 04:00', 'Leido');

-- Consultas rápidas de todas las tablas principales.
SELECT * FROM Usuarios;
SELECT * FROM Perfil;
SELECT * FROM Contenido;
SELECT * FROM Suscripcion;
SELECT * FROM Pago;
SELECT * FROM Mensaje;