import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/comentario_model.dart';

class ComentarioService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<List<ComentarioModel>> obtenerComentarios() async {
    final respuesta = await http
        .get(Uri.parse('$baseUrl/comentarios'))
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode == 200) {
      final List<dynamic> datos = jsonDecode(respuesta.body);
      return datos
          .map((json) => ComentarioModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al cargar comentarios');
  }

  Future<void> agregarComentario(ComentarioModel comentario) async {
    final respuesta = await http
        .post(
          Uri.parse('$baseUrl/comentarios'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(comentario.toJsonCrear()),
        )
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode != 201 && respuesta.statusCode != 200) {
      throw Exception('No se pudo enviar el comentario');
    }
  }

  Future<List<ComentarioModel>> obtenerReportados() async {
    final respuesta = await http
        .get(Uri.parse('$baseUrl/comentarios/reportados'))
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode == 200) {
      final List<dynamic> datos = jsonDecode(respuesta.body);
      return datos
          .map((json) => ComentarioModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al cargar reportes');
  }

  Future<void> aprobarComentario(int id) async {
    final respuesta = await http.put(
      Uri.parse('$baseUrl/comentarios/$id/aprobar'),
    );
    if (respuesta.statusCode != 200) {
      throw Exception('No se pudo aprobar');
    }
  }

  Future<void> reportarComentario(int id) async {
    final respuesta = await http.put(
      Uri.parse('$baseUrl/comentarios/$id/reportar'),
    );

    if (respuesta.statusCode != 200) {
      throw Exception('HTTP ${respuesta.statusCode} - ${respuesta.body}');
    }
  }

  Future<void> eliminarComentario(int id) async {
    final respuesta = await http.delete(Uri.parse('$baseUrl/comentarios/$id'));
    if (respuesta.statusCode != 204 && respuesta.statusCode != 200) {
      throw Exception('No se pudo eliminar');
    }
  }
}
