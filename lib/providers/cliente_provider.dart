import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import '../bloc/preferencias_bloc.dart';
import '../model/cliente_model.dart';
import '../model/notificacion_model.dart';
import '../model/session_model.dart';
import '../preference/push_provider.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/conf.dart' as config;
import '../utils/upload.dart' as upload;
import '../utils/utils.dart' as utils;
import 'package:intl/intl.dart';

class ClienteProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final String _urlMensaje = 'cliente/mensaje';
  final String _urlVer = 'cliente/ver';
  final String _urlAutenticarClave = 'cliente/autenticar-clave';
  final String _urlAutenticarApple = 'cliente/autenticar-apple';
  final String _urlAutenticarGoogle = 'cliente/autenticar-google';
  final String _urlAutenticarFacebook = 'cliente/autenticar-facebook';
  final String _urlActualizarToken = 'cliente/actualizar-token';
  final String _recuperarContrasenia = 'cliente/recuperar-contrasenia';
  final String _urlCerrarSession = 'cliente/cerrar-session';
  final String _urlEditar = 'cliente/editar';
  final String _urlCambiarContrasenia = 'cliente/cambiar-contrasenia';
  final String _urlCambiarImagen = 'cliente/cambiar-imagen';
  final String _urlLike = 'cliente/like';
  final String _urlUrbe = 'cliente/urbe';
  final String _urlLink = 'cliente/link';
  final String _urlRastrear = 'cliente/rastrear';
  final String _urlSessiones = 'cliente/sessiones';
  final String _urlGenero = 'cliente/genero';
  final String _urlVerificarValidadCelular =
      'cliente/verificar-validar-celular';
  final String _urlValidadCelular = 'cliente/validar-celular';
  final String _urlEscuchar = 'cliente/escuchar';
  final String _urlCanjear = 'cliente/canjear';
  final String _urlSaldo = 'saldo/ver';

  urbe(dynamic idUrbe) async {
    /* var client = http.Client();
    try {
      await client.post(Uri.parse(Sistema.dominio + _urlUrbe),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'idUrbe': idUrbe.toString(),
            'auth': _prefs.auth,
          });
    } catch (err) {
      print('cliente_provider 1 error: $err');
    } finally {
      client.close();
    } */
  }

  mensaje(String idMensaje, int accion) async {
    var client = http.Client();
    try {
      await client.post(Uri.parse(Sistema.dominio + _urlMensaje),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'perfil': _prefs.clienteModel.perfil.toString(),
            'idMensaje': idMensaje,
            'accion': accion.toString(),
          });
    } catch (err) {
      print('cliente_provider 2 error: $err');
    } finally {
      client.close();
    }
  }

  saldo(dynamic idCliente, Function response) async {
    var client = http.Client();

    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlSaldo),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'perfil': _prefs.clienteModel.perfil.toString(),
            'dir': _prefs.clienteModel.direcciones.toString(),
            'idClienteSaldo': idCliente.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);

      if (decodedResp['estado'] == 1) {
        try {
          return response(
            double.parse(decodedResp['s']['saldo'].toString())
                .toStringAsFixed(2),
            double.parse(decodedResp['s']['credito'].toString())
                .toStringAsFixed(2),
            double.parse(decodedResp['s']['cash'].toString())
                .toStringAsFixed(2),
          );
        } catch (err) {
          print('cliente_provider saldo error: $err');
        }
      }
      return response('0.00', '0.00', '0.00');
    } catch (err) {
      print('cliente_provider 3 error: $err');
    } finally {
      client.close();
    }
    //Retornamos el saldo y el credito
    return response('0.00', '0.00', '0.00');
  }

  canjear(dynamic idClienteRefiere, int tipo) async {
    if (idClienteRefiere.toString() == _prefs.idCliente.toString()) return;
    var client = http.Client();
    try {
      await client.post(Uri.parse(Sistema.dominio + _urlCanjear),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'idClienteRefiere': idClienteRefiere.toString(),
            'tipo': tipo.toString(),
          });
    } catch (err) {
      print('cliente_provider 4 error: $err');
    } finally {
      client.close();
    }
  }

  link(dynamic idCliente, String link) async {
    var client = http.Client();
    try {
      await client.post(Uri.parse(Sistema.dominio + _urlLink),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'link': link.toString(),
          });
    } catch (err) {
      print('cliente_provider 5 error: $err');
    } finally {
      client.close();
    }
  }

 Stream<Map<String,dynamic>> escuchar(dynamic idRastreo) {
    return FirebaseFirestore.instance.collection('drivers').doc(idRastreo).snapshots().map(
          (DocumentSnapshot snapshot) => snapshot.data() as Map<String,dynamic>);
 }

 updateUser(Map<String, dynamic> data)async {
  
   await FirebaseFirestore.instance
        .collection('drivers')
        .doc(data['id'])
        .set(data);
  }

  Future rastrear(bool rastrear) async {
    var client = http.Client();
    try {
      await FirebaseFirestore.instance
          .collection("client_session")
          .doc(_prefs.idCliente)
          .update({
        'rastrear': rastrear ? 1 : 0,
      }).then((value) {
        return true;
      });
    } catch (err) {
      print('cliente_provider 7 error: $err');
    } finally {
      client.close();
    }
    return false;
  }

  //FALTA ESTO CONTIENE NOTIFICACION
  Future enviarRastreo(double lt, double lg) async {
    try {
      DateTime initialDate = DateTime.now();
      final fC = new DateFormat('yyyy-MM-dd');
       DateTime now = DateTime.now();
       FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentReference documentReferenceCards = FirebaseFirestore.instance
              .collection('track_register')
              .doc(_prefs.idCliente);
         await transaction.set(documentReferenceCards, {
            'fecha': fC.format(initialDate),
            'id_cliente':int.parse(_prefs.idCliente),
            'imei':utils.headers['imei'] ,
            'p': {'lg':lg.toString(),'lt': lt.toString(), },
            'hora':now.hour.toString()+':'+ now.minute.toString()+':'+now.second.toString(),
          });
        });
        await FirebaseFirestore.instance
          .collection("client_session")
          .doc(_prefs.idCliente)
          .update({
            'lt':lt.toString(),
            'lg':lg.toString(),
            'utc':now.toString()
          }).then((value) {
            return true;
          });
    } catch (err) {
      print('cliente_provider 8 error: $err');
    } 
    return false;
  }

  verificarValidadCelular(dynamic celular, Function response) async {
    var client = http.Client();
    try {
      final resp = await client.post(
          Uri.parse(Sistema.dominio + _urlVerificarValidadCelular),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'celular': celular.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      return response(decodedResp['estado'], decodedResp['error']);
    } catch (err) {
      print('cliente_provider 9 error: $err');
    } finally {
      client.close();
    }
    return response(0, config.MENSAJE_INTERNET);
  }

  validadCelular(dynamic celular, {dynamic idClienteVerificar: 0}) async {
    var client = http.Client();
    try {
      final resp = await client.post(
          Uri.parse(Sistema.dominio + _urlValidadCelular),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'idClienteVerificar': idClienteVerificar == 0
                ? _prefs.idCliente
                : idClienteVerificar.toString(),
            'auth': _prefs.auth,
            'celular': celular.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (idClienteVerificar == 0 && decodedResp['estado'] == 1) {
        ClienteModel clienteModel =
            ClienteModel.fromJson(decodedResp['cliente']);
        _prefs.clienteModel = clienteModel;
        _prefs.sms = '';
      }
    } catch (err) {
      print('cliente_provider 10 error: $err');
    } finally {
      client.close();
    }
  }

  genero(ClienteModel cliente) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlGenero),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'sexo': cliente.sexo.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) _prefs.clienteModel = cliente;
    } catch (err) {
      print('cliente_provider 11 error: $err');
    } finally {
      client.close();
    }
  }

  Future<List<SessionModel>> listarSessiones() async {
    var client = http.Client();
    List<SessionModel> sessionesResponse = [];
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlSessiones),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);

      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['sessiones']) {
          sessionesResponse.add(SessionModel.fromJson(item));
        }
      }
    } catch (err) {
      print('cliente_provider 12 error: $err');
    } finally {
      client.close();
    }
    return sessionesResponse;
  }

  like(dynamic idCliente, String like) async {
    var client = http.Client();
    try {
      await client.post(Uri.parse(Sistema.dominio + _urlLike),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'idClienteLike': idCliente.toString(),
            'auth': _prefs.auth,
            'like': like.toString(),
          });
    } catch (err) {
      print('cliente_provider 13 error: $err');
    } finally {
      client.close();
    }
  }

  cambiarImagen(dynamic img, Function response) async {
    try {
      await FirebaseFirestore.instance
          .collection("client")
          .doc("client_" + _prefs.idCliente.toString())
          .update({"img": img});
      return response(1, "Actualizacion correcta");
    } catch (err) {
      print('cliente_provider 14 error: $err');
      return response(0, config.MENSAJE_INTERNET);
    }
  }

  Future<String> subirArchivoMobil(File imagen, String nombreImagen) async {
    try {
      return await upload.subirArchivoMobil(
          imagen, 'uss/$nombreImagen', Sistema.TARGET_WIDTH_PERFIL);
    } catch (err) {
      print('cliente_provider 15 error: $err');
    }
    return '';
  }

  Future<String> subirArchivoWeb(List<int> value, String nombreImagen) async {
    try {
      return await upload.subirArchivoWeb(value, 'uss/$nombreImagen');
    } catch (err) {
      print('cliente_provider 16 error: $err');
    }
    return '';
  }

  cambiarContrasenia(dynamic contraseniaAnterior, dynamic contraseniaNueva,
      Function response) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("client")
          .doc("client_" + _prefs.idCliente.toString())
          .get();
      Map<String, dynamic> clientMap = documentSnapshot.data() ?? {};
      if (documentSnapshot.exists &&
          clientMap["clave"] == contraseniaAnterior) {
        await FirebaseFirestore.instance
            .collection("client")
            .doc("client_" + _prefs.idCliente.toString())
            .update({"clave": contraseniaNueva});
        return response(1, "Se realizo el cambio con exito!");
      }
      return response(1, "Clave anterior incorrecta!");
    } catch (err) {
      print('cliente_provider 17 error: $err');
    }
    return response(0, config.MENSAJE_INTERNET);
  }

  editar(ClienteModel cliente, Function response) async {
    try {
      await FirebaseFirestore.instance
          .collection("client")
          .doc("client_" + _prefs.idCliente.toString())
          .update({
        "correo": cliente.correo.toString(),
        "nombres": cliente.nombres.toString(),
        "apellidos": cliente.apellidos.toString()
      });
      _prefs.clienteModel.correo = cliente.correo.toString();
      _prefs.clienteModel.nombres = cliente.nombres.toString();
      _prefs.clienteModel.apellidos = cliente.apellidos.toString();
      _prefs.clienteModel = cliente;
      
      return response(1, "▲ Cambio con exito ▼ ↔ ↨ ◘ ◙ ► ◄ ▬");
    } catch (err) {
      print('cliente_provider 18 error: $err');
    }
    return response(0, config.MENSAJE_INTERNET);
  }

  Future cerrarSession(Function response,
      {dynamic idPlataforma, dynamic imei, int all: 0}) async {
    try {
      await FirebaseFirestore.instance
          .collection("client")
          .doc("client_" + _prefs.idCliente.toString())
          .update({"on_line": 0});
      return response(1, "Sesion cerrada");
    } catch (err) {
      print("Cliente Provider 19 " + err.toString());
      return response(0, config.MENSAJE_INTERNET);
    }
  }

  recuperarContrasenia(
      ClienteModel clienteModel, int tipo, Function response) async {
    var client = http.Client();
    try {
      final resp = await client.post(
          Uri.parse(Sistema.dominio + _recuperarContrasenia),
          headers: utils.headers,
          body: {
            'celular': clienteModel.celular.toString(),
            'correo': clienteModel.correo.toString(),
            'tipo': tipo.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) return response(1, decodedResp['error']);
      return response(0, decodedResp['error']);
    } catch (err) {
      print('cliente_provider 20 error: $err');
    } finally {
      client.close();
    }
    return response(0, config.MENSAJE_INTERNET);
  }

  PreferenciasBloc preferenciasBloc = PreferenciasBloc();

  ver(Function response) async {
    var client = http.Client();
    NotificacionModel notificacionModel = NotificacionModel();
    int push = 0;
    
    return response(1, config.MENSAJE_INTERNET, push, notificacionModel);
  }

  var _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  clienteSession() async {
    DateTime now = DateTime.now();
    await FirebaseFirestore.instance.collection("client").doc("client_" +_prefs.idCliente.toString()).update({"on_line":1});
    await FirebaseFirestore.instance
        .collection("client_session")
        .where("id_cliente", isEqualTo: _prefs.idCliente)
        // .snapshots()
        .get()
        .then((QuerySnapshot value) async {
      if (value.size < 1) {
        return FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentReference documentReferenceCards = FirebaseFirestore.instance
              .collection('client_session')
              .doc(_prefs.idCliente);
          DateTime now = DateTime.now();
          transaction.set(documentReferenceCards, {
            'meta': utils.headers.toString().toString(),
            'id_cliente': int.parse(_prefs.idCliente),
            'imei': utils.headers["imei"].toString(),
            'auth': getRandomString(80),
            'token': _prefs.token,
            'marca': utils.headers["marca"].toString(),
            'modelo': utils.headers["modelo"].toString(),
            'fecha_inicio': now.toString(),
            'on_line': 1,
            'activado': 1,
            'activo': 1,
            'fecha_registro': now.toString(),
            'fecha_actualizo': now.toString(),
            'rastrear': 1,
            'lt': 0,
            'lg': 0,
            'id_rastreo':0
          });
        }).catchError((error) {
          print("Error sesion :");
          print(error);
        });
      } else {
        await FirebaseFirestore.instance
            .collection("client_session")
            .doc(_prefs.idCliente)
            .update({
          'meta': utils.headers.toString().toString(),
          'id_cliente': int.parse(_prefs.idCliente),
          'imei': utils.headers["imei"].toString(),
          'auth': getRandomString(80),
          'token': _prefs.token,
          'marca': utils.headers["marca"].toString(),
          'modelo': utils.headers["modelo"].toString(),
          'fecha_inicio': now.toString(),
          'fecha_actualizo': now.toString()
        });
      }
    });
  }
  autenticarTelefono(String telefono, Function response) async {
    await utils.getDeviceDetails();
    try {
      await FirebaseFirestore.instance
          .collection("client")
          .where("celular", isEqualTo: telefono)
          .limit(1)
          .get()
          .then((QuerySnapshot value) {
        if (value.size > 0) {
          Map client_map = value.docs.first.data() as Map;
          ClienteModel clienteModel = ClienteModel.fromJson(client_map);
          
          clienteModel.perfil = clienteModel.perfil.toString();
          clienteModel.idCliente = clienteModel.idCliente.toString();
          _prefs.auth = client_map['auth'];
          _prefs.idCliente = clienteModel.idCliente.toString();
          _prefs.clienteModel.link = clienteModel.link.toString();
          _prefs.clienteModel.nombres = clienteModel.nombres.toString();
          _prefs.clienteModel.apellidos = clienteModel.apellidos.toString();
          _prefs.clienteModel.correo = clienteModel.correo.toString();
          _prefs.clienteModel.idCliente = clienteModel.idCliente.toString();
          _prefs.clienteModel.cedula = clienteModel.cedula.toString();
          _prefs.clienteModel.celular = clienteModel.celular.toString();
          _prefs.clienteModel.img = clienteModel.img.toString();
          _prefs.clienteModel.perfil = clienteModel.perfil.toString();
          _prefs.clienteModel.celularValidado = clienteModel.celularValidado;
          _prefs.clienteModel.sexo = clienteModel.sexo;
          _prefs.clienteModel.calificacion = clienteModel.calificacion;
          _prefs.clienteModel.calificaciones = clienteModel.calificaciones;
          _prefs.clienteModel.registros = clienteModel.registros;
          _prefs.clienteModel.puntos = clienteModel.puntos;
          _prefs.clienteModel.direcciones = clienteModel.direcciones;
          _prefs.clienteModel.correctos = clienteModel.correctos;
          _prefs.clienteModel.canceladas = clienteModel.canceladas;
          _prefs.clienteModel.fechaNacimiento =
              clienteModel.fechaNacimiento.toString();
          _prefs.clienteModel.driverModel = clienteModel.driverModel.toString();
          _prefs.clienteModel.driverLicensePlate =
              clienteModel.driverLicensePlate.toString();
          _prefs.clienteModel.driverTradeMark =
              clienteModel.driverTradeMark.toString();
          _prefs.clienteModel.idUrbe = clienteModel.idUrbe;
          _prefs.clienteModel.token = clienteModel.token;
          _prefs.clienteModel = clienteModel;
          clienteSession();
          return response(1, clienteModel);
        }
        return response(0, "Teléfono incorrectas");
      });
    } catch (err) {
      return response(0, config.MENSAJE_INTERNET);
    }
  }

  autenticarClave(String correo, String clave, Function response) async {
    await utils.getDeviceDetails();
    try {
      await FirebaseFirestore.instance
          .collection("client")
          .where("correo", isEqualTo: correo)
          .where("clave", isEqualTo: clave)
          .limit(1)
          .get()
          .then((QuerySnapshot value) async{
        if (value.size > 0) {
          Map client_map = value.docs.first.data() as Map;
          if (client_map['activo'] == 0) {
             return response(0, "Cuenta Desactivada");
          }
          ClienteModel clienteModel = ClienteModel.fromJson(client_map);
          clienteModel.perfil = clienteModel.perfil.toString();
          clienteModel.idCliente = clienteModel.idCliente.toString();
          clienteModel.token = _prefs.token;
          _prefs.auth = client_map['auth'];
          _prefs.idCliente = clienteModel.idCliente.toString();
          _prefs.clienteModel.link = clienteModel.link.toString();
          _prefs.clienteModel.nombres = clienteModel.nombres.toString();
          _prefs.clienteModel.apellidos = clienteModel.apellidos.toString();
          _prefs.clienteModel.correo = clienteModel.correo.toString();
          _prefs.clienteModel.idCliente = clienteModel.idCliente.toString();
          _prefs.clienteModel.cedula = clienteModel.cedula.toString();
          _prefs.clienteModel.celular = clienteModel.celular.toString();
          _prefs.clienteModel.img = clienteModel.img.toString();
          _prefs.clienteModel.perfil = clienteModel.perfil.toString();
          _prefs.clienteModel.celularValidado = clienteModel.celularValidado;
          _prefs.clienteModel.sexo = clienteModel.sexo;
          _prefs.clienteModel.calificacion = clienteModel.calificacion;
          _prefs.clienteModel.calificaciones = clienteModel.calificaciones;
          _prefs.clienteModel.registros = clienteModel.registros;
          _prefs.clienteModel.puntos = clienteModel.puntos;
          _prefs.clienteModel.direcciones = clienteModel.direcciones;
          _prefs.clienteModel.correctos = clienteModel.correctos;
          _prefs.clienteModel.canceladas = clienteModel.canceladas;
          _prefs.clienteModel.fechaNacimiento =
              clienteModel.fechaNacimiento.toString();
          _prefs.clienteModel.driverModel = clienteModel.driverModel.toString();
          _prefs.clienteModel.driverLicensePlate =
              clienteModel.driverLicensePlate.toString();
          _prefs.clienteModel.driverTradeMark =
              clienteModel.driverTradeMark.toString();
          _prefs.clienteModel.idUrbe = clienteModel.idUrbe;
          _prefs.clienteModel.color = clienteModel.color;
          _prefs.clienteModel.token = clienteModel.token;
          _prefs.clienteModel = clienteModel;
          await actualizarToken();
          await clienteSession();
          return response(1, clienteModel);
        }
        return response(0, "Correo y/o clave incorrectas");
      });
    } catch (err) {
      return response(0, config.MENSAJE_INTERNET);
    }
  }

  Future<bool> autenticarApple(
      String codigoPais,
      String smn,
      String correo,
      String idApple,
      String nombres,
      String apellidos,
      Function response) async {
    await utils.getDeviceDetails();
    var client = http.Client();
    try {
      final resp = await client.post(
          Uri.parse(Sistema.dominio + _urlAutenticarApple),
          headers: utils.headers,
          body: {
            'nombres': nombres.toString(),
            'apellidos': apellidos.toString(),
            'correo': correo.toString(),
            'idApple': idApple.toString(),
            'token': _prefs.token,
            'simCountryCode': _prefs.simCountryCode,
            'codigoPais': codigoPais,
            'smn': smn.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        _prefs.auth = decodedResp['auth'];
        ClienteModel clienteModel =
            ClienteModel.fromJson(decodedResp['cliente']);
        _prefs.idCliente = clienteModel.idCliente.toString();
        _prefs.clienteModel = clienteModel;
        response(1, clienteModel);
        return true;
      }
      response(0, decodedResp['error']);
      return false;
    } catch (err) {
      print('cliente_provider 23 error: $err');
    } finally {
      client.close();
    }
    response(0, config.MENSAJE_INTERNET);
    return false;
  }

  autenticarGoogle(
      String codigoPais,
      String smn,
      String correo,
      String img,
      String idGoogle,
      String nombres,
      String apellidos,
      Function response) async {
    await utils.getDeviceDetails();
    try {
      await FirebaseFirestore.instance
          .collection("client")
          .where("correo", isEqualTo: correo)
          .limit(1)
          .get()
          .then((QuerySnapshot value) async {
        if (value.size > 0) {
          Map client_map = value.docs.first.data() as Map;
          if (client_map['activo'] == 0) {
             return response(0, "Cuenta Desactivada");
          }
          ClienteModel clienteModel = ClienteModel.fromJson(client_map);
          
          clienteModel.perfil = clienteModel.perfil.toString();
          clienteModel.idCliente = clienteModel.idCliente.toString();
          clienteModel.token = _prefs.token;
          _prefs.auth = client_map['auth'];
          _prefs.idCliente = clienteModel.idCliente.toString();
          _prefs.clienteModel.link = clienteModel.link.toString();
          _prefs.clienteModel.nombres = clienteModel.nombres.toString();
          _prefs.clienteModel.apellidos = clienteModel.apellidos.toString();
          _prefs.clienteModel.correo = clienteModel.correo.toString();
          _prefs.clienteModel.idCliente = clienteModel.idCliente.toString();
          _prefs.clienteModel.cedula = clienteModel.cedula.toString();
          _prefs.clienteModel.celular = clienteModel.celular.toString();
          _prefs.clienteModel.img = clienteModel.img.toString();
          _prefs.clienteModel.perfil = clienteModel.perfil.toString();
          _prefs.clienteModel.celularValidado = clienteModel.celularValidado;
          _prefs.clienteModel.sexo = clienteModel.sexo;
          _prefs.clienteModel.calificacion = clienteModel.calificacion;
          _prefs.clienteModel.calificaciones = clienteModel.calificaciones;
          _prefs.clienteModel.registros = clienteModel.registros;
          _prefs.clienteModel.puntos = clienteModel.puntos;
          _prefs.clienteModel.direcciones = clienteModel.direcciones;
          _prefs.clienteModel.correctos = clienteModel.correctos;
          _prefs.clienteModel.canceladas = clienteModel.canceladas;
          _prefs.clienteModel.fechaNacimiento =
              clienteModel.fechaNacimiento.toString();
          _prefs.clienteModel.driverModel = clienteModel.driverModel.toString();
          _prefs.clienteModel.driverLicensePlate =
              clienteModel.driverLicensePlate.toString();
          _prefs.clienteModel.driverTradeMark =
              clienteModel.driverTradeMark.toString();
          _prefs.clienteModel.idUrbe = clienteModel.idUrbe;
          _prefs.clienteModel.color = clienteModel.color;
          _prefs.clienteModel.token = clienteModel.token;
          _prefs.clienteModel = clienteModel;
          await FirebaseFirestore.instance
              .collection("client")
              .doc(value.docs.first.id)
              .update({"idGoogle": idGoogle.toString()});
          await actualizarToken();
          await clienteSession();
          return response(1, clienteModel);
        }
        return response(0, "Correo invalido");
      });
    } catch (err) {
      return response(0, config.MENSAJE_INTERNET);
    }
  }

  autenticarFacebook(
      String codigoPais,
      String smn,
      String correo,
      String idFacebook,
      String nombres,
      String apellidos,
      Function response) async {
    await utils.getDeviceDetails();
    try {
      await FirebaseFirestore.instance
          .collection("client")
          .where("correo", isEqualTo: correo)
          .limit(1)
          .get()
          .then((QuerySnapshot value) async {
        if (value.size > 0) {
          Map client_map = value.docs.first.data() as Map;
          if (client_map['activo'] == 0) {
             return response(0, "Cuenta Desactivada");
          }
          ClienteModel clienteModel = ClienteModel.fromJson(client_map);
          
          clienteModel.perfil = clienteModel.perfil.toString();
          clienteModel.idCliente = clienteModel.idCliente.toString();
          clienteModel.token = _prefs.token;
          _prefs.auth = client_map['auth'];
          _prefs.idCliente = clienteModel.idCliente.toString();
          _prefs.clienteModel.link = clienteModel.link.toString();
          _prefs.clienteModel.nombres = clienteModel.nombres.toString();
          _prefs.clienteModel.apellidos = clienteModel.apellidos.toString();
          _prefs.clienteModel.correo = clienteModel.correo.toString();
          _prefs.clienteModel.idCliente = clienteModel.idCliente.toString();
          _prefs.clienteModel.cedula = clienteModel.cedula.toString();
          _prefs.clienteModel.celular = clienteModel.celular.toString();
          _prefs.clienteModel.img = clienteModel.img.toString();
          _prefs.clienteModel.perfil = clienteModel.perfil.toString();
          _prefs.clienteModel.celularValidado = clienteModel.celularValidado;
          _prefs.clienteModel.sexo = clienteModel.sexo;
          _prefs.clienteModel.calificacion = clienteModel.calificacion;
          _prefs.clienteModel.calificaciones = clienteModel.calificaciones;
          _prefs.clienteModel.registros = clienteModel.registros;
          _prefs.clienteModel.puntos = clienteModel.puntos;
          _prefs.clienteModel.direcciones = clienteModel.direcciones;
          _prefs.clienteModel.correctos = clienteModel.correctos;
          _prefs.clienteModel.canceladas = clienteModel.canceladas;
          _prefs.clienteModel.fechaNacimiento =
              clienteModel.fechaNacimiento.toString();
          _prefs.clienteModel.driverModel = clienteModel.driverModel.toString();
          _prefs.clienteModel.driverLicensePlate =
              clienteModel.driverLicensePlate.toString();
          _prefs.clienteModel.driverTradeMark =
              clienteModel.driverTradeMark.toString();
          _prefs.clienteModel.idUrbe = clienteModel.idUrbe;
          _prefs.clienteModel.color = clienteModel.color;
          _prefs.clienteModel.token = clienteModel.token;
          _prefs.clienteModel = clienteModel;
          await FirebaseFirestore.instance
              .collection("client")
              .doc(value.docs.first.id)
              .update({"idFacebook": idFacebook.toString()});
          await actualizarToken();
          await clienteSession();
          return response(1, clienteModel);
        }
        return response(0, "Correo invalido");
      });
    } catch (err) {
      return response(0, config.MENSAJE_INTERNET);
    }
  }

  Future<bool> actualizarToken() async {
    
    if (_prefs.idCliente == '' || _prefs.idCliente == Sistema.ID_CLIENTE) return false;
    if (_prefs.token == '') {
      await PushProvider().obtenerToken();
      return false;
    }
    try {
      await FirebaseFirestore.instance
          .collection("client")
          .doc("client_" + _prefs.idCliente.toString())
          .update({"token": _prefs.token});
      return true;
    } catch (err) {
      print('cliente_provider 26 error: $err');
      return false;
    }
  }
}