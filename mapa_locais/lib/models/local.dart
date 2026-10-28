const cidades = ['São Paulo', 'Campinas', 'Jundiaí'];
const categorias = ['Academia', 'Restaurante', 'Farmácia', 'Mercado', 'Café'];

/// Centro de cada cidade (latitude, longitude), usado no mapa e como posição padrão.
const centroCidade = {
  'São Paulo': (-23.5505, -46.6333),
  'Campinas': (-22.9056, -47.0608),
  'Jundiaí': (-23.1857, -46.8978),
};

class Local {
  final String id;
  final String nome;
  final String categoria;
  final String cidade;
  final double avaliacao;
  final double distancia;
  final String horario;
  final String descricao;
  final bool favorito;
  final double latitude;
  final double longitude;

  Local({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.cidade,
    required this.avaliacao,
    required this.distancia,
    required this.horario,
    required this.descricao,
    required this.favorito,
    required this.latitude,
    required this.longitude,
  });

  factory Local.fromMap(String id, Map<String, dynamic> data) {
    final cidade = data['cidade'] ?? '';
    final centro = centroCidade[cidade] ?? centroCidade[cidades.first]!;
    return Local(
      id: id,
      nome: data['nome'] ?? '',
      categoria: data['categoria'] ?? '',
      cidade: cidade,
      avaliacao: (data['avaliacao'] ?? 0).toDouble(),
      distancia: (data['distancia'] ?? 0).toDouble(),
      horario: data['horario'] ?? '',
      descricao: data['descricao'] ?? '',
      favorito: data['favorito'] ?? false,
      latitude: (data['latitude'] ?? centro.$1).toDouble(),
      longitude: (data['longitude'] ?? centro.$2).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'categoria': categoria,
      'cidade': cidade,
      'avaliacao': avaliacao,
      'distancia': distancia,
      'horario': horario,
      'descricao': descricao,
      'favorito': favorito,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

/// Filtro em memória da pesquisa por texto e dos favoritos do usuário.
/// Cidade e categoria já chegam filtradas pelo Firestore (where), mas são
/// conferidas aqui também para a função servir sozinha nos testes.
List<Local> filtrarLocais(
  List<Local> locais,
  String texto,
  String cidade,
  String categoria, {
  Set<String>? favoritos,
}) {
  final termo = texto.trim().toLowerCase();
  return locais.where((local) {
    final correspondeCidade = cidade == 'Todas' || local.cidade == cidade;
    final correspondeCategoria =
        categoria == 'Todos' || local.categoria == categoria;
    final correspondeTexto = local.nome.toLowerCase().contains(termo) ||
        local.categoria.toLowerCase().contains(termo);
    return correspondeCidade &&
        correspondeCategoria &&
        correspondeTexto &&
        (favoritos == null || favoritos.contains(local.id));
  }).toList();
}
