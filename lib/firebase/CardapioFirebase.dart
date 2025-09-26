import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/Cardapio.dart';
import '../models/ItemCardapio.dart';

class CardapioFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Retorna o uid do usuário logado
  String? pegarIdUsuarioLogado() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<String?> verificarGerenteUid() async {
    String? userId = pegarIdUsuarioLogado();
    if (userId == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(userId)
          .get();
      final userData = doc.data() as Map<String, dynamic>?;
      final gerenteUid = userData?['gerenteUid'] as String? ?? userId;
      return gerenteUid;
    } catch (e) {
      print('Erro ao verificar gerenteUid: $e');
      return null;
    }
  }

  /// Adiciona um cardápio e retorna o id gerado
  Future<String> adicionarCardapio(String Id, Cardapio cardapio) async {
    try {
      if (Id.isEmpty) throw Exception('inválido');

      final doc = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(Id)
          .get();
      final userData = doc.data() as Map<String, dynamic>?;
      final cargo = userData?['cargo'] as String?;

      if (cargo == "Gerente") {
        DocumentReference docRef = await _firestore.collection('Cardapios').add({
          'nome': cardapio.nome,
          'categoria': cardapio.categoria,
          'ativo': cardapio.ativo,
          'criadoEm': FieldValue.serverTimestamp(),
          'itens': cardapio.itens.map((i) => i.toMap()).toList(),
          'gerenteUid': Id,
        });

        await docRef.update({'uid': docRef.id});
        return docRef.id;
      } else {
        final gerenteUid = userData?['gerenteUid'] as String?;
        DocumentReference docRef = await _firestore.collection('Cardapios').add({
          'nome': cardapio.nome,
          'categoria': cardapio.categoria,
          'ativo': cardapio.ativo,
          'criadoEm': FieldValue.serverTimestamp(),
          'itens': cardapio.itens.map((i) => i.toMap()).toList(),
          'gerenteUid': gerenteUid,
        });

        await docRef.update({'uid': docRef.id});
        return docRef.id;
      }
    } catch (e) {
      throw Exception('Erro ao adicionar cardapio: $e');
    }
  }

  /// Busca todos os cardápios de uma vez (snapshot único)
  Future<QuerySnapshot> buscarCardapios(String gerenteId) async {
    return _firestore
        .collection('Cardapios')
        .where('gerenteUid', isEqualTo: gerenteId)
        .get();
  }

  /// Busca apenas cardápios ativos
  Future<QuerySnapshot> buscarCardapiosAtivos(String gerenteId) async {
    return _firestore
        .collection('Cardapios')
        .where('gerenteUid', isEqualTo: gerenteId)
        .where('ativo', isEqualTo: true)
        .get();
  }

  /// Atualiza o cardápio (valida uid)
  Future<void> atualizarCardapio(String gerenteId, Cardapio cardapio) async {
    try {
      if (gerenteId.isEmpty) throw Exception('GerenteId inválido');

      await _firestore.collection('Cardapios').doc(cardapio.uid).update({
        'nome': cardapio.nome,
        'categoria': cardapio.categoria,
        'ativo': cardapio.ativo,
        'atualizadoEm': FieldValue.serverTimestamp(),
        'itens': cardapio.itens.map((i) => i.toMap()).toList(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar cardápio: ${e.toString()}');
    }
  }

  /// Exclui um cardápio (valida uid)
  Future<void> excluirCardapio(String gerenteId, String cardapioId) async {
    try {
      if (gerenteId.isEmpty) throw Exception('GerenteId inválido');

      final doc = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(gerenteId)
          .get();
      final userData = doc.data() as Map<String, dynamic>?;
      final cargo = userData?['cargo'] as String?;

      if (cargo == 'Gerente') {
        await _firestore.collection('Cardapios').doc(cardapioId).delete();
      } else
        throw Exception("Para Excluir deve ser O gerente do estabelecimento");
    } catch (e) {
      throw Exception('Erro ao excluir cardápio:');
    }
  }

  /// Suspende/reativa (atualiza campo 'ativo')
  Future<void> suspenderCardapio(
    String gerenteId,
    String cardapioId,
    bool ativo,
  ) async {
    try {
      if (gerenteId.isEmpty) throw Exception('GerenteId inválido');
      await _firestore
          .collection('Cardapios')
          .doc(cardapioId)
          .update({'ativo': ativo});
    } catch (e) {
      throw Exception('Erro ao suspender/reativar cardápio: ${e.toString()}');
    }
  }

  /// Converter DocumentSnapshot para Cardapio
  Cardapio documentParaCardapio(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Cardapio.fromMap(data, doc.id);
  }

  /// Converter QuerySnapshot para lista de cardápios
  List<Cardapio> querySnapshotParaCardapios(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => documentParaCardapio(doc))
        .where((cardapio) => cardapio.ativo) // Filtra apenas os ativos
        .toList();
  }
}
