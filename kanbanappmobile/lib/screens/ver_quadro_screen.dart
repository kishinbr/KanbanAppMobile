import 'package:flutter/material.dart';
import '../models/quadro_detalhe.dart';
import '../services/quadro_service.dart';
import '../services/coluna_service.dart';
import '../services/cartao_service.dart';

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
                        Text(
                          colunaComCartoes.coluna.nome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                              return Container(
                                width: 140,
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  cartao.titulo,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
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
            floatingActionButton: FloatingActionButton(
              onPressed: _abrirDialogoCriarColuna,
              tooltip: 'Nova coluna',
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}