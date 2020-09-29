import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/auxiliar/payment_service.dart';
import 'package:protips/model/post.dart';
import 'package:protips/model/post_perfil.dart';
import 'package:protips/model/user.dart';
import 'package:protips/model/user_dados.dart';
import 'package:protips/pages/denuncia_page.dart';
import 'package:protips/pages/perfil_page.dart';

class DialogResult {
  static int none = 0;
  static int cancel = 3;
  static int ok = 4;

  DialogResult(this.result);

  int result;
  bool get isOk => result == ok;
  bool get isCancel => result == cancel;
  bool get isNone => result == none;
}

class MyResources {
  //region square
  static final String _squareAppID = 'sq0idp-MvECrxIBwpuNJ9m8qQxnRQ';
  static String get squareAppID => _squareAppID;

  static final String _squareLocationID = 'LW0F0J0YVEEJT';
  static String get squareLocationID => _squareLocationID;

  static String _squareTokem = 'EAAAEC3GXtHmZlSRcmpUfP0i4ig225OyzNzDsQ86p4nxsLSuJlw7pFip_TCkln73';
  static String get squareToken => _squareTokem;
  //endregion

  static const String _merchantID = 'BCR2DN6TRO7IDZQU';
  static String get merchantID => _merchantID;

  static const String _revenueCatApi = 'VRRjFFOPMTWmsERpyrlnrSYjygsnLPiZ';
  static String get revenueCatApi => _revenueCatApi;

  static String _picPayTokem = 'd85a521e-85ad-46cc-ba01-5c49a8d68db6';
  static String get picPayToken => _picPayTokem;

  //region stripe
  static final String _stripeID = 'pk_live_51HGkODJw3SRUGsteYNHlXKCq1djfq7KlMmIFNSAoUy8HBBK3wARVbaQKboRTNNAgn1Fe1QJyz5Llb60iq1NwFYQy00GVfJMspD';
  static String get stripeID => _stripeID;

  static final String _stripeIDTeste = 'pk_test_51HGkODJw3SRUGsteCiTxv5nQXx3AS4qEBYhvYG6tLyBz8tTgXquWLpUtERw7ne4IMpRX9ITwiFX0Fr1y1pxZM60I00isA6r0Io';
  static String get stripeIDTeste => _stripeIDTeste;
  //endregion
}

class GoogleProductsID {
  static const Map<String, String> precos = {
    '10': '10,00',
    '15': '15,00',
    '20': '20,00',
    '25': '25,00',
    '30': '30,00',
    '35': '35,00',
    '40': '40,00',
    '45': '45,00',
    '50': '50,00',
    '55': '55,00',
    '60': '60,00',
    '65': '65,00',
    '70': '70,00',
    '75': '75,00',
    '80': '80,00',
    '85': '85,00',
    '90': '90,00',
    '95': '95,00',

    '100': '100,00',
    '105': '105,00',
    '110': '110,00',
    '115': '115,00',
    '120': '120,00',
    '125': '125,00',
    '130': '130,00',
    '135': '135,00',
    '140': '140,00',
    '145': '145,00',
    '150': '150,00',
    '155': '155,00',
    '160': '160,00',
    '165': '165,00',
    '170': '170,00',
    '175': '175,00',
    '180': '180,00',
    '185': '185,00',
    '190': '190,00',
    '195': '195,00',

    '200': '200,00',
  };
  /*
    '205': '205,00',
    '210': '210,00',
    '215': '215,00',
    '220': '220,00',
    '225': '225,00',
    '230': '230,00',
    '235': '235,00',
    '240': '240,00',
    '245': '245,00',
    '250': '250,00',
    '255': '255,00',
    '260': '260,00',
    '265': '265,00',
    '270': '270,00',
    '275': '275,00',
    '280': '280,00',
    '285': '285,00',
    '290': '290,00',
    '295': '295,00',
  * */
}

