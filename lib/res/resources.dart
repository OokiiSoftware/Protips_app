import 'dart:ui';

import 'package:flutter/material.dart';

class SharedPreferencesKey {
  static const String EMAIL = "email";
  static const String ULTIMO_TOKEM = "ultimo_tokem";
}

class FirebaseChild {
  static const String IDENTIFICADOR = "identificadores";
  static const String USUARIO = "usuarios";
  static final String CONTATO = "contatos";
  static final String DADOS = "dados";
  static final String CONVERSAS = "conversas";

  static final String PERFIL = "perfil";
  static final String POSTES = "postes";
  static final String POSTES_PERFIL = "post_perfil";

  static final String SEGUIDORES_PENDENTES = "seguidoresPendentes";
  static final String TELEFONE = "telefone";

  static const String TAGS = 'tags';
  static const String LOGS = 'logs';

  static final String SOLICITACAO_NOVO_TIPSTER = "solicitacao_novo_tipster";
  static final String SEGUIDORES = "seguidores";
  static final String SEGUINDO = "seguindo";
  static final String BOM = "bom";
  static final String RUIM = "ruim";
  static final String ESPORTES = "esportes";
  static final String LINHAS = "linhas";
  //Use LINHAS
//  @deprecated
//  static final String MERCADOS = "mercados";
//  static final String BLOQUEADO = "bloqueado";
  static final String IS_BLOQUEADO = "isBloqueado";
  static final String ADMINISTRADORES = "administradores";
  static final String VERSAO = "versao";
  static final String APP = "app";
  static final String APK = "apk";
  static final String IOS = "ios";
  static final String IS_TIPSTER = "isTipster";
  static final String TOKENS = "tokens";
  static final String MESSAGES = "messages";
  static final String NOTIFICACOES = "notificacoes";
  static final String NOTIFICATIONS = "notifications";
  static final String AUTO_COMPLETE = "auto_complete";
  static final String CAMPEONATOS = "campeonatos";
}

class MyTooltips {
  static const String NOTIFICACOES = 'Nofiticações';
  static const String POSTAR_TIP = 'Postar Tip';
  static const String POSTAR_NO_PERFIL = 'Postar no perfil';
  static const String EDITAR_PERFIL = 'Editar perfil';
}

class MyStrings {
  static const String APP_NAME = 'ProTips';
  static const String app_email = 'protips@gmail.com';
  static const String app_whatsapp = '(88) 9996-4046';
  static const String company_email = 'okisoftware@gmail.com';

  static final String EXCLUIR = "Excluir";
  static final String BAIXANDO = "Baixando";
  static final String BAIXAR = "Baixar";
  static final String EXISTE = "Existe";
  static final String SIM = "Sim";
  static final String NAO = "Não";
  static final String MSG_EXCLUIR_POST_PERFIL = "Excluir este post permanentemente?";
  static const String VERIF_ATUALIZACAO = 'Verificando atualização';
  static const String BAIXAR_ATUALIZACAO = 'Baixar atualização';
  static const String AGUARDE = 'Aguarde..';
  static const String solicitacao_tipster = 'Solicitação para ser um Tipster';
  static const String solicitacao_tipster_mensagem = 'Entre em contato com\nEmail: ' + app_email + '\nWhatsApp: ';
  static const String solicitacao_filiado_mensagem = 'Não quero mais sem um Tipster';
  static const String solicitacao_filiado = 'Solicitação para ser um Filiado';

  static const String SOLICITAR = 'Solicitar';
  static const String OK = 'OK';

  static const String EM_ANDAMENTO = 'Em Andamento';

  static const String TIPSTER = 'Tipster';
  static const String TIPSTERS = 'Tipsters';
  static const String FILIADO = 'Filiado';
  static const String FILIADOS = 'Filiados';
  static const String ABRIR_IMAGEM = 'Abrir Imagem';
  static const String CONCLUIR = 'Concluir';
  static const String CANCELAR = 'Cancelar';
  static const String SEGUNDO_PLANO = 'Segundo Plano';
  static const String POSTAR = 'Postar';
  static const String TITULO = 'Titulo';
  static const String LEGENDA = 'Legenda';
  static const String CANCELAR_SOLICITACAO = 'Cancelar solicitação';

  static const String ANEXAR_IMAGEM = 'Anexar Imagem';
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
  static const String HORARIO_MINIMO = 'Horario Mínimo';
  static const String HORARIO_MAXIMO = 'Horario Máximo';
  static const String HORARIO_MINIMO_ENTRADA = 'Horario Mínimo para entrada';
  static const String HORARIO_MAXIMO_ENTRADA = 'Horario Máximo para entrada';
  static const String ESPORTE = 'Esporte';
  static const String LINHA = 'Linha';
  static const String LINK = 'Link';
  static const String CAMPEONATO = 'Campeonato';
  static const String TIP_PUBLICO = 'Tip Público';

