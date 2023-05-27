import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mimo/model/cliente_model.dart';
import 'package:mimo/preference/shared_preferences.dart';

class TaxistasProvider {
   final PreferenciasUsuario _prefs = PreferenciasUsuario();
  
  registrartaxista(String dni, String tipovehiculo, String marca, String modelo, String placa, String infoad, String color,String licencia ,ClienteModel cliente, Function response) async {
      try{
        DocumentReference documentReferenceCards = await FirebaseFirestore.instance
          .collection('request')
          .doc(_prefs.idCliente);
      if((await documentReferenceCards.get()).exists){
        return response(0);
      }
      DateTime now = DateTime.now();
      documentReferenceCards.set({
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
        'tipoSolicitud':"taxista",
        'eliminado': false,
        "color":color.toString()
      });
      return response(1);
      }catch(e){
        return response(0);
      }
  }
}