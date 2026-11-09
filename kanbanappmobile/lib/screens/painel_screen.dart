import 'package:flutter/material.dart';
import '../models/quadro.dart';
import '../services/quadro_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';
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
  String _nome = '';

  @override
  void initState() {
    super.initState();
    _quadrosFuture = _quadroService.listar();
    _storageService.obterNome().then((nome) {
      if (mounted && nome != null) setState(() => _nome = nome);
    });
  }

  void _recarregar() {
    setState(() => _quadrosFuture = _quadroService.listar());
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
    final nome = await dialogoTexto(
      context,
      titulo: 'Novo kanban',
      dica: 'Ex.: Projeto da faculdade',
      confirmar: 'Criar',
    );
    if (nome == null || nome.trim().isEmpty) return;
    try {
      await _quadroService.criar(nome.trim());
      _recarregar();
    } catch (e) {
      if (mounted) mostrarMensagem(context, e);
    }
  }

  Future<void> _abrirDialogoEntrarComCodigo() async {
    final codigo = await dialogoTexto(
      context,
      titulo: 'Entrar com código',
      dica: 'Código de 6 caracteres',
      confirmar: 'Entrar',
      maiusculas: true,
    );
    if (codigo == null || codigo.trim().isEmpty) return;
    try {
      await _quadroService.entrar(codigo.trim());
      _recarregar();
      if (mounted) mostrarMensagem(context, 'Você entrou no kanban');
    } catch (e) {
      if (mounted) mostrarMensagem(context, e);
    }
  }

  Future<void> _abrirQuadro(Quadro quadro) async {
    final atualizou = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerQuadroScreen(quadroId: quadro.id),
      ),
    );
    if (atualizou == true) _recarregar();
  }

  @override
  Widget build(BuildContext context) {
    final primeiroNome = _nome.trim().split(' ').first;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  AvatarInicial(_nome.isEmpty ? '?' : _nome, tamanho: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      primeiroNome.isEmpty ? 'Olá!' : 'Olá, $primeiroNome',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppCores.textoSuave,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.group_add_outlined),
                    onPressed: _abrirDialogoEntrarComCodigo,
                    tooltip: 'Entrar com código',
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded),
                    onPressed: _fazerLogout,
                    tooltip: 'Sair da conta',
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Text(
                'Meus kanbans',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.1,
                ),
              ),
            ),
            Expanded(child: _lista()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirDialogoCriarKanban,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo kanban',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      ),
    );
  }

  Widget _lista() {
    return FutureBuilder<List<Quadro>>(
      future: _quadrosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: EstadoVazio(
              icone: Icons.error_outline_rounded,
              titulo: 'Não foi possível carregar',
              descricao: limparErro(snapshot.error!),
              acao: TextButton(
                  onPressed: _recarregar,
                  child: const Text('Tentar de novo')),
            ),
          );
        }

        final quadros = snapshot.data ?? [];

        return RefreshIndicator(
          color: AppCores.texto,
          backgroundColor: AppCores.superficie,
          onRefresh: () async {
            _recarregar();
            await _quadrosFuture;
          },
          child: quadros.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 80),
                    EstadoVazio(
                      icone: Icons.view_kanban_outlined,
                      titulo: 'Nenhum kanban ainda',
                      descricao:
                          'Crie seu primeiro quadro ou entre no de alguém usando um código.',
                      acao: OutlinedButton.icon(
                        onPressed: _abrirDialogoEntrarComCodigo,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppCores.texto,
                          side: const BorderSide(color: AppCores.borda),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                        ),
                        icon: const Icon(Icons.group_add_outlined, size: 18),
                        label: const Text('Entrar com código'),
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                  itemCount: quadros.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) => _QuadroTile(
                    quadro: quadros[index],
                    onTap: () => _abrirQuadro(quadros[index]),
                  ),
                ),
        );
      },
    );
  }
}

class _QuadroTile extends StatelessWidget {
  final Quadro quadro;
  final VoidCallback onTap;

  const _QuadroTile({required this.quadro, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ehDono = quadro.papel == 'dono';
    return Superficie(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      child: Row(
        children: [
          AvatarInicial(quadro.nome, tamanho: 48, raio: 14),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quadro.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      ehDono ? Icons.star_rounded : Icons.visibility_outlined,
                      size: 14,
                      color: AppCores.textoSuave,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ehDono ? 'Dono' : 'Espectador',
                      style: const TextStyle(
                          fontSize: 13, color: AppCores.textoSuave),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CodigoCopiavel(quadro.codigoCompartilhamento),
        ],
      ),
    );
  }
}
