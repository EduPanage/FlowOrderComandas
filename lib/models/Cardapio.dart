class Cardapio {
  String uid;
  String nome;
  String descricao;
  double preco;
  bool ativo;
  String categoria;
  String? observacao;

  Cardapio({
    this.uid = '',
    required this.nome,
    required this.descricao,
    required this.preco,
    this.ativo = true,
    this.categoria = 'Outros',
    this.observacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'ativo': ativo,
      'categoria': categoria,
      'observacao': observacao,
    };
  }

  factory Cardapio.fromMap(Map<String, dynamic> map, String documentId) {
    return Cardapio(
      uid: documentId,
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      preco: (map['preco'] ?? 0).toDouble(),
      ativo: map['ativo'] ?? true,
      categoria: map['categoria'] ?? 'Outros',
      observacao: map['observacao'],
    );
  }
}