class SharedPreferencesKey {
  static const String EMAIL = "email";
  static const String DIA_PAGAMENTO = "dia_pagamento";
  static const String ULTIMO_TOKEM = "ultimo_tokem";
  static const String ULTIMO_TUTORIAL_OK = "01";
}

class FirebaseChild {
  static const String IDENTIFICADOR = "identificadores";
  static const String USUARIO = "usuarios";
  static const String CONTATO = "contatos";
  static const String DADOS = "dados";
  static const String CONVERSAS = "conversas";

  static const String PERFIL = "perfil";
  static const String POSTES = "postes";
  static const String POSTES_PERFIL = "post_perfil";

  static const String SEGUIDORES_PENDENTES = "seguidoresPendentes";
  static const String TELEFONE = "telefone";

  static const String TAGS = 'tags';
  static const String LOGS = 'logs';
  static const String PAGAMENTOS = 'pagamentos';
  static const String DENUNCIAS = 'denuncias';
  static const String COMPRAS_IDS = 'comprasIDs';

  static const String SOLICITACAO_NOVO_TIPSTER = "solicitacao_novo_tipster";
  static const String SEGUIDORES = "seguidores";
  static const String SEGUINDO = "seguindo";
  static const String BOM = "bom";
  static const String RUIM = "ruim";
  static const String ESPORTES = "esportes";
  static const String LINHAS = "linhas";
  //Use LINHAS
//  @deprecated
//  static final String MERCADOS = "mercados";
//  static final String BLOQUEADO = "bloqueado";
  static const String IS_BLOQUEADO = "isBloqueado";
  static const String ADMINISTRADORES = "administradores";
  static const String VERSAO = "versao";
  static const String APP = "app";
  static const String APK = "apk";
  static const String IOS = "ios";
  static const String IS_TIPSTER = "isTipster";
  static const String TOKENS = "tokens";
  static const String MESSAGES = "messages";
  static const String NOTIFICACOES = "notificacoes";
  static const String NOTIFICATIONS = "notifications";
  static const String AUTO_COMPLETE = "auto_complete";
  static const String CAMPEONATOS = "campeonatos";

  static const String CARDS = 'cards';
}

class MyTooltips {
  static const String NOTIFICACOES = 'Nofiticações';
  static const String POSTAR_TIP = 'Postar Tip';
  static const String POSTAR_NO_PERFIL = 'Postar no perfil';
  static const String EDITAR_PERFIL = 'Editar perfil';
  static const String VOLTAR = 'Voltar';
  static const String CASH = 'Meus Ganhos';
}

class MyStrings {
  static const String APP_NAME = 'ProTips';
  static const String app_email = 'app.protips@gmail.com';
  static const String app_whatsapp = '(88) 9996-4046';
  static const String whatsapp = 'Whatsapp';
  static const String company_email = 'okisoftware@gmail.com';
  static const String company_name = 'ŌkīSoftware';

  static const String ATENCAO = "Atenção";
  static const String FECHAR = "Fechar";
  static const String MOTIVO = "Motivo";
  static const String VERSAO = "Versão";
  static const String CONTATOS = "contatos";
  static const String ITEM = "ITEM";
  static const String VALOR = "VALOR";
  static const String POR = "por";
  static const String EXCLUIR = "Excluir";
  static const String BAIXANDO = "Baixando";
  static const String BAIXAR = "Baixar";
  static const String EXISTE = "Existe";
  static const String SIM = "Sim";
  static const String NAO = "Não";
  static const String AGUARDE = 'Aguarde..';

  static const String SOLICITAR = 'Solicitar';
  static const String OK = 'OK';

