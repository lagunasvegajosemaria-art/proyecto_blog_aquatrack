import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user_model.dart';

class UserService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<List<UserModel>> obtenerUsuarios() async {
    final respuesta = await http
        .get(Uri.parse('$baseUrl/usuarios'))
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode != 200) {
      throw Exception('Error al consultar usuarios: ${respuesta.statusCode}');
    }

    final List<dynamic> datos = jsonDecode(respuesta.body);
    return datos
        .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<UserModel> agregarUsuario(UserModel usuario) async {
    final respuesta = await http
        .post(
          Uri.parse('$baseUrl/usuarios'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(usuario.toJsonCrear()),
        )
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode == 201 || respuesta.statusCode == 200) {
      return UserModel.fromJson(
        jsonDecode(respuesta.body) as Map<String, dynamic>,
      );
    }
    throw Exception(
      'Error al procesar la solicitud (HTTP ${respuesta.statusCode})',
    );
  }

  Future<bool> actualizarUsuario(UserModel usuario) async {
    if (usuario.id <= 0) {
      throw Exception(
        'El ID del usuario es inválido (0). No se puede actualizar.',
      );
    }

    final respuesta = await http
        .put(
          Uri.parse('$baseUrl/usuarios/${usuario.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'nom_usr': usuario.nombre.trim(),
            'mail': usuario.correo.trim().toLowerCase(),
            'dir_usr': usuario.direccion?.trim() ?? '',
            'tip_usu': usuario.tipoUsuario,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
      return true;
    }

    final dynamic resultado = respuesta.body.isNotEmpty
        ? jsonDecode(respuesta.body)
        : null;

    if (resultado is Map && resultado['detail'] != null) {
      final detail = resultado['detail'];
      if (detail is List) {
        final mensajes = detail
            .map((e) => '${e['loc']?.last}: ${e['msg']}')
            .join('\n');
        throw Exception(mensajes);
      }
      throw Exception(detail.toString());
    }

    throw Exception('Error al actualizar: HTTP ${respuesta.statusCode}');
  }

  Future<bool> eliminarUsuario(int usuarioId) async {
    final respuesta = await http
        .delete(
          Uri.parse('$baseUrl/usuarios/$usuarioId'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode == 200 || respuesta.statusCode == 204) {
      return true;
    }

    final dynamic resultado = respuesta.body.isNotEmpty
        ? jsonDecode(respuesta.body)
        : null;

    if (resultado is Map && resultado['detail'] != null) {
      throw Exception(resultado['detail'].toString());
    }

    throw Exception('Error al eliminar usuario: HTTP ${respuesta.statusCode}');
  }

  Future<String> recuperarPassword(String nombre, String correo) async {
    final respuesta = await http
        .post(
          Uri.parse('$baseUrl/usuarios/recuperar'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'nom_usr': nombre.trim(),
            'mail': correo.trim().toLowerCase(),
          }),
        )
        .timeout(const Duration(seconds: 10));

    final data = jsonDecode(respuesta.body);

    if (respuesta.statusCode == 200) {
      return data['password_temporal'];
    } else {
      throw Exception(data['detail'] ?? 'Error al recuperar la contraseña');
    }
  }

  Future<void> cambiarPassword(int id, String nuevaPassword) async {
    final res = await http.put(
      Uri.parse('$baseUrl/usuarios/$id/password'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'new_password': nuevaPassword}),
    );
    if (res.statusCode != 200) {
      final error = jsonDecode(res.body);
      throw Exception(error['detail'] ?? 'Error al cambiar la contraseña');
    }
  }
}
