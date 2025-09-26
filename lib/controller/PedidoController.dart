import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase/PedidoFirebase.dart';
import '../firebase/MesaFirebase.dart'; // Importação para controlar o status da mesa
import '../models/Pedido.dart';

class PedidoController {
  // Inicializa a camada de serviço do Pedido e da Mesa
  final PedidoFirebase _pedidoFirebase = PedidoFirebase();
  final MesaFirebase _mesaFirebase = MesaFirebase();

  // Método auxiliar para obter o UID do Gerente
  Future<String?> _getGerenteUid() async {
    return await _mesaFirebase.verificarGerenteUid();
  }

  /// Cadastra um novo pedido no Firestore e atualiza o status da mesa
  Future<String> cadastrarPedido(Pedido pedido) async {
    try {
      // Validações
      if (pedido.itens.isEmpty) {
        return 'Erro: O pedido deve ter pelo menos um item.';
      }
      if (pedido.mesaUid == null || pedido.mesaUid!.isEmpty) {
        return 'Erro: O pedido deve estar associado a uma mesa.';
      }

      // 1. Obter o UID do Gerente e aplicar ao pedido
      String? gerenteUid = await _getGerenteUid();
      if (gerenteUid == null) {
        return 'Erro: Usuário não logado ou gerente não encontrado.';
      }
      pedido.gerenteUid = gerenteUid;

      // 2. Definir o status inicial e horário
      pedido.statusAtual = 'Aberto';
      pedido.horario = Timestamp.now();

      // 3. Enviar o pedido para o Firebase
      String pedidoId = await _pedidoFirebase.adicionarPedido(pedido);
      pedido.uid = pedidoId;

      // 4. Atualizar o status da Mesa para 'Ocupada'
      await _mesaFirebase.atualizarStatusMesa(
          gerenteUid,
          pedido.mesaUid!,
          'Ocupada'
      );

      return 'Pedido cadastrado com sucesso: $pedidoId';
    } catch (e) {
      print('Erro ao cadastrar pedido: $e');
      return 'Erro ao cadastrar pedido: ${e.toString()}';
    }
  }

  /// Lista pedidos em tempo real (Stream)
  Stream<List<Pedido>> listarPedidosTempoReal() async* {
    String? gerenteUid = await _getGerenteUid();

    if (gerenteUid == null) {
      yield* Stream.value([]);
      return;
    }

    // Chama o serviço do Firebase com o UID do gerente
    yield* _pedidoFirebase.listarPedidosTempoReal(gerenteUid);
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
                  // Mudar o status da mesa de volta para 'Livre'
                  await _mesaFirebase.atualizarStatusMesa(gerenteUid, pedido.mesaUid!, 'Livre');
              }
          }
      }

      return true;
    } catch (e) {
      print('Erro ao mudar status do pedido: $e');
      return false;
    }
  }
}