  static const String TIPSTER = 'Tipster';
  static const String TIPSTERS = 'Tipsters';
  static const String FILIADO = 'Filiado';
  static const String FILIADOS = 'Filiados';
  static const String CONCLUIR = 'Concluir';
  static const String CANCELAR = 'Cancelar';
  static const String POSTAR = 'Postar';
  static const String TITULO = 'Titulo';
  static const String LEGENDA = 'Legenda';
  static const String ODD_MINIMA = 'Odd Mínima';
  static const String ODD_MAXIMA = 'Odd Máxima';
  static const String ODD_ATUAL = 'Odd Atual';
  static const String CATEGORIA = 'Categoria';
  static const String UNIDADES = 'Unidades';
  static const String MINIMO = 'Mínimo';
  static const String MAXIMO = 'Máximo';
  static const String ODD = 'Odd';
  static const String HORARIO = 'Horário';
  static const String ZERO_HORA = '00:00';
  static const String ESPORTE = 'Esporte';
  static const String LINHA = 'Linha';
  static const String LINK = 'Link';
  static const String CAMPEONATO = 'Campeonato';
  static const String SALVAR = 'Salvar';
  static const String NOME = 'Nome';
  static const String TIP_NAME = 'TipName';
  static const String EMAIL = 'Email';
  static const String TELEFONE = 'Telefone';
  static const String NASCIMENTO = 'Nascimento';
  static const String ESTADO = 'Estado';
  static const String PRIVACIDADE = 'Privacidade';
  static const String DESCRICAO = 'Descrição';
  static const String PESQUISAR = 'Pesquisar';
  static const String DEFAULT = 'default';
}

class MyLayouts {

  static Future<DialogResult> dialogCancelOK(BuildContext context, {String title, Widget content, EdgeInsets contentPadding}) async {
    return await _dialogAux(context, title: title, content: content, contentPadding: contentPadding);
  }

