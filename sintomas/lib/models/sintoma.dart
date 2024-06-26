class Sintoma {
  final String? id;
  final String sintoma;
  final int intensidade;
  final String data;

  Sintoma({
    this.id,
    required this.sintoma,
    required this.intensidade,
    required this.data,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sintoma': sintoma,
      'intensidade': intensidade,
      'data': data,
    };
  }
}
