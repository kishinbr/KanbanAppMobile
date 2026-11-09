import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import '../models/usuario.dart';
import 'database_service.dart';

class AuthService {
  String _hash(String senha) => sha256.convert(utf8.encode(senha)).toString();

  Future<Usuario> login(String email, String senha) async {
    final db = await DatabaseService.instance.db;
    final rows = await db.query(
      'usuarios',
      where: 'email = ? AND senha_hash = ?',
      whereArgs: [email.trim().toLowerCase(), _hash(senha)],
    );

    if (rows.isEmpty) {
      throw Exception('Email ou senha inválidos');
    }
    final u = rows.first;
    return Usuario(
      id: u['id'] as int,
      nome: u['nome'] as String,
      email: u['email'] as String,
      // Sem servidor não existe JWT; o "token" passa a ser só o id do usuário.
      token: '${u['id']}',
    );
  }

  Future<Usuario> cadastro(String nome, String email, String senha) async {
    final db = await DatabaseService.instance.db;
    final emailNormalizado = email.trim().toLowerCase();
    try {
      final id = await db.insert('usuarios', {
        'nome': nome,
        'email': emailNormalizado,
        'senha_hash': _hash(senha),
      });
      return Usuario(id: id, nome: nome, email: emailNormalizado, token: '$id');
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception('Este email já está cadastrado');
      }
      throw Exception('Erro ao cadastrar');
    }
  }
}
