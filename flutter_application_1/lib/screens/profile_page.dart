import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/app_drawer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _direccion = TextEditingController();

  Map<String, dynamic> _usuario = {};
  bool _cargando = false;
  bool _inicializado = false;

  static const colorOscuro = Color(0xFF1e81b0);
  static const colorClaro = Color(0xFFa8d5e2);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _usuario = Map<String, dynamic>.from(args);
    }

    _nombre.text = _usuario['nom_usr']?.toString() ?? '';
    _correo.text = _usuario['mail']?.toString() ?? '';
    _direccion.text = _usuario['dir_usr']?.toString() ?? '';

    _inicializado = true;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _direccion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      final userService = UserService();
      final dynamic rawId =
          _usuario['id_usr'] ?? _usuario['id'] ?? _usuario['id_usuario'];
      int? id = rawId != null
          ? (rawId is num
                ? rawId.toInt()
                : int.tryParse(rawId.toString().trim()))
          : null;

      if (id == null || id <= 0) {
        final miCorreoOriginal = _usuario['mail']?.toString() ?? '';
        if (miCorreoOriginal.isEmpty)
          throw Exception('No se pudo identificar tu correo.');

        final usuarios = await userService.obtenerUsuarios();
        final usuarioDb = usuarios.firstWhere(
          (u) => u.correo.toLowerCase() == miCorreoOriginal.toLowerCase(),
          orElse: () =>
              throw Exception('No se encontró tu usuario en el sistema.'),
        );
        id = usuarioDb.id;
      }

      if (id <= 0)
        throw Exception('No se pudo obtener un ID válido para guardar.');

      final usuarioActualizado = UserModel(
        id: id,
        nombre: _nombre.text.trim(),
        correo: _correo.text.trim().toLowerCase(),
        direccion: _direccion.text.trim(),
        tipoUsuario: (_usuario['tip_usu'] as num?)?.toInt() ?? 2,
      );

      await userService.actualizarUsuario(usuarioActualizado);

      if (!mounted) return;

      setState(() {
        _usuario['nom_usr'] = usuarioActualizado.nombre;
        _usuario['mail'] = usuarioActualizado.correo;
        _usuario['dir_usr'] = usuarioActualizado.direccion;
        _usuario['id_usr'] = id;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo actualizar: ${e.toString().replaceFirst("Exception: ", "")}',
          ),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarDialogoCambiarPassword() {
    final passController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool guardando = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Cambiar Contraseña',
                style: TextStyle(
                  color: colorOscuro,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: passController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Nueva Contraseña',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: colorOscuro,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (v) => v == null || v.length < 8
                          ? 'Mínimo 8 caracteres'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: confirmController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Contraseña',
                        prefixIcon: const Icon(
                          Icons.lock_reset,
                          color: colorOscuro,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (v) => v != passController.text
                          ? 'Las contraseñas no coinciden'
                          : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: guardando ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: guardando
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setStateDialog(() => guardando = true);
                          try {
                            final dynamic rawId =
                                _usuario['id_usr'] ?? _usuario['id'];
                            final int id = rawId is num
                                ? rawId.toInt()
                                : int.parse(rawId.toString());

                            await UserService().cambiarPassword(
                              id,
                              passController.text,
                            );
                            if (!mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Contraseña actualizada con éxito',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            setStateDialog(() => guardando = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceFirst('Exception: ', ''),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: colorOscuro),
                  child: guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Actualizar',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Mi perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorOscuro,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      drawer: buildAppDrawer(usuario: _usuario, rutaActual: '/profile'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: colorClaro,
                          child: Icon(
                            Icons.person,
                            size: 56,
                            color: colorOscuro,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _nombre.text.isEmpty ? 'Usuario' : _nombre.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colorOscuro,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _nombre,
                        decoration: InputDecoration(
                          labelText: 'Nombre completo',
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: colorOscuro,
                          ),
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
                        validator: (v) => v == null || v.trim().length < 2
                            ? 'Ingresa un nombre válido'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _correo,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: colorOscuro,
                          ),
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
                        validator: (v) => v == null || !v.contains('@')
                            ? 'Ingresa un correo válido'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _direccion,
                        decoration: InputDecoration(
                          labelText: 'Dirección (opcional)',
                          prefixIcon: const Icon(
                            Icons.location_on_outlined,
                            color: colorOscuro,
                          ),
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
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorOscuro,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _cargando ? null : _guardar,
                          icon: _cargando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            _cargando ? 'Guardando...' : 'Guardar cambios',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorOscuro,
                            side: const BorderSide(
                              color: colorOscuro,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _mostrarDialogoCambiarPassword,
                          icon: const Icon(Icons.password),
                          label: const Text(
                            'Cambiar Contraseña',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
