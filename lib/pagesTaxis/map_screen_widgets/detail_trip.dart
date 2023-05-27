import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mimo/model/map_action.dart';
import 'package:mimo/model/trip_model.dart';
import 'package:mimo/Core/ProviderModels/MapModel.dart';
import 'package:mimo/preference/shared_preferences.dart';
import '../../../utils/personalizacion.dart' as prs;
import 'package:mimo/pagesTaxis/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:flash/flash.dart';

class ConfirmPickup extends StatefulWidget {
  final MapModel mapProvider;
  const ConfirmPickup({Key key, this.mapProvider}) : super(key: key);
  @override
  State<ConfirmPickup> createState() => _ConfirmPickupState();
}

class _ConfirmPickupState extends State<ConfirmPickup> {
  List<dynamic> misTarjetas = [];
  List<dynamic> tarjetas = [];
  PreferenciasUsuario _prefs = PreferenciasUsuario();
  List<dynamic> usuariosprueba = ['19','271','2','13'];
  @override
  void initState() {
    getAllCards();
    getAllRates();
    super.initState();
    FocusManager.instance.primaryFocus.unfocus();
  }

  mensaje(int tipoMensaje, int duracion, BuildContext context,
      String colorDeFondoS, IconData icono, String textoMensaje) {
    Color colorDeFondo;
    if (colorDeFondoS == 'success') {
      colorDeFondo = Color.fromRGBO(37, 217, 194, 1);
    } else if (colorDeFondoS == 'danger') {
      colorDeFondo = Color.fromRGBO(217, 33, 78, 1);
    }

    switch (tipoMensaje) {
      case 1:
        showFlash(
            context: context,
            duration: Duration(seconds: duracion),
            builder: (context, controller) {
              return Flash(
                controller: controller,
                behavior: FlashBehavior.fixed,
                position: FlashPosition.top,
                boxShadows: kElevationToShadow[0],
                // horizontalDismissDirection: HorizontalDismissDirection.horizontal,
                backgroundColor: colorDeFondo,
                // borderRadius: BorderRadius.only(topLeft: Radius.zero,topRight: Radius.zero,bottomLeft: Radius.circular(500),bottomRight: Radius.circular(500)),
                child: FlashBar(
                  content: Container(
                      constraints: BoxConstraints(minHeight: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icono,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            constraints: BoxConstraints(maxWidth: 250),
                            child: Text(textoMensaje,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ],
                      )),
                ),
              );
            });
        break;
      default:
        break;
    }
  }

