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
  Future<List<Pedido>> buscarTodosPedidos(String gerenteUid) async {
    try {
      final snapshot = await _pedidosRef.where('gerenteUid', isEqualTo: gerenteUid).get();
      return snapshot.docs
          .map((doc) => Pedido.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar todos os pedidos: $e');
    }
  }

  /// Busca pedidos em tempo real (stream)
  Stream<List<Pedido>> listarPedidosTempoReal(String gerenteUid) {
    return _pedidosRef
        .where('gerenteUid', isEqualTo: gerenteUid)
        // Ordena por horário decrescente para os pedidos mais recentes aparecerem primeiro
        .orderBy('horario', descending: true) 
        .snapshots()
        .map((snapshot) {
      // Converte a QuerySnapshot do Firestore para List<Pedido>
      return snapshot.docs.map((doc) {
        return Pedido.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> editarPedido(String uid, Map<String, dynamic> dadosAtualizados) async {
    await _pedidosRef.doc(uid).update(dadosAtualizados);
  }

  Future<List<Pedido>> buscarPedidosDoDia(DateTime dia) async {
    try {
      final inicio = DateTime(dia.year, dia.month, dia.day, 0, 0, 0);
      final fim = DateTime(dia.year, dia.month, dia.day, 23, 59, 59);

      final snapshot = await _pedidosRef
          .where('horario', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
          .where('horario', isLessThanOrEqualTo: Timestamp.fromDate(fim))
          .get();

      return snapshot.docs
          .map((doc) => Pedido.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Pedido>> buscarPedidosPorPeriodo(DateTime inicio, DateTime fim) async {
    try {
      final snapshot = await _pedidosRef
          .where('horario', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
          .where('horario', isLessThanOrEqualTo: Timestamp.fromDate(fim))
          .get();

      return snapshot.docs
          .map((doc) => Pedido.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> buscarDetalhePagamento(String pedidoUid) async {
    try {
      final snapshot = await _pedidosRef.doc(pedidoUid).collection('Pagamentos').get();
      double valorPago = 0.0;
      String metodoPagamento = 'Outro';

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        valorPago = (data['valor'] as num).toDouble();
        metodoPagamento = data['metodo'] as String;
      }

      return {
        'valorPago': valorPago,
        'metodoPagamento': metodoPagamento,
      };
    } catch (e) {
      return {'valorPago': 0.0, 'metodoPagamento': 'Outro'};
    }
  }

  Future<Map<String, dynamic>> calcularTotaisPorMetodoPagamento(
      DateTime inicio, DateTime fim) async {
    try {
      final pedidos = await buscarPedidosPorPeriodo(inicio, fim);
      final totalPorMetodo = <String, double>{
        'Dinheiro': 0.0,
        'Cartão': 0.0,
        'PIX': 0.0,
        'Outro': 0.0,
      };
      final quantidadePorMetodo = <String, int>{
        'Dinheiro': 0,
        'Cartão': 0,
        'PIX': 0,
        'Outro': 0,
      };

      for (var pedido in pedidos) {
        if (pedido.uid != null) {
          final detalhe = await buscarDetalhePagamento(pedido.uid!);
          final valor = (detalhe['valorPago'] as num).toDouble();
          final metodo = detalhe['metodoPagamento'] as String? ?? 'Outro';

          totalPorMetodo[metodo] = (totalPorMetodo[metodo] ?? 0) + valor;
          quantidadePorMetodo[metodo] = (quantidadePorMetodo[metodo] ?? 0) + 1;
        }
      }

      return {
        'totalPorMetodo': totalPorMetodo,
        'quantidadePorMetodo': quantidadePorMetodo,
      };
    } catch (e) {
      return {
        'totalPorMetodo': {'Dinheiro': 0.0, 'Cartão': 0.0, 'PIX': 0.0, 'Outro': 0.0},
        'quantidadePorMetodo': {'Dinheiro': 0, 'Cartão': 0, 'PIX': 0, 'Outro': 0},
      };
    }
  }

  Future<Pedido?> buscarPedidoPorId(String pedidoId) async {
    try {
      // _pedidosRef é a CollectionReference já definida na classe
      final doc = await _pedidosRef.doc(pedidoId).get();
      if (!doc.exists) return null;
      // Reutiliza o factory constructor do Pedido
      return Pedido.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      print('Erro ao buscar pedido por ID: $e');
      return null;
    }
  }

}
