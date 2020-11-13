import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/aplication.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/user_pro.dart';
import 'package:protips/pages/denuncia_page.dart';
import 'package:protips/pages/perfil_page.dart';

class MyResources {
  static const String APP_NAME = 'ProTips';
  static const String app_email = 'app.protips@gmail.com';
  static const String app_instagram = '@protips.oki';
  static const String app_whatsapp = '(83) 99632-5982';
  static const String company_email = 'okisoftware@gmail.com';
  static const String company_name = 'ŌkīSoftware';
  static const String playStoryLink = 'https://play.google.com/store/apps/details?id=com.ookiisoftware.protips';

  static const String _merchantID = '07216026269368834349';
  static String get merchantID => _merchantID;

  //region stripe
  static final String _stripeKey = 'pk_live_51HbF49Kf3ZXGH4nWuoF0pffzesendEeLjyfNzTzwNKYuO0RJiR6Ied4PjWumH1CRj7b1gESIjq2ES9OsdD1FqV3K00Gq9HZWDP';
  static final String _stripeKeyTeste = 'pk_test_51HbF49Kf3ZXGH4nWCf91e4eawsBg5of1VQ8yYWZP6hTBgyAm4IlS8PxIwZJRop4ka0s9j9DqSFOBziGoNY03vhKM00FaBR9v2h';
  static final String _stripeSecretKey = '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';
  static final String _stripeSecretKeyTeste = 'sk_test_51HbF49Kf3ZXGH4nWyMvdzbsKIkitdVOSrUWwc822LWXzETjOcxtl8BDjswbCdHaWoLo7U4Ofe2FHxevAgcvSsGpq00iStHMHCX';

  static String get stripeKey => Aplication.isRelease ? _stripeKey : _stripeKeyTeste;
  static String get stripeSecretKey => Aplication.isRelease ? _stripeSecretKey : _stripeSecretKeyTeste;
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

class MyTooltips {
  static const String NOTIFICACOES = 'Nofiticações';
  static const String POSTAR_TIP = 'Postar Tip';
  static const String POSTAR_NO_PERFIL = 'Postar no perfil';
  static const String EDITAR_PERFIL = 'Editar perfil';
  static const String VOLTAR = 'Voltar';
  static const String CASH = 'Meus Ganhos';
}

class MyStrings {
  static const String whatsapp = 'Whatsapp';

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
  static const String LINK = 'Link para página';
  static const String CAMPEONATO = 'Campeonato';
  static const String SALVAR = 'Salvar';
  static const String NOME = 'Nome';
  static const String TIP_NAME = 'TipName';
  static const String EMAIL = 'Email';
  static const String TELEFONE = 'Telefone';
  static const String NASCIMENTO = 'Nascimento';
  static const String ESTADO = 'Estado';
  static const String PRIVACIDADE = 'Privacidade';
  static const String DESCRICAO_TIPS = 'Descreva sua tip...';
  static const String DESCRICAO_USER = 'Descreva sobre você';
  static const String PESQUISAR = 'Pesquisar';
  static const String DEFAULT = 'default';
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
  static const String solicitacao_filiado_mensagem = 'Não quero mais ser um Tipster na plataforma ProTips';
  static const String solicitacao_filiado = 'Cancelar conta';
  static const String EM_ANDAMENTO = 'Em Andamento';

  static const String DESENVOLVIDO_POR = "desenvolvido por";
  static const String ABRIR_IMAGEM = 'Trocar Foto';
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
  static const String GERENCIA = 'Gerência';
  static const String CONFIG = 'Configurações';

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

  static Future<void> onCliked(BuildContext context, String acao, {UserPro user}) async {
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
  static const ABRIR_INSTAGRAM = 'Erro ao abrir Instagram';
  static const ERRO_GENERICO = 'Ocorreu um erro';
  static const PERFIL_USER_SALVO = 'Erro ao salvar os dados';
  static const PAGAMENTO = 'Ops. Ocorreu um erro. Se o erro persistir entre em contato com o suporte.';
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
  static const CASH = 'FINANCEIRO';
  static const TELEFONE_PAGE = 'REGISTRAR TELEFONE';

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

  static List thema = [
    'Sistema', 'Claro', 'Escuro'
  ];

  static List get privacidade => ['Público', 'Privado'];

  static const List orderUsers = ['Ranking', 'Nome', 'Green', 'Red', 'Posts'];
}
