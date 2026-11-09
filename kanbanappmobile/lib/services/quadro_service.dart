import 'dart:math';
import 'package:sqflite/sqflite.dart';
import '../models/quadro.dart';
import '../models/coluna.dart';
import '../models/cartao.dart';
import '../models/quadro_detalhe.dart';
import 'database_service.dart';
import 'storage_service.dart';

class QuadroService {
  final _storageService = StorageService();

  Future<Database> get _db => DatabaseService.instance.db;

  String _gerarCodigo() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random.secure();
    return List.generate(6, (_) => chars[r.nextInt(chars.length)]).join();
  }

  Quadro _quadroFromRow(Map<String, Object?> r) => Quadro(
        id: r['id'] as int,
        nome: r['nome'] as String,
        usuarioDonoId: r['usuario_dono_id'] as int,
        codigoCompartilhamento: r['codigo_compartilhamento'] as String,
        papel: r['papel'] as String,
      );

  Future<String> _papel(Database db, int quadroId, int usuarioId) async {
    final rows = await db.query('membros',
        columns: ['papel'],
        where: 'quadro_id = ? AND usuario_id = ?',
        whereArgs: [quadroId, usuarioId]);
    if (rows.isEmpty) throw Exception('Você não participa deste kanban');
    return rows.first['papel'] as String;
  }

  Future<List<Quadro>> listar() async {
    final usuarioId = await _storageService.exigirUsuarioId();
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT q.*, m.papel FROM quadros q
      JOIN membros m ON m.quadro_id = q.id
      WHERE m.usuario_id = ?
      ORDER BY q.id
    ''', [usuarioId]);
    return rows.map(_quadroFromRow).toList();
  }

  Future<int> criar(String nome) async {
    final usuarioId = await _storageService.exigirUsuarioId();
    final db = await _db;
    return db.transaction((txn) async {
      final id = await txn.insert('quadros', {
        'nome': nome,
        'usuario_dono_id': usuarioId,
        'codigo_compartilhamento': _gerarCodigo(),
      });
      await txn.insert('membros',
          {'quadro_id': id, 'usuario_id': usuarioId, 'papel': 'dono'});
      return id;
    });
  }

  /// Só funciona entre contas criadas no MESMO aparelho, já que não há servidor.
  Future<void> entrar(String codigo) async {
    final usuarioId = await _storageService.exigirUsuarioId();
    final db = await _db;
    final rows = await db.query('quadros',
        where: 'codigo_compartilhamento = ?',
        whereArgs: [codigo.trim().toUpperCase()]);
    if (rows.isEmpty) throw Exception('Código inválido');
    final quadroId = rows.first['id'] as int;
    final ja = await db.query('membros',
        where: 'quadro_id = ? AND usuario_id = ?',
        whereArgs: [quadroId, usuarioId]);
    if (ja.isNotEmpty) throw Exception('Você já participa deste kanban');
    await db.insert('membros',
        {'quadro_id': quadroId, 'usuario_id': usuarioId, 'papel': 'espectador'});
  }

  Future<QuadroDetalhe> verDetalhes(int quadroId) async {
    final usuarioId = await _storageService.exigirUsuarioId();
    final db = await _db;
    final papel = await _papel(db, quadroId, usuarioId);

    final q = await db.query('quadros', where: 'id = ?', whereArgs: [quadroId]);
    if (q.isEmpty) throw Exception('Erro ao carregar o quadro');
    final quadro = _quadroFromRow({...q.first, 'papel': papel});

    final colunasRows = await db.query('colunas',
        where: 'quadro_id = ?', whereArgs: [quadroId], orderBy: 'id');
    final colunas = <ColunaComCartoes>[];
    for (final c in colunasRows) {
      final cartoesRows = await db.query('cartoes',
          where: 'coluna_id = ?', whereArgs: [c['id']], orderBy: 'ordem, id');
      colunas.add(ColunaComCartoes(
        coluna: Coluna(
          id: c['id'] as int,
          quadroId: c['quadro_id'] as int,
          nome: c['nome'] as String,
        ),
        cartoes: cartoesRows
            .map((k) => Cartao(
                  id: k['id'] as int,
                  colunaId: k['coluna_id'] as int,
                  titulo: k['titulo'] as String,
                  descricao: k['descricao'] as String?,
                  ordem: k['ordem'] as int,
                ))
            .toList(),
      ));
    }

    final membrosRows = await db.rawQuery('''
      SELECT u.nome, m.papel FROM membros m
      JOIN usuarios u ON u.id = m.usuario_id
      WHERE m.quadro_id = ?
      ORDER BY m.papel = 'dono' DESC, u.nome
    ''', [quadroId]);
    final membros = membrosRows
        .map((m) => Membro(nome: m['nome'] as String, papel: m['papel'] as String))
        .toList();

    return QuadroDetalhe(
        quadro: quadro, papel: papel, colunas: colunas, membros: membros);
  }

  Future<void> sair(int quadroId) async {
    final usuarioId = await _storageService.exigirUsuarioId();
    final db = await _db;
    if (await _papel(db, quadroId, usuarioId) == 'dono') {
      throw Exception('O dono não pode sair, apenas excluir o kanban');
    }
    await db.delete('membros',
        where: 'quadro_id = ? AND usuario_id = ?',
        whereArgs: [quadroId, usuarioId]);
  }

  Future<void> excluir(int quadroId) async {
    final usuarioId = await _storageService.exigirUsuarioId();
    final db = await _db;
    if (await _papel(db, quadroId, usuarioId) != 'dono') {
      throw Exception('Apenas o dono pode excluir o kanban');
    }
    // colunas, cartões e membros são apagados em cascata
    await db.delete('quadros', where: 'id = ?', whereArgs: [quadroId]);
  }
}
