import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class CartaoService {
  static const String baseUrl =
      'https://kanban-app.bluewave-06d366a7.chilecentral.azurecontainerapps.io/api/cartoes';

  final _storageService = StorageService();

  Future<int> criar(int colunaId, String titulo, String? descricao) async {
    final token = await _storageService.obterToken();

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'colunaId': colunaId,
        'titulo': titulo,
        'descricao': descricao,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['cartaoId'];
    } else {
      throw Exception('Erro ao criar o cartão');
    }
  }
}