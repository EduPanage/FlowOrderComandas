import 'package:cloud_firestore/cloud_firestore.dart';

class Mesa {
  final String? uid;
  final String nome;
  final int numero;
  final String? gerenteUid;
  final Timestamp? criadoEm;

  Mesa({
    this.uid,
    required this.nome,
    required this.numero,
    this.gerenteUid,
    this.criadoEm,
  });

  factory Mesa.fromMap(Map<String, dynamic> map, String uid) {
    return Mesa(
      uid: uid,
      nome: map['nome'] ?? 'Mesa ${map['numero']}',
      numero: map['numero'] ?? 0,
      gerenteUid: map['gerenteUid'],
      criadoEm: map['criadoEm'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'numero': numero,
      'gerenteUid': gerenteUid,
      'criadoEm': criadoEm,
    };
  }
}
