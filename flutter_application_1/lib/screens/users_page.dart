import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/admin_drawer.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final UserService userService = UserService();
  late Future<List<UserModel>> futuroUsuarios;

  static const colorOscuro = Color(0xFF1e81b0);
  static const colorClaro = Color(0xFFa8d5e2);

  @override
  void initState() {
    super.initState();
    futuroUsuarios = userService.obtenerUsuarios();
  }

  void recargarUsuarios() {
    setState(() {
      futuroUsuarios = userService.obtenerUsuarios();
    });
  }

  void mostrarMensaje(String mensaje, {bool esError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> mostrarFormulario({UserModel? usuario}) async {
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _UserFormDialog(usuarioAEditar: usuario, userService: userService),
    );

    if (resultado == true && mounted) {
      recargarUsuarios();
      mostrarMensaje(
        usuario == null
            ? 'Usuario registrado correctamente'
            : 'Usuario actualizado correctamente',
      );
    }
  }

  Future<void> eliminarUsuario(UserModel usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar usuario'),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${usuario.nombre}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Sí, eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await userService.eliminarUsuario(usuario.id);
      if (!mounted) return;
      recargarUsuarios();
      mostrarMensaje('Usuario eliminado correctamente');
    } catch (e) {
      mostrarMensaje('No se pudo eliminar: $e', esError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final argumentos = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic> usuario = argumentos is Map
        ? Map<String, dynamic>.from(argumentos)
        : {};

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Gestión de usuarios',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorOscuro,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            onPressed: recargarUsuarios,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      drawer: AdminDrawer(usuario: usuario, rutaActual: '/users'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => mostrarFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo usuario'),
        backgroundColor: colorOscuro,
      ),
      body: FutureBuilder<List<UserModel>>(
        future: futuroUsuarios,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text('No se pudieron cargar los usuarios.'),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: recargarUsuarios,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorOscuro,
                      ),
                      child: const Text(
                        'Reintentar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final usuarios = snapshot.data ?? [];
          if (usuarios.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        horizontalMargin: 24,
                        columnSpacing: 60,
                        headingRowHeight: 60,
                        dataRowMinHeight: 80,
                        dataRowMaxHeight: 80,
                        headingRowColor: MaterialStateProperty.all(
                          colorClaro.withOpacity(0.3),
                        ),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Usuario',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: colorOscuro,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Correo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: colorOscuro,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Rol',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: colorOscuro,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Acciones',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: colorOscuro,
                              ),
                            ),
                          ),
                        ],
                        rows: usuarios.map((usuario) {
                          final esAdmin = usuario.tipoUsuario == 1;
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: esAdmin
                                          ? colorClaro
                                          : Colors.grey[200],
                                      child: Text(
                                        usuario.nombre.isNotEmpty
                                            ? usuario.nombre[0].toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: esAdmin
                                              ? colorOscuro
                                              : Colors.grey[800],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      usuario.nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  usuario.correo,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    Icon(
                                      esAdmin
                                          ? Icons.admin_panel_settings
                                          : Icons.person,
                                      size: 20,
                                      color: esAdmin
                                          ? colorOscuro
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      esAdmin ? 'Administrador' : 'Usuario',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: esAdmin
                                            ? colorOscuro
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      iconSize: 28,
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: colorOscuro,
                                      ),
                                      tooltip: 'Editar',
                                      onPressed: () =>
                                          mostrarFormulario(usuario: usuario),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      iconSize: 28,
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Eliminar',
                                      onPressed: () => eliminarUsuario(usuario),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Diálogo del formulario
class _UserFormDialog extends StatefulWidget {
  final UserModel? usuarioAEditar;
  final UserService userService;
  const _UserFormDialog({
    required this.usuarioAEditar,
    required this.userService,
  });
  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _correoController;
  late TextEditingController _direccionController;
  final TextEditingController _passwordController = TextEditingController();
  int _tipoUsuario = 1;
  bool _guardando = false;
  bool _verPassword = false;
  static const colorOscuro = Color(0xFF1e81b0);
  bool get _esEdicion => widget.usuarioAEditar != null;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.usuarioAEditar?.nombre ?? '',
    );
    _correoController = TextEditingController(
      text: widget.usuarioAEditar?.correo ?? '',
    );
    _direccionController = TextEditingController(
      text: widget.usuarioAEditar?.direccion ?? '',
    );
    _tipoUsuario = widget.usuarioAEditar?.tipoUsuario ?? 1;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final direccion = _direccionController.text.trim();
      if (_esEdicion) {
        final actualizado = UserModel(
          id: widget.usuarioAEditar!.id,
          nombre: _nombreController.text.trim(),
          correo: _correoController.text.trim(),
          direccion: direccion.isEmpty ? null : direccion,
          tipoUsuario: _tipoUsuario,
        );
        await widget.userService.actualizarUsuario(actualizado);
      } else {
        final nuevo = UserModel(
          id: 0,
          nombre: _nombreController.text.trim(),
          correo: _correoController.text.trim(),
          password: _passwordController.text,
          direccion: direccion.isEmpty ? null : direccion,
          tipoUsuario: _tipoUsuario,
        );
        await widget.userService.agregarUsuario(nuevo);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        _esEdicion ? 'Editar usuario' : 'Nuevo usuario',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: colorOscuro,
        ),
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: colorOscuro,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'El nombre es obligatorio'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _correoController,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: colorOscuro,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (v) => v == null || !v.contains('@')
                      ? 'Ingresa un correo válido'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _direccionController,
                  decoration: InputDecoration(
                    labelText: 'Dirección (opcional)',
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: colorOscuro,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (!_esEdicion) ...[
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_verPassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: colorOscuro,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _verPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _verPassword = !_verPassword),
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
                ],
                DropdownButtonFormField<int>(
                  value: _tipoUsuario,
                  decoration: InputDecoration(
                    labelText: 'Rol del usuario',
                    prefixIcon: const Icon(
                      Icons.badge_outlined,
                      color: colorOscuro,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Administrador')),
                    DropdownMenuItem(value: 2, child: Text('Usuario normal')),
                  ],
                  onChanged: _guardando
                      ? null
                      : (v) => setState(() => _tipoUsuario = v!),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _guardando ? null : _guardar,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorOscuro,
            foregroundColor: Colors.white,
          ),
          child: _guardando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(_esEdicion ? 'Actualizar' : 'Guardar'),
        ),
      ],
    );
  }
}