  //String get _merchantBaseUrl => 'https://api.openpay.pe/v1/m0qhimwy1aullokkujfg';
  // final String apiKeyPublic = "pk_20261e9590c24c1995bd82c30959d12b";
  // final String apiKeyPrivate = "sk_da8b8e48791540958a47dae3488abfa9";
  String get _merchantBaseUrl =>
      'https://sandbox-api.openpay.pe/v1/mkq9aic4rs51cybtcdut';
  final String apiKeyPublic = "pk_92bef45248c34ce7a41d59ca30ab72c1";
  final String apiKeyPrivate = "sk_41d63faafb4c413581fbf776030771da";
  Future<Map> createCharge(
      String source_id,
      double amount,
      String name,
      String last_name,
      String phone_number,
      String email,
      String _deviceID) async {
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$apiKeyPrivate:'));
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': basicAuth,
      'Accept': 'application/json',
    };
    String body = """{  
      "source_id": "$source_id",
      "method": "card",
      "amount": $amount,
      "currency": "PEN",
      "description": "Cargo Taxi",
      "device_session_id": "$_deviceID",
      "customer":{
        "name" : "$name",
        "last_name" : "$last_name",
        "phone_number" : "$phone_number",
        "email" : "$email" 
      }
    }""";
    Response response = await post(Uri.parse('$_merchantBaseUrl/charges'),
        headers: headers, body: body);
    Map responseReturn = {'body': response.body};
    if (response.statusCode == 201 || response.statusCode == 200) {
      responseReturn['status'] = true;
      return responseReturn;
    } else {
      responseReturn['status'] = false;
      return responseReturn;
    }
  }

  Future getAllCards() async {
    final _prefs = PreferenciasUsuario();
    var id = _prefs.clienteModel.idCliente;
    await FirebaseFirestore.instance
        .collection("cards")
        .where("idCliente", isEqualTo: id.toString())
        .where("eliminado", isEqualTo: false)
        .where('seleccionado', isEqualTo: true)
        .snapshots()
        .listen((result) async {
      misTarjetas.clear();
      misTarjetas.addAll(result.docs);
      if (mounted) {
        setState(() {
          tarjetas = misTarjetas;
        });
      }
    });
  }

  Map<int, Map<String, dynamic>> ratesTaxi = {};
  Map<int, Map<String, dynamic>> ratesEnvio = {};

  Future getAllRates() async {
    await FirebaseFirestore.instance
        .collection("servicios_taxi")
        .snapshots()
        .listen((rates) async {
      rates.docs.forEach((rate) {
        Map<String, dynamic> rateMap = rate.data();
        
        rateMap['tipoServicio'] == "taxi"
            ? ratesTaxi[rateMap['idServicio']] = rateMap
            : ratesEnvio[rateMap['idServicio']] = rateMap;
      });
      if (mounted) {
        setState(() {});
      }
      
    });
  }

  Future<bool> _preparedNotification(List<String> tokens) async {
    String mensajeNotification = "Hola estoy en la busqueda de un conductor!!!",
        tituloNotification = "Solicitud de Viaje";
        String tag =  "-75132912-" ;
    Map<String, dynamic> data = {
      "PUSH": 1111,
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "sound": "default",
      "priority": "high",
      "content_available": true,
      "mutable_content": true,
      "time_to_live": 180,
      "apns": {
        "headers": {"apns-priority": "10"},
        "payload": {
          "aps": {"sound": "default"}
        }
      },
      "android": {
        "priority": "high",
        "notification": {"sound": "default"}
      },
      "json": true
    };
    String dataJson = jsonEncode(data);
    String tokensJson = jsonEncode(tokens);
    return await createNotification(
        tokensJson, tituloNotification, mensajeNotification, dataJson,tag);
  }

  String keyNotification1 =
      "key=AAAAvJkV440:APA91bHgpgFXv0AW0MAKmCcty7I0zP3lW-SWBVHa4nsFfMiKfUcnHmnGxmPW05WoWAfjtSZgfkhs_0oD84gx28IwzHKEfj6ANcz0VyO2qwAg-CerrSmw0kD6SbL2FKygiPN9oBdHGd5X";
  final _notificationBaseUrl = "https://fcm.googleapis.com/fcm/send";

  Future<bool> createNotification(String tokens, String tituloNotification,
      String mensajeNotification, String data,String tag) async {
    
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
    Response response = await post(Uri.parse('$_notificationBaseUrl'),
        headers: headers, body: body);
    if (response.statusCode == 200) {
     
      return true;
    } else {
      
      return false;
    }
  }

  Future<List<String>> _getTokens(String typeVehicle) async {
    
    List<String> tokens = [];
    await FirebaseFirestore.instance
        .collection("client")
        .where("typeVehicle", isEqualTo: typeVehicle)
        .where("on_line", isEqualTo: 1)
        .where("activo", isEqualTo: 1)
        .where("id_cliente", isNotEqualTo: int.parse(_prefs.idCliente))
        .get()
        .then((clientes) {
      clientes.docs.forEach((cliente) {
        tokens.add(cliente['token'].toString());

       
      });
    });
    
    return tokens;
  }

  Future<void> _startTrip(
      BuildContext context, String tipoServicio, String typeVehicle) async {
    FocusManager.instance.primaryFocus.unfocus();
    widget.mapProvider.changeMapActionTemp(MapAction.searchDriverTemp);
    if (_saving) return;
    _saving = true;
    if (mounted) setState(() {});
    final _prefs = PreferenciasUsuario();
    String id = _prefs.clienteModel.idCliente;
    final DatabaseService dbService = DatabaseService();
    await widget.mapProvider.setCost(_price);
    await widget.mapProvider.calculateCost();
    await widget.mapProvider.calculateTime();
    String name = _prefs.clienteModel.nombres +
        " " +
        (_prefs.clienteModel.apellidos == null
            ? ""
            : _prefs.clienteModel.apellidos);
    String passengerPhone = _prefs.clienteModel.celular;
    String passengerImg = _prefs.clienteModel.img;
    int totalTrips = await dbService.getTotalTripsByPassenger(id);
    DateTime now = DateTime.now();
    Map monthString = {
      1: "enero",
      2: "febrero",
      3: "marzo",
      4: "abril",
      5: "mayo",
      6: "junio",
      7: "julio",
      8: "agosto",
      9: "setiembre",
      10: "octubre",
      11: "noviembre",
      12: "diciembre"
    };
    String creatat = now.day.toString() +
        " de " +
        monthString[now.month] +
        ", " +
        (now.hour > 9 ? now.hour.toString() : "0" + now.hour.toString()) +
        ":" +
        (now.minute > 9 ? now.minute.toString() : "0" + now.minute.toString());
    Trip newTrip = Trip(
        pickupAddress: widget.mapProvider.deviceAddress,
        destinationAddress: widget.mapProvider.remoteAddress,
        pickupLatitude: widget.mapProvider.pickupPosition.latitude,
        pickupLongitude: widget.mapProvider.pickupPosition.longitude,
        destinationLatitude: widget.mapProvider.remoteLocation.latitude,
        destinationLongitude: widget.mapProvider.remoteLocation.longitude,
        distance: widget.mapProvider.distance,
        cost: widget.mapProvider.cost,
        timeTrip: widget.mapProvider.timeTrip,
        price: _price,
        passengerId: id,
        createat: creatat,
        createatMili: now.millisecondsSinceEpoch,
        typePayment: _valueMetodoPago,
        passengerName: name,
        passengerTrips: totalTrips,
        passengerImg: passengerImg,
        passengerPhone: passengerPhone,
        paymentStatus: 0,
        passengerCard: "",
        chargeId: "",
        passengerShippingDetail: detalleEnvio,
        typeService: tipoServicio,
        typeVehicle: typeVehicle);
        
    // String tripId = await dbService.startTrip(newTrip);
    // newTrip.id = tripId;
    if (_valueMetodoPago > 3) {
      String passengerCorreo = _prefs.clienteModel.correo;
      String passengeCelular = _prefs.clienteModel.celular;
      String source_id = "";
      String _deviceID = "";
      await FirebaseFirestore.instance
          .collection("cards")
          .where("idCliente", isEqualTo: id)
          .where("eliminado", isEqualTo: false)
          .where("seleccionado", isEqualTo: true)
          .get()
          .then(
        (value) {
          _deviceID = value.docs.first['device'];
          source_id = value.docs.first['token'];
        },
      );
      Map chargeTemp = await createCharge(
          source_id,
          widget.mapProvider.cost,
          _prefs.clienteModel.nombres,
          (_prefs.clienteModel.apellidos == null
              ? ""
              : _prefs.clienteModel.apellidos),
          passengeCelular,
          passengerCorreo,
          _deviceID);
      if (chargeTemp['status']) {
        String tripId = await dbService.startTrip(newTrip);
        newTrip.id = tripId;
        Map charge = jsonDecode(chargeTemp['body']) as Map;
        
        List<String> tokens = await _getTokens(typeVehicle);
        await _preparedNotification(tokens);
        newTrip.chargeId = charge['id'];
        dbService.updateTrip(newTrip);
        widget.mapProvider.confirmTrip(newTrip);
        widget.mapProvider.triggerAutoCancelTrip(
          tripDeleteHandler: () {
            newTrip.canceled = true;
            dbService.updateTrip(newTrip);
            refuseCharge(newTrip.chargeId);
          },
          snackbarHandler: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ningun conductor acepto el viaje.'),
              ),
            );
          },
        );
        mensaje(1, 3, context, "success", Icons.error,
            "Se hizo el cobro correcto de su tarjeta");
        setState(() {
          _saving = false;
        });
      } else {
        
        newTrip.canceled = true;
        dbService.updateTrip(newTrip);
        widget.mapProvider.changeMapActionTemp(MapAction.tripSelected);
        setState(() {
          _saving = false;
        });
        mensaje(1, 3, context, "danger", Icons.error,
            "Hubo un problema con la tarjeta seleccionada, por favor intentelo mas tarde");
      }
      Navigator.pop(context);
    } else {
      
        String tripId = await dbService.startTrip(newTrip);
        newTrip.id = tripId;
      
      List<String> tokens = await _getTokens(typeVehicle);
      
      widget.mapProvider.confirmTrip(newTrip);
      widget.mapProvider.triggerAutoCancelTrip(
        tripDeleteHandler: () {
          newTrip.canceled = true;
          dbService.updateTrip(newTrip);
          
        },
        snackbarHandler: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ningun conductor acepto la solicitud.'),
            ),
          );
        },
      );
      setState(() {
        _saving = false;
      });
      Navigator.pop(context);
    }
  }

  refuseCharge(String chargeId) async {
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$apiKeyPrivate:'));
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': basicAuth,
      'Accept': 'application/json',
    };
    Response response = await post(
        Uri.parse('$_merchantBaseUrl/charges/$chargeId/refund'),
        headers: headers);
    Map responseReturn = {'body': response.body};
    if (response.statusCode == 201 || response.statusCode == 200) {
      responseReturn['status'] = true;
      return responseReturn;
    } else {
      responseReturn['status'] = false;
      return responseReturn;
    }
  }

  int _valueModoViaje = 0;
  int _valueMetodoPago = 0;
  double _price = 0;
  String detalleEnvio = "";
  String espeficaciones = "Sin Especificar";
  String modoviaje = "Sin Especificar";
  String metodopago = "Sin Especificar";
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return widget.mapProvider.pickupPosition != null &&
            widget.mapProvider.destinationPosition != null &&
            widget.mapProvider.mapAction == MapAction.tripSelected
        ? _saving
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Text(
                                "¿Qué servicio te facilitamos?",
                                style: TextStyle(
                                  fontFamily: "GoldplayRegular",
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Image(
                                    image: AssetImage(
                                      "assets/png/auto.png",
                                    ),
                                    width: 100,
                                    height: 80,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _price = 0;
                                      _valueModoViaje = 0;
                                      detalleEnvio = "";
                                      espeficaciones = "Sin Especificar";
                                      modoviaje = "Sin Especificar";
                                      showModalBottomSheet(
                                          isScrollControlled: true,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(30),
                                                  topRight:
                                                      Radius.circular(30))),
                                          context: context,
                                          builder: (context) {
                                            return StatefulBuilder(builder:
                                                (BuildContext context,
                                                    StateSetter myStateTaxi) {
                                              return Container(
                                                  padding: EdgeInsets.all(20),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(40),
                                                      topRight:
                                                          Radius.circular(40),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "TAXI",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "GoldplayBlack",
                                                              fontSize: 17,
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                              onTap: () =>
                                                                  showModalBottomSheet(
                                                                    isScrollControlled:
                                                                        true,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(30),
                                                                            topRight: Radius.circular(30))),
                                                                    context:
                                                                        context,
                                                                    builder: (context) => StatefulBuilder(builder: (BuildContext
                                                                            context,
                                                                        StateSetter
                                                                            mystate) {
                                                                      return Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 5),
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  SizedBox(
                                                                                    height: 30,
                                                                                  ),
                                                                                  Text(
                                                                                    '¿Seguro que quieres cancelar el proceso de solicitud?',
                                                                                    textAlign: TextAlign.center,
                                                                                    style: TextStyle(
                                                                                      fontFamily: 'GoldplayRegular',
                                                                                      fontSize: 20,
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 20,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: double.infinity,
                                                                                    child: ElevatedButton(
                                                                                      onPressed: () {
                                                                                        _valueMetodoPago = 0;
                                                                                        _valueModoViaje = 0;
                                                                                        modoviaje = "Sin Especificar";
                                                                                        metodopago = "Sin Especificar";
                                                                                        Navigator.pop(context);
                                                                                        Navigator.pop(context);
                                                                                        widget.mapProvider.cancelTrip();
                                                                                      },
                                                                                      child: Text(
                                                                                        "Sí, seguro",
                                                                                        style: TextStyle(color: Colors.white),
                                                                                      ),
                                                                                      style: ElevatedButton.styleFrom(shape: StadiumBorder(), padding: EdgeInsets.symmetric(vertical: 20), backgroundColor: prs.colorMorado, foregroundColor: prs.colorMorado),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 20,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: double.infinity,
                                                                                    child: ElevatedButton(
                                                                                      onPressed: () {
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      child: Text(
                                                                                        "Cancelar",
                                                                                        style: TextStyle(color: prs.colorMorado),
                                                                                      ),
                                                                                      style: ElevatedButton.styleFrom(shape: StadiumBorder(), side: BorderSide(color: prs.colorMorado, width: 1), elevation: 0, padding: EdgeInsets.symmetric(vertical: 20), backgroundColor: Colors.transparent, foregroundColor: prs.colorMorado),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ]);
                                                                    }),
                                                                  ),
                                                              child: Text(
                                                                "Cancelar",
                                                                style: TextStyle(
                                                                    color: prs
                                                                        .colorMorado,
                                                                    fontSize:
                                                                        17),
                                                              ))
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 30,
                                                      ),
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color: prs
                                                                  .colorGrisBordes),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            20.0,
                                                          ),
                                                        ),
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        child: ListTile(
                                                          leading: Image(
                                                            height: 50,
                                                            width: 50,
                                                            image: AssetImage(
                                                              "assets/png/modoviaje.png",
                                                            ),
                                                          ),
                                                          title: Text(
                                                            "Modo de Viaje",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "GoldplayRegular",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 17),
                                                          ),
                                                          subtitle: Text(
                                                              "$modoviaje",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "GoldplayRegular",
                                                                fontSize: 15,
                                                              )),
                                                          trailing: IconButton(
                                                            onPressed: () {
                                                              int _value =
                                                                  _valueModoViaje;
                                                              showModalBottomSheet(
                                                                  isScrollControlled:
                                                                      true,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                              30),
                                                                          topRight: Radius.circular(
                                                                              30))),
                                                                  context:
                                                                      context,
                                                                  builder: (context) =>
                                                                      StatefulBuilder(builder: (BuildContext
                                                                              context,
                                                                          StateSetter
                                                                              myStateModoViaje) {
                                                                        return Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 5),
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    SizedBox(
                                                                                      height: 30,
                                                                                    ),
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Text(
                                                                                          "Modo de viaje",
                                                                                          style: TextStyle(
                                                                                            fontFamily: "GoldplayRegular",
                                                                                            fontSize: 17,
                                                                                          ),
                                                                                        ),
                                                                                        GestureDetector(
                                                                                            onTap: () {
                                                                                              Navigator.pop(context);
                                                                                            },
                                                                                            child: Text(
                                                                                              "Cancelar",
                                                                                              style: TextStyle(color: prs.colorMorado, fontSize: 17),
                                                                                            )),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: 30,
                                                                                    ),
                                                                                    ListTile(
                                                                                        leading: Image(
                                                                                          height: 50,
                                                                                          width: 50,
                                                                                          image: AssetImage(
                                                                                            "assets/png/estandar.png",
                                                                                          ),
                                                                                        ),
                                                                                        title: Text.rich(
                                                                                          TextSpan(
                                                                                            children: [
                                                                                              TextSpan(
                                                                                                text: ratesTaxi[1]['nombre'],
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 17),
                                                                                              ),
                                                                                              TextSpan(
                                                                                                text: ratesTaxi[1]['subnombre'],
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontSize: 17),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        subtitle: Text.rich(
                                                                                          TextSpan(
                                                                                            children: [
                                                                                              // TextSpan(
                                                                                              //   text: "S/ ${ratesTaxi[1]['precio'].toString()}",
                                                                                              //   style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 15),
                                                                                              // ),
                                                                                              TextSpan(
                                                                                                text: "• ${ratesTaxi[1]['descripcion']}",
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontSize: 15),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        trailing:Transform.scale(
                                                                                           scale: 1.5,
                                                                                          child: Radio(
                                                                                          value: 1,
                                                                                          groupValue: _value,
                                                                                          onChanged: (value) {
                                                                                            myStateModoViaje(() {
                                                                                              _value = value;
                                                                                            });
                                                                                          },
                                                                                        ))),
                                                                                    Divider(
                                                                                      color: Colors.black87,
                                                                                    ),
                                                                                    ListTile(
                                                                                        leading: Image(
                                                                                          height: 50,
                                                                                          width: 50,
                                                                                          image: AssetImage(
                                                                                            "assets/png/comodo.png",
                                                                                          ),
                                                                                        ),
                                                                                        title: Text.rich(
                                                                                          TextSpan(
                                                                                            children: [
                                                                                              TextSpan(
                                                                                                text: ratesTaxi[2]['nombre'],
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 17),
                                                                                              ),
                                                                                              TextSpan(
                                                                                                text: ratesTaxi[2]['subnombre'],
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontSize: 17),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        subtitle: Text.rich(
                                                                                          TextSpan(
                                                                                            children: [
                                                                                              // TextSpan(
                                                                                              //   text: "S/ ${ratesTaxi[2]['precio'].toString()}",
                                                                                              //   style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 15),
                                                                                              // ),
                                                                                              TextSpan(
                                                                                                text: "• ${ratesTaxi[2]['descripcion']}",
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontSize: 15),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        trailing: Transform.scale(
                                                                                           scale: 1.5,
                                                                                          child:Radio(
                                                                                            value: 2,
                                                                                            groupValue: _value,
                                                                                            onChanged: (value) {
                                                                                              myStateModoViaje(() {
                                                                                                _value = value;
                                                                                              });
                                                                                            }))),
                                                                                    Divider(
                                                                                      color: Colors.black87,
                                                                                    ),
                                                                                    ListTile(
                                                                                        leading: Image(
                                                                                          height: 50,
                                                                                          width: 50,
                                                                                          image: AssetImage(
                                                                                            "assets/png/carga.png",
                                                                                          ),
                                                                                        ),
                                                                                        title: Text.rich(
                                                                                          TextSpan(
                                                                                            children: [
                                                                                              TextSpan(
                                                                                                text: ratesTaxi[3]['nombre'],
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 17),
                                                                                              ),
                                                                                              TextSpan(
                                                                                                text: ratesTaxi[3]['subnombre'],
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontSize: 17),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        subtitle: Text.rich(
                                                                                          TextSpan(
                                                                                            children: [
                                                                                              // TextSpan(
                                                                                              //   text: "S/ ${ratesTaxi[3]['precio'].toString()}",
                                                                                              //   style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 15),
                                                                                              // ),
                                                                                              TextSpan(
                                                                                                text: "• ${ratesTaxi[3]['descripcion']}",
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontSize: 15),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        trailing: Transform.scale(
                                                                                           scale: 1.5,
                                                                                          child:Radio(
                                                                                            value: 3,
                                                                                            groupValue: _value,
                                                                                            onChanged: (value) {
                                                                                              myStateModoViaje(() {
                                                                                                _value = value;
                                                                                              });
                                                                                            }))),
                                                                                    SizedBox(
                                                                                      height: 20,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: double.infinity,
                                                                                      child: ElevatedButton(
                                                                                        onPressed: () {
                                                                                          if (_value == 0) {
                                                                                            return null;
                                                                                          } else {
                                                                                            modoviaje = "Estandar";
                                                                                            _price = double.parse(ratesTaxi[1]['precio'].toString());
                                                                                            if (_value == 2) {
                                                                                              modoviaje = "Comodo";
                                                                                              _price = double.parse(ratesTaxi[2]['precio'].toString());
                                                                                            }
                                                                                            if (_value == 3) {
                                                                                              modoviaje = "Espacio de carga";
                                                                                              _price = double.parse(ratesTaxi[3]['precio'].toString());
                                                                                            }
                                                                                            _valueModoViaje = _value;
                                                                                            myStateTaxi(() {});
                                                                                            Navigator.pop(context);
                                                                                          }
                                                                                        },
                                                                                        child: Text(
                                                                                          "Confirmar",
                                                                                          style: TextStyle(color: Colors.white),
                                                                                        ),
                                                                                        style: ElevatedButton.styleFrom(shape: StadiumBorder(), padding: EdgeInsets.symmetric(vertical: 20), backgroundColor: _value == 0 ? Colors.grey.shade500 : prs.colorMorado, foregroundColor: prs.colorMorado),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ]);
                                                                      }));
                                                            },
                                                            icon: Icon(
                                                              Icons
                                                                  .arrow_forward_ios_sharp,
                                                              color: prs
                                                                  .colorMorado,
                                                                  size: 40,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color: prs
                                                                  .colorGrisBordes),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            20.0,
                                                          ),
                                                        ),
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        child: ListTile(
                                                          leading: Image(
                                                            height: 50,
                                                            width: 50,
                                                            image: AssetImage(
                                                              "assets/png/cartera.png",
                                                            ),
                                                          ),
                                                          title: Text(
                                                            "Método de pago",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "GoldplayRegular",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 17),
                                                          ),
                                                          subtitle: Text(
                                                              "$metodopago",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "GoldplayRegular",
                                                                fontSize: 15,
                                                              )),
                                                          trailing: IconButton(
                                                            onPressed: () {
                                                              int _value =
                                                                  _valueMetodoPago;
                                                              showModalBottomSheet(
                                                                  isScrollControlled:
                                                                      true,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                              30),
                                                                          topRight: Radius.circular(
                                                                              30))),
                                                                  context:
                                                                      context,
                                                                  builder: (context) =>
                                                                      StatefulBuilder(builder: (BuildContext
                                                                              context,
                                                                          StateSetter
                                                                              myStateMetodoPago) {
                                                                        return Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 5),
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    SizedBox(
                                                                                      height: 30,
                                                                                    ),
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Text(
                                                                                          "Método de pago",
                                                                                          style: TextStyle(
                                                                                            fontFamily: "GoldplayRegular",
                                                                                            fontSize: 17,
                                                                                          ),
                                                                                        ),
                                                                                        GestureDetector(
                                                                                            onTap: () {
                                                                                              Navigator.pop(context);
                                                                                            },
                                                                                            child: Text(
                                                                                              "Cancelar",
                                                                                              style: TextStyle(color: prs.colorMorado, fontSize: 17),
                                                                                            )),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: 30,
                                                                                    ),
                                                                                    ListTile(
                                                                                        leading: Image(
                                                                                          height: 50,
                                                                                          width: 50,
                                                                                          image: AssetImage(
                                                                                            "assets/png/efectivo.png",
                                                                                          ),
                                                                                        ),
                                                                                        title: Text.rich(
                                                                                          TextSpan(
                                                                                            children: [
                                                                                              TextSpan(
                                                                                                text: "Efectivo",
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 17),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        trailing: Transform.scale(
                                                                                           scale: 1.5,
                                                                                          child:Radio(
                                                                                            value: 1,
                                                                                            groupValue: _value,
                                                                                            onChanged: (value) {
                                                                                              myStateMetodoPago(() {
                                                                                                _value = value;
                                                                                              });
                                                                                            }))
                                                                                        // trailing: Container(decoration: BoxDecoration(border: Border.all(color:prs.colorGrisBordes )),)
                                                                                        ),
                                                                                    Divider(
                                                                                      color: Colors.black87,
                                                                                    ),
                                                                                    ListTile(
                                                                                        leading: Image(
                                                                                          height: 50,
                                                                                          width: 50,
                                                                                          image: AssetImage(
                                                                                            "assets/png/yape.png",
                                                                                          ),
                                                                                        ),
                                                                                        title: Text.rich(
                                                                                          TextSpan(
                                                                                            children: [
                                                                                              TextSpan(
                                                                                                text: "Yape",
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 17),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        trailing: Transform.scale(
                                                                                           scale: 1.5,
                                                                                          child:Radio(
                                                                                            value: 2,
                                                                                            groupValue: _value,
                                                                                            onChanged: (value) {
                                                                                              myStateMetodoPago(() {
                                                                                                _value = value;
                                                                                              });
                                                                                            }))
                                                                                        // trailing: Container(decoration: BoxDecoration(border: Border.all(color:prs.colorGrisBordes )),)
                                                                                        ),
                                                                                    Divider(
                                                                                      color: Colors.black87,
                                                                                    ),
                                                                                    ListTile(
                                                                                        leading: Image(
                                                                                          height: 50,
                                                                                          width: 50,
                                                                                          image: AssetImage(
                                                                                            "assets/png/plin.png",
                                                                                          ),
                                                                                        ),
                                                                                        title: Text.rich(
                                                                                          TextSpan(
                                                                                            children: [
                                                                                              TextSpan(
                                                                                                text: "Plin",
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 17),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        trailing: Transform.scale(
                                                                                           scale: 1.5,
                                                                                          child:Radio(
                                                                                            value: 3,
                                                                                            groupValue: _value,
                                                                                            onChanged: (value) {
                                                                                              myStateMetodoPago(() {
                                                                                                _value = value;
                                                                                              });
                                                                                            }))
                                                                                        // trailing: Container(decoration: BoxDecoration(border: Border.all(color:prs.colorGrisBordes )),)
                                                                                        ),
                                                                                    Divider(
                                                                                      color: Colors.black87,
                                                                                    ),
                                                                                    misTarjetas.length > 0
                                                                                        ? ListTile(
                                                                                            leading: Image(
                                                                                              height: 50,
                                                                                              width: 50,
                                                                                              image: AssetImage(
                                                                                                "assets/png/tarjetadecredito.png",
                                                                                              ),
                                                                                            ),
                                                                                            // title: Text.rich(
                                                                                            //   TextSpan(
                                                                                            //     children: [
                                                                                            //       TextSpan(
                                                                                            //         text: "Débito •••• •••• ••••",
                                                                                            //         style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 17),
                                                                                            //       ),
                                                                                            //       TextSpan(
                                                                                            //         text: misTarjetas[0]['tarjeta'],
                                                                                            //         style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 17),
                                                                                            //       ),
                                                                                            //     ],
                                                                                            //   ),
                                                                                            // ),
                                                                                            title: Text.rich(
                                                                                              TextSpan(
                                                                                                children: [
                                                                                                  TextSpan(
                                                                                                    text: misTarjetas[0]['alias'],
                                                                                                    style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 17),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                            trailing: Transform.scale(
                                                                                           scale: 1.5,
                                                                                          child:Radio(
                                                                                                value: 4,
                                                                                                groupValue: _value,
                                                                                                onChanged: (value) {
                                                                                                  myStateMetodoPago(() {
                                                                                                    _value = value;
                                                                                                  });
                                                                                                }))
                                                                                            // trailing: Container(decoration: BoxDecoration(border: Border.all(color:prs.colorGrisBordes )),)
                                                                                            )
                                                                                        : SizedBox(),
                                                                                    SizedBox(
                                                                                      height: 20,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: double.infinity,
                                                                                      child: ElevatedButton(
                                                                                        onPressed: () {
                                                                                          if (_value == 0) {
                                                                                            return null;
                                                                                          } else {
                                                                                            metodopago = "Debito";
                                                                                            if (_value == 1) {
                                                                                              metodopago = "Efectivo";
                                                                                            }
                                                                                            if (_value == 2) {
                                                                                              metodopago = "Yape";
                                                                                            }
                                                                                            if (_value == 3) {
                                                                                              metodopago = "Plin";
                                                                                            }
                                                                                            _valueMetodoPago = _value;
                                                                                            myStateTaxi(() {});
                                                                                            Navigator.pop(context);
                                                                                          }
                                                                                        },
                                                                                        child: Text(
                                                                                          "Confirmar",
                                                                                          style: TextStyle(color: Colors.white),
                                                                                        ),
                                                                                        style: ElevatedButton.styleFrom(shape: StadiumBorder(), padding: EdgeInsets.symmetric(vertical: 20), backgroundColor: _value == 0 ? Colors.grey.shade400 : prs.colorMorado, foregroundColor: prs.colorMorado),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ]);
                                                                      }));
                                                            },
                                                            icon: Icon(
                                                              Icons
                                                                  .arrow_forward_ios_sharp,
                                                              color: prs
                                                                  .colorMorado,
                                                                  size: 40,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Container(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  ElevatedButton(
                                                                onPressed: () => modoviaje ==
                                                                            "Sin Especificar" ||
                                                                        metodopago ==
                                                                            "Sin Especificar"
                                                                    ? null
                                                                    : modoviaje ==
                                                                            "Estandar"
                                                                        ? _startTrip(
                                                                            context,
                                                                            "Taxi",
                                                                            "A")
                                                                        : modoviaje ==
                                                                                "Comodo"
                                                                            ? _startTrip(
                                                                                context,
                                                                                "Taxi",
                                                                                "C")
                                                                            : _startTrip(
                                                                                context,
                                                                                "Taxi",
                                                                                "H"),
                                                                child: Text(
                                                                  "Pedir ahora",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          17,
                                                                      fontFamily:
                                                                          'GoldplayRegular',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                        shape:
                                                                            StadiumBorder(),
                                                                        padding:
                                                                            EdgeInsets
                                                                                .symmetric(
                                                                          vertical:
                                                                              20,
                                                                        ),
                                                                        backgroundColor: modoviaje == "Sin Especificar" || metodopago == "Sin Especificar"
                                                                            ? Colors
                                                                                .grey.shade400
                                                                            : prs
                                                                                .colorMorado,
                                                                        foregroundColor:
                                                                            prs.colorMorado),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ));
                                            });
                                          });
                                    },
                                    child: Text(
                                      "Taxi",
                                      style: TextStyle(
                                          fontFamily: "GoldplayRegular",
                                          color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF1ED673),
                                        foregroundColor: Color(0xFF1ED673),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 30),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50))),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  Image(
                                    image: AssetImage("assets/png/caja.png"),
                                    width: 100,
                                    height: 80,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _price = 0;
                                      _valueModoViaje = 0;
                                      detalleEnvio = "";
                                      espeficaciones = "Sin Especificar";
                                      modoviaje = "Sin Especificar";
                                      showModalBottomSheet(
                                          isScrollControlled: true,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(30),
                                                  topRight:
                                                      Radius.circular(30))),
                                          context: context,
                                          builder: (context) {
                                            return StatefulBuilder(builder:
                                                (BuildContext context,
                                                    StateSetter myStateTaxi) {
                                              return Container(
                                                  padding: EdgeInsets.all(20),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(40),
                                                      topRight:
                                                          Radius.circular(40),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "ENVÍO",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "GoldplayBlack",
                                                              fontSize: 17,
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                              onTap: () =>
                                                                  showModalBottomSheet(
                                                                    isScrollControlled:
                                                                        true,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(30),
                                                                            topRight: Radius.circular(30))),
                                                                    context:
                                                                        context,
                                                                    builder: (context) => StatefulBuilder(builder: (BuildContext
                                                                            context,
                                                                        StateSetter
                                                                            mystate) {
                                                                      return Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 5),
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  SizedBox(
                                                                                    height: 30,
                                                                                  ),
                                                                                  Text(
                                                                                    '¿Seguro que quieres cancelar el proceso de solicitud?',
                                                                                    textAlign: TextAlign.center,
                                                                                    style: TextStyle(
                                                                                      fontFamily: 'GoldplayRegular',
                                                                                      fontSize: 20,
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 20,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: double.infinity,
                                                                                    child: ElevatedButton(
                                                                                      onPressed: () {
                                                                                        _valueMetodoPago = 0;
                                                                                        _valueModoViaje = 0;
                                                                                        detalleEnvio = "";
                                                                                        espeficaciones = "Sin Especificar";
                                                                                        modoviaje = "Sin Especificar";
                                                                                        metodopago = "Sin Especificar";
                                                                                        Navigator.pop(context);
                                                                                        Navigator.pop(context);
                                                                                        widget.mapProvider.cancelTrip();
                                                                                      },
                                                                                      child: Text(
                                                                                        "Sí, seguro",
                                                                                        style: TextStyle(color: Colors.white),
                                                                                      ),
                                                                                      style: ElevatedButton.styleFrom(shape: StadiumBorder(), padding: EdgeInsets.symmetric(vertical: 20), backgroundColor: prs.colorMorado, foregroundColor: prs.colorMorado),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 20,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: double.infinity,
                                                                                    child: ElevatedButton(
                                                                                      onPressed: () {
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      child: Text(
                                                                                        "Cancelar",
                                                                                        style: TextStyle(color: prs.colorMorado),
                                                                                      ),
                                                                                      style: ElevatedButton.styleFrom(shape: StadiumBorder(), side: BorderSide(color: prs.colorMorado, width: 1), elevation: 0, padding: EdgeInsets.symmetric(vertical: 20), backgroundColor: Colors.transparent, foregroundColor: prs.colorMorado),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ]);
                                                                    }),
                                                                  ),
                                                              child: Text(
                                                                "Cancelar",
                                                                style: TextStyle(
                                                                    color: prs
                                                                        .colorMorado,
                                                                    fontSize:
                                                                        17),
                                                              ))
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 30,
                                                      ),
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color: prs
                                                                  .colorGrisBordes),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            20.0,
                                                          ),
                                                        ),
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        child: ListTile(
                                                          leading: Image(
                                                            height: 50,
                                                            width: 50,
                                                            image: AssetImage(
                                                              "assets/png/rutaazul.png",
                                                            ),
                                                          ),
                                                          title: Text(
                                                            "Modo de Envío",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "GoldplayRegular",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 17),
                                                          ),
                                                          subtitle: Text(
                                                              "$modoviaje",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "GoldplayRegular",
                                                                fontSize: 15,
                                                              )),
                                                          trailing: IconButton(
                                                            onPressed: () {
                                                              int _value =
                                                                  _valueModoViaje;
                                                              showModalBottomSheet(
                                                                  isScrollControlled:
                                                                      true,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                              30),
                                                                          topRight: Radius.circular(
                                                                              30))),
                                                                  context:
                                                                      context,
                                                                  builder: (context) =>
                                                                      StatefulBuilder(builder: (BuildContext
                                                                              context,
                                                                          StateSetter
                                                                              myStateModoViaje) {
                                                                        return Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 5),
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    SizedBox(
                                                                                      height: 30,
                                                                                    ),
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Text(
                                                                                          "Modo de envío",
                                                                                          style: TextStyle(
                                                                                            fontFamily: "GoldplayRegular",
                                                                                            fontSize: 17,
                                                                                          ),
                                                                                        ),
                                                                                        GestureDetector(
                                                                                            onTap: () {
                                                                                              Navigator.pop(context);
                                                                                            },
                                                                                            child: Text(
                                                                                              "Cancelar",
                                                                                              style: TextStyle(color: prs.colorMorado, fontSize: 17),
                                                                                            )),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: 30,
                                                                                    ),
                                                                                    ListTile(
                                                                                        leading: Image(
                                                                                          height: 50,
                                                                                          width: 50,
                                                                                          image: AssetImage(
                                                                                            "assets/png/motocicleta.png",
                                                                                          ),
                                                                                        ),
                                                                                        title: Text.rich(
                                                                                          TextSpan(
                                                                                            children: [
                                                                                              TextSpan(
                                                                                                text: ratesEnvio[4]['nombre'],
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 17),
                                                                                              ),
                                                                                              TextSpan(
                                                                                                text: ratesEnvio[4]['subnombre'],
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontSize: 17),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        subtitle: Text.rich(
                                                                                          TextSpan(
                                                                                            children: [
                                                                                              // TextSpan(
                                                                                              //   text: "S/ ${ratesEnvio[4]['precio'].toString()}",
                                                                                              //   style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 15),
                                                                                              // ),
                                                                                              TextSpan(
                                                                                                text: "• ${ratesEnvio[4]['descripcion']}",
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontSize: 15),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        trailing: Transform.scale(
                                                                                           scale: 1.5,
                                                                                          child: Radio(
                                                                                            value: 1,
                                                                                            groupValue: _value,
                                                                                            onChanged: (value) {
                                                                                              myStateModoViaje(() {
                                                                                                _value = value;
                                                                                              });
                                                                                            },
                                                                                          ),
                                                                                        )),
                                                                                    Divider(
                                                                                      color: Colors.black87,
                                                                                    ),
                                                                                    ListTile(
                                                                                        leading: Image(
                                                                                          height: 50,
                                                                                          width: 50,
                                                                                          image: AssetImage(
                                                                                            "assets/png/auto.png",
                                                                                          ),
                                                                                        ),
                                                                                        title: Text.rich(
                                                                                          TextSpan(
                                                                                            children: [
                                                                                              TextSpan(
                                                                                                text: ratesEnvio[5]['nombre'],
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 17),
                                                                                              ),
                                                                                              TextSpan(
                                                                                                text: ratesEnvio[5]['subnombre'],
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontSize: 17),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        subtitle: Text.rich(
                                                                                          TextSpan(
                                                                                            children: [
                                                                                              // TextSpan(
                                                                                              //   text: "S/ ${ratesEnvio[5]['precio'].toString()}",
                                                                                              //   style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 15),
                                                                                              // ),
                                                                                              TextSpan(
                                                                                                text: "• ${ratesEnvio[5]['descripcion']}",
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontSize: 15),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        trailing: Transform.scale(
                                                                                           scale: 1.5,
                                                                                          child:Radio(
                                                                                          value: 2,
                                                                                          groupValue: _value,
                                                                                          onChanged: (value) {
                                                                                            myStateModoViaje(() {
                                                                                              _value = value;
                                                                                            });
                                                                                          },
                                                                                        ))),
                                                                                      Divider(
                                                                                      color: Colors.black87,
                                                                                    ),
                                                                                    usuariosprueba.contains(_prefs.idCliente.toString())?
                                                                                    ListTile(
                                                                                        leading: Image(
                                                                                          height: 50,
                                                                                          width: 50,
                                                                                          image: AssetImage(
                                                                                            "assets/png/auto.png",
                                                                                          ),
                                                                                        ),
                                                                                        title: Text.rich(
                                                                                          TextSpan(
                                                                                            children: [
                                                                                              TextSpan(
                                                                                                text: ratesEnvio[6]['nombre'],
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 17),
                                                                                              ),
                                                                                              TextSpan(
                                                                                                text: ratesEnvio[6]['subnombre'],
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontSize: 17),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        subtitle: Text.rich(
                                                                                          TextSpan(
                                                                                            children: [
                                                                                              // TextSpan(
                                                                                              //   text: "S/ ${ratesEnvio[5]['precio'].toString()}",
                                                                                              //   style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 15),
                                                                                              // ),
                                                                                              TextSpan(
                                                                                                text: "• ${ratesEnvio[6]['descripcion']}",
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontSize: 15),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        trailing: Transform.scale(
                                                                                           scale: 1.5,
                                                                                          child:Radio(
                                                                                          value: 3,
                                                                                          groupValue: _value,
                                                                                          onChanged: (value) {
                                                                                            myStateModoViaje(() {
                                                                                              _value = value;
                                                                                            });
                                                                                          },
                                                                                        ))): SizedBox(),
                                                                                    /*
                                                                                   ListTile(
                                                                                      leading: Image(
                                                                                        height: 50,
                                                                                        width: 50,
                                                                                        image: AssetImage(
                                                                                          "assets/png/comodo.png",
                                                                                        ),
                                                                                      ),
                                                                                      title: Text.rich(
                                                                                        TextSpan(
                                                                                          children: [
                                                                                            TextSpan(
                                                                                              text: "Cómodo ",
                                                                                              style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 17),
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: "(camioneta)",
                                                                                              style: TextStyle(fontFamily: "GoldplayRegular", fontSize: 17),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      subtitle: Text.rich(
                                                                                        TextSpan(
                                                                                          children: [
                                                                                            TextSpan(
                                                                                              text: "S/.8 ",
                                                                                              style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 15),
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: "• hasta 4 personas",
                                                                                              style: TextStyle(fontFamily: "GoldplayRegular", fontSize: 15),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      trailing: Radio(
                                                                                          value: 2,
                                                                                          groupValue: _value,
                                                                                          onChanged: (value) {
                                                                                            myStateModoViaje(() {
                                                                                              _value = value;
                                                                                            });
                                                                                          })),
                                                                                  Divider(
                                                                                    color: Colors.black87,
                                                                                  ),
                                                                                  ListTile(
                                                                                      leading: Image(
                                                                                        height: 50,
                                                                                        width: 50,
                                                                                        image: AssetImage(
                                                                                          "assets/png/carga.png",
                                                                                        ),
                                                                                      ),
                                                                                      title: Text.rich(
                                                                                        TextSpan(
                                                                                          children: [
                                                                                            TextSpan(
                                                                                              text: "Espacio de carga ",
                                                                                              style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 17),
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: "(hatchback)",
                                                                                              style: TextStyle(fontFamily: "GoldplayRegular", fontSize: 17),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      subtitle: Text.rich(
                                                                                        TextSpan(
                                                                                          children: [
                                                                                            TextSpan(
                                                                                              text: "S/.10 ",
                                                                                              style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 15),
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: "• hasta 4 personas",
                                                                                              style: TextStyle(fontFamily: "GoldplayRegular", fontSize: 15),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      trailing: Radio(
                                                                                          value: 3,
                                                                                          groupValue: _value,
                                                                                          onChanged: (value) {
                                                                                            myStateModoViaje(() {
                                                                                              _value = value;
                                                                                            });
                                                                                          })),
                                                                                   */
                                                                                    SizedBox(
                                                                                      height: 20,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: double.infinity,
                                                                                      child: ElevatedButton(
                                                                                        onPressed: () {
                                                                                          if (_value == 0) {
                                                                                            return null;
                                                                                          } else {
                                                                                            modoviaje = "Motocicleta";
                                                                                            _price = double.parse(ratesEnvio[4]['precio'].toString());
                                                                                            if (_value == 2) {
                                                                                              modoviaje = "Automóvil";
                                                                                              _price = double.parse(ratesEnvio[5]['precio'].toString());
                                                                                            }
                                                                                            if (_value == 3) {
                                                                                              modoviaje = "Prueba";
                                                                                              _price = double.parse(ratesEnvio[6]['precio'].toString());
                                                                                            }
                                                                                            // if (_value == 3) {
                                                                                            //   modoviaje = "Camión";
                                                                                            //   _price = 10;
                                                                                            // }
                                                                                            _valueModoViaje = _value;
                                                                                            myStateTaxi(() {});
                                                                                            Navigator.pop(context);
                                                                                          }
                                                                                        },
                                                                                        child: Text(
                                                                                          "Confirmar",
                                                                                          style: TextStyle(color: Colors.white),
                                                                                        ),
                                                                                        style: ElevatedButton.styleFrom(shape: StadiumBorder(), padding: EdgeInsets.symmetric(vertical: 20), backgroundColor: _value == 0 ? Colors.grey.shade500 : prs.colorMorado, foregroundColor: prs.colorMorado),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ]);
                                                                      }));
                                                            },
                                                            icon: Icon(
                                                              Icons
                                                                  .arrow_forward_ios_sharp,
                                                              color: prs
                                                                  .colorMorado,
                                                              size: 40,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color: prs
                                                                  .colorGrisBordes),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            20.0,
                                                          ),
                                                        ),
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        child: ListTile(
                                                          leading: Image(
                                                            height: 50,
                                                            width: 50,
                                                            image: AssetImage(
                                                              "assets/png/cartera.png",
                                                            ),
                                                          ),
                                                          title: Text(
                                                            "Método de pago",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "GoldplayRegular",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 17),
                                                          ),
                                                          subtitle: Text(
                                                              "$metodopago",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "GoldplayRegular",
                                                                fontSize: 15,
                                                              )),
                                                          trailing: IconButton(
                                                            onPressed: () {
                                                              int _value =
                                                                  _valueMetodoPago;
                                                              showModalBottomSheet(
                                                                  isScrollControlled:
                                                                      true,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                              30),
                                                                          topRight: Radius.circular(
                                                                              30))),
                                                                  context:
                                                                      context,
                                                                  builder: (context) =>
                                                                      StatefulBuilder(builder: (BuildContext
                                                                              context,
                                                                          StateSetter
                                                                              myStateMetodoPago) {
                                                                        return Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 5),
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    SizedBox(
                                                                                      height: 30,
                                                                                    ),
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Text(
                                                                                          "Método de pago",
                                                                                          style: TextStyle(
                                                                                            fontFamily: "GoldplayRegular",
                                                                                            fontSize: 17,
                                                                                          ),
                                                                                        ),
                                                                                        GestureDetector(
                                                                                            onTap: () {
                                                                                              Navigator.pop(context);
                                                                                            },
                                                                                            child: Text(
                                                                                              "Cancelar",
                                                                                              style: TextStyle(color: prs.colorMorado, fontSize: 17),
                                                                                            )),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: 30,
                                                                                    ),
                                                                                    ListTile(
                                                                                        leading: Image(
                                                                                          height: 50,
                                                                                          width: 50,
                                                                                          image: AssetImage(
                                                                                            "assets/png/efectivo.png",
                                                                                          ),
                                                                                        ),
                                                                                        title: Text.rich(
                                                                                          TextSpan(
                                                                                            children: [
                                                                                              TextSpan(
                                                                                                text: "Efectivo",
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 17),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        trailing: Transform.scale(
                                                                                           scale: 1.5,
                                                                                          child:Radio(
                                                                                            value: 1,
                                                                                            groupValue: _value,
                                                                                            onChanged: (value) {
                                                                                              myStateMetodoPago(() {
                                                                                                _value = value;
                                                                                              });
                                                                                            }))
                                                                                        // trailing: Container(decoration: BoxDecoration(border: Border.all(color:prs.colorGrisBordes )),)
                                                                                        ),
                                                                                    Divider(
                                                                                      color: Colors.black87,
                                                                                    ),
                                                                                    ListTile(
                                                                                        leading: Image(
                                                                                          height: 50,
                                                                                          width: 50,
                                                                                          image: AssetImage(
                                                                                            "assets/png/yape.png",
                                                                                          ),
                                                                                        ),
                                                                                        title: Text.rich(
                                                                                          TextSpan(
                                                                                            children: [
                                                                                              TextSpan(
                                                                                                text: "Yape",
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 17),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        trailing: Transform.scale(
                                                                                           scale: 1.5,
                                                                                          child:Radio(
                                                                                            value: 2,
                                                                                            groupValue: _value,
                                                                                            onChanged: (value) {
                                                                                              myStateMetodoPago(() {
                                                                                                _value = value;
                                                                                              });
                                                                                            }))
                                                                                        // trailing: Container(decoration: BoxDecoration(border: Border.all(color:prs.colorGrisBordes )),)
                                                                                        ),
                                                                                    Divider(
                                                                                      color: Colors.black87,
                                                                                    ),
                                                                                    ListTile(
                                                                                        leading: Image(
                                                                                          height: 50,
                                                                                          width: 50,
                                                                                          image: AssetImage(
                                                                                            "assets/png/plin.png",
                                                                                          ),
                                                                                        ),
                                                                                        title: Text.rich(
                                                                                          TextSpan(
                                                                                            children: [
                                                                                              TextSpan(
                                                                                                text: "Plin",
                                                                                                style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 17),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        trailing: Transform.scale(
                                                                                           scale: 1.5,
                                                                                          child:Radio(
                                                                                            value: 3,
                                                                                            groupValue: _value,
                                                                                            onChanged: (value) {
                                                                                              myStateMetodoPago(() {
                                                                                                _value = value;
                                                                                              });
                                                                                            }))
                                                                                        // trailing: Container(decoration: BoxDecoration(border: Border.all(color:prs.colorGrisBordes )),)
                                                                                        ),
                                                                                    Divider(
                                                                                      color: Colors.black87,
                                                                                    ),
                                                                                    misTarjetas.length > 0
                                                                                        ? ListTile(
                                                                                            leading: Image(
                                                                                              height: 50,
                                                                                              width: 50,
                                                                                              image: AssetImage(
                                                                                                "assets/png/tarjetadecredito.png",
                                                                                              ),
                                                                                            ),
                                                                                            // title: Text.rich(
                                                                                            //   TextSpan(
                                                                                            //     children: [
                                                                                            //       TextSpan(
                                                                                            //         text: "Débito •••• •••• ••••",
                                                                                            //         style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 17),
                                                                                            //       ),
                                                                                            //       TextSpan(
                                                                                            //         text: misTarjetas[0]['tarjeta'],
                                                                                            //         style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 17),
                                                                                            //       ),
                                                                                            //     ],
                                                                                            //   ),
                                                                                            // ),
                                                                                            title: Text.rich(
                                                                                              TextSpan(
                                                                                                children: [
                                                                                                  TextSpan(
                                                                                                    text: misTarjetas[0]['alias'],
                                                                                                    style: TextStyle(fontFamily: "GoldplayRegular", fontWeight: FontWeight.w600, fontSize: 17),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                            trailing: Transform.scale(
                                                                                           scale: 1.5,
                                                                                          child:Radio(
                                                                                                value: 4,
                                                                                                groupValue: _value,
                                                                                                onChanged: (value) {
                                                                                                  myStateMetodoPago(() {
                                                                                                    _value = value;
                                                                                                  });
                                                                                                }))
                                                                                            // trailing: Container(decoration: BoxDecoration(border: Border.all(color:prs.colorGrisBordes )),)
                                                                                            )
                                                                                        : SizedBox(),
                                                                                    SizedBox(
                                                                                      height: 20,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: double.infinity,
                                                                                      child: ElevatedButton(
                                                                                        onPressed: () {
                                                                                          if (_value == 0) {
                                                                                            return null;
                                                                                          } else {
                                                                                            metodopago = "Debito";
                                                                                            if (_value == 1) {
                                                                                              metodopago = "Efectivo";
                                                                                            }
                                                                                            if (_value == 2) {
                                                                                              metodopago = "Yape";
                                                                                            }
                                                                                            if (_value == 3) {
                                                                                              metodopago = "Plin";
                                                                                            }
                                                                                            _valueMetodoPago = _value;
                                                                                            myStateTaxi(() {});
                                                                                            Navigator.pop(context);
                                                                                          }
                                                                                        },
                                                                                        child: Text(
                                                                                          "Confirmar",
                                                                                          style: TextStyle(color: Colors.white),
                                                                                        ),
                                                                                        style: ElevatedButton.styleFrom(shape: StadiumBorder(), padding: EdgeInsets.symmetric(vertical: 20), backgroundColor: _value == 0 ? Colors.grey.shade400 : prs.colorMorado, foregroundColor: prs.colorMorado),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ]);
                                                                      }));
                                                            },
                                                            icon: Icon(
                                                              Icons
                                                                  .arrow_forward_ios_sharp,
                                                              color: prs
                                                                  .colorMorado,
                                                                  size: 40,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color: prs
                                                                  .colorGrisBordes),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            20.0,
                                                          ),
                                                        ),
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        child: ListTile(
                                                          leading: Image(
                                                            height: 50,
                                                            width: 50,
                                                            image: AssetImage(
                                                              "assets/png/rutaamarillo.png",
                                                            ),
                                                          ),
                                                          title: Text(
                                                            "Especificaciones",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "GoldplayRegular",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 17),
                                                          ),
                                                          subtitle: Text(
                                                              "$espeficaciones",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "GoldplayRegular",
                                                                fontSize: 15,
                                                              )),
                                                          trailing: IconButton(
                                                            onPressed: () {
                                                              int _value =
                                                                  _valueMetodoPago;
                                                              String
                                                                  detalleEnvioInterno =
                                                                  detalleEnvio;
                                                              showModalBottomSheet(
                                                                  isScrollControlled:
                                                                      true,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                              30),
                                                                          topRight: Radius.circular(
                                                                              30))),
                                                                  context:
                                                                      context,
                                                                  builder: (context) =>
                                                                      StatefulBuilder(builder: (BuildContext
                                                                              context,
                                                                          StateSetter
                                                                              myStateMetodoPago) {
                                                                        return Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 5),
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    SizedBox(
                                                                                      height: 30,
                                                                                    ),
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Text(
                                                                                          "Especificaciones",
                                                                                          style: TextStyle(
                                                                                            fontFamily: "GoldplayRegular",
                                                                                            fontSize: 17,
                                                                                          ),
                                                                                        ),
                                                                                        GestureDetector(
                                                                                            onTap: () {
                                                                                              Navigator.pop(context);
                                                                                            },
                                                                                            child: Text(
                                                                                              "Cancelar",
                                                                                              style: TextStyle(color: prs.colorMorado, fontSize: 17),
                                                                                            )),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: 30,
                                                                                    ),
                                                                                    TextField(
                                                                                      keyboardType: TextInputType.multiline,
                                                                                      onChanged: (value) {
                                                                                        detalleEnvioInterno = value;
                                                                                      },
                                                                                      maxLines: 12,
                                                                                      maxLength: 1000,
                                                                                      decoration: InputDecoration(enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.5, color: Colors.black))),
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: 20,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: double.infinity,
                                                                                      child: ElevatedButton(
                                                                                        onPressed: () {
                                                                                          if (detalleEnvioInterno.isNotEmpty) {
                                                                                            detalleEnvio = detalleEnvioInterno;
                                                                                            espeficaciones = "Detallado";
                                                                                          }
                                                                                          myStateTaxi(() {});
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        child: Text(
                                                                                          "Confirmar",
                                                                                          style: TextStyle(color: Colors.white),
                                                                                        ),
                                                                                        style: ElevatedButton.styleFrom(shape: StadiumBorder(), padding: EdgeInsets.symmetric(vertical: 20), backgroundColor: _value == 0 ? Colors.grey.shade400 : prs.colorMorado, foregroundColor: prs.colorMorado),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ]);
                                                                      }));
                                                            },
                                                            icon: Icon(
                                                              Icons
                                                                  .arrow_forward_ios_sharp,
                                                              color: prs
                                                                  .colorMorado,
                                                                  size: 40,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Container(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  ElevatedButton(
                                                                onPressed: () => modoviaje ==
                                                                            "Sin Especificar" ||
                                                                        metodopago ==
                                                                            "Sin Especificar"
                                                                    ? null
                                                                    : modoviaje ==
                                                                            "Motocicleta"
                                                                        ? _startTrip(
                                                                            context,
                                                                            "Envio",
                                                                            "M")
                                                                        : modoviaje ==
                                                                            "Automóvil" 
                                                                            ? _startTrip(
                                                                            context,
                                                                            "Envio",
                                                                            "A")
                                                                            : _startTrip(
                                                                            context,
                                                                            "Envio",
                                                                            "P"),
                                                                child: Text(
                                                                  "Pedir ahora",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          17,
                                                                      fontFamily:
                                                                          'GoldplayRegular',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                        shape:
                                                                            StadiumBorder(),
                                                                        padding:
                                                                            EdgeInsets
                                                                                .symmetric(
                                                                          vertical:
                                                                              20,
                                                                        ),
                                                                        backgroundColor: modoviaje == "Sin Especificar" || metodopago == "Sin Especificar"
                                                                            ? Colors
                                                                                .grey.shade400
                                                                            : prs
                                                                                .colorMorado,
                                                                        foregroundColor:
                                                                            prs.colorMorado),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ));
                                            });
                                          });
                                    },
                                    child: Text(
                                      "Envíos",
                                      style: TextStyle(
                                          fontFamily: "GoldplayRegular",
                                          color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF1681EC),
                                        foregroundColor: Color(0xFF1681EC),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 30),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50))),
                                  )
                                ],
                              ),
                              /* Column(
                                children: [
                                  Image(
                                    image: AssetImage("assets/png/camion.png"),
                                    height: 80,
                                    width: 100,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {},
                                    child: Text(
                                      "Flete",
                                      style: TextStyle(
                                          fontFamily: "GoldplayRegular",
                                          color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFFB9E41),
                                        foregroundColor: Color(0xFFFB9E41),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 30),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50))),
                                  )
                                ],
                              ), */
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )
        : const Padding(
            padding: EdgeInsets.only(bottom: 15.0),
            child: Center(
              child: SizedBox(width: 30, height: 30),
            ),
          );
  }
}
