import 'package:cloud_firestore/cloud_firestore.dart';
import 'ItemPedido.dart'; // Importação corrigida para o item de pedido

class Pedido {
  String? uid;
  String? gerenteUid;
  String? mesaUid;
  String? nomeMesa;
  String statusAtual;
  double total;
  List<ItemPedido> itens; // Agora usa List<ItemPedido>
  String? observacoes;
  Timestamp? horario;

  Pedido({
    this.uid,
    this.gerenteUid,
    this.mesaUid,
    this.nomeMesa,
    this.statusAtual = 'Aberto', // Define 'Aberto' como status inicial
    required this.total,
    required this.itens,
    this.observacoes,
    this.horario,
  }) {
    // Garante que o total é calculado (embora o Controller possa fazer isso)
    this.total = itens.fold(0.0, (sum, item) => sum + (item.preco * item.quantidade));
  }

  // Converte o objeto Pedido para um Map para ser enviado ao Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'gerenteUid': gerenteUid,
      'mesaUid': mesaUid,
      'nomeMesa': nomeMesa,
      'statusAtual': statusAtual,
      'total': total,
      // Converte a lista de ItemPedido para Map
      'itens': itens.map((item) => item.toMap()).toList(),
      'observacoes': observacoes,
      'horario': horario ?? FieldValue.serverTimestamp(),
    };
  }

  // Construtor factory para criar um Pedido a partir de um DocumentSnapshot do Firestore
  factory Pedido.fromMap(Map<String, dynamic> data, String docId) {
    List<ItemPedido> itensList = [];
    if (data['itens'] != null) {
      itensList = List<ItemPedido>.from(
        data['itens'].map((itemMap) => ItemPedido.fromMap(itemMap)),
      );
    }

    double calculatedTotal = itensList.fold(0.0, (sum, item) => sum + (item.preco * item.quantidade));

    return Pedido(
      uid: docId,
      gerenteUid: data['gerenteUid'],
      mesaUid: data['mesaUid'],
      nomeMesa: data['nomeMesa'],
      statusAtual: data['statusAtual'] ?? 'Aberto',
      // Usa o total do banco ou recalcula
      total: (data['total'] as num?)?.toDouble() ?? calculatedTotal, 
      itens: itensList,
      observacoes: data['observacoes'],
      horario: data['horario'] as Timestamp?,
    );
  }
}