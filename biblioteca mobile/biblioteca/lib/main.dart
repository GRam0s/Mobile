import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';



void main() {

  runApp(const SenaiStockApp());

}



// ─────────────────────────────────────────────

// MODELS

// ─────────────────────────────────────────────



class Usuario {

  final String id;

  final String nome;

  final String login;

  final String senha;

  final String perfil; // 'almoxarife' | 'professor'



  const Usuario({

    required this.id,

    required this.nome,

    required this.login,

    required this.senha,

    required this.perfil,

  });



  Usuario copyWith({String? nome, String? login, String? senha, String? perfil}) {

    return Usuario(

      id: id,

      nome: nome ?? this.nome,

      login: login ?? this.login,

      senha: senha ?? this.senha,

      perfil: perfil ?? this.perfil,

    );

  }



  factory Usuario.fromJson(Map<String, dynamic> j) => Usuario(

    id: j['id'] as String,

    nome: j['nome'] as String,

    login: j['login'] as String,

    senha: j['senha'] as String,

    perfil: j['perfil'] as String,

  );



  Map<String, dynamic> toJson() => {

    'id': id,

    'nome': nome,

    'login': login,

    'senha': senha,

    'perfil': perfil,

  };

}



class Livro {

  final String id;

  String titulo;

  String isbn;

  String materia;

  int saldo;

  static const int nivelMinimo = 10;



  Livro({

    required this.id,

    required this.titulo,

    required this.isbn,

    required this.materia,

    this.saldo = 0,

  });



  bool get estoqueAbaixoMinimo => saldo < nivelMinimo;

  bool get estoqueCritico => saldo == 0;



  factory Livro.fromJson(Map<String, dynamic> j) => Livro(

    id: j['id'] as String,

    titulo: j['titulo'] as String,

    isbn: j['isbn'] as String,

    materia: j['materia'] as String,

    saldo: j['saldo'] as int,

  );



  Map<String, dynamic> toJson() => {

    'id': id,

    'titulo': titulo,

    'isbn': isbn,

    'materia': materia,

    'saldo': saldo,

  };

}



class Movimentacao {

  final String id;

  final String livroId;

  final String livroTitulo;

  final String tipo; // 'entrada' | 'saida'

  final int quantidade;

  final String? observacao;

  final DateTime data;

  final String usuarioNome;



  const Movimentacao({

    required this.id,

    required this.livroId,

    required this.livroTitulo,

    required this.tipo,

    required this.quantidade,

    this.observacao,

    required this.data,

    required this.usuarioNome,

  });



  factory Movimentacao.fromJson(Map<String, dynamic> j) => Movimentacao(

    id: j['id'] as String,

    livroId: j['livroId'] as String,

    livroTitulo: j['livroTitulo'] as String,

    tipo: j['tipo'] as String,

    quantidade: j['quantidade'] as int,

    observacao: j['observacao'] as String?,

    data: DateTime.parse(j['data'] as String),

    usuarioNome: j['usuarioNome'] as String,

  );



  Map<String, dynamic> toJson() => {

    'id': id,

    'livroId': livroId,

    'livroTitulo': livroTitulo,

    'tipo': tipo,

    'quantidade': quantidade,

    'observacao': observacao,

    'data': data.toIso8601String(),

    'usuarioNome': usuarioNome,

  };

}



class Solicitacao {

  final String id;

  final String professorLogin;

  final String professorNome;

  final String livroId;

  final String livroTitulo;

  final int quantidade;

  final String? observacao;

  final DateTime dataSolicitacao;

  String status; // 'pendente' | 'aprovada' | 'recusada'

  String? motivoRecusa;

  DateTime? dataResposta;

  bool lidaAlmo; // almoxarife viu a solicitação?

  bool lidaProf; // professor viu a resposta?



  Solicitacao({

    required this.id,

    required this.professorLogin,

    required this.professorNome,

    required this.livroId,

    required this.livroTitulo,

    required this.quantidade,

    this.observacao,

    required this.dataSolicitacao,

    this.status = 'pendente',

    this.motivoRecusa,

    this.dataResposta,

    this.lidaAlmo = false,

    this.lidaProf = false,

  });



  factory Solicitacao.fromJson(Map<String, dynamic> j) => Solicitacao(

    id: j['id'] as String,

    professorLogin: j['professorLogin'] as String,

    professorNome: j['professorNome'] as String,

    livroId: j['livroId'] as String,

    livroTitulo: j['livroTitulo'] as String,

    quantidade: j['quantidade'] as int,

    observacao: j['observacao'] as String?,

    dataSolicitacao: DateTime.parse(j['dataSolicitacao'] as String),

    status: j['status'] as String,

    motivoRecusa: j['motivoRecusa'] as String?,

    dataResposta: j['dataResposta'] != null ? DateTime.parse(j['dataResposta'] as String) : null,

    lidaAlmo: j['lidaAlmo'] as bool,

    lidaProf: j['lidaProf'] as bool,

  );



  Map<String, dynamic> toJson() => {

    'id': id,

    'professorLogin': professorLogin,

    'professorNome': professorNome,

    'livroId': livroId,

    'livroTitulo': livroTitulo,

    'quantidade': quantidade,

    'observacao': observacao,

    'dataSolicitacao': dataSolicitacao.toIso8601String(),

    'status': status,

    'motivoRecusa': motivoRecusa,

    'dataResposta': dataResposta?.toIso8601String(),

    'lidaAlmo': lidaAlmo,

    'lidaProf': lidaProf,

  };

}



// ─────────────────────────────────────────────

// SERVIÇO / MOCK BACKEND

// ─────────────────────────────────────────────



class StockService extends ChangeNotifier {

  Usuario? _usuarioLogado;

  Usuario? get usuarioLogado => _usuarioLogado;

  bool get autenticado => _usuarioLogado != null;



  final List<Usuario> _usuarios = [

    Usuario(

      id: '1',

      nome: 'Almoxarife',

      login: 'almoxarife',

      senha: '1234',

      perfil: 'almoxarife',

    ),

    Usuario(

      id: '2',

      nome: 'Professor',

      login: 'professor',

      senha: '1234',

      perfil: 'professor',

    ),

  ];



  final List<Livro> _livros = [

    Livro(

      id: '1',

      titulo: 'Fundamentos de Elétrica Industrial',

      isbn: '978-85-7404-123-4',

      materia: 'Elétrica',

      saldo: 45,

    ),

    Livro(

      id: '2',

      titulo: 'Automação e Controle de Processos',

      isbn: '978-85-7404-456-5',

      materia: 'Automação',

      saldo: 8,

    ),

    Livro(

      id: '3',

      titulo: 'Segurança do Trabalho - NR10',

      isbn: '978-85-7404-789-6',

      materia: 'Segurança',

      saldo: 0,

    ),

    Livro(

      id: '4',

      titulo: 'Mecânica Geral Aplicada',

      isbn: '978-85-7404-321-0',

      materia: 'Mecânica',

      saldo: 22,

    ),

    Livro(

      id: '5',

      titulo: 'Informática para Técnicos',

      isbn: '978-85-7404-654-1',

      materia: 'Informática',

      saldo: 5,

    ),

  ];



  final List<Movimentacao> _movimentacoes = [];

  final List<Solicitacao> _solicitacoes = [];



  List<Livro> get livros => List.unmodifiable(_livros);

  List<Movimentacao> get movimentacoes => List.unmodifiable(_movimentacoes);

  List<Usuario> get usuarios => List.unmodifiable(_usuarios);

  List<Solicitacao> get solicitacoes => List.unmodifiable(_solicitacoes);

  List<Livro> get livrosBaixoEstoque =>

      _livros.where((l) => l.estoqueAbaixoMinimo).toList();



  List<Solicitacao> get solicitacoesPendentes =>

      _solicitacoes.where((s) => s.status == 'pendente').toList();



  List<Solicitacao> solicitacoesDoProf(String login) =>

      _solicitacoes.where((s) => s.professorLogin == login).toList();



  int get notifAlmoxarife =>

      _solicitacoes.where((s) => !s.lidaAlmo).length;



  int notifProfessor(String login) => _solicitacoes

      .where((s) =>

          s.professorLogin == login &&

          !s.lidaProf &&

          s.status != 'pendente')

      .length;



  // ── AUTH ──────────────────────────────────



  bool login(String loginInput, String senhaInput) {

    try {

      final usuario = _usuarios.firstWhere(

        (u) => u.login == loginInput && u.senha == senhaInput,

      );

      _usuarioLogado = usuario;

      notifyListeners();

      return true;

    } catch (_) {

      return false;

    }

  }



  void logout() {

    _usuarioLogado = null;

    notifyListeners();

  }



  // ── USUÁRIOS ──────────────────────────────



  String cadastrarUsuario({

    required String nome,

    required String login,

    required String senha,

    required String perfil,

  }) {

    if (nome.isEmpty || login.isEmpty || senha.isEmpty) {

      return 'Preencha todos os campos.';

    }

    if (_usuarios.any((u) => u.login == login)) {

      return 'Usuário já cadastrado.';

    }

    _usuarios.add(Usuario(

      id: DateTime.now().millisecondsSinceEpoch.toString(),

      nome: nome,

      login: login,

      senha: senha,

      perfil: perfil,

    ));

    notifyListeners();

    _salvarUsuarios();

    return 'ok';

  }



  String editarUsuario({

    required String id,

    required String nome,

    required String login,

    required String senha,

    required String perfil,

  }) {

    if (nome.isEmpty || login.isEmpty || senha.isEmpty) {

      return 'Preencha todos os campos.';

    }

    final idx = _usuarios.indexWhere((u) => u.id == id);

    if (idx == -1) return 'Usuário não encontrado.';

    if (_usuarios.any((u) => u.login == login && u.id != id)) {

      return 'Usuário já cadastrado.';

    }

    _usuarios[idx] = _usuarios[idx].copyWith(

      nome: nome,

      login: login,

      senha: senha,

      perfil: perfil,

    );

    notifyListeners();

    _salvarUsuarios();

    return 'ok';

  }



  // ── CATÁLOGO ──────────────────────────────



  String cadastrarLivro({

    required String titulo,

    required String isbn,

    required String materia,

  }) {

    if (titulo.isEmpty || isbn.isEmpty || materia.isEmpty) {

      return 'Preencha todos os campos.';

    }

    final existe = _livros.any((l) => l.isbn == isbn);

    if (existe) return 'ISBN já cadastrado.';



    _livros.add(

      Livro(

        id: DateTime.now().millisecondsSinceEpoch.toString(),

        titulo: titulo,

        isbn: isbn,

        materia: materia,

      ),

    );

    notifyListeners();

    _salvarLivros();

    return 'ok';

  }



  // ── ENTRADA ───────────────────────────────



  String registrarEntrada({

    required String livroId,

    required int quantidade,

    String? observacao,

  }) {

    if (quantidade <= 0) return 'Quantidade deve ser maior que zero.';

    final idx = _livros.indexWhere((l) => l.id == livroId);

    if (idx == -1) return 'Livro não encontrado.';



    _livros[idx].saldo += quantidade;



    _movimentacoes.insert(

      0,

      Movimentacao(

        id: DateTime.now().millisecondsSinceEpoch.toString(),

        livroId: livroId,

        livroTitulo: _livros[idx].titulo,

        tipo: 'entrada',

        quantidade: quantidade,

        observacao: observacao,

        data: DateTime.now(),

        usuarioNome: _usuarioLogado!.nome,

      ),

    );

    notifyListeners();

    _salvarLivros();

    _salvarMovimentacoes();

    return 'ok';

  }



  // ── SAÍDA ─────────────────────────────────



  String registrarSaida({

    required String livroId,

    required int quantidade,

    String? observacao,

  }) {

    if (quantidade <= 0) return 'Quantidade deve ser maior que zero.';

    final idx = _livros.indexWhere((l) => l.id == livroId);

    if (idx == -1) return 'Livro não encontrado.';



    if (_livros[idx].saldo < quantidade) {

      return 'Estoque Insuficiente. Saldo atual: ${_livros[idx].saldo} unidades.';

    }



    _livros[idx].saldo -= quantidade;



    _movimentacoes.insert(

      0,

      Movimentacao(

        id: DateTime.now().millisecondsSinceEpoch.toString(),

        livroId: livroId,

        livroTitulo: _livros[idx].titulo,

        tipo: 'saida',

        quantidade: quantidade,

        observacao: observacao,

        data: DateTime.now(),

        usuarioNome: _usuarioLogado!.nome,

      ),

    );

    notifyListeners();

    _salvarLivros();

    _salvarMovimentacoes();

    return 'ok';

  }



  // ── SOLICITAÇÕES ──────────────────────────



  String criarSolicitacao({

    required String livroId,

    required int quantidade,

    String? observacao,

  }) {

    if (quantidade <= 0) return 'Quantidade deve ser maior que zero.';

    final idx = _livros.indexWhere((l) => l.id == livroId);

    if (idx == -1) return 'Livro não encontrado.';

    _solicitacoes.insert(

      0,

      Solicitacao(

        id: DateTime.now().millisecondsSinceEpoch.toString(),

        professorLogin: _usuarioLogado!.login,

        professorNome: _usuarioLogado!.nome,

        livroId: livroId,

        livroTitulo: _livros[idx].titulo,

        quantidade: quantidade,

        observacao: observacao,

        dataSolicitacao: DateTime.now(),

        lidaAlmo: false,

        lidaProf: false,

      ),

    );

    notifyListeners();

    _salvarSolicitacoes();

    return 'ok';

  }



  String aprovarSolicitacao(String solicitacaoId) {

    final si = _solicitacoes.indexWhere((s) => s.id == solicitacaoId);

    if (si == -1) return 'Solicitação não encontrada.';

    final sol = _solicitacoes[si];

    final li = _livros.indexWhere((l) => l.id == sol.livroId);

    if (li == -1) return 'Livro não encontrado.';

    if (_livros[li].saldo < sol.quantidade) {

      return 'Estoque insuficiente (${_livros[li].saldo} un. disponíveis).';

    }

    _livros[li].saldo -= sol.quantidade;

    _movimentacoes.insert(

      0,

      Movimentacao(

        id: DateTime.now().millisecondsSinceEpoch.toString(),

        livroId: sol.livroId,

        livroTitulo: sol.livroTitulo,

        tipo: 'saida',

        quantidade: sol.quantidade,

        observacao: 'Aprovado para ${sol.professorNome}',

        data: DateTime.now(),

        usuarioNome: _usuarioLogado!.nome,

      ),

    );

    sol.status = 'aprovada';

    sol.dataResposta = DateTime.now();

    sol.lidaAlmo = true;

    sol.lidaProf = false;

    notifyListeners();

    _salvarLivros();

    _salvarMovimentacoes();

    _salvarSolicitacoes();

    return 'ok';

  }



  String recusarSolicitacao(String solicitacaoId, String motivo) {

    final si = _solicitacoes.indexWhere((s) => s.id == solicitacaoId);

    if (si == -1) return 'Solicitação não encontrada.';

    final sol = _solicitacoes[si];

    sol.status = 'recusada';

    sol.motivoRecusa = motivo.trim().isEmpty ? 'Sem motivo informado.' : motivo.trim();

    sol.dataResposta = DateTime.now();

    sol.lidaAlmo = true;

    sol.lidaProf = false;

    notifyListeners();

    _salvarSolicitacoes();

    return 'ok';

  }



  void marcarLidasAlmo() {

    bool changed = false;

    for (final s in _solicitacoes.where((s) => !s.lidaAlmo)) {

      s.lidaAlmo = true;

      changed = true;

    }

    if (changed) {

      notifyListeners();

      _salvarSolicitacoes();

    }

  }



  void marcarLidasProf(String login) {

    bool changed = false;

    for (final s in _solicitacoes

        .where((s) => s.professorLogin == login && !s.lidaProf)) {

      s.lidaProf = true;

      changed = true;

    }

    if (changed) {

      notifyListeners();

      _salvarSolicitacoes();

    }

  }



  // ── PERSISTÊNCIA ──────────────────────────



