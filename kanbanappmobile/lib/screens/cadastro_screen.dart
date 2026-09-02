import 'package:flutter/material.dart';
import '../services/auth_service.dart';

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

  bool _carregando = false;
  String? _erro;

  Future<void> _fazerCadastro() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final usuario = await _authService.cadastro(
        _nomeController.text,
        _emailController.text,
        _senhaController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cadastro OK! Bem-vindo, ${usuario.nome}')),
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
      appBar: AppBar(title: const Text('Criar Conta')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 16),
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
                      onPressed: _fazerCadastro,
                      child: const Text('Cadastrar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}