import 'dart:convert';

import '../utils/cache.dart' as img;

//Promocion se almmacena en base version tneer en cuenta
class PromocionModel {
  dynamic idAgencia;
  dynamic idPromocion;
  dynamic idUrbe;
  String link = '';
  dynamic incentivo;
  String incentivoPrevio;
  dynamic producto;
  dynamic descripcion;
  dynamic precio;
  dynamic imagen;
  dynamic minimo;
  dynamic maximo;
  Productos productos;

  int aprobado;
  int destacado;
  int promocion;
  int estado;
  String mensaje;

  dynamic idProducto;
  List<String> idsProductos = [];

  int tipo;
  String inventario;
  String dt;
  String contactoEntrega;
  bool isComprada;
  int cantidad;
  int activo;
  int visible;
  dynamic costo;
  String tiempo_preparacion;
  bool tieneDescuento;
  double descuento;

  get costoTotalDescuento => tieneDescuento ? cantidad * ((precio * (100-descuento))/100) : -1;
  get costoTotal => cantidad * precio;
  get precioPromocion => (precio * (100-descuento))/100;
  bool isComproProductos() {
    return idsProductos.length > 0;
  }

  PromocionModel({
    this.incentivoPrevio,
    this.tieneDescuento: false,
    this.descuento: 0.0,
    this.aprobado: 1,
    this.promocion: 0,
    this.estado: 1, //1 Es activo
    this.destacado: 0,
    this.mensaje: 'Agotado',
    this.productos,
    this.idAgencia,
    this.idPromocion,
    this.idUrbe,
    this.incentivo,
    this.producto,
    this.descripcion,
    this.precio: 0.0,
    this.imagen,
    this.minimo,
    this.maximo,
    this.isComprada: false,
    this.tipo: 1,
    this.cantidad: 1,
    this.costo: 0.0,
    this.dt: '',
    this.contactoEntrega: '',
    this.inventario,
    this.activo: 0,
    this.visible: 1,
    this.idProducto: 0,
    this.tiempo_preparacion
  });

  factory PromocionModel.fromJson(Map<String, dynamic> json) => PromocionModel(
        aprobado: json["aprobado"] == null ? 1 : json["aprobado"],
        tieneDescuento: json["tieneDescuento"] == null ? false : json["tieneDescuento"].toString()=="true" ? true : false,
        descuento: json["descuento"] == null ? 0.0 : double.parse(json["descuento"].toString()),
        destacado: json["destacado"] == null ? 0 : json["destacado"],
        promocion: json["promocion"] == null ? 0 : json["promocion"],
        estado: json["estado"] == null ? 1 : json["estado"],
        mensaje: json["mensaje"] == null ? '' : json["mensaje"].toString(),
        productos: json["productos"] == null ? null : Productos.fromJson(jsonDecode(json["productos"].toString())),
        visible: json["visible"] == null ? 0 : int.parse(json["visible"]?.toString()),
        activo: json["activo"] == null ? 0 : int.parse(json["activo"]?.toString()),
        idAgencia: json["id_agencia"],
        idPromocion: json["id_promocion"],
        idProducto: json["id_producto"] == null ? 0 : json["id_producto"],
        idUrbe: json["id_urbe"],
        incentivoPrevio: json["incentivo"],
        incentivo: json["incentivo"],
        producto: json["producto"],
        descripcion: json["descripcion"],
        precio: json["precio"] == null ? 0.0 : double.parse(json["precio"].toString()),
        imagen: img.img(json["imagen"]),
        minimo: json["minimo"],
        maximo: json["maximo"],
        tipo: json["tipo"] == null ? 1 : int.parse(json["tipo"]?.toString()),
        cantidad: json["cantidad"] == null ? 1 : int.parse(json["cantidad"]?.toString()),
        contactoEntrega: json["contactoEntrega"] == null ? '' : json["contactoEntrega"]?.toString(),
        costo: json["costoTotal"],
        dt: json["dt"] == null ? '' : json["dt"],
        inventario:json["inventario"] == null ? '500' : json["inventario"].toString(),
        tiempo_preparacion: json['tiempo_preparacion'] == null ? '' : json['tiempo_preparacion'],
      );

  Map<String, dynamic> toJson() => {
        "id_agencia": idAgencia,
        "tieneDescuento": tieneDescuento,
        "descuento": descuento,
        "id_promocion": idPromocion,
        "id_producto": idProducto,
        "id_urbe": idUrbe,
        "producto": producto,
        "descripcion": descripcion,
        "precio": precio,
        "imagen": imagen,
        "tipo": tipo,
        "dt": dt,
        "cantidad": cantidad,
        "costoTotal": (costoTotal).toStringAsFixed(2),
        "inventario": inventario,
        "contactoEntrega": contactoEntrega,
        "incentivo": incentivo,
        "tiempo_preparacion": tiempo_preparacion
      };
}

class Productos {
  List<LP> lP;

  Productos({
    this.lP,
  });

  factory Productos.fromJson(Map<String, dynamic> json) => Productos(
        lP: List<LP>.from(json["lP"].map((x) => LP.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        '"lP"': List<dynamic>.from(lP.map((x) => x.toJson())),
      };
}

class LP {
  String id;
  String d;
  double p;
  bool isComprada = false;

  LP({this.d, this.p, this.id});

  factory LP.fromJson(Map<String, dynamic> json) => LP(
        id: json["id"],
        d: json["d"],
        p: double.parse(json["p"].toString()),
      );

  Map<String, dynamic> toJson() => {
        '"id"': '"$id"',
        '"d"': '"$d"',
        '"p"': '"$p"',
      };
}
