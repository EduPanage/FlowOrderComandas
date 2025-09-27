import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase/PedidoFirebase.dart';
import '../firebase/MesaFirebase.dart';
import '../models/Pedido.dart';

class PedidoController {
  final PedidoFirebase _pedidoFirebase = PedidoFirebase();
  final MesaFirebase _mesaFirebase = MesaFirebase();

  // Método auxiliar para obter o UID do Gerente
  Future<String?> _getGerenteUid() async {
    return await _mesaFirebase.verificarGerenteUid();
  }

  /// Cadastra um novo pedido no Firestore e atualiza o status da mesa
  Future<String> cadastrarPedido(Pedido pedido) async {
    try {
      // Validações: Agora lança exceção para melhor tratamento na View
      if (pedido.itens.isEmpty) {
        throw Exception('O pedido deve ter pelo menos um item.');
      }
      if (pedido.mesaUid == null || pedido.mesaUid!.isEmpty) {
        throw Exception('O pedido deve estar associado a uma mesa.');
      }

      // 1. Obter o UID do Gerente e aplicar ao pedido
      String? gerenteUid = await _getGerenteUid();
      if (gerenteUid == null) {
        throw Exception('Usuário não logado ou gerente não encontrado.');
      }
      pedido.gerenteUid = gerenteUid;

      // 2. Definir o status inicial e horário
      pedido.statusAtual = 'Pendente'; // Status inicial de um novo pedido
      pedido.horario = Timestamp.now();

      // 3. Cadastrar o pedido (pega o uid gerado)
      String pedidoId = await _pedidoFirebase.adicionarPedido(pedido);

      // 4. Mudar o status da mesa para 'Ocupada' (se já não estiver)
      await _mesaFirebase.atualizarStatusMesa(
        gerenteUid,
        pedido.mesaUid!,
        'Ocupada',
      );

      return 'success'; // Retorna sucesso
    } catch (e) {
      print('Erro ao cadastrar pedido: $e');
      throw Exception(
        'Erro ao cadastrar pedido: ${e.toString()}',
      ); // Lança a exceção
    }
  }

  /// **NOVO**: Lista pedidos ativos em tempo real para uma mesa específica (Stream)
  Stream<List<Pedido>> listarPedidosTempoRealPorMesa(String mesaUid) async* {
    String? gerenteUid = await _getGerenteUid();

    if (gerenteUid == null) {
      yield* Stream.value([]);
      return;
    }

    // Chama o serviço do Firebase com o UID do gerente e da mesa
    yield* _pedidoFirebase.listarPedidosTempoRealPorMesa(gerenteUid, mesaUid);
  }

  /// Atualiza o status de um pedido e gerencia o status da mesa
  Future<bool> mudarStatusPedido(String pedidoId, String novoStatus) async {
    try {
      await _pedidoFirebase.atualizarStatus(pedidoId, novoStatus);

      // Lógica para liberar a mesa quando o pedido é finalizado ou cancelado
      if (novoStatus == 'Entregue' || novoStatus == 'Cancelado') {
        final pedido = await _pedidoFirebase.buscarPedidoPorId(pedidoId);
        if (pedido != null && pedido.mesaUid != null) {
          String? gerenteUid = await _getGerenteUid();
          if (gerenteUid != null) {
            // TODO: Lógica futura para verificar se não há outros pedidos ATIVOS
            // Antes de mudar o status da mesa para 'Livre'
            // Por enquanto, apenas atualiza o status. A mesa será liberada na tela de pagamento
            // await _mesaFirebase.atualizarStatusMesa(gerenteUid, pedido.mesaUid!, 'Livre');
          }
        }
      }

      return true;
    } catch (e) {
      throw Exception('Erro ao mudar status do pedido: ${e.toString()}');
    }
  }

  // TODO: Adicionar métodos de buscar relatórios, etc.
}
