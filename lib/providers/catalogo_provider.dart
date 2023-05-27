import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import '../model/catalogo_model.dart';
import '../model/promocion_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class CatalogoProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlListarAgencias = 'catalogo/listar-agencias';
  final String _urlListarPromociones = 'catalogo/listar-promociones';
  final String _urlVer = 'catalogo/ver';
  final String _urlLike = 'catalogo/like';
  final String _urlReferido = 'catalogo/referido';

  Future<bool> like(CatalogoModel catalogoModel, {bool isShare: false, dynamic idP: '0'}) async {
    try {
      Map<String, dynamic> client_agency = {};
      client_agency["activo"] = 1;
      client_agency["fecha_actualizo"] = DateTime.now().toString();
      client_agency["id_actualizo"] = int.parse(_prefs.idCliente);
      client_agency["id_agencia"] = catalogoModel.idAgencia;
      client_agency["id_cliente"] = int.parse(_prefs.idCliente);
      client_agency["id_registro"] = int.parse(_prefs.idCliente);
      client_agency["me_gusta"] = catalogoModel.like;
      client_agency["shares"] = 0;
      client_agency["fecha_registro"] = DateTime.now().toString();
      await FirebaseFirestore.instance.collection("client_agency").doc("client_agency_${_prefs.idCliente.toString()}_${catalogoModel.idAgencia.toString()}").set(client_agency);        
      return true;
    } catch (err) {
      print('catalogo_provider error: $err');
    } 
    return false;
  }

  referido(CatalogoModel catalogoModel, {dynamic idP: '0'}) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlReferido),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'idAgencia': catalogoModel.idAgencia.toString(),
            'idP': idP.toString()
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        return true;
      }
    } catch (err) {
      print('catalogo_provider error: $err');
    } finally {
      client.close();
    }
    return false;
  }

  Future<CatalogoModel> ver(dynamic idCatalogo) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlVer),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'idCatalogo': idCatalogo.toString()
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        return CatalogoModel.fromJson(decodedResp['catalogo']);
      }
    } catch (err) {
      print('catalogo_provider error: $err');
    } finally {
      client.close();
    }
    return null;
  }

  Future<List<CatalogoModel>> listarAgencias(int selectedIndex, dynamic idUrbe, int categoria, String criterio) async {
    List<CatalogoModel> catalogosResponse = [];
    try {
      if (selectedIndex == 3) {
        //return FirebaseFirestore.instance.runTransaction((transaction) async {
          return FirebaseFirestore.instance
              .collection("client_agency")
              .where("activo", isEqualTo: 1)
              .where("id_cliente", isEqualTo: int.parse(_prefs.idCliente))
              .where("me_gusta", isEqualTo: 1)
              .snapshots()
              .asyncMap((client_agencys) async{
              final List<Future<CatalogoModel>> listCatalogo = client_agencys.docs.map((client_agency)async{
              Map clienteAgency = client_agency.data();
              Map agencyProductoModel = await _getAgencyProduct(clienteAgency['id_agencia'],criterio);
              Map agencyModel = agencyProductoModel==null ? null : await _getAgency(clienteAgency['id_agencia'],categoria,criterio);
              CatalogoModel catalogoModelTemp = CatalogoModel();
              if(agencyModel!=null) catalogoModelTemp = await _getCatalogoModel(agencyModel, clienteAgency);
              if(catalogoModelTemp.abiero=="1") return catalogoModelTemp;
            }).toList();
            List<CatalogoModel> list = await Future.wait(listCatalogo);
            return await list;
          }).firstWhere((catalogo) => true).then((catalogo) async { 
            catalogosResponse.addAll(await catalogo);
            catalogosResponse.removeWhere((element) => element==null);
            return catalogosResponse;
          });
        //});
      } else {
        //return FirebaseFirestore.instance.runTransaction((transaction) async {
          Query queryAgency;
          if (categoria == 0) {
            if (selectedIndex == 4) {
              queryAgency = FirebaseFirestore.instance
                  .collection("agency")
                  .where("activo", isEqualTo: 1)
                  .where("recomendado", isEqualTo: 1)
                  .where("tipo", isEqualTo: 1);
            } else {
              queryAgency = FirebaseFirestore.instance
                  .collection("agency")
                  .where("activo", isEqualTo: 1)
                  .where("tipo", isEqualTo: 1);
            }
          } else {
            if (selectedIndex == 4) {
              queryAgency = FirebaseFirestore.instance
                  .collection("agency")
                  .where("activo", isEqualTo: 1)
                  .where("recomendado", isEqualTo: 1)
                  .where("tipo", isEqualTo: 1)
                  .where("id_categoria", isEqualTo: categoria);
            } else {
              queryAgency = FirebaseFirestore.instance
                  .collection("agency")
                  .where("activo", isEqualTo: 1)
                  .where("id_categoria", isEqualTo: categoria)
                  .where("tipo", isEqualTo: 1);
            }
          }
        return queryAgency.snapshots().asyncMap((agencys)async{
          List<CatalogoModel> list;
            if(criterio.isEmpty){
              final List<Future<CatalogoModel>> listCatalogo = agencys.docs.map((agency)async{
                Map agencyMap = agency.data();
                Map clientAgencyModel = await _getclientAgency(agencyMap['id_agencia']);
                CatalogoModel catalogoModelTemp = await _getCatalogoModel(agencyMap, clientAgencyModel);
                if(catalogoModelTemp.abiero=="1") return catalogoModelTemp;
              }).toList();
              list = await Future.wait(listCatalogo);
            }else{
              /* Iterable<QueryDocumentSnapshot<Object>> agencysTemp = agencys.docs.where((QueryDocumentSnapshot agency){
                return agency['criterio'].toLowerCase().contains(criterio);
              }); */
              final List<Future<CatalogoModel>> listCatalogo = agencys.docs.map((agency)async{
                Map clienteAgency = agency.data();
                Map agencyProductoModel = await _getAgencyProduct(clienteAgency['id_agencia'],criterio);
                Map agencyMap = agencyProductoModel==null ? null : agency.data();
                CatalogoModel catalogoModelTemp = CatalogoModel();
                if(agencyMap!=null) catalogoModelTemp = await _getCatalogoModel(agencyMap, clienteAgency);
                if(catalogoModelTemp.abiero=="1") return catalogoModelTemp;
              }).toList();
              list = await Future.wait(listCatalogo);
            }
            return await list;
          }).firstWhere((catalogo) => true).then((catalogo) async { 
            catalogosResponse.addAll(await catalogo);
            catalogosResponse.removeWhere((element) => element==null);
            return catalogosResponse;
          });
        /* }).catchError((error) {
          return catalogosResponse;
        }); */
      }
    } catch (err) {
      print('catalogo_provider error: $err');
    }
    return catalogosResponse;
  }

  Future<Map> _getclientAgency(int agencyID) async {
    String clientAgencyId = "client_agency_${_prefs.idCliente.toString()}_${agencyID.toString()}";
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("client_agency")
        .doc(clientAgencyId)
        .get();
    Map clientAgencyModel = documentSnapshot.data();
    return clientAgencyModel;
  }

  Future<Map> _getAgencyProduct(int agencyID, String criterio) async {
    Map agencyMap;
    Query queryAgency;
      queryAgency = FirebaseFirestore.instance
          .collection("product")
          .where("activo", isEqualTo: 1)
          .where("id_agencia", isEqualTo: agencyID)
          .where("tipo", isEqualTo: 1)
          .where("visible", isEqualTo: 1);
    await queryAgency.get().then((agencys) async {
      Iterable<QueryDocumentSnapshot<Object>> agencysTemp = agencys.docs.where((QueryDocumentSnapshot agency){
          return agency['criterio'].toLowerCase().contains(criterio);
        });
        if (agencysTemp.length > 0) agencyMap = agencysTemp.first.data();
    });
    return agencyMap;
  }

  Future<Map> _getAgency(int agencyID, int categoria, String criterio) async {
    Map agencyMap;
    Query queryAgency;
    if (categoria == 0) {
      queryAgency = FirebaseFirestore.instance
          .collection("agency")
          .where("activo", isEqualTo: 1)
          .where("id_agencia", isEqualTo: agencyID)
          .where("tipo", isEqualTo: 1)
          .limit(1);
    } else {
      queryAgency = FirebaseFirestore.instance
          .collection("agency")
          .where("activo", isEqualTo: 1)
          .where("id_agencia", isEqualTo: agencyID)
          .where("tipo", isEqualTo: 1)
          .where("id_categoria", isEqualTo: categoria)
          .limit(1);
    }
    await queryAgency.get().then((agencys) async {
      //if(criterio.isEmpty){
        if (agencys.size > 0) agencyMap = agencys.docs.first.data();
      /* }else{
        Iterable<QueryDocumentSnapshot<Object>> agencysTemp = agencys.docs.where((QueryDocumentSnapshot agency){
          return agency['criterio'].toLowerCase().contains(criterio);
        });
        if (agencysTemp.length > 0) agencyMap = agencysTemp.first.data();
      } */
    });
    return agencyMap;
  }

  Future<CatalogoModel> _getCatalogoModel(Map agencyMap,clientAgencyModel) async {
    CatalogoModel catalogoModelTemp = CatalogoModel();
    DateTime day = DateTime.now();
    await FirebaseFirestore.instance
        .collection("subsidiary_schedule")
        .where("activo", isEqualTo: 1)
        .where("dia", isEqualTo: day.weekday)
        .where("id_sucursal", isEqualTo: agencyMap['id_agencia'])
        .limit(1)
        .get()
        .then((schedules) async {
      if (schedules.size > 0) {
        Map scheduleMap = schedules.docs.first.data();
        int desde = int.parse(scheduleMap['desde'].toString().split(":")[0]);
        int hasta = int.parse(scheduleMap['hasta'].toString().split(":")[0]);
        DateTime now = DateTime.now();
        if (now.hour >= desde && hasta > now.hour) {
          catalogoModelTemp.abiero = "1";
          catalogoModelTemp.agencia = agencyMap['agencia'];
          catalogoModelTemp.contacto = agencyMap['contacto'];
          catalogoModelTemp.direccion = agencyMap['direccion'];
          catalogoModelTemp.idAgencia = agencyMap['id_agencia'];
          catalogoModelTemp.label = agencyMap['label'];
          catalogoModelTemp.tipo = agencyMap['tipo'];
          catalogoModelTemp.like = clientAgencyModel==null ? 0 : clientAgencyModel['me_gusta'] == 1 ? 1 : 0;
          catalogoModelTemp.img = agencyMap['img'];
          catalogoModelTemp.observacion = agencyMap['observacion'];
          catalogoModelTemp.idCategoria = agencyMap['id_categoria'];
          catalogoModelTemp.promedioCalificacion = agencyMap['promedioCalificacion'] ?? 0.1;
        }
      }
    });
    return catalogoModelTemp;
  } 

  bool _cargando = false;

  listarPromociones(dynamic idAgencia, dynamic alias, bool isClean, int pagina, dynamic idPromocion, Function response) async {
    List<PromocionModel> promocionesResponse = [];
    int total = 0;
    if (isClean || pagina == 0) {
      _cargando = false;
    }
    if (_cargando) return [];
    _cargando = true;
    // try {
      DateTime now = DateTime.now();
      
      QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentPromocion = (await FirebaseFirestore.instance.collection("promociones").where("id_agencia", isEqualTo: int.parse(idAgencia))
      .where("fecha_fin_mili",isGreaterThanOrEqualTo: now.millisecondsSinceEpoch)
      .limit(1).get()).docs.firstWhere((element) => element['fecha_inicio_mili']<=now.millisecondsSinceEpoch, orElse: () => null);
      Map<String, dynamic> promocion = queryDocumentPromocion==null ? {} : queryDocumentPromocion.data();



      List<dynamic> listaProductosDescuento = promocion["ids_productos"]??[];
      
      await FirebaseFirestore.instance
          .collection("product")
          .where("activo", isEqualTo: 1)
          .where("aprobado", isEqualTo: 1)
          .where("id_agencia", isEqualTo: int.parse(idAgencia))
          .where("visible", isEqualTo: 1)
          .where("tipo", isEqualTo: 1)
          .get()
          .then((products) {
        if (products.size > 0) {
          products.docs.forEach((product) {
            PromocionModel productoModelTemp = PromocionModel();
            Map productoMap = product.data();
            productoModelTemp.estado = 1;
            productoModelTemp.activo = productoMap['activo'];
            productoModelTemp.mensaje = "Local Cerrado";
            productoModelTemp.promocion = productoMap['promocion'];
            productoModelTemp.productos = null;
            productoModelTemp.tipo = productoMap['tipo'];
            productoModelTemp.aprobado = productoMap['aprobado'];
            productoModelTemp.visible = productoMap['visible'];
            productoModelTemp.tiempo_preparacion = productoMap['tiempo_preparacion'];
            productoModelTemp.idUrbe = productoMap['id_urbe'];
            productoModelTemp.inventario = productoMap['inventario'].toString();
            productoModelTemp.idPromocion = productoMap['id_promocion'];
            productoModelTemp.idAgencia = productoMap['id_agencia'];
            productoModelTemp.incentivo = productoMap['incentivo'];
            productoModelTemp.producto = productoMap['producto'];
            productoModelTemp.descripcion = productoMap['descripcion'];
            productoModelTemp.precio = productoMap['precio'];
            productoModelTemp.imagen = productoMap['imagen'];
            productoModelTemp.minimo = productoMap['minimo'];
            productoModelTemp.maximo = productoMap['maximo'];
            productoModelTemp.destacado = productoMap['destacado'];
            productoModelTemp.tieneDescuento = listaProductosDescuento.contains(productoMap['id_promocion']) ? true : false;
            productoModelTemp.descuento = listaProductosDescuento.contains(productoMap['id_promocion']) ? double.parse(promocion['descuento'].toString()) : 0.0;

            promocionesResponse.add(productoModelTemp);
          });
        }
      });
      AggregateQuerySnapshot  aggregateQuerySnapshot = await FirebaseFirestore.instance
          .collection("product")
          .where("activo", isEqualTo: 1)
          .where("aprobado", isEqualTo: 1)
          .where("id_agencia", isEqualTo: int.parse(idAgencia))
          .where("visible", isEqualTo: 1)
          .where("tipo", isEqualTo: 1)
          .count().get();
          total = aggregateQuerySnapshot.count;
    
    _cargando = false;
    if (promocionesResponse.length <= 0) _cargando = true;
    return response(promocionesResponse, total);
  }

}