import 'package:flutter/material.dart';

void main() {
  runApp(const AppContatos());
}

class AppContatos extends StatelessWidget {
  const AppContatos({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contatos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const ListaContatos(),
    );
  }
}

// ─────────────────────────────────────────────
//  MODELO DE DADOS
// ─────────────────────────────────────────────
class Contato {
  final String nome;
  final String telefone;
  final String email;
  final String avatar; // iniciais

  const Contato({
    required this.nome,
    required this.telefone,
    required this.email,
    required this.avatar,
  });
}

// ─────────────────────────────────────────────
//  TELA 1 – LISTA DE CONTATOS
// ─────────────────────────────────────────────
class ListaContatos extends StatelessWidget {
  const ListaContatos({super.key});

  // Lista fixa de contatos
  static const List<Contato> contatos = [
    Contato(
      nome: 'Ana Silva',
      telefone: '(11) 98765-4321',
      email: 'ana.silva@email.com',
      avatar: 'AS',
    ),
    Contato(
      nome: 'Bruno Costa',
      telefone: '(21) 91234-5678',
      email: 'bruno.costa@email.com',
      avatar: 'BC',
    ),
    Contato(
      nome: 'Carla Mendes',
      telefone: '(31) 99876-5432',
      email: 'carla.mendes@email.com',
      avatar: 'CM',
    ),
    Contato(
      nome: 'Diego Rocha',
      telefone: '(41) 97654-3210',
      email: 'diego.rocha@email.com',
      avatar: 'DR',
    ),
    Contato(
      nome: 'Elisa Ferreira',
      telefone: '(51) 93210-9876',
      email: 'elisa.ferreira@email.com',
      avatar: 'EF',
    ),
  ];

  // Cores dos avatares
  static const List<Color> coresAvatar = [
    Color(0xFF6C63FF),
    Color(0xFFFF6584),
    Color(0xFF43C6AC),
    Color(0xFFFFA500),
    Color(0xFF3A86FF),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        title: const Text(
          'Meus Contatos',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: false,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              '${ListaContatos.contatos.length} contatos',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: contatos.length,
              itemBuilder: (context, index) {
                final contato = contatos[index];
                final cor = coresAvatar[index % coresAvatar.length];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    elevation: 2,
                    shadowColor: cor.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: cor,
                        radius: 26,
                        child: Text(
                          contato.avatar,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      title: Text(
                        contato.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        contato.telefone,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: cor,
                      ),
                      onTap: () {
                        // Navega para a tela de detalhes passando os dados
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalheContato(
                              contato: contato,
                              corAvatar: cor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // Extensão futura
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TELA 2 – DETALHES DO CONTATO
// ─────────────────────────────────────────────
class DetalheContato extends StatelessWidget {
  final Contato contato;
  final Color corAvatar;

  const DetalheContato({
    super.key,
    required this.contato,
    required this.corAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // AppBar transparente – o header é customizado
      appBar: AppBar(
        backgroundColor: corAvatar,
        foregroundColor: Colors.white,
        title: const Text('Detalhes'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context), // Volta para a lista
        ),
      ),
      body: Column(
        children: [
          // ── Header colorido com avatar ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 32, top: 20),
            decoration: BoxDecoration(
              color: corAvatar,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(36),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  child: Text(
                    contato.avatar,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  contato.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Cards de informação ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _InfoCard(
                  icone: Icons.phone,
                  label: 'Telefone',
                  valor: contato.telefone,
                  cor: corAvatar,
                ),
                const SizedBox(height: 14),
                _InfoCard(
                  icone: Icons.email_outlined,
                  label: 'E-mail',
                  valor: contato.email,
                  cor: corAvatar,
                ),
              ],
            ),
          ),

          const Spacer(),

          // ── Botão Voltar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text(
                  'Voltar para Lista',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: corAvatar,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: corAvatar.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WIDGET AUXILIAR – Card de informação
// ─────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icone;
  final String label;
  final String valor;
  final Color cor;

  const _InfoCard({
    required this.icone,
    required this.label,
    required this.valor,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cor.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icone, color: cor, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
