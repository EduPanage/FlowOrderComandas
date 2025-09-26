import 'package:cloud_firestore/cloud_firestore.dart';
import 'ItemCardapio.dart';

class Pedido {
  String? uid;
  String? gerenteUid;
  String? mesaUid;
  String? nomeMesa;
  String? statusAtual;
  double? total;
  List<ItemCardapio>? itens;
  String? observacoes;
  Timestamp? horario;

  Pedido({
    this.uid,
    this.gerenteUid,
    this.mesaUid,
    this.nomeMesa,
    this.statusAtual,
    this.total,
    this.itens,
    this.observacoes,
    this.horario,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'gerenteUid': gerenteUid,
      'mesaUid': mesaUid,
      'nomeMesa': nomeMesa,
      'statusAtual': statusAtual,
      'total': total,
      'itens': itens?.map((item) => item.toMap()).toList(),
      'observacoes': observacoes,
      'horario': horario,
    };
  }

  static Pedido fromMap(Map<String, dynamic> data, String uid) {
    List<ItemCardapio> itensList = [];
    if (data['itens'] != null) {
      itensList = List<ItemCardapio>.from(
          data['itens'].map((item) => ItemCardapio.fromMap(item)));
    }

    return Pedido(
      uid: uid,
      gerenteUid: data['gerenteUid'],
      mesaUid: data['mesaUid'],
      nomeMesa: data['nomeMesa'],
      statusAtual: data['statusAtual'],
      total: data['total'] != null ? (data['total'] as num).toDouble() : 0.0,
      itens: itensList,
      observacoes: data['observacoes'],
      horario: data['horario'] as Timestamp,
    );
  }
}
