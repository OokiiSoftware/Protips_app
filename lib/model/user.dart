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

//  bool _isExpanded = false;
//  bool get isExpanded => _isExpanded ?? false;
//  set isExpanded(bool value) {_isExpanded = value;}

  //region Variaveis
  static const String TAG = 'User';

  UserDados _dados;

  Map<dynamic, dynamic> _seguidores;
  Map<dynamic, dynamic> _seguindo;
  Map<dynamic, dynamic> _seguidoresPendentes;
  Map<dynamic, dynamic> _tags;

  Map<String, Post> _postes;
  Map<String, Token> _tokens;
  Map<String, PostPerfil> _postPerfil;

//  String postsPublicas;

  //endregion

  //region Construtores

  User() {
    tags = Map();
    seguindo = Map();
    seguidores = Map();
    postPerfil = Map();
    seguidoresPendentes = Map();
    postes = Map();
    dados = UserDados();
  }

  static Map<String, User> fromMapList(Map map) {
    Map<String, User> items = Map();
    if (map == null)
      return items;
    for (String key in map.keys)
      items[key] = User.fromJson(map[key]);
    return items;
  }

  User.newUser(User user) {
    UserDados _dados = user.dados;
    tags = Map();
    postes = Map();
    seguindo = Map();
    seguidores = Map();
    postPerfil = Map();
    seguidoresPendentes = Map();

    tags.addAll(user.tags);
    postes.addAll(user.postes);
    seguindo.addAll(user.seguindo);
    seguidores.addAll(user.seguidores);
    postPerfil.addAll(user.postPerfil);
    seguidoresPendentes.addAll(user.seguidoresPendentes);

    dados.id = _dados.id;
    dados.nome = _dados.nome;
    dados.foto = _dados.foto;
    dados.senha = _dados.senha;
    dados.email = _dados.email;
    dados.isTipster = _dados.isTipster;
    dados.tipname = _dados.tipname;
    dados.isPrivado = _dados.isPrivado;
    dados.endereco = _dados.endereco;
    dados.telefone = _dados.telefone;
    dados.isBloqueado = _dados.isBloqueado;
    dados.descricao = _dados.descricao;
    dados.nascimento = _dados.nascimento;
  }

  User.fromJson(Map<dynamic, dynamic> map) {
    dados = UserDados.fromJson(map['dados']);
    seguidoresPendentes = map['seguidoresPendentes'];
    postPerfil = PostPerfil.fromJsonList(map['post_perfil']);
    postes = Post.fromJsonList(map['postes']);
    seguidores = map['seguidores'];
    seguindo = map['seguindo'];
    tokens = Token.fromJsonList(map['tokens']);
    tags = map['tags'];
  }

  Map<String, dynamic> toJson() => {
    "tags": tags,
    "dados": dados.toJson(),
    "seguidores": seguidores,
    "seguindo": seguindo,
    "seguidoresPendentes": seguidoresPendentes,
    "postes": postes,
    "tokens": tokens,
    "post_perfil": postPerfil
  };

  //endregion

  //region Metodos

  Future<bool> salvar() async {
    var reference = getFirebase.databaseReference();
    var result = await reference
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .set(toJson())
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

  Future<bool> refresh() async {
    Log.d(TAG, 'refresh', 'Init');
    try {
      User item = await getUsers.baixarUser(dados.id);
      if (item != null) {
        dados = item.dados;
        seguidores = item.seguidores;
        seguidoresPendentes = item.seguidoresPendentes;
        seguindo = item.seguindo;
        tags = item.tags;
        postes = item.postes;
        postPerfil = item.postPerfil;
        tokens = item.tokens;
        Log.d(TAG, 'refresh', 'OK');
        return true;
      }
      Log.e(TAG, 'refresh', 'NO OK', 'user == null');
      return false;
    } catch(e) {
      Log.e(TAG, 'refresh', e);
      return false;
    }
  }


  Future<bool> salvarToken(Token token) async {
    Log.d(TAG, 'salvarToken', token.device);
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.TOKENS)
        .child(token.value)
        .set(token.toJson())
        .then((value) => true)
        .catchError((e) => false);

    Log.d(TAG, 'salvarToken', result);
    return result;
  }

  Future<bool> removeToken(String token) async {
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.TOKENS)
        .child(token)
        .remove()
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
      await addTag(tag);

      await habilitarTipster(true);
      dados.isTipster = true;