  static Future<DialogResult> dialogOK(BuildContext context, {String title, Widget content, EdgeInsets contentPadding}) async {
    return await _dialogAux(context, title: title, content: content, contentPadding: contentPadding, cancelButton: false);
  }
  static Future<DialogResult> _dialogAux(BuildContext context, {String title, Widget content, EdgeInsets contentPadding, bool okButton = true, bool cancelButton = true, bool noneButton = false}) async {
    if(contentPadding == null)
      contentPadding = EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0);
    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: title == null ? null : Text(title),
          content: content,
          contentPadding: contentPadding,
          actions: [
            if (noneButton) FlatButton(
                child: Text(MyStrings.FECHAR),
                onPressed: () => Navigator.pop(context, DialogResult(DialogResult.none)),
              ),
            if (cancelButton) FlatButton(
                child: Text(MyStrings.CANCELAR),
                onPressed: () => Navigator.pop(context, DialogResult(DialogResult.cancel)),
              ),
            if (okButton) FlatButton(
                child: Text(MyStrings.OK),
                onPressed: () => Navigator.pop(context, DialogResult(DialogResult.ok)),
              ),
          ],
        )
    ) ?? false;
  }

  static Future<void> showPopupPostPerfil(BuildContext context, PostPerfil item) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            insetPadding: EdgeInsets.all(10),
            content: GestureDetector(
              child: fotoPostNetwork(item.foto),
              onTapUp: (value) {
                Navigator.pop(context);
              },
            ),
          );
        }
    );
  }

  static Widget splashScreen() {
    double iconSize = 200;
    var backColor = Color.fromRGBO(4, 68, 118, 1);

    return Scaffold(
        backgroundColor: backColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(MyAssets.ic_launcher_adaptive, width: iconSize, height: iconSize),
            Padding(padding: EdgeInsets.only(top: 20)),
            Text(MyStrings.APP_NAME, style: TextStyle(fontSize: 25, color: MyTheme.textColor())),
            LinearProgressIndicator(backgroundColor: backColor)
          ],
        )
    );
  }

  //Foto e Dados
  static Widget fotoEDados(User user) {
    bool isTipster = user.dados.isTipster;
    Color itemColor = MyTheme.primaryLight2();
    var headItemPadding = Padding(padding: EdgeInsets.only(left: 3));
    var itemTextStyle = TextStyle(color: MyTheme.textColor(), fontSize: 15);

    return Row(children: [
        //Foto
        Container(
            height: 90,
            width: 90,
            child: iconFormatUser(
                radius: 100,
                child: fotoUser(user.dados)
            )
        ),
        Padding(padding: EdgeInsets.only(right: 5)),
        //Dados
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Nome
            Row(
              children: [
                Icon(Icons.person, color: itemColor),
                headItemPadding,
                Text(user.dados.nome, style: itemTextStyle)
              ],
            ),
            //TipName
            Row(
              children: [
                Icon(Icons.language, color: itemColor),
                headItemPadding,
                Text(user.dados.tipname, style: itemTextStyle)
              ],
            ),
            //Filiados
            Row(
              children: [
                Icon(Icons.group, color: itemColor),
                headItemPadding,
                Text((isTipster ? MyStrings.FILIADOS : MyStrings.TIPSTERS) + ': ' + (isTipster ? user.seguidores : user.seguindo).values.length.toString(), style: itemTextStyle)
              ],
            ),
          ],
        ),
      ]);
  }

  static Widget customAppBar(BuildContext context, {args, Widget icon}) {
    return Row(children: [
      Tooltip(
        message: 'Voltar',
        child: GestureDetector(
          child: Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.arrow_back),
          ),
          onTap: () => Navigator.pop(context, args),
        ),
      ),
      Expanded(child: Text(Titles.PERFIL_FILIADO)),
      if (icon != null) icon,
    ]);
  }

  static FlatButton btnPagamento({String valor = '', @required User tipster}) {
    var text = 'Realizar Pagamento';
    if (valor.isNotEmpty)
      text += ' $valor';

    return FlatButton(
      child: Text(text),
      color: Colors.green[800],
      textColor: Colors.white,
      onPressed: () {
        PaymentService.novoPagamento(tipster);
      },
    );
  }

  //region Fotos layouts
  static Widget iconFormatUser({Widget child, double radius = 0}) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius/3),
      ),
      child: child,
    );
  }

  static Widget fotoUser(UserDados item, {double iconSize, BoxFit fit}) {
    bool fotoLocal = item.fotoLocalExist;
    if (fotoLocal) {
      return fotoUserFile(item.fotoToFile, iconSize: iconSize, fit: fit);
    } else {
      if (item.foto.isEmpty)
        return icPersonOnError(iconSize);
      return fotoUserNetwork(item.foto, iconSize: iconSize, fit: fit);
    }
  }
  static Widget fotoPost(Post item, [double iconSize]) {
    bool fotoLocal = item.fotoLocalExist;
    if (fotoLocal) {
      return fotoPostFile(item.fotoToFile, iconSize);
    } else {
      return fotoPostNetwork(item.foto, iconSize);
    }
  }

  static Widget fotoUserFile(File file, {double iconSize, BoxFit fit}) => Image.file(file, fit: fit, width: iconSize, height: iconSize);
  static Widget fotoUserNetwork(String url, {double iconSize, BoxFit fit}) =>
      Image.network(url, fit: fit, width: iconSize, height: iconSize, loadingBuilder: (context, widget, progress) {
        if (progress == null) return widget;
        return CircularProgressIndicator(value: (progress.expectedTotalBytes == null) ? null : progress.cumulativeBytesLoaded/progress.expectedTotalBytes);
      }, /*errorBuilder: (c, u, e) => icPersonOnError(iconSize)*/);

  static Widget fotoPostFile(File file, [double iconSize]) => Image.file(file, width: iconSize, height: iconSize, errorBuilder: (c, u, e) => icPostOnError());
  static Widget fotoPostNetwork(String url, [double iconSize]) =>
      Image.network(url, width: iconSize, height: iconSize, errorBuilder: (c, u, e) => icPostOnError(),
          loadingBuilder: (context, widget, progress) {
        if (progress == null) return widget;
        return CircularProgressIndicator(value: (progress.expectedTotalBytes == null) ? null : progress.cumulativeBytesLoaded/progress.expectedTotalBytes);
      });

  static Widget icPersonOnError(double iconSize) => Image.asset(MyAssets.ic_person_light, width: iconSize, height: iconSize);
  static Widget icPostOnError([double iconSize]) => Image.asset(MyAssets.ic_image_broken, width: iconSize, height: iconSize);

  //endregion
}

