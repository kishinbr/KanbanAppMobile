import 'package:flutter/material.dart';
import '../models/quadro.dart';
import '../services/quadro_service.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';
import 'ver_quadro_screen.dart';

class PainelScreen extends StatefulWidget {
  const PainelScreen({super.key});

  @override
  State<PainelScreen> createState() => _PainelScreenState();
}

class _PainelScreenState extends State<PainelScreen> {
  final _quadroService = QuadroService();
  final _storageService = StorageService();
  late Future<List<Quadro>> _quadrosFuture;

  @override
  void initState() {
    super.initState();
    _quadrosFuture = _quadroService.listar();
    
  }

  Future<void> _fazerLogout() async {
    await _storageService.limparSessao();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _abrirDialogoCriarKanban() async {
    final nomeController = TextEditingController();

    final nome = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Criar novo Kanban'),
          content: TextField(
            controller: nomeController,
            decoration: const InputDecoration(labelText: 'Nome do Kanban'),
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
        await _quadroService.criar(nome.trim());
        setState(() {
          _quadrosFuture = _quadroService.listar();
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e')),
          );
        }
      }
    }
  }
  Future<void> _abrirDialogoEntrarComCodigo() async {
    final codigoController = TextEditingController();

    final codigo = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Entrar com código'),
          content: TextField(
            controller: codigoController,
            decoration: const InputDecoration(labelText: 'Código do Kanban'),
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, codigoController.text),
              child: const Text('Entrar'),
            ),
          ],
        );
      },
    );

    if (codigo != null && codigo.trim().isNotEmpty) {
      try {
        await _quadroService.entrar(codigo.trim());
        setState(() {
          _quadrosFuture = _quadroService.listar();
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
      appBar: AppBar(
        title: const Text('Meus Kanbans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: _abrirDialogoEntrarComCodigo,
            tooltip: 'Entrar com código',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _fazerLogout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: FutureBuilder<List<Quadro>>(
        future: _quadrosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final quadros = snapshot.data ?? [];

          if (quadros.isEmpty) {
            return const Center(child: Text('Você ainda não tem nenhum kanban.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _quadrosFuture = _quadroService.listar();
              });
              await _quadrosFuture;
            },
            child: ListView.builder(
              itemCount: quadros.length,
              itemBuilder: (context, index) {
                final quadro = quadros[index];
                return ListTile(
                  title: Text(quadro.nome),
                  subtitle: Text(
                    quadro.papel == 'dono' ? 'Você é o dono' : 'Espectador',
                  ),
                  trailing: Text(quadro.codigoCompartilhamento),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerQuadroScreen(quadroId: quadro.id),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirDialogoCriarKanban,
        tooltip: 'Criar novo Kanban',
        child: const Icon(Icons.add),
      ),
    );
  }
}