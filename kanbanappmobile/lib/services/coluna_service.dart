import 'database_service.dart';
import 'storage_service.dart';

class ColunaService {
  final _storageService = StorageService();

  Future<void> _exigirDonoDoQuadro(int quadroId) async {
    final usuarioId = await _storageService.exigirUsuarioId();
    final db = await DatabaseService.instance.db;
    final rows = await db.query('membros',
        where: "quadro_id = ? AND usuario_id = ? AND papel = 'dono'",
        whereArgs: [quadroId, usuarioId]);
    if (rows.isEmpty) throw Exception('Apenas o dono pode editar o kanban');
  }

  Future<int> _quadroDaColuna(int colunaId) async {
    final db = await DatabaseService.instance.db;
    final rows = await db.query('colunas',
        columns: ['quadro_id'], where: 'id = ?', whereArgs: [colunaId]);
    if (rows.isEmpty) throw Exception('Coluna não encontrada');
    return rows.first['quadro_id'] as int;
  }

  Future<int> criar(int quadroId, String nome) async {
    await _exigirDonoDoQuadro(quadroId);
    final db = await DatabaseService.instance.db;
    return db.insert('colunas', {'quadro_id': quadroId, 'nome': nome});
  }

  Future<void> excluir(int colunaId) async {
    await _exigirDonoDoQuadro(await _quadroDaColuna(colunaId));
    final db = await DatabaseService.instance.db;
    await db.delete('colunas', where: 'id = ?', whereArgs: [colunaId]);
  }

  Future<void> editar(int colunaId, String nome) async {
    await _exigirDonoDoQuadro(await _quadroDaColuna(colunaId));
    final db = await DatabaseService.instance.db;
    await db.update('colunas', {'nome': nome},
        where: 'id = ?', whereArgs: [colunaId]);
  }
}
