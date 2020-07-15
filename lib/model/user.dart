import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/post.dart';
import 'package:protips/model/post_perfil.dart';
import 'package:protips/model/token.dart';
import 'package:protips/model/user_dados.dart';
import 'package:protips/res/resources.dart';

class UserTag {
  static const String SOLICITACAO_SER_TIPSTER = 'solicitacao_tipster';
}

class User {

  bool _isExpanded = false;
  bool get isExpanded => _isExpanded ?? false;
  set isExpanded(bool value) {
    _isExpanded = value;
  }

  //region Variaveis
  static const String TAG = 'User';

  UserDados _dados;

  Map<dynamic, dynamic> _seguidores;
  Map<dynamic, dynamic> _seguindo;
  Map<dynamic, dynamic> _seguidoresPendentes;
//  Map<String, String> _tags;

  Map<String, Post> _postes;
  Map<String, Token> _tokens;
  Map<String, PostPerfil> _post_perfil;

  String postsPublicas;

  //endregion

  User() {
//    _tags = Map();
    seguindo = Map();
    seguidores = Map();
    post_perfil = Map();
    seguidoresPendentes = Map();
    postes = Map();
    dados = UserDados();
  }

  User.fromMap(Map map) {
    dados = UserDados.fromMap(map['dados']);
    seguidoresPendentes = map['seguidoresPendentes'];
    post_perfil = PostPerfil.fromMapList(map['post_perfil']);
    postes = Post.fromMapList(map['postes']);
    seguidores = map['seguidores'];
    seguindo = map['seguindo'];
    tokens = map['tokens'];
  }

  static Map<String, User> fromMapList(Map map) {
    Map<String, User> items = Map();
    if (map == null)
      return items;
    for (String key in map.keys)
      items[key] = User.fromMap(map[key]);
    return items;
  }

  User.newUser(User user) {
    UserDados _dados = user.dados;
//    tags = Map();
    postes = Map();
    seguindo = Map();
    seguidores = Map();
    post_perfil = Map();
    seguidoresPendentes = Map();

//    tags.addAll(user.tags);
    postes.addAll(user.postes);
    seguindo.addAll(user.seguindo);
    seguidores.addAll(user.seguidores);
    post_perfil.addAll(user.post_perfil);
    seguidoresPendentes.addAll(user.seguidoresPendentes);

    dados.id = _dados.id;
    dados.tags = _dados.tags;
    dados.nome = _dados.nome;
    dados.foto = _dados.foto;
    dados.senha = _dados.senha;
    dados.email = _dados.email;
    dados.isTipster = _dados.isTipster;
    dados.tipname = _dados.tipname;
    dados.isPrivado = _dados.isPrivado;
    dados.endereco = _dados.endereco;
    dados.telefone = _dados.telefone;
    dados.bloqueado = _dados.bloqueado;
    dados.descricao = _dados.descricao;
    dados.nascimento = _dados.nascimento;
  }

  Map toMap() => {
//    "tags": tags,
    "dados": dados.toMap(),
    "seguidores": seguidores,
    "seguindo": seguindo,
    "seguidoresPendentes": seguidoresPendentes,
    "postes": postes,
    "tokens": tokens,
    "post_perfil": post_perfil
  };

  //region Metodos

  Future<bool> salvar() async {
    var reference = getFirebase.databaseReference();
    var result = await reference
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .set(toMap())
        .then((value) => true)
        .catchError((e) => false);

    if (!result)
      return result;

    result = await reference
        .child(FirebaseChild.IDENTIFICADOR)
        .child(dados.tipname)
        .set(dados.id)
        .then((value) => true)
        .catchError((e) => false);

    Log.d(TAG, 'salvar', result);
    return result;
  }

  Future<bool> logout() async {
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.TOKENS)
        .child(getFirebase.token.value)
        .remove()
        .then((value) => true)
        .catchError((e) => false);

    Log.d(TAG, 'logout', result);
    return result;
  }


  Future<bool> salvarToken(Token token) async {
    String child = token.device + '_' + token.data.substring(0, token.data.indexOf('.'));
    Log.d(TAG, 'salvarToken', child);
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.TOKENS)
        .child(child.trim())
        .set(token.toMap())
        .then((value) => true)
        .catchError((e) => false);

    Log.d(TAG, 'salvarToken', result);
    return result;
  }

  Future<bool> solicitarSerTipster() async {
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.SOLICITACAO_NOVO_TIPSTER)
        .child(dados.id)
        .set(dados.tipname)
        .then((value) => true)
        .catchError((e) => false);

    if (result) {
      String tag = UserTag.SOLICITACAO_SER_TIPSTER;
      await dados.addTag(tag);

      await habilitarTipster(true);
      dados.isTipster = true;
      bloquear();
    }

    Log.d(TAG, 'solicitarSerTipster', result);
    return result;
  }

  Future<bool> habilitarTipster(bool valor) async {
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.DADOS)
        .child(FirebaseChild.TIPSTER)
        .set(valor)
        .then((value) => true)
        .catchError((e) => false);

    if (result) {
      dados.isTipster = valor;
      await desbloquear();
    }

    Log.d(TAG, 'habilitarTipster', result);
    return result;
  }

  Future<bool> solicitarSerTipsterCancelar() async {
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.SOLICITACAO_NOVO_TIPSTER)
        .child(dados.id)
        .remove()
        .then((value) => true)
        .catchError((e) => false);

    if (!result)
      return result;


    String tag = UserTag.SOLICITACAO_SER_TIPSTER;
    await dados.removeTag(tag);

    await habilitarTipster(false);
    await desbloquear();
    dados.isTipster = false;

    Log.d(TAG, 'solicitarSerTipsterCancelar', result);
    return result;
  }

  bool solicitacaoEmAndamento() {
    return dados.tags.contains(UserTag.SOLICITACAO_SER_TIPSTER);
  }


  Future<bool> addSolicitacao(User user) async {
    String userId = user.dados.id;
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.SEGUIDORES_PENDENTES)
        .child(userId)
        .set(userId)
        .then((value) => true)
        .catchError((e) => false);

    if (result)
      seguidoresPendentes[userId] = userId;
    Log.d(TAG, 'addSolicitacao', result);
    return result;
