class Ingrediente {
  final int? id;
  final String nomeIngrediente;
  final int quantidade;
  final int receitaId;

  Ingrediente({
    this.id,
    required this.nomeIngrediente,
    required this.quantidade,
    required this.receitaId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome_ingrediente': nomeIngrediente,
      'quantidade': quantidade,
      'receita_id': receitaId,
    };
  }

  factory Ingrediente.fromMap(Map<String, dynamic> map) {
    return Ingrediente(
      id: map['id'],
      nomeIngrediente: map['nome_ingrediente'],
      quantidade: map['quantidade'],
      receitaId: map['receita_id'],
    );
  }
}