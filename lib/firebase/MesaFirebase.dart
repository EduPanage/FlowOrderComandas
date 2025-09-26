// lib/firebase/MesaFirebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/Mesa.dart';

class MesaFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Pegar ID do usuário logado
  String? pegarIdUsuarioLogado() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  // Verifica se o usuário é Gerente ou Funcionário e retorna o UID do Gerente
  Future<String?> verificarGerenteUid() async {
    String? userId = pegarIdUsuarioLogado();
    if (userId == null) return null;

    try {
      final doc = await _firestore.collection('Usuarios').doc(userId).get();
      final userData = doc.data() as Map<String, dynamic>?;

      final cargo = userData?['cargo'] as String?;

      // Se for Gerente, o gerenteUid é o próprio userId
      if (cargo == 'Gerente') {
        return userId;
      }

      // Se for Funcionário, retorna o gerenteUid do documento do usuário
      final gerenteUid = userData?['gerenteUid'] as String?;
      return gerenteUid;
    } catch (e) {
      print('Erro ao verificar gerenteUid: $e');
      return null;
    }
  }

  /// Adicionar mesa
  Future<String> adicionarMesa(String Id, Mesa mesa) async {
    final doc = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(Id)
        .get();
    final userData = doc.data() as Map<String, dynamic>?;
    final cargo = userData?['cargo'] as String?;
    ;

    DocumentReference docRef;

    if (cargo == "Gerente") {
      docRef = await _firestore.collection('Mesas').add({
        'nome': mesa.nome,
        'numero': mesa.numero,
        'gerenteUid': Id,
        'status': 'Livre', // Adiciona status inicial
        'criadoEm': FieldValue.serverTimestamp(),
      });
    } else {
      final gerenteUid = userData?['gerenteUid'] as String?;
      if (gerenteUid == null) {
        throw Exception('GerenteUid não encontrado para o usuário');
      }
      docRef = await _firestore.collection('Mesas').add({
        'nome': mesa.nome,
        'numero': mesa.numero,
        'gerenteUid': gerenteUid,
        'status': 'Livre', // Adiciona status inicial
        'criadoEm': FieldValue.serverTimestamp(),
      });
    }
    return docRef.id;
  }

  /// Listar mesas em tempo real (QuerySnapshot)
  Stream<QuerySnapshot> listarMesasTempoReal(String gerenteId) {
    // Filtra pelo gerenteId e ordena, se necessário.
    return _firestore
        .collection('Mesas')
        .where('gerenteUid', isEqualTo: gerenteId)
        .orderBy('numero')
        .snapshots();
  }

  /// Deletar mesa
  Future<void> deletarMesa(String gerenteId, String mesaUid) async {
    await _firestore.collection('Mesas').doc(mesaUid).delete();
  }

  /// Atualizar mesa
  Future<void> atualizarMesa(String gerenteId, Mesa mesa) async {
    await _firestore.collection('Mesas').doc(mesa.uid).update({
      'nome': mesa.nome,
      'numero': mesa.numero,
      'status': mesa.status, // Atualiza o status
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

  /// Converter DocumentSnapshot em Mesa
  Mesa documentParaMesa(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Mesa(
      uid: doc.id,
      nome: data['nome'] ?? "Mesa ${data['numero']}",
      numero: data['numero'] ?? 0,
      // CORREÇÃO ESSENCIAL 1: Adiciona o campo 'status'
      status: data['status'] ?? 'Livre',
    );
  }

  /// Converter QuerySnapshot em lista de mesas
  List<Mesa> querySnapshotParaMesas(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) => documentParaMesa(doc)).toList();
  }

  /// Verificar se já existe mesa com esse número
  Future<bool> verificarMesaExistente(int numero, String userId) async {
    return false;
  }

  Future<void> atualizarStatusMesa(
      String gerenteId,
      String mesaUid,
      String novoStatus,
      ) async {
    await _firestore.collection('Mesas').doc(mesaUid).update({
      'status': novoStatus,
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }
}
