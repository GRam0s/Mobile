import 'package:flutter/material.dart';
import '../models/local.dart';

const iconesCategoria = {
  'Academia': Icons.fitness_center,
  'Restaurante': Icons.restaurant,
  'Farmácia': Icons.local_pharmacy,
  'Mercado': Icons.shopping_cart,
  'Café': Icons.local_cafe,
};

class LocalCard extends StatelessWidget {
  final Local local;
  final bool favorito;
  final VoidCallback onTap;
  // null para usuários comuns: os botões de edição não aparecem.
  final VoidCallback? onEditar;
  final VoidCallback? onExcluir;

  const LocalCard({
    super.key,
    required this.local,
    required this.favorito,
    required this.onTap,
    this.onEditar,
    this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Icon(iconesCategoria[local.categoria] ?? Icons.place),
        ),
        title: Text(local.nome),
        subtitle: Text(
          '${local.categoria} · ${local.cidade}\n'
          '${local.distancia.toStringAsFixed(1)} km · ★ ${local.avaliacao.toStringAsFixed(1)}',
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (favorito)
              const Icon(Icons.favorite, color: Colors.red, size: 20),
            if (onEditar != null)
              IconButton(
                tooltip: 'Editar',
                icon: const Icon(Icons.edit),
                onPressed: onEditar,
              ),
            if (onExcluir != null)
              IconButton(
                tooltip: 'Excluir',
                icon: const Icon(Icons.delete),
                onPressed: onExcluir,
              ),
          ],
        ),
      ),
    );
  }
}