  Future<void> inicializar() async {

    final prefs = await SharedPreferences.getInstance();



    final usuariosJson = prefs.getString('usuarios');

    if (usuariosJson != null) {

      final list = jsonDecode(usuariosJson) as List;

      _usuarios

        ..clear()

        ..addAll(list.map((j) => Usuario.fromJson(j as Map<String, dynamic>)));

    }



    final livrosJson = prefs.getString('livros');

    if (livrosJson != null) {

      final list = jsonDecode(livrosJson) as List;

      _livros

        ..clear()

        ..addAll(list.map((j) => Livro.fromJson(j as Map<String, dynamic>)));

    }



    final movJson = prefs.getString('movimentacoes');

    if (movJson != null) {

      final list = jsonDecode(movJson) as List;

      _movimentacoes

        ..clear()

        ..addAll(list.map((j) => Movimentacao.fromJson(j as Map<String, dynamic>)));

    }



    final solJson = prefs.getString('solicitacoes');

    if (solJson != null) {

      final list = jsonDecode(solJson) as List;

      _solicitacoes

        ..clear()

        ..addAll(list.map((j) => Solicitacao.fromJson(j as Map<String, dynamic>)));

    }

  }



  Future<void> _salvarUsuarios() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('usuarios', jsonEncode(_usuarios.map((u) => u.toJson()).toList()));

  }



  Future<void> _salvarLivros() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('livros', jsonEncode(_livros.map((l) => l.toJson()).toList()));

  }



  Future<void> _salvarMovimentacoes() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('movimentacoes', jsonEncode(_movimentacoes.map((m) => m.toJson()).toList()));

  }



  Future<void> _salvarSolicitacoes() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('solicitacoes', jsonEncode(_solicitacoes.map((s) => s.toJson()).toList()));

  }

}



// ─────────────────────────────────────────────

// APP ROOT

// ─────────────────────────────────────────────



class SenaiStockApp extends StatefulWidget {

  const SenaiStockApp({super.key});



  @override

  State<SenaiStockApp> createState() => _SenaiStockAppState();

}



class _SenaiStockAppState extends State<SenaiStockApp> {

  final StockService _service = StockService();

  bool _carregando = true;



  @override

  void initState() {

    super.initState();

    _service.inicializar().then((_) {

      if (mounted) setState(() => _carregando = false);

    });

  }



  @override

  Widget build(BuildContext context) {

    if (_carregando) {

      return const MaterialApp(

        home: Scaffold(

          body: Center(child: CircularProgressIndicator()),

        ),

      );

    }

    return AnimatedBuilder(

      animation: _service,

      builder: (context, _) {

        return MaterialApp(

          title: 'SenaiStock',

          debugShowCheckedModeBanner: false,

          theme: _buildTheme(),

          home: _service.autenticado

              ? HomeScreen(service: _service)

              : LoginScreen(service: _service),

        );

      },

    );

  }



  ThemeData _buildTheme() {

    const primary = Color(0xFFCC0020);

    const primaryDark = Color(0xFF8B0000);

    const bg = Color(0xFFFCF8F8);

    const surface = Color(0xFFFFFFFF);



    return ThemeData(

      useMaterial3: true,

      colorScheme: ColorScheme.light(

        primary: primary,

        secondary: primaryDark,

        surface: surface,

        onPrimary: Colors.white,

        onSecondary: Colors.white,

      ),

      scaffoldBackgroundColor: bg,

      appBarTheme: const AppBarTheme(

        backgroundColor: primary,

        foregroundColor: Colors.white,

        elevation: 0,

        centerTitle: false,

        titleTextStyle: TextStyle(

          fontSize: 18,

          fontWeight: FontWeight.w700,

          color: Colors.white,

          letterSpacing: 0.2,

        ),

      ),

      cardTheme: CardThemeData(

        color: surface,

        elevation: 0,

        shape: RoundedRectangleBorder(

          borderRadius: BorderRadius.circular(14),

          side: const BorderSide(color: Color(0xFFEDE4E4), width: 1),

        ),

        margin: EdgeInsets.zero,

      ),

      inputDecorationTheme: InputDecorationTheme(

        filled: true,

        fillColor: const Color(0xFFFFF5F5),

        border: OutlineInputBorder(

          borderRadius: BorderRadius.circular(12),

          borderSide: const BorderSide(color: Color(0xFFE8DADA)),

        ),

        enabledBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(12),

          borderSide: const BorderSide(color: Color(0xFFE8DADA)),

        ),

        focusedBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(12),

          borderSide: const BorderSide(color: primary, width: 2),

        ),

        contentPadding: const EdgeInsets.symmetric(

          horizontal: 16,

          vertical: 14,

        ),

        labelStyle: const TextStyle(color: Color(0xFF8C7070), fontSize: 14),

        prefixIconColor: primary,

      ),

      elevatedButtonTheme: ElevatedButtonThemeData(

        style: ElevatedButton.styleFrom(

          backgroundColor: primary,

          foregroundColor: Colors.white,

          elevation: 0,

          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),

          shape: RoundedRectangleBorder(

            borderRadius: BorderRadius.circular(12),

          ),

          textStyle: const TextStyle(

            fontWeight: FontWeight.w700,

            fontSize: 15,

            letterSpacing: 0.4,

          ),

        ),

      ),

      textButtonTheme: TextButtonThemeData(

        style: TextButton.styleFrom(

          foregroundColor: primary,

          textStyle: const TextStyle(fontWeight: FontWeight.w600),

        ),

      ),

      chipTheme: ChipThemeData(

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),

      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(

        backgroundColor: primary,

        foregroundColor: Colors.white,

        elevation: 3,

        shape: CircleBorder(),

      ),

    );

  }

}



// ─────────────────────────────────────────────

// LOGIN SCREEN

// ─────────────────────────────────────────────



class LoginScreen extends StatefulWidget {

  final StockService service;

  const LoginScreen({super.key, required this.service});



  @override

  State<LoginScreen> createState() => _LoginScreenState();

}



class _LoginScreenState extends State<LoginScreen> {

  final _loginCtrl = TextEditingController();

  final _senhaCtrl = TextEditingController();

  bool _senhaVisivel = false;

  bool _carregando = false;

  String? _erro;



  @override

  void dispose() {

    _loginCtrl.dispose();

    _senhaCtrl.dispose();

    super.dispose();

  }



