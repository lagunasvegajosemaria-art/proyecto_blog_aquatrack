import 'package:flutter/material.dart';

import '../models/comentario_model.dart';
import '../services/comentario_service.dart';
import '../widgets/admin_drawer.dart';

class ReportedCommentsPage extends StatefulWidget {
  const ReportedCommentsPage({super.key});

  @override
  State<ReportedCommentsPage> createState() => _ReportedCommentsPageState();
}

class _ReportedCommentsPageState extends State<ReportedCommentsPage> {
  final ComentarioService _service = ComentarioService();
  late Future<List<ComentarioModel>> _futuroReportes;
  Map<String, dynamic> _usuarioActual = {};

  static const colorOscuro = Color(0xFF1e81b0);
  static const colorClaro = Color(0xFFa8d5e2);

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _usuarioActual = Map<String, dynamic>.from(args);
    }
  }

  void _cargarReportes() {
    setState(() {
      _futuroReportes = _service.obtenerReportados();
    });
  }

  void _mostrarMensaje(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _aprobar(int id) async {
    try {
      await _service.aprobarComentario(id);
      _cargarReportes();
      _mostrarMensaje('Comentario aprobado y restaurado');
    } catch (e) {
      _mostrarMensaje('Error: $e', error: true);
    }
  }

  Future<void> _eliminar(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Comentario'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este comentario permanentemente?',
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
      await _service.eliminarComentario(id);
      _cargarReportes();
      _mostrarMensaje('Comentario eliminado');
    } catch (e) {
      _mostrarMensaje('Error: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Comentarios Reportados',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorOscuro,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            onPressed: _cargarReportes,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      drawer: AdminDrawer(
        usuario: _usuarioActual,
        rutaActual: '/reported-comments',
      ),
      body: FutureBuilder<List<ComentarioModel>>(
        future: _futuroReportes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: colorOscuro),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final reportes = snapshot.data ?? [];
          if (reportes.isEmpty) {
            return const Center(
              child: Text('No hay comentarios reportados. ¡Todo está limpio!'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          colorClaro.withOpacity(0.3),
                        ),
                        dataRowMinHeight: 70,
                        dataRowMaxHeight: 70,
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Autor',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorOscuro,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Comentario',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorOscuro,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Fecha',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorOscuro,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Acciones',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorOscuro,
                              ),
                            ),
                          ),
                        ],
                        rows: reportes.map((c) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 18,
                                      color: colorOscuro,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      c.autorNombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 300,
                                  child: Text(
                                    c.comentario,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  c.fecha.length > 10
                                      ? c.fecha.substring(0, 10)
                                      : c.fecha,
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.check_circle_outline,
                                        color: Colors.green,
                                      ),
                                      tooltip: 'Aprobar / Restaurar',
                                      onPressed: () => _aprobar(c.id),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Eliminar Definitivamente',
                                      onPressed: () => _eliminar(c.id),
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
