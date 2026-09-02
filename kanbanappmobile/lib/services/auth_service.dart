import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class AuthService {
  // static const String baseUrl = 'http://10.0.2.2:8080/api/auth';
  static const String baseUrl = 'https://kanban-app.bluewave-06d366a7.chilecentral.azurecontainerapps.io/api/auth';

  Future<Usuario> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'senha': senha,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Usuario.fromJson(json);
    } else {
      throw Exception('Email ou senha inválidos');
    }
  }

  Future<Usuario> cadastro(String nome, String email, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cadastro'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'senha': senha,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Usuario.fromJson(json);
    } else {
      final json = jsonDecode(response.body);
      throw Exception(json['mensagem'] ?? 'Erro ao cadastrar');
    }
  }
}