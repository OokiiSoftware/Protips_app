class Endereco {

  String _pais;
  String _estado;
  String _cidade;
  String _bairro;
  String _numero;
  String _rua;
  String _cep;

  Endereco();

  Endereco.from(Map map) {
    pais = map['pais'];
    estado = map['estado'];
    cidade = map['cidade'];
    bairro = map['bairro'];
    numero = map['numero'];
    rua = map['rua'];
    cep = map['cep'];
  }

  void setEndereco(Endereco endereco) {
    pais = endereco.pais;
    estado = endereco.estado;
    cidade = endereco.cidade;
    bairro = endereco.bairro;
    rua = endereco.rua;
    cep = endereco.cep;
  }

  Map toMap() => {
      "Pais": _pais,
      "estado": _estado,
      "cidade": _cidade,
      "bairro": _bairro,
      "numero": _numero,
      "rua": _rua,
      "cep": _cep,
    };

  //region get set

  String get cep => _cep ?? '';

  set cep(String value) {
    _cep = value;
  }

  String get rua => _rua ?? '';

  set rua(String value) {
    _rua = value;
  }

  String get numero => _numero ?? '';

  set numero(String value) {
    _numero = value;
  }

  String get bairro => _bairro ?? '';

  set bairro(String value) {
    _bairro = value;
  }

  String get cidade => _cidade ?? '';

  set cidade(String value) {
    _cidade = value;
  }

  String get estado => _estado ?? '';

  set estado(String value) {
    _estado = value;
  }

  String get pais => _pais ?? '';

  set pais(String value) {
    _pais = value;
  }

  //endregion

}