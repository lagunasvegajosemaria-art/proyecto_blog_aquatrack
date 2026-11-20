import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../widgets/app_drawer.dart';

class AddBlogPage extends StatefulWidget {
  const AddBlogPage({super.key});

  @override
  State<AddBlogPage> createState() => _AddBlogPageState();
}

class _AddBlogPageState extends State<AddBlogPage> {
  final _formKey = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _descripcion = TextEditingController();
  final _contenido = TextEditingController();
  final _tags = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _foto;
  Uint8List? _imagenBytes;

  bool _guardando = false;
  Map<String, dynamic> _usuario = {};

  static const colorOscuro = Color(0xFF1e81b0);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _usuario = Map<String, dynamic>.from(args);
    }
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    _contenido.dispose();
    _tags.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto() async {
    final imagen = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );

    if (imagen != null) {
      final bytes = await imagen.readAsBytes();
      setState(() {
        _foto = imagen;
        _imagenBytes = bytes;
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_foto == null || _imagenBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor captura o selecciona una fotografía'),
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final dynamic rawId = _usuario['id_usr'] ?? _usuario['id'];
      final int? usuarioId = rawId is num
          ? rawId.toInt()
          : int.tryParse(rawId?.toString() ?? '');

      if (usuarioId == null) {
        throw Exception(
          'No se pudo identificar al autor. Vuelve a iniciar sesión.',
        );
      }

      final uri = Uri.parse('http://127.0.0.1:8000/blog');

      var request = http.MultipartRequest('POST', uri)
        ..fields['titulo'] = _titulo.text.trim()
        ..fields['descripcion'] = _descripcion.text.trim()
        ..fields['contenido'] = _contenido.text.trim()
        ..fields['tags'] = _tags.text.trim()
        ..fields['usr_id'] = usuarioId.toString()
        ..files.add(
          http.MultipartFile.fromBytes(
            'imagen',
            _imagenBytes!,
            filename: _foto!.name,
          ),
        );

      var streamedResponse = await request.send();
      var respuesta = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (respuesta.statusCode == 201 || respuesta.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publicación agregada correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        _titulo.clear();
        _descripcion.clear();
        _contenido.clear();
        _tags.clear();
        setState(() {
          _foto = null;
          _imagenBytes = null;
        });
      } else {
        throw Exception('Error del servidor: ${respuesta.body}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo guardar: ${e.toString().replaceFirst("Exception: ", "")}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _usuario['nom_usr']?.toString() ?? 'Administrador';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Agregar blog',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorOscuro,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      drawer: buildAppDrawer(usuario: _usuario, rutaActual: '/add-blog'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
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
                      const Text(
                        'Nueva publicación',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorOscuro,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Autor: $nombre',
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      ),
                      const SizedBox(height: 32),

                      TextFormField(
                        controller: _titulo,
                        decoration: InputDecoration(
                          labelText: 'Título del blog',
                          prefixIcon: const Icon(
                            Icons.title,
                            color: colorOscuro,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Ingresa el título'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _descripcion,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText:
                              'Resumen (aparece en la tarjeta principal)',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Ingresa un resumen'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _contenido,
                        maxLines: 8,
                        decoration: InputDecoration(
                          labelText: 'Contenido completo del blog',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Ingresa el contenido del blog'
                            : null,
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Imagen de portada',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      if (_imagenBytes != null)
                        Container(
                          height: 200,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              _imagenBytes!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 150,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'Sin fotografía seleccionada',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _seleccionarFoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Tomar / Seleccionar Foto'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorOscuro,
                            side: const BorderSide(color: colorOscuro),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _tags,
                        decoration: InputDecoration(
                          labelText: 'Etiquetas (ej. agua, salud, ahorro)',
                          prefixIcon: const Icon(
                            Icons.local_offer_outlined,
                            color: colorOscuro,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _guardando ? null : _guardar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorOscuro,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: _guardando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.publish),
                          label: Text(
                            _guardando ? 'Guardando...' : 'Publicar blog',
                            style: const TextStyle(
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
