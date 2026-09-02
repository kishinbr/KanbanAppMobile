class Coluna {
  final int id;
  final int quadroId;
  final String nome;

  Coluna({
    required this.id,
    required this.quadroId,
    required this.nome,
  });

  factory Coluna.fromJson(Map<String, dynamic> json) {
    return Coluna(
      id: json['id'],
      quadroId: json['quadroId'],
      nome: json['nome'],
    );
  }
}