class Quadro {
  final int id;
  final String nome;
  final int usuarioDonoId;
  final String codigoCompartilhamento;
  final String papel;

  Quadro({
    required this.id,
    required this.nome,
    required this.usuarioDonoId,
    required this.codigoCompartilhamento,
    required this.papel,
  });

  factory Quadro.fromJson(Map<String, dynamic> json) {
    return Quadro(
      id: json['id'],
      nome: json['nome'],
      usuarioDonoId: json['usuarioDonoId'],
      codigoCompartilhamento: json['codigoCompartilhamento'],
      papel: json['papel'],
    );
  }
}