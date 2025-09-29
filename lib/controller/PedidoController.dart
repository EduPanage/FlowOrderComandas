// lib/controller/PedidoController.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase/PedidoFirebase.dart';
import '../firebase/UsuarioFirebase.dart';
import '../models/Pedido.dart';
import '../models/ItemCardapio.dart';

class PedidoController {
  final PedidoFirebase _pedidoFirebase = PedidoFirebase();
  final UsuarioFirebase _usuarioFirebase = UsuarioFirebase();

  PedidoController();

  /// Retorna um Stream<List<Pedido>> pronto para o StreamBuilder da UI.
  Future<Stream<List<Pedido>>> listarPedidosTempoReal() async {
    final uid = _usuarioFirebase.pegarIdUsuarioLogado();
    if (uid == null) return Stream.value([]);

    final gerenteUid = await _usuarioFirebase.pegarGerenteUid(uid);
    if (gerenteUid == null) return Stream.value([]);

    return _pedidoFirebase.streamPedidos(gerenteUid).map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Pedido.fromMap(data, doc.id);
      }).toList();
    });
  }


  Future<void> cadastrarPedido(Pedido pedido) async {
    final uidUsuario = _usuarioFirebase.pegarIdUsuarioLogado();
    if (uidUsuario == null) throw Exception('Usuário não logado');

    final gerenteUid = await _usuarioFirebase.pegarGerenteUid(uidUsuario);
    if (gerenteUid == null) throw Exception('GerenteUid não encontrado');

    await _pedidoFirebase.adicionarPedido(gerenteUid, pedido);
  }

  Future<void> atualizarStatusPedido(String pedidoId, String novoStatus) async {
    await _pedidoFirebase.atualizarStatus(pedidoId, novoStatus);
  }

  Future<void> atualizarItensPedido(String pedidoId, List<ItemCardapio> itens) async {
    final listaMap = itens.map((i) => i.toMap()).toList();
    await _pedidoFirebase.editarPedido(pedidoId, {'itens': listaMap});
  }

  Future<bool> excluirPedido(String pedidoUid) async {
    try {
      await _pedidoFirebase.excluirPedido(pedidoUid);
      return true;
    } catch (e) {
      print("Erro excluir pedido: $e");
      return false;
    }
  }

  Future<Pedido?> buscarPedidoPorUid(String uid) async {
    return await _pedidoFirebase.buscarPedidoPorUid(uid);
  }
}
