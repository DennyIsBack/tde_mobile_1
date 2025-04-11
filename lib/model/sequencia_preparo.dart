class SequenciaPreparo {
  final int? id;
  final int ordem;
  final String instrucao;
  final int receitaId;

  SequenciaPreparo({
    this.id,
    required this.ordem,
    required this.instrucao,
    required this.receitaId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ordem': ordem,
      'instrucao': instrucao,
      'receita_id': receitaId,
    };
  }

  factory SequenciaPreparo.fromMap(Map<String, dynamic> map) {
    return SequenciaPreparo(
      id: map['id'],
      ordem: map['ordem'],
      instrucao: map['instrucao'],
      receitaId: map['receita_id'],
    );
  }
}