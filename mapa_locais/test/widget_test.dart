import 'package:flutter_test/flutter_test.dart';
import 'package:mapa_locais/models/avaliacao.dart';
import 'package:mapa_locais/models/local.dart';

Local _local(String nome, String categoria, String cidade) => Local(
      id: nome,
      nome: nome,
      categoria: categoria,
      cidade: cidade,
      avaliacao: 4,
      distancia: 1,
      horario: '08:00 - 18:00',
      descricao: '',
      favorito: false,
      latitude: 0,
      longitude: 0,
    );

void main() {
  final locais = [
    _local('Academia Fitness', 'Academia', 'São Paulo'),
    _local('Café Central', 'Café', 'Campinas'),
    _local('Restaurante Sabor', 'Restaurante', 'Jundiaí'),
  ];

  test('pesquisa por categoria ignora maiúsculas', () {
    expect(filtrarLocais(locais, 'academia', 'Todas', 'Todos').single.nome,
        'Academia Fitness');
  });

  test('filtra por cidade e categoria', () {
    expect(filtrarLocais(locais, '', 'Campinas', 'Todos').single.nome,
        'Café Central');
    expect(filtrarLocais(locais, '', 'Campinas', 'Academia'), isEmpty);
  });

  test('filtra pelos favoritos do usuário', () {
    expect(
        filtrarLocais(locais, '', 'Todas', 'Todos',
                favoritos: {'Café Central'})
            .single
            .nome,
        'Café Central');
    expect(filtrarLocais(locais, '', 'Todas', 'Todos', favoritos: {}), isEmpty);
  });

  test('fromMap aceita inteiros e campos ausentes', () {
    final l = Local.fromMap('x', {'nome': 'A', 'avaliacao': 5, 'cidade': 'Campinas'});
    expect(l.avaliacao, 5.0);
    expect(l.distancia, 0.0);
    expect(l.favorito, false);
    // Sem coordenadas, o local fica no centro da sua cidade.
    expect((l.latitude, l.longitude), centroCidade['Campinas']);
    expect(Local.fromMap('x', l.toMap()).toMap(), l.toMap());
  });

  test('média das avaliações dos usuários', () {
    Avaliacao a(int nota) =>
        Avaliacao(uid: '$nota', autor: 'x', nota: nota, comentario: '');
    expect(mediaAvaliacoes([]), 0);
    expect(mediaAvaliacoes([a(5), a(4), a(3)]), 4);
  });
}
