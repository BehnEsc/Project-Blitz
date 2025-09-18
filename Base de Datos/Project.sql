-- Creación de la base de datos.
CREATE DATABASE IF NOT EXISTS Project;
USE Project;

-- Creación de las tablas.
CREATE TABLE Usuarios (
    IdUsuario INT PRIMARY KEY AUTO_INCREMENT,
    NombreUsuario NVARCHAR(16) UNIQUE NOT NULL,
    Correo NVARCHAR(64) NOT NULL,
    HashContraseña NVARCHAR(128) NOT NULL,
    FechaRegistro DATETIME NOT NULL,
    EstadoCuenta NVARCHAR(20) NOT NULL,
    TipoUsuario NVARCHAR(20) NOT NULL,
    PreferenciasPrivacidad NVARCHAR(20) NOT NULL
);

CREATE TABLE Perfil (
    IdPerfil INT PRIMARY KEY AUTO_INCREMENT,
    IdUsuario INT NOT NULL,
    FotoPerfil NVARCHAR(256),
    Biografia NVARCHAR(512),
    EnlacesSociales NVARCHAR(256),
    EnlacePersonal NVARCHAR(256),
    FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario)
);

CREATE TABLE Contenido (
    IdContenido INT PRIMARY KEY AUTO_INCREMENT,
    IdAutor INT NOT NULL,
    Título NVARCHAR (64) NOT NULL,
    Descripción NVARCHAR (2048),
    TipoContenido NVARCHAR (32),
    UrlContenido NVARCHAR (256) NOT NULL,
    FechaCreación DATETIME NOT NULL,
    EstadoContenido NVARCHAR (20) NOT NULL,
    FOREIGN KEY (IdAutor) REFERENCES Usuarios(IdUsuario)
);

CREATE TABLE Suscripción (
    IdSuscripción INT PRIMARY KEY AUTO_INCREMENT,
    IdSuscriptor INT NOT NULL,
    IdCreador INT NOT NULL,
    Monto DECIMAL(10,2) NOT NULL,
    FechaPago DATETIME NOT NULL,    
    EstadoPago NVARCHAR(20) NOT NULL,
    FOREIGN KEY (IdSuscriptor) REFERENCES Usuarios(IdUsuario),
    FOREIGN KEY (IdCreador) REFERENCES Usuarios(IdUsuario)  

); 

CREATE TABLE Pago (
    IdPago INT PRIMARY KEY AUTO_INCREMENT,
    IdPagador INT NOT NULL,
    IdReceptor INT NOT NULL,
    Monto DECIMAL(10,2) NOT NULL,
    FechaPago DATETIME NOT NULL,
    EstadoPago NVARCHAR(20) NOT NULL,
    MetodoPago NVARCHAR(32) NOT NULL,
    IdEmisor INT,
    FOREIGN KEY (IdPagador) REFERENCES Usuarios(IdUsuario),
    FOREIGN KEY (IdReceptor) REFERENCES Usuarios(IdUsuario)
);

CREATE TABLE Mensaje (
    IdMensaje INT PRIMARY KEY AUTO_INCREMENT,
    IdEmisor INT NOT NULL,
    IdReceptor INT NOT NULL,
    ContenidoMensaje NVARCHAR(1024) NOT NULL,
    FechaMensaje DATETIME NOT NULL,
    EstadoMensaje NVARCHAR(20) NOT NULL,
    FOREIGN KEY (IdEmisor) REFERENCES Usuarios(IdUsuario),
    FOREIGN KEY (IdReceptor) REFERENCES Usuarios(IdUsuario)
);

CREATE TABLE Consentimiento (
    IdConsentimiento INT PRIMARY KEY AUTO_INCREMENT,
    IdUsuario INT NOT NULL,
    TipoConsentimiento NVARCHAR(64) NOT NULL,
    FechaConsentimiento DATETIME NOT NULL,
    DetallesConsentimiento NVARCHAR(512),
    EstadoConsentimiento NVARCHAR(20) NOT NULL,
    FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario)
);

-- Consultas a las tablas.
SELECT * FROM Usuarios;
SELECT * FROM Perfil;
SELECT * FROM Contenido;
SELECT * FROM Suscripción;
SELECT * FROM Pago;
SELECT * FROM Mensaje;
SELECT * FROM Consentimiento;

-- Creación de los datos de pruebas.

