import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../dialogs/confirm_delete.dart';
import '../models/local.dart';
import '../services/auth_service.dart';
import '../services/local_service.dart';
import '../widgets/local_card.dart';
import '../widgets/local_form.dart';
import 'detalhes_screen.dart';

class ResultadosScreen extends StatefulWidget {
  final String cidade;
  final String pesquisa;

  const ResultadosScreen({
    super.key,
    required this.cidade,
    required this.pesquisa,
  });

  @override
  State<ResultadosScreen> createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  final _service = LocalService();
  final _usuario = FirebaseAuth.instance.currentUser!;
  late final _admin = ehAdmin(_usuario);
  late final _favoritos = _service.favoritos(_usuario.uid);
  late final _pesquisa = TextEditingController(text: widget.pesquisa);
  late String _cidade = widget.cidade;
  String _categoria = 'Todos';
  bool _somenteFavoritos = false;
  late Stream<List<Local>> _locais = _consultar();

  // Cidade e categoria vão para o Firestore (where); o texto é filtrado em memória.
  Stream<List<Local>> _consultar() =>
      _service.listarLocais(cidade: _cidade, categoria: _categoria);

  @override
  void dispose() {
    _pesquisa.dispose();
    super.dispose();
  }

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

  Future<void> _cadastrar() async {
    final novo = await abrirFormularioLocal(context);
    if (novo != null) {
      await _executar(() => _service.adicionar(novo), 'Local cadastrado.');
    }
  }

  Future<void> _editar(Local local) async {
    final editado = await abrirFormularioLocal(context, local: local);
    if (editado != null) {
      await _executar(() => _service.atualizar(editado), 'Local atualizado.');
    }
  }

  Future<void> _excluir(Local local) async {
    if (await confirmarExclusao(context, local.nome)) {
      await _executar(() => _service.excluir(local.id), 'Local excluído.');
    }
  }

  Widget _filtro(String rotulo, String valor, List<String> opcoes,
      ValueChanged<String> onChanged) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        initialValue: valor,
        isExpanded: true,
        decoration: InputDecoration(
            labelText: rotulo, border: const OutlineInputBorder()),
        items: [
          for (final o in opcoes) DropdownMenuItem(value: o, child: Text(o)),
        ],
        onChanged: (v) => setState(() {
          onChanged(v!);
          _locais = _consultar();
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultados')),
      floatingActionButton: _admin
          ? FloatingActionButton.extended(
              onPressed: _cadastrar,
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              controller: _pesquisa,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Pesquisar por nome ou categoria',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _filtro('Cidade', _cidade, ['Todas', ...cidades],
                    (v) => _cidade = v),
                const SizedBox(width: 12),
                _filtro('Categoria', _categoria, ['Todos', ...categorias],
                    (v) => _categoria = v),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: FilterChip(
                label: const Text('Somente favoritos'),
                avatar: const Icon(Icons.favorite, size: 18),
                selected: _somenteFavoritos,
                onSelected: (v) => setState(() => _somenteFavoritos = v),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<Set<String>>(
              stream: _favoritos,
              builder: (context, favSnapshot) {
                final favoritos = favSnapshot.data ?? {};
                return StreamBuilder<List<Local>>(
                  stream: _locais,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                            'Erro ao carregar os locais.\n${snapshot.error}',
                            textAlign: TextAlign.center),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final locais = filtrarLocais(
                      snapshot.data!,
                      _pesquisa.text,
                      _cidade,
                      _categoria,
                      favoritos: _somenteFavoritos ? favoritos : null,
                    );
                    if (locais.isEmpty) {
                      return const Center(
                          child: Text('Nenhum local encontrado.'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
                      itemCount: locais.length,
                      itemBuilder: (context, index) {
                        final local = locais[index];
                        return LocalCard(
                          local: local,
                          favorito: favoritos.contains(local.id),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DetalhesScreen(local: local)),
                          ),
                          onEditar: _admin ? () => _editar(local) : null,
                          onExcluir: _admin ? () => _excluir(local) : null,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
