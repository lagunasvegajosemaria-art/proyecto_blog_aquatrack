import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/post_detail_page.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../widgets/post_card.dart';
import '../widgets/app_drawer.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final PostService postService = PostService();
  late Future<List<PostModel>> futurePosts;
  String nombreUsuario = 'Usuario';
  Map<String, dynamic> usuarioActual = {};
  bool _cargandoUsuario = true;
  bool _inicializado = false;

  // Paleta de colores AquaTrack
  static const colorOscuro = Color(0xFF1e81b0);
  static const colorMedio = Color(0xFF76b5c5);

  @override
  void initState() {
    super.initState();
    futurePosts = postService.obtenerPosts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      _cargarUsuario();
      _inicializado = true;
    }
  }

  Future<void> _cargarUsuario() async {
    final argumento = ModalRoute.of(context)?.settings.arguments;

    if (argumento is Map<String, dynamic> && argumento.isNotEmpty) {
      usuarioActual = Map<String, dynamic>.from(argumento);
    } else {
      // Si recargamos la página, obtenemos los datos de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      usuarioActual = {
        'id': prefs.getInt('id_usr') ?? 0,
        'id_usr': prefs.getInt('id_usr') ?? 0,
        'nom_usr': prefs.getString('nom_usr') ?? 'Usuario',
        'mail': prefs.getString('mail') ?? '',
        'tip_usu': prefs.getInt('tip_usu') ?? 2,
        'dir_usr': prefs.getString('dir_usr') ?? '',
      };
    }

    if (mounted) {
      setState(() {
        nombreUsuario = usuarioActual['nom_usr']?.toString() ?? 'Usuario';
        _cargandoUsuario = false;
      });
    }
  }

  void recargarPosts() {
    setState(() {
      futurePosts = postService.obtenerPosts();
    });
  }

  void _abrirDetalle(PostModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PostDetailPage(post: post, usuario: usuarioActual),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargandoUsuario) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: colorOscuro)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        toolbarHeight: 65,
        backgroundColor: colorOscuro, // Fondo azul oscuro AquaTrack
        foregroundColor: Colors.white,
        elevation: 4,
        title: Row(
          children: [
            const Icon(Icons.water_drop, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'AquaTrack Blog',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hola, $nombreUsuario',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Actualizar blog',
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: recargarPosts,
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: buildAppDrawer(usuario: usuarioActual, rutaActual: '/blog'),
      body: FutureBuilder<List<PostModel>>(
        future: futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: colorOscuro),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final posts = snapshot.data ?? [];

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1700),
              child: CustomScrollView(
                slivers: [
                  // ─── ENCABEZADO TIPO HERO ───
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 48,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [colorMedio, colorOscuro],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'La importancia de cuidar cada gota',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Descubre cómo pequeños hábitos pueden salvar nuestro planeta y mejorar tu salud.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ─── LISTA DE POSTS (GRID) ───
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 480,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            childAspectRatio: 0.85,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final post = posts[index];
                        return PostCard(
                          post: post,
                          onTap: () => _abrirDetalle(post),
                        );
                      }, childCount: posts.length),
                    ),
                  ),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
