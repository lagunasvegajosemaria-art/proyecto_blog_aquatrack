class UserModel {
  final int id;
  final String nombre;
  final String correo;
  final String? password;
  final String? direccion;
  final int tipoUsuario;

  UserModel({
    required this.id,
    required this.nombre,
    required this.correo,
    this.password,
    this.direccion,
    this.tipoUsuario = 1,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawId =
        json['id_usr'] ??
        json['id'] ??
        json['id_usuario'] ??
        json['usuario_id'];

    int idParseado = 0;
    if (rawId != null) {
      idParseado = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;
    }

    return UserModel(
      id: idParseado,
      nombre: json['nom_usr']?.toString() ?? '',
      correo: json['mail']?.toString() ?? '',
      direccion: json['dir_usr']?.toString(),
      tipoUsuario: (json['tip_usu'] is int)
          ? json['tip_usu']
          : int.tryParse(json['tip_usu']?.toString() ?? '2') ?? 2,
    );
  }

  Map<String, dynamic> toJsonCrear() {
    return {
      'nom_usr': nombre,
      'mail': correo,
      'password': password,
      'dir_usr': direccion,
      'tip_usu': tipoUsuario,
    };
  }
}
