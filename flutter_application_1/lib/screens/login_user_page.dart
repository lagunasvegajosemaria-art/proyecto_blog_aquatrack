import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/spacing.dart';
import '../services/auth_service.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'contra_user_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();

  bool ocultarPassword = true;
  bool cargando = false;

  // Paleta AquaTrack
  static const colorOscuro = Color(0xFF1e81b0);

  @override
  void initState() {
    super.initState();

    usuarioController.clear();
    passwordController.clear();
  }

  @override
  void dispose() {
    usuarioController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> iniciarSesion() async {
    FocusScope.of(context).unfocus();

    final mensaje = authService.validarLogin(
      usuario: usuarioController.text,
      password: passwordController.text,
    );

    if (mensaje != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensaje)));
      return;
    }

    setState(() => cargando = true);

    try {
      final usuario = await authService.autenticar(
        correo: usuarioController.text,
        password: passwordController.text,
      );

      if (!mounted) return;

      final int tipoUsuario = (usuario['tip_usu'] as num?)?.toInt() ?? 2;
      final int idUsuario = (usuario['id_usr'] ?? usuario['id']) is num
          ? (usuario['id_usr'] ?? usuario['id']).toInt()
          : int.tryParse((usuario['id_usr'] ?? usuario['id']).toString()) ?? 0;

      final String nombreUsuario =
          usuario['nom_usr'] ?? usuario['nombre'] ?? 'Usuario';
      final String correoUsuario =
          usuario['mail'] ?? usuario['correo'] ?? usuarioController.text;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('id_usr', idUsuario);
      await prefs.setString('nom_usr', nombreUsuario);
      await prefs.setString('mail', correoUsuario);
      await prefs.setInt('tip_usu', tipoUsuario);

      final Map<String, dynamic> datos = {
        'id': idUsuario,
        'id_usr': idUsuario,
        'nom_usr': nombreUsuario,
        'mail': correoUsuario,
        'tip_usu': tipoUsuario,
      };

      if (tipoUsuario == 1) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/users',
          (route) => false,
          arguments: datos,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/blog',
          (route) => false,
          arguments: datos,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.maxFormWidth),
            child: AuthCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.water_drop,
                    size: AppSizes.iconLarge,
                    color: colorOscuro,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'INICIAR SESIÓN',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: colorOscuro,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Campo Correo
                  CustomTextField(
                    controller: usuarioController,
                    label: 'Correo electrónico',
                    prefixIcon: Icons.person,
                    keyboardType: TextInputType.emailAddress,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () => usuarioController.clear(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Campo Contraseña
                  CustomTextField(
                    controller: passwordController,
                    label: 'Contraseña',
                    prefixIcon: Icons.lock_outline,
                    obscureText: ocultarPassword,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () => passwordController.clear(),
                        ),
                        IconButton(
                          icon: Icon(
                            ocultarPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(
                            () => ocultarPassword = !ocultarPassword,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContraPage(),
                          ),
                        );
                      },
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(fontSize: 13, color: colorOscuro),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: PrimaryButton(
                      text: cargando ? 'Validando...' : 'Ingresar',
                      onPressed: cargando ? () {} : iniciarSesion,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿No tienes cuenta?'),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/register'),
                        child: const Text(
                          'Registrarse',
                          style: TextStyle(
                            color: colorOscuro,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