  void _entrar() async {

    setState(() {

      _carregando = true;

      _erro = null;

    });

    await Future.delayed(const Duration(milliseconds: 500));

    final ok = widget.service.login(

      _loginCtrl.text.trim(),

      _senhaCtrl.text.trim(),

    );

    setState(() {

      _carregando = false;

      if (!ok) _erro = 'Usuário ou senha incorretos.';

    });

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      body: Stack(

        children: [

          // Fundo gradiente vermelho

          Container(

            height: MediaQuery.of(context).size.height * 0.52,

            decoration: const BoxDecoration(

              gradient: LinearGradient(

                colors: [Color(0xFFCC0020), Color(0xFF6B0011)],

                begin: Alignment.topLeft,

                end: Alignment.bottomRight,

              ),

            ),

          ),

          // Círculo decorativo topo direito

          Positioned(

            top: -60,

            right: -60,

            child: Container(

              width: 220,

              height: 220,

              decoration: BoxDecoration(

                shape: BoxShape.circle,

                color: Colors.white.withValues(alpha: 0.07),

              ),

            ),

          ),

          // Círculo decorativo menor

          Positioned(

            top: 40,

            right: 60,

            child: Container(

              width: 90,

              height: 90,

              decoration: BoxDecoration(

                shape: BoxShape.circle,

                color: Colors.white.withValues(alpha: 0.06),

              ),

            ),

          ),

          SafeArea(

            child: Column(

              children: [

                // Header

                Expanded(

                  flex: 5,

                  child: Padding(

                    padding: const EdgeInsets.symmetric(horizontal: 32),

                    child: Column(

                      mainAxisAlignment: MainAxisAlignment.center,

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        Container(

                          width: 64,

                          height: 64,

                          decoration: BoxDecoration(

                            color: Colors.white.withValues(alpha: 0.18),

                            borderRadius: BorderRadius.circular(18),

                            border: Border.all(

                              color: Colors.white.withValues(alpha: 0.3),

                              width: 1.5,

                            ),

                          ),

                          child: const Icon(

                            Icons.inventory_2_rounded,

                            color: Colors.white,

                            size: 32,

                          ),

                        ),

                        const SizedBox(height: 20),

                        const Text(

                          'SenaiStock',

                          style: TextStyle(

                            color: Colors.white,

                            fontSize: 36,

                            fontWeight: FontWeight.w800,

                            letterSpacing: -1,

                            height: 1.1,

                          ),

                        ),

                        const SizedBox(height: 6),

                        Text(

                          'Controle de estoque\nde livros didáticos',

                          style: TextStyle(

                            color: Colors.white.withValues(alpha: 0.75),

                            fontSize: 14,

                            height: 1.5,

                          ),

                        ),

                      ],

                    ),

                  ),

                ),

                // Card de login

                Expanded(

                  flex: 7,

                  child: Container(

                    width: double.infinity,

                    decoration: const BoxDecoration(

                      color: Color(0xFFFCF8F8),

                      borderRadius: BorderRadius.vertical(

                        top: Radius.circular(32),

                      ),

                      boxShadow: [

                        BoxShadow(

                          color: Color(0x22000000),

                          blurRadius: 24,

                          offset: Offset(0, -4),

                        ),

                      ],

                    ),

                    padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),

                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        const Text(

                          'Bem-vindo',

                          style: TextStyle(

                            fontSize: 24,

                            fontWeight: FontWeight.w800,

                            color: Color(0xFF1A0A0A),

                            letterSpacing: -0.5,

                          ),

                        ),

                        const SizedBox(height: 4),

                        const Text(

                          'Acesso restrito a funcionários autorizados',

                          style: TextStyle(

                            fontSize: 13,

                            color: Color(0xFF8C7070),

                          ),

                        ),

                        const SizedBox(height: 28),

                        TextField(

                          controller: _loginCtrl,

                          decoration: const InputDecoration(

                            labelText: 'Usuário',

                            prefixIcon: Icon(Icons.person_outline_rounded,

                                size: 20),

                          ),

                          textInputAction: TextInputAction.next,

                        ),

                        const SizedBox(height: 14),

                        TextField(

                          controller: _senhaCtrl,

                          obscureText: !_senhaVisivel,

                          decoration: InputDecoration(

                            labelText: 'Senha',

                            prefixIcon: const Icon(Icons.lock_outline_rounded,

                                size: 20),

                            suffixIcon: IconButton(

                              icon: Icon(

                                _senhaVisivel

                                    ? Icons.visibility_off_outlined

                                    : Icons.visibility_outlined,

                                size: 20,

                                color: const Color(0xFF8C7070),

                              ),

                              onPressed: () => setState(

                                  () => _senhaVisivel = !_senhaVisivel),

                            ),

                          ),

                          onSubmitted: (_) => _entrar(),

                        ),

                        if (_erro != null) ...[

                          const SizedBox(height: 12),

                          Container(

                            padding: const EdgeInsets.symmetric(

                                horizontal: 14, vertical: 10),

                            decoration: BoxDecoration(

                              color: const Color(0xFFFFEEEE),

                              borderRadius: BorderRadius.circular(10),

                              border: const Border.fromBorderSide(

                                BorderSide(color: Color(0xFFFFCCCC)),

                              ),

                            ),

                            child: Row(

                              children: [

                                const Icon(Icons.error_outline,

                                    color: Color(0xFFCC0020), size: 18),

                                const SizedBox(width: 8),

                                Text(

                                  _erro!,

                                  style: const TextStyle(

                                      color: Color(0xFFCC0020), fontSize: 13),

                                ),

                              ],

                            ),

                          ),

                        ],

                        const SizedBox(height: 24),

                        SizedBox(

                          width: double.infinity,

                          height: 52,

                          child: ElevatedButton(

                            onPressed: _carregando ? null : _entrar,

                            style: ElevatedButton.styleFrom(

                              backgroundColor: const Color(0xFFCC0020),

                              shape: RoundedRectangleBorder(

                                borderRadius: BorderRadius.circular(14),

                              ),

                            ),

                            child: _carregando

                                ? const SizedBox(

                                    height: 20,

                                    width: 20,

                                    child: CircularProgressIndicator(

                                      strokeWidth: 2.5,

                                      color: Colors.white,

                                    ),

                                  )

                                : const Text('Entrar',

                                    style: TextStyle(

                                        fontSize: 16,

                                        fontWeight: FontWeight.w700)),

                          ),

                        ),

                        const Spacer(),

                        Center(

                          child: Text(

                            'almoxarife / 1234  ·  professor / 1234',

                            style: const TextStyle(

                              fontSize: 10,

                              color: Color(0xFFBBA0A0),

                            ),

                            textAlign: TextAlign.center,

                          ),

                        ),

                      ],

                    ),

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

}



// ─────────────────────────────────────────────

// HOME SCREEN (com navegação)

// ─────────────────────────────────────────────



class HomeScreen extends StatefulWidget {

  final StockService service;

  const HomeScreen({super.key, required this.service});



  @override

  State<HomeScreen> createState() => _HomeScreenState();

}



class _HomeScreenState extends State<HomeScreen> {

  int _tab = 0;



  bool get _isAlmoxarife =>

      widget.service.usuarioLogado?.perfil == 'almoxarife';



  bool get _isProfessor =>

      widget.service.usuarioLogado?.perfil == 'professor';



  late final List<Widget> _tabWidgets;



  @override

  void initState() {

    super.initState();

    _tabWidgets = _isProfessor

        ? [

            DashboardTab(service: widget.service),

            CatalogoTab(service: widget.service),

            SolicitarTab(service: widget.service),

            MinhasSolicitacoesTab(service: widget.service),

          ]

        : [

            DashboardTab(service: widget.service),

            CatalogoTab(service: widget.service),

            MovimentacaoTab(service: widget.service, tipo: 'entrada'),

            SolicitacoesTab(service: widget.service),

            MonitoramentoTab(service: widget.service),

            RelatoriosTab(service: widget.service),

            UsuariosTab(

              service: widget.service,

              onEditar: (u) =>

                  _mostrarDialogEdicaoUsuario(context, u),

            ),

          ];

  }



  @override

  Widget build(BuildContext context) {

    FloatingActionButton? fab;

    if (_isAlmoxarife && _tab == 1) {

      fab = FloatingActionButton(

        onPressed: () => _mostrarDialogCadastroLivro(context),

        tooltip: 'Cadastrar Livro',

        child: const Icon(Icons.add),

      );

    } else if (_isAlmoxarife && _tab == 6) {

      fab = FloatingActionButton(

        onPressed: () => _mostrarDialogCadastroUsuario(context),

        tooltip: 'Cadastrar Professor',

        child: const Icon(Icons.person_add_rounded),

      );

    }



    return Scaffold(

      appBar: AppBar(

        flexibleSpace: Container(

          decoration: const BoxDecoration(

            gradient: LinearGradient(

              colors: [Color(0xFFCC0020), Color(0xFF8B0000)],

              begin: Alignment.centerLeft,

              end: Alignment.centerRight,

            ),

          ),

        ),

        backgroundColor: Colors.transparent,

        title: Row(

          children: [

            Container(

              padding: const EdgeInsets.all(6),

              decoration: BoxDecoration(

                color: Colors.white.withValues(alpha: 0.18),

                borderRadius: BorderRadius.circular(8),

              ),

              child: const Icon(Icons.inventory_2_rounded,

                  size: 18, color: Colors.white),

            ),

            const SizedBox(width: 10),

            const Text('SenaiStock'),

          ],

        ),

        actions: [

          Padding(

            padding: const EdgeInsets.only(right: 4),

            child: Center(

              child: Container(

                padding:

                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),

                decoration: BoxDecoration(

                  color: Colors.white.withValues(alpha: 0.2),

                  borderRadius: BorderRadius.circular(20),

                  border: Border.all(

                    color: Colors.white.withValues(alpha: 0.4),

                    width: 1,

                  ),

                ),

                child: Text(

                  widget.service.usuarioLogado!.perfil.toUpperCase(),

                  style: const TextStyle(

                    fontSize: 10,

                    fontWeight: FontWeight.w700,

                    color: Colors.white,

                    letterSpacing: 0.5,

                  ),

                ),

              ),

            ),

          ),

          IconButton(

            icon: const Icon(Icons.logout_rounded),

            tooltip: 'Sair',

            onPressed: () => _confirmarLogout(context),

          ),

        ],

      ),

      body: IndexedStack(

        index: _tab,

        children: _tabWidgets,

      ),

      floatingActionButton: fab,

      bottomNavigationBar: NavigationBar(

        selectedIndex: _tab,

        onDestinationSelected: (i) => setState(() => _tab = i),

        backgroundColor: Colors.white,

        indicatorColor: const Color(0xFFFFE5E8),

        destinations: _isProfessor

            ? [

                const NavigationDestination(

                  icon: Icon(Icons.dashboard_outlined),

                  selectedIcon: Icon(Icons.dashboard_rounded),

                  label: 'Painel',

                ),

                const NavigationDestination(

                  icon: Icon(Icons.menu_book_outlined),

                  selectedIcon: Icon(Icons.menu_book_rounded),

                  label: 'Catálogo',

                ),

                const NavigationDestination(

                  icon: Icon(Icons.send_outlined),

                  selectedIcon: Icon(Icons.send_rounded),

                  label: 'Solicitar',

                ),

                NavigationDestination(

                  icon: Badge(

                    isLabelVisible: widget.service.notifProfessor(

                            widget.service.usuarioLogado!.login) >

                        0,

                    label: Text(widget.service

                        .notifProfessor(widget.service.usuarioLogado!.login)

                        .toString()),

                    child: const Icon(Icons.inbox_outlined),

                  ),

                  selectedIcon: const Icon(Icons.inbox_rounded),

                  label: 'Pedidos',

                ),

              ]

            : [

                const NavigationDestination(

                  icon: Icon(Icons.dashboard_outlined),

                  selectedIcon: Icon(Icons.dashboard_rounded),

                  label: 'Painel',

                ),

                const NavigationDestination(

                  icon: Icon(Icons.menu_book_outlined),

                  selectedIcon: Icon(Icons.menu_book_rounded),

                  label: 'Catálogo',

                ),

                const NavigationDestination(

                  icon: Icon(Icons.add_box_outlined),

                  selectedIcon: Icon(Icons.add_box_rounded),

                  label: 'Entrada',

                ),

                NavigationDestination(

                  icon: Badge(

                    isLabelVisible:

                        widget.service.notifAlmoxarife > 0,

                    label: Text(

                        widget.service.notifAlmoxarife.toString()),

                    child: const Icon(Icons.assignment_outlined),

                  ),

                  selectedIcon: const Icon(Icons.assignment_rounded),

                  label: 'Pedidos',

                ),

                NavigationDestination(

                  icon: Badge(

                    isLabelVisible:

                        widget.service.livrosBaixoEstoque.isNotEmpty,

                    label: Text(

                        widget.service.livrosBaixoEstoque.length.toString()),

                    child: const Icon(Icons.warning_amber_outlined),

                  ),

                  selectedIcon: const Icon(Icons.warning_amber_rounded),

                  label: 'Alertas',

                ),

                const NavigationDestination(

                  icon: Icon(Icons.bar_chart_outlined),

                  selectedIcon: Icon(Icons.bar_chart_rounded),

                  label: 'Relatórios',

                ),

                const NavigationDestination(

                  icon: Icon(Icons.manage_accounts_outlined),

                  selectedIcon: Icon(Icons.manage_accounts_rounded),

                  label: 'Usuários',

                ),

              ],

      ),

    );

  }



  void _mostrarDialogCadastroLivro(BuildContext context) {

    final tituloCtrl = TextEditingController();

    final isbnCtrl = TextEditingController();

    final materiaCtrl = TextEditingController();



    showDialog(

      context: context,

      builder: (ctx) {

        String? erro;

        return StatefulBuilder(

          builder: (ctx, setStateDialog) => AlertDialog(

            title: const Text('Cadastrar Livro'),

            content: SingleChildScrollView(

              child: Column(

                mainAxisSize: MainAxisSize.min,

                children: [

                  if (erro != null) ...[

                    Container(

                      padding: const EdgeInsets.all(10),

                      decoration: BoxDecoration(

                        color: const Color(0xFFFFEEEE),

                        borderRadius: BorderRadius.circular(8),

                        border: const Border.fromBorderSide(

                          BorderSide(color: Color(0xFFFFCCCC)),

                        ),

                      ),

                      child: Row(

                        children: [

                          const Icon(Icons.error_outline,

                              color: Color(0xFFE8000D), size: 16),

                          const SizedBox(width: 6),

                          Expanded(

                            child: Text(

                              erro!,

                              style: const TextStyle(

                                  color: Color(0xFFE8000D), fontSize: 12),

                            ),

                          ),

                        ],

                      ),

                    ),

                    const SizedBox(height: 12),

                  ],

                  TextField(

                    controller: tituloCtrl,

                    decoration: const InputDecoration(labelText: 'Título *'),

                    textInputAction: TextInputAction.next,

                  ),

                  const SizedBox(height: 12),

                  TextField(

                    controller: isbnCtrl,

                    decoration: const InputDecoration(labelText: 'ISBN *'),

                    textInputAction: TextInputAction.next,

                  ),

                  const SizedBox(height: 12),

                  TextField(

                    controller: materiaCtrl,

                    decoration: const InputDecoration(labelText: 'Matéria *'),

                  ),

                ],

              ),

            ),

            actions: [

              TextButton(

                onPressed: () => Navigator.pop(ctx),

                child: const Text('Cancelar'),

              ),

              ElevatedButton(

                onPressed: () {

                  final resultado = widget.service.cadastrarLivro(

                    titulo: tituloCtrl.text.trim(),

                    isbn: isbnCtrl.text.trim(),

                    materia: materiaCtrl.text.trim(),

                  );

                  if (resultado == 'ok') {

                    Navigator.pop(ctx);

                  } else {

                    setStateDialog(() => erro = resultado);

                  }

                },

                child: const Text('Cadastrar'),

              ),

            ],

          ),

        );

      },

    ).whenComplete(() {

      tituloCtrl.dispose();

      isbnCtrl.dispose();

      materiaCtrl.dispose();

    });

  }



  void _mostrarDialogCadastroUsuario(BuildContext context) {

    final loginCtrl = TextEditingController();

    final senhaCtrl = TextEditingController();



    showDialog(

      context: context,

      builder: (ctx) {

        String? erro;

        return StatefulBuilder(

          builder: (ctx, setStateDialog) => AlertDialog(

            title: const Text('Cadastrar Professor'),

            content: SingleChildScrollView(

              child: Column(

                mainAxisSize: MainAxisSize.min,

                children: [

                  if (erro != null) ...[

                    Container(

                      padding: const EdgeInsets.all(10),

                      decoration: BoxDecoration(

                        color: const Color(0xFFFFEEEE),

                        borderRadius: BorderRadius.circular(8),

                        border: const Border.fromBorderSide(

                          BorderSide(color: Color(0xFFFFCCCC)),

                        ),

                      ),

                      child: Row(

                        children: [

                          const Icon(Icons.error_outline,

                              color: Color(0xFFE8000D), size: 16),

                          const SizedBox(width: 6),

                          Expanded(

                            child: Text(

                              erro!,

                              style: const TextStyle(

                                  color: Color(0xFFE8000D), fontSize: 12),

                            ),

                          ),

                        ],

                      ),

                    ),

                    const SizedBox(height: 12),

                  ],

                  TextField(

                    controller: loginCtrl,

                    decoration: const InputDecoration(labelText: 'Usuário *'),

                    textInputAction: TextInputAction.next,

                  ),

                  const SizedBox(height: 12),

                  TextField(

                    controller: senhaCtrl,

                    decoration: const InputDecoration(labelText: 'Senha *'),

                    obscureText: true,

                  ),

                ],

              ),

            ),

            actions: [

              TextButton(

                onPressed: () => Navigator.pop(ctx),

                child: const Text('Cancelar'),

              ),

              ElevatedButton(

                onPressed: () {

                  final resultado = widget.service.cadastrarUsuario(

                    nome: 'Professor',

                    login: loginCtrl.text.trim(),

                    senha: senhaCtrl.text.trim(),

                    perfil: 'professor',

                  );

                  if (resultado == 'ok') {

                    Navigator.pop(ctx);

                  } else {

                    setStateDialog(() => erro = resultado);

                  }

                },

                child: const Text('Cadastrar'),

              ),

            ],

          ),

        );

      },

    ).whenComplete(() {

      loginCtrl.dispose();

      senhaCtrl.dispose();

    });

  }



  void _mostrarDialogEdicaoUsuario(BuildContext context, Usuario usuario) {

    final loginCtrl = TextEditingController(text: usuario.login);

    final senhaCtrl = TextEditingController(text: usuario.senha);

    String perfilSelecionado = usuario.perfil;

    bool senhaVisivel = false;



    showDialog(

      context: context,

      builder: (ctx) {

        String? erro;

        return StatefulBuilder(

          builder: (ctx, setStateDialog) => AlertDialog(

            title: const Text('Editar Usuário'),

            content: SingleChildScrollView(

              child: Column(

                mainAxisSize: MainAxisSize.min,

                children: [

                  if (erro != null) ...[

                    Container(

                      padding: const EdgeInsets.all(10),

                      decoration: BoxDecoration(

                        color: const Color(0xFFFFEEEE),

                        borderRadius: BorderRadius.circular(8),

                        border: const Border.fromBorderSide(

                          BorderSide(color: Color(0xFFFFCCCC)),

                        ),

                      ),

                      child: Row(

                        children: [

                          const Icon(Icons.error_outline,

                              color: Color(0xFFE8000D), size: 16),

                          const SizedBox(width: 6),

                          Expanded(

                            child: Text(

                              erro!,

                              style: const TextStyle(

                                  color: Color(0xFFE8000D), fontSize: 12),

                            ),

                          ),

                        ],

                      ),

                    ),

                    const SizedBox(height: 12),

                  ],

                  TextField(

                    controller: loginCtrl,

                    decoration: const InputDecoration(labelText: 'Usuário *'),

                    textInputAction: TextInputAction.next,

                  ),

                  const SizedBox(height: 12),

                  TextField(

                    controller: senhaCtrl,

                    obscureText: !senhaVisivel,

                    decoration: InputDecoration(

                      labelText: 'Senha *',

                      suffixIcon: IconButton(

                        icon: Icon(senhaVisivel

                            ? Icons.visibility_off_outlined

                            : Icons.visibility_outlined),

                        onPressed: () =>

                            setStateDialog(() => senhaVisivel = !senhaVisivel),

                      ),

                    ),

                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(

                    initialValue: perfilSelecionado,

                    decoration: const InputDecoration(labelText: 'Cargo *'),

                    items: const [

                      DropdownMenuItem(

                          value: 'almoxarife', child: Text('Almoxarife')),

                      DropdownMenuItem(

                          value: 'professor', child: Text('Professor')),

                    ],

                    onChanged: (v) {

                      if (v != null) {

                        setStateDialog(() => perfilSelecionado = v);

                      }

                    },

                  ),

                ],

              ),

            ),

            actions: [

              TextButton(

                onPressed: () => Navigator.pop(ctx),

                child: const Text('Cancelar'),

              ),

              ElevatedButton(

                onPressed: () {

                  final resultado = widget.service.editarUsuario(

                    id: usuario.id,

                    nome: usuario.nome,

                    login: loginCtrl.text.trim(),

                    senha: senhaCtrl.text.trim(),

                    perfil: perfilSelecionado,

                  );

                  if (resultado == 'ok') {

                    Navigator.pop(ctx);

                  } else {

                    setStateDialog(() => erro = resultado);

                  }

                },

                child: const Text('Salvar'),

              ),

            ],

          ),

        );

      },

    ).whenComplete(() {

      loginCtrl.dispose();

      senhaCtrl.dispose();

    });

  }



  void _confirmarLogout(BuildContext context) {

    showDialog(

      context: context,

      builder: (_) => AlertDialog(

        title: const Text('Sair do sistema'),

        content: const Text('Deseja encerrar a sessão?'),

        actions: [

          TextButton(

            onPressed: () => Navigator.pop(context),

            child: const Text('Cancelar'),

          ),

          ElevatedButton(

            onPressed: () {

              Navigator.pop(context);

              widget.service.logout();

            },

            child: const Text('Sair'),

          ),

        ],

      ),

    );

  }

}



// ─────────────────────────────────────────────

// DASHBOARD TAB

// ─────────────────────────────────────────────



class DashboardTab extends StatelessWidget {

  final StockService service;

  const DashboardTab({super.key, required this.service});



  @override

  Widget build(BuildContext context) {

    final isProfessor = service.usuarioLogado?.perfil == 'professor';

    if (isProfessor) return _buildDashboardProfessor(context);

    return _buildDashboardGeral(context);

  }



  Widget _buildDashboardGeral(BuildContext context) {

    final totalLivros = service.livros.length;

    final totalUnidades = service.livros.fold<int>(

      0,

      (sum, l) => sum + l.saldo,

    );

    final alertas = service.livrosBaixoEstoque.length;

    final zerados = service.livros.where((l) => l.saldo == 0).length;

    final movimentos = service.movimentacoes;



    final totalEntradas =

        movimentos.where((m) => m.tipo == 'entrada').length;

    final totalSaidas = movimentos.where((m) => m.tipo == 'saida').length;



    final Map<String, int> porMateria = {};

    for (final l in service.livros) {

      porMateria[l.materia] = (porMateria[l.materia] ?? 0) + l.saldo;

    }

    final maxMateria = porMateria.isEmpty

        ? 1

        : porMateria.values.reduce((a, b) => a > b ? a : b);



    final criticos = [...service.livrosBaixoEstoque]

      ..sort((a, b) => a.saldo.compareTo(b.saldo));



    return SingleChildScrollView(

      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          _WelcomeBanner(service: service, subtitulo: 'Resumo do estoque hoje'),

          const SizedBox(height: 12),

          GridView.count(

            crossAxisCount: 2,

            shrinkWrap: true,

            physics: const NeverScrollableScrollPhysics(),

            crossAxisSpacing: 8,

            mainAxisSpacing: 8,

            childAspectRatio: 2.6,

            children: [

              _StatCard(

                label: 'Títulos cadastrados',

                valor: '$totalLivros',

                icon: Icons.menu_book_rounded,

                cor: const Color(0xFFCC0020),

              ),

              _StatCard(

                label: 'Unidades em estoque',

                valor: '$totalUnidades',

                icon: Icons.layers_rounded,

                cor: const Color(0xFF16A34A),

              ),

              _StatCard(

                label: 'Alertas de estoque',

                valor: '$alertas',

                icon: Icons.warning_amber_rounded,

                cor: const Color(0xFFD97706),

              ),

              _StatCard(

                label: 'Títulos zerados',

                valor: '$zerados',

                icon: Icons.error_rounded,

                cor: const Color(0xFF7B2FBE),

              ),

            ],

          ),

          const SizedBox(height: 20),

          const _SectionTitle('Atividade de Movimentações'),

          const SizedBox(height: 8),

          Row(

            children: [

              Expanded(

                child: _ActivityTile(

                  label: 'Entradas',

                  valor: totalEntradas,

                  icon: Icons.arrow_downward_rounded,

                  cor: const Color(0xFF16A34A),

                ),

              ),

              const SizedBox(width: 8),

              Expanded(

                child: _ActivityTile(

                  label: 'Saídas',

                  valor: totalSaidas,

                  icon: Icons.arrow_upward_rounded,

                  cor: const Color(0xFFCC0020),

                ),

              ),

            ],

          ),

          const SizedBox(height: 20),

          const _SectionTitle('Estoque por Matéria'),

          const SizedBox(height: 10),

          ...porMateria.entries.map(

            (e) => _MateriaRow(

              materia: e.key,

              total: e.value,

              maxTotal: maxMateria,

            ),

          ),

          const SizedBox(height: 20),

          if (criticos.isNotEmpty) ...[

            const _SectionTitle('Requerem Atenção'),

            const SizedBox(height: 8),

            ...criticos.take(3).map((l) => _CriticoRow(livro: l)),

            const SizedBox(height: 20),

          ],

          const _SectionTitle('Últimas Movimentações'),

          const SizedBox(height: 8),

          if (movimentos.isEmpty)

            _EmptyState(

              icon: Icons.swap_horiz_rounded,

              mensagem: 'Nenhuma movimentação registrada ainda.',

            )

          else

            ...movimentos.take(5).map((m) => _MovItem(mov: m)),

        ],

      ),

    );

  }



  Widget _buildDashboardProfessor(BuildContext context) {

    final nomeProf = service.usuarioLogado!.nome;

    final disponiveis =

        service.livros.where((l) => l.saldo > 0).toList();

    final indisponiveis =

        service.livros.where((l) => l.saldo == 0).toList();

    final minhasRetiradas = service.movimentacoes

        .where((m) => m.tipo == 'saida' && m.usuarioNome == nomeProf)

        .toList();



    final Map<String, int> porMateria = {};

    for (final l in disponiveis) {

      porMateria[l.materia] = (porMateria[l.materia] ?? 0) + l.saldo;

    }

    final maxMateria = porMateria.isEmpty

        ? 1

        : porMateria.values.reduce((a, b) => a > b ? a : b);



    return SingleChildScrollView(

      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          _WelcomeBanner(

            service: service,

            subtitulo: 'Acervo disponível para retirada',

          ),

          const SizedBox(height: 12),

          GridView.count(

            crossAxisCount: 2,

            shrinkWrap: true,

            physics: const NeverScrollableScrollPhysics(),

            crossAxisSpacing: 8,

            mainAxisSpacing: 8,

            childAspectRatio: 2.6,

            children: [

              _StatCard(

                label: 'Títulos disponíveis',

                valor: '${disponiveis.length}',

                icon: Icons.check_circle_rounded,

                cor: const Color(0xFF16A34A),

              ),

              _StatCard(

                label: 'Títulos indisponíveis',

                valor: '${indisponiveis.length}',

                icon: Icons.cancel_rounded,

                cor: const Color(0xFFCC0020),

              ),

              _StatCard(

                label: 'Minhas retiradas',

                valor: '${minhasRetiradas.length}',

                icon: Icons.school_rounded,

                cor: const Color(0xFF003087),

              ),

              _StatCard(

                label: 'Com estoque baixo',

                valor: '${service.livrosBaixoEstoque.length}',

                icon: Icons.warning_amber_rounded,

                cor: const Color(0xFFD97706),

              ),

            ],

          ),

          const SizedBox(height: 20),

          const _SectionTitle('Disponibilidade por Matéria'),

          const SizedBox(height: 10),

          if (porMateria.isEmpty)

            const Padding(

              padding: EdgeInsets.only(bottom: 12),

              child: Text(

                'Nenhum livro disponível no momento.',

                style: TextStyle(color: Color(0xFF9AA5BE), fontSize: 13),

              ),

            )

          else

            ...porMateria.entries.map(

              (e) => _MateriaRow(

                materia: e.key,

                total: e.value,

                maxTotal: maxMateria,

              ),

            ),

          const SizedBox(height: 20),

          if (indisponiveis.isNotEmpty) ...[

            const _SectionTitle('Indisponíveis no Momento'),

            const SizedBox(height: 8),

            ...indisponiveis.map(

              (l) => Padding(

                padding: const EdgeInsets.only(bottom: 6),

                child: Container(

                  padding: const EdgeInsets.symmetric(

                      horizontal: 12, vertical: 10),

                  decoration: BoxDecoration(

                    color: const Color(0xFFCC0020).withValues(alpha: 0.05),

                    borderRadius: BorderRadius.circular(10),

                    border: Border.all(

                        color:

                            const Color(0xFFCC0020).withValues(alpha: 0.2)),

                  ),

                  child: Row(

                    children: [

                      const Icon(Icons.cancel_rounded,

                          color: Color(0xFFCC0020), size: 16),

                      const SizedBox(width: 10),

                      Expanded(

                        child: Text(

                          l.titulo,

                          style: const TextStyle(

                            fontSize: 12,

                            fontWeight: FontWeight.w600,

                            color: Color(0xFF1A0A0A),

                          ),

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                        ),

                      ),

                      _Tag(l.materia, const Color(0xFFCC0020)),

                    ],

                  ),

                ),

              ),

            ),

            const SizedBox(height: 20),

          ],

          const _SectionTitle('Minhas Últimas Retiradas'),

          const SizedBox(height: 8),

          if (minhasRetiradas.isEmpty)

            _EmptyState(

              icon: Icons.school_rounded,

              mensagem: 'Você ainda não registrou retiradas.',

            )

          else

            ...minhasRetiradas.take(5).map((m) => _MovItem(mov: m)),

        ],

      ),

    );

  }

}



