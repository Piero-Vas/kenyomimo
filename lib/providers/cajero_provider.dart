import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../model/cajero_model.dart';
import '../model/direccion_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class CajeroProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlListarCompras = 'cajero/listar-registros';
  final String _urlListarEnCamno = 'cajero/listar-en-camino';
  final String _urlVerCostoPromocion = 'cajero/ver-costo-promocion';
  final String _urlCancelar = 'cajero/cancelar';
  final String _urlVer = 'cajero/ver';

  Future<CajeroModel> ver(dynamic idCompra) async {
    CajeroModel cajeroModel = CajeroModel();
    DocumentSnapshot documentSnapshotBuy = await FirebaseFirestore.instance.collection("compra").doc("compra_"+idCompra.toString()).get();
    Map<String,dynamic> buyMap = documentSnapshotBuy.data();

    DocumentSnapshot documentSnapshotDispatchStatus = await FirebaseFirestore.instance.collection("compra_estado").doc("compra_estado_"+buyMap['id_compra_estado'].toString()).get();
    Map<String,dynamic> dispatchStatusMap = documentSnapshotDispatchStatus.data();
    
    DocumentSnapshot documentSubsidiary = await FirebaseFirestore.instance.collection("subsidiary").doc("subsidiary_"+buyMap['id_sucursal'].toString()).get();
    Map<String,dynamic> subsidiarybuyMap = documentSubsidiary.data();

    DocumentSnapshot documentClient = await FirebaseFirestore.instance.collection("client").doc("client_"+buyMap['id_cliente'].toString()).get();
    Map<String,dynamic> clientMap = documentClient.exists ? documentClient.data() : null;
    
    cajeroModel.idDespacho = buyMap['id_despacho'];
    cajeroModel.tiempo_viaje = buyMap['tiempo_preparacion'];
    cajeroModel.idDireccion = buyMap['id_direccion'];
    cajeroModel.sinLeerCajero = buyMap['sinLeerCajero'];
    cajeroModel.sinLeerCliente = buyMap['sinLeerCliente'];
    cajeroModel.calificarCliente = buyMap['calificarCliente'];
    cajeroModel.calificarCajero = buyMap['calificarCajero'];
    cajeroModel.calificacionCliente =  buyMap['calificacionCliente']==null ? 0.0 : buyMap['calificacionCliente'];
    cajeroModel.calificacionCajero = buyMap['calificacionCliente']==null ? 0.0 : buyMap['calificacionCliente'];
    cajeroModel.comentarioCliente = buyMap['comentarioCliente'];
    cajeroModel.comentarioCajero = buyMap['comentarioCajero'];
    cajeroModel.costoEnvio = buyMap['costo_entrega'];
    cajeroModel.costo = buyMap['costo'];
    cajeroModel.detalle = buyMap['detalle'];
    cajeroModel.referencia = buyMap['referencia'];
    cajeroModel.alias = buyMap['alias'];
    cajeroModel.lt = buyMap['lt'];
    cajeroModel.lg = buyMap['lg'];
    cajeroModel.idCajero = buyMap['id_cajero'];
    cajeroModel.idCompraEstado = buyMap['id_compra_estado'];
    cajeroModel.idCompra = buyMap['id_compra'];
    cajeroModel.typePayment = buyMap['typePayment'];
    cajeroModel.chargeId = buyMap['chargeId'];
    cajeroModel.propina = buyMap['propina'];
    
    cajeroModel.onLine = clientMap['on_line'];
    cajeroModel.idCliente = clientMap['id_cliente'];
    cajeroModel.codigoPais = clientMap['codigoPais'];
    cajeroModel.celular = clientMap['celular'];
    cajeroModel.nombres = clientMap['nombres'];
    cajeroModel.apellidos = clientMap['apellidos'];
    cajeroModel.img = clientMap['img'];
    cajeroModel.celularValidado = clientMap['celularValidado'];

    cajeroModel.idSucursal = subsidiarybuyMap['id_sucursal'];
    cajeroModel.sucursal = subsidiarybuyMap['sucursal'];

    cajeroModel.estado = dispatchStatusMap['estado'];
     
    return cajeroModel;
  }

  Future<CajeroModel> cancelar(CajeroModel cajeroModel, dynamic idClienteRecibe,dynamic idClienteEnvia, int envia) async {
    
    CajeroModel cajeroModelTemp = CajeroModel();
    return FirebaseFirestore.instance.runTransaction((transaction) async {
    DateTime now = DateTime.now();
    await _createBuyChat(cajeroModel.idCompra, now, transaction, idClienteEnvia, idClienteRecibe, '🚫 Compra cancelada', envia, 3, 100,"","🚫 Compra cancelada",-1);
    await _updateBuy(cajeroModel.idCompra, transaction);
    await _createBuyChat(cajeroModel.idCompra, now, transaction, idClienteEnvia, idClienteRecibe, '😔 Tu compra se ha cancelado', envia, 3, 100,"","😔 Tu compra se ha cancelado",-1);
    await _updateDispatch(cajeroModel.idCompra, transaction, _prefs.clienteModel.idCliente, now);
    await _createBuyChat(cajeroModel.idCompra, now, transaction, idClienteEnvia, idClienteRecibe, '🚫 Compra cancelada', envia, 3, 100,"","🚫 Compra cancelada",-1);
    cajeroModelTemp = await ver(cajeroModel.idCompra);
    return cajeroModelTemp;
    });
  }

  Future _updateBuy(idCompra, Transaction transaction)async {
    DocumentReference documentReferenceTemp =await FirebaseFirestore.instance.collection("compra").doc("compra_"+idCompra.toString());
    Map<String,dynamic> agencyTemp = (await documentReferenceTemp.get()).data() as Map;
    agencyTemp['calificarCajero'] = 1;
    agencyTemp['calificarCliente'] = 1;
    agencyTemp['id_compra_estado'] = 100;
    agencyTemp['fecha_cancelo']=DateTime.now().toString();
    agencyTemp['sinLeerCliente']=agencyTemp['sinLeerCliente']+3;
    
    await transaction.update(documentReferenceTemp, agencyTemp);
  }


  Future _updateDispatch(idDespacho, Transaction transaction, String idCancelo, now)async {
    DocumentReference documentReferenceTemp =await FirebaseFirestore.instance.collection("despacho").doc("despacho_"+idDespacho.toString());
    Map<String,dynamic> agencyTemp = (await documentReferenceTemp.get()).data() as Map;
    agencyTemp['id_cancelo'] = int.parse(idCancelo);
    agencyTemp['calificarConductor'] = 1;
    agencyTemp['calificarCliente'] = 1;
    agencyTemp['id_despacho_estado'] = 100;
    agencyTemp['fecha_pago'] = now.toString();
    
    await transaction.update(documentReferenceTemp, agencyTemp);
  }

  Future _createBuyChat(int idCompra,now, Transaction transaction,id_cliente_envia, id_cliente_recibe, mensaje, envia, tipo, valor, String token, String tituloNotification, int push) async {
    Map<String, dynamic> modelChatSubsidiary = {};
        DateTime now = DateTime.now();
        modelChatSubsidiary['id_chat'] = id_cliente_envia.toString()+"_"+DateTime.now().millisecondsSinceEpoch.toString();
        modelChatSubsidiary['id_compra'] = idCompra;
        modelChatSubsidiary['id_cliente_envia'] = int.parse(id_cliente_envia.toString());
        modelChatSubsidiary['id_cliente_recibe'] = int.parse(id_cliente_recibe.toString());
        modelChatSubsidiary['id_compra_estado'] = 100;
        modelChatSubsidiary['mensaje'] = mensaje;
        modelChatSubsidiary['envia'] = envia;
        modelChatSubsidiary['tipo'] = tipo;
        modelChatSubsidiary['valor'] = valor;
        modelChatSubsidiary['estado'] = 2;
        modelChatSubsidiary['fecha_entregado'] = now.toString();
        modelChatSubsidiary['fecha_leido'] = null;
        modelChatSubsidiary['fecha_registro'] = now.toString();
        modelChatSubsidiary['fecha_registro_corto'] = DateTime(now.year,now.month,now.day,now.hour,now.minute).toString();
        modelChatSubsidiary['hora'] = now.hour.toString()+":" + now.hour.toString(); 
        
        DocumentReference documentReferenceTemp = await FirebaseFirestore.instance
        .collection('compra_chat')
        .doc(id_cliente_envia.toString()+"_"+DateTime.now().millisecondsSinceEpoch.toString()); 
        await transaction.set(documentReferenceTemp, modelChatSubsidiary);

         String mensajeNotification = mensaje, tag = idCompra.toString();
        Map<String,dynamic> data = {
          "PUSH": push,
          "chat": modelChatSubsidiary,
          "click_action": "FLUTTER_NOTIFICATION_CLICK", 
          "sound": "default", "priority": "high", "content_available": true, "mutable_content": true, "time_to_live": 180,
          "apns": { "headers": { "apns-priority": "10" }, "payload": { "aps": { "sound": "default" } } }, "android": { "priority": "high", "notification": { "sound": "default" } },
          "json":true
        };
        String dataJson = jsonEncode(data);
        return await createNotification(token, tituloNotification, mensajeNotification, dataJson, tag);
  }
  String keyNotification1 = "key=AAAAvJkV440:APA91bHgpgFXv0AW0MAKmCcty7I0zP3lW-SWBVHa4nsFfMiKfUcnHmnGxmPW05WoWAfjtSZgfkhs_0oD84gx28IwzHKEfj6ANcz0VyO2qwAg-CerrSmw0kD6SbL2FKygiPN9oBdHGd5X";
  final _notificationBaseUrl = "https://fcm.googleapis.com/fcm/send";

   Future<bool> createNotification(String token, String tituloNotification, String mensajeNotification, String data, String tag) async {
    Map<String, String> headers = {
      'Content-type': 'application/json',
      HttpHeaders.authorizationHeader: keyNotification1,
      HttpHeaders.acceptHeader: '/',
      HttpHeaders.hostHeader: "fcm.googleapis.com",
      HttpHeaders.acceptEncodingHeader: "gzip, deflate",
      HttpHeaders.connectionHeader: "keep-alive"
    };
    String body = """{
      "registration_ids":["$token"],
      "notification":{ "title": "$tituloNotification", "tag": "$tag", "body": "$mensajeNotification", "sound": "default" },
      "data": $data
    }""";
    http.Response response = await http.post(Uri.parse('$_notificationBaseUrl'), headers: headers, body: body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<CajeroModel>> verCostoPromocion(int tipo,
      DireccionModel direccionModel, String agencias, String promociones,
      {DireccionModel direccionCliente}) async {
    List<CajeroModel> cajerosResponse = [];
    try {
      CajeroModel cajeroModel = CajeroModel();
      DocumentSnapshot documentSubsidiary = await FirebaseFirestore.instance.collection("subsidiary").doc("subsidiary_"+agencias).get();
      DocumentSnapshot documentAgency = await FirebaseFirestore.instance.collection("agency").doc("agency_"+agencias).get();
      Map subsidiaryMap =  documentSubsidiary.data() as Map;
      Map agencyMap =  documentAgency.data() as Map;

      List<LatLng> points = [
      LatLng(direccionModel.lt, direccionModel.lg),
      LatLng(double.parse(subsidiaryMap['lt']), double.parse(subsidiaryMap['lg']))
    ];
    
    double distance = await calculateDistance(points);
    
    int time = ((distance / 22) * 60).round();
      cajeroModel.idAgencia = agencyMap['id_agencia'];
      cajeroModel.isTarjeta = agencyMap['isTarjeta'];
      cajeroModel.idSucursal = subsidiaryMap['id_sucursal'];
      cajeroModel.sucursal = subsidiaryMap['sucursal'];
      cajeroModel.img = subsidiaryMap['img'];
      cajeroModel.costo_km_recorrido = subsidiaryMap['costo_km_recorrido'].toDouble(); 
      cajeroModel.costoEnvio = subsidiaryMap['costo_km_recorrido']*distance;
      cajeroModel.tiempo_viaje = time;
      cajeroModel.lt = double.parse(subsidiaryMap['lt']);
      cajeroModel.lg = double.parse(subsidiaryMap['lg']);
      cajerosResponse.add(cajeroModel);
      return cajerosResponse;
    } catch (err) {
      
      return null;
    } 
  }

  calculateDistance(List<dynamic> points) async {
    double distance = 0;
    for (int i = 0; i < points.length - 1; i++) {
      distance += Geolocator.distanceBetween(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }
    distance = distance / 1000;
    return distance;
  }

  Future<List<CajeroModel>> 
  
  listarEnCamino() async {
    List<CajeroModel> comprasResponse = [];
    try {
      //return FirebaseFirestore.instance.runTransaction((transaction) async {
      return FirebaseFirestore.instance.collection("compra").where("id_cliente",isEqualTo: int.parse(_prefs.idCliente)).where("id_compra_estado",isNotEqualTo: 200).snapshots().asyncMap((compras) async {
        
        
        Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> comprasTemp = await compras.docs.where((QueryDocumentSnapshot element) => element['calificarCliente'] == 2 ? false : true); 
        
        comprasTemp = await comprasTemp.where((QueryDocumentSnapshot element) =>  DateTime.parse(element['fecha_registro'].toString()).millisecondsSinceEpoch >= DateTime.now().millisecondsSinceEpoch ? false : true);  
        
        DocumentSnapshot documentReferenceClient = await FirebaseFirestore.instance.collection("client").doc("client_"+_prefs.idCliente).get();
        final List<Future<CajeroModel>> listCajero = comprasTemp.map((compra) async{
          Map compraModel = compra.data();
          DocumentSnapshot documentReferenceCompraEstado = await FirebaseFirestore.instance.collection("compra_estado").doc("compra_estado_"+compraModel['id_compra_estado'].toString()).get();
          DocumentSnapshot documentReferenceSubsidiary = await FirebaseFirestore.instance.collection("subsidiary").doc("subsidiary_"+compraModel['id_sucursal'].toString()).get();
          CajeroModel cajeroModel = await _getCajeroModel(documentReferenceSubsidiary, documentReferenceCompraEstado, documentReferenceClient, compraModel);
          if(cajeroModel != null) return cajeroModel;
        }).toList(); 
        List<CajeroModel> list = await Future.wait(listCajero);
        return await list;
      }).firstWhere((catalogo) => true).then((catalogo) async { 
            comprasResponse.addAll(await catalogo);
            comprasResponse.removeWhere((element) => element==null);
            return comprasResponse;
      });
      /* }).catchError((error) {
          return comprasResponse;
        }); */
    } catch (err) {
      return comprasResponse;
    } 
  }

  Future<CajeroModel> _getCajeroModel(documentReferenceSubsidiary,documentReferenceCompraEstado, documentReferenceClient, compraModel)async {
    CajeroModel cajeroModel = CajeroModel();
    if (documentReferenceSubsidiary.exists &&
        documentReferenceCompraEstado.exists &&
        documentReferenceClient.exists) {
      
      Map compraEstadoModel = documentReferenceCompraEstado.data();
      Map subsidiaryModel = documentReferenceSubsidiary.data();
      Map clientModel = documentReferenceClient.data();
      
      //COMPRA
      cajeroModel.idDespacho = compraModel['id_despacho'];
      cajeroModel.idDireccion = compraModel['id_direccion'];
      cajeroModel.sinLeerCajero = compraModel['sinLeerCajero'];
      cajeroModel.sinLeerCliente = compraModel['sinLeerCliente'];
      cajeroModel.calificacionCliente = compraModel['calificacionCliente']==null ? 0.0 : compraModel['calificacionCliente'];
      cajeroModel.calificacionCajero = compraModel['calificacionCajero']==null ? 0.0 : compraModel['calificacionCajero'];
      cajeroModel.calificarCajero = compraModel['calificarCajero'];
      cajeroModel.calificarCliente = compraModel['calificarCliente'];
      cajeroModel.comentarioCajero = compraModel['comentarioCajero'];
      cajeroModel.comentarioCliente = compraModel['comentarioCliente'];
      cajeroModel.costoEnvio = compraModel['costo_entrega'].toDouble();
      cajeroModel.costo = compraModel['costo'];
      cajeroModel.detalle = compraModel['detalle'];
      cajeroModel.referencia = compraModel['referencia'];
      cajeroModel.alias = compraModel['alias'];
      cajeroModel.lgB = compraModel['lg'];
      cajeroModel.ltB = compraModel['lt'];
      cajeroModel.idCajero = compraModel['idCajero'];
      cajeroModel.idCliente = compraModel['id_cliente'];
      cajeroModel.idCompraEstado = compraModel['id_compra_estado'];
      cajeroModel.idCompra = compraModel['id_compra'];
      //SUCURSAL
      cajeroModel.lg = subsidiaryModel['lg'];
      cajeroModel.lt = subsidiaryModel['lt'];
      cajeroModel.sucursal = subsidiaryModel['sucursal'];
      cajeroModel.img = subsidiaryModel['img'];
      //CLIENTE
      cajeroModel.codigoPais = clientModel['codigoPais']; 
      cajeroModel.celular = clientModel['celular'];
      cajeroModel.nombres = clientModel['nombres'];
      cajeroModel.apellidos = clientModel['apellidos'];
      cajeroModel.celularValidado = clientModel['celularValidado'];
      cajeroModel.onLine = clientModel['on_line'];
      //COMPRA ESTADO
      cajeroModel.estado = compraEstadoModel['estado'];
      return cajeroModel;
    }else{ return null;}
  }

  Future<List<CajeroModel>> listarCompras(int tipo, String fecha) async {
    var client = http.Client();
    List<CajeroModel> comprasResponse = [];
    try {
      final resp = await http.post(
          Uri.parse(Sistema.dominio + _urlListarCompras),
          headers: utils.headers,
          body: {
            'idCajero': _prefs.idCliente,
            'auth': _prefs.auth,
            'tipo': tipo.toString(),
            'fecha': fecha
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['cajeros']) {
          comprasResponse.add(CajeroModel.fromJson(item));
        }
      }
    } catch (err) {
      print('cajero_provider error: $err');
    } finally {
      client.close();
    }
    return comprasResponse;
  }
}