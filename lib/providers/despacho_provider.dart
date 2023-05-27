import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../model/despacho_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class DespachoProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final String _urlListarDepachos = 'despacho/listar-despachos';
  final String _urlIniciar = 'despacho/iniciar';
  final String _urlIRegistrar = 'despacho/registrar';
  final String _urlConfirmarRecogida = 'despacho/confirmar-recogida';
  final String _urlEntregarProducto = 'despacho/entregar-producto';
  final String _urlCancelar = 'despacho/cancelar';
  final String _urlReversar = 'despacho/reversar';
  final String _urlVer = 'despacho/ver';
  final String _urlCalificar = 'despacho/calificar';
  final String _urlMarcarLeido = 'despacho/marcar-leido';
  final String _urlConfirmarnNotificacion = 'despacho/confirmar-notificacion';

  Future<DespachoModel> reversar(DespachoModel despachoModel) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlReversar),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idDespacho': despachoModel.idDespacho.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return DespachoModel.fromJson(decodedResp['despacho']);
    }
    return null;
  }

  Future<DespachoModel> confirmarNoticicacion(
      DespachoModel despachoModel,
      dynamic idClienteRecibe,
      dynamic idClienteEnvia,
      int tipo,
      String preparandose,
      int tipoNotificacion) async {
    final resp = await http.post(
        Uri.parse(Sistema.dominio + _urlConfirmarnNotificacion),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'tipo': tipo.toString(),
          'idClienteRecibe': idClienteRecibe.toString(),
          'idClienteEnvia': idClienteEnvia.toString(),
          'idDespacho': despachoModel.idDespacho.toString(),
          'preparandose': preparandose,
          'tipoNotificacion': tipoNotificacion.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return DespachoModel.fromJson(decodedResp['despacho']);
    }
    return null;
  }

  Future<dynamic> registrar(DespachoModel despachoModel, String desde,
      String hasta, String detalle, String referencia) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlIRegistrar),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idCompra': despachoModel.idCompra.toString(),
          'ltA': despachoModel.ltA.toString(),
          'lgA': despachoModel.lgA.toString(),
          'ltB': despachoModel.ltB.toString(),
          'lgB': despachoModel.lgB.toString(),
          'costo': despachoModel.costo.toString(),
          'costoEnvio': despachoModel.costoEnvio.toString(),
          'desde': desde.toString(),
          'hasta': hasta.toString(),
          'detalle': detalle.toString(),
          'referencia': referencia.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return decodedResp['idDespacho'];
    }
    return 0;
  }

  calificar(DespachoModel despachoModel, Function response) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlCalificar),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idDespacho': despachoModel.idDespacho.toString(),
          'comentarioConductor': despachoModel.comentarioConductor.toString(),
          'calificacionConductor':
              despachoModel.calificacionConductor.toString(),
          'comentarioCliente': despachoModel.comentarioCliente.toString(),
          'calificacionCliente': despachoModel.calificacionCliente.toString(),
          'tipo': despachoModel.tipoUsuario().toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      DespachoModel despachoResponse =
          DespachoModel.fromJson(decodedResp['despacho']);
      return response(1, decodedResp['error'], despachoResponse);
    }
    return response(0, decodedResp['error'], null);
  }

  Future<bool> entregarProducto(DespachoModel despachoModel) async {
     List<Future<DespachoModel>> listCajero = [];
     DespachoModel despachoModelTemp = DespachoModel();
     DateTime now = DateTime.now();
      return FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot documentReferenceClient = await FirebaseFirestore.instance.collection("client").doc("client_"+despachoModel.idCliente.toString()).get();
        List<String> tokens = [documentReferenceClient['token']]; 
        await _updateDespachoEntrega(despachoModel.idDespacho);
        await _updateCompraEntrega(despachoModel.idDespacho);
        await _updateAsignadoEntrega();
        await _createBuyChat(4,despachoModel.idDespacho, now, transaction, despachoModel.idConductor, despachoModel.idCliente, '🥳 Compra entregada', 2, 1, "",tokens,'🥳 Compra entregada',5);
        listCajero.add(Future.value(despachoModelTemp));
        List<DespachoModel> list = await Future.wait(listCajero);
        return true;
      });
  }

  Future _updateDespachoEntrega(idDespacho)async{
    Map<String,dynamic> despachoTemp = {"id_despacho_estado":4};
    await FirebaseFirestore.instance.collection("despacho").doc("despacho_"+idDespacho.toString()).update(despachoTemp);
  }
  Future _updateCompraEntrega(idDespacho)async{
    Map<String,dynamic> compraTemp = {"id_compra_estado":200};
    await FirebaseFirestore.instance.collection("compra").doc("compra_"+idDespacho.toString()).update(compraTemp);
  }

  Future _updateAsignadoEntrega()async{
    DocumentReference documentReferenceTemp =await FirebaseFirestore.instance.collection("asignado").doc("asignado_"+_prefs.idCliente.toString());
    Map<String,dynamic> despachoTemp = (await documentReferenceTemp.get()).data() as Map;
    await FirebaseFirestore.instance.collection("asignado").doc("asignado_"+_prefs.idCliente.toString()).update({'entregado' : 1 + despachoTemp['entregado'] });
  }
  Future<DespachoModel> confirmarRecogida(DespachoModel despachoModel,dynamic idClienteRecibe, dynamic idClienteEnvia, int tipo) async {
    List<Future<DespachoModel>> listCajero = [];
     DespachoModel despachoModelTemp = DespachoModel();
     DateTime now = DateTime.now();
      return FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot documentReferenceClient = await FirebaseFirestore.instance.collection("client").doc("client_"+idClienteRecibe.toString()).get();
        List<String> tokens = [documentReferenceClient['token']]; 
        await _updateDespacho(despachoModel.idDespacho);
        await _updateCompra(despachoModel.idDespacho);
        await _createBuyChat(3,despachoModel.idDespacho, now, transaction, idClienteEnvia, idClienteRecibe, '🛍 Compra en camino', 2, 1, "",tokens,'🛍 Compra en camino',5);
        despachoModelTemp = await ver(despachoModel.idDespacho, tipo);
        listCajero.add(Future.value(despachoModelTemp));
        List<DespachoModel> list = await Future.wait(listCajero);
        return list.first;
      });
  }
  
  Future _updateDespacho(idDespacho)async{
    Map<String,dynamic> despachoTemp = {"id_despacho_estado":3, "fecha_pago":DateTime.now().toString()};
    await FirebaseFirestore.instance.collection("despacho").doc("despacho_"+idDespacho.toString()).update(despachoTemp);
  }

  Future _updateCompra(idDespacho)async{
    Map<String,dynamic> despachoTemp = {"id_compra_estado":4,};
    await FirebaseFirestore.instance.collection("compra").doc("compra_"+idDespacho.toString()).update(despachoTemp);
  }

  iniciar(DespachoModel despachoModelParam, Function response) async {
    List<Future<DespachoModel>> listCajero = [];
    Future.delayed(const Duration(milliseconds: 500));
    return FirebaseFirestore.instance.runTransaction((transaction) async {
    DateTime now = DateTime.now();
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection("despacho").doc("despacho_"+despachoModelParam.idDespacho.toString()).get();
    Map<String, dynamic> despachoModel = documentSnapshot.data();

    if (despachoModel['id_conductor'] != int.parse(_prefs.idCliente.toString())) {
      return response(0, "Ya fue aceptada por otro motorizado" ,null);
    }
    
    Map<String, dynamic> data = {"id_despacho_estado": 2, "id_conductor": int.parse(_prefs.clienteModel.idCliente.toString()), "fecha_iniciado": DateTime.now().toString(),"chats":2,"nombreConductor":_prefs.clienteModel.nombres+" "+_prefs.clienteModel.apellidos,"dniConductor":_prefs.clienteModel.cedula};
    Map<String, dynamic> dataCompra = {"id_compra_estado": 3, "id_conductor": despachoModelParam.idConductor, "chats":6};
    DocumentSnapshot documentReferenceClient = await FirebaseFirestore.instance.collection("client").doc("client_"+despachoModel['id_cliente'].toString()).get();
    DocumentSnapshot documentReferenceCompraEstado = await FirebaseFirestore.instance.collection("despacho_estado").doc("despacho_estado_"+despachoModelParam.idDespachoEstado.toString()).get();
    DocumentSnapshot documentReferenceBuy = await FirebaseFirestore.instance.collection("compra").doc("compra_"+despachoModel['id_compra'].toString()).get();
    await FirebaseFirestore.instance.collection("despacho").doc("despacho_"+despachoModelParam.idDespacho.toString()).update(data);
    await FirebaseFirestore.instance.collection("compra").doc("compra_"+despachoModelParam.idCompra.toString()).update(dataCompra);
    List<String> tokens = [documentReferenceClient['token']];
    await _createBuyChat(2,despachoModelParam.idDespacho, now, transaction, int.parse(_prefs.clienteModel.idCliente.toString()), despachoModelParam.idCliente, '🚀 Despachador asignado', 2, 3, "",tokens,'🚀 Despachador asignado',5);
    await _createBuyChat(2,despachoModelParam.idDespacho, now, transaction, int.parse(_prefs.clienteModel.idCliente.toString()), despachoModelParam.idCliente, "👋 Hola ${despachoModelParam.nombres.split(' ')[0].toString()} mi nombre es ${_prefs.clienteModel.nombres.split(' ')[0].toString()}. 👍 Un gusto poder atenderte", 2, 1, "",tokens,'🚀 Despachador asignado',5);
    await _createAsignado(transaction, now);
    await _updateClientDespacho(transaction, now);
    DespachoModel cajeroModel = await _getCajeroModel(documentReferenceBuy, documentReferenceCompraEstado, documentReferenceClient, despachoModel);
    listCajero.add(Future.value(cajeroModel));
    List<DespachoModel> list = await Future.wait(listCajero);
    
    return response(1, "Postulacion Exitosa" ,list.first);
    });
  }


  Future _createAsignado(transaction,now)async{
    await FirebaseFirestore.instance
        .collection("asignado")
        .where("id_conductor", isEqualTo: int.parse(_prefs.idCliente))
        .get()
        .then((QuerySnapshot value) async {
      if (value.size < 1) {
         Map<String, dynamic> modelAsignado = {};
          modelAsignado['id_conductor'] = int.parse(_prefs.idCliente);
          modelAsignado['asignados'] = 1;
          modelAsignado['recogido'] = 0;
          modelAsignado['entregado'] = 0;
          modelAsignado['cancelada'] = 0;
          modelAsignado['fecha_asignado'] = now.toString();
          modelAsignado['fecha_actualizo'] = now.toString();
          modelAsignado['fecha_registro'] = now.toString();
          
          DocumentReference documentReferenceTemp = await FirebaseFirestore.instance
              .collection('asignado')
              .doc('asignado_'+_prefs.idCliente); 
          await transaction.set(documentReferenceTemp, modelAsignado);
      }else{
        DocumentReference documentReferenceTemp =await FirebaseFirestore.instance.collection("asignado").doc('asignado_'+_prefs.idCliente);
        Map agencyTemp = (await documentReferenceTemp.get()).data() as Map;
        await transaction.update(documentReferenceTemp, {"asignados":agencyTemp['asignados']+1,"fecha_asignado" :now.toString()});
      }
      });
  }

  Future _updateClientDespacho(transaction, now)async {
    DocumentReference documentReferenceTemp =await FirebaseFirestore.instance.collection("client").doc("client_"+_prefs.idCliente.toString());
    Map agencyTemp = (await documentReferenceTemp.get()).data() as Map;
    await transaction.update(documentReferenceTemp, {"confirmados":agencyTemp['confirmados']+1, "fecha_ultima":now.toString(), "registros" : agencyTemp['registros']+1});
  }
  


  Future<bool> marcarLeido(DespachoModel despachoModel) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlMarcarLeido),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idDespacho': despachoModel.idDespacho.toString(),
          'tipo': despachoModel.tipoUsuario().toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return true;
    }
    return false;
  }

  Future<DespachoModel> ver(dynamic idDespacho, int tipo) async {
    
    DespachoModel despachoModel = DespachoModel();
    DocumentSnapshot documentSnapshotDispatch = await FirebaseFirestore.instance.collection("despacho").doc("despacho_"+idDespacho.toString()).get();
    Map<String,dynamic> despachoMap = documentSnapshotDispatch.data();

    DocumentSnapshot documentSnapshotBuy = await FirebaseFirestore.instance.collection("compra").doc("compra_"+idDespacho.toString()).get();
    Map<String,dynamic> buyMap = documentSnapshotBuy.data();
    
    DocumentSnapshot documentSnapshotDispatchStatus = await FirebaseFirestore.instance.collection("despacho_estado").doc("despacho_estado_"+despachoMap['id_despacho_estado'].toString()).get();
    Map<String,dynamic> dispatchStatusMap = documentSnapshotDispatchStatus.data();
    
    DocumentSnapshot documentSubsidiary = await FirebaseFirestore.instance.collection("subsidiary").doc("subsidiary_"+buyMap['id_sucursal'].toString()).get();
    Map<String,dynamic> subsidiarybuyMap = documentSubsidiary.data();
    String idClienteStr = tipo == 0 ? despachoMap['id_conductor'].toString() : despachoMap['id_cliente'].toString();
    DocumentSnapshot documentClient = await FirebaseFirestore.instance.collection("client").doc("client_$idClienteStr").get();
    Map<String,dynamic> clientMap = documentClient.exists ? documentClient.data() : null;

    DocumentSnapshot documentClientSession = await FirebaseFirestore.instance.collection("client_session").doc(buyMap['id_conductor'].toString()).get();
    Map<String,dynamic> clientSessionMap = documentClientSession.exists ? documentClientSession.data() : null;
    
    despachoModel.preparandose = despachoMap['preparandose'];
    despachoModel.tiempoEntrega = despachoMap['tiempo_preparacion'].toString();
    despachoModel.propina = despachoMap['propina'];
    despachoModel.typePayment = despachoMap['typePayment'];
    despachoModel.formaPago = "Efectivo";
    despachoModel.tipo = despachoMap['tipo'];
    despachoModel.propina = despachoMap['propina'];
    despachoModel.despacho = despachoMap['despacho'];
    despachoModel.ltA = despachoMap['ltA'];
    despachoModel.lgA = despachoMap['lgA'];
    despachoModel.ltB = despachoMap['ltB'];
    despachoModel.lgB = despachoMap['lgB'];
    despachoModel.ruta = despachoMap['ruta'];
    despachoModel.idCompra = despachoMap['id_compra'];
    despachoModel.sinLeerCliente = despachoMap['sinLeerCliente'];
    despachoModel.sinLeerConductor = despachoMap['sinLeerConductor'];
    despachoModel.calificacionCliente = despachoMap['calificacionCliente']==null ? 0.0 : despachoMap['calificacionCliente'];
    despachoModel.calificacionConductor = despachoMap['calificacionConductor']==null ? 0.0 : despachoMap['calificacionConductor'];
    despachoModel.calificarCliente = despachoMap['calificarCliente'];
    despachoModel.calificarConductor = despachoMap['calificarConductor'];
    despachoModel.comentarioCliente = despachoMap['comentarioCliente'];
    despachoModel.comentarioConductor = despachoMap['comentarioConductor'];
    despachoModel.costoEnvio = double.parse(despachoMap['costo_entrega'].toString());
    despachoModel.costo = despachoMap['costo'];
    despachoModel.costo = despachoMap['costo'];
    despachoModel.idCliente = despachoMap['id_cliente'];
    despachoModel.idConductor = despachoMap['id_conductor'];
    despachoModel.idDespachoEstado = despachoMap['id_despacho_estado'];
    despachoModel.idDespacho = despachoMap['id_despacho'];
    despachoModel.celularValidado = 1;
    
    despachoModel.costoProducto = buyMap['costo_producto'];
    despachoModel.creditoProducto = double.parse(buyMap['credito_producto'].toString());
    despachoModel.credito = double.parse(buyMap['credito'].toString());
    despachoModel.creditoEnvio = double.parse(buyMap['credito_envio'].toString());
    despachoModel.costoEnvio = buyMap['costo_entrega'];
    despachoModel.costo = buyMap['costo'];
    despachoModel.telSuc = subsidiarybuyMap['contacto'];
    despachoModel.estado = dispatchStatusMap['estado'];
    despachoModel.correctos = clientMap==null ? null : clientMap['correctos'];
    despachoModel.onLine = clientMap==null ? null : clientMap['on_line'];
    despachoModel.celular = clientMap==null ? "Sin conductor" : clientMap['celular'];
    despachoModel.nombres = clientMap==null ? "Sin conductor" : clientMap['nombres'];
    despachoModel.img = clientMap==null ? "https://w7.pngwing.com/pngs/321/641/png-transparent-load-the-map-loading-load-waiting.png" : clientMap['img'];
    despachoModel.codigoPais = "+51";
    despachoModel.lt = clientSessionMap==null ? 0.0 : double.parse(clientSessionMap['lt'].toString());
    despachoModel.lg = clientSessionMap==null ? 0.0 : double.parse(clientSessionMap['lg'].toString());
    return despachoModel;
  }

  Future<DespachoModel> cancelar(DespachoModel despachoModel, dynamic idClienteRecibe, dynamic idClienteEnvia, int tipo) async {
    DespachoModel despachoModelTemp = DespachoModel();
     DocumentSnapshot documentReferenceClient = await FirebaseFirestore.instance.collection("client").doc("client_"+idClienteRecibe.toString()).get();
     List<String> tokens = [documentReferenceClient['token']];
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DateTime now = DateTime.now();
    
    await _createBuyChat(100,despachoModel.idDespacho, now, transaction, idClienteEnvia, idClienteRecibe, '🚫 Compra cancelada',  2, 1, "",tokens,"🚫 Compra cancelada",5);
    await _updateBuy(despachoModel.idDespacho, transaction);
    
    await _createBuyChat(100,despachoModel.idDespacho, now, transaction, idClienteEnvia, idClienteRecibe, '😔 Tu compra se ha cancelado',  2, 1, "",tokens,'🚫 Compra cancelada',5);
    await _updateDispatch(despachoModel.idDespacho, transaction, _prefs.clienteModel.idCliente, now);
    await _updateAsignadoCancelar(transaction,now);
    
    await _createBuyChat(100,despachoModel.idDespacho, now, transaction, idClienteEnvia, idClienteRecibe, '🚫 Compra cancelada',  2, 1, "",tokens,"🚫 Compra cancelada",5);
    despachoModelTemp = await ver(despachoModel.idDespacho, tipo);
      return despachoModelTemp;
    });
  }

  

  Future _updateAsignadoCancelar(transaction, now)async {
    DocumentReference documentReferenceTemp =await FirebaseFirestore.instance.collection("asignado").doc("asignado_"+_prefs.idCliente.toString());
    Map agencyTemp = (await documentReferenceTemp.get()).data() as Map;
    await transaction.update(documentReferenceTemp, {"cancelada":agencyTemp['cancelada']+1 });
  }
  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0' + numberStr;
    }
    return numberStr;
  }

  Future<bool> _createBuyChat(int idDespachoEstado, int idDespacho,now, Transaction transaction,id_cliente_envia, id_cliente_recibe, mensaje, envia, tipo, valor, List<String> tokens, String tituloNotification, int push) async {
    Map<String, dynamic> modelChatSubsidiary = {};
        DateTime now = DateTime.now();
        modelChatSubsidiary['id_chat'] = int.parse('${DateTime.now().millisecondsSinceEpoch}');
        modelChatSubsidiary['id_despacho'] = idDespacho;
        modelChatSubsidiary['id_cliente_envia'] = int.parse(id_cliente_envia.toString());
        modelChatSubsidiary['id_cliente_recibe'] = int.parse(id_cliente_recibe.toString());
        modelChatSubsidiary['id_despacho_estado'] = idDespachoEstado;
        modelChatSubsidiary['mensaje'] = mensaje;
        modelChatSubsidiary['envia'] = envia;
        modelChatSubsidiary['tipo'] = tipo;
        modelChatSubsidiary['valor'] = valor;
        modelChatSubsidiary['estado'] = 1;
        modelChatSubsidiary['fecha_entregado'] = now.toString();
        modelChatSubsidiary['fecha_leido'] = null;
        modelChatSubsidiary['fecha_registro'] = now.toString();
        modelChatSubsidiary['fecha_registro_corto'] = "${now.year}-${_formatNumber(now.month)}-${_formatNumber(now.day)} ${_formatNumber(now.hour)}:${_formatNumber(now.minute)}";
        modelChatSubsidiary['hora'] = "${_formatNumber(now.hour)}:${_formatNumber(now.minute)}";
         
        DocumentReference documentReferenceTemp = await FirebaseFirestore.instance
        .collection('despacho_chat')
        .doc(id_cliente_envia.toString()+"_"+DateTime.now().millisecondsSinceEpoch.toString()); 
        await transaction.set(documentReferenceTemp, modelChatSubsidiary);
        String mensajeNotification = mensaje, tag = idDespacho.toString();
        Map<String,dynamic> data = {
          "PUSH": push,
          "chat": modelChatSubsidiary,
          "click_action": "FLUTTER_NOTIFICATION_CLICK", 
          "sound": "default", "priority": "high", "content_available": true, "mutable_content": true, "time_to_live": 180,
          "apns": { "headers": { "apns-priority": "10" }, "payload": { "aps": { "sound": "default" } } }, "android": { "priority": "high", "notification": { "sound": "default" } },
          "json":true
        };
        String dataJson = jsonEncode(data);
        String tokensJson = jsonEncode(tokens);
        return await createNotification(tokensJson, tituloNotification, mensajeNotification, dataJson, tag);
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

  Future<List<DespachoModel>> listarCompras(int tipo, String fecha) async {
    List<DespachoModel> despachoResponse = [];
    if (tipo == 0) {
      try {
      return FirebaseFirestore.instance.collection("despacho").where("id_despacho_estado",isEqualTo: 1).where("id_conductor",isNull: true )
      .snapshots().asyncMap((despachos) async {
        
        final List<Future<DespachoModel>> listCajero = despachos.docs.map((despacho) async{
          Map despachoModel = despacho.data();
          DocumentSnapshot documentReferenceClient = await FirebaseFirestore.instance.collection("client").doc("client_"+despachoModel['id_cliente'].toString()).get();
          DocumentSnapshot documentReferenceCompraEstado = await FirebaseFirestore.instance.collection("despacho_estado").doc("despacho_estado_"+despachoModel['id_despacho_estado'].toString()).get();
          DocumentSnapshot documentReferenceBuy = await FirebaseFirestore.instance.collection("compra").doc("compra_"+despachoModel['id_compra'].toString()).get();
          DespachoModel cajeroModel = await _getCajeroModel(documentReferenceBuy, documentReferenceCompraEstado, documentReferenceClient, despachoModel);
          if(cajeroModel != null) return cajeroModel;
        }).toList(); 
        List<DespachoModel> list = await Future.wait(listCajero);
        return await list;
      }).firstWhere((catalogo) => true).then((catalogo) async { 
            despachoResponse.addAll(await catalogo);
            despachoResponse.removeWhere((element) => element==null);
            return despachoResponse;
      });
    } catch (err) {
      return despachoResponse;
    } 
    }else if (tipo == 1){
      try {
      return FirebaseFirestore.instance.collection("despacho").where("id_despacho_estado",isNotEqualTo: 1).where("id_conductor",isEqualTo: int.parse(_prefs.idCliente)).where("fecha",isEqualTo: '${fecha.substring(0,10)}' )
      .snapshots().asyncMap((despachos) async {
       
        final List<Future<DespachoModel>> listCajero = despachos.docs.map((despacho) async{
          Map despachoModel = despacho.data();
          DocumentSnapshot documentReferenceClient = await FirebaseFirestore.instance.collection("client").doc("client_"+despachoModel['id_cliente'].toString()).get();
          DocumentSnapshot documentReferenceCompraEstado = await FirebaseFirestore.instance.collection("despacho_estado").doc("despacho_estado_"+despachoModel['id_despacho_estado'].toString()).get();
          DocumentSnapshot documentReferenceBuy = await FirebaseFirestore.instance.collection("compra").doc("compra_"+despachoModel['id_compra'].toString()).get();
          DespachoModel cajeroModel = await _getCajeroModel(documentReferenceBuy, documentReferenceCompraEstado, documentReferenceClient, despachoModel);
          if(cajeroModel != null) return cajeroModel;
        }).toList(); 
        List<DespachoModel> list = await Future.wait(listCajero);
        return await list;
      }).firstWhere((catalogo) => true).then((catalogo) async { 
            despachoResponse.addAll(await catalogo);
            despachoResponse.removeWhere((element) => element==null);
            return despachoResponse;
      });
    } catch (err) {
      return despachoResponse;
    } 
    }else{
      return despachoResponse;
    }
  }

  Future<DespachoModel> _getCajeroModel(documentReferenceBuy,documentReferenceCompraEstado, documentReferenceClient, despachoModel)async {
    DespachoModel cajeroModel = DespachoModel();
    if (documentReferenceBuy.exists &&
        documentReferenceCompraEstado.exists &&
        documentReferenceClient.exists) {
      
      Map compraEstadoModel = documentReferenceCompraEstado.data();
      Map buyModel = documentReferenceBuy.data();
      Map clientModel = documentReferenceClient.data();
      
      //DESPAHO
      cajeroModel.preparandose = despachoModel['preparandose'];
      cajeroModel.tipo = despachoModel['tipo'];
      cajeroModel.telSuc = "";
      cajeroModel.propina = despachoModel['propina'];
      
      cajeroModel.sinLeerCliente = int.parse(despachoModel['sinLeerCliente'].toString());
      cajeroModel.sinLeerConductor = int.parse(despachoModel['sinLeerConductor'].toString());
      cajeroModel.calificarCliente = despachoModel['calificarCliente'];
      cajeroModel.calificarConductor = despachoModel['calificarConductor'];
      cajeroModel.calificacionCliente = despachoModel['calificacionCliente']==null ? 0.0 : despachoModel['calificacionCliente'];
      cajeroModel.calificacionConductor = despachoModel['calificacionConductor']==null ? 0.0 : despachoModel['calificacionConductor'];
      cajeroModel.ltA = double.parse(despachoModel['ltA'].toString());
      cajeroModel.lgA = double.parse(despachoModel['lgA'].toString());
      cajeroModel.despacho = despachoModel['despacho'];
      cajeroModel.ruta = despachoModel['ruta'];
      cajeroModel.idCompra = despachoModel['id_compra'];
      cajeroModel.comentarioCliente = despachoModel['comentarioCliente'];
      cajeroModel.comentarioConductor = despachoModel['comentarioConductor'];
      cajeroModel.lgB = despachoModel['lgB'];
      cajeroModel.ltB = despachoModel['ltB'];
      cajeroModel.idConductor = despachoModel['id_conductor'];
      cajeroModel.idCliente = despachoModel['id_cliente'];
      cajeroModel.idDespachoEstado = despachoModel['id_despacho_estado'];
      cajeroModel.idDespacho = despachoModel['id_despacho'];
      cajeroModel.typePayment = despachoModel['typePayment'];
      cajeroModel.tiempoEntrega = despachoModel['tiempo_preparacion'].toString();

      //COMPRA
      cajeroModel.costoProducto = buyModel['costo_producto'];
      cajeroModel.credito = buyModel['credito'];
      cajeroModel.creditoProducto = buyModel['credito_producto'];
      cajeroModel.creditoEnvio = double.parse(buyModel['credito_envio'].toString());
      cajeroModel.costoEnvio = double.parse(buyModel['costo_entrega'].toString());
      cajeroModel.costo = buyModel['costo'];
      

      //CLIENTE
      cajeroModel.codigoPais = clientModel['codigoPais']; 
      cajeroModel.celular = clientModel['celular'];
      cajeroModel.nombres = clientModel['nombres'].toString()+" "+clientModel['apellidos'].toString();
      cajeroModel.img = clientModel['img'];
      cajeroModel.correctos = clientModel['correctos'];
      cajeroModel.celularValidado = clientModel['celularValidado'];
      cajeroModel.onLine = int.parse(clientModel['on_line'].toString());
      //COMPRA ESTADO
      cajeroModel.estado = compraEstadoModel['estado'];
      return cajeroModel;
    }else{ return null;}
  }
}