class _StatCard extends StatelessWidget {

  final String label;

  final String valor;

  final IconData icon;

  final Color cor;



  const _StatCard({

    required this.label,

    required this.valor,

    required this.icon,

    required this.cor,

  });



  @override

  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: const Color(0xFFEDE4E4)),

        boxShadow: [

          BoxShadow(

            color: cor.withValues(alpha: 0.07),

            blurRadius: 8,

            offset: const Offset(0, 3),

          ),

        ],

      ),

      child: Row(

        children: [

          Container(

            padding: const EdgeInsets.all(7),

            decoration: BoxDecoration(

              color: cor.withValues(alpha: 0.12),

              borderRadius: BorderRadius.circular(8),

            ),

            child: Icon(icon, color: cor, size: 17),

          ),

          const SizedBox(width: 10),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                Text(

                  valor,

                  style: TextStyle(

                    fontSize: 20,

                    fontWeight: FontWeight.w900,

                    color: cor,

                    height: 1.1,

                  ),

                ),

                Text(

                  label,

                  style: const TextStyle(

                    fontSize: 10,

                    color: Color(0xFF8C7070),

                    fontWeight: FontWeight.w500,

                  ),

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

}



class _WelcomeBanner extends StatelessWidget {

  final StockService service;

  final String subtitulo;

  const _WelcomeBanner({required this.service, required this.subtitulo});



  @override

  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),

      decoration: BoxDecoration(

        gradient: const LinearGradient(

          colors: [Color(0xFFCC0020), Color(0xFF6B0011)],

          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

        ),

        borderRadius: BorderRadius.circular(14),

        boxShadow: const [

          BoxShadow(

            color: Color(0x33CC0020),

            blurRadius: 12,

            offset: Offset(0, 4),

          ),

        ],

      ),

      child: Row(

        children: [

          Container(

            padding: const EdgeInsets.all(8),

            decoration: BoxDecoration(

              color: Colors.white.withValues(alpha: 0.18),

              borderRadius: BorderRadius.circular(9),

            ),

            child: const Icon(Icons.waving_hand_rounded,

                color: Colors.amber, size: 18),

          ),

          const SizedBox(width: 12),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  'Olá, ${service.usuarioLogado!.nome.split(' ').first}!',

                  style: const TextStyle(

                    color: Colors.white,

                    fontWeight: FontWeight.w700,

                    fontSize: 14,

                  ),

                ),

                const SizedBox(height: 1),

                Text(

                  subtitulo,

                  style: const TextStyle(

                      color: Colors.white70, fontSize: 11, height: 1.3),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

}



class _SectionTitle extends StatelessWidget {

  final String title;

  const _SectionTitle(this.title);



  @override

  Widget build(BuildContext context) {

    return Row(

      children: [

        Container(

          width: 3,

          height: 15,

          decoration: BoxDecoration(

            color: const Color(0xFFCC0020),

            borderRadius: BorderRadius.circular(2),

          ),

        ),

        const SizedBox(width: 8),

        Text(

          title,

          style: const TextStyle(

            fontWeight: FontWeight.w700,

            fontSize: 13,

            color: Color(0xFF1A0A0A),

          ),

        ),

      ],

    );

  }

}



class _ActivityTile extends StatelessWidget {

  final String label;

  final int valor;

  final IconData icon;

  final Color cor;



  const _ActivityTile({

    required this.label,

    required this.valor,

    required this.icon,

    required this.cor,

  });



  @override

  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: const Color(0xFFEDE4E4)),

        boxShadow: [

          BoxShadow(

            color: cor.withValues(alpha: 0.07),

            blurRadius: 8,

            offset: const Offset(0, 3),

          ),

        ],

      ),

      child: Row(

        children: [

          Container(

            padding: const EdgeInsets.all(7),

            decoration: BoxDecoration(

              color: cor.withValues(alpha: 0.12),

              borderRadius: BorderRadius.circular(8),

            ),

            child: Icon(icon, color: cor, size: 16),

          ),

          const SizedBox(width: 10),

          Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(

                '$valor',

                style: TextStyle(

                  fontSize: 18,

                  fontWeight: FontWeight.w900,

                  color: cor,

                  height: 1.1,

                ),

              ),

              Text(

                label,

                style: const TextStyle(

                  fontSize: 10,

                  color: Color(0xFF8C7070),

                  fontWeight: FontWeight.w500,

                ),

              ),

            ],

          ),

        ],

      ),

    );

  }

}



class _MateriaRow extends StatelessWidget {

  final String materia;

  final int total;

  final int maxTotal;



  const _MateriaRow({

    required this.materia,

    required this.total,

    required this.maxTotal,

  });



  @override

  Widget build(BuildContext context) {

    final ratio = maxTotal > 0 ? total / maxTotal : 0.0;

    return Padding(

      padding: const EdgeInsets.only(bottom: 8),

      child: Row(

        children: [

          SizedBox(

            width: 90,

            child: Text(

              materia,

              style: const TextStyle(

                fontSize: 12,

                fontWeight: FontWeight.w600,

                color: Color(0xFF1A0A0A),

              ),

              overflow: TextOverflow.ellipsis,

            ),

          ),

          const SizedBox(width: 10),

          Expanded(

            child: ClipRRect(

              borderRadius: BorderRadius.circular(4),

              child: LinearProgressIndicator(

                value: ratio,

                backgroundColor: const Color(0xFFEDE4E4),

                color: const Color(0xFFCC0020),

                minHeight: 6,

              ),

            ),

          ),

          const SizedBox(width: 10),

          SizedBox(

            width: 46,

            child: Text(

              '$total un.',

              style: const TextStyle(

                fontSize: 11,

                fontWeight: FontWeight.w700,

                color: Color(0xFF1A0A0A),

              ),

              textAlign: TextAlign.right,

            ),

          ),

        ],

      ),

    );

  }

}



class _CriticoRow extends StatelessWidget {

  final Livro livro;

  const _CriticoRow({required this.livro});



  @override