-- Usuarios (20 registros, más atributos variados)
INSERT INTO Usuarios (NombreUsuario, Correo, HashContraseña, FechaRegistro, EstadoCuenta, TipoUsuario, PreferenciasPrivacidad)
VALUES 
('Alice', 'alice@email.com', SHA2('passA', 256), '2025-09-01', 'Activo', 'Creador', 'Privado'),
('Bob', 'bob@email.com', SHA2('passB', 256), '2025-09-02', 'Activo', 'Suscriptor', 'Público'),
('Carla', 'carla@email.com', SHA2('passC', 256), '2025-09-03', 'Activo', 'Creador', 'Privado'),
('Daniel', 'daniel@email.com', SHA2('passD', 256), '2025-09-04', 'Suspendido', 'Suscriptor', 'Privado'),
('Eva', 'eva@email.com', SHA2('passE', 256), '2025-09-05', 'Activo', 'Creador', 'Público'),
('Frank', 'frank@email.com', SHA2('passF', 256), '2025-09-06', 'Activo', 'Suscriptor', 'Privado'),
('Gina', 'gina@email.com', SHA2('passG', 256), '2025-09-07', 'Activo', 'Creador', 'Privado'),
('Hector', 'hector@email.com', SHA2('passH', 256), '2025-09-08', 'Activo', 'Suscriptor', 'Público'),
('Irene', 'irene@email.com', SHA2('passI', 256), '2025-09-09', 'Activo', 'Creador', 'Privado'),
('Juan', 'juan@email.com', SHA2('passJ', 256), '2025-09-10', 'Activo', 'Suscriptor', 'Privado'),
('Karla', 'karla@email.com', SHA2('passK', 256), '2025-09-11', 'Activo', 'Creador', 'Público'),
('Luis', 'luis@email.com', SHA2('passL', 256), '2025-09-12', 'Activo', 'Suscriptor', 'Privado'),
('Marina', 'marina@email.com', SHA2('passM', 256), '2025-09-13', 'Activo', 'Creador', 'Privado'),
('Nicolas', 'nicolas@email.com', SHA2('passN', 256), '2025-09-14', 'Activo', 'Suscriptor', 'Público'),
('Olga', 'olga@email.com', SHA2('passO', 256), '2025-09-15', 'Activo', 'Creador', 'Privado'),
('Pablo', 'pablo@email.com', SHA2('passP', 256), '2025-09-16', 'Activo', 'Suscriptor', 'Privado'),
('Quique', 'quique@email.com', SHA2('passQ', 256), '2025-09-17', 'Activo', 'Creador', 'Público'),
('Rosa', 'rosa@email.com', SHA2('passR', 256), '2025-09-18', 'Activo', 'Suscriptor', 'Privado'),
('Samuel', 'samuel@email.com', SHA2('passS', 256), '2025-09-19', 'Activo', 'Creador', 'Privado'),
('Tania', 'tania@email.com', SHA2('passT', 256), '2025-09-20', 'Activo', 'Suscriptor', 'Público');

-- Perfiles (20 registros, con atributos variados)
INSERT INTO Perfil (IdUsuario, FotoPerfil, Biografia, EnlacesSociales, EnlacePersonal)
VALUES
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

-- Contenidos (solo creadores, algunos con varios contenidos)
INSERT INTO Contenido (IdAutor, Título, Descripción, TipoContenido, UrlContenido, FechaCreación, EstadoContenido)
VALUES
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

-- Suscripciones (solo algunos usuarios suscriptores)
INSERT INTO Suscripción (IdSuscriptor, IdCreador, Monto, FechaPago, EstadoPago)
VALUES
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

-- Pagos (solo usuarios con suscripción)
INSERT INTO Pago (IdPagador, IdReceptor, Monto, FechaPago, EstadoPago, MetodoPago, IdEmisor)
VALUES
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

