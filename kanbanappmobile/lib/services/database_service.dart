import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Banco SQLite local que substitui a API na nuvem.
/// Todos os dados ficam salvos no próprio aparelho.
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _abrir();
    return _db!;
  }

  Future<Database> _abrir() async {
    final caminho = join(await getDatabasesPath(), 'kanban.db');
    return openDatabase(
      caminho,
      version: 1,
      onConfigure: (db) async {
        // Necessário para o ON DELETE CASCADE funcionar no SQLite
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            senha_hash TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE quadros (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            usuario_dono_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
            codigo_compartilhamento TEXT NOT NULL UNIQUE
          )
        ''');
        await db.execute('''
          CREATE TABLE membros (
            quadro_id INTEGER NOT NULL REFERENCES quadros(id) ON DELETE CASCADE,
            usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
            papel TEXT NOT NULL,
            PRIMARY KEY (quadro_id, usuario_id)
          )
        ''');
        await db.execute('''
          CREATE TABLE colunas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            quadro_id INTEGER NOT NULL REFERENCES quadros(id) ON DELETE CASCADE,
            nome TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE cartoes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            coluna_id INTEGER NOT NULL REFERENCES colunas(id) ON DELETE CASCADE,
            titulo TEXT NOT NULL,
            descricao TEXT,
            ordem INTEGER NOT NULL
          )
        ''');
      },
    );
  }
}
