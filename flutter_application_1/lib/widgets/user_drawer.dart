import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDrawer extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final String rutaActual;

  const UserDrawer({
    super.key,
    required this.usuario,
    required this.rutaActual,
  });

  // 👇 DEFINIMOS LOS COLORES AQUÍ
  static const colorOscuro = Color(0xFF1e81b0);
  static const colorClaro = Color(0xFFa8d5e2);

  String get nombre => usuario['nom_usr']?.toString() ?? 'Usuario';
  String get correo => usuario['mail']?.toString() ?? '';

  void _navegar(BuildContext context, String ruta) {
    Navigator.pop(context);
    if (ruta == rutaActual) return;
    Navigator.pushReplacementNamed(context, ruta, arguments: usuario);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: colorOscuro),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: colorOscuro, size: 34),
              ),
              accountName: Text(nombre),
              accountEmail: Text(correo),
            ),

            _opcion(context, Icons.home_outlined, 'Blog', '/blog'),
            _opcion(context, Icons.post_add, 'Agregar blog', '/add-blog'),
            _opcion(
              context,
              Icons.account_circle_outlined,
              'Mi perfil',
              '/profile',
            ),

            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _opcion(
    BuildContext context,
    IconData icono,
    String titulo,
    String ruta,
  ) {
    final seleccionado = ruta == rutaActual;

    return ListTile(
      leading: Icon(
        icono,
        color: seleccionado ? colorOscuro : Colors.grey[700],
      ),
      title: Text(
        titulo,
        style: TextStyle(
          fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
          color: seleccionado ? colorOscuro : Colors.black87,
        ),
      ),
      tileColor: seleccionado ? colorClaro.withOpacity(0.3) : null,
      selected: seleccionado,
      onTap: () => _navegar(context, ruta),
    );
  }
}
