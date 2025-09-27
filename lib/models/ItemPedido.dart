import '../models/ItemCardapio.dart';

class ItemPedido {
  String uid; 
  String nome;
  double preco;
  int quantidade;
  String? observacoes;

  ItemPedido({
    required this.uid, 
    required this.nome,
    required this.preco,
    required this.quantidade,
    this.observacoes,
  });

  // Converte o objeto para Map (para enviar ao Firestore dentro de Pedido)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'preco': preco,
      'quantidade': quantidade,
      'observacoes': observacoes,
    };
  }

  // Cria ItemPedido a partir de um Map (para receber do Firestore)
  factory ItemPedido.fromMap(Map<String, dynamic> data) {
    return ItemPedido(
      uid: data['uid'] ?? '', 
      nome: data['nome'] ?? 'Item Desconhecido',
      preco: (data['preco'] as num?)?.toDouble() ?? 0.0,
      quantidade: data['quantidade'] ?? 0,
      observacoes: data['observacoes'],
    );
  }
}