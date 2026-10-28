import 'package:flutter/material.dart';
import '../models/local.dart';

/// Abre o formulário em um Bottom Sheet. Retorna o local preenchido ou null se cancelado.
Future<Local?> abrirFormularioLocal(BuildContext context, {Local? local}) {
  return showModalBottomSheet<Local>(
    context: context,
    isScrollControlled: true,
    builder: (_) => LocalForm(local: local),
  );
}

class LocalForm extends StatefulWidget {
  final Local? local;

  const LocalForm({super.key, this.local});

  @override
  State<LocalForm> createState() => _LocalFormState();
}

class _LocalFormState extends State<LocalForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: widget.local?.nome);
  late final _horario = TextEditingController(text: widget.local?.horario);
  late final _descricao = TextEditingController(text: widget.local?.descricao);
  late final _avaliacao =
      TextEditingController(text: widget.local?.avaliacao.toString());
  late final _distancia =
      TextEditingController(text: widget.local?.distancia.toString());
  late String _categoria = widget.local?.categoria ?? categorias.first;
  late String _cidade = widget.local?.cidade ?? cidades.first;
  late final _latitude = TextEditingController(
      text: (widget.local?.latitude ?? centroCidade[_cidade]!.$1).toString());
  late final _longitude = TextEditingController(
      text: (widget.local?.longitude ?? centroCidade[_cidade]!.$2).toString());

  void _trocarCidade(String cidade) {
    setState(() => _cidade = cidade);
    // No cadastro, a posição acompanha o centro da cidade escolhida.
    if (widget.local == null) {
      _latitude.text = centroCidade[cidade]!.$1.toString();
      _longitude.text = centroCidade[cidade]!.$2.toString();
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nome, _horario, _descricao, _avaliacao, _distancia, _latitude, _longitude
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _obrigatorio(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null;

  String? Function(String?) _numero(double max, {double min = 0}) => (v) {
        final n = double.tryParse((v ?? '').replaceAll(',', '.'));
        if (n == null) return 'Informe um número';
        if (n < min || n > max) return 'Entre $min e $max';
        return null;
      };

  double _ler(TextEditingController c) => double.parse(c.text.replaceAll(',', '.'));

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Local(
        id: widget.local?.id ?? '',
        nome: _nome.text.trim(),
        categoria: _categoria,
        cidade: _cidade,
        avaliacao: _ler(_avaliacao),
        distancia: _ler(_distancia),
        horario: _horario.text.trim(),
        descricao: _descricao.text.trim(),
        favorito: widget.local?.favorito ?? false,
        latitude: _ler(_latitude),
        longitude: _ler(_longitude),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const espaco = SizedBox(height: 12);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.local == null ? 'Cadastrar local' : 'Editar local',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              espaco,
              TextFormField(
                controller: _nome,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: _obrigatorio,
              ),
              espaco,
              DropdownButtonFormField<String>(
                initialValue: _categoria,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: [
                  for (final c in categorias)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => setState(() => _categoria = v!),
              ),
              espaco,
              DropdownButtonFormField<String>(
                initialValue: _cidade,
                decoration: const InputDecoration(labelText: 'Cidade'),
                items: [
                  for (final c in cidades)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => _trocarCidade(v!),
              ),
              espaco,
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitude,
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      validator: _numero(90, min: -90),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _longitude,
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      validator: _numero(180, min: -180),
                    ),
                  ),
                ],
              ),
              espaco,
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _avaliacao,
                      decoration:
                          const InputDecoration(labelText: 'Avaliação (0-5)'),
                      keyboardType: TextInputType.number,
                      validator: _numero(5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _distancia,
                      decoration:
                          const InputDecoration(labelText: 'Distância (km)'),
                      keyboardType: TextInputType.number,
                      validator: _numero(1000),
                    ),
                  ),
                ],
              ),
              espaco,
              TextFormField(
                controller: _horario,
                decoration: const InputDecoration(
                    labelText: 'Horário', hintText: '08:00 - 18:00'),
                validator: _obrigatorio,
              ),
              espaco,
              TextFormField(
                controller: _descricao,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              FilledButton(onPressed: _salvar, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
