import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/avaliacao.dart';
import '../models/local.dart';

class LocalService {
  final _db = FirebaseFirestore.instance;
  late final CollectionReference locais = _db.collection('locais');

  /// Cidade e categoria são filtradas no próprio Firestore (where + orderBy,
  /// com índices compostos em firestore.indexes.json).
  Stream<List<Local>> listarLocais({String cidade = 'Todas', String categoria = 'Todos'}) {
    Query consulta = locais;
    if (cidade != 'Todas') consulta = consulta.where('cidade', isEqualTo: cidade);
    if (categoria != 'Todos') {
      consulta = consulta.where('categoria', isEqualTo: categoria);
    }
    return consulta.orderBy('nome').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Local.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> adicionar(Local local) async {
    await locais.add(local.toMap());
  }

  Future<void> atualizar(Local local) async {
    await locais.doc(local.id).update(local.toMap());
  }

  Future<void> excluir(String id) async {
    await locais.doc(id).delete();
  }

  // Favoritos por usuário: usuarios/{uid} { favoritos: [ids dos locais] }
  Stream<Set<String>> favoritos(String uid) {
    return _db.collection('usuarios').doc(uid).snapshots().map(
        (doc) => Set<String>.from(doc.data()?['favoritos'] ?? const []));
  }

  Future<void> alterarFavorito(String uid, String localId, bool favorito) async {
    await _db.collection('usuarios').doc(uid).set({
      'favoritos': favorito
          ? FieldValue.arrayUnion([localId])
          : FieldValue.arrayRemove([localId]),
    }, SetOptions(merge: true));
  }

  // Avaliações: locais/{localId}/avaliacoes/{uid}, uma por usuário.
  Stream<List<Avaliacao>> avaliacoes(String localId) {
    return locais.doc(localId).collection('avaliacoes').snapshots().map(
        (s) => s.docs.map((d) => Avaliacao.fromMap(d.id, d.data())).toList());
  }

  Future<void> avaliar(String localId, Avaliacao avaliacao) async {
    await locais
        .doc(localId)
        .collection('avaliacoes')
        .doc(avaliacao.uid)
        .set(avaliacao.toMap());
  }
}
