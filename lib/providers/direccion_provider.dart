import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../model/cliente_model.dart';
import '../model/direccion_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class DireccionProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  Future<bool> eliminarDireccion(DireccionModel direccionModel) async {
    await FirebaseFirestore.instance.collection("address").doc(direccionModel.idDireccion.toString()).update({"eliminada":1});
    DocumentReference documentReferenceTemp = await FirebaseFirestore.instance.collection("client").doc("client_"+_prefs.idCliente.toString());
    Map agencyTemp = (await documentReferenceTemp.get()).data() as Map;
    await FirebaseFirestore.instance.collection("client").doc("client_"+_prefs.idCliente.toString()).update({"direcciones":agencyTemp['direcciones']-1});
    return true;
  }

  Future<bool> editarDireccion(DireccionModel direccionModel) async {
    Map direccion = direccionModel.toJson();
    direccion['referencia'] = direccionModel.referencia.toString();
    direccion['alias'] = direccionModel.alias.toString();
    direccion['lt'] = direccionModel.lt;
    direccion['lg'] = direccionModel.lg;
    direccion['idUrbe'] = direccionModel.idUrbe;
    direccion['img'] = "https://cdn-icons-png.flaticon.com/512/3176/3176130.png";
    direccion['auth'] = _prefs.auth;
    await FirebaseFirestore.instance.collection("address").doc(direccionModel.idDireccion.toString()).update(direccion);
    return true;
  }

  Future<Map> crearDireccion(DireccionModel direccionModel) async {
    DateTime now = DateTime.now();
    Map direccion = direccionModel.toJson();
    direccion['id_cliente'] = int.parse(_prefs.idCliente);
    direccion['id_direccion'] = int.parse(_prefs.idCliente+""+now.millisecondsSinceEpoch.toString());
    direccion['fecha_registro'] = now.toString();
    direccion['eliminada'] = 0;
    direccion['img'] = "https://cdn-icons-png.flaticon.com/512/3176/3176130.png";
    direccion['auth'] = _prefs.auth;
    await FirebaseFirestore.instance.collection("address").doc(_prefs.idCliente+now.millisecondsSinceEpoch.toString()).set(direccion);
    DocumentReference documentReference = await FirebaseFirestore.instance.collection("address").doc(_prefs.idCliente+now.millisecondsSinceEpoch.toString());
    ClienteModel clienteModel = _prefs.clienteModel;
    await FirebaseFirestore.instance.collection("client").doc("client_"+_prefs.idCliente.toString()).update({'direcciones':clienteModel.direcciones + 1});
    clienteModel.direcciones = clienteModel.direcciones + 1;
    _prefs.clienteModel = clienteModel;
    return documentReference.get().then((DocumentSnapshot documentSnapshot) => documentSnapshot.data() as Map);
    //return int.parse(documentReference.id);
  }

  Future<List<DireccionModel>> listarDirecciones() async {
    List<DireccionModel> direccionesResponse = [];
    try {
      await FirebaseFirestore.instance.collection("address").where("eliminada",isEqualTo: 0).where("id_cliente",isEqualTo: int.parse(_prefs.idCliente))
      .get().then((addresses){
        if(addresses.size>0){
          addresses.docs.forEach((address) {
            DireccionModel direccionModel = DireccionModel();
            Map addressMap = address.data();
            direccionModel.idDireccion = addressMap['id_direccion'];
            direccionModel.idCliente = addressMap['id_cliente'];
            direccionModel.fechaRegistro = addressMap['fecha_registro'];
            direccionModel.alias = addressMap['alias'];
            direccionModel.referencia = addressMap['referencia'];
            direccionModel.img = addressMap['img'];
            direccionModel.lt = addressMap['lt'];
            direccionModel.lg = addressMap['lg'];
            direccionModel.idUrbe  = addressMap['id_urbe'];
            direccionesResponse.add(direccionModel);
           });
           return direccionesResponse;
        }
      });
    } catch (err) {
      print('direccion_provider error: $err');
    } 
    return direccionesResponse;
  }
}