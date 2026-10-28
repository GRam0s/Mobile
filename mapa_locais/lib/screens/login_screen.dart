import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _enviar({required bool criarConta}) async {
    if (!_formKey.currentState!.validate()) return;
    final auth = FirebaseAuth.instance;
    setState(() => _carregando = true);
    try {
      // Ao entrar, o main.dart troca para a MapaScreen (authStateChanges).
      if (criarConta) {
        await auth.createUserWithEmailAndPassword(
            email: _email.text.trim(), password: _senha.text);
      } else {
        await auth.signInWithEmailAndPassword(
            email: _email.text.trim(), password: _senha.text);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(mensagemErroLogin(e)),
      ));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.map, size: 72),
                  const SizedBox(height: 8),
                  Text('Mapa de Locais',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                        labelText: 'E-mail', border: OutlineInputBorder()),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Informe um e-mail válido'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _senha,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    decoration: const InputDecoration(
                        labelText: 'Senha', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Mínimo de 6 caracteres'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed:
                        _carregando ? null : () => _enviar(criarConta: false),
                    child: const Text('Entrar'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed:
                        _carregando ? null : () => _enviar(criarConta: true),
                    child: const Text('Criar conta'),
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
