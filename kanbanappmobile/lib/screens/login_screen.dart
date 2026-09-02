import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'cadastro_screen.dart';
import '../services/storage_service.dart';
import 'painel_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authService = AuthService();
  final _storageService = StorageService();

  bool _carregando = false;
  String? _erro;

  Future<void> _fazerLogin() async {
    if (_emailController.text.trim().isEmpty ||
      _senhaController.text.trim().isEmpty) {
      setState(() {
        _erro = 'Preencha email e senha.';
      });
      return;
    }
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final usuario = await _authService.login(
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PainelScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _erro = e.toString();
      });
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Kanban App',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _senhaController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 24),
              if (_erro != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_erro!, style: const TextStyle(color: Colors.red)),
                ),
              _carregando
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _fazerLogin,
                      child: const Text('Entrar'),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CadastroScreen()),
                );
                },
                child: const Text('Não tem conta? Cadastre-se!!'),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}