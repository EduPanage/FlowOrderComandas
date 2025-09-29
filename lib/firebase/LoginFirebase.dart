import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb

class LoginFirebase {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Construtor
  LoginFirebase() {
    _initializePersistence();
  }

  // Inicializa a persistência apenas para web
  Future<void> _initializePersistence() async {
    try {
      // setPersistence só é suportado na web
      if (kIsWeb) {
        await _auth.setPersistence(Persistence.LOCAL);
      }
      // No mobile (Android/iOS), a persistência é automática
    } catch (e) {
      print('Erro ao configurar persistência: $e');
      // Continua a execução mesmo se houver erro na persistência
    }
  }

  // Verifica se o usuário está logado
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Obter usuário atual
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Login do usuário
  Future<String> login(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return 'Email e senha são obrigatórios';
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        return 'success';
      } else {
        return 'Erro ao fazer login';
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Usuário não encontrado';
        case 'wrong-password':
          return 'Senha incorreta';
        case 'user-disabled':
          return 'Usuário desabilitado';
        case 'invalid-email':
          return 'Email inválido';
        case 'invalid-credential':
          return 'Credenciais inválidas';
        case 'too-many-requests':
          return 'Muitas tentativas. Tente novamente mais tarde';
        default:
          return 'Erro: ${e.message}';
      }
    } catch (e) {
      return 'Erro inesperado: $e';
    }
  }

  // Cadastro de usuário
  Future<String> register(String email, String password, String name) async {
    try {
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        return 'Todos os campos são obrigatórios';
      }

      if (password.length < 6) {
        return 'A senha deve ter pelo menos 6 caracteres';
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        // Atualiza o nome do usuário
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload();

        return 'success';
      } else {
        return 'Erro ao criar conta';
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'Senha muito fraca';
        case 'email-already-in-use':
          return 'Email já está em uso';
        case 'invalid-email':
          return 'Email inválido';
        case 'operation-not-allowed':
          return 'Operação não permitida';
        default:
          return 'Erro: ${e.message}';
      }
    } catch (e) {
      return 'Erro inesperado: $e';
    }
  }

  // Reset de senha
  Future<String> resetPassword(String email) async {
    try {
      if (email.isEmpty) {
        return 'Email é obrigatório';
      }

      await _auth.sendPasswordResetEmail(email: email.trim());
      return 'Email de redefinição enviado com sucesso';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Usuário não encontrado';
        case 'invalid-email':
          return 'Email inválido';
        default:
          return 'Erro: ${e.message}';
      }
    } catch (e) {
      return 'Erro inesperado: $e';
    }
  }

  // Logout
  Future<String> logout() async {
    try {
      await _auth.signOut();
      return 'Logout realizado com sucesso';
    } catch (e) {
      return 'Erro ao fazer logout: $e';
    }
  }

  // Stream para ouvir mudanças no estado de autenticação
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }
}