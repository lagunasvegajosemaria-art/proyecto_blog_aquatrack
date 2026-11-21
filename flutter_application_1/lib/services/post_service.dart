import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post_model.dart';

class PostService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<List<PostModel>> obtenerPosts() async {
    final respuesta = await http.get(Uri.parse('$baseUrl/blog'));

    if (respuesta.statusCode != 200) {
      throw Exception('Error al consultar publicaciones');
    }

    final List<dynamic> datos = jsonDecode(respuesta.body);
    return datos
        .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<PostModel> agregarPost({
    required String titulo,
    required String descripcion,
    String? imagen,
    String? tags,
    required int usuarioId,
  }) async {
    final respuesta = await http
        .post(
          Uri.parse('$baseUrl/blog'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'id_blog': 0,
            'titulo': titulo.trim(),
            'desc': descripcion.trim(),
            'img': (imagen ?? '').trim().isEmpty ? null : imagen!.trim(),
            'tags': (tags ?? '').trim().isEmpty ? null : tags!.trim(),
            'usuario_id': usuarioId,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final dynamic resultado = respuesta.body.isNotEmpty
        ? jsonDecode(respuesta.body)
        : null;

    if ((respuesta.statusCode == 200 || respuesta.statusCode == 201) &&
        resultado is Map<String, dynamic>) {
      return PostModel.fromJson(resultado);
    }

    if (resultado is Map && resultado['detail'] != null) {
      throw Exception(resultado['detail'].toString());
    }

    throw Exception(
      'No se pudo guardar la publicación (HTTP ${respuesta.statusCode})',
    );
  }

  Future<void> eliminarBlog(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/blog/$id'));
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('No se pudo eliminar el blog');
    }
  }
}
