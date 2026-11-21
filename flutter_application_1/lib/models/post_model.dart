class PostModel {
  final int id;
  final String titulo;
  final String descripcion;
  final String contenido;
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

      descripcion: json['descripcion']?.toString() ?? '',

      contenido: json['contenido']?.toString() ?? '',

      autor: json['nom_usr']?.toString() ?? 'Anónimo',

      fecha: json['fecha']?.toString() ?? 'Reciente',
      imagen: json['img']?.toString() ?? '',
      categoria: json['tags']?.toString() ?? 'General',
    );
  }
}
