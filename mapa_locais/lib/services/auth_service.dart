import 'package:firebase_auth/firebase_auth.dart';

// Mesma lista de firestore.rules (função admin); é o servidor que garante a permissão.
const emailsAdmin = ['ramos04082005@gmail.com'];

bool ehAdmin(User? usuario) => emailsAdmin.contains(usuario?.email);

String mensagemErroLogin(Object erro) {
  if (erro is! FirebaseAuthException) return 'Erro inesperado: $erro';
  return switch (erro.code) {
    'invalid-email' => 'E-mail inválido.',
    'invalid-credential' || 'wrong-password' || 'user-not-found' =>
      'E-mail ou senha incorretos.',
    'email-already-in-use' => 'Já existe uma conta com esse e-mail.',
    'weak-password' => 'A senha precisa ter pelo menos 6 caracteres.',
    'network-request-failed' => 'Sem conexão com a internet.',
    'operation-not-allowed' =>
      'Login por e-mail não está ativado no Firebase.',
    _ => 'Erro ao entrar: ${erro.message}',
  };
}
