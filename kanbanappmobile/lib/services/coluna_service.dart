import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ColunaService {
  static const String baseUrl =
      'https://kanban-app.bluewave-06d366a7.chilecentral.azurecontainerapps.io/api/colunas';

  final _storageService = StorageService();

  Future<int> criar(int quadroId, String nome) async {
    final token = await _storageService.obterToken();

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'quadroId': quadroId,
        'nome': nome,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['colunaId'];
    } else {
      throw Exception('Erro ao criar a coluna');
    }
  }
  Future<void> excluir(int colunaId) async {
    final token = await _storageService.obterToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/$colunaId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao excluir a coluna');
    }
  }
  Future<void> editar(int colunaId, String nome) async {
    final token = await _storageService.obterToken();

    final response = await http.put(
      Uri.parse('$baseUrl/$colunaId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'nome': nome}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao editar a coluna');
    }
  }
}