-- Mensajes (usuarios con y sin suscripción, alternando emisor/receptor)
INSERT INTO Mensaje (IdEmisor, IdReceptor, ContenidoMensaje, FechaMensaje, EstadoMensaje)
VALUES
(2, 1, 'Hola Alice, me gusta tu trabajo!', '2025-09-02 10:00', 'Leído'),
(4, 3, 'Carla, ¿cuándo publicas nuevo artículo?', '2025-09-04 11:00', 'Leído'),
(6, 5, 'Eva, ¿tienes rutinas para principiantes?', '2025-09-06 12:00', 'Leído'),
(8, 7, 'Gina, tu receta fue un éxito!', '2025-09-08 13:00', 'Leído'),
(10, 9, 'Irene, ¿aceptas encargos?', '2025-09-10 14:00', 'Leído'),
(12, 11, 'Karla, ¿harás stream hoy?', '2025-09-12 15:00', 'Leído'),
(14, 13, 'Marina, tu arte es genial!', '2025-09-14 16:00', 'Leído'),
(16, 15, 'Olga, ¿más tutoriales pronto?', '2025-09-16 17:00', 'Leído'),
(18, 17, 'Quique, tus memes son los mejores!', '2025-09-18 18:00', 'Leído'),
(20, 19, 'Samuel, ¿qué tema será el próximo video?', '2025-09-20 19:00', 'Leído'),
(1, 2, 'Gracias por tu apoyo, Bob!', '2025-09-02 20:00', 'Leído'),
(3, 4, '¡Pronto publicaré más!', '2025-09-04 21:00', 'Leído'),
(5, 6, 'Sí, tengo rutinas para todos.', '2025-09-06 22:00', 'Leído'),
(7, 8, 'Me alegra que te gustara!', '2025-09-08 23:00', 'Leído'),
(9, 10, 'Claro, mándame detalles.', '2025-09-10 09:00', 'Leído'),
(11, 12, 'Sí, a las 8pm!', '2025-09-12 08:00', 'Leído'),
(13, 14, '¡Gracias por tu comentario!', '2025-09-14 07:00', 'Leído'),
(15, 16, 'Sí, pronto más tutoriales.', '2025-09-16 06:00', 'Leído'),
(17, 18, '¡Gracias por seguirme!', '2025-09-18 05:00', 'Leído'),
(19, 20, 'Será sobre historia universal.', '2025-09-20 04:00', 'Leído');

-- Consentimientos (todos los usuarios, diferentes tipos)
INSERT INTO Consentimiento (IdUsuario, TipoConsentimiento, FechaConsentimiento, DetallesConsentimiento, EstadoConsentimiento)
VALUES
(1, 'DatosPersonales', '2025-09-01', 'Acepta uso de datos personales.', 'Vigente'),
(2, 'Newsletter', '2025-09-02', 'Acepta recibir boletines.', 'Vigente'),
(3, 'Publicidad', '2025-09-03', 'Acepta recibir publicidad.', 'Vigente'),
(4, 'DatosPersonales', '2025-09-04', 'Acepta uso de datos personales.', 'Vigente'),
(5, 'Newsletter', '2025-09-05', 'Acepta recibir boletines.', 'Vigente'),
(6, 'Publicidad', '2025-09-06', 'Acepta recibir publicidad.', 'Vigente'),
(7, 'DatosPersonales', '2025-09-07', 'Acepta uso de datos personales.', 'Vigente'),
(8, 'Newsletter', '2025-09-08', 'Acepta recibir boletines.', 'Vigente'),
(9, 'Publicidad', '2025-09-09', 'Acepta recibir publicidad.', 'Vigente'),
(10, 'DatosPersonales', '2025-09-10', 'Acepta uso de datos personales.', 'Vigente'),
(11, 'Newsletter', '2025-09-11', 'Acepta recibir boletines.', 'Vigente'),
(12, 'Publicidad', '2025-09-12', 'Acepta recibir publicidad.', 'Vigente'),
(13, 'DatosPersonales', '2025-09-13', 'Acepta uso de datos personales.', 'Vigente'),
(14, 'Newsletter', '2025-09-14', 'Acepta recibir boletines.', 'Vigente'),
(15, 'Publicidad', '2025-09-15', 'Acepta recibir publicidad.', 'Vigente'),
(16, 'DatosPersonales', '2025-09-16', 'Acepta uso de datos personales.', 'Vigente'),
(17, 'Newsletter', '2025-09-17', 'Acepta recibir boletines.', 'Vigente'),
(18, 'Publicidad', '2025-09-18', 'Acepta recibir publicidad.', 'Vigente'),
(19, 'DatosPersonales', '2025-09-19', 'Acepta uso de datos personales.', 'Vigente'),
(20, 'Newsletter', '2025-09-20', 'Acepta recibir boletines.', 'Vigente');