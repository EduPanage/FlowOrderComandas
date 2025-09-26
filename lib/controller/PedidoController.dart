import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floworder/firebase/PedidoFirebase.dart';
import 'package:floworder/firebase/UsuarioFirebase.dart';
import '../models/ItemCardapio.dart';
import '../models/Pedido.dart';

class PedidoController {
  final FirebaseFirestore _firestore;
  late final CollectionReference _pedidosRef;
  final UsuarioFirebase _user = UsuarioFirebase();
  PedidoFirebase _pedidoFirebase = PedidoFirebase();

  PedidoController({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _pedidosRef = _firestore.collection('Pedidos');
  }

  /// Cadastra um novo pedido no Firestore
  Future<void> cadastrarPedido(Pedido pedido) async {
    try {
      String? uid = _user.pegarIdUsuarioLogado();

      // Busca o documento do usuário
      final doc = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(uid)
          .get();
      final gerenteUid = doc.data()?['gerenteUid'] as String?;

      if (gerenteUid == null) {
        throw Exception('GerenteUid não encontrado para o usuário');
      }

      pedido.gerenteUid = gerenteUid;
      DocumentReference docRef = await _pedidosRef.add(pedido.toMap());
      await docRef.update({'uid': docRef.id});
    } catch (e) {
      throw Exception('Erro ao cadastrar pedido: $e');
    }
  }

  /// Atualiza o status de um pedido
  Future<bool> mudarStatusPedido(String pedidoUid, String novoStatus) async {
    try {
      await _pedidoFirebase.atualizarStatus(pedidoUid, novoStatus);
      return true;
    } catch (e) {
      print('Erro ao mudar status do pedido: $e');
      return false;
    }
  }

  /// Exclui um pedido (cancela)
  Future<bool> cancelarPedido(String pedidoUid) async {
    try {
      await _pedidoFirebase.excluirPedido(pedidoUid);
      return true;
    } catch (e) {
      print('Erro ao cancelar pedido: $e');
      return false;
    }
  }

  /// Busca todos os pedidos do gerente logado em tempo real (stream)
  Stream<List<Pedido>> listarPedidosTempoReal() {
    try {
      String? gerenteUid = _user.pegarIdUsuarioLogado();
      if (gerenteUid == null) {
        throw Exception('Usuário não logado');
      }
      return _pedidoFirebase.buscarPedidosTempoReal(gerenteUid);
    } catch (e) {
      print('Erro ao buscar pedidos em tempo real: $e');
      return Stream.value([]);
    }
  }

  /// Gera um relatório diário de vendas e status
  Future<Map<String, dynamic>> gerarRelatorioDiario() async {
    final hoje = DateTime.now();
    final pedidos = await _pedidoFirebase.buscarPedidosDoDia(hoje);
    double totalVendas = 0.0;
    int totalPedidos = pedidos.length;
    Map<String, int> statusCount = {};
    Map<String, double> pagamentoPorMetodo = {
      "Dinheiro": 0.0,
      "Cartão": 0.0,
      "PIX": 0.0,
      "Outro": 0.0,
    };

    // Busca detalhes de pagamento em paralelo para todos os pedidos
    final futures = pedidos.map((p) async {
      Map<String, dynamic>? detalhe;
      if (p.uid != null) {
        detalhe = await _pedidoFirebase.buscarDetalhePagamento(p.uid!);
      }
      return {'pedido': p, 'detalhe': detalhe};
    }).toList();

    final results = await Future.wait(futures);

    for (final r in results) {
      final Pedido pedido = r['pedido'] as Pedido;
      final detalhe = r['detalhe'] as Map<String, dynamic>?;

      // Somar total de vendas pelos pagamentos encontrados (se houver)
      if (detalhe != null) {
        final valor = (detalhe['valorPago'] as num).toDouble();
        final metodo = detalhe['metodoPagamento'] as String? ?? 'Outro';

        totalVendas += valor;
        pagamentoPorMetodo[metodo] = (pagamentoPorMetodo[metodo] ?? 0.0) + valor;
      }

      // Corrigido: Usar um valor padrão para a chave do mapa, se 'statusAtual' for nulo.
      final status = pedido.statusAtual ?? 'Desconhecido';
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }

    return {
      'totalVendas': totalVendas,
      'totalPedidos': totalPedidos,
      'statusCount': statusCount,
      'pagamentoPorMetodo': pagamentoPorMetodo,
    };
  }

  /// Gerar relatório de vendas por período
  Future<Map<String, dynamic>> gerarRelatorioPorPeriodo(
      DateTime inicio, DateTime fim) async {
    final pedidos = await _pedidoFirebase.buscarPedidosPorPeriodo(inicio, fim);
    double totalVendas = 0.0;
    int totalPedidos = pedidos.length;
    Map<String, int> statusCount = {};
    Map<String, double> pagamentoPorMetodo = {
      "Dinheiro": 0.0,
      "Cartão": 0.0,
      "PIX": 0.0,
      "Outro": 0.0,
    };

    // Busca detalhes de pagamento em paralelo para todos os pedidos
    final futures = pedidos.map((p) async {
      Map<String, dynamic>? detalhe;
      if (p.uid != null) {
        detalhe = await _pedidoFirebase.buscarDetalhePagamento(p.uid!);
      }
      return {'pedido': p, 'detalhe': detalhe};
    }).toList();

    final results = await Future.wait(futures);

    for (final r in results) {
      final Pedido pedido = r['pedido'] as Pedido;
      final detalhe = r['detalhe'] as Map<String, dynamic>?;

      // Somar total de vendas pelos pagamentos encontrados (se houver)
      if (detalhe != null) {
        final valor = (detalhe['valorPago'] as num).toDouble();
        final metodo = detalhe['metodoPagamento'] as String? ?? 'Outro';

        totalVendas += valor;
        pagamentoPorMetodo[metodo] = (pagamentoPorMetodo[metodo] ?? 0.0) + valor;
      }

      final status = pedido.statusAtual ?? 'Desconhecido';
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }

    return {
      'totalVendas': totalVendas,
      'totalPedidos': totalPedidos,
      'statusCount': statusCount,
      'pagamentoPorMetodo': pagamentoPorMetodo,
    };
  }
}
