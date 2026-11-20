-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 16, 2026 at 05:42 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_aplicacion_movil`
--

-- --------------------------------------------------------

--
-- Table structure for table `blog`
--

CREATE TABLE `blog` (
  `id_blog` int(11) NOT NULL,
  `titulo` varchar(150) NOT NULL,
  `desc` text DEFAULT NULL,
  `img` varchar(500) DEFAULT NULL,
  `tags` varchar(255) DEFAULT NULL,
  `contenido` text DEFAULT NULL,
  `usr_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `blog`
--

INSERT INTO `blog` (`id_blog`, `titulo`, `desc`, `img`, `tags`, `contenido`, `usr_id`) VALUES
(1, 'Introducci?n a las Rutas en Flutter', 'Aprende a navegar entre diferentes pantallas utilizando Navigator y rutas nombradas.', 'https://ejemplo.com/images/flutter-routes.png', 'flutter, navigation, mobile', NULL, NULL),
(2, 'Desarrollo de Interfaces con Tkinter', 'Gu?a pr?ctica para crear aplicaciones de escritorio interactivas en Python usando widgets personalizados.', 'https://ejemplo.com/images/python-tkinter.png', 'python, gui, desktop', NULL, NULL),
(3, 'Control de Versiones con Git y GitHub', 'Domina las ramas, los commits y la resoluci?n de conflictos al trabajar en equipo.', 'https://ejemplo.com/images/git-github.png', 'git, github, version-control', NULL, NULL),
(4, 'Administraci?n de Permisos en Linux', 'Comprende el funcionamiento de chmod, chown y los niveles de acceso para usuarios en entornos Unix.', 'https://ejemplo.com/images/linux-permissions.png', 'linux, administration, security', NULL, NULL),
(5, 'Creaci?n de APIs REST con FastAPI', 'Construye servicios web r?pidos y documentados autom?ticamente utilizando Python y Pydantic.', 'https://ejemplo.com/images/fastapi-rest.png', 'python, fastapi, backend', NULL, NULL),
(6, 'a', 'a', 'a', 'pepe', NULL, NULL),
(7, 'hola', 'holaaa', NULL, NULL, NULL, NULL),
(8, 'king crimson', 'usuario diavolo', '/uploads/afef7a7d5b2f440f803e731911a5b48a.jpg', NULL, NULL, NULL),
(9, 'king crimson', 'stand de corto alcanze', '/uploads/4e69f029ef2e4121a750db95621e508b.jpg', NULL, NULL, NULL),
(10, 'king crimson', 'esta inspirado en la banda del mismo nombre', '/uploads/f095eee0f53b4066bb608c1cd5c527af.jpg', NULL, NULL, NULL),
(11, 'prueba1', 'hola', '/uploads/0b20f3b543814f7cbcafd925001d4899.jpg', NULL, 'este es una prueba de publicacion', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `comentarios`
--

CREATE TABLE `comentarios` (
  `id_com` int(11) NOT NULL,
  `comentario` text NOT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `estatus` int(11) NOT NULL DEFAULT 1,
  `usr_id` int(11) NOT NULL,
  `blog_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `comentarios`
--

INSERT INTO `comentarios` (`id_com`, `comentario`, `fecha`, `estatus`, `usr_id`, `blog_id`) VALUES
(6, '?Se ven incre?bles! Definitivamente los voy a preparar este fin de semana.', '2026-10-14 12:53:43', 1, 1, 1),
(7, '?Qu? tipo de galletas recomiendas usar para la base del pay?', '2026-10-14 12:53:43', 1, 2, 2),
(8, 'El toque de canela hace toda la diferencia, ?me encant? la receta!', '2026-10-14 12:53:43', 1, 1, 3),
(9, 'Prob? la pasta ayer y a todos en casa nos fascin?.', '2026-10-14 12:53:43', 1, 2, 4),
(10, 'Me sali? perfecta la salsa siguiendo estos pasos, gracias por el tip.', '2026-10-14 12:53:43', 1, 1, 5),
(11, 'Hola este es un comentario desde el API como prueba', '2026-10-21 12:46:28', 1, 1, 1),
(12, 'hola', '2026-11-15 17:33:45', 1, 9, 2),
(13, 'hola', '2026-11-15 17:39:27', 1, 9, 10),
(14, 'hola2', '2026-11-15 17:52:36', 1, 9, 2);

-- --------------------------------------------------------

--
-- Table structure for table `usuario`
--

CREATE TABLE `usuario` (
  `id_usr` int(11) NOT NULL,
  `nom_usr` varchar(100) NOT NULL,
  `mail` varchar(150) NOT NULL,
  `pass` varchar(255) NOT NULL,
  `dir_usr` varchar(200) DEFAULT NULL,
  `tip_usu` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `usuario`
--

INSERT INTO `usuario` (`id_usr`, `nom_usr`, `mail`, `pass`, `dir_usr`, `tip_usu`) VALUES
(1, 'pedro', 'pedro@gmail.com', '12345', 'QUERETARO', 1),
(2, 'jose', 'jose@gmail.com', '12567', 'CDMX', 1),
(3, 'fernando', 'fer@gmail', '$argon2id$v=19$m=65536,t=3,p=4$VojBn13Tc0/HNlFOJwFNxQ$xSEHmZE8VZ1MnKGi9XPhjVhutZ3An67f/wmAHIgonw4', 'QUERETARO', 1),
(4, 'carlos', 'carlos@gmail.com', '$argon2id$v=19$m=65536,t=3,p=4$MKLXdbUf9DeVrOWrE/JZ4w$PKuuAoQ3lMEC0zNy1eD9TMMDX+In978HwZBA5kpRhj4', 'COLIMA', 1),
(5, 'hola', 'hola@gmail.com', '$argon2id$v=19$m=65536,t=3,p=4$ZNlXyaDmR1JlmsnUzy9AEQ$r1DlKnA2UTIZney0CQ9GTtuDAhwoDI4ByHb5DfPdC6E', 'MEX', 1),
(6, 'hola2', 'hola2@gmail.com', '$argon2id$v=19$m=65536,t=3,p=4$maYlnbwRGRTUNua+EvqYlg$cg/XECbKgXGTUzaG2ETZgy/gwbLuqJemS3FIaG33tP4', 'OAXACA', 2),
(7, 'prueba1', 'prueba1@gmail.com', '$argon2id$v=19$m=65536,t=3,p=4$F0/sT8nKDwpmKm+Y85Hg9Q$Yh4JFJD5dkPsdxfEodKwjo2+jDNF0ZnypTSw8DFPiY8', 'OAXACA', 1),
(8, 'prueba2', 'prueba2@gmail.com', '$argon2id$v=19$m=65536,t=3,p=4$LFvrTc86b3cglr+cxsvF+w$Nj9QILBFIYVOVxt0dUoS8kh+WfZjH/wTwNymSicA/8s', 'OAXACA', 1),
(9, 'admin1', 'sesion1@gmail.com', '$argon2id$v=19$m=65536,t=3,p=4$ArYUZxMioQGDtfFEDALBjg$9Y38eJ902tRaersXc0T5QaiLvQw5HoNh9yiERy2FRQs', '', 1),
(10, 'sesion2', 'sesion2@gmail.com', '$argon2id$v=19$m=65536,t=3,p=4$saq1qhNhqhcA0N+Ti0Tr9g$JvT5INseZS2DtXwqspmScoSDxJKs5WzsRKwpPM7DOR0', 'CHIAPAS', 2),
(11, 'mpape', 'mpape@gmail.com', '$argon2id$v=19$m=65536,t=3,p=4$89Hg7SMdHrudMw3dbV+0Lg$4nRm2Fs5y2uXVOWMpoXuNF7eb3UJpF0L6pIEYtF44Sg', NULL, 1),
(12, 'carl', 'carl@gmail.com', '$argon2id$v=19$m=65536,t=3,p=4$RvwnS7xAhTsPuU7K5vSUBw$GmBtX5tCU4vuSaTZTfQ/D85ys6zJ9BWSlXdYHzP9Xkg', NULL, 1),
(19, 'py', 'py@gmail.com', '$argon2id$v=19$m=65536,t=3,p=4$oo2jxqVr4c1A121bKnhSFg$ddQ2mgg+P5aWd28yuNroyogfkif8LkkhJyfyWX33qsk', NULL, 1),
(20, 'admin2', 'ad2@gmail.com', '$argon2id$v=19$m=65536,t=3,p=4$ww4ZKezjFSJJM6wlqV3PEQ$Kq8JZUV0sDsRaF58HcZzgFSVYAFeyoLptByKyyNMPPU', NULL, 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `blog`
--
ALTER TABLE `blog`
  ADD PRIMARY KEY (`id_blog`),
  ADD KEY `fk_blog_usuario` (`usr_id`);

--
-- Indexes for table `comentarios`
--
ALTER TABLE `comentarios`
  ADD PRIMARY KEY (`id_com`),
  ADD KEY `fk_comentario_usuario` (`usr_id`),
  ADD KEY `fk_comentario_blog` (`blog_id`);

--
-- Indexes for table `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usr`),
  ADD UNIQUE KEY `mail` (`mail`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `blog`
--
ALTER TABLE `blog`
  MODIFY `id_blog` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `comentarios`
--
ALTER TABLE `comentarios`
  MODIFY `id_com` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usr` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `blog`
--
ALTER TABLE `blog`
  ADD CONSTRAINT `fk_blog_usuario` FOREIGN KEY (`usr_id`) REFERENCES `usuario` (`id_usr`) ON DELETE SET NULL;

--
-- Constraints for table `comentarios`
--
ALTER TABLE `comentarios`
  ADD CONSTRAINT `fk_comentario_blog` FOREIGN KEY (`blog_id`) REFERENCES `blog` (`id_blog`),
  ADD CONSTRAINT `fk_comentario_usuario` FOREIGN KEY (`usr_id`) REFERENCES `usuario` (`id_usr`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
