import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _chaveToken = 'token';
  static const _chaveNome = 'nome';
  static const _chaveEmail = 'email';
  static const _chaveUsuarioId = 'usuarioId';

  Future<void> salvarSessao({
    required String token,
    required String nome,
    required String email,
    required int usuarioId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveToken, token);
    await prefs.setString(_chaveNome, nome);
    await prefs.setString(_chaveEmail, email);
    await prefs.setInt(_chaveUsuarioId, usuarioId);
  }

  Future<String?> obterToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chaveToken);
  }

  Future<String?> obterNome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chaveNome);
  }

  Future<void> limparSessao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}