class MyColors {
  static const Color primary = Color.fromRGBO(0, 123, 164, 1);
  static const Color primaryLight = Color.fromRGBO(70, 181, 190, 1);
  static const Color primaryLight2 = Color.fromRGBO(156, 215, 221, 1);
  static const Color primaryDark = Color.fromRGBO(0, 106, 142, 1);
  static const Color accent = Color.fromRGBO(255, 201, 9, 1);
  static const Color background = Colors.white;
  static Color transparentColor(double alpha) => Color.fromRGBO(0, 0, 0, alpha);

  static  Color textLight = Colors.white;
  static  Color textLightInvert(double alfa) => Color.fromRGBO(0, 0, 0, alfa);
  static  Color textColorError(double alfa) => Color.fromRGBO(245, 0, 0, alfa);
  static  Color textSubtitleLight = Colors.white54;
  static  Color tintLight = Colors.white;
  static  Color tintLight2 = Color.fromRGBO(222, 229, 237, 1);
}

class MyAssets {

  static const String ic_launcher = 'assets/icons/ic_launcher.png';
  static const String ic_launcher_adaptive = 'assets/icons/ic_launcher_adaptive.png';
  static const String ic_google = 'assets/icons/ic_google.png';
  static const String ic_person = 'assets/icons/ic_person.png';
  static const String ic_person_light = 'assets/icons/ic_person_light.png';

  static const String ic_cash = 'assets/icons/ic_cash.png';
  static const String ic_add = 'assets/icons/ic_add.png';
//  static const String ic_download = 'assets/icons/ic_download.png';
//  static const String ic_enter = 'assets/icons/ic_enter.png';
  static const String ic_lamp = 'assets/icons/ic_lamp.png';
//  static const String ic_lamp_p = 'assets/icons/ic_lamp_p.png';
  static const String ic_planilha = 'assets/icons/ic_planilha.png';
  static const String ic_sms = 'assets/icons/ic_sms.png';
  static const String ic_sms_2 = 'assets/icons/ic_sms_2.png';
//  static const String ic_home_svg = 'assets/icons/ic_home.svg';
//  static const String ic_home = 'assets/icons/ic_home.png';
//  static const String ic_key = 'assets/icons/ic_key.png';
  static const String ic_negativo = 'assets/icons/ic_negativo.png';
//  static const String ic_perfil = 'assets/icons/ic_perfil.png';
//  static const String ic_perfil_svg = 'assets/icons/ic_perfil.svg';
//  static const String ic_pesquisa = 'assets/icons/ic_pesquisa.png';
//  static const String ic_pesquisa_svg = 'assets/icons/ic_pesquisa.svg';
  static const String ic_positivo = 'assets/icons/ic_positivo.png';
  static const String ic_image_broken = 'assets/icons/ic_image_broken.png';

  static const String img_tutorial = 'assets/icons/img_tutorial.png';

}

class MyTexts {
  static const ORDEM_POR = 'Ordem por';
  static const ATENCAO = 'Atenção';
  static const PERFIL_USER_SALVO = 'Dados salvos';
  static const EXCLUIR_POST_PERMANENTE = 'Excluir este post permanentemente?';
  static const SOLICITACAO_FILIADO = 'Solicitação de Filiado';
  static const SOLICITACAO_TIPSTER = 'Solicitação Tipster';
  static const SOLICITACAO_ACEITA = 'Solicitação Aceita';
  static const REALIZAR_PAGAMENTO = 'Realize o pagamento deste mês para visualizar este TIP';
  static const NOVO_TIP = 'Nova Tip';
  static const DADOS_SALVOS = 'Dados Salvos';

