import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quadro.dart';
import 'storage_service.dart';

class QuadroService {
  static const String baseUrl =
      'https://kanban-app.bluewave-06d366a7.chilecentral.azurecontainerapps.io/api/quadros';

  final _storageService = StorageService();

  Future<List<Quadro>> listar() async {
    final token = await _storageService.obterToken();

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> lista = jsonDecode(response.body);
      return lista.map((json) => Quadro.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar os quadros');
    }
  }
}