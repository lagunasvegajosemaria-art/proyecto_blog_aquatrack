# 🌊 AquaTrack Blog

Aplicación móvil para la gestión de blogs con temática de concientización sobre el agua. Cuenta con un sistema de usuarios, roles (Administrador y Usuario), gestión de publicaciones, comentarios y reportes.

##  Tecnologías utilizadas
* **Frontend:** Flutter (Dart)
* **Backend:** Python (FastAPI)
* **Base de Datos:** MySQL (MariaDB)
* **Autenticación:** Passlib (Hash de contraseñas)

---

## Estructura del Proyecto
* `flutter_application_1/`: Código fuente de la aplicación móvil/web en Flutter.
* `backend_API/`: Código fuente de la API RESTful en FastAPI.
  * `database.sql`: Script para crear e importar la base de datos.

---

## Instrucciones de Instalación y Uso

### 1. Configurar la Base de Datos
1. Abre tu gestor de MySQL (XAMPP/phpMyAdmin o MySQL Workbench).
2. Utilizamos la base de datos creada durante el curso llamada `db_aplicacion_movil`.
3. Importa el archivo `backend_API/database.sql` dentro de esa base de datos.

### 2. Configurar el Backend (FastAPI)
Abre una terminal y navega a la carpeta del backend:
```bash
cd backend_API