import 'package:flutter/material.dart';
import '../models/quadro.dart';
import '../services/quadro_service.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';

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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Kanbans'),
        actions: [
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

          return ListView.builder(
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
                  // Depois vamos navegar para a tela de detalhes do quadro
                },
              );
            },
          );
        },
      ),
    );
  }
}