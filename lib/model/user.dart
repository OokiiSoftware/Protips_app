import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/denuncia.dart';
import 'package:protips/model/post.dart';
import 'package:protips/model/post_perfil.dart';
import 'package:protips/model/user_dados.dart';
import 'package:protips/auxiliar/log.dart';

class UserTag {
  static const String SOLICITACAO_SER_TIPSTER = 'solicitacao_tipster';
  static const String PRECO_PADRAO = 'default';
}

class UserPro {

  bool isExpanded = false;

  //region Variaveis
  static const String TAG = 'User';

  UserDados _dados;

  Map<dynamic, dynamic> _seguindo;
  Map<dynamic, dynamic> _seguidores;
  Map<dynamic, dynamic> _seguidoresPendentes;
  Map<dynamic, dynamic> _tags;

  Map<String, Post> _postes;
  Map<String, Denuncia> _denuncias;
  Map<String, PostPerfil> _postPerfil;

  //endregion

  //region Construtores

  UserPro() {
    tags = Map();
    postes = Map();
    seguindo = Map();
    denuncias = Map();
    seguidores = Map();
    postPerfil = Map();
    seguidoresPendentes = Map();
    dados = UserDados();
  }

  static Map<String, UserPro> fromJsonList(Map map) {
    Map<String, UserPro> items = Map();
    if (map == null) return items;

    for (String key in map.keys)
      items[key] = UserPro.fromJson(map[key]);

    return items;
  }

  UserPro.newUser(UserPro user) {
    UserDados _dados = user.dados;
    tags = Map();
    postes = Map();
    seguindo = Map();
    denuncias = Map();
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
    dados.diaPagamento = _dados.diaPagamento;
    dados.precoPadrao = _dados.precoPadrao;
  }

  UserPro.fromJson(Map<dynamic, dynamic> map) {
    if (_valueNoNull(map['dados']))
      dados = UserDados.fromJson(map['dados']);

    try {
      if (_valueNoNull(map['seguidoresPendentes']))
        seguidoresPendentes = map['seguidoresPendentes'];
    } catch (e) {
      Log.e(TAG, 'fromJson', e, 'seguidoresPendentes');
    }

    try {
      if (_valueNoNull(map['post_perfil']))
        postPerfil = PostPerfil.fromJsonList(map['post_perfil']);
    } catch (e) {
      Log.e(TAG, 'fromJson', e, 'post_perfil');
    }

    try {
      if (_valueNoNull(map['postes']))
        postes = Post.fromJsonList(map['postes']);
    } catch (e) {
      Log.e(TAG, 'fromJson', e, 'postes');
    }

    try {
      if (_valueNoNull(map['seguidores']))
        seguidores = map['seguidores'];
    } catch (e) {
      Log.e(TAG, 'fromJson', e, 'seguidores');
    }

    try {
      if (_valueNoNull(map['seguindo']))
        seguindo = map['seguindo'];
    } catch (e) {
      Log.e(TAG, 'fromJson', e, 'seguindo');
    }

    try {
      if (_valueNoNull(map['denuncias']))
        denuncias = Denuncia.fromJsonList(map['denuncias']);
    } catch (e) {
      Log.e(TAG, 'fromJson', e, 'denuncias');
    }

    try {
      if (_valueNoNull(map['tags']))
        tags = map['tags'];
    } catch (e) {
      Log.e(TAG, 'fromJson', e, 'tags');
    }
  }

  Map<String, dynamic> toJson() => {
    "tags": tags,
    "dados": dados.toJson(),
    "seguidores": seguidores,
    "seguindo": seguindo,
    "seguidoresPendentes": seguidoresPendentes,
    "postes": postes,
    "denuncias": denuncias,
    "post_perfil": postPerfil,
  };

  //endregion

  //region Metodos

  static bool _valueNoNull(dynamic value) => value != null;

