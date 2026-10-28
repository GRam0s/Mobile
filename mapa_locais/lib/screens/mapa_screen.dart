import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/local.dart';
import '../services/auth_service.dart';
import '../services/local_service.dart';
import '../widgets/local_card.dart';
import 'detalhes_screen.dart';
import 'resultados_screen.dart';

class MapaScreen extends StatefulWidget {
  /// Local destacado ao vir de "Ver no mapa".
  final Local? destaque;

  const MapaScreen({super.key, this.destaque});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final _service = LocalService();
  final _pesquisa = TextEditingController();
  late String _cidade = widget.destaque?.cidade ?? cidades.first;
  late Stream<List<Local>> _locais = _service.listarLocais(cidade: _cidade);

  @override
  void dispose() {
    _pesquisa.dispose();
    super.dispose();
  }

  void _trocarCidade(String cidade) {
    setState(() {
      _cidade = cidade;
      _locais = _service.listarLocais(cidade: cidade);
    });
  }

  void _abrirResultados() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ResultadosScreen(cidade: _cidade, pesquisa: _pesquisa.text),
      ),
    );
  }

  Future<void> _sair() async {
    await FirebaseAuth.instance.signOut();
    // Volta para a raiz, onde o main.dart mostra a tela de login.
    if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Locais'),
        actions: [
          DropdownButton<String>(
            value: _cidade,
            underline: const SizedBox(),
            icon: const Icon(Icons.location_city),
            items: [
              for (final c in cidades)
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: (v) => _trocarCidade(v!),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Text(
                    '${usuario?.email}\n${ehAdmin(usuario) ? 'Administrador' : 'Usuário comum'}'),
              ),
              PopupMenuItem(onTap: _sair, child: const Text('Sair')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _pesquisa,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _abrirResultados(),
              decoration: InputDecoration(
                hintText: 'Pesquisar em $_cidade (nome ou categoria)',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Local>>(
              stream: _locais,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao carregar os locais.\n${snapshot.error}',
                        textAlign: TextAlign.center),
                  );
                }
                return _Mapa(
                  // A key recria o mapa centralizado ao trocar de cidade.
                  key: ValueKey(_cidade),
                  cidade: _cidade,
                  locais: snapshot.data ?? [],
                  destaque: widget.destaque,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _abrirResultados,
                icon: const Icon(Icons.list),
                label: const Text('Ver resultados'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Mapa extends StatelessWidget {
  final String cidade;
  final List<Local> locais;
  final Local? destaque;

  const _Mapa({
    super.key,
    required this.cidade,
    required this.locais,
    required this.destaque,
  });

  @override
  Widget build(BuildContext context) {
    final centro = destaque?.cidade == cidade
        ? LatLng(destaque!.latitude, destaque!.longitude)
        : LatLng(centroCidade[cidade]!.$1, centroCidade[cidade]!.$2);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: FlutterMap(
        options: MapOptions(initialCenter: centro, initialZoom: 13),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'br.senai.mapa_locais',
          ),
          MarkerLayer(
            markers: [
              for (final local in locais)
                Marker(
                  point: LatLng(local.latitude, local.longitude),
                  width: 130,
                  height: 64,
                  child: _Marcador(
                      local: local, destacado: local.id == destaque?.id),
                ),
            ],
          ),
          const RichAttributionWidget(
            attributions: [TextSourceAttribution('OpenStreetMap contributors')],
          ),
        ],
      ),
    );
  }
}

class _Marcador extends StatelessWidget {
  final Local local;
  final bool destacado;

  const _Marcador({required this.local, required this.destacado});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetalhesScreen(local: local)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: destacado ? 20 : 16,
            backgroundColor: destacado ? Colors.red : Colors.blue.shade800,
            child: Icon(iconesCategoria[local.categoria] ?? Icons.place,
                size: destacado ? 22 : 18, color: Colors.white),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            color: Colors.white70,
            child: Text(local.nome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
