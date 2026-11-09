import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/cartao.dart';
import '../models/coluna.dart';
import '../models/quadro_detalhe.dart';
import '../services/cartao_service.dart';
import '../services/coluna_service.dart';
import '../services/quadro_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class VerQuadroScreen extends StatefulWidget {
  final int quadroId;

  const VerQuadroScreen({super.key, required this.quadroId});

  @override
  State<VerQuadroScreen> createState() => _VerQuadroScreenState();
}

class _VerQuadroScreenState extends State<VerQuadroScreen> {
  final _quadroService = QuadroService();
  final _colunaService = ColunaService();
  final _cartaoService = CartaoService();

  late Future<QuadroDetalhe> _detalheFuture;

  // Rolagem horizontal das colunas + rolagem automática durante o arraste.
  final _scroll = ScrollController();
  Timer? _autoScroll;
  double? _dedoX;

  @override
  void initState() {
    super.initState();
    _detalheFuture = _quadroService.verDetalhes(widget.quadroId);
  }

  @override
  void dispose() {
    _autoScroll?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _recarregar() {
    setState(() {
      _detalheFuture = _quadroService.verDetalhes(widget.quadroId);
    });
  }

  /// Executa uma ação, recarrega o quadro e mostra o erro se algo falhar.
  Future<void> _executar(Future<void> Function() acao) async {
    try {
      await acao();
      _recarregar();
    } catch (e) {
      if (mounted) mostrarMensagem(context, e);
    }
  }

  // ---------------- Arraste: rolagem automática nas bordas ----------------

  void _aoArrastar(Offset posicao) {
    _dedoX = posicao.dx;
    _autoScroll ??= Timer.periodic(const Duration(milliseconds: 16), (_) {
      final x = _dedoX;
      if (x == null || !_scroll.hasClients) return;
      final largura = MediaQuery.sizeOf(context).width;
      const zona = 64.0; // faixa nas bordas que ativa a rolagem
      double passo = 0;
      if (x < zona) passo = -14;
      if (x > largura - zona) passo = 14;
      if (passo == 0) return;
      final alvo = (_scroll.offset + passo)
          .clamp(0.0, _scroll.position.maxScrollExtent);
      _scroll.jumpTo(alvo);
    });
  }

  void _fimArraste() {
    _autoScroll?.cancel();
    _autoScroll = null;
    _dedoX = null;
  }

  // ---------------- Colunas ----------------

  Future<void> _abrirDialogoCriarColuna() async {
    final nome = await dialogoTexto(
      context,
      titulo: 'Nova coluna',
      dica: 'Ex.: A fazer',
      confirmar: 'Criar',
    );
    if (nome == null || nome.trim().isEmpty) return;
    await _executar(() => _colunaService.criar(widget.quadroId, nome.trim()));
    // Leva a visão até a coluna recém-criada (a última).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _abrirDialogoRenomearColuna(Coluna coluna) async {
    final nome = await dialogoTexto(
      context,
      titulo: 'Renomear coluna',
      dica: 'Nome da coluna',
      inicial: coluna.nome,
    );
    if (nome == null || nome.trim().isEmpty) return;
    await _executar(() => _colunaService.editar(coluna.id, nome.trim()));
  }

  Future<void> _confirmarExclusaoColuna(Coluna coluna) async {
    final ok = await dialogoConfirmar(
      context,
      titulo: 'Excluir coluna',
      mensagem:
          'Tem certeza que deseja excluir "${coluna.nome}"? Todos os cartões dela também serão excluídos.',
      confirmar: 'Excluir',
    );
    if (ok) await _executar(() => _colunaService.excluir(coluna.id));
  }

  // ---------------- Cartões ----------------

  Future<void> _abrirDialogoCriarCartao(int colunaId) async {
    final titulo = await dialogoTexto(
      context,
      titulo: 'Novo cartão',
      dica: 'O que precisa ser feito?',
      confirmar: 'Criar',
    );
    if (titulo == null || titulo.trim().isEmpty) return;
    await _executar(() => _cartaoService.criar(colunaId, titulo.trim(), null));
  }

  Future<void> _abrirDialogoEditarCartao(Cartao cartao) async {
    final tituloController = TextEditingController(text: cartao.titulo);
    final descricaoController =
        TextEditingController(text: cartao.descricao ?? '');

    final resultado = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              const Expanded(child: Text('Editar cartão')),
              IconButton(
                tooltip: 'Excluir cartão',
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppCores.perigo),
                onPressed: () {
                  Navigator.pop(ctx);
                  _confirmarExclusaoCartao(cartao);
                },
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descricaoController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  alignLabelWithHint: true,
                ),
                minLines: 3,
                maxLines: 6,
              ),
            ],
          ),
          actions: acoesDialogo(
            ctx,
            confirmar: 'Salvar',
            aoConfirmar: () => Navigator.pop(ctx, {
              'titulo': tituloController.text,
              'descricao': descricaoController.text,
            }),
          ),
        );
      },
    );

    if (resultado == null || resultado['titulo']!.trim().isEmpty) return;
    final descricao = resultado['descricao']!.trim();
    await _executar(() => _cartaoService.editar(
          cartao.id,
          resultado['titulo']!.trim(),
          descricao.isEmpty ? null : descricao,
        ));
  }

  Future<void> _confirmarExclusaoCartao(Cartao cartao) async {
    final ok = await dialogoConfirmar(
      context,
      titulo: 'Excluir cartão',
      mensagem: 'Tem certeza que deseja excluir "${cartao.titulo}"?',
      confirmar: 'Excluir',
    );
    if (ok) await _executar(() => _cartaoService.excluir(cartao.id));
  }

  Future<void> _moverCartao(Cartao cartao, ColunaComCartoes destino) async {
    if (cartao.colunaId == destino.coluna.id) return;
    await _executar(() => _cartaoService.mover(
          cartao.id,
          destino.coluna.id,
          destino.cartoes.length, // entra no final da coluna
        ));
  }

  // ---------------- Quadro ----------------

  Future<void> _confirmarSairDoKanban() async {
    final ok = await dialogoConfirmar(
      context,
      titulo: 'Sair do kanban',
      mensagem:
          'Tem certeza que deseja sair? Você vai perder o acesso a este kanban.',
      confirmar: 'Sair',
    );
    if (!ok) return;
    try {
      await _quadroService.sair(widget.quadroId);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) mostrarMensagem(context, e);
    }
  }

  Future<void> _confirmarExclusaoQuadro() async {
    final ok = await dialogoConfirmar(
      context,
      titulo: 'Excluir kanban',
      mensagem:
          'Todas as colunas, cartões e o acesso de todos os participantes serão perdidos permanentemente.',
      confirmar: 'Excluir',
    );
    if (!ok) return;
    try {
      await _quadroService.excluir(widget.quadroId);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) mostrarMensagem(context, e);
    }
  }

  void _mostrarMembros(QuadroDetalhe detalhe) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Membros',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text(
                'Compartilhe o código para convidar alguém.',
                style: TextStyle(color: AppCores.textoSuave),
              ),
              const SizedBox(height: 14),
              CodigoCopiavel(detalhe.quadro.codigoCompartilhamento),
              const SizedBox(height: 18),
              ...detalhe.membros.map(
                (m) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      AvatarInicial(m.nome, tamanho: 38),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(m.nome,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                      Text(
                        m.papel == 'dono' ? 'Dono' : 'Espectador',
                        style: const TextStyle(
                            color: AppCores.textoSuave, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Interface ----------------

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuadroDetalhe>(
      future: _detalheFuture,
      builder: (context, snapshot) {
        // Ao recarregar, o FutureBuilder mantém os dados antigos na tela,
        // então o quadro não "pisca".
        if (!snapshot.hasData && !snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: EstadoVazio(
                icone: Icons.error_outline_rounded,
                titulo: 'Não foi possível abrir o quadro',
                descricao: limparErro(snapshot.error!),
                acao: TextButton(
                    onPressed: _recarregar,
                    child: const Text('Tentar de novo')),
              ),
            ),
          );
        }

        return _quadro(snapshot.data!);
      },
    );
  }

  Widget _quadro(QuadroDetalhe detalhe) {
    final ehDono = detalhe.papel == 'dono';
    final totalCartoes =
        detalhe.colunas.fold<int>(0, (s, c) => s + c.cartoes.length);
    final larguraColuna = min(MediaQuery.sizeOf(context).width * 0.82, 340.0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.maybePop(context),
          tooltip: 'Voltar',
        ),
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _mostrarMembros(detalhe),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: PilhaAvatares(detalhe.membros.map((m) => m.nome).toList()),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz_rounded),
            tooltip: 'Mais opções',
            position: PopupMenuPosition.under,
            onSelected: (v) {
              if (v == 'membros') _mostrarMembros(detalhe);
              if (v == 'sair') _confirmarSairDoKanban();
              if (v == 'excluir') _confirmarExclusaoQuadro();
            },
            itemBuilder: (context) => [
              itemMenu('membros', Icons.people_outline_rounded,
                  'Membros e código'),
              if (ehDono)
                itemMenu('excluir', Icons.delete_outline_rounded,
                    'Excluir kanban',
                    perigoso: true)
              else
                itemMenu('sair', Icons.logout_rounded, 'Sair do kanban',
                    perigoso: true),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título grande
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detalhe.quadro.nome,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '$totalCartoes ${totalCartoes == 1 ? 'cartão' : 'cartões'}'
                      '  ·  código ${detalhe.quadro.codigoCompartilhamento}',
                      style: const TextStyle(
                          fontSize: 13.5, color: AppCores.textoSuave),
                    ),
                    if (!ehDono) ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.visibility_outlined,
                          size: 14, color: AppCores.textoSuave),
                      const SizedBox(width: 4),
                      const Text('Somente leitura',
                          style: TextStyle(
                              fontSize: 13.5, color: AppCores.textoSuave)),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Colunas lado a lado
          Expanded(
            child: detalhe.colunas.isEmpty
                ? Center(
                    child: EstadoVazio(
                      icone: Icons.view_column_outlined,
                      titulo: 'Nenhuma coluna ainda',
                      descricao: ehDono
                          ? 'Comece com colunas como "A fazer", "Fazendo" e "Feito".'
                          : 'O dono ainda não criou colunas neste quadro.',
                      acao: ehDono
                          ? FilledButton.icon(
                              onPressed: _abrirDialogoCriarColuna,
                              style: FilledButton.styleFrom(
                                  minimumSize: const Size(0, 48),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20)),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Criar coluna'),
                            )
                          : null,
                    ),
                  )
                : ListView.separated(
                    controller: _scroll,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: detalhe.colunas.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final c = detalhe.colunas[i];
                      return SizedBox(
                        width: larguraColuna,
                        child: _ColunaWidget(
                          coluna: c,
                          cor: AppCores.colunas[i % AppCores.colunas.length],
                          ehDono: ehDono,
                          larguraCartao: larguraColuna - 24,
                          aoCriarCartao: () =>
                              _abrirDialogoCriarCartao(c.coluna.id),
                          aoRenomear: () =>
                              _abrirDialogoRenomearColuna(c.coluna),
                          aoExcluir: () => _confirmarExclusaoColuna(c.coluna),
                          aoTocarCartao: _abrirDialogoEditarCartao,
                          aoSoltarCartao: (cartao) => _moverCartao(cartao, c),
                          aoArrastar: _aoArrastar,
                          aoFimArraste: _fimArraste,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: ehDono && detalhe.colunas.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _abrirDialogoCriarColuna,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Coluna',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            )
          : null,
    );
  }
}