  static const String VC_FOI_DENUNCIADO = "Você foi denunciado";
  static const String PAGAMENTO_REALIZADO = "Você recebeu um pagamento";
  static const String MSG_EXCLUIR_POST_PERFIL = "Excluir este post permanentemente?";
  static const String VERIF_ATUALIZACAO = 'Verificando atualização';
  static const String BAIXAR_ATUALIZACAO = 'Baixar atualização';
  static const String solicitacao_tipster = 'Solicitação para ser um Tipster';
  static const String solicitacao_tipster_mensagem = 'entre em contato\nEmail:';
  static const String solicitacao_filiado_mensagem = 'Não quero mais sem um Tipster na plataforma ProTips.';
  static const String solicitacao_filiado = 'Cancelar minha conta';
  static const String EM_ANDAMENTO = 'Em Andamento';

  static const String DESENVOLVIDO_POR = "desenvolvido por";
  static const String ABRIR_IMAGEM = 'Selecionar Imagem';
  static const String SEGUNDO_PLANO = 'Segundo Plano';
  static const String CANCELAR_SOLICITACAO = 'Cancelar solicitação';
  static const String ANEXAR_IMAGEM = 'Anexar Imagem';
  static const String HORARIO_MINIMO = 'Horario Mínimo';
  static const String HORARIO_MAXIMO = 'Horario Máximo';
  static const String HORARIO_MINIMO_ENTRADA = 'Horario Mínimo para entrada';
  static const String HORARIO_MAXIMO_ENTRADA = 'Horario Máximo para entrada';
  static const String TIP_PUBLICO = 'Tip Público';

  static const String SOU_UM = 'Sou um';
  static const String PRECO_PADRAO = 'Preço padrão de suas Tips';
  static const String QUERO_SER_TIPSTER = 'Quero ser um Tipster';
  static const String CANCELAR_CONTA_TIPSTER = 'Cancelar conta Tipster';

  static const String IDADE_MINIMA = 'Idade mínima é 18 anos';
  static const String LIMPAR_TUDO = 'Limpar tudo';
}

class MyMenus {

  static const String ATUALIZACAO = 'Verificar atualização';
  static const String MEU_PERFIL = 'Meu Perfil';
  static const String MEUS_FILIADOS = 'Meus Filiados';
  static const String MEUS_TIPSTERS = 'Meus Tipsters';
  static const String MEUS_POSTS = 'Meus Posts';
  static const String LOGOUT = 'Sair';
  static const String SOBRE = 'Sobre';
  static const String PAGAMENTO = 'Pagamento';
  static const String TUTORIAL = 'Tutorial';
  static const String GERENCIA = 'Gerencia';

  static const ABRIR_LINK = 'Abrir link';
  static const ABRIR_WHATSAPP = 'WhatsApp';
  static const EXCLUIR = 'Excluir';
  static const DENUNCIAR = 'Denunciar';

  static const List<String> meuPost = <String>[
    ABRIR_LINK, EXCLUIR
  ];
  static const List<String> post = <String>[
    ABRIR_LINK, EXCLUIR, DENUNCIAR
  ];
  static const List<String> perfilPage = <String>[
    ABRIR_WHATSAPP, DENUNCIAR
  ];

  static Future<void> onCliked(BuildContext context, String acao, {User user}) async {
    switch(acao) {
      case MyMenus.ABRIR_WHATSAPP:
        if (user != null)
          Import.openWhatsApp(user.dados.telefone, context);
        break;
      case MyMenus.DENUNCIAR:
        if (user != null)
          Navigate.to(context, DenunciaPage.User(user));
        break;
      case MyMenus.MEU_PERFIL:
        await Navigate.to(context, PerfilPage());
        break;
    }
  }
}

