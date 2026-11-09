import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';
import 'painel_screen.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authService = AuthService();
  final _storageService = StorageService();

  bool _carregando = false;
  bool _mostrarSenha = false;
  String? _erro;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _fazerCadastro() async {
    FocusScope.of(context).unfocus();
    if (_nomeController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _senhaController.text.trim().isEmpty) {
      setState(() => _erro = 'Preencha todos os campos.');
      return;
    }
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final usuario = await _authService.cadastro(
        _nomeController.text.trim(),
        _emailController.text,
        _senhaController.text,
      );

      await _storageService.salvarSessao(
        token: usuario.token,
        nome: usuario.nome,
        email: usuario.email,
        usuarioId: usuario.id,
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PainelScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _erro = limparErro(e));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Criar conta',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Leva menos de um minuto.',
                    style: TextStyle(color: AppCores.textoSuave, fontSize: 15),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _nomeController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _senhaController,
                    obscureText: !_mostrarSenha,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    onSubmitted: (_) => _fazerCadastro(),
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(_mostrarSenha
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () =>
                            setState(() => _mostrarSenha = !_mostrarSenha),
                      ),
                    ),
                  ),
                  if (_erro != null) ...[
                    const SizedBox(height: 16),
                    CaixaErro(_erro!),
                  ],
                  const SizedBox(height: 24),
                  BotaoPrincipal(
                    texto: 'Criar conta',
                    carregando: _carregando,
                    onPressed: _fazerCadastro,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