class _ColunaWidget extends StatelessWidget {
  final ColunaComCartoes coluna;
  final Color cor;
  final bool ehDono;
  final double larguraCartao;
  final VoidCallback aoCriarCartao;
  final VoidCallback aoRenomear;
  final VoidCallback aoExcluir;
  final void Function(Cartao) aoTocarCartao;
  final void Function(Cartao) aoSoltarCartao;
  final void Function(Offset) aoArrastar;
  final VoidCallback aoFimArraste;

  const _ColunaWidget({
    required this.coluna,
    required this.cor,
    required this.ehDono,
    required this.larguraCartao,
    required this.aoCriarCartao,
    required this.aoRenomear,
    required this.aoExcluir,
    required this.aoTocarCartao,
    required this.aoSoltarCartao,
    required this.aoArrastar,
    required this.aoFimArraste,
  });

  @override
  Widget build(BuildContext context) {
    final cartoes = coluna.cartoes;

    return DragTarget<Cartao>(
      onWillAcceptWithDetails: (details) => ehDono,
      onAcceptWithDetails: (details) => aoSoltarCartao(details.data),
      builder: (context, candidatos, rejeitados) {
        // Destaca a coluna quando um cartão de OUTRA coluna passa por cima.
        final destacada =
            candidatos.any((c) => c != null && c.colunaId != coluna.coluna.id);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
          decoration: BoxDecoration(
            color: destacada ? const Color(0xFFE4E2DC) : AppCores.coluna,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: destacada ? AppCores.texto : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho da coluna
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    Container(
                      width: 9,
                      height: 9,
                      decoration:
                          BoxDecoration(color: cor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              coluna.coluna.nome,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text('${cartoes.length}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppCores.textoFraco,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    if (ehDono) ...[
                      IconButton(
                        icon: const Icon(Icons.add_rounded,
                            color: AppCores.textoSuave),
                        tooltip: 'Novo cartão',
                        visualDensity: VisualDensity.compact,
                        onPressed: aoCriarCartao,
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz_rounded,
                            color: AppCores.textoSuave),
                        tooltip: 'Opções da coluna',
                        position: PopupMenuPosition.under,
                        onSelected: (v) {
                          if (v == 'renomear') aoRenomear();
                          if (v == 'excluir') aoExcluir();
                        },
                        itemBuilder: (context) => [
                          itemMenu('renomear', Icons.edit_outlined, 'Renomear'),
                          itemMenu('excluir', Icons.delete_outline_rounded,
                              'Excluir coluna',
                              perigoso: true),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Cartões
              Expanded(
                child: cartoes.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 60),
                          child: Text(
                            ehDono
                                ? 'Toque em + ou arraste\num cartão para cá'
                                : 'Nenhum cartão',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppCores.textoFraco,
                                fontSize: 13.5,
                                height: 1.4),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(top: 2, bottom: 96),
                        itemCount: cartoes.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final cartao = cartoes[i];

                          if (!ehDono) return _CartaoVisual(cartao);

                          return LongPressDraggable<Cartao>(
                            data: cartao,
                            delay: const Duration(milliseconds: 250),
                            onDragUpdate: (d) => aoArrastar(d.globalPosition),
                            onDragEnd: (_) => aoFimArraste(),
                            feedback: Material(
                              color: Colors.transparent,
                              child: Transform.rotate(
                                angle: 0.035,
                                child: SizedBox(
                                  width: larguraCartao,
                                  child: _CartaoVisual(cartao, flutuando: true),
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: _CartaoVisual(cartao),
                            ),
                            child: _CartaoVisual(
                              cartao,
                              onTap: () => aoTocarCartao(cartao),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CartaoVisual extends StatelessWidget {
  final Cartao cartao;
  final VoidCallback? onTap;
  final bool flutuando;

  const _CartaoVisual(this.cartao, {this.onTap, this.flutuando = false});

  @override
  Widget build(BuildContext context) {
    final temDescricao =
        cartao.descricao != null && cartao.descricao!.trim().isNotEmpty;

    return Superficie(
      onTap: onTap,
      raio: 14,
      padding: const EdgeInsets.all(14),
      sombra: flutuando ? AppSombras.flutuante : AppSombras.suave,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              cartao.titulo,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                height: 1.35,
                color: AppCores.texto,
              ),
            ),
            if (temDescricao) ...[
              const SizedBox(height: 6),
              Text(
                cartao.descricao!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color: AppCores.textoSuave,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
