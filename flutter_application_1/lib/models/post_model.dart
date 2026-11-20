class PostModel {
  final int id;
  final String titulo;
  final String descripcion; // 👈 Resumen corto (para la tarjeta)
  final String contenido; // 👈 Texto completo (para el detalle)
  final String autor;
  final String fecha;
  final String imagen;
  final String categoria;

  PostModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.contenido,
    required this.autor,
    required this.fecha,
    required this.imagen,
    required this.categoria,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id_blog'] is int
          ? json['id_blog']
          : int.parse(json['id_blog'].toString()),
      titulo: json['titulo']?.toString() ?? 'Sin título',

      // Mapeamos el resumen
      descripcion: json['descripcion']?.toString() ?? '',

      // Mapeamos el contenido completo
      contenido: json['contenido']?.toString() ?? '',

      // Mapeamos el autor (que viene como nom_usr de Python)
      autor: json['nom_usr']?.toString() ?? 'Anónimo',

      fecha: json['fecha']?.toString() ?? 'Reciente',
      imagen: json['img']?.toString() ?? '',
      categoria: json['tags']?.toString() ?? 'General',
    );
  }
}
