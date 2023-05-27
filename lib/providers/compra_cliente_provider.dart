import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../model/cajero_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class CompraClienteProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlListar = 'compra/listar';

  Future<List<CajeroModel>> listarCompras(dynamic anio, dynamic mes) async {
     List<CajeroModel> comprasResponse = [];
    try {
      //return FirebaseFirestore.instance.runTransaction((transaction) async {
      return FirebaseFirestore.instance.collection("compra").where("id_cliente",isEqualTo: int.parse(_prefs.idCliente)).where("visible",isEqualTo: 1)
      .where("anio",isEqualTo: anio).where("mes",isEqualTo: mes).snapshots().asyncMap((compras) async {
        
        DocumentSnapshot documentReferenceClient = await FirebaseFirestore.instance.collection("client").doc("client_"+_prefs.idCliente).get();
        final List<Future<CajeroModel>> listCajero = compras.docs.map((compra) async{
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

}