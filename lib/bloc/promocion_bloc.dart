import 'dart:async';

import 'package:mimo/bloc/carrito_bloc.dart';

import '../model/promocion_model.dart';
import '../preference/db_provider.dart';
import '../preference/shared_preferences.dart';
import '../providers/promocion_provider.dart';

class PromocionBloc {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final PromocionProvider _promocionProvider = PromocionProvider();
  final CarritoBloc _carritoBloc = CarritoBloc();
  List<PromocionModel> promociones = [];

  static PromocionBloc _instancia;

  PromocionBloc._internal();

  factory PromocionBloc() {
    if (_instancia == null) {
      _instancia = PromocionBloc._internal();
    }
    return _instancia;
  }

  final promocionesStreamController =
      StreamController<List<PromocionModel>>.broadcast();

  Function(List<PromocionModel>) get promocionSink =>
      promocionesStreamController.sink.add;

  Stream<List<PromocionModel>> get promocionStream =>
      promocionesStreamController.stream;

  Future listar({dynamic idUrbe: '0',int categoria: 0,String criterio: '',bool isClena = false}) async {
    idUrbe = idUrbe.toString();
    if (idUrbe == '0') idUrbe = _prefs.idUrbe;
    if (_prefs.idUrbe != idUrbe) {
      isClena = true;
      promociones.clear();
      promocionSink(promociones);
    }
    final promocionesResponse = await _promocionProvider.listarPromociones(idUrbe, isClena, criterio, categoria);
    promociones.clear();
    List<PromocionModel> aux = await DBProvider.db.listar(idUrbe);
    aux.forEach((promo) {
      for (var promocion in promocionesResponse) {
        if (promo.idPromocion.toString() == promocion.idPromocion.toString()) {
          promocion.isComprada = true;
          break;
        }
      }
    });
    
    promociones.addAll(promocionesResponse);
    promocionSink(promociones);
    //_carritoBloc.promocionSink(promociones);
    return;
  }

  Future actualizar(PromocionModel promocionModel) async {
    await DBProvider.db.editarPromocion(promocionModel);
    promociones.forEach((promocion) {
      if (promocion.idPromocion.toString() ==
          promocionModel.idPromocion.toString()) {
        promocion.isComprada = promocionModel.isComprada;
        promocion.cantidad = promocionModel.cantidad;
      }
    });
    promocionSink(promociones);
    return;
  }

  Future getPromotions(dynamic idAgencia)async{
    return await DBProvider.db.search(idAgencia);
  }

  Future getCountPromotions()async{
    return await DBProvider.db.contar();
  }

  final carritoStreamController = StreamController<int>.broadcast();

  Function(int) get carritoSink => carritoStreamController.sink.add;

  Stream<int> get carritoStream => carritoStreamController.stream;

  Future carrito() async {
    int cuantos = await DBProvider.db.contar();
    carritoSink(cuantos);
    return;
  }

  Future<int> getTotal() async{
    return await DBProvider.db.contar();
  }

  final costoStreamController = StreamController<double>.broadcast();

  Function(double) get costoSink => costoStreamController.sink.add;

  Stream<double> get costoStream => costoStreamController.stream;

  void disposeStreams() {
    promocionesStreamController?.close();
    carritoStreamController?.close();
    costoStreamController?.close();
  }
}