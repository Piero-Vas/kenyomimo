import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../model/chat_despacho_model.dart';
import '../model/despacho_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/conf.dart' as conf;
import '../utils/utils.dart' as utils;

class ChatDespachoProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final String _urlObtener = 'chat-despacho/obtener';
  final String _urlEnviar = 'chat-despacho/enviar';
  final String _urlEstado = 'chat-despacho/estado';

  Future<List<ChatDespachoModel>> obtener(DespachoModel despachoModel) async {
    // var client = http.Client();
    List<ChatDespachoModel> chatDespachosResponse = [];
    
    try {
      
     await FirebaseFirestore.instance.collection("despacho_chat").where("id_despacho",isEqualTo: int.parse(despachoModel.idDespacho.toString()))
      .orderBy("id_chat",descending: true).get().then((value) {
        value.docs.forEach((element) {
          chatDespachosResponse.add(ChatDespachoModel.fromJson(element.data()));
        });
      });
      return chatDespachosResponse;
    } catch (err) {
      return chatDespachosResponse;
    } 
  }


  Future<ChatDespachoModel> _getChatsModel(despachoModel)async {
    ChatDespachoModel chatdespacho = ChatDespachoModel();
      
      chatdespacho.idChat = despachoModel['id_chat'];
      chatdespacho.idClienteEnvia = despachoModel['id_cliente_envia'];
      chatdespacho.idClienteRecibe = despachoModel['id_cliente_recibe'];
      chatdespacho.mensaje = despachoModel['mensaje'];
      chatdespacho.tipo = despachoModel['tipo'];
      chatdespacho.envia = despachoModel['envia'];
      chatdespacho.estado = despachoModel['estado'];
      chatdespacho.fechaRegistro = despachoModel['fecha_registro_corto'];
      chatdespacho.hora = despachoModel['hora'];
      chatdespacho.idDespacho = despachoModel['id_despacho'];
      chatdespacho.idDespachoEstado = despachoModel['id_despacho_estado'];
      chatdespacho.valor = despachoModel['valor'];
      return chatdespacho;
   
  }


  enviar(ChatDespachoModel chatDespachoModel, DespachoModel despachoModel,
      Function response) async {
    // final resp = await http.post(Uri.parse(Sistema.dominio + _urlEnviar),
    //     headers: utils.headers,
    //     body: {
    //       'idClienteEnvia': _prefs.idCliente,
    //       'idDespacho': despachoModel.idDespacho.toString(),
    //       'auth': _prefs.auth,
    //       'mensaje': chatDespachoModel.mensaje,
    //       'idClienteRecibe': (despachoModel.idConductor.toString() ==
    //               _prefs.idCliente.toString())
    //           ? despachoModel.idCliente.toString()
    //           : despachoModel.idConductor.toString(),
    //       'envia': (despachoModel.idConductor.toString() ==
    //               _prefs.idCliente.toString())
    //           ? conf.CHAT_ENVIA_CAJERO.toString()
    //           : conf.CHAT_ENVIA_CLIENTE.toString(),
    //       'tipo': chatDespachoModel.tipo.toString(),
    //       'valor': chatDespachoModel.valor.toString(),
    //       'idDespachoEstado': despachoModel.idDespachoEstado.toString()
    //     });
    // Map<String, dynamic> decodedResp = json.decode(resp.body);
    // if (decodedResp['estado'] == 1) {
    //   return response(decodedResp['id_chat'], decodedResp['chats']);
    // }
    // return response(0, 0);
    return FirebaseFirestore.instance.runTransaction((transaction) async {
var idDespachoEstado = int.parse(despachoModel.idDespachoEstado.toString()) ;
    var idDespacho = int.parse(despachoModel.idDespacho.toString());
    DateTime now = DateTime.now();
    var id_cliente_envia =  _prefs.idCliente;
    var id_cliente_recibe = (despachoModel.idConductor.toString() ==_prefs.idCliente.toString())? despachoModel.idCliente: despachoModel.idConductor;
    var mensaje =  chatDespachoModel.mensaje.toString();
    var envia = (despachoModel.idConductor.toString() ==  _prefs.idCliente.toString()) ? conf.CHAT_ENVIA_CAJERO.toString() : conf.CHAT_ENVIA_CLIENTE.toString();
    var tipo = chatDespachoModel.tipo;
    var valor = chatDespachoModel.valor.toString();
    DocumentSnapshot documentReferenceClient = await FirebaseFirestore.instance.collection("client").doc("client_"+id_cliente_recibe.toString()).get();
    List<String> tokens = [documentReferenceClient['token']];
    
    if(_prefs.clienteModel.perfil == '2'){
     
      await _createBuyChat( idDespachoEstado, idDespacho,now, transaction,id_cliente_envia, id_cliente_recibe, mensaje, envia, tipo, valor, tokens, "Mensaje de Repartidor", 5);
    }else{
     
       await _createBuyChat( idDespachoEstado, idDespacho,now, transaction,id_cliente_envia, id_cliente_recibe, mensaje, envia, tipo, valor, tokens, "Mensaje de Cliente", 5);
    }
   

    // await _createBuyChat( idDespachoEstado, idDespacho,now, transaction,id_cliente_envia, id_cliente_recibe, mensaje, envia, tipo, valor, tokens, mensaje, 1);
    });
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
        modelChatSubsidiary['envia'] = int.parse(envia) ;
        modelChatSubsidiary['tipo'] = int.parse(tipo.toString()) ;
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

  estadoPush(dynamic idDespacho, dynamic idClienteEnvia, dynamic idClienteRecibe, int estado) async {
    //FALTA ENVIAR NOTIFICACION 
    if(estado == 3){
      await FirebaseFirestore.instance.collection("despacho_chat").where("id_despacho",isEqualTo: idDespacho).where("id_cliente_recibe",isEqualTo: idClienteRecibe)
    .get().then((chats)async{
      Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> chatsTemp = await chats.docs.where((chatTemp) => estado > chatTemp['estado']);
      chatsTemp.forEach((chat) async{
        await FirebaseFirestore.instance.collection("despacho_chat").doc(chat.id).update({"estado":estado, "fecha_leido":DateTime.now().toString()});
      });
    });
    }else{
      await FirebaseFirestore.instance.collection("despacho_chat").where("id_despacho",isEqualTo: idDespacho).where("id_cliente_recibe",isEqualTo: idClienteRecibe)
    .get().then((chats)async{
      Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> chatsTemp = await chats.docs.where((chatTemp) => estado > chatTemp['estado']);
      chatsTemp.forEach((chat) async{
        await FirebaseFirestore.instance.collection("despacho_chat").doc(chat.id).update({"estado":estado, "fecha_entregado":DateTime.now().toString()});
      });
    });
    }
  }
}