  static const String SALVAR = 'Salvar';

  static const String NOME = 'Nome';
  static const String TIP_NAME = 'TipName';
  static const String EMAIL = 'Email';
  static const String TELEFONE = 'Telefone';
  static const String NASCIMENTO = 'Nascimento';
  static const String ESTADO = 'Estado';
  static const String PRIVACIDADE = 'Privacidade';
  static const String DESCRICAO = 'Descrição';
  static const String SOU_UM = 'Sou um';
  static const String PESQUISAR = 'Pesquisar';
  static const String QUERO_SER_TIPSTER = 'Quero ser um Tipster';
  static const String QUERO_SER_FILIADO = 'Quero ser um Filiado';

  static const String IDADE_MINIMA = 'Idade mínima é 18 anos';

  static const String MSG_USUARIO_SALVO = 'Dados Salvos';
  static const String MSG_USUARIO_SALVO_ERRO = 'Erro ao salvar os dados';
}

class MyColors {
  static const Color primary = Color.fromRGBO(0, 123, 164, 1);
  static const Color primaryLight = Color.fromRGBO(75, 166, 189, 1);
  static const Color primaryLight2 = Color.fromRGBO(112, 194, 226, 1);
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

class MyTexts {
  static const ORDEM_POR = 'Ordem por';
  static const EXCLUIR_POST_PERMANENTE = 'Excluir este post permanentemente?';
  static const SOLICITACAO_FILIAL = 'Solicitação de Filialdo';
  static const SOLICITACAO_ACEITA = 'Solicitação Aceita';
  static const NOVO_TIP = 'Novo Tip';
}

class MyMenus {

  static const String ATUALIZACAO = 'Verificar atualização';
  static const String MEU_PERFIL = 'Meu Perfil';
  static const String MEUS_POSTS = 'Meus Posts';
  static const String LOGOUT = 'Sair';

  static const ABRIR_LINK = 'Abrir link';
  static const ABRIR_WHATSAPP = 'Abrir WhatsApp';
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
}

class MyErros {
  static const ABRIR_LINK = 'Erro ao abrir link';
  static const ABRIR_WHATSAPP = 'Erro ao abrir WhatsApp';
  static const ERRO_GENERICO = 'Ocorreu um erro';
}

class MyIcons {

  static const String ic_launcher = 'assets/icons/ic_launcher.png';
  static const String ic_google = 'assets/icons/ic_google.png';
  static const String ic_person = 'assets/icons/ic_person.png';

  static const String ic_cash = 'assets/icons/ic_cash.png';
  static const String ic_download = 'assets/icons/ic_download.png';
  static const String ic_enter = 'assets/icons/ic_enter.png';
  static const String ic_lamp = 'assets/icons/ic_lamp.png';
  static const String ic_planilha = 'assets/icons/ic_planilha.png';
  static const String ic_sms = 'assets/icons/ic_sms.png';
  static const String ic_sms_2 = 'assets/icons/ic_sms_2.png';
  static const String ic_home_svg = 'assets/icons/ic_home.svg';
  static const String ic_home = 'assets/icons/ic_home.png';
  static const String ic_key = 'assets/icons/ic_key.png';
  static const String ic_negativo = 'assets/icons/ic_negativo.png';
  static const String ic_perfil = 'assets/icons/ic_perfil.png';
  static const String ic_perfil_svg = 'assets/icons/ic_perfil.svg';
  static const String ic_pesquisa = 'assets/icons/ic_pesquisa.png';
  static const String ic_pesquisa_svg = 'assets/icons/ic_pesquisa.svg';
  static const String ic_positivo = 'assets/icons/ic_positivo.png';
  static const String ic_image_broken = 'assets/icons/ic_image_broken.png';
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
  static const PROTIPS = 'PROTIPS';
  static const TIPSTERS = 'TIPSTERS';
  static const PERFIL = 'PERFIL';
  static const POST_TIP = 'POSTAR TIP';
  static const NOTIFICACOES = 'NOTIFICAÇÕES';

  static const String TITLE_MAIN = 'PROTIPS';
  static const String TITLE_ABOUT = 'SOBRE NÓS';


  static const main_page = [
    'PRO TIPS', 'TIPSTERS', 'PERFIL', 'NOTIFICAÇÕES'
  ];
  static const nav_titles_main = [
    'Início', 'Encontre', 'Perfil', 'Notificações'
  ];

}

class Arrays {
  static List estados = [
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

  static List privacidade = ['Público', 'Privado'];

  static const List orderUsers = ['Ranking', 'Nome', 'Green', 'Red', 'Posts'];
}
