class ItemPedido {
  String nome;
  int quantidade;
  double preco;
  String? observacoes;

  ItemPedido({
    required this.nome,
    required this.quantidade,
    required this.preco,
    this.observacoes,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'quantidade': quantidade,
      'preco': preco,
      'observacoes': observacoes,
    };
  }

  factory ItemPedido.fromMap(Map<String, dynamic> map) {
    return ItemPedido(
      nome: map['nome'] ?? '',
      quantidade: map['quantidade'] ?? 0,
      preco: (map['preco'] as num?)?.toDouble() ?? 0.0,
      observacoes: map['observacoes'],
    );
  }
}
