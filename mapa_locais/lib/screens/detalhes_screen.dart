import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/avaliacao.dart';
import '../models/local.dart';
import '../services/local_service.dart';
import '../widgets/local_card.dart';
import 'mapa_screen.dart';

class DetalhesScreen extends StatefulWidget {
  final Local local;

  const DetalhesScreen({super.key, required this.local});

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  final _service = LocalService();
  final _usuario = FirebaseAuth.instance.currentUser!;
  late final _favoritos = _service.favoritos(_usuario.uid);
  late final _avaliacoes = _service.avaliacoes(widget.local.id);

  Future<void> _executar(Future<void> Function() operacao, String sucesso) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await operacao();
      messenger.showSnackBar(SnackBar(content: Text(sucesso)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Erro na operação: $e'),
      ));
    }
  }

  Future<void> _avaliar(Avaliacao? minha) async {
    final nova = await showDialog<Avaliacao>(
      context: context,
      builder: (_) => _AvaliacaoDialog(
        minha: minha,
        uid: _usuario.uid,
        autor: _usuario.email!.split('@').first,
      ),
    );
    if (nova != null) {
      await _executar(
          () => _service.avaliar(widget.local.id, nova), 'Avaliação salva.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = widget.local;
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(local.nome),
        actions: [
          StreamBuilder<Set<String>>(
            stream: _favoritos,
            builder: (context, snapshot) {
              final favorito = snapshot.data?.contains(local.id) ?? false;
              return IconButton(
                tooltip: favorito ? 'Desfavoritar' : 'Favoritar',
                onPressed: !snapshot.hasData
                    ? null
                    : () => _executar(
                          () => _service.alterarFavorito(
                              _usuario.uid, local.id, !favorito),
                          favorito
                              ? 'Removido dos favoritos.'
                              : 'Adicionado aos favoritos.',
                        ),
                icon: Icon(favorito ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Avaliacao>>(
        stream: _avaliacoes,
        builder: (context, snapshot) {
          final avaliacoes = snapshot.data ?? [];
          final minha =
              avaliacoes.where((a) => a.uid == _usuario.uid).firstOrNull;
          return ListView(
            children: [
              Container(
                height: 180,
                color: tema.colorScheme.primaryContainer,
                child: Icon(
                  iconesCategoria[local.categoria] ?? Icons.place,
                  size: 96,
                  color: tema.colorScheme.onPrimaryContainer,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(local.nome, style: tema.textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text('${local.categoria} · ${local.cidade}'),
                    const Divider(height: 32),
                    _Info(Icons.star, 'Avaliação',
                        local.avaliacao.toStringAsFixed(1)),
                    _Info(
                      Icons.people,
                      'Nota dos usuários',
                      avaliacoes.isEmpty
                          ? 'Sem avaliações'
                          : '${mediaAvaliacoes(avaliacoes).toStringAsFixed(1)} (${avaliacoes.length})',
                    ),
                    _Info(Icons.directions_walk, 'Distância',
                        '${local.distancia.toStringAsFixed(1)} km'),
                    _Info(Icons.schedule, 'Horário', local.horario),
                    const SizedBox(height: 16),
                    Text('Descrição', style: tema.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(local.descricao.isEmpty
                        ? 'Sem descrição.'
                        : local.descricao),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Voltar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => MapaScreen(destaque: local)),
                            ),
                            icon: const Icon(Icons.map),
                            label: const Text('Ver no mapa'),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Avaliações',
                              style: tema.textTheme.titleMedium),
                        ),
                        TextButton.icon(
                          onPressed: () => _avaliar(minha),
                          icon: const Icon(Icons.rate_review),
                          label: Text(minha == null ? 'Avaliar' : 'Editar a minha'),
                        ),
                      ],
                    ),
                    if (snapshot.hasError)
                      Text('Erro ao carregar avaliações: ${snapshot.error}'),
                    if (avaliacoes.isEmpty && !snapshot.hasError)
                      const Text('Ninguém avaliou este local ainda.'),
                    for (final a in avaliacoes)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(child: Text('${a.nota}')),
                        title: Text(a.autor),
                        subtitle:
                            a.comentario.isEmpty ? null : Text(a.comentario),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AvaliacaoDialog extends StatefulWidget {
  final Avaliacao? minha;
  final String uid;
  final String autor;

  const _AvaliacaoDialog(
      {required this.minha, required this.uid, required this.autor});

  @override
  State<_AvaliacaoDialog> createState() => _AvaliacaoDialogState();
}

class _AvaliacaoDialogState extends State<_AvaliacaoDialog> {
  late int _nota = widget.minha?.nota ?? 5;
  late final _comentario =
      TextEditingController(text: widget.minha?.comentario);

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sua avaliação'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var n = 1; n <= 5; n++)
                IconButton(
                  tooltip: '$n estrela${n > 1 ? 's' : ''}',
                  onPressed: () => setState(() => _nota = n),
                  icon: Icon(n <= _nota ? Icons.star : Icons.star_border,
                      color: Colors.amber),
                ),
            ],
          ),
          TextField(
            controller: _comentario,
            maxLength: 500,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Comentário'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            Avaliacao(
              uid: widget.uid,
              autor: widget.autor,
              nota: _nota,
              comentario: _comentario.text.trim(),
            ),
          ),
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String valor;

  const _Info(this.icone, this.rotulo, this.valor);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icone),
      title: Text(rotulo),
      trailing: Text(valor, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
