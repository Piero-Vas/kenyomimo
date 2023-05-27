import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';

import '../model/promocion_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class PromocionProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlSubirImagen = 'g/promocion/subir';
  final String _urlListar = 'promocion/listar';
  final String _urlEditar = 'g/promocion/editar';
  final String _urlEditarSubProductos = 'g/promocion/editar-sub-productos';

  bool _cargando = false;
  int _pagina = 0;

  Future<bool> subirArchivoMobil(io.File imagen, dynamic nombreImagen,
      String id, dynamic idagencia, dynamic idurbe, int targetWidth) async {
    ImageProperties properties =
        await FlutterNativeImage.getImageProperties(imagen.path);
    io.File compressedFile = await FlutterNativeImage.compressImage(imagen.path,
        targetWidth: targetWidth,
        targetHeight:
            (properties.height * targetWidth / properties.width).round());
    try {
      final mimeType = mime(compressedFile.path).split('/'); //  image/jpeg
      FormData formData = new FormData.fromMap({
        "promocion": await MultipartFile.fromFile(compressedFile.path,
            contentType: MediaType(mimeType[0], mimeType[1]))
      });
      var headers = utils.headers;
      headers['archivo'] = nombreImagen.toString();
      headers['idcliente'] = _prefs.idCliente.toString();
      headers['idagencia'] = idagencia.toString();
      headers['idurbe'] = idurbe.toString();
      headers['id'] = id.toString();
      await Dio().post(
        Sistema.dominio + _urlSubirImagen,
        data: formData,
        options: Options(headers: headers),
      );
      return false;
    } catch (err) {
      print('promocion_provider error 1: $err');
    }
    return false;
  }

  Future<bool> subirArchivoWeb(
      List<int> value, String nombreImagen, String id) async {
    try {
      FormData formData = FormData.fromMap({
        "promocion": MultipartFile.fromBytes(value, filename: nombreImagen),
      });
      var headers = utils.headers;
      headers['archivo'] = nombreImagen.toString();
      headers['id'] = id.toString();
      await Dio().post(
        Sistema.dominio + _urlSubirImagen,
        data: formData,
        options: Options(headers: headers),
      );
      return false;
    } catch (err) {
      print('promocion_provider error 2: $err');
    }
    return false;
  }

  Future<List<PromocionModel>> listarPromociones(String idUrbe, bool isClean, String criterio, int categoria) async {
    List<PromocionModel> promocionesResponse = [];
    try{
      return await FirebaseFirestore.instance.runTransaction((transaction) async {
            Query queryAgency;
            if(categoria==0){
              queryAgency = FirebaseFirestore.instance.collection("agency").where("activo",isEqualTo: 1).where("tipo",isEqualTo: 1);
            }else{
              queryAgency = FirebaseFirestore.instance.collection("agency").where("activo",isEqualTo: 1).where("id_categoria",isEqualTo: categoria).where("tipo",isEqualTo: 1);
            }
            await queryAgency.get().then((agencys){
              if(agencys.size>0){
                DateTime day = DateTime.now(); 
                agencys.docs.forEach((agency) async{
                  Map agencyMap = agency.data();
                  await FirebaseFirestore.instance.collection("subsidiary_schedule").where("activo",isEqualTo: 1).where("dia",isEqualTo: day.weekday)
                  .where("id_sucursal",isEqualTo: agencyMap['id_agencia']).limit(1).get().then((schedules) async{
                    if(schedules.size>0){
                        Map scheduleMap = schedules.docs.first.data();
                        int desde = int.parse(scheduleMap['desde'].toString().split(":")[0]);
                        int hasta = int.parse(scheduleMap['hasta'].toString().split(":")[0]);
                        DateTime now = DateTime.now();
                        if (now.hour >= desde && hasta >= now.hour) {
                          await FirebaseFirestore.instance.collection("product").where("activo",isEqualTo: 1).where("aprobado",isEqualTo: 1)
                          .where("id_agencia",isEqualTo: agencyMap['id_agencia']).where("visible",isEqualTo: 1).where("tipo",isEqualTo: 1).get()
                          .then((products){
                            if(products.size>0){
                              PromocionModel productoModelTemp = PromocionModel();
                              products.docs.forEach((product) {
                                Map productoMap = product.data();
                                productoModelTemp.estado = 1;
                                productoModelTemp.activo = productoMap['activo'];
                                productoModelTemp.mensaje = "Local Cerrado";
                                productoModelTemp.promocion = productoMap['promocion'];
                                productoModelTemp.productos = null;
                                productoModelTemp.tipo = productoMap['tipo'];
                                productoModelTemp.aprobado = productoMap['aprobado'];
                                productoModelTemp.visible = productoMap['visible'];
                                productoModelTemp.tiempo_preparacion = productoMap['tiempo_preparacion'].toString();
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
                                promocionesResponse.add(productoModelTemp);
                              });
                            }
                          }); 
                        }
                    }
                  });
                });
              }
            });
          return promocionesResponse;
        });
    }catch (err){
      print("promocion_provider error 3: $err");
    }
    return promocionesResponse;
  }

  Future<bool> editar(PromocionModel promocion) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlEditar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'idAgencia': promocion.idAgencia.toString(),
            'idUrbe': promocion.idUrbe.toString(),
            'incentivo': promocion.incentivo.toString(),
            'producto': promocion.producto.toString(),
            'descripcion': promocion.descripcion.toString(),
            'precio': promocion.precio.toString(),
            'minimo': promocion.minimo.toString(),
            'maximo': promocion.maximo.toString(),
            'inventario': promocion.inventario.toString(),
            'activo': promocion.activo.toString(),
            'visible': promocion.visible.toString(),
            'promocion': promocion.promocion.toString(),
            'idPromocion': promocion.idPromocion.toString()
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        return true;
      }
    } catch (err) {
      print('promocion_provider error 4: $err');
    } finally {
      client.close();
    }
    return false;
  }

  Future<bool> editarSubProductos(PromocionModel promocion) async {
    var client = http.Client();
    try {
      final resp = await client.post(
          Uri.parse(Sistema.dominio + _urlEditarSubProductos),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'idPromocion': promocion.idPromocion.toString(),
            'productos': promocion.productos.toJson().toString()
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        return true;
      }
    } catch (err) {
      print('promocion_provider error 5: $err');
    } finally {
      client.close();
    }
    return false;
  }
}