class MyErros {
  static const ABRIR_LINK = 'Erro ao abrir link';
  static const ABRIR_EMAIL = 'Erro ao abrir o email';
  static const ABRIR_WHATSAPP = 'Erro ao abrir WhatsApp';
  static const ERRO_GENERICO = 'Ocorreu um erro';
  static const PERFIL_USER_SALVO = 'Erro ao salvar os dados';
}

class MyTheme {
  static Color primary() => MyColors.primary;
  static Color primaryLight() => MyColors.primaryLight;
  static Color primaryLight2() => MyColors.primaryLight2;
  static Color primaryDark() => MyColors.primaryDark;
  static Color accent() => MyColors.accent;

  static Color textColor() => MyColors.textLight;
  static Color textColorInvert([double alfa = 1]) => MyColors.textLightInvert(alfa);
  static Color textColorError([double alfa = 1]) => MyColors.textColorError(alfa);
  static Color textSubtitleColor() => MyColors.textSubtitleLight;
  static Color tintColor() => MyColors.tintLight;
  static Color tintColor2() => MyColors.tintLight2;
  static Color backgroundColor() => MyColors.background;
  static Color transparentColor([double alpha = 0]) => MyColors.transparentColor(alpha);
}

class Titles {
  static const MEU_PERFIL = 'MEU PERFIL';
  static const MEUS_FILIADOS = 'MEUS FILIADOS';
  static const MEUS_TIPSTRES = 'MEUS TIPSTRES';
  static const PROTIPS = 'PROTIPS';
  static const TIPSTERS = 'TIPSTERS';
  static const PERFIL = 'PERFIL';
  static const PERFIL_TIPSTER = 'PERFIL TIPSTER';
  static const PERFIL_FILIADO = 'PERFIL FILIADO';
  static const GERENCIA = 'GERENCIA';
  static const POST_TIP = 'POSTAR TIP';
  static const NOTIFICACOES = 'NOTIFICAÇÕES';
  static const RECUPERAR_SENHA = 'Recuperar Senha';
  static const DENUNCIA_USER = 'DENUNCIAR USUÁRIO';
  static const DENUNCIA_POST = 'DENUNCIAR POST';
  static const PAGAMENTO = 'PAGAMENTO';
  static const CONFIGURACOES = 'CONFIGURAÇÕES';
  static const CASH = 'MEUS GANHOS';

  static const String MAIN = 'PROTIPS';
  static const String ABOUT = 'SOBRE NÓS';


  static const gerencia_page = [
    'SOLICITAÇÕES', 'DENUNCIAS', 'LISTA DE ERROS', 'CONFIGURAÇÕES',
  ];
  static const main_page = [
    'PRO TIPS', 'TIPSTERS', 'PERFIL'
  ];
  static const nav_titles_main = [
    'Início', 'Encontre', 'Perfil', 'Notificações'
  ];
  static const nav_titles_gerencia = [
    'Solicitações', 'Denuncias', 'Logs', 'Config'
  ];

}

class Arrays {
  static List get estados => [
    'Acre', 'Amapá', 'Amazonas',
    'Bahia',
    'Ceará',
    'Distrito Federal',
    'Espírito Santo',
    'Goiás',
    'Maranhão', 'Mato Grosso', 'Mato Grosso do Sul', 'Minas Gerais',
    'Pará', 'Paraíba', 'Paraná', 'Pernambuco', 'Piauí',
    'Rio de Janeiro', 'Rio Grande do Norte', 'Rio Grande do Sul', 'Rondônia', 'Roraima',
    'Santa Catarina', 'São Paulo', 'Sergipe',
    'Tocantins',
  ];

  static List get privacidade => ['Público', 'Privado'];

  static const List orderUsers = ['Ranking', 'Nome', 'Green', 'Red', 'Posts'];
}
