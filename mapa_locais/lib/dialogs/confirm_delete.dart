import 'package:flutter/material.dart';

Future<bool> confirmarExclusao(BuildContext context, String nome) async {
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Excluir "$nome"?'),
        content: const Text('Essa ação não poderá ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      );
    },
  );
  return confirmou == true;
}