  Widget build(BuildContext context) {

    final zerado = livro.saldo == 0;

    final cor = zerado ? const Color(0xFFCC0020) : const Color(0xFFD97706);



    return Padding(

      padding: const EdgeInsets.only(bottom: 6),

      child: Container(

        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

        decoration: BoxDecoration(

          color: cor.withValues(alpha: 0.05),

          borderRadius: BorderRadius.circular(10),

          border: Border.all(color: cor.withValues(alpha: 0.25)),

        ),

        child: Row(

          children: [

            Icon(

              zerado ? Icons.error_rounded : Icons.warning_amber_rounded,

              color: cor,

              size: 16,

            ),

            const SizedBox(width: 10),

            Expanded(

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(

                    livro.titulo,

                    style: const TextStyle(

                      fontSize: 12,

                      fontWeight: FontWeight.w600,

                      color: Color(0xFF1A0A0A),

                    ),

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                  ),

                  Text(

                    livro.materia,

                    style: const TextStyle(

                      fontSize: 10,

                      color: Color(0xFF8C7070),

                    ),

                  ),

                ],

              ),

            ),

            const SizedBox(width: 8),

            Container(

              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),

              decoration: BoxDecoration(

                color: cor,

                borderRadius: BorderRadius.circular(6),

              ),

              child: Text(

                zerado ? 'Zerado' : '${livro.saldo} un.',

                style: const TextStyle(

                  color: Colors.white,

                  fontSize: 10,

                  fontWeight: FontWeight.w700,

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}



class _MovItem extends StatelessWidget {

  final Movimentacao mov;

  const _MovItem({required this.mov});



  @override

  Widget build(BuildContext context) {

    final entrada = mov.tipo == 'entrada';

    final cor =

        entrada ? const Color(0xFF16A34A) : const Color(0xFFCC0020);

    return Padding(

      padding: const EdgeInsets.only(bottom: 8),

      child: Container(

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius: BorderRadius.circular(12),

          border: Border.all(color: const Color(0xFFEDE4E4)),

        ),

        child: Padding(

          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

          child: Row(

            children: [

              Container(

                width: 38,

                height: 38,

                decoration: BoxDecoration(

                  color: cor.withValues(alpha: 0.1),

                  borderRadius: BorderRadius.circular(10),

                ),

                child: Icon(

                  entrada

                      ? Icons.arrow_downward_rounded

                      : Icons.arrow_upward_rounded,

                  color: cor,

                  size: 18,

                ),

              ),

              const SizedBox(width: 12),

              Expanded(

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(

                      mov.livroTitulo,

                      style: const TextStyle(

                          fontSize: 13, fontWeight: FontWeight.w600,

                          color: Color(0xFF1A0A0A)),

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                    ),

                    const SizedBox(height: 2),

                    Text(

                      '${mov.usuarioNome} · ${_formatarData(mov.data)}',

                      style: const TextStyle(

                          fontSize: 11, color: Color(0xFF8C7070)),

                    ),

                  ],

                ),

              ),

              const SizedBox(width: 8),

              Container(

                padding:

                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),

                decoration: BoxDecoration(

                  color: cor.withValues(alpha: 0.1),

                  borderRadius: BorderRadius.circular(20),

                ),

                child: Text(

                  '${entrada ? '+' : '-'}${mov.quantidade}',

                  style: TextStyle(

                    fontWeight: FontWeight.w800,

                    fontSize: 13,

                    color: cor,

                  ),

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }



  String _formatarData(DateTime d) {

    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  }

}



// ─────────────────────────────────────────────

// CATÁLOGO TAB

// ─────────────────────────────────────────────



class CatalogoTab extends StatefulWidget {

  final StockService service;

  const CatalogoTab({super.key, required this.service});



  @override

  State<CatalogoTab> createState() => _CatalogoTabState();

}



class _CatalogoTabState extends State<CatalogoTab> {

  String _busca = '';

  String _filtroEstoque = 'todos';

  String _filtroMateria = 'todas';



  @override

  Widget build(BuildContext context) {

    final materias = widget.service.livros

        .map((l) => l.materia)

        .toSet()

        .toList()

      ..sort();

    final livros = widget.service.livros.where((l) {

      final q = _busca.toLowerCase();

      final textoOk = q.isEmpty ||

          l.titulo.toLowerCase().contains(q) ||

          l.materia.toLowerCase().contains(q) ||

          l.isbn.contains(q);

      final estoqueOk = _filtroEstoque == 'todos' ||

          (_filtroEstoque == 'zerado' && l.estoqueCritico) ||

          (_filtroEstoque == 'baixo' &&

              l.estoqueAbaixoMinimo &&

              !l.estoqueCritico) ||

          (_filtroEstoque == 'normal' && !l.estoqueAbaixoMinimo);

      final materiaOk =

          _filtroMateria == 'todas' || l.materia == _filtroMateria;

      return textoOk && estoqueOk && materiaOk;

    }).toList();



    return Column(

      children: [

        Padding(

          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),

          child: TextField(

            decoration: const InputDecoration(

              labelText: 'Buscar título, matéria ou ISBN...',

              prefixIcon: Icon(Icons.search, size: 20),

            ),

            onChanged: (v) => setState(() => _busca = v),

          ),

        ),

        SingleChildScrollView(

          scrollDirection: Axis.horizontal,

          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),

          child: Row(

            children: [

              _FiltroChip(

                label: 'Todos',

                selecionado: _filtroEstoque == 'todos',

                onTap: () => setState(() => _filtroEstoque = 'todos'),

              ),

              const SizedBox(width: 8),

              _FiltroChip(

                label: 'Normal',

                selecionado: _filtroEstoque == 'normal',

                cor: const Color(0xFF16A34A),

                onTap: () => setState(() => _filtroEstoque = 'normal'),

              ),

              const SizedBox(width: 8),

              _FiltroChip(

                label: 'Baixo',

                selecionado: _filtroEstoque == 'baixo',

                cor: const Color(0xFFD97706),

                onTap: () => setState(() => _filtroEstoque = 'baixo'),

              ),

              const SizedBox(width: 8),

              _FiltroChip(

                label: 'Zerado',

                selecionado: _filtroEstoque == 'zerado',

                cor: const Color(0xFFCC0020),

                onTap: () => setState(() => _filtroEstoque = 'zerado'),

              ),

            ],

          ),

        ),

        if (materias.isNotEmpty)

          SingleChildScrollView(

            scrollDirection: Axis.horizontal,

            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),

            child: Row(

              children: [

                _FiltroChip(

                  label: 'Todas as matérias',

                  selecionado: _filtroMateria == 'todas',

                  cor: const Color(0xFF003087),

                  onTap: () => setState(() => _filtroMateria = 'todas'),

                ),

                ...materias.map(

                  (m) => Padding(

                    padding: const EdgeInsets.only(left: 8),

                    child: _FiltroChip(

                      label: m,

                      selecionado: _filtroMateria == m,

                      cor: const Color(0xFF003087),

                      onTap: () => setState(() => _filtroMateria = m),

                    ),

                  ),

                ),

              ],

            ),

          ),

        Expanded(

          child: livros.isEmpty

              ? const _EmptyState(

                  icon: Icons.search_off,

                  mensagem: 'Nenhum livro encontrado.',

                )

              : ListView.builder(

                  padding: const EdgeInsets.symmetric(

                    horizontal: 16,

                    vertical: 4,

                  ),

                  itemCount: livros.length,

                  itemBuilder: (_, i) => _LivroCard(livro: livros[i]),

                ),

        ),

      ],

    );

  }

}



class _LivroCard extends StatelessWidget {

  final Livro livro;

  const _LivroCard({required this.livro});



  @override

  Widget build(BuildContext context) {

    Color saldoCor;

    String saldoLabel;

    if (livro.saldo == 0) {

      saldoCor = const Color(0xFFE8000D);

      saldoLabel = 'Zerado';

    } else if (livro.estoqueAbaixoMinimo) {

      saldoCor = const Color(0xFFD97706);

      saldoLabel = 'Baixo';

    } else {

      saldoCor = const Color(0xFF0B7D3E);

      saldoLabel = 'Normal';

    }



    return Padding(

      padding: const EdgeInsets.only(bottom: 10),

      child: Container(

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius: BorderRadius.circular(14),

          border: Border.all(color: const Color(0xFFEDE4E4)),

          boxShadow: const [

            BoxShadow(

              color: Color(0x0A000000),

              blurRadius: 8,

              offset: Offset(0, 2),

            ),

          ],

        ),

        child: ClipRRect(

          borderRadius: BorderRadius.circular(14),

          child: Row(

            children: [

              Container(

                width: 5,

                height: 80,

                color: saldoCor,

              ),

              const SizedBox(width: 12),

              Container(

                width: 42,

                height: 50,

                decoration: BoxDecoration(

                  color: const Color(0xFFCC0020).withValues(alpha: 0.08),

                  borderRadius: BorderRadius.circular(10),

                ),

                child: const Icon(

                  Icons.menu_book_rounded,

                  color: Color(0xFFCC0020),

                  size: 22,

                ),

              ),

              const SizedBox(width: 12),

              Expanded(

                child: Padding(

                  padding: const EdgeInsets.symmetric(vertical: 14),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(

                        livro.titulo,

                        style: const TextStyle(

                          fontWeight: FontWeight.w700,

                          fontSize: 13,

                          color: Color(0xFF1A0A0A),

                        ),

                        maxLines: 2,

                        overflow: TextOverflow.ellipsis,

                      ),

                      const SizedBox(height: 5),

                      Row(

                        children: [

                          _Tag(livro.materia, const Color(0xFFCC0020)),

                          const SizedBox(width: 6),

                          Flexible(

                            child: Text(

                              livro.isbn,

                              style: const TextStyle(

                                fontSize: 10,

                                color: Color(0xFFBBA0A0),

                              ),

                              overflow: TextOverflow.ellipsis,

                            ),

                          ),

                        ],

                      ),

                    ],

                  ),

                ),

              ),

              Padding(

                padding: const EdgeInsets.only(right: 14),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.end,

                  children: [

                    Text(

                      '${livro.saldo}',

                      style: TextStyle(

                        fontSize: 22,

                        fontWeight: FontWeight.w900,

                        color: saldoCor,

                      ),

                    ),

                    Container(

                      padding: const EdgeInsets.symmetric(

                          horizontal: 7, vertical: 2),

                      decoration: BoxDecoration(

                        color: saldoCor,

                        borderRadius: BorderRadius.circular(6),

                      ),

                      child: Text(

                        saldoLabel,

                        style: const TextStyle(

                          fontSize: 9,

                          fontWeight: FontWeight.w800,

                          color: Colors.white,

                          letterSpacing: 0.3,

                        ),

                      ),

                    ),

                  ],

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

}



class _Tag extends StatelessWidget {

  final String texto;

  final Color cor;

  const _Tag(this.texto, this.cor);



  @override

  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),

      decoration: BoxDecoration(

        color: cor.withValues(alpha: 0.1),

        borderRadius: BorderRadius.circular(4),

      ),

      child: Text(

        texto,

        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: cor),

      ),

    );

  }

}



// ─────────────────────────────────────────────

// MOVIMENTAÇÃO TAB (Entrada e Saída)

// ─────────────────────────────────────────────



class MovimentacaoTab extends StatefulWidget {

  final StockService service;

  final String tipo; // 'entrada' | 'saida'



  const MovimentacaoTab({super.key, required this.service, required this.tipo});



  @override

  State<MovimentacaoTab> createState() => _MovimentacaoTabState();

}



class _MovimentacaoTabState extends State<MovimentacaoTab> {

  Livro? _livroSelecionado;

  final _qtdCtrl = TextEditingController();

  final _obsCtrl = TextEditingController();

  String? _erro;

  bool _sucesso = false;



  bool get entrada => widget.tipo == 'entrada';



  @override

  void dispose() {

    _qtdCtrl.dispose();

    _obsCtrl.dispose();

    super.dispose();

  }



  void _confirmar() {

    setState(() {

      _erro = null;

      _sucesso = false;

    });



    if (_livroSelecionado == null) {

      setState(() => _erro = 'Selecione um livro.');

      return;

    }

    final qtd = int.tryParse(_qtdCtrl.text.trim());

    if (qtd == null || qtd <= 0) {

      setState(() => _erro = 'Informe uma quantidade válida.');

      return;

    }



    String resultado;

    if (entrada) {

      resultado = widget.service.registrarEntrada(

        livroId: _livroSelecionado!.id,

        quantidade: qtd,

        observacao: _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),

      );

    } else {

      resultado = widget.service.registrarSaida(

        livroId: _livroSelecionado!.id,

        quantidade: qtd,

        observacao: _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),

      );

    }



    if (resultado == 'ok') {

      setState(() {

        _sucesso = true;

        _livroSelecionado = null;

        _qtdCtrl.clear();

        _obsCtrl.clear();

      });

    } else {

      setState(() => _erro = resultado);

    }

  }



  @override

  Widget build(BuildContext context) {

    final cor = entrada ? const Color(0xFF16A34A) : const Color(0xFFCC0020);

    final corDark = entrada ? const Color(0xFF0A5C2A) : const Color(0xFF8B0000);

    final icone = entrada ? Icons.add_box_rounded : Icons.remove_circle_rounded;

    final titulo = entrada ? 'Entrada de Estoque' : 'Saída de Estoque';

    final desc = entrada

        ? 'Registre a chegada de livros da editora.'

        : 'Registre a retirada de livros para as turmas.';



    return SingleChildScrollView(

      padding: const EdgeInsets.all(16),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Container(

            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(

              gradient: LinearGradient(

                colors: [cor, corDark],

                begin: Alignment.centerLeft,

                end: Alignment.centerRight,

              ),

              borderRadius: BorderRadius.circular(16),

              boxShadow: [

                BoxShadow(

                  color: cor.withValues(alpha: 0.35),

                  blurRadius: 12,

                  offset: const Offset(0, 5),

                ),

              ],

            ),

            child: Row(

              children: [

                Container(

                  padding: const EdgeInsets.all(10),

                  decoration: BoxDecoration(

                    color: Colors.white.withValues(alpha: 0.2),

                    borderRadius: BorderRadius.circular(12),

                  ),

                  child: Icon(icone, color: Colors.white, size: 24),

                ),

                const SizedBox(width: 14),

                Expanded(

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(

                        titulo,

                        style: const TextStyle(

                          color: Colors.white,

                          fontWeight: FontWeight.w800,

                          fontSize: 16,

                        ),

                      ),

                      Text(

                        desc,

                        style: TextStyle(

                          color: Colors.white.withValues(alpha: 0.8),

                          fontSize: 12,

                        ),

                      ),

                    ],

                  ),

                ),

              ],

            ),

          ),

          const SizedBox(height: 20),

          const Text(

            'Livro *',

            style: TextStyle(

              fontWeight: FontWeight.w600,

              fontSize: 13,

              color: Color(0xFF1A2340),

            ),

          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<Livro>(

            key: ValueKey(_livroSelecionado?.id ?? ''),

            initialValue: _livroSelecionado,

            hint: const Text('Selecione o título'),

            decoration: const InputDecoration(),

            items: widget.service.livros

                .map(

                  (l) => DropdownMenuItem(

                    value: l,

                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,

                      mainAxisSize: MainAxisSize.min,

                      children: [

                        Text(

                          l.titulo,

                          style: const TextStyle(

                            fontSize: 13,

                            fontWeight: FontWeight.w500,

                          ),

                          overflow: TextOverflow.ellipsis,

                        ),

                        Text(

                          'Saldo: ${l.saldo} un.',

                          style: const TextStyle(

                            fontSize: 11,

                            color: Color(0xFF9AA5BE),

                          ),

                        ),

                      ],

                    ),

                  ),

                )

                .toList(),

            onChanged: (v) => setState(() {

              _livroSelecionado = v;

              _erro = null;

              _sucesso = false;

            }),

          ),

          if (_livroSelecionado != null) ...[

            const SizedBox(height: 10),

            Container(

              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

              decoration: BoxDecoration(

                color: const Color(0xFFF0F4FF),

                borderRadius: BorderRadius.circular(8),

              ),

              child: Row(

                children: [

                  const Icon(

                    Icons.layers_rounded,

                    size: 16,

                    color: Color(0xFF003087),

                  ),

                  const SizedBox(width: 8),

                  Text(

                    'Saldo atual: ',

                    style: const TextStyle(

                      fontSize: 13,

                      color: Color(0xFF6B7A99),

                    ),

                  ),

                  Text(

                    '${_livroSelecionado!.saldo} unidades',

                    style: const TextStyle(

                      fontSize: 13,

                      fontWeight: FontWeight.w700,

                      color: Color(0xFF003087),

                    ),

                  ),

                ],

              ),

            ),

          ],



          const SizedBox(height: 16),

          const Text(

            'Quantidade *',

            style: TextStyle(

              fontWeight: FontWeight.w600,

              fontSize: 13,

              color: Color(0xFF1A2340),

            ),

          ),

          const SizedBox(height: 8),

          TextField(

            controller: _qtdCtrl,

            keyboardType: TextInputType.number,

            inputFormatters: [FilteringTextInputFormatter.digitsOnly],

            decoration: InputDecoration(

              labelText: 'Ex: 30',

              prefixIcon: Icon(

                entrada ? Icons.add : Icons.remove,

                size: 20,

                color: cor,

              ),

            ),

          ),

          const SizedBox(height: 16),

          const Text(

            'Observação (opcional)',

            style: TextStyle(

              fontWeight: FontWeight.w600,

              fontSize: 13,

              color: Color(0xFF1A2340),

            ),

          ),

          const SizedBox(height: 8),

          TextField(

            controller: _obsCtrl,

            decoration: InputDecoration(

              labelText: entrada

                  ? 'Ex: Caixas recebidas da Editora Senai'

                  : 'Ex: Turma A – Sala 201',

              prefixIcon: const Icon(Icons.notes_rounded, size: 20),

            ),

            maxLines: 2,

          ),

          const SizedBox(height: 8),



          if (_erro != null) ...[

            const SizedBox(height: 4),

            Container(

              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(

                color: const Color(0xFFFFEEEE),

                borderRadius: BorderRadius.circular(8),

                border: const Border.fromBorderSide(

                  BorderSide(color: Color(0xFFFFCCCC)),

                ),

              ),

              child: Row(

                children: [

                  const Icon(

                    Icons.error_outline,

                    color: Color(0xFFE8000D),

                    size: 18,

                  ),

                  const SizedBox(width: 8),

                  Expanded(

                    child: Text(

                      _erro!,

                      style: const TextStyle(

                        color: Color(0xFFE8000D),

                        fontSize: 13,

                      ),

                    ),

                  ),

                ],

              ),

            ),

          ],



          if (_sucesso) ...[

            const SizedBox(height: 4),

            Container(

              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(

                color: const Color(0xFFE6F4EE),

                borderRadius: BorderRadius.circular(8),

                border: const Border.fromBorderSide(

                  BorderSide(color: Color(0xFFB2DFC8)),

                ),

              ),

              child: Row(

                children: [

                  const Icon(

                    Icons.check_circle_outline,

                    color: Color(0xFF0B7D3E),

                    size: 18,

                  ),

                  const SizedBox(width: 8),

                  Text(

                    entrada

                        ? 'Entrada registrada com sucesso!'

                        : 'Saída registrada com sucesso!',

                    style: const TextStyle(

                      color: Color(0xFF0B7D3E),

                      fontSize: 13,

                    ),

                  ),

                ],

              ),

            ),

          ],



          const SizedBox(height: 20),

          SizedBox(

            width: double.infinity,

            child: ElevatedButton.icon(

              style: ElevatedButton.styleFrom(backgroundColor: cor),

              icon: Icon(icone, size: 18),

              label: Text(entrada ? 'Registrar Entrada' : 'Registrar Saída'),

              onPressed: _confirmar,

            ),

          ),

        ],

      ),

    );

  }

}



// ─────────────────────────────────────────────

// MONITORAMENTO TAB

// ─────────────────────────────────────────────



class MonitoramentoTab extends StatelessWidget {

  final StockService service;

  const MonitoramentoTab({super.key, required this.service});



  @override

  Widget build(BuildContext context) {

    final alertas = service.livrosBaixoEstoque;



    return Column(

      children: [

        Container(

          margin: const EdgeInsets.all(16),

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(

            gradient: alertas.isEmpty

                ? const LinearGradient(

                    colors: [Color(0xFF16A34A), Color(0xFF0A5C2A)],

                    begin: Alignment.centerLeft,

                    end: Alignment.centerRight,

                  )

                : const LinearGradient(

                    colors: [Color(0xFFD97706), Color(0xFF92400E)],

                    begin: Alignment.centerLeft,

                    end: Alignment.centerRight,

                  ),

            borderRadius: BorderRadius.circular(16),

            boxShadow: [

              BoxShadow(

                color: (alertas.isEmpty

                        ? const Color(0xFF16A34A)

                        : const Color(0xFFD97706))

                    .withValues(alpha: 0.3),

                blurRadius: 12,

                offset: const Offset(0, 4),

              ),

            ],

          ),

          child: Row(

            children: [

              Container(

                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(

                  color: Colors.white.withValues(alpha: 0.2),

                  borderRadius: BorderRadius.circular(12),

                ),

                child: Icon(

                  alertas.isEmpty

                      ? Icons.check_circle_rounded

                      : Icons.warning_amber_rounded,

                  color: Colors.white,

                  size: 24,

                ),

              ),

              const SizedBox(width: 14),

              Expanded(

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(

                      alertas.isEmpty

                          ? 'Estoque em dia!'

                          : '${alertas.length} título(s) precisam de reposição',

                      style: const TextStyle(

                        fontWeight: FontWeight.w800,

                        fontSize: 15,

                        color: Colors.white,

                      ),

                    ),

                    const SizedBox(height: 2),

                    Text(

                      'Nível mínimo: ${Livro.nivelMinimo} unidades por título',

                      style: TextStyle(

                        fontSize: 12,

                        color: Colors.white.withValues(alpha: 0.8),

                      ),

                    ),

                  ],

                ),

              ),

            ],

          ),

        ),

        Expanded(

          child: alertas.isEmpty

              ? _EmptyState(

                  icon: Icons.inventory_2_rounded,

                  mensagem: 'Nenhum título abaixo do nível mínimo.',

                )

              : ListView.builder(

                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

                  itemCount: alertas.length,

                  itemBuilder: (_, i) => _AlertaCard(livro: alertas[i]),

                ),

        ),

      ],

    );

  }

}



