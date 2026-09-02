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

  Future<int> criar(String nome) async {
    final token = await _storageService.obterToken();

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'nome': nome}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['quadroId'];
    } else {
      throw Exception('Erro ao criar o kanban');
    }
  }
  Future<void> entrar(String codigo) async {
    final token = await _storageService.obterToken();

    final response = await http.post(
      Uri.parse('$baseUrl/entrar'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'codigo': codigo}),
    );

    if (response.statusCode != 200) {
      final json = jsonDecode(response.body);
      throw Exception(json['mensagem'] ?? 'Erro ao entrar no kanban');
    }
  }
}