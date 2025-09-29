class ItemCardapio {
  String? uid;
  String nome;
  double preco;
  String categoria;
  String? observacao;
  int quantidade;

  ItemCardapio({
    this.uid,
    required this.nome,
    required this.preco,
    required this.categoria,
    this.observacao,
    this.quantidade = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'preco': preco,
      'categoria': categoria,
      'observacao': observacao,
      'quantidade': quantidade,
    };
  }

  factory ItemCardapio.fromMap(Map<String, dynamic> map, String documentId) {
    return ItemCardapio(
      uid: documentId,
      nome: map['nome'] ?? '',
      preco: (map['preco'] ?? 0).toDouble(),
      categoria: map['categoria'] ?? '',
      observacao: map['observacao'],
      quantidade: map['quantidade'] ?? 1,
    );
  }
}
