class Cartao {
  final int id;
  final int colunaId;
  final String titulo;
  final String? descricao;
  final int ordem;

  Cartao({
    required this.id,
    required this.colunaId,
    required this.titulo,
    this.descricao,
    required this.ordem,
  });

  factory Cartao.fromJson(Map<String, dynamic> json) {
    return Cartao(
      id: json['id'],
      colunaId: json['colunaId'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      ordem: json['ordem'],
    );
  }
}