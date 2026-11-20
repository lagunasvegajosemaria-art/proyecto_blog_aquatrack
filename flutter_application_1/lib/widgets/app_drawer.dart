import 'package:flutter/material.dart';

import 'admin_drawer.dart';
import 'user_drawer.dart';

Widget buildAppDrawer({
  required Map<String, dynamic> usuario,
  required String rutaActual,
}) {
  final esAdmin = (usuario['tip_usu'] as num? ?? 2).toInt() == 1;
  return esAdmin
      ? AdminDrawer(usuario: usuario, rutaActual: rutaActual)
      : UserDrawer(usuario: usuario, rutaActual: rutaActual);
}
