from contextlib import asynccontextmanager
from fastapi import FastAPI, Depends, HTTPException, UploadFile, File, Form
from fastapi.staticfiles import StaticFiles
from pathlib import Path
import shutil
import uuid
import secrets
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from pwdlib import PasswordHash
from pydantic import BaseModel

from database import Base, engine, obtener_sesion
from models import Usuario, Blog, Comentario
from schemas import (
    UsuarioCrear,
    UsuarioRespuesta,
    BlogRespuesta,
    ComentarioCrear,
    ComentarioRespuesta,
    LoginRequest,
)

password_hash = PasswordHash.recommended()


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield

app = FastAPI(
    title="API de aplicación móvil",
    lifespan=lifespan,
)

# Configuración de la carpeta para guardar las imágenes subidas
UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")


@app.get("/")
def inicio():
    return {"mensaje": "API funcionando correctamente"}

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ==========================================
# USUARIOS
# ==========================================

@app.get("/usuarios", response_model=list[UsuarioRespuesta])
def listar_usuarios(db: Session = Depends(obtener_sesion)):
    return db.scalars(
        select(Usuario).order_by(Usuario.id_usr)
    ).all()


@app.post("/usuarios", response_model=UsuarioRespuesta, status_code=201)
def crear_usuario(
    datos: UsuarioCrear,
    db: Session = Depends(obtener_sesion),
):
    usuario = Usuario(
        nom_usr=datos.nom_usr.strip(),
        mail=datos.mail.strip().lower(),
        pass_hash=password_hash.hash(datos.password),
        dir_usr=datos.dir_usr,
        tip_usu=datos.tip_usu,
    )

    db.add(usuario)

    try:
        db.commit()
        db.refresh(usuario)
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="El correo ya está registrado",
        )

    return usuario


# 👇 NUEVO: Esquema para actualizar usuario 👇
class UsuarioUpdate(BaseModel):
    nom_usr: str
    mail: str
    dir_usr: str | None = None
    tip_usu: int


# 👇 NUEVO: Ruta para actualizar (PUT) 👇
@app.put("/usuarios/{id_usr}", response_model=UsuarioRespuesta)
def actualizar_usuario(
    id_usr: int,
    datos: UsuarioUpdate,
    db: Session = Depends(obtener_sesion),
):
    usuario = db.get(Usuario, id_usr)

    if usuario is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado",
        )

    usuario.nom_usr = datos.nom_usr.strip()
    usuario.mail = datos.mail.strip().lower()
    usuario.dir_usr = datos.dir_usr
    usuario.tip_usu = datos.tip_usu

    try:
        db.commit()
        db.refresh(usuario)
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="El correo ya está registrado por otro usuario",
        )

    return usuario


# 👇 NUEVO: Ruta para eliminar (DELETE) 👇
@app.delete("/usuarios/{id_usr}", status_code=204)
def eliminar_usuario(
    id_usr: int,
    db: Session = Depends(obtener_sesion),
):
    usuario = db.get(Usuario, id_usr)

    if usuario is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado",
        )

    db.delete(usuario)
    db.commit()
    return None


# ==========================================
# BLOG
# ==========================================

@app.get("/blog", response_model=list[BlogRespuesta])
def listar_blog(db: Session = Depends(obtener_sesion)):
    # Hacemos un JOIN con la tabla Usuario para traer el nombre del autor
    stmt = (
        select(Blog, Usuario.nom_usr)
        .outerjoin(Usuario, Blog.usr_id == Usuario.id_usr)
        .order_by(Blog.id_blog)
    )
    resultados = db.execute(stmt).all()
    
    lista_final = []
    for b, nombre_autor in resultados:
        lista_final.append({
            "id_blog": b.id_blog,
            "titulo": b.titulo,
            "descripcion": b.descripcion,
            "contenido": b.contenido,
            "img": b.img,
            "tags": b.tags,
            "nom_usr": nombre_autor or "Anónimo" # 👈 Mandamos el nombre
        })
    return lista_final


