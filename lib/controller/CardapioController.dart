import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase/CardapioFirebase.dart';
import '../models/Cardapio.dart';
import '../models/ItemCardapio.dart';

class CardapioController {
  final CardapioFirebase _cardapioFirebase = CardapioFirebase();

  /// Cadastrar cardápio
  Future<String> cadastrarCardapio(Cardapio cardapio) async {
    try {
      if (cardapio.nome.isEmpty) {
        return 'Erro: Nome do cardápio não pode estar vazio';
      }

      String? userId = await _cardapioFirebase.pegarIdUsuarioLogado();
      if (userId == null) {
        throw Exception('Erro: Nenhum Gerente logado');
      }

      String cardapioId = await _cardapioFirebase.adicionarCardapio(
        userId,
        cardapio,
      );
      cardapio.uid = cardapioId;

      return 'Cardápio cadastrado com sucesso';
    } catch (e) {
      throw Exception('Erro ao cadastrar cardápio');
    }
  }

  Future<List<Cardapio>> buscarCardapios() async {
    String? userId = await _cardapioFirebase.verificarGerenteUid();
    if (userId == null) {
      return []; // Retorna lista vazia se não houver gerente
    }

    try {
      // 1. AWAIT para obter o QuerySnapshot
      final snapshot = await _cardapioFirebase.buscarCardapios(userId);

      // 2. CONVERTER o QuerySnapshot para List<Cardapio> usando o método de conversão
      return _cardapioFirebase.querySnapshotParaCardapios(snapshot);
    } catch (e) {
      throw Exception('Erro ao buscar cardápios: ${e.toString()}');
    }
  }

  Stream<List<ItemCardapio>> listarItensCardapioTempoReal() async* {
    // Obter GerenteUid (boa prática)
    String? gerenteUid = await _cardapioFirebase.verificarGerenteUid();

    if (gerenteUid == null) {
      // Se não houver gerenteId, retornamos um stream vazio
      yield* Stream.value([]);
      return;
    }

    // Chama o serviço do Firebase (que já faz o filtro de gerente e ativo)
    yield* _cardapioFirebase.listarItensCardapioTempoReal();
  }

  /// Atualizar cardápio
  Future<String> atualizarCardapio(Cardapio cardapio) async {
    String? userId = await _cardapioFirebase.pegarIdUsuarioLogado();
    if (userId == null) {
      throw Exception('Erro: Nenhum Gerente logado');
    }
    if (cardapio.uid == null) {
      throw Exception('UID do cardápio é necessário para atualizar');
    }

    try {
      await _cardapioFirebase.atualizarCardapio(userId, cardapio);
      return 'Cardápio atualizado com sucesso';
    } catch (e) {
      throw Exception('Erro ao atualizar cardápio: ${e.toString()}');
    }
  }

  /// Deletar cardápio
  Future<String> deletarCardapio(String cardapioUid) async {
    String? userId = await _cardapioFirebase.pegarIdUsuarioLogado();
    if (userId == null) {
      throw Exception('Erro: Nenhum Gerente logado');
    }

    try {
      await _cardapioFirebase.excluirCardapio(userId, cardapioUid);
      return 'Cardápio deletado com sucesso';
    } catch (e) {
      throw Exception('Erro ao deletar cardápio:');
    }
  }

  /// Suspender ou reativar cardápio
  Future<String> suspenderCardapio(String cardapioUid, bool suspender) async {
    String? userId = await _cardapioFirebase.verificarGerenteUid();
    if (userId == null) {
      throw Exception('Erro: Nenhum Gerente logado');
    }

    try {
      await _cardapioFirebase.suspenderCardapio(userId, cardapioUid, suspender);
      return suspender
          ? 'Cardápio suspenso com sucesso'
          : 'Cardápio reativado com sucesso';
    } catch (e) {
      throw Exception('Erro ao suspender/reativar cardápio:');
    }
  }
}
