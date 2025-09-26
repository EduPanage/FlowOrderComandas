class ItemCardapio {
  final String uid;
  final String nome;
  final String categoria;
  final String descricao;
  final String? imagemUrl;
  final double preco;
  int quantidade;

  ItemCardapio({
    required this.uid,
    required this.nome,
    required this.categoria,
    required this.descricao,
    this.imagemUrl,
    required this.preco,
    this.quantidade = 1,
  });

  factory ItemCardapio.fromMap(Map<String, dynamic> data) {
    return ItemCardapio(
      uid: data['uid'] ?? '',
      nome: data['nome'] ?? '',
      categoria: data['categoria'] ?? '',
      descricao: data['descricao'] ?? '',
      imagemUrl: data['imagemUrl'],
      preco: (data['preco'] as num).toDouble(),
      quantidade: data['quantidade'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'categoria': categoria,
      'descricao': descricao,
      'imagemUrl': imagemUrl,
      'preco': preco,
      'quantidade': quantidade,
    };
  }
}
