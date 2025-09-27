import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Pedido.dart';

class PedidoFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _pedidosRef => _firestore.collection('Pedidos');

  /// Adiciona um pedido no Firestore
  Future<String> adicionarPedido(Pedido pedido) async {
    try {
      DocumentReference docRef = await _pedidosRef.add(pedido.toMap());
      await docRef.update({'uid': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao adicionar pedido: $e');
    }
  }

  /// Atualiza o status de um pedido
  Future<void> atualizarStatus(String pedidoId, String novoStatus) async {
    try {
      await _pedidosRef.doc(pedidoId).update({'statusAtual': novoStatus});
    } catch (e) {
      throw Exception('Erro ao atualizar status do pedido: $e');
    }
  }

  /// Exclui um pedido/Cancela
  Future<void> excluirPedido(String pedidoId) async {
    try {
      await _pedidosRef.doc(pedidoId).update({'statusAtual': 'Cancelado'});
    } catch (e) {
      throw Exception('Erro ao excluir pedido: $e');
    }
  }

  /// Busca todos os pedidos de uma vez (sem tempo real)
  Future<List<Pedido>> buscarPedidos() async {
    try {
      final snapshot = await _pedidosRef.get();
      return snapshot.docs
          .map((doc) => Pedido.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar pedidos: $e');
    }
  }

  /// Lista pedidos em tempo real (Stream)
  Stream<List<Pedido>> listarPedidosTempoReal(String gerenteUid) {
    return _pedidosRef
        .where('gerenteUid', isEqualTo: gerenteUid)
        .where(
          'statusAtual',
          whereIn: ['Aberto', 'Pendente', 'Preparando', 'Pronto'],
        ) // Lista apenas pedidos ativos
        .orderBy('horario', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Pedido.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// **NOVO**: Lista pedidos em tempo real de uma mesa (apenas 'Aberto', 'Pendente', 'Preparando')
  Stream<List<Pedido>> listarPedidosTempoRealPorMesa(String gerenteUid, String mesaUid) {
    // Filtra por gerente, mesa e status, excluindo 'Entregue' e 'Cancelado'
    return _pedidosRef
        .where('gerenteUid', isEqualTo: gerenteUid)
        .where('mesaUid', isEqualTo: mesaUid)
        .where(
          'statusAtual',
          whereIn: ['Aberto', 'Pendente', 'Preparando', 'Pronto'], // Status considerados ativos na comanda
        )
        .orderBy('horario', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Pedido.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  /// **NOVO**: Busca um pedido por ID (necessário para atualizar o status da mesa)
  Future<Pedido?> buscarPedidoPorId(String pedidoId) async {
    try {
      final doc = await _pedidosRef.doc(pedidoId).get();
      if (doc.exists) {
        return Pedido.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar pedido por ID: $e');
    }
  }
}