@app.get("/blog/{blog_id}", response_model=BlogRespuesta)
def obtener_blog(
    blog_id: int,
    db: Session = Depends(obtener_sesion),
):
    stmt = (
        select(Blog, Usuario.nom_usr)
        .outerjoin(Usuario, Blog.usr_id == Usuario.id_usr)
        .where(Blog.id_blog == blog_id)
    )
    resultado = db.execute(stmt).first()
    
    if resultado is None:
        raise HTTPException(status_code=404, detail="Publicación no encontrada")
        
    b, nombre_autor = resultado
    return {
        "id_blog": b.id_blog,
        "titulo": b.titulo,
        "descripcion": b.descripcion,
        "contenido": b.contenido,
        "img": b.img,
        "tags": b.tags,
        "nom_usr": nombre_autor or "Anónimo"
    }


@app.post("/blog", response_model=BlogRespuesta, status_code=201)
async def crear_blog(
    titulo: str = Form(...),
    descripcion: str = Form(...),
    contenido: str = Form(None),  
    tags: str = Form(None),       
    usr_id: int = Form(...), # 👈 Recibimos el ID del autor
    imagen: UploadFile = File(...),
    db: Session = Depends(obtener_sesion),
):
    # Validar extensión de la imagen
    extension = Path(imagen.filename or "").suffix.lower()
    if extension not in [".jpg", ".jpeg", ".png", ".webp"]:
        raise HTTPException(status_code=400, detail="Formato de imagen no permitido")

    # Guardar imagen
    nombre_archivo = f"{uuid.uuid4().hex}{extension}"
    ruta_archivo = UPLOAD_DIR / nombre_archivo
    with ruta_archivo.open("wb") as destino:
        shutil.copyfileobj(imagen.file, destino)
    ruta_publica = f"/uploads/{nombre_archivo}"

    # Crear publicación con el autor
    publicacion = Blog(
        titulo=titulo.strip(),
        descripcion=descripcion.strip(),
        contenido=contenido.strip() if contenido else None, 
        tags=tags.strip() if tags else None,               
        img=ruta_publica,
        usr_id=usr_id, # 👈 Guardamos la llave foránea
    )

    db.add(publicacion)
    try:
        db.commit()
        db.refresh(publicacion)
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

    # Buscamos el nombre del usuario para devolverlo en la respuesta
    usuario = db.get(Usuario, usr_id)
    return {
        "id_blog": publicacion.id_blog,
        "titulo": publicacion.titulo,
        "descripcion": publicacion.descripcion,
        "contenido": publicacion.contenido,
        "img": publicacion.img,
        "tags": publicacion.tags,
        "nom_usr": usuario.nom_usr if usuario else "Anónimo"
    }

class RecuperarPasswordRequest(BaseModel):
    nom_usr: str
    mail: str

@app.post("/usuarios/recuperar")
def recuperar_password(
    datos: RecuperarPasswordRequest,
    db: Session = Depends(obtener_sesion),
):
    usuario = db.scalar(
        select(Usuario).where(
            Usuario.mail == datos.mail.strip().lower(),
            Usuario.nom_usr == datos.nom_usr.strip()
        )
    )

    if usuario is None:
        raise HTTPException(
            status_code=404,
            detail="No se encontró ningún usuario con ese nombre y correo.",
        )

    # 👇 AQUÍ ESTÁ EL TRUCO: Cambiamos la contraseña en la BD a 123456Pass
    password_fija = "123456Pass"
    usuario.pass_hash = password_hash.hash(password_fija)
    db.commit()

    return {
        "mensaje": "Contraseña restablecida",
        "password": password_fija
    }

# ==========================================
# COMENTARIOS
# ==========================================

@app.get(
    "/comentarios",
    response_model=list[ComentarioRespuesta],
)
def listar_comentarios(db: Session = Depends(obtener_sesion)):
    # Hacemos un JOIN para unir el comentario con el nombre del usuario
    stmt = (
        select(Comentario, Usuario.nom_usr)
        .join(Usuario, Comentario.usr_id == Usuario.id_usr)
        .order_by(Comentario.id_com)
    )
    
    resultados = db.execute(stmt).all()
    
    lista_final = []
    for c, nombre in resultados:
        lista_final.append({
            "id_com": c.id_com,
            "comentario": c.comentario,
            "fecha": c.fecha,
            "estatus": c.estatus,
            "usr_id": c.usr_id,
            "blog_id": c.blog_id,
            "nom_usr": nombre 
        })
        
    return lista_final



