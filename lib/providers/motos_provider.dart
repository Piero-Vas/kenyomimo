import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mimo/model/cliente_model.dart';
import 'package:mimo/preference/shared_preferences.dart';

class MotosProvider {
   final PreferenciasUsuario _prefs = PreferenciasUsuario();
  
  registrarmotos(String tipovehiculo, String marca, String modelo, String placa, String infoad, String dni,String licencia ,ClienteModel cliente, Function response) async {
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference documentReferenceCards = FirebaseFirestore.instance
          .collection('request')
          .doc(_prefs.idCliente);
      DateTime now = DateTime.now();
      transaction.set(documentReferenceCards, {
        'idcliente': _prefs.idCliente,
        'tipovehiculo': tipovehiculo.toString(),
        'marca': marca.toString(),
        'modelo': modelo.toString(),
        'placa': placa.toString(),
        'infoad': infoad.toString(),
        'dni': dni.toString(),
        'nombre': cliente.nombres.toString(),
        'correo': cliente.correo.toString(),
        'licencia': licencia.toString(),
        'fechacreacion': now.toString(),
        'fechacreacionmili': now.millisecondsSinceEpoch,
        'aprobado': 1,
        'tipoSolicitud':"motorizado",
        'eliminado': false
      });
      return response(1);
    }).catchError((error) {
      return response(0);
    });
  }
}