class _AlertaCard extends StatelessWidget {

  final Livro livro;

  const _AlertaCard({required this.livro});



  @override

  Widget build(BuildContext context) {

    final zerado = livro.saldo == 0;

    final cor = zerado ? const Color(0xFFCC0020) : const Color(0xFFD97706);

    final label = zerado ? 'ZERADO' : 'CRÍTICO';



    return Padding(

      padding: const EdgeInsets.only(bottom: 10),

      child: Container(

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius: BorderRadius.circular(14),

          border: Border.all(color: cor.withValues(alpha: 0.3)),

          boxShadow: [

            BoxShadow(

              color: cor.withValues(alpha: 0.08),

              blurRadius: 10,

              offset: const Offset(0, 3),

            ),

          ],

        ),

        child: ClipRRect(

          borderRadius: BorderRadius.circular(14),

          child: Row(

            children: [

              Container(width: 5, height: 70, color: cor),

              Expanded(

                child: Padding(

                  padding: const EdgeInsets.all(14),

                  child: Row(

                    children: [

                      Container(

                        padding: const EdgeInsets.all(10),

                        decoration: BoxDecoration(

                          color: cor.withValues(alpha: 0.1),

                          borderRadius: BorderRadius.circular(10),

                        ),

                        child: Icon(

                          zerado

                              ? Icons.error_rounded

                              : Icons.warning_amber_rounded,

                          color: cor,

                          size: 22,

                        ),

                      ),

                      const SizedBox(width: 12),

                      Expanded(

                        child: Column(

                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            Text(

                              livro.titulo,

                              style: const TextStyle(

                                fontWeight: FontWeight.w700,

                                fontSize: 13,

                                color: Color(0xFF1A0A0A),

                              ),

                              maxLines: 2,

                              overflow: TextOverflow.ellipsis,

                            ),

                            const SizedBox(height: 4),

                            Row(

                              children: [

                                _Tag(livro.materia, const Color(0xFFCC0020)),

                                const SizedBox(width: 6),

                                Text(

                                  'Saldo: ${livro.saldo} · Mín: ${Livro.nivelMinimo}',

                                  style: const TextStyle(

                                    fontSize: 11,

                                    color: Color(0xFFBBA0A0),

                                  ),

                                ),

                              ],

                            ),

                          ],

                        ),

                      ),

                      const SizedBox(width: 8),

                      Container(

                        padding: const EdgeInsets.symmetric(

                            horizontal: 8, vertical: 4),

                        decoration: BoxDecoration(

                          color: cor,

                          borderRadius: BorderRadius.circular(8),

                        ),

                        child: Text(

                          label,

                          style: const TextStyle(

                            color: Colors.white,

                            fontSize: 10,

                            fontWeight: FontWeight.w800,

                            letterSpacing: 0.5,

                          ),

                        ),

                      ),

                    ],

                  ),

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

}



// ─────────────────────────────────────────────

// USUÁRIOS TAB

// ─────────────────────────────────────────────



class UsuariosTab extends StatefulWidget {

  final StockService service;

  final void Function(Usuario) onEditar;

  const UsuariosTab({super.key, required this.service, required this.onEditar});



  @override

  State<UsuariosTab> createState() => _UsuariosTabState();

}



class _UsuariosTabState extends State<UsuariosTab> {

  static const Map<String, Color> _perfilCor = {

    'almoxarife': Color(0xFF0B7D3E),

    'professor': Color(0xFFCC6600),

  };

  String _busca = '';

  String _filtroPerfil = 'todos';



  @override

  Widget build(BuildContext context) {

    final usuarios = widget.service.usuarios.where((u) {

      final q = _busca.toLowerCase();

      final textoOk = q.isEmpty ||

          u.nome.toLowerCase().contains(q) ||

          u.login.toLowerCase().contains(q);

      final perfilOk =

          _filtroPerfil == 'todos' || u.perfil == _filtroPerfil;

      return textoOk && perfilOk;

    }).toList();



    return Column(

      children: [

        Padding(

          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),

          child: TextField(

            decoration: const InputDecoration(

              labelText: 'Buscar por nome ou login...',

              prefixIcon: Icon(Icons.search, size: 20),

            ),

            onChanged: (v) => setState(() => _busca = v),

          ),

        ),

        SingleChildScrollView(

          scrollDirection: Axis.horizontal,

          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),

          child: Row(

            children: [

              _FiltroChip(

                label: 'Todos',

                selecionado: _filtroPerfil == 'todos',

                onTap: () => setState(() => _filtroPerfil = 'todos'),

              ),

              const SizedBox(width: 8),

              _FiltroChip(

                label: 'Almoxarife',

                selecionado: _filtroPerfil == 'almoxarife',

                cor: const Color(0xFF0B7D3E),

                onTap: () => setState(() => _filtroPerfil = 'almoxarife'),

              ),

              const SizedBox(width: 8),

              _FiltroChip(

                label: 'Professor',

                selecionado: _filtroPerfil == 'professor',

                cor: const Color(0xFFCC6600),

                onTap: () => setState(() => _filtroPerfil = 'professor'),

              ),

            ],

          ),

        ),

        Expanded(

          child: usuarios.isEmpty

              ? const _EmptyState(

                  icon: Icons.person_search_outlined,

                  mensagem: 'Nenhum usuário encontrado.',

                )

              : ListView.builder(

                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

                  itemCount: usuarios.length,

                  itemBuilder: (_, i) {

                    final u = usuarios[i];

                    final cor =

                        _perfilCor[u.perfil] ?? const Color(0xFF6B7A99);

                    return Padding(

                      padding: const EdgeInsets.only(bottom: 10),

                      child: Card(

                        child: ListTile(

                          leading: Container(

                            width: 42,

                            height: 42,

                            decoration: BoxDecoration(

                              color: cor.withValues(alpha: 0.1),

                              borderRadius: BorderRadius.circular(10),

                            ),

                            child: Icon(Icons.person_rounded,

                                color: cor, size: 22),

                          ),

                          title: Text(

                            u.nome,

                            style: const TextStyle(

                                fontWeight: FontWeight.w600, fontSize: 14),

                          ),

                          subtitle: Text(

                            u.login,

                            style: const TextStyle(

                                fontSize: 12, color: Color(0xFF9AA5BE)),

                          ),

                          trailing: Row(

                            mainAxisSize: MainAxisSize.min,

                            children: [

                              Container(

                                padding: const EdgeInsets.symmetric(

                                    horizontal: 8, vertical: 4),

                                decoration: BoxDecoration(

                                  color: cor,

                                  borderRadius: BorderRadius.circular(6),

                                ),

                                child: Text(

                                  u.perfil.toUpperCase(),

                                  style: const TextStyle(

                                    color: Colors.white,

                                    fontSize: 10,

                                    fontWeight: FontWeight.w700,

                                    letterSpacing: 0.5,

                                  ),

                                ),

                              ),

                              const SizedBox(width: 4),

                              IconButton(

                                icon: const Icon(Icons.edit_outlined, size: 18),

                                color: const Color(0xFF6B7A99),

                                tooltip: 'Editar usuário',

                                onPressed: () => widget.onEditar(u),

                              ),

                            ],

                          ),

                        ),

                      ),

                    );

                  },

                ),

        ),

      ],

    );

  }

}



// ─────────────────────────────────────────────

// SOLICITAR TAB (professor)

// ─────────────────────────────────────────────



class SolicitarTab extends StatefulWidget {

  final StockService service;

  const SolicitarTab({super.key, required this.service});



  @override

  State<SolicitarTab> createState() => _SolicitarTabState();

}



class _SolicitarTabState extends State<SolicitarTab> {

  Livro? _livroSelecionado;

  final _qtdCtrl = TextEditingController();

  final _obsCtrl = TextEditingController();

  String? _erro;

  bool _sucesso = false;



  @override

  void dispose() {

    _qtdCtrl.dispose();

    _obsCtrl.dispose();

    super.dispose();

  }



  void _enviar() {

    setState(() {

      _erro = null;

      _sucesso = false;

    });

    if (_livroSelecionado == null) {

      setState(() => _erro = 'Selecione um livro.');

      return;

    }

    final qtd = int.tryParse(_qtdCtrl.text.trim());

    if (qtd == null || qtd <= 0) {

      setState(() => _erro = 'Informe uma quantidade válida.');

      return;

    }

    final resultado = widget.service.criarSolicitacao(

      livroId: _livroSelecionado!.id,

      quantidade: qtd,

      observacao: _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),

    );

    if (resultado == 'ok') {

      setState(() {

        _sucesso = true;

        _livroSelecionado = null;

        _qtdCtrl.clear();

        _obsCtrl.clear();

      });

    } else {

      setState(() => _erro = resultado);

    }

  }



  @override

  Widget build(BuildContext context) {

    const cor = Color(0xFF003087);

    const corDark = Color(0xFF001A4D);



    return SingleChildScrollView(

      padding: const EdgeInsets.all(16),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Container(

            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(

              gradient: const LinearGradient(

                colors: [cor, corDark],

                begin: Alignment.centerLeft,

                end: Alignment.centerRight,

              ),

              borderRadius: BorderRadius.circular(16),

              boxShadow: [

                BoxShadow(

                  color: cor.withValues(alpha: 0.3),

                  blurRadius: 12,

                  offset: const Offset(0, 5),

                ),

              ],

            ),

            child: Row(

              children: [

                Container(

                  padding: const EdgeInsets.all(10),

                  decoration: BoxDecoration(

                    color: Colors.white.withValues(alpha: 0.2),

                    borderRadius: BorderRadius.circular(12),

                  ),

                  child: const Icon(Icons.send_rounded,

                      color: Colors.white, size: 24),

                ),

                const SizedBox(width: 14),

                const Expanded(

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(

                        'Solicitar Livro',

                        style: TextStyle(

                          color: Colors.white,

                          fontWeight: FontWeight.w800,

                          fontSize: 16,

                        ),

                      ),

                      Text(

                        'O almoxarife receberá e aprovará seu pedido.',

                        style: TextStyle(

                          color: Colors.white70,

                          fontSize: 12,

                        ),

                      ),

                    ],

                  ),

                ),

              ],

            ),

          ),

          const SizedBox(height: 20),

          const Text(

            'Livro *',

            style: TextStyle(

                fontWeight: FontWeight.w600,

                fontSize: 13,

                color: Color(0xFF1A2340)),

          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<Livro>(

            key: ValueKey(_livroSelecionado?.id ?? ''),

            initialValue: _livroSelecionado,

            hint: const Text('Selecione o título'),

            decoration: const InputDecoration(),

            items: widget.service.livros

                .map((l) => DropdownMenuItem(

                      value: l,

                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,

                        mainAxisSize: MainAxisSize.min,

                        children: [

                          Text(l.titulo,

                              style: const TextStyle(

                                  fontSize: 13, fontWeight: FontWeight.w500),

                              overflow: TextOverflow.ellipsis),

                          Text(

                            l.saldo == 0

                                ? 'Sem estoque no momento'

                                : 'Estoque atual: ${l.saldo} un.',

                            style: TextStyle(

                                fontSize: 11,

                                color: l.saldo == 0

                                    ? const Color(0xFFCC0020)

                                    : const Color(0xFF9AA5BE)),

                          ),

                        ],

                      ),

                    ))

                .toList(),

            onChanged: (v) => setState(() {

              _livroSelecionado = v;

              _erro = null;

              _sucesso = false;

            }),

          ),

          if (_livroSelecionado != null) ...[

            const SizedBox(height: 10),

            Container(

              padding:

                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

              decoration: BoxDecoration(

                color: _livroSelecionado!.saldo == 0

                    ? const Color(0xFFFFEEEE)

                    : _livroSelecionado!.estoqueAbaixoMinimo

                        ? const Color(0xFFFFF8E1)

                        : const Color(0xFFF0F4FF),

                borderRadius: BorderRadius.circular(8),

              ),

              child: Row(

                children: [

                  Icon(

                    _livroSelecionado!.saldo == 0

                        ? Icons.warning_rounded

                        : Icons.layers_rounded,

                    size: 16,

                    color: _livroSelecionado!.saldo == 0

                        ? const Color(0xFFCC0020)

                        : _livroSelecionado!.estoqueAbaixoMinimo

                            ? const Color(0xFFD97706)

                            : const Color(0xFF003087),

                  ),

                  const SizedBox(width: 8),

                  Expanded(

                    child: Text(

                      _livroSelecionado!.saldo == 0

                          ? 'Sem estoque agora — o almoxarife avaliará a solicitação.'

                          : 'Estoque atual: ${_livroSelecionado!.saldo} unidades',

                      style: TextStyle(

                        fontSize: 12,

                        color: _livroSelecionado!.saldo == 0

                            ? const Color(0xFFCC0020)

                            : _livroSelecionado!.estoqueAbaixoMinimo

                                ? const Color(0xFFD97706)

                                : const Color(0xFF003087),

                        fontWeight: FontWeight.w500,

                      ),

                    ),

                  ),

                ],

              ),

            ),

          ],

          const SizedBox(height: 16),

          const Text(

            'Quantidade *',

            style: TextStyle(

                fontWeight: FontWeight.w600,

                fontSize: 13,

                color: Color(0xFF1A2340)),

          ),

          const SizedBox(height: 8),

          TextField(

            controller: _qtdCtrl,

            keyboardType: TextInputType.number,

            inputFormatters: [FilteringTextInputFormatter.digitsOnly],

            decoration: const InputDecoration(

              labelText: 'Ex: 30',

              prefixIcon: Icon(Icons.numbers_rounded, size: 20),

            ),

          ),

          const SizedBox(height: 16),

          const Text(

            'Observação (opcional)',

            style: TextStyle(

                fontWeight: FontWeight.w600,

                fontSize: 13,

                color: Color(0xFF1A2340)),

          ),

          const SizedBox(height: 8),

          TextField(

            controller: _obsCtrl,

            decoration: const InputDecoration(

              labelText: 'Ex: Turma A – Sala 201',

              prefixIcon: Icon(Icons.notes_rounded, size: 20),

            ),

            maxLines: 2,

          ),

          if (_erro != null) ...[

            const SizedBox(height: 12),

            _ErroBox(mensagem: _erro!),

          ],

          if (_sucesso) ...[

            const SizedBox(height: 12),

            Container(

              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(

                color: const Color(0xFFE6F4EE),

                borderRadius: BorderRadius.circular(8),

                border: const Border.fromBorderSide(

                    BorderSide(color: Color(0xFFB2DFC8))),

              ),

              child: const Row(

                children: [

                  Icon(Icons.check_circle_outline,

                      color: Color(0xFF0B7D3E), size: 18),

                  SizedBox(width: 8),

                  Text('Solicitação enviada! Aguarde a aprovação.',

                      style:

                          TextStyle(color: Color(0xFF0B7D3E), fontSize: 13)),

                ],

              ),

            ),

          ],

          const SizedBox(height: 20),

          SizedBox(

            width: double.infinity,

            child: ElevatedButton.icon(

              style: ElevatedButton.styleFrom(backgroundColor: cor),

              icon: const Icon(Icons.send_rounded, size: 18),

              label: const Text('Enviar Solicitação'),

              onPressed: _enviar,

            ),

          ),

        ],

      ),

    );

  }

}



// ─────────────────────────────────────────────

// MINHAS SOLICITAÇÕES TAB (professor)

// ─────────────────────────────────────────────



class MinhasSolicitacoesTab extends StatefulWidget {

  final StockService service;

  const MinhasSolicitacoesTab({super.key, required this.service});



  @override

  State<MinhasSolicitacoesTab> createState() => _MinhasSolicitacoesTabState();

}



class _MinhasSolicitacoesTabState extends State<MinhasSolicitacoesTab> {

  String _filtroStatus = 'todos';

  String _busca = '';



  @override

  void initState() {

    super.initState();

    widget.service.addListener(_onServiceChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {

      widget.service.marcarLidasProf(widget.service.usuarioLogado!.login);

    });

  }



  @override

  void dispose() {

    widget.service.removeListener(_onServiceChanged);

    super.dispose();

  }