@app.post(
    "/comentarios",
    response_model=ComentarioRespuesta,
    status_code=201,
)
def crear_comentario(
    datos: ComentarioCrear,
    db: Session = Depends(obtener_sesion),
):
    if not datos.comentario.strip():
        raise HTTPException(
            status_code=422,
            detail="El comentario no puede estar vacío",
        )

    if db.get(Usuario, datos.usr_id) is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado",
        )

    if db.get(Blog, datos.blog_id) is None:
        raise HTTPException(
            status_code=404,
            detail="Publicación no encontrada",
        )

    nuevo = Comentario(
        comentario=datos.comentario.strip(),
        usr_id=datos.usr_id,
        blog_id=datos.blog_id,
        estatus=1,
    )

    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)

    return nuevo


# ==========================================
# LOGIN
# ==========================================

@app.post("/login", response_model=UsuarioRespuesta)
def iniciar_sesion(
    datos: LoginRequest,
    db: Session = Depends(obtener_sesion),
):
    correo = datos.mail.strip().lower()

    usuario = db.scalar(
        select(Usuario).where(Usuario.mail == correo)
    )

    if usuario is None or not password_hash.verify(
        datos.password,
        usuario.pass_hash
    ):
        raise HTTPException(
            status_code=401,
            detail="Correo o contraseña incorrectos",
        )
    return usuario
# ==========================================
# GESTIÓN DE COMENTARIOS REPORTADOS
# ==========================================

@app.get("/comentarios/reportados", response_model=list[ComentarioRespuesta])
def listar_comentarios_reportados(db: Session = Depends(obtener_sesion)):
    # Traemos los comentarios con estatus = 0 (reportados) y el nombre del usuario
    stmt = (
        select(Comentario, Usuario.nom_usr)
        .join(Usuario, Comentario.usr_id == Usuario.id_usr)
        .where(Comentario.estatus == 0)
        .order_by(Comentario.id_com)
    )
    resultados = db.execute(stmt).all()
    
    lista_final = []
    for c, nombre in resultados:
        lista_final.append({
            "id_com": c.id_com,
            "comentario": c.comentario,
            "fecha": c.fecha,
            "estatus": c.estatus,
            "usr_id": c.usr_id,
            "blog_id": c.blog_id,
            "nom_usr": nombre
        })
    return lista_final

@app.put("/comentarios/{id_com}/reportar")
def reportar_comentario(id_com: int, db: Session = Depends(obtener_sesion)):
    comentario = db.get(Comentario, id_com)
    if comentario is None:
        raise HTTPException(status_code=404, detail="Comentario no encontrado")
    
    comentario.estatus = 0 # 0 significa reportado
    db.commit()
    return {"mensaje": "Comentario reportado"}

@app.delete("/comentarios/{id_com}", status_code=204)
def eliminar_comentario(id_com: int, db: Session = Depends(obtener_sesion)):
    comentario = db.get(Comentario, id_com)
    if comentario is None:
        raise HTTPException(status_code=404, detail="Comentario no encontrado")
    
    db.delete(comentario)
    db.commit()
    return None
# ==========================================
# CAMBIAR CONTRASEÑA (NUEVO)
# ==========================================
class PasswordChangeRequest(BaseModel):
    new_password: str

@app.put("/usuarios/{id_usr}/password")
def cambiar_password(
    id_usr: int, 
    datos: PasswordChangeRequest, 
    db: Session = Depends(obtener_sesion)
):
    usuario = db.get(Usuario, id_usr)
    
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    
    if len(datos.new_password) < 8:
        raise HTTPException(status_code=400, detail="La contraseña debe tener al menos 8 caracteres")

    usuario.pass_hash = password_hash.hash(datos.new_password)
    db.commit()
    return {"mensaje": "Contraseña actualizada correctamente"}

# ==========================================
# ELIMINAR BLOG (NUEVO)
# ==========================================
@app.delete("/blog/{blog_id}", status_code=204)
def eliminar_blog(blog_id: int, db: Session = Depends(obtener_sesion)):
    blog = db.get(Blog, blog_id)
    if not blog:
        raise HTTPException(status_code=404, detail="Blog no encontrado")
    

    db.query(Comentario).filter(Comentario.blog_id == blog_id).delete()
    

    db.delete(blog)
    db.commit()
    return None