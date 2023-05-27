import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:mimo/model/despacho_model.dart';

import '../model/cajero_model.dart';
import '../model/compra_promocion_model.dart';
import '../model/direccion_model.dart';
import '../model/factura_model.dart';
import '../model/promocion_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/conf.dart' as config;
import '../utils/utils.dart' as utils;

class CompraProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlVer = 'compra/ver';
  final String _urlMarcarLeido = 'compra/marcar-leido';
  final String _urlIniciar = 'compra/inciar';

  final String _urlCalificar = 'compra/calificar';
  final String _urlListarPromociones = 'compra/listar-promociones';

  Future<List<CompraPromocionModel>> listarCompraPromociones(
      dynamic idCompra) async {
    List<CompraPromocionModel> promocionesResponse = [];
    final resp = await http.post(
        Uri.parse(Sistema.dominio + _urlListarPromociones),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idCompra': idCompra.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      for (var item in decodedResp['promociones']) {
        promocionesResponse.add(CompraPromocionModel.fromJson(item));
      }
    }
    return promocionesResponse;
  }

  calificar(CajeroModel cajeroModel, int tipo, Function response) async {
    Map<String,dynamic> cajeroMap = {};
    cajeroMap['calificarCliente'] = 2;
    cajeroMap['calificacionCliente'] = cajeroModel.calificacionCliente;
    cajeroMap['comentarioCliente'] = cajeroModel.comentarioCliente;
    cajeroMap['fecha_califico_cliente'] = DateTime.now().toString();
    await FirebaseFirestore.instance.collection("compra").doc("compra_"+cajeroModel.idCompra.toString()).update(cajeroMap);
    return response(1,"Se califico con exito",cajeroModel);
  }

  Future<bool> marcarLeido(CajeroModel cajeroModel, int tipo) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlMarcarLeido),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idCompra': cajeroModel.idCompra.toString(),
          'tipo': tipo.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return true;
    }
    return false;
  }

  Future<CajeroModel> ver(dynamic idCompra) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlVer),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idCompra': idCompra.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return CajeroModel.fromJson(decodedResp['cajero']);
    }
    return null;
  }

  Future _createDispatch(cantidadCards,costo,costoEntrega, idSucursal,DireccionModel direccionmodel,CajeroModel cajero, int tiempo_preparacion , int typePayment, double propina )async{
    DocumentSnapshot dsSubsidiary = await FirebaseFirestore.instance.collection("subsidiary").doc("subsidiary_"+idSucursal.toString()).get();
    Map<String, dynamic> subsidiaryModel = dsSubsidiary.data();
    DateTime now = DateTime.now();
    Map<String, dynamic> despachoMap = {};
    despachoMap['id_sucursal'] = idSucursal;
    despachoMap['typePayment'] = typePayment;
    despachoMap['propina'] = double.parse(propina.toString());
    despachoMap['tiempo_preparacion'] = tiempo_preparacion;
    despachoMap['id_despacho'] = cantidadCards;
    despachoMap['tipo'] = 2;
    despachoMap['id_compra'] = cantidadCards;
    despachoMap['id_cliente'] = int.parse(_prefs.idCliente);
    despachoMap['id_despacho_estado'] = 1;
    despachoMap['costo'] = costo;
    despachoMap['costo_entrega'] = double.parse(costoEntrega.toString());
    despachoMap['ltA'] = double.parse(subsidiaryModel['lt'].toString());
    despachoMap['lgA'] = double.parse(subsidiaryModel['lg'].toString());
    despachoMap['ltB'] = direccionmodel.lt;
    despachoMap['lgB'] = direccionmodel.lg;
    despachoMap['despacho'] = "{ 'a': ${cajero.sucursal}, 'b': ${cajero.nombres}, 'd': ${cajero.detalle}, 'r': ${cajero.referencia}, 'c': ${cajero.costo}, 'ce': ${cajero.costoEnvio} }";
    despachoMap['ruta'] = "{ 't': 3 }";
    despachoMap['anio'] = now.year;
    despachoMap['mes'] = now.month;
    despachoMap['fecha'] = now.toString().substring(0,10);
    despachoMap['meta'] = utils.headers.toString();
    despachoMap['paymentStatusAgencia'] = 0;
    despachoMap['paymentStatusMoto'] = 0;
    despachoMap['preparandose'] = 0;
    despachoMap['sinLeerConductor'] = 0;
    despachoMap['sinLeerCliente'] = 0;
    despachoMap['calificarCliente'] = 0;
    despachoMap['calificarConductor'] = 0;
    despachoMap['calificacionCliente'] = 0.0;
    despachoMap['calificacionConductor'] = 0.0;
    despachoMap['comentarioCliente'] = null;
    despachoMap['comentarioConductor'] = null;
    despachoMap['id_conductor'] = null;
    despachoMap['id_promocion'] = null;
    despachoMap['id_cancelo'] = null;
    despachoMap['id_finalizo'] = null;
    despachoMap['fecha_registro'] = now.toString();
    despachoMap['fecha_iniciado'] = null;
    despachoMap['fecha_pago'] = null;
    despachoMap['fecha_referencia'] = null;
    despachoMap['fecha_califico_conductor'] = null;
    despachoMap['fecha_califico_cliente'] = null;
    despachoMap['fecha_cancelo'] = null;
    despachoMap['chats'] = 0;
    await FirebaseFirestore.instance.collection("despacho").doc("despacho_"+cantidadCards.toString()).set(despachoMap);
  }

  Future _updateAgency(idSucursal, transaction)async {
    DocumentReference documentReferenceTemp =await FirebaseFirestore.instance.collection("agency").doc("agency_"+idSucursal.toString());
    Map agencyTemp = (await documentReferenceTemp.get()).data() as Map;
    await transaction.update(documentReferenceTemp, {"ventas":agencyTemp['ventas']+1});
  }

  Future _updateClient(transaction, now)async {
    DocumentReference documentReferenceTemp =await FirebaseFirestore.instance.collection("client").doc("client_"+_prefs.idCliente.toString());
    Map agencyTemp = (await documentReferenceTemp.get()).data() as Map;
    await transaction.update(documentReferenceTemp, {"fecha_ultima": now.toString(), "registros":agencyTemp['registros']+1 });
  }


  Future<CajeroModel> _getCajeroModel(DireccionModel direccionModel, costoEntrega, costoTotal, detalle, idSucursal, int cantidadCards, int typePayment, String chargeId, double propina) async{
    DocumentSnapshot dsSubsidiary = await FirebaseFirestore.instance.collection("subsidiary").doc("subsidiary_"+idSucursal.toString()).get();
    Map subsidiaryModel = dsSubsidiary.data();
    CajeroModel cajeroModel = CajeroModel();
    cajeroModel.typePayment = typePayment;
    cajeroModel.propina = propina;
    cajeroModel.chargeId = chargeId;
    cajeroModel.idDespacho = cantidadCards;
    cajeroModel.onLine = 1;
    cajeroModel.idDireccion = direccionModel.idDireccion;
    cajeroModel.sinLeerCajero = 0;
    cajeroModel.sinLeerCliente = 0;
    cajeroModel.calificarCajero = 0;
    cajeroModel.calificarCliente = 0;
    cajeroModel.calificacionCajero = null;
    cajeroModel.calificacionCliente = null;
    cajeroModel.comentarioCajero = null;
    cajeroModel.comentarioCliente = null;
    cajeroModel.costoEnvio = double.parse(costoEntrega.toString());
    cajeroModel.costo = costoTotal;
    cajeroModel.detalle = detalle;
    cajeroModel.referencia = direccionModel.referencia;
    cajeroModel.ltB = double.parse(direccionModel.lt.toString());
    cajeroModel.lgB = double.parse(direccionModel.lg.toString());
    cajeroModel.idCajero = int.parse(idSucursal.toString());
    cajeroModel.idCliente = int.parse(_prefs.idCliente);
    cajeroModel.codigoPais = "+51";
    cajeroModel.celular = _prefs.clienteModel.celular;
    cajeroModel.nombres = _prefs.clienteModel.nombres;
    cajeroModel.apellidos = _prefs.clienteModel.apellidos;
    cajeroModel.img = _prefs.clienteModel.img;
    cajeroModel.celularValidado = 1;
    cajeroModel.idCompraEstado = 2;
    cajeroModel.idSucursal = idSucursal;
    cajeroModel.sucursal = subsidiaryModel['sucursal'];
    cajeroModel.estado = "Consultando";
    cajeroModel.idCompra = cantidadCards;
    cajeroModel.lt = subsidiaryModel['lt'];
    cajeroModel.lg = subsidiaryModel['lg'];
    
    return cajeroModel;
  }

  Future<String> _createBuyPromotion(promociones, cantidadCards, now, transaction) async{
    String detalle = "Detalle: ";
    promociones.forEach((PromocionModel promocion) async{ 
          Map<String, dynamic> promocionTemp = {};
          
          promocionTemp['id_compra'] = cantidadCards;
          promocionTemp['id_promocion'] = promocion.idPromocion;
          promocionTemp['incentivo'] = promocion.incentivo??"";
          promocionTemp['producto'] = promocion.producto;
          promocionTemp['descripcion'] = promocion.descripcion;
          promocionTemp['precio'] = promocion.precio;
          promocionTemp['cantidad'] = promocion.cantidad;
          promocionTemp['total'] = promocion.costoTotal;
          promocionTemp['imagen'] = promocion.imagen;
          
          promocionTemp['fecha_registro'] = now.toString();
          detalle = detalle+promocion.cantidad.toString()+" / "+promocion.producto+" / "+promocion.descripcion+" / "+promocion.costoTotal.toString()+"/ ("+promocion.dt+")\n";
          
          DocumentReference documentReferenceTemp = await FirebaseFirestore.instance
        .collection('compra_promocion')
        .doc(cantidadCards.toString()+"_"+promocion.idPromocion.toString()); 
        await transaction.set(documentReferenceTemp, promocionTemp);
        DocumentReference documentReferenceTemp2 =await FirebaseFirestore.instance.collection("product").doc("product_"+promocion.idPromocion.toString());
        Map productoTemp = (await documentReferenceTemp2.get()).data() as Map;
        await transaction.update(documentReferenceTemp2, {"ventas":productoTemp['ventas'] + promocion.cantidad,});
    });
    return detalle;
  }

  Future _createBuyChat(int cantidadCards, idSucursal,now, Transaction transaction, id_chat,id_cliente_envia, id_cliente_recibe, mensaje,int envia, int tipo, valor, String tituloNotification, List<String> tokens,int push) async {
    Map<String, dynamic> modelChatSubsidiary = {};
        modelChatSubsidiary['id_chat'] = id_cliente_envia.toString()+"_"+DateTime.now().millisecondsSinceEpoch.toString();
        modelChatSubsidiary['id_compra'] = cantidadCards;
        modelChatSubsidiary['id_cliente_envia'] = int.parse(id_cliente_envia.toString());
        modelChatSubsidiary['id_cliente_recibe'] = int.parse(id_cliente_recibe.toString());
        modelChatSubsidiary['id_compra_estado'] = 2;
        modelChatSubsidiary['mensaje'] = mensaje;
        modelChatSubsidiary['envia'] = envia;
        modelChatSubsidiary['tipo'] = tipo;
        modelChatSubsidiary['valor'] = valor;
        modelChatSubsidiary['estado'] = 2;
        modelChatSubsidiary['fecha_entregado'] = now.toString();
        modelChatSubsidiary['fecha_leido'] = null;
        modelChatSubsidiary['fecha_registro'] = now.toString();
        modelChatSubsidiary['fecha_registro_corto'] = "${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}";
        modelChatSubsidiary['hora'] = "${now.hour}:${now.minute}";
        
        DocumentReference documentReferenceTemp = await FirebaseFirestore.instance
        .collection('compra_chat')
        .doc(id_cliente_envia.toString()+"_"+DateTime.now().millisecondsSinceEpoch.toString());
        await transaction.set(documentReferenceTemp, modelChatSubsidiary);
        // String mensajeNotification = mensaje, tag = push==100 ? "-75132912-" : cantidadCards.toString();
        String mensajeNotification = mensaje, tag = push==100 ? "-75132912-" : cantidadCards.toString();
        Map<String,dynamic> data = {
          "PUSH": push,
          "chat": modelChatSubsidiary,
          "click_action": "FLUTTER_NOTIFICATION_CLICK", 
          "sound": "default", 
          "priority": "high", 
          "content_available": true, 
          "mutable_content": true, 
          "time_to_live": 180,
          "apns": { "headers": { "apns-priority": "10" }, "payload": { "aps": { "sound": "default" } } }, "android": { "priority": "high", "notification": { "sound": "default" } },
          "json":true
        };
        
        String dataJson = jsonEncode(data);
        String tokensJson = jsonEncode(tokens);
        return await createNotification(tokensJson, tituloNotification, mensajeNotification, dataJson, tag);
  }

  Future _createBuy(int cantidadCards, idSucursal, CajeroModel cajero, DireccionModel direccionModel,
  costoEntrega, detalle, costoTotal, now, Transaction  transaction, int tiempo_preparacion, int typePayment, String chargeId, double propina )async {
    Map<String, dynamic> modelSubsidiary = {};
        modelSubsidiary['id_despacho'] = cantidadCards;
        modelSubsidiary['propina'] = double.parse(propina.toString());
        modelSubsidiary['tiempo_preparacion'] = tiempo_preparacion;
        modelSubsidiary['typePayment'] = typePayment;
        modelSubsidiary['chargeId'] = chargeId;
        modelSubsidiary['id_compra'] = cantidadCards;
        modelSubsidiary['id_sucursal'] = idSucursal;
        modelSubsidiary['id_compra_estado'] = 2;
        modelSubsidiary['id_cliente'] = int.parse(_prefs.idCliente);
        modelSubsidiary['id_cajero'] = int.parse(idSucursal.toString());
        modelSubsidiary['paymentStatusAgencia'] = 0;
        modelSubsidiary['paymentStatusMoto'] = 0;
        modelSubsidiary['id_forma_pago'] = cajero?.cardModel?.idFormaPago ?? "10";
        modelSubsidiary['credito_producto'] = 0.0;
        modelSubsidiary['credito'] = 0.0;
        modelSubsidiary['id_direccion'] = direccionModel.idDireccion;  
        modelSubsidiary['calificacionCajero'] = null;
        modelSubsidiary['calificacionCliente'] = null;
        modelSubsidiary['calificarCajero'] = 0;
        modelSubsidiary['calificarCliente'] = 0;
        modelSubsidiary['cash'] = 0;
        modelSubsidiary['chats'] = 0;
        modelSubsidiary['comentarioCajero'] = null;
        modelSubsidiary['comentarioCliente'] = null;
        modelSubsidiary['credito_envio'] = 0;
        modelSubsidiary['detalle'] = detalle;
        modelSubsidiary['fecha_acreditado'] = null;
        modelSubsidiary['acreditado'] = -1;
        modelSubsidiary['fecha_califico_cajero'] = null;
        modelSubsidiary['fecha_califico_cliente'] = null;
        modelSubsidiary['fecha_cancelo'] = null;
        modelSubsidiary['fecha_despachado'] = null;
        modelSubsidiary['fecha_pago'] =now.toString();
        modelSubsidiary['fecha_referencia'] = null;
        modelSubsidiary['id_cancelo'] = null;
        modelSubsidiary['id_cash'] = null;
        modelSubsidiary['id_chat'] = null;
        modelSubsidiary['id_conductor'] = null;
        modelSubsidiary['id_cupon'] = null;
        modelSubsidiary['id_pago'] = null;
        modelSubsidiary['visible'] = 1;
        modelSubsidiary['referencia'] = direccionModel.referencia;
        modelSubsidiary['alias'] = direccionModel.alias;
        modelSubsidiary['lt'] = direccionModel.lt;
        modelSubsidiary['lg'] = direccionModel.lg;
        modelSubsidiary['costo_entrega'] = double.parse(costoEntrega.toString());
        modelSubsidiary['costo_producto'] = costoTotal;
        modelSubsidiary['costo'] = costoTotal;
        modelSubsidiary['transaccion'] = 0;
        modelSubsidiary['descontado'] = 0.0;
        modelSubsidiary['anio'] = now.year;
        modelSubsidiary['mes'] = now.month;
        modelSubsidiary['fecha'] = now.toString().substring(0,10);
        modelSubsidiary['meta'] = utils.headers;  
        modelSubsidiary['hashtag'] = 0;
        modelSubsidiary['id_hashtag'] = 0;
        modelSubsidiary['sinLeerCajero'] = 1;
        modelSubsidiary['sinLeerCliente'] = 1;
        modelSubsidiary['chats'] = 4;
        modelSubsidiary['fecha_registro'] = now.toString();
        modelSubsidiary['fecha_comprada'] = now.toString();
        modelSubsidiary['aCobrar'] = double.parse(cajero?.aCobrar?.toStringAsFixed(2));
        
        DocumentReference documentReferenceTemp = 
        await FirebaseFirestore.instance
        .collection('compra')
        .doc('compra_$cantidadCards');//.set(modelSubsidiary); 
        await transaction.set(documentReferenceTemp, modelSubsidiary);
  }

  Future<List<String>> _getTokensMotorizados()async{
    List<String> tokens = [];
    await FirebaseFirestore.instance.collection("client").where("perfil",isEqualTo: 2)
    .where("on_line", isEqualTo: 1).where("activo",isEqualTo: 1).where("canceladas",isLessThan: 8)
    .get().then((clientes){
      clientes.docs.forEach((cliente) { tokens.add(cliente['token'].toString());});
      
    });
    return tokens;
  }

  iniciar(int tipo, dynamic idCajero, dynamic idSucursal,DireccionModel direccionModel, dynamic costoEntrega, int typePayment, String chargeId, Function response,  {DireccionModel direccionCliente,List<PromocionModel> promociones,CajeroModel cajero,costo,costoTotal,FacturaModel facturaModel, int tiempo_preparacion, double propina}) async {
    if (facturaModel == null) facturaModel = FacturaModel();

    try {
      CajeroModel cajeroModel = CajeroModel();
      DocumentReference documentReference = await FirebaseFirestore.instance.collection('compra').doc('--stats--');
      return FirebaseFirestore.instance.runTransaction((transaction) async {
        // Get the document
        DateTime now = DateTime.now();
        DocumentSnapshot snapshot = await transaction.get(documentReference);
        if (!snapshot.exists) {
          throw Exception("No existe la coleccion Cliente!");
        }
        dynamic cantidadCards = snapshot.get('cantidadCompra') + 1;
        transaction.set(documentReference, {
          'cantidadCompra': cantidadCards,
        });
        
        await FirebaseFirestore.instance
          .collection("subsidiary_schedule")
          .where("activo", isEqualTo: 1)
          .where("dia", isEqualTo: now.weekday)
          .where("id_sucursal", isEqualTo: idSucursal)
          .limit(1)
          .snapshots()
          .asyncMap((schedules) async{
        final List<Future<CajeroModel>> listCatalogo = schedules.docs.map((schedule) async{ 
        Map scheduleMap = schedule.data();
        int desde = int.parse(scheduleMap['desde'].toString().split(":")[0]);
        int hasta = int.parse( scheduleMap['hasta'].toString().split(":")[0]);
        
        if (now.hour >= desde && hasta >= now.hour) {
          String detalle = "Detalle: ";
          detalle = await _createBuyPromotion(promociones, cantidadCards, now, transaction);
          List<String> tokens = await _getTokensMotorizados();
          // List<String> tokens = ['c4WBssjKTcmEwUIjodPLLR:APA91bFQ1O1T8i7SN8t07Uq44b4kTiuJvoA3-rj6UItqKL9fJDVVDR13ibBbhjiMjRGpy2sqNqn0FcmAQ1DnPYAFU493J_EdZEl3QafpQqw1pThJcyBhQH83ttPpc1__clOZ_1MkvOcg'];
          
          Map<String, dynamic> modelClient = (await FirebaseFirestore.instance.collection("client").doc("client_"+_prefs.idCliente.toString()).get()).data(); 
          await _createBuy(cantidadCards, idSucursal, cajero, direccionModel, costoEntrega, detalle ,costoTotal, now, transaction, tiempo_preparacion, typePayment, chargeId, propina);
          await _createBuyChat(cantidadCards, idSucursal, now, transaction, _prefs.idCliente, _prefs.idCliente, idSucursal, "👋 Iniciada", 1, 3, "",'👋 Nueva compra',[modelClient['token']],1122);
          await _createBuyChat(cantidadCards, idSucursal, now, transaction, idSucursal, idSucursal, _prefs.idCliente, "👋 Hola, estamos procesando tu compra...", 2, 1, "",'👋 Nueva compra',[modelClient['token']],1122);
          await _updateAgency(idSucursal,transaction);
          await _createBuyChat(cantidadCards, idSucursal, now, transaction, idSucursal, idSucursal, _prefs.idCliente, "👋 Hola, tienes una nueva solicitud ...", 2, 3, "",'👨🏼‍🚀 Nueva solicitud',tokens,1122);
          await _updateClient(transaction, now);
          cajeroModel = await _getCajeroModel(direccionModel, costoEntrega, costoTotal, detalle, idSucursal, cantidadCards, typePayment, chargeId, propina);
          await _createDispatch(cantidadCards, costoTotal, costoEntrega,idSucursal, direccionModel, cajeroModel, tiempo_preparacion, typePayment, propina);
          
          return cajeroModel;
        }}).toList();
        
        List<CajeroModel> list = await Future.wait(listCatalogo);
        return await list;
      }).firstWhere((cajeroModels) => true).then((cajeroModels){
        
        return response(1, 'Solicitud iniciada', cajeroModels.first);
      });
      });
      //return response(1, 'Solicitud iniciada', cajeroModel);
    } catch (err) {
      print('compra_provider error: $err');
    }
    return response(-100, config.MENSAJE_INTERNET, null);
  }

  String keyNotification1 = "key=AAAAvJkV440:APA91bHgpgFXv0AW0MAKmCcty7I0zP3lW-SWBVHa4nsFfMiKfUcnHmnGxmPW05WoWAfjtSZgfkhs_0oD84gx28IwzHKEfj6ANcz0VyO2qwAg-CerrSmw0kD6SbL2FKygiPN9oBdHGd5X";
  final _notificationBaseUrl = "https://fcm.googleapis.com/fcm/send";

  Future<bool> createNotification(String tokens, String tituloNotification, String mensajeNotification, String data, String tag) async {
    Map<String, String> headers = {
      'Content-type': 'application/json',
      HttpHeaders.authorizationHeader: keyNotification1,
      HttpHeaders.acceptHeader: '/',
      HttpHeaders.hostHeader: "fcm.googleapis.com",
      HttpHeaders.acceptEncodingHeader: "gzip, deflate",
      HttpHeaders.connectionHeader: "keep-alive"
    };
    String body = """{
      "registration_ids": $tokens,
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
  
  Future<Map<String, dynamic>> obtenerAgencia(String idAgencia)async{
      return await (await FirebaseFirestore.instance.collection("agency").doc('agency_'+idAgencia).get()).data();
    }

    Future<bool> actualizarAgencia(String idAgencia, Map<String, dynamic> data)async{
      try {
        await FirebaseFirestore.instance.collection("agency").doc('agency_'+idAgencia).update(data);
        return true;
      } catch (e) {
        return false;
      }
    }
}