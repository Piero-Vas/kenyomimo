import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../model/cliente_model.dart';
import '../preference/shared_preferences.dart';
import '../utils/utils.dart' as utils;

class RegistroProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final String _urlRegistrar = 'registro/registrar';

  registrar(ClienteModel clienteModel, String codigoPais, String smn,Function response) async {

    if(clienteModel.celular.toString().trim().isEmpty || clienteModel.correo.toString().trim().isEmpty || clienteModel.clave.toString().trim().isEmpty || clienteModel.nombres.toString().trim().isEmpty || clienteModel.apellidos.toString().trim().isEmpty || clienteModel.cedula.toString().trim().isEmpty){
      return response(0,clienteModel);
    }

    await utils.getDeviceDetails();
    Map headers = utils.headers;
    DocumentReference documentReference = FirebaseFirestore.instance.collection('client').doc('--stats--');
  return FirebaseFirestore.instance.runTransaction((transaction) async {
    // Get the document
    DocumentSnapshot snapshot = await transaction.get(documentReference);
    if (!snapshot.exists) {
      throw Exception("No existe la coleccion Cliente!");
    }
    dynamic cantidadCards = snapshot.get('cantidadClientes') + 1;
    DocumentReference documentReferenceCards = FirebaseFirestore.instance
        .collection('client').doc('client_$cantidadCards');
    transaction.set(documentReference, {
      'cantidadClientes': cantidadCards,
    });
    String auth = encriptarTexto(clienteModel.correo.toString()+clienteModel.celular.toString());
    DateTime now = DateTime.now();

    

    transaction.set(documentReferenceCards, {
      'id_urbe': 1,
      'beta': "",
      'celular': clienteModel.celular.toString(),
      'correo': clienteModel.correo.toString(),
      'clave': utils.generateMd5(clienteModel.clave.toString()),
      'nombres': clienteModel.nombres.toString(),
      'apellidos': clienteModel.apellidos.toString(),
      'cedula': clienteModel.cedula.toString(),
      'celularValidado': 1,
      'correoValidado': 1,
      'typeVehicle': '',
      'simCountryCode': _prefs.simCountryCode,
      'codigoPais': codigoPais,
      'token': _prefs.token,
      'smn': smn.toString(),
      'perfil': 0,
      'link': "",
      'img': "https://firebasestorage.googleapis.com/v0/b/mimo-3ef92.appspot.com/o/default-image.png?alt=media&token=9b400614-9d8a-4fc4-8919-4fa59cedc8cd",
      'sexo': 0,
      'calificacion': 0.0,
      'calificaciones': 0,
      'registros': 0,
      'puntos': 0,
      'direcciones': 0,
      'correctos': 0,
      'canceladas': 0,
      'fecha_nacimiento': "",
      'idaplicativo': headers['idaplicativo'],
      'idFacebook': null,
      'idGoogle': null,
      'idApple': null,
      'fecha_registro': now.toString(),
      'idplataforma': headers['idplataforma'],
      'meta': "0",
      'activo': 1,
      'marca': headers['marca'],
      'modelo': headers['modelo'],
      'so': headers['so'],
      'vs': headers['vs'],
      'fecha_inicio': now.toString(),
      'fecha_ultima': now.toString(),
      'on_line': 1,
      'bloqueado': 0,
      'fecha_bloqueado': null,
      'motivo_bloqueado': null,
      'cambiarClave': 0,
      'claveTemporal': null,
      'driverLicensePlate': "",
      'driverTradeMark': "",
      'driverModel': "",
      'headers': headers.toString(),
      'id_cliente': cantidadCards,
      'fecha_actualizo': now.toString(),
      'fecha_recupero': null,
      'auth': auth,
      'eliminado': false,
      'fecha_cancelado':null,
      'fecha_cancelado_mili':null,
      'confirmados':0,
      'color':''
    });
      clienteModel.perfil = "0";
      clienteModel.direcciones = 0;
      clienteModel.idCliente = cantidadCards.toString();
      _prefs.auth = auth;
      _prefs.idCliente = cantidadCards.toString();
      _prefs.clienteModel.link = clienteModel.link.toString();
      _prefs.clienteModel.nombres = clienteModel.nombres.toString();
      _prefs.clienteModel.apellidos = clienteModel.apellidos.toString();
      _prefs.clienteModel.correo = clienteModel.correo.toString();
      _prefs.clienteModel.idCliente = cantidadCards.toString();
      _prefs.clienteModel.cedula = clienteModel.cedula.toString();
      _prefs.clienteModel.celular = clienteModel.celular.toString();
      _prefs.clienteModel.img = clienteModel.img.toString();
      _prefs.clienteModel.perfil = clienteModel.perfil;
      _prefs.clienteModel.color = clienteModel.color;

      _prefs.clienteModel.celularValidado = clienteModel.celularValidado;
      _prefs.clienteModel.sexo = clienteModel.sexo;
      _prefs.clienteModel.calificacion = clienteModel.calificacion;
      _prefs.clienteModel.calificaciones = clienteModel.calificaciones;
      _prefs.clienteModel.registros = clienteModel.registros;
      _prefs.clienteModel.puntos = clienteModel.puntos;
      _prefs.clienteModel.direcciones = clienteModel.direcciones;
      _prefs.clienteModel.correctos = clienteModel.correctos;
      _prefs.clienteModel.canceladas = clienteModel.canceladas;
      _prefs.clienteModel.fechaNacimiento = clienteModel.fechaNacimiento.toString();
      _prefs.clienteModel.driverModel = '';
      _prefs.clienteModel.driverLicensePlate = '';
      _prefs.clienteModel.driverTradeMark = '';
      _prefs.clienteModel.idUrbe = clienteModel.idUrbe.toString();
      
      _prefs.clienteModel = clienteModel;
      
    return response(1,clienteModel);
  }).catchError((error) {
     return response(0,clienteModel);
});
  }

  encriptarTexto(auth) {
  final key = encrypt.Key.fromLength(32);
  final iv = encrypt.IV.fromLength(8);
  final encrypter = encrypt.Encrypter(encrypt.Salsa20(key));
  final encrypted = encrypter.encrypt(auth, iv: iv);
  String textEncrypted1 = encrypted.base64.substring(0, 6);
  String textEncrypted2 = encrypted.base64.substring(7);
  String textEncrypted = utils.generateMd5(textEncrypted2) + textEncrypted1;
  return textEncrypted;
}
}