// lib/firebase/PedidoFirebase.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Pedido.dart';

class PedidoFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _pedidosRef =
  FirebaseFirestore.instance.collection('Pedidos');

  /// Stream de pedidos filtrando por gerenteUid
  Stream<QuerySnapshot<Map<String, dynamic>>> streamPedidos(String gerenteUid) {
    return _firestore
        .collection('Pedidos')
        .where('gerenteUid', isEqualTo: gerenteUid)
        .where('pago', isEqualTo: false)
        .where('statusAtual', whereIn: ['Aberto', 'Em Preparo', 'Pronto', 'Entregue'])
        .orderBy('horario', descending: true)
        .withConverter<Map<String, dynamic>>(
      fromFirestore: (snap, _) => snap.data()!,
      toFirestore: (data, _) => data,
    )
        .snapshots();
  }

  /// Adiciona pedido e atualiza uid + gerenteUid
  Future<void> adicionarPedido(String gerenteUid, Pedido pedido) async {
    final Map<String, dynamic> map = pedido.toMap();
    map['gerenteUid'] = gerenteUid;
    final docRef = await _pedidosRef.add(map);
    await docRef.update({'uid': docRef.id});
  }

  Future<void> atualizarStatus(String pedidoUid, String novoStatus) async {
    await _pedidosRef.doc(pedidoUid).update({'statusAtual': novoStatus});
  }

  Future<void> excluirPedido(String pedidoUid) async {
    await _pedidosRef.doc(pedidoUid).delete();
  }

  Future<void> editarPedido(String pedidoUid, Map<String, dynamic> data) async {
    await _pedidosRef.doc(pedidoUid)
        .update({'statusAtual': 'Cancelado'});
  }

  Future<Pedido?> buscarPedidoPorUid(String uid) async {
    final doc = await _pedidosRef.doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    return Pedido.fromMap(data, doc.id);
  }



// Exemplos de helpers (marcar pago, buscar por periodo etc) podem ser adicionados aqui
}
