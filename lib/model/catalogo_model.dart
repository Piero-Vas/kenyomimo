import '../utils/cache.dart' as cache;

class CatalogoModel {
  String link = '';
  dynamic idAgencia;
  dynamic idUrbe;
  dynamic idCategoria;
  dynamic idPromocion; //Promocion que se agrego por link profundo
  bool isPay;
  String agencia;
  String direccion;
  String observacion;
  String img;
  String label;
  String contacto;
  int resta;
  int tipo;
  int like;
  String hasta;
  String abiero;
  double promedioCalificacion;

  CatalogoModel({
    this.isPay: false,
    this.label: '',
    this.idPromocion: '0',
    this.idAgencia: 0,
    this.idCategoria,
    this.idUrbe,
    this.agencia,
    this.direccion,
    this.observacion,
    this.img,
    this.contacto,
    this.resta,
    this.tipo: 1,
    this.like: 0,
    this.hasta,
    this.abiero: '0',
    this.promedioCalificacion: 0.1,
  });

  factory CatalogoModel.fromJson(Map<String, dynamic> json) => CatalogoModel(
        isPay: json["isPay"] == null
            ? false
            : int.parse(json["isPay"]?.toString()) == 1,
        label: json["label"],
        idAgencia: json["id_agencia"],
        idUrbe: json["id_urbe"],
        agencia: json["agencia"],
        direccion: json["direccion"],
        tipo: json["tipo"] == null ? 1 : int.parse(json["tipo"]?.toString()),
        like: json["like"] == null ? 0 : int.parse(json["like"]?.toString()),
        observacion: json["observacion"],
        img: cache.img(json["img"]),
        contacto: json["contacto"],
        resta: json["resta"],
        hasta: json["hasta"],
        promedioCalificacion: json["promedioCalificacion"]??0.1,
        abiero: json["abiero"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id_agencia": idAgencia,
        "id_urbe": idUrbe,
        "agencia": agencia,
        "direccion": direccion,
        "observacion": observacion,
        "img": img,
        "tipo": tipo,
        "like": like,
        "contacto": contacto,
        "resta": resta,
        "hasta": hasta,
        "abiero": abiero,
        "idCategoria":idCategoria,
        "promedioCalificacion":promedioCalificacion,
      };
}