import 'ItemCardapio.dart';

class Cardapio {
  String? uid;
  String nome;
  String categoria;
  bool ativo;
  List<ItemCardapio> itens;

  Cardapio({
    this.uid,
    required this.nome,
    required this.categoria,
    required this.ativo,
    this.itens = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'categoria': categoria,
      'ativo': ativo,
      'itens': itens.map((item) => item.toMap()).toList(),
    };
  }

  factory Cardapio.fromMap(Map<String, dynamic> map, String uid) {
    var itensList = map['itens'] as List? ?? [];
    List<ItemCardapio> itens = itensList.map((item) => ItemCardapio.fromMap(item)).toList();
    return Cardapio(
      uid: uid,
      nome: map['nome'] ?? '',
      categoria: map['categoria'] ?? '',
      ativo: map['ativo'] ?? false,
      itens: itens,
    );
  }
}
