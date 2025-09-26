import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase/MesaFirebase.dart';
import '../models/Mesa.dart';

class MesaController {
  final MesaFirebase _mesaFirebase = MesaFirebase();

  /// Cadastrar mesa
  Future<String> cadastrarMesa(Mesa mesa) async {
    try {
      String? userId = _mesaFirebase.pegarIdUsuarioLogado();
      if (userId == null) {
        throw Exception('Erro: Nenhum Gerente logado');
      }

      if (await _mesaFirebase.verificarMesaExistente(mesa.numero, userId)) {
        return 'Erro: Mesa já cadastrada';
      }

      String mesaId = await _mesaFirebase.adicionarMesa(userId, mesa);

      return 'Mesa cadastrada com sucesso';
    } catch (e) {
      throw Exception('Erro ao cadastrar mesa: ${e.toString()}');
    }
  }

  /// Buscar mesas do gerente logado (snapshot único)
  Future<List<Mesa>> buscarMesas() async {
    String? userId = _mesaFirebase.pegarIdUsuarioLogado();
    if (userId == null) {
      throw Exception('Erro: Nenhum Gerente logado');
    }

    try {
      QuerySnapshot snapshot = await _mesaFirebase.buscarMesas(userId);
      return _mesaFirebase.querySnapshotParaMesas(snapshot);
    } catch (e) {
      throw Exception('Erro ao buscar mesas: ${e.toString()}');
    }
  }

  /// Listar mesas em tempo real (stream)
  Stream<List<Mesa>> listarMesasTempoReal() {
    String? userId = _mesaFirebase.pegarIdUsuarioLogado();
    if (userId == null) {
      throw Exception('Erro: Nenhum Gerente logado');
    }
  
    return _mesaFirebase.listarMesasTempoReal(userId).map((snapshot) {
      return _mesaFirebase.querySnapshotParaMesas(snapshot);
    });
  }

  /// Deletar mesa
  Future<String> deletarMesa(String mesaUid) async {
    String? userId = _mesaFirebase.pegarIdUsuarioLogado();
    if (userId == null) {
      throw Exception('Erro: Nenhum Gerente logado');
    }

    try {
      await _mesaFirebase.deletarMesa(userId, mesaUid);
      return 'Mesa deletada com sucesso';
    } catch (e) {
      throw Exception('Erro ao deletar mesa: ${e.toString()}');
    }
  }

  /// Atualizar mesa
  Future<String> atualizarMesa(Mesa mesa) async {
    String? userId = _mesaFirebase.pegarIdUsuarioLogado();
    if (userId == null) {
      throw Exception('Erro: Nenhum Gerente logado');
    }

    if (mesa.uid!.isEmpty) {
      throw Exception('UID da mesa é necessário para atualizar');
    }

    try {
      await _mesaFirebase.atualizarMesa(userId, mesa);
      return 'Mesa atualizada com sucesso';
    } catch (e) {
      throw Exception('Erro ao atualizar mesa: ${e.toString()}');
    }
  }
}