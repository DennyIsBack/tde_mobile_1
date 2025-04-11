class Receita {
  final int? id;
  final String nome;
  final double nota;
  final String dataAdicionada;
  final int tempoPreparo;

  Receita({
    this.id,
    required this.nome,
    required this.nota,
    required this.dataAdicionada,
    required this.tempoPreparo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'nota': nota,
      'data_adicionada': dataAdicionada,
      'tempo_preparo': tempoPreparo,
    };
  }

  factory Receita.fromMap(Map<String, dynamic> map) {
    return Receita(
      id: map['id'],
      nome: map['nome'],
      nota: map['nota'],
      dataAdicionada: map['data_adicionada'],
      tempoPreparo: map['tempo_preparo'],
    );
  }
}