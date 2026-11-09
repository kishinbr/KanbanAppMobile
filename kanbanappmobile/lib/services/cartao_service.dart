import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import 'storage_service.dart';

class CartaoService {
  final _storageService = StorageService();

  Future<Database> get _db => DatabaseService.instance.db;

  /// Garante que o usuário logado é dono do quadro ao qual a coluna pertence.
  Future<void> _exigirDonoPelaColuna(int colunaId) async {
    final usuarioId = await _storageService.exigirUsuarioId();
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT 1 FROM colunas c
      JOIN membros m ON m.quadro_id = c.quadro_id
      WHERE c.id = ? AND m.usuario_id = ? AND m.papel = 'dono'
    ''', [colunaId, usuarioId]);
    if (rows.isEmpty) throw Exception('Apenas o dono pode editar o kanban');
  }

  Future<int> _colunaDoCartao(int cartaoId) async {
    final db = await _db;
    final rows = await db.query('cartoes',
        columns: ['coluna_id'], where: 'id = ?', whereArgs: [cartaoId]);
    if (rows.isEmpty) throw Exception('Cartão não encontrado');
    return rows.first['coluna_id'] as int;
  }

  Future<int> criar(int colunaId, String titulo, String? descricao) async {
    await _exigirDonoPelaColuna(colunaId);
    final db = await _db;
    final r = await db.rawQuery(
        'SELECT COALESCE(MAX(ordem) + 1, 0) AS proxima FROM cartoes WHERE coluna_id = ?',
        [colunaId]);
    return db.insert('cartoes', {
      'coluna_id': colunaId,
      'titulo': titulo,
      'descricao': descricao,
      'ordem': r.first['proxima'] as int,
    });
  }

  Future<void> editar(int cartaoId, String titulo, String? descricao) async {
    await _exigirDonoPelaColuna(await _colunaDoCartao(cartaoId));
    final db = await _db;
    await db.update('cartoes', {'titulo': titulo, 'descricao': descricao},
        where: 'id = ?', whereArgs: [cartaoId]);
  }

  Future<void> excluir(int cartaoId) async {
    await _exigirDonoPelaColuna(await _colunaDoCartao(cartaoId));
    final db = await _db;
    await db.delete('cartoes', where: 'id = ?', whereArgs: [cartaoId]);
  }

  Future<void> mover(int cartaoId, int novaColunaId, int novaOrdem) async {
    final colunaAtual = await _colunaDoCartao(cartaoId);
    await _exigirDonoPelaColuna(colunaAtual);
    await _exigirDonoPelaColuna(novaColunaId);
    final db = await _db;
    await db.transaction((txn) async {
      // abre espaço na coluna de destino
      await txn.rawUpdate(
          'UPDATE cartoes SET ordem = ordem + 1 WHERE coluna_id = ? AND ordem >= ?',
          [novaColunaId, novaOrdem]);
      await txn.update('cartoes', {'coluna_id': novaColunaId, 'ordem': novaOrdem},
          where: 'id = ?', whereArgs: [cartaoId]);
    });
  }
}
