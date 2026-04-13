import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

void main() {
  runApp(const CadastroApp());
}

class CadastroApp extends StatelessWidget {
  const CadastroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro Inteligente',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}

// ─── HOME PAGE (Listagem) ───────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // ── Busca todos os itens do banco (ordenados por título) ──────────────────
  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getAllItems();
    setState(() {
      _items = data;
      _isLoading = false;
    });
  }

  // ── Remove item pelo ID e atualiza a lista ────────────────────────────────
  Future<void> _deleteItem(int id) async {
    await DatabaseHelper.instance.deleteItem(id);
    _loadItems();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removido com sucesso!'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // ── Diálogo de confirmação antes de excluir ───────────────────────────────
  void _confirmDelete(int id, String titulo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja remover "$titulo"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              _deleteItem(id);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Navega para tela de cadastro/edição ───────────────────────────────────
  Future<void> _navigateToForm({Map<String, dynamic>? item}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormPage(item: item),
      ),
    );
    _loadItems(); // Recarrega ao voltar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        title: const Text(
          '📋 Cadastro Inteligente',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              // ── BÔNUS: Mensagem quando lista está vazia ──────────────────
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum item cadastrado',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toque no + para adicionar o primeiro!',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                )
              // ── Listagem com ListView.builder ────────────────────────────
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return _buildItemCard(item);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo Item'),
      ),
    );
  }

  // ── Card de cada item da lista ────────────────────────────────────────────
  Widget _buildItemCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        // ── Ao clicar abre a tela de edição ─────────────────────────────
        onTap: () => _navigateToForm(item: item),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Ícone colorido
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0x1F6C63FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.article_outlined,
                    color: Color(0xFF6C63FF)),
              ),
              const SizedBox(width: 12),
              // Título + Descrição + Data (BÔNUS)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['titulo'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2B55),
                      ),
                    ),
                    if ((item['descricao'] ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item['descricao'],
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    // ── BÔNUS: Exibe data de criação ─────────────────────
                    if (item['data'] != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 11, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(item['data']),
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Botão Excluir
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'Excluir',
                onPressed: () =>
                    _confirmDelete(item['id'], item['titulo'] ?? ''),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return isoDate;
    }
  }
}

// ─── FORM PAGE (Cadastro / Edição) ─────────────────────────────────────────

class FormPage extends StatefulWidget {
  final Map<String, dynamic>? item; // null = novo cadastro

  const FormPage({super.key, this.item});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    // Pré-preenche campos se estiver editando
    if (_isEditing) {
      _tituloController.text = widget.item!['titulo'] ?? '';
      _descricaoController.text = widget.item!['descricao'] ?? '';
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  // ── Salva (insert ou update) ──────────────────────────────────────────────
  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = {
      'titulo': _tituloController.text.trim(),
      'descricao': _descricaoController.text.trim(),
      // BÔNUS: salva data de criação (apenas no insert)
      'data': _isEditing
          ? widget.item!['data']
          : DateTime.now().toIso8601String(),
    };

    if (_isEditing) {
      await DatabaseHelper.instance.updateItem(widget.item!['id'], data);
    } else {
      await DatabaseHelper.instance.insertItem(data);
    }

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Item atualizado com sucesso!'
              : 'Item cadastrado com sucesso!'),
          backgroundColor: const Color(0xFF6C63FF),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        title: Text(
          _isEditing ? '✏️ Editar Item' : '➕ Novo Item',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Campo Título ─────────────────────────────────────────────
              const Text('Título *',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2B55))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tituloController,
                decoration: _inputDecoration('Digite o título', Icons.title),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Título obrigatório' : null,
              ),
              const SizedBox(height: 20),

              // ── Campo Descrição ──────────────────────────────────────────
              const Text('Descrição',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2B55))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descricaoController,
                decoration:
                    _inputDecoration('Digite a descrição', Icons.notes),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 32),

              // ── Botão Salvar ─────────────────────────────────────────────
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Icon(_isEditing ? Icons.save : Icons.check),
                label: Text(_isEditing ? 'Atualizar' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
      ),
    );
  }
}