  Future<bool> salvar() async {
    var reference = FirebasePro.database;
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

  Future<bool> refresh() async {
    Log.d(TAG, 'refresh', 'Init');

    try {
      UserPro item = await baixar(dados.id);
      if (item != null) {
        tags.clear();
        postes.clear();
        // tokens.clear();
        seguindo.clear();
        seguidores.clear();
        postPerfil.clear();
        seguidoresPendentes.clear();

        dados = item.dados;
        for (var key in item.tags.keys)
          tags[key] = item.tags[key];
        for (var key in item.postes.keys)
          postes[key] = item.postes[key];
        // for (var key in item.tokens.keys)
        //   tokens[key] = item.tokens[key];
        for (var key in item.seguindo.keys)
          seguindo[key] = item.seguindo[key];
        for (var key in item.seguidores.keys)
          seguidores[key] = item.seguidores[key];
        for (var key in item.postPerfil.keys)
          postPerfil[key] = item.postPerfil[key];
        for (var key in item.seguidoresPendentes.keys)
          seguidoresPendentes[key] = item.seguidoresPendentes[key];
        Log.d(TAG, 'refresh', 'OK');
        return true;
      }
      Log.d(TAG, 'refresh', 'NO OK', 'user == null');
      return false;
    } catch(e) {
      Log.e(TAG, 'refresh', e);
      return false;
    }
  }

  Future<bool> excluir() async {
    var result = await FirebasePro.database
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

  Future<bool> bloquear(bool valor) async {
    var result = await FirebasePro.database
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

  //region Token

  /*Future<bool> salvarToken(Token token) async {
    if (token == null)
      return false;
    Log.d(TAG, 'salvarToken', token.device);
    var result = await Firebase.databaseReference
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.TOKENS)
        .child(token.value)
        .set(token.toJson())
        .then((value) => true)
        .catchError((e) => false);

    await Firebase.databaseReference
        .child(FirebaseChild.TOKENS)
        .child(token.value)
        .set(dados.id)
        .then((value) => true)
        .catchError((e) => false);

    tokens[token.value] = token;

    Log.d(TAG, 'salvarToken', result);
    return result;
  }

  Future<bool> removeToken(String token) async {
    if (token == null)
      return false;
    //Remove do meu usuario
    var result = await Firebase.databaseReference
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.TOKENS)
        .child(token)
        .remove()
        .then((value) => true)
        .catchError((e) => false);

    //remove da lista geral de tokens
    await Firebase.databaseReference
        .child(FirebaseChild.TOKENS)
        .child(token)
        .remove()
        .then((value) => true)
        .catchError((e) => false);

    tokens.remove(token);

    Log.d(TAG, 'salvarToken', result);
    return result;
  }

  Future<bool> validarTokens() async {
    try {
      List<String> tokensAntigos = [];
      for (String token in tokens.keys) {
        var result = await Firebase.databaseReference
            .child(FirebaseChild.TOKENS)
            .child(token)
            .once()
            .then((value) => value)
            .catchError((e) => null);

        if (result == null || result.value.toString() != dados.id) {
          tokensAntigos.add(token);
        }
      }
      for (String token in tokensAntigos) {
        await removeToken(token);
        Log.d(TAG, 'validarToken', 'Removendo token antigo', token);
      }
      return true;
    } catch(e) {
      Log.e(TAG, 'validarToken', e);
      return false;
    }
  }*/

  //endregion

  //region Tipster

  Future<bool> solicitarSerTipster() async {
    var result = await FirebasePro.database
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

      EventListener.onSolicitacaoTipster(this);
    }

    Log.d(TAG, 'solicitarSerTipster', result);
    return result;
  }

  Future<bool> solicitarSerTipsterAprovar() async {
    if (await solicitarSerTipsterCancelar(true)) {
      EventListener.onSolicitacaoTipsterAceita(this);
      return await bloquear(false);
    }
    return false;
  }

  Future<bool> habilitarTipster(bool valor) async {
    var result = await FirebasePro.database
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

  Future<bool> solicitarSerTipsterCancelar([bool _habilitarTipster = false]) async {
    var result = await FirebasePro.database
        .child(FirebaseChild.SOLICITACAO_NOVO_TIPSTER)
        .child(dados.id)
        .remove()
        .then((value) => true)
        .catchError((e) => false);

    if (!result)
      return result;

    await removeTag(UserTag.SOLICITACAO_SER_TIPSTER);

    await habilitarTipster(_habilitarTipster);
//    await desbloquear();
    dados.isTipster = false;

    Log.d(TAG, 'solicitarSerTipsterCancelar', result);
    return result;
  }

  bool solicitacaoEmAndamento() {
    return tags.containsKey(UserTag.SOLICITACAO_SER_TIPSTER);
  }

  bool get isMyTipster => seguidores.containsKey(FirebasePro.user.uid);

  //endregion

  //region Filiado

  Future<bool> addSolicitacao(UserPro user) async {
    String userId = user.dados.id;
    var result = await FirebasePro.database
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.SEGUIDORES_PENDENTES)
        .child(userId)
        .set(userId)
        .then((value) => true)
        .catchError((e) => false);

    EventListener.onSolicitacaoFiliado(this);
    if (result)
      seguidoresPendentes[userId] = userId;
    Log.d(TAG, 'addSolicitacao', result);
    return result;
  }

  Future<bool> removeSolicitacao(String userId) async {
    var result = await FirebasePro.database
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
    var result = await FirebasePro.database
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
    var result = await FirebasePro.database
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

  Future<bool> aceitarSeguidor(UserPro user) async {
    String userId = user.dados.id;
    var result = await FirebasePro.database
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.SEGUIDORES)
        .child(userId)
        .set(UserTag.PRECO_PADRAO)
        .then((value) => true)
        .catchError((e) => false);

    EventListener.onSolicitacaoFiliadoAceita(this);
    if (result) {
      user.addSeguindo(FirebasePro.user.uid);
      seguidores[userId] = 0;
      await removeSolicitacao(userId);
    }
    Log.d(TAG, 'aceitarSeguidor', result);
    return result;
  }

  Future<bool> removeSeguidor(UserPro punter) async {
    await punter.removeSeguindo(dados.id);
    String userId = punter.dados.id;
    var result = await FirebasePro.database
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

  Future<bool> updateMensalidadeFiliado(String userId, String value) async {
    var result = await FirebasePro.database
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.SEGUIDORES)
        .child(userId)
        .set(value)
        .then((value) => true)
        .catchError((e) => false);

    if (result)
      seguidores[userId] = value;
    Log.d(TAG, 'updateMensalidade', result, userId, value);
    return result;
  }

  Future<String> pagamento(String tipsterID, String data) async {
    try {
      var snapshot = await FirebasePro.database
          .child(FirebaseChild.PAGAMENTOS)
          .child(tipsterID)
          .child(data)
          .child(dados.id)
          .once();
      return snapshot.value;
    } catch (e) {
      Log.e(TAG, 'pagamento', e);
      return null;
    }
  }

  //endregion

  //region add & remove

  Future<bool> addTag(String tag) async {
    var result = await FirebasePro.database
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
    var result = await FirebasePro.database
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


  Future<bool> removeDenuncia(String key) async {
    if (!denuncias.containsKey(key))
      return true;

    var result = await FirebasePro.database
        .child(FirebaseChild.USUARIO)
        .child(dados.id)
        .child(FirebaseChild.DENUNCIAS)
        .child(key)
        .remove()
        .then((value) => true)
        .catchError((e) => false);

    if (result)
      denuncias.remove(key);
    Log.d(TAG, 'removeDenuncia', result);
    return result;
  }

  //endregion

  //region greem red

  int get bomCount {
    int count = 0;
    for (Post p in postes.values) {
      count += p.bom.length;
    }
    return count;
  }
  int get ruimCount {
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

  static Future<UserPro> baixar(String uid) async {
    try {
      var snapshot = await FirebasePro.database
          .child(FirebaseChild.USUARIO).child(uid).once();
      if (snapshot.value == null)
        return null;
      return UserPro.fromJson(snapshot.value);
    } catch (e) {
      Log.e(TAG, 'baixar', e);
      return null;
    }
  }

  static Future<void> baixarList() async {
    try {
      var snapshot = await FirebasePro.database.child(FirebaseChild.USUARIO).once();
      Map<dynamic, dynamic> map = snapshot.value;

      getUsers.dd(fromJsonList(map));
      Log.d(TAG, 'baixarList', 'OK');
    } catch (e) {
      Log.e(TAG, 'baixarList', e);
    }
    // saveFotosPerfilLocal();
  }

  //endregion

  //region get set

  List<PostPerfil> get postPerfilList {
    List<PostPerfil> list = [];
    list.addAll(postPerfil.values..toList());
    return list..sort((a, b) => b.data.compareTo(a.data));
  }

  Map<String, PostPerfil> get postPerfil {
    if (_postPerfil == null)
      _postPerfil = Map();
    return _postPerfil;
  }

  set postPerfil(Map<String, PostPerfil> value) {
    _postPerfil = value;
  }

  // ignore: unnecessary_getters_setters
  // Map<String, Token> get tokens {
  //   if (_tokens == null)
  //     _tokens = Map();
  //   return _tokens;
  // }
  //
  // // ignore: unnecessary_getters_setters
  // set tokens(Map<String, Token> value) {
  //   _tokens = value;
  // }

  Map<String, Denuncia> get denuncias {
    if (_denuncias == null)
      _denuncias = Map();
    return _denuncias;
  }

  set denuncias(Map<String, Denuncia> value) {
    _denuncias = value;
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


  // Map<dynamic, dynamic> get comprasIDs {
  //   if (_comprasIDs == null)
  //     _comprasIDs = Map();
  //   return _comprasIDs;
  // }
  //
  // set comprasIDs(Map<dynamic, dynamic> value) {
  //   _comprasIDs = value;
  // }

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