  void _onServiceChanged() {

    if (mounted) setState(() {});

  }



  @override

  Widget build(BuildContext context) {

    final login = widget.service.usuarioLogado!.login;

    final todas = widget.service.solicitacoesDoProf(login);

    final lista = todas.where((s) {

      final statusOk =

          _filtroStatus == 'todos' || s.status == _filtroStatus;

      final textoOk = _busca.isEmpty ||

          s.livroTitulo.toLowerCase().contains(_busca.toLowerCase());

      return statusOk && textoOk;

    }).toList();



    return Column(

      children: [

        Container(

          margin: const EdgeInsets.all(16),

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(

            gradient: const LinearGradient(

              colors: [Color(0xFF003087), Color(0xFF001A4D)],

              begin: Alignment.centerLeft,

              end: Alignment.centerRight,

            ),

            borderRadius: BorderRadius.circular(16),

            boxShadow: [

              BoxShadow(

                color: const Color(0xFF003087).withValues(alpha: 0.3),

                blurRadius: 12,

                offset: const Offset(0, 4),

              ),

            ],

          ),

          child: Row(

            children: [

              Container(

                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(

                  color: Colors.white.withValues(alpha: 0.2),

                  borderRadius: BorderRadius.circular(12),

                ),

                child: const Icon(Icons.inbox_rounded,

                    color: Colors.white, size: 24),

              ),

              const SizedBox(width: 14),

              Expanded(

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(

                      '${lista.length} solicitação(ões)',

                      style: const TextStyle(

                          fontWeight: FontWeight.w800,

                          fontSize: 15,

                          color: Colors.white),

                    ),

                    const Text(

                      'Acompanhe o status dos seus pedidos',

                      style: TextStyle(fontSize: 12, color: Colors.white70),

                    ),

                  ],

                ),

              ),

            ],

          ),

        ),

        Padding(

          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),

          child: TextField(

            decoration: const InputDecoration(

              labelText: 'Buscar por título do livro...',

              prefixIcon: Icon(Icons.search, size: 20),

            ),

            onChanged: (v) => setState(() => _busca = v),

          ),

        ),

        SingleChildScrollView(

          scrollDirection: Axis.horizontal,

          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),

          child: Row(

            children: [

              _FiltroChip(

                label: 'Todos',

                selecionado: _filtroStatus == 'todos',

                onTap: () => setState(() => _filtroStatus = 'todos'),

              ),

              const SizedBox(width: 8),

              _FiltroChip(

                label: 'Pendente',

                selecionado: _filtroStatus == 'pendente',

                cor: const Color(0xFFD97706),

                onTap: () => setState(() => _filtroStatus = 'pendente'),

              ),

              const SizedBox(width: 8),

              _FiltroChip(

                label: 'Aprovada',

                selecionado: _filtroStatus == 'aprovada',

                cor: const Color(0xFF16A34A),

                onTap: () => setState(() => _filtroStatus = 'aprovada'),

              ),

              const SizedBox(width: 8),

              _FiltroChip(

                label: 'Recusada',

                selecionado: _filtroStatus == 'recusada',

                cor: const Color(0xFFCC0020),

                onTap: () => setState(() => _filtroStatus = 'recusada'),

              ),

            ],

          ),

        ),

        Expanded(

          child: lista.isEmpty

              ? const _EmptyState(

                  icon: Icons.inbox_outlined,

                  mensagem: 'Nenhuma solicitação encontrada.',

                )

              : ListView.builder(

                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

                  itemCount: lista.length,

                  itemBuilder: (_, i) =>

                      _SolicitacaoCardProf(sol: lista[i]),

                ),

        ),

      ],

    );

  }

}



class _SolicitacaoCardProf extends StatelessWidget {

  final Solicitacao sol;

  const _SolicitacaoCardProf({required this.sol});



  @override

  Widget build(BuildContext context) {

    Color cor;

    IconData icone;

    String label;

    switch (sol.status) {

      case 'aprovada':

        cor = const Color(0xFF16A34A);

        icone = Icons.check_circle_rounded;

        label = 'APROVADA';

        break;

      case 'recusada':

        cor = const Color(0xFFCC0020);

        icone = Icons.cancel_rounded;

        label = 'RECUSADA';

        break;

      default:

        cor = const Color(0xFFD97706);

        icone = Icons.hourglass_top_rounded;

        label = 'PENDENTE';

    }



    return Padding(

      padding: const EdgeInsets.only(bottom: 10),

      child: Container(

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius: BorderRadius.circular(14),

          border: Border.all(color: cor.withValues(alpha: 0.3)),

          boxShadow: [

            BoxShadow(

              color: cor.withValues(alpha: 0.07),

              blurRadius: 8,

              offset: const Offset(0, 3),

            ),

          ],

        ),

        child: ClipRRect(

          borderRadius: BorderRadius.circular(14),

          child: Row(

            children: [

              Container(width: 5, color: cor,

                  height: sol.motivoRecusa != null ? 100 : 80),

              Expanded(

                child: Padding(

                  padding: const EdgeInsets.all(14),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Row(

                        children: [

                          Expanded(

                            child: Text(

                              sol.livroTitulo,

                              style: const TextStyle(

                                  fontWeight: FontWeight.w700,

                                  fontSize: 13,

                                  color: Color(0xFF1A0A0A)),

                              maxLines: 1,

                              overflow: TextOverflow.ellipsis,

                            ),

                          ),

                          const SizedBox(width: 8),

                          Container(

                            padding: const EdgeInsets.symmetric(

                                horizontal: 8, vertical: 3),

                            decoration: BoxDecoration(

                              color: cor,

                              borderRadius: BorderRadius.circular(6),

                            ),

                            child: Row(

                              mainAxisSize: MainAxisSize.min,

                              children: [

                                Icon(icone,

                                    color: Colors.white, size: 11),

                                const SizedBox(width: 4),

                                Text(label,

                                    style: const TextStyle(

                                        color: Colors.white,

                                        fontSize: 10,

                                        fontWeight: FontWeight.w700)),

                              ],

                            ),

                          ),

                        ],

                      ),

                      const SizedBox(height: 6),

                      Row(

                        children: [

                          const Icon(Icons.layers_rounded,

                              size: 13, color: Color(0xFF8C7070)),

                          const SizedBox(width: 4),

                          Text('${sol.quantidade} un.',

                              style: const TextStyle(

                                  fontSize: 12,

                                  color: Color(0xFF8C7070))),

                          const SizedBox(width: 12),

                          const Icon(Icons.calendar_today_rounded,

                              size: 13, color: Color(0xFF8C7070)),

                          const SizedBox(width: 4),

                          Text(_fmt(sol.dataSolicitacao),

                              style: const TextStyle(

                                  fontSize: 12,

                                  color: Color(0xFF8C7070))),

                        ],

                      ),

                      if (sol.observacao != null) ...[

                        const SizedBox(height: 4),

                        Text(sol.observacao!,

                            style: const TextStyle(

                                fontSize: 11,

                                color: Color(0xFF9AA5BE),

                                fontStyle: FontStyle.italic)),

                      ],

                      if (sol.motivoRecusa != null) ...[

                        const SizedBox(height: 6),

                        Container(

                          padding: const EdgeInsets.symmetric(

                              horizontal: 8, vertical: 5),

                          decoration: BoxDecoration(

                            color: const Color(0xFFFFEEEE),

                            borderRadius: BorderRadius.circular(6),

                          ),

                          child: Row(

                            children: [

                              const Icon(Icons.info_outline,

                                  size: 13,

                                  color: Color(0xFFCC0020)),

                              const SizedBox(width: 6),

                              Expanded(

                                child: Text(

                                  'Motivo: ${sol.motivoRecusa}',

                                  style: const TextStyle(

                                      fontSize: 11,

                                      color: Color(0xFFCC0020)),

                                ),

                              ),

                            ],

                          ),

                        ),

                      ],

                    ],

                  ),

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }



  String _fmt(DateTime d) =>

      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} '

      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

}



// ─────────────────────────────────────────────

// SOLICITAÇÕES TAB (almoxarife)

// ─────────────────────────────────────────────



class SolicitacoesTab extends StatefulWidget {

  final StockService service;

  const SolicitacoesTab({super.key, required this.service});



  @override

  State<SolicitacoesTab> createState() => _SolicitacoesTabState();

}



class _SolicitacoesTabState extends State<SolicitacoesTab> {

  String _busca = '';

  String _filtroStatus = 'todos';



  @override

  void initState() {

    super.initState();

    widget.service.addListener(_onServiceChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {

      widget.service.marcarLidasAlmo();

    });

  }



  @override

  void dispose() {

    widget.service.removeListener(_onServiceChanged);

    super.dispose();

  }



  void _onServiceChanged() {

    if (mounted) setState(() {});

  }



  @override

  Widget build(BuildContext context) {

    final todas = widget.service.solicitacoes.where((s) {

      final statusOk =

          _filtroStatus == 'todos' || s.status == _filtroStatus;

      final textoOk = _busca.isEmpty ||

          s.livroTitulo.toLowerCase().contains(_busca.toLowerCase()) ||

          s.professorNome.toLowerCase().contains(_busca.toLowerCase());

      return statusOk && textoOk;

    }).toList();

    final pendentes = todas.where((s) => s.status == 'pendente').toList();

    final respondidas =

        todas.where((s) => s.status != 'pendente').toList();



    return Column(

      children: [

        Container(

          margin: const EdgeInsets.all(16),

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(

            gradient: pendentes.isEmpty

                ? const LinearGradient(

                    colors: [Color(0xFF16A34A), Color(0xFF0A5C2A)],

                    begin: Alignment.centerLeft,

                    end: Alignment.centerRight,

                  )

                : const LinearGradient(

                    colors: [Color(0xFFD97706), Color(0xFF92400E)],

                    begin: Alignment.centerLeft,

                    end: Alignment.centerRight,

                  ),

            borderRadius: BorderRadius.circular(16),

            boxShadow: [

              BoxShadow(

                color: (pendentes.isEmpty

                        ? const Color(0xFF16A34A)

                        : const Color(0xFFD97706))

                    .withValues(alpha: 0.3),

                blurRadius: 12,

                offset: const Offset(0, 4),

              ),

            ],

          ),

          child: Row(

            children: [

              Container(

                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(

                  color: Colors.white.withValues(alpha: 0.2),

                  borderRadius: BorderRadius.circular(12),

                ),

                child: Icon(

                  pendentes.isEmpty

                      ? Icons.check_circle_rounded

                      : Icons.assignment_late_rounded,

                  color: Colors.white,

                  size: 24,

                ),

              ),

              const SizedBox(width: 14),

              Expanded(

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(

                      pendentes.isEmpty

                          ? 'Nenhum pedido pendente'

                          : '${pendentes.length} pedido(s) aguardando',

                      style: const TextStyle(

                          fontWeight: FontWeight.w800,

                          fontSize: 15,

                          color: Colors.white),

                    ),

                    const Text(

                      'Aprovar ou recusar solicitações dos professores',

                      style: TextStyle(fontSize: 12, color: Colors.white70),

                    ),

                  ],

                ),

              ),

            ],

          ),

        ),

        Padding(

          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),

          child: TextField(

            decoration: const InputDecoration(

              labelText: 'Buscar por livro ou professor...',

              prefixIcon: Icon(Icons.search, size: 20),

            ),

            onChanged: (v) => setState(() => _busca = v),

          ),

        ),

        SingleChildScrollView(

          scrollDirection: Axis.horizontal,

          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),

          child: Row(

            children: [

              _FiltroChip(

                label: 'Todos',

                selecionado: _filtroStatus == 'todos',

                onTap: () => setState(() => _filtroStatus = 'todos'),

              ),

              const SizedBox(width: 8),

              _FiltroChip(

                label: 'Pendente',

                selecionado: _filtroStatus == 'pendente',

                cor: const Color(0xFFD97706),

                onTap: () => setState(() => _filtroStatus = 'pendente'),

              ),

              const SizedBox(width: 8),

              _FiltroChip(

                label: 'Aprovada',

                selecionado: _filtroStatus == 'aprovada',

                cor: const Color(0xFF16A34A),

                onTap: () => setState(() => _filtroStatus = 'aprovada'),

              ),

              const SizedBox(width: 8),

              _FiltroChip(

                label: 'Recusada',

                selecionado: _filtroStatus == 'recusada',

                cor: const Color(0xFFCC0020),

                onTap: () => setState(() => _filtroStatus = 'recusada'),

              ),

            ],

          ),

        ),

        Expanded(

          child: todas.isEmpty

              ? const _EmptyState(

                  icon: Icons.assignment_outlined,

                  mensagem: 'Nenhuma solicitação encontrada.',

                )

              : ListView(

                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

                  children: [

                    if (pendentes.isNotEmpty) ...[

                      const _SectionTitle('Aguardando Resposta'),

                      const SizedBox(height: 8),

                      ...pendentes.map((s) =>

                          _SolicitacaoCardAlmo(

                            sol: s,

                            service: widget.service,

                            onAcao: () => setState(() {}),

                          )),

                      const SizedBox(height: 16),

                    ],

                    if (respondidas.isNotEmpty) ...[

                      const _SectionTitle('Respondidas'),

                      const SizedBox(height: 8),

                      ...respondidas.map((s) =>

                          _SolicitacaoCardAlmo(

                            sol: s,

                            service: widget.service,

                            onAcao: () => setState(() {}),

                          )),

                    ],

                  ],

                ),

        ),

      ],

    );

  }

}



class _SolicitacaoCardAlmo extends StatelessWidget {

  final Solicitacao sol;

  final StockService service;

  final VoidCallback onAcao;

  const _SolicitacaoCardAlmo(

      {required this.sol, required this.service, required this.onAcao});



  @override

