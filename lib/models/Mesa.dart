class Mesa {
  String uid;
  String nome;
  int numero;
  String status; 

  Mesa({
    required this.uid,
    required this.nome,
    required this.numero,
    this.status = 'Livre', 
  });

  factory Mesa.fromJson(Map<String, dynamic> json, String uid) {
    return Mesa(
      uid: uid,
      nome: json['nome'] ?? 'Mesa Sem Nome',
      numero: json['numero'] ?? 0,
      status: json['status'] ?? 'Livre', 
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'numero': numero,
      'status': status,
    };
  }
}