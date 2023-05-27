import '../utils/cache.dart' as cache;

class ClienteModel {
  String color;
  String beta;
  int sexo;

  dynamic idCliente;
  String idUrbe;
  dynamic celular;
  dynamic correo;
  dynamic nombres;
  dynamic apellidos;
  dynamic clave;
  dynamic cedula;
  dynamic cambiarClave;
  dynamic celularValidado;
  dynamic correoValidado;
  dynamic img;
  dynamic perfil;
  dynamic codigoPais;
  String link;
  String fechaNacimiento;
  String driverLicensePlate;
  String driverTradeMark;
  String driverModel;
  String typeVehicle;
  String token;

  dynamic calificacion;
  int calificaciones, registros, puntos, direcciones, correctos, canceladas;

  get acronimo {
    var acronimos = nombres.toString().split(' ');
    String first = acronimos.first.substring(0, 1);
    String last = acronimos.length > 1 ? acronimos[1].substring(0, 1) : '';
    return '$first$last'.toUpperCase();
  }

  ClienteModel({
    this.color: '',
    this.beta: 'null',
    this.sexo: 0,
    this.idCliente,
    this.idUrbe: '1',
    this.celular: '',
    this.correo: '',
    this.nombres: '',
    this.apellidos: '',
    this.clave: '***',
    this.cedula,
    this.cambiarClave,
    this.celularValidado: 1,
    this.correoValidado: 1,
    this.img: '',
    this.perfil:'0',
    this.codigoPais: '',
    this.calificacion: 0.0,
    this.calificaciones: 0,
    this.registros: 0,
    this.puntos: 0,
    this.direcciones: 1,
    this.correctos: 0,
    this.canceladas: 0,
    this.fechaNacimiento: '',
    this.driverLicensePlate:'',
    this.driverTradeMark:'',
    this.driverModel:'',
    this.link: '',
    this.typeVehicle:'',
    this.token
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) => ClienteModel(
        link: json["link"] == null ? '' : json["link"],
        idUrbe: json["id_urbe"] == null ? '1' : json["id_urbe"].toString(),
        beta: json["beta"],
        color: json["color"],
        sexo: json["sexo"],
        idCliente: json["id_cliente"],
        celular: json["celular"] == null ? '' : json["celular"],
        correo: json["correo"],
        nombres: json["nombres"],
        apellidos: json["apellidos"],
        cedula: json["cedula"],
        cambiarClave: json["cambiarClave"],
        celularValidado: json["celularValidado"],
        correoValidado: json["correoValidado"],
        img: cache.img(json["img"]),
        perfil: json["perfil"],
        codigoPais: json["codigoPais"],
        calificacion: json["calificacion"] == null ? 0.0 : json["calificacion"].toDouble(),
        calificaciones: json["calificaciones"],
        registros: json["registros"],
        puntos: json["puntos"],
        direcciones: json["direcciones"],
        correctos: json["correctos"],
        canceladas: json["canceladas"],
        fechaNacimiento: json["fecha_nacimiento"],
        driverLicensePlate: json["driverLicensePlate"],
        driverTradeMark: json["driverTradeMark"],
        driverModel: json["driverModel"],
        typeVehicle:json["typeVehicle"],
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "typeVehicle": typeVehicle,
        "link": link,
        "beta": beta,
        "color":color,
        "sexo": sexo,
        "id_cliente": idCliente,
        "celular": celular,
        "correo": correo,
        "nombres": nombres,
        "apellidos": apellidos,
        "cedula": cedula,
        "cambiarClave": cambiarClave,
        "celularValidado": celularValidado,
        "correoValidado": correoValidado,
        "img": img,
        "perfil": perfil,
        "codigoPais": codigoPais,
        "calificacion": calificacion,
        "calificaciones": calificaciones,
        "registros": registros,
        "puntos": puntos,
        "direcciones": direcciones,
        "correctos": correctos,
        "canceladas": canceladas,
        "fecha_nacimiento": fechaNacimiento,
        "driverLicensePlate":driverLicensePlate,
        "driverTradeMark": driverTradeMark,
        "driverModel":driverModel,
        "token":token
      };
}