  Widget build(BuildContext context) {

    final isPendente = sol.status == 'pendente';

    final cor = isPendente

        ? const Color(0xFFD97706)

        : sol.status == 'aprovada'

            ? const Color(0xFF16A34A)

            : const Color(0xFFCC0020);



    return Padding(

      padding: const EdgeInsets.only(bottom: 10),

      child: Container(

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius: BorderRadius.circular(14),

          border: Border.all(color: cor.withValues(alpha: 0.25)),

          boxShadow: [

            BoxShadow(

              color: cor.withValues(alpha: 0.06),

              blurRadius: 8,

              offset: const Offset(0, 3),

            ),

          ],

        ),

        child: Padding(

          padding: const EdgeInsets.all(14),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Row(

                children: [

                  Expanded(

                    child: Text(

                      sol.livroTitulo,

                      style: const TextStyle(

                          fontWeight: FontWeight.w700,

                          fontSize: 13,

                          color: Color(0xFF1A0A0A)),

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                    ),

                  ),

                  if (!isPendente)

                    Container(

                      padding: const EdgeInsets.symmetric(

                          horizontal: 8, vertical: 3),

                      decoration: BoxDecoration(

                        color: cor,

                        borderRadius: BorderRadius.circular(6),

                      ),

                      child: Text(

                        sol.status.toUpperCase(),

                        style: const TextStyle(

                            color: Colors.white,

                            fontSize: 10,

                            fontWeight: FontWeight.w700),

                      ),

                    ),

                ],

              ),

              const SizedBox(height: 6),

              Row(

                children: [

                  const Icon(Icons.person_outline_rounded,

                      size: 13, color: Color(0xFF8C7070)),

                  const SizedBox(width: 4),

                  Text(sol.professorNome,

                      style: const TextStyle(

                          fontSize: 12, color: Color(0xFF8C7070))),

                  const SizedBox(width: 12),

                  const Icon(Icons.layers_rounded,

                      size: 13, color: Color(0xFF8C7070)),

                  const SizedBox(width: 4),

                  Text('${sol.quantidade} un.',

                      style: const TextStyle(

                          fontSize: 12, color: Color(0xFF8C7070))),

                  const SizedBox(width: 12),

                  const Icon(Icons.calendar_today_rounded,

                      size: 13, color: Color(0xFF8C7070)),

                  const SizedBox(width: 4),

                  Text(_fmt(sol.dataSolicitacao),

                      style: const TextStyle(

                          fontSize: 12, color: Color(0xFF8C7070))),

                ],

              ),

              if (sol.observacao != null) ...[

                const SizedBox(height: 4),

                Text(sol.observacao!,

                    style: const TextStyle(

                        fontSize: 11,

                        color: Color(0xFF9AA5BE),

                        fontStyle: FontStyle.italic)),

              ],

              if (sol.motivoRecusa != null) ...[

                const SizedBox(height: 6),

                Text('Motivo: ${sol.motivoRecusa}',

                    style: const TextStyle(

                        fontSize: 11, color: Color(0xFFCC0020))),

              ],

              if (isPendente) ...[

                const SizedBox(height: 12),

                Row(

                  children: [

                    Expanded(

                      child: OutlinedButton.icon(

                        style: OutlinedButton.styleFrom(

                          foregroundColor: const Color(0xFFCC0020),

                          side: const BorderSide(color: Color(0xFFCC0020)),

                          padding: const EdgeInsets.symmetric(vertical: 10),

                          shape: RoundedRectangleBorder(

                              borderRadius: BorderRadius.circular(10)),

                        ),

                        icon: const Icon(Icons.close_rounded, size: 16),

                        label: const Text('Recusar',

                            style: TextStyle(

                                fontSize: 13,

                                fontWeight: FontWeight.w600)),

                        onPressed: () =>

                            _mostrarDialogRecusa(context),

                      ),

                    ),

                    const SizedBox(width: 10),

                    Expanded(

                      child: ElevatedButton.icon(

                        style: ElevatedButton.styleFrom(

                          backgroundColor: const Color(0xFF16A34A),

                          padding: const EdgeInsets.symmetric(vertical: 10),

                          shape: RoundedRectangleBorder(

                              borderRadius: BorderRadius.circular(10)),

                        ),

                        icon: const Icon(Icons.check_rounded, size: 16),

                        label: const Text('Aprovar',

                            style: TextStyle(

                                fontSize: 13,

                                fontWeight: FontWeight.w600)),

                        onPressed: () {

                          final res =

                              service.aprovarSolicitacao(sol.id);

                          if (res != 'ok') {

                            ScaffoldMessenger.of(context).showSnackBar(

                              SnackBar(

                                content: Text(res),

                                backgroundColor: const Color(0xFFCC0020),

                              ),

                            );

                          } else {

                            onAcao();

                          }

                        },

                      ),

                    ),

                  ],

                ),

              ],

            ],

          ),

        ),

      ),

    );

  }



  void _mostrarDialogRecusa(BuildContext context) {

    final motivoCtrl = TextEditingController();

    showDialog(

      context: context,

      builder: (ctx) => AlertDialog(

        title: const Text('Recusar Solicitação'),

        content: Column(

          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(

              sol.livroTitulo,

              style: const TextStyle(

                  fontWeight: FontWeight.w600, fontSize: 14),

            ),

            const SizedBox(height: 4),

            Text('${sol.quantidade} un. · ${sol.professorNome}',

                style: const TextStyle(

                    fontSize: 12, color: Color(0xFF8C7070))),

            const SizedBox(height: 16),

            TextField(

              controller: motivoCtrl,

              decoration: const InputDecoration(

                labelText: 'Motivo (opcional)',

                prefixIcon: Icon(Icons.notes_rounded, size: 20),

              ),

              maxLines: 2,

              autofocus: true,

            ),

          ],

        ),

        actions: [

          TextButton(

            onPressed: () => Navigator.pop(ctx),

            child: const Text('Cancelar'),

          ),

          ElevatedButton(

            style: ElevatedButton.styleFrom(

                backgroundColor: const Color(0xFFCC0020)),

            onPressed: () {

              service.recusarSolicitacao(sol.id, motivoCtrl.text);

              Navigator.pop(ctx);

              onAcao();

            },

            child: const Text('Recusar'),

          ),

        ],

      ),

    ).whenComplete(motivoCtrl.dispose);

  }



  String _fmt(DateTime d) =>

      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} '

      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

}



// ─────────────────────────────────────────────

// WIDGETS AUXILIARES

// ─────────────────────────────────────────────



class _ErroBox extends StatelessWidget {

  final String mensagem;

  const _ErroBox({required this.mensagem});



  @override

  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(

        color: const Color(0xFFFFEEEE),

        borderRadius: BorderRadius.circular(8),

        border: const Border.fromBorderSide(

            BorderSide(color: Color(0xFFFFCCCC))),

      ),

      child: Row(

        children: [

          const Icon(Icons.error_outline,

              color: Color(0xFFE8000D), size: 18),

          const SizedBox(width: 8),

          Expanded(

            child: Text(mensagem,

                style: const TextStyle(

                    color: Color(0xFFE8000D), fontSize: 13)),

          ),

        ],

      ),

    );

  }

}



class _EmptyState extends StatelessWidget {

  final IconData icon;

  final String mensagem;

  const _EmptyState({required this.icon, required this.mensagem});



  @override

  Widget build(BuildContext context) {

    return Center(

      child: Column(

        mainAxisSize: MainAxisSize.min,

        children: [

          Icon(icon, size: 48, color: const Color(0xFFCDD4E0)),

          const SizedBox(height: 12),

          Text(

            mensagem,

            style: const TextStyle(color: Color(0xFF9AA5BE), fontSize: 14),

            textAlign: TextAlign.center,

          ),

        ],

      ),

    );

  }

}



// ─────────────────────────────────────────────

// FILTRO CHIP (compartilhado)

// ─────────────────────────────────────────────



class _FiltroChip extends StatelessWidget {

  final String label;

  final bool selecionado;

  final Color? cor;

  final VoidCallback onTap;

  const _FiltroChip({

    required this.label,

    required this.selecionado,

    required this.onTap,

    this.cor,

  });



  @override

  Widget build(BuildContext context) {

    final color = cor ?? const Color(0xFF6B7A99);

    return GestureDetector(

      onTap: onTap,

      child: AnimatedContainer(

        duration: const Duration(milliseconds: 180),

        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),

        decoration: BoxDecoration(

          color: selecionado ? color : color.withValues(alpha: 0.08),

          borderRadius: BorderRadius.circular(20),

          border: Border.all(

            color: selecionado ? color : color.withValues(alpha: 0.3),

            width: selecionado ? 1.5 : 1,

          ),

        ),

        child: Text(

          label,

          style: TextStyle(

            color: selecionado ? Colors.white : color,

            fontWeight: selecionado ? FontWeight.w700 : FontWeight.w500,

            fontSize: 12,

          ),

        ),

      ),

    );

  }

}



// ─────────────────────────────────────────────

// RELATÓRIOS TAB (almoxarife)

// ─────────────────────────────────────────────



class RelatoriosTab extends StatefulWidget {

  final StockService service;

  const RelatoriosTab({super.key, required this.service});



  @override

  State<RelatoriosTab> createState() => _RelatoriosTabState();

}



class _RelatoriosTabState extends State<RelatoriosTab> {

  String _filtroTipo = 'todos';

  String _filtroPeriodo = 'tudo';

  String _busca = '';



  @override

  void initState() {

    super.initState();

    widget.service.addListener(_onServiceChanged);

  }



  @override

  void dispose() {

    widget.service.removeListener(_onServiceChanged);

    super.dispose();

  }



  void _onServiceChanged() {

    if (mounted) setState(() {});

  }



  List<Movimentacao> get _filtradas {

    final agora = DateTime.now();

    return widget.service.movimentacoes.where((m) {

      if (_filtroTipo != 'todos' && m.tipo != _filtroTipo) { return false; }

      if (_filtroPeriodo == 'hoje') {

        if (m.data.year != agora.year ||

            m.data.month != agora.month ||

            m.data.day != agora.day) { return false; }

      } else if (_filtroPeriodo == 'semana') {

        if (agora.difference(m.data).inDays > 7) { return false; }

      } else if (_filtroPeriodo == 'mes') {

        if (agora.difference(m.data).inDays > 30) { return false; }

      }

      if (_busca.isNotEmpty) {

        final q = _busca.toLowerCase();

        if (!m.livroTitulo.toLowerCase().contains(q) &&

            !m.usuarioNome.toLowerCase().contains(q) &&

            !(m.observacao ?? '').toLowerCase().contains(q)) { return false; }

      }

      return true;

    }).toList();

  }



  @override

  Widget build(BuildContext context) {

    final lista = _filtradas;

    final totalEntrada = lista

        .where((m) => m.tipo == 'entrada')

        .fold<int>(0, (s, m) => s + m.quantidade);

    final totalSaida = lista

        .where((m) => m.tipo == 'saida')

        .fold<int>(0, (s, m) => s + m.quantidade);



    return Column(

      children: [

        Container(

          margin: const EdgeInsets.all(16),

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(

            gradient: const LinearGradient(

              colors: [Color(0xFF7B2FBE), Color(0xFF4A0080)],

              begin: Alignment.centerLeft,

              end: Alignment.centerRight,

            ),

            borderRadius: BorderRadius.circular(16),

            boxShadow: [

              BoxShadow(

                color: const Color(0xFF7B2FBE).withValues(alpha: 0.3),

                blurRadius: 12,

                offset: const Offset(0, 4),

              ),

            ],

          ),

          child: Row(

            children: [

              Container(

                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(

                  color: Colors.white.withValues(alpha: 0.2),

                  borderRadius: BorderRadius.circular(12),

                ),

                child: const Icon(Icons.bar_chart_rounded,

                    color: Colors.white, size: 24),

              ),

              const SizedBox(width: 14),

              Expanded(

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(

                      '${lista.length} movimentação(ões)',

                      style: const TextStyle(

                          fontWeight: FontWeight.w800,

                          fontSize: 15,

                          color: Colors.white),

                    ),

                    const SizedBox(height: 2),

                    Text(

                      'Entradas: $totalEntrada un.  ·  Saídas: $totalSaida un.',

                      style: const TextStyle(

                          fontSize: 12, color: Colors.white70),

                    ),

                  ],

                ),

              ),

            ],

          ),

        ),

        Padding(

          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),

          child: TextField(

            decoration: const InputDecoration(

              labelText: 'Buscar livro, responsável ou obs...',

              prefixIcon: Icon(Icons.search, size: 20),

            ),

            onChanged: (v) => setState(() => _busca = v),

          ),

        ),

        SingleChildScrollView(

          scrollDirection: Axis.horizontal,

          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),

          child: Row(

            children: [

              _FiltroChip(

                label: 'Todos',

                selecionado: _filtroTipo == 'todos',

                onTap: () => setState(() => _filtroTipo = 'todos'),

              ),

              const SizedBox(width: 8),

              _FiltroChip(

                label: 'Entradas',

                selecionado: _filtroTipo == 'entrada',

                cor: const Color(0xFF16A34A),

                onTap: () => setState(() => _filtroTipo = 'entrada'),

              ),

              const SizedBox(width: 8),

              _FiltroChip(

                label: 'Saídas',

                selecionado: _filtroTipo == 'saida',

                cor: const Color(0xFFCC0020),

                onTap: () => setState(() => _filtroTipo = 'saida'),

              ),

            ],

          ),

        ),

        SingleChildScrollView(

          scrollDirection: Axis.horizontal,

          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),

          child: Row(

            children: [

              _FiltroChip(

                label: 'Tudo',

                selecionado: _filtroPeriodo == 'tudo',

                cor: const Color(0xFF7B2FBE),

                onTap: () => setState(() => _filtroPeriodo = 'tudo'),

              ),

              const SizedBox(width: 8),

              _FiltroChip(

                label: 'Hoje',

                selecionado: _filtroPeriodo == 'hoje',

                cor: const Color(0xFF7B2FBE),

                onTap: () => setState(() => _filtroPeriodo = 'hoje'),

              ),

              const SizedBox(width: 8),

              _FiltroChip(

                label: '7 dias',

                selecionado: _filtroPeriodo == 'semana',

                cor: const Color(0xFF7B2FBE),

                onTap: () => setState(() => _filtroPeriodo = 'semana'),

              ),

              const SizedBox(width: 8),

              _FiltroChip(

                label: '30 dias',

                selecionado: _filtroPeriodo == 'mes',

                cor: const Color(0xFF7B2FBE),

                onTap: () => setState(() => _filtroPeriodo = 'mes'),

              ),

            ],

          ),

        ),

        Expanded(

          child: lista.isEmpty

              ? const _EmptyState(

                  icon: Icons.bar_chart_outlined,

                  mensagem: 'Nenhuma movimentação encontrada.',

                )

              : ListView.builder(

                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

                  itemCount: lista.length,

                  itemBuilder: (_, i) {

                    final m = lista[i];

                    final entrada = m.tipo == 'entrada';

                    final cor = entrada

                        ? const Color(0xFF16A34A)

                        : const Color(0xFFCC0020);

                    final data = m.data;

                    final dataStr =

                        '${data.day.toString().padLeft(2, '0')}/'

                        '${data.month.toString().padLeft(2, '0')}/'

                        '${data.year}  '

                        '${data.hour.toString().padLeft(2, '0')}:'

                        '${data.minute.toString().padLeft(2, '0')}';

                    return Card(

                      margin: const EdgeInsets.only(bottom: 10),

                      child: Row(

                        children: [

                          Container(

                            width: 5,

                            height: 80,

                            decoration: BoxDecoration(

                              color: cor,

                              borderRadius: const BorderRadius.only(

                                topLeft: Radius.circular(12),

                                bottomLeft: Radius.circular(12),

                              ),

                            ),

                          ),

                          const SizedBox(width: 12),

                          Container(

                            padding: const EdgeInsets.all(8),

                            decoration: BoxDecoration(

                              color: cor.withValues(alpha: 0.1),

                              borderRadius: BorderRadius.circular(8),

                            ),

                            child: Icon(

                              entrada

                                  ? Icons.arrow_downward_rounded

                                  : Icons.arrow_upward_rounded,

                              color: cor,

                              size: 18,

                            ),

                          ),

                          const SizedBox(width: 10),

                          Expanded(

                            child: Padding(

                              padding: const EdgeInsets.symmetric(vertical: 10),

                              child: Column(

                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [

                                  Row(

                                    children: [

                                      Expanded(

                                        child: Text(

                                          m.livroTitulo,

                                          style: const TextStyle(

                                            fontWeight: FontWeight.w600,

                                            fontSize: 13,

                                          ),

                                          maxLines: 1,

                                          overflow: TextOverflow.ellipsis,

                                        ),

                                      ),

                                      Container(

                                        padding: const EdgeInsets.symmetric(

                                            horizontal: 7, vertical: 3),

                                        decoration: BoxDecoration(

                                          color: cor,

                                          borderRadius: BorderRadius.circular(6),

                                        ),

                                        child: Text(

                                          entrada ? 'ENTRADA' : 'SAÍDA',

                                          style: const TextStyle(

                                            color: Colors.white,

                                            fontSize: 9,

                                            fontWeight: FontWeight.w700,

                                          ),

                                        ),

                                      ),

                                    ],

                                  ),

                                  const SizedBox(height: 4),

                                  Row(

                                    children: [

                                      Icon(Icons.numbers_rounded,

                                          size: 13,

                                          color: const Color(0xFF9AA5BE)),

                                      const SizedBox(width: 3),

                                      Text(

                                        '${m.quantidade} un.',

                                        style: const TextStyle(

                                            fontSize: 12,

                                            color: Color(0xFF6B7A99)),

                                      ),

                                      const SizedBox(width: 10),

                                      Icon(Icons.calendar_today_rounded,

                                          size: 13,

                                          color: const Color(0xFF9AA5BE)),

                                      const SizedBox(width: 3),

                                      Text(

                                        dataStr,

                                        style: const TextStyle(

                                            fontSize: 12,

                                            color: Color(0xFF6B7A99)),

                                      ),

                                    ],

                                  ),

                                  if (m.observacao != null &&

                                      m.observacao!.isNotEmpty) ...[

                                    const SizedBox(height: 2),

                                    Text(

                                      m.observacao!,

                                      style: const TextStyle(

                                        fontSize: 11,

                                        color: Color(0xFF9AA5BE),

                                        fontStyle: FontStyle.italic,

                                      ),

                                      maxLines: 1,

                                      overflow: TextOverflow.ellipsis,

                                    ),

                                  ],

                                ],

                              ),

                            ),

                          ),

                          const SizedBox(width: 12),

                        ],

                      ),

                    );

                  },

                ),

        ),

      ],

    );

  }

}
