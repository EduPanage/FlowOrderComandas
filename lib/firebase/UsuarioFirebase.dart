import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class UsuarioFirebase {
  final CollectionReference _usuariosRef = FirebaseFirestore.instance
      .collection('Usuarios');

  /// Pegar ID do usuário logado
  String? pegarIdUsuarioLogado() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  /// Criar usuário no Firebase Auth
  Future<String> criarUsuarioAuth(String email, String senha) async {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: senha);
    return userCredential.user!.uid;
  }
}