//      bloquear();
    }

    Log.d(TAG, 'solicitarSerTipster', result);
    return result;
  }

  Future<bool> habilitarTipster(bool valor) async {
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.DADOS)
        .child(FirebaseChild.IS_TIPSTER)
        .set(valor)
        .then((value) => true)
        .catchError((e) => false);

    if (result) {
      dados.isTipster = valor;
//      await desbloquear();
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
    await removeTag(tag);

    await habilitarTipster(false);
//    await desbloquear();
    dados.isTipster = false;

    Log.d(TAG, 'solicitarSerTipsterCancelar', result);
    return result;
  }

  bool solicitacaoEmAndamento() {
    return tags.containsKey(UserTag.SOLICITACAO_SER_TIPSTER);
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

    await getFirebase.notificationManager.sendSolicitacao(this);
    if (result)
      seguidoresPendentes[userId] = userId;
    Log.d(TAG, 'addSolicitacao', result);
    return result;
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

    await getFirebase.notificationManager.sendSolicitacaoAceita(user);
    if (result) {
      user.addSeguindo(getFirebase.fUser().uid);
      seguidores[userId] = userId;
      await removeSolicitacao(userId);
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


  Future<bool> addTag(String tag) async {
    if (tags.containsKey(tag))
      return null;

    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.TAGS)
        .child(tag)
        .set(tag)
        .then((value) => true)
        .catchError((e) => false);

    if (result)
      tags[tag] = tag;
    Log.d(TAG, 'addTag', result);
    return result;
  }

  Future<bool> removeTag(String tag) async {
    if (!tags.containsKey(tag))
      return null;

    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.TAGS)
        .child(tag)
        .remove()
        .then((value) => true)
        .catchError((e) => false);

    if (result)
      tags.remove(tag);
    Log.d(TAG, 'removeTag', result);
    return result;
  }


  Future<bool> bloquear(bool valor) async {
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.DADOS)
        .child(FirebaseChild.IS_BLOQUEADO)
        .set(valor)
        .then((value) => true)
        .catchError((e) => false);

    if (result)
      dados.isBloqueado = valor;
    Log.d(TAG, 'bloquear', result);
    return result;
  }

//  Future<bool> _desbloquear() async {
//    var result = await getFirebase.databaseReference()
//        .child(FirebaseChild.USUARIO)
//        .child(dados.id)
//        .child(FirebaseChild.DADOS)
//        .child(FirebaseChild.IS_BLOQUEADO)
//        .set(false)
//        .then((value) => true)
//        .catchError((e) => false);
//
//    if (result)
//      dados.isBloqueado = false;
//    Log.d(TAG, 'desbloquear', result);
//    return result;
//  }

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

  Map<String, PostPerfil> get postPerfil {
    if (_postPerfil == null)
      _postPerfil = Map();
    return _postPerfil;
  }

  set postPerfil(Map<String, PostPerfil> value) {
    _postPerfil = value;
  }

  // ignore: unnecessary_getters_setters
  Map<String, Token> get tokens {
    if (_tokens == null)
      _tokens = Map();
    return _tokens;
  }

  // ignore: unnecessary_getters_setters
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

  Map<dynamic, dynamic> get tags {
    if (_tags == null)
      _tags = Map();
    return _tags;
  }

  set tags(Map<dynamic, dynamic> value) {
    _tags = value;
  }

  //endregion

}