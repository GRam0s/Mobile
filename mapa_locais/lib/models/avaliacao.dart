/// Avaliação de um usuário: documento locais/{localId}/avaliacoes/{uid}.
class Avaliacao {
  final String uid;
  final String autor;
  final int nota;
  final String comentario;

  Avaliacao({
    required this.uid,
    required this.autor,
    required this.nota,
    required this.comentario,
  });

  factory Avaliacao.fromMap(String uid, Map<String, dynamic> data) {
    return Avaliacao(
      uid: uid,
      autor: data['autor'] ?? '',
      nota: (data['nota'] ?? 0).toInt(),
      comentario: data['comentario'] ?? '',
    );
  }

  Map<String, dynamic> toMap() =>
      {'autor': autor, 'nota': nota, 'comentario': comentario};
}

double mediaAvaliacoes(List<Avaliacao> avaliacoes) => avaliacoes.isEmpty
    ? 0
    : avaliacoes.map((a) => a.nota).reduce((a, b) => a + b) / avaliacoes.length;
