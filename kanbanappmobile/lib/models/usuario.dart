class Usuario {
  final int id;
  final String nome;
  final String email;
  final String token;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.token,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['usuarioId'],
      nome: json['nome'],
      email: json['email'],
      token: json['token'],
    );
  }
}