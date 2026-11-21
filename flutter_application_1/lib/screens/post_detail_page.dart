import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../models/comentario_model.dart';
import '../services/comentario_service.dart';
import '../services/user_service.dart';
import '../services/post_service.dart';

class PostDetailPage extends StatefulWidget {
  final PostModel post;
  final Map<String, dynamic> usuario;

  const PostDetailPage({super.key, required this.post, required this.usuario});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final ComentarioService _comentarioService = ComentarioService();
  final TextEditingController _comentarioController = TextEditingController();

  late Future<List<ComentarioModel>> _futureComentarios;
  bool _enviandoComentario = false;
  int? _miUsuarioId;

  static const colorOscuro = Color(0xFF1e81b0);
  static const colorClaro = Color(0xFFa8d5e2);

  @override
  void initState() {
    super.initState();
    _cargarComentarios();
    _obtenerMiId();
  }

  void _obtenerMiId() {
    final dynamic rawId = widget.usuario['id_usr'] ?? widget.usuario['id'];
    if (rawId != null) {
      _miUsuarioId = rawId is num
          ? rawId.toInt()
          : int.tryParse(rawId.toString());
    }
  }

  void _cargarComentarios() {
    setState(() {
      _futureComentarios = _comentarioService.obtenerComentarios();
    });
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _eliminarPost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar publicación'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este blog permanentemente? Se borrarán también sus comentarios.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await PostService().eliminarBlog(widget.post.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Publicación eliminada'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _enviarComentario() async {
    final texto = _comentarioController.text.trim();
    if (texto.isEmpty) return;

    setState(() => _enviandoComentario = true);

    try {
      int? usuarioId = _miUsuarioId;

      if (usuarioId == null || usuarioId <= 0) {
        final miCorreo = widget.usuario['mail']?.toString() ?? '';
        if (miCorreo.isEmpty)
          throw Exception('No se pudo identificar tu correo.');

        final userService = UserService();
        final usuarios = await userService.obtenerUsuarios();
        final usuarioDb = usuarios.firstWhere(
          (u) => u.correo.toLowerCase() == miCorreo.toLowerCase(),
          orElse: () => throw Exception('Tu usuario no existe.'),
        );
        usuarioId = usuarioDb.id;
      }

      final nuevoComentario = ComentarioModel(
        id: 0,
        comentario: texto,
        fecha: '',
        estatus: 1,
        usuarioId: usuarioId,
        blogId: widget.post.id,
      );

      await _comentarioService.agregarComentario(nuevoComentario);
      _comentarioController.clear();
      _cargarComentarios();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comentario publicado'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString().replaceFirst("Exception: ", "")}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _enviandoComentario = false);
    }
  }

  Future<void> _reportarComentario(int idComentario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reportar comentario'),
        content: const Text(
          '¿Estás seguro de que deseas reportar este comentario? Será revisado por un administrador.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Reportar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _comentarioService.reportarComentario(idComentario);
      _cargarComentarios();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comentario reportado. Gracias por tu ayuda.'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al reportar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String inicialUsuario = 'U';
    final String nombreUsuario =
        widget.usuario['nom_usr']?.toString().trim() ?? '';
    if (nombreUsuario.isNotEmpty) {
      inicialUsuario = nombreUsuario[0].toUpperCase();
    }

    final esAdmin = (widget.usuario['tip_usu'] as num?)?.toInt() == 1;
    final esAutor = widget.post.autor == nombreUsuario;
    final puedeEliminar = esAdmin || esAutor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detalle del post',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorOscuro,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          if (puedeEliminar)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              tooltip: 'Eliminar publicación',
              onPressed: _eliminarPost,
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: Image.network(
                    widget.post.imagen.startsWith('http')
                        ? widget.post.imagen
                        : 'http://127.0.0.1:8000${widget.post.imagen}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.post.categoria.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorClaro.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.post.categoria.toUpperCase(),
                            style: const TextStyle(
                              color: colorOscuro,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        widget.post.titulo,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colorOscuro,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 18,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              widget.post.autor,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.post.fecha,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 32),
                      Text(
                        widget.post.contenido,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.8,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),

                Container(
                  color: colorClaro.withOpacity(0.15),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Comentarios',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colorOscuro,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: colorClaro,
                            child: Text(
                              inicialUsuario,
                              style: const TextStyle(
                                color: colorOscuro,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _comentarioController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Escribe un comentario...',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: colorOscuro,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _enviandoComentario
                                  ? null
                                  : _enviarComentario,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorOscuro,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _enviandoComentario
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.send),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      FutureBuilder<List<ComentarioModel>>(
                        future: _futureComentarios,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: colorOscuro,
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return Text(
                              'Error al cargar comentarios: ${snapshot.error}',
                            );
                          }

                          final todos = snapshot.data ?? [];
                          final comentariosDelPost = todos
                              .where(
                                (c) =>
                                    c.blogId == widget.post.id &&
                                    c.estatus == 1,
                              )
                              .toList();

                          if (comentariosDelPost.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Text(
                                  'Aún no hay comentarios. ¡Sé el primero en opinar!',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comentariosDelPost.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 24),
                            itemBuilder: (context, index) {
                              final c = comentariosDelPost[index];
                              final esMio =
                                  _miUsuarioId != null &&
                                  c.usuarioId == _miUsuarioId;

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.person,
                                      size: 20,
                                      color: colorOscuro,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              c.autorNombre,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: colorOscuro,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  c.fecha.length > 10
                                                      ? c.fecha.substring(0, 10)
                                                      : c.fecha,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                if (!esMio)
                                                  InkWell(
                                                    onTap: () =>
                                                        _reportarComentario(
                                                          c.id,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                    child: const Padding(
                                                      padding: EdgeInsets.all(
                                                        4.0,
                                                      ),
                                                      child: Icon(
                                                        Icons.flag_outlined,
                                                        size: 18,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          c.comentario,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