//    MyNotificationManager.getInstance(context).sendSolicitacao(this);
  }

  Future<bool> removeSolicitacao(String userId) async {
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.SEGUIDORES_PENDENTES)
        .child(userId)
        .remove()
        .then((value) => true)
        .catchError((e) => false);

    seguidoresPendentes.remove(userId);
    Log.d(TAG, 'removeSolicitacao', result);
    return result;
  }

  Future<bool> addSeguindo(String userId) async {
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.SEGUINDO)
        .child(userId)
        .set(userId)
        .then((value) => true)
        .catchError((e) => false);

    Log.d(TAG, 'addSeguindo', result);
    return result;
  }

  Future<bool> removeSeguindo(String userId) async {
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.SEGUINDO)
        .child(userId)
        .remove()
        .then((value) => true)
        .catchError((e) => false);

    if (result)
      seguindo.remove(userId);
    Log.d(TAG, 'removeSeguindo', result);
    return result;
  }

  Future<bool> aceitarSeguidor(User user) async {
    String userId = user.dados.id;
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.SEGUIDORES)
        .child(userId)
        .set(userId)
        .then((value) => true)
        .catchError((e) => false);

    if (result) {
      user.addSeguindo(getFirebase.fUser().uid);
      seguidores[userId] = userId;
      await removeSolicitacao(userId);
//      MyNotificationManager.getInstance(context).sendSolicitacaoAceita(user);
    }
    Log.d(TAG, 'aceitarSeguidor', result);
    return result;
  }

  Future<bool> removeSeguidor(User punter) async {
    await punter.removeSeguindo(dados.id);
    String userId = punter.dados.id;
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.SEGUIDORES)
        .child(userId)
        .remove()
        .then((value) => true)
        .catchError((e) => false);

    if (result)
      seguidores.remove(userId);
    Log.d(TAG, 'removeSeguidor', result);
    return result;
  }


  Future<bool> bloquear() async {
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.DADOS)
        .child(FirebaseChild.BLOQUEADO)
        .set(true)
        .then((value) => true)
        .catchError((e) => false);

    if (result)
      dados.bloqueado = true;
    Log.d(TAG, 'bloquear', result);
    return result;
  }

  Future<bool> desbloquear() async {
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.DADOS)
        .child(FirebaseChild.BLOQUEADO)
        .set(false)
        .then((value) => true)
        .catchError((e) => false);

    if (result)
      dados.bloqueado = false;
    Log.d(TAG, 'desbloquear', result);
    return result;
  }

  Future<bool> excluir() async {
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .remove()
        .then((value) => true)
        .catchError((e) => false);

    if (result)
      for (Post item in postes.values)
        await item.excluir();
    Log.d(TAG, 'excluir', result);
    return result;
  }

  int bomCount() {
    int count = 0;
    for (Post p in postes.values) {
      count += p.bom.length;
    }
    return count;
  }
  int ruimCount()  {
    int count = 0;
    for (Post p in postes.values) {
      count += p.ruim.length;
    }
    return count;
  }

  double media() {
    double media;
    double mediaBom = 0;
    double mediaRuim = 0;
    double bom = 0;
    double ruim = 0;
    for (Post p in postes.values) {
      bom += p.bom.length;
      ruim += p.ruim.length;
    }
    if (postes.values.length > 0) {
      mediaBom = bom / postes.values.length;
      mediaRuim = ruim / postes.values.length;
    }
    media = mediaBom - mediaRuim;
    return media;
  }

  //endregion

  //region get set

  Map<String, PostPerfil> get post_perfil {
    if (_post_perfil == null)
      _post_perfil = Map();
    return _post_perfil;
  }

  set post_perfil(Map<String, PostPerfil> value) {
    _post_perfil = value;
  }

  Map<String, Token> get tokens => _tokens;

  set tokens(Map<String, Token> value) {
    _tokens = value;
  }

  Map<String, Post> get postes {
    if (_postes == null)
      _postes = Map();
    return _postes;
  }

  set postes(Map<String, Post> value) {
    _postes = value;
  }

  Map<dynamic, dynamic> get seguidoresPendentes {
    if (_seguidoresPendentes == null)
      _seguidoresPendentes = Map();
    return _seguidoresPendentes;
  }

  set seguidoresPendentes(Map<dynamic, dynamic> value) {
    _seguidoresPendentes = value;
  }

  Map<dynamic, dynamic> get seguindo {
    if (_seguindo == null)
      _seguindo = Map();
    return _seguindo;
  }

  set seguindo(Map<dynamic, dynamic> value) {
    _seguindo = value;
  }

  Map<dynamic, dynamic> get seguidores {
    if (_seguidores == null)
      _seguidores = Map();
    return _seguidores;
  }

  set seguidores(Map<dynamic, dynamic> value) {
    _seguidores = value;
  }

  UserDados get dados {
    if (_dados == null)
      _dados = UserDados();
    return _dados;
  }

  set dados(UserDados value) {
    _dados = value;
  }

  /*Map<String, String> get tags {
    if (_tags == null)
      _tags = Map();
    return _tags;
  }

  set tags(Map<String, String> value) {
    _tags = value;
  }*/

  //endregion

}