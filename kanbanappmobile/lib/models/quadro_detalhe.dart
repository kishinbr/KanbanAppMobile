import 'quadro.dart';
import 'coluna.dart';
import 'cartao.dart';

class ColunaComCartoes {
  final Coluna coluna;
  final List<Cartao> cartoes;

  ColunaComCartoes({
    required this.coluna,
    required this.cartoes,
  });

  factory ColunaComCartoes.fromJson(Map<String, dynamic> json) {
    return ColunaComCartoes(
      coluna: Coluna.fromJson(json['coluna']),
      cartoes: (json['cartoes'] as List)
          .map((item) => Cartao.fromJson(item))
          .toList(),
    );
  }
}

class Membro {
  final String nome;
  final String papel;

  Membro({required this.nome, required this.papel});

  factory Membro.fromJson(Map<String, dynamic> json) {
    return Membro(
      nome: json['nome'],
      papel: json['papel'],
    );
  }
}

class QuadroDetalhe {
  final Quadro quadro;
  final String papel;
  final List<ColunaComCartoes> colunas;
  final List<Membro> membros;

  QuadroDetalhe({
    required this.quadro,
    required this.papel,
    required this.colunas,
    required this.membros,
  });

  factory QuadroDetalhe.fromJson(Map<String, dynamic> json) {
    return QuadroDetalhe(
      quadro: Quadro.fromJson(json['quadro']),
      papel: json['papel'],
      colunas: (json['colunas'] as List)
          .map((item) => ColunaComCartoes.fromJson(item))
          .toList(),
      membros: (json['membros'] as List)
          .map((item) => Membro.fromJson(item))
          .toList(),
    );
  }
}