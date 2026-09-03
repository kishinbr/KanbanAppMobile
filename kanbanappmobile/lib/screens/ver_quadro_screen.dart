import 'package:flutter/material.dart';
import '../models/quadro_detalhe.dart';
import '../services/quadro_service.dart';
import '../services/coluna_service.dart';
import '../services/cartao_service.dart';
import '../models/cartao.dart';
import '../models/coluna.dart';

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

  @override
  void initState() {
    super.initState();
    _detalheFuture = _quadroService.verDetalhes(widget.quadroId);
  }
  Future<void> _abrirDialogoCriarColuna() async {
    final nomeController = TextEditingController();

    final nome = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova coluna'),
          content: TextField(
            controller: nomeController,
            decoration: const InputDecoration(labelText: 'Nome da coluna'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, nomeController.text),
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );

    if (nome != null && nome.trim().isNotEmpty) {
      try {
        await _colunaService.criar(widget.quadroId, nome.trim());
        setState(() {
          _detalheFuture = _quadroService.verDetalhes(widget.quadroId);
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'.replaceAll('Exception: ', ''))),
          );
        }
      }
    }
  }
  Future<void> _abrirDialogoCriarCartao(int colunaId) async {
    final tituloController = TextEditingController();

    final titulo = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Novo cartão'),
          content: TextField(
            controller: tituloController,
            decoration: const InputDecoration(labelText: 'Título do cartão'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, tituloController.text),
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );

    if (titulo != null && titulo.trim().isNotEmpty) {
      try {
        await _cartaoService.criar(colunaId, titulo.trim(), null);
        setState(() {
          _detalheFuture = _quadroService.verDetalhes(widget.quadroId);
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'.replaceAll('Exception: ', ''))),
          );
        }
      }
    }
  }
  Future<void> _abrirDialogoEditarCartao(Cartao cartao) async {
    final tituloController = TextEditingController(text: cartao.titulo);
    final descricaoController =
        TextEditingController(text: cartao.descricao ?? '');

    final resultado = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar cartão'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmarExclusaoCartao(cartao);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, {
                'titulo': tituloController.text,
                'descricao': descricaoController.text,
              }),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (resultado != null && resultado['titulo']!.trim().isNotEmpty) {
      try {
        await _cartaoService.editar(
          cartao.id,
          resultado['titulo']!.trim(),
          resultado['descricao']?.trim().isEmpty ?? true
              ? null
              : resultado['descricao'],
        );
        setState(() {
          _detalheFuture = _quadroService.verDetalhes(widget.quadroId);
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'.replaceAll('Exception: ', ''))),
          );
        }
      }
    }
  }
  Future<void> _abrirDialogoEditarColuna(Coluna coluna) async {
    final nomeController = TextEditingController(text: coluna.nome);

    final resultado = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar coluna'),
          content: TextField(
            controller: nomeController,
            decoration: const InputDecoration(labelText: 'Nome da coluna'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmarExclusaoColuna(coluna);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, nomeController.text),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (resultado != null && resultado.trim().isNotEmpty) {
      try {
        await _colunaService.editar(coluna.id, resultado.trim());
        setState(() {
          _detalheFuture = _quadroService.verDetalhes(widget.quadroId);
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'.replaceAll('Exception: ', ''))),
          );
        }
      }
    }
  }

  Future<void> _confirmarExclusaoColuna(Coluna coluna) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir coluna'),
          content: Text(
            'Tem certeza que deseja excluir "${coluna.nome}"? Todos os cartões dela também serão excluídos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmou == true) {
      try {
        await _colunaService.excluir(coluna.id);
        setState(() {
          _detalheFuture = _quadroService.verDetalhes(widget.quadroId);
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'.replaceAll('Exception: ', ''))),
          );
        }
      }
    }
  }
  Future<void> _confirmarExclusaoCartao(Cartao cartao) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir cartão'),
          content: Text('Tem certeza que deseja excluir "${cartao.titulo}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmou == true) {
      try {
        await _cartaoService.excluir(cartao.id);
        setState(() {
          _detalheFuture = _quadroService.verDetalhes(widget.quadroId);
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'.replaceAll('Exception: ', ''))),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuadroDetalhe>(
        future: _detalheFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final detalhe = snapshot.data!;
          final ehDono = detalhe.papel == 'dono';

          return Scaffold(
            appBar: AppBar(title: Text(detalhe.quadro.nome)),
            body: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: detalhe.colunas.length,
              itemBuilder: (context, index) {
                final colunaComCartoes = detalhe.colunas[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: ehDono ? () => _abrirDialogoEditarColuna(colunaComCartoes.coluna) : null,
                          child: Text(
                            colunaComCartoes.coluna.nome,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: colunaComCartoes.cartoes.length + 1,
                            itemBuilder: (context, cartaoIndex) {
                              if (cartaoIndex == colunaComCartoes.cartoes.length) {
                                if (!ehDono) {
                                  return const SizedBox.shrink();
                                }
                                return Center(
                                  child: IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () =>
                                        _abrirDialogoCriarCartao(colunaComCartoes.coluna.id),
                                    tooltip: 'Novo cartão',
                                  ),
                                );
                              }

                              final cartao = colunaComCartoes.cartoes[cartaoIndex];
                                return GestureDetector(
                                  onTap: ehDono ? () => _abrirDialogoEditarCartao(cartao) : null,
                                  child: Container(
                                    width: 140,
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          cartao.titulo,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        if (cartao.descricao != null && cartao.descricao!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            cartao.descricao!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            floatingActionButton: ehDono
              ? FloatingActionButton(
                  onPressed: _abrirDialogoCriarColuna,
                  tooltip: 'Nova coluna',
                  child: const Icon(Icons.add),
                )
              : null,
          );
        },
      ),
    );
  }
}