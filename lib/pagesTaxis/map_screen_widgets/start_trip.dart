import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:mimo/pagesTaxis/services/location_service.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:mimo/model/driver_map_action.dart';
import 'package:mimo/model/trip_model.dart';
import 'package:mimo/Core/ProviderModels/map_provider.dart';
import 'package:mimo/pagesTaxis/services/driver_database_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/personalizacion.dart' as prs;


class StartTrip extends StatefulWidget {
  final MapProvider mapProvider;
  const StartTrip({Key key,this.mapProvider}) : super(key: key);

  @override
  State<StartTrip> createState() => _StartTripState();
}
 
class _StartTripState extends State<StartTrip> {
  StreamSubscription<Position> _positionStream;

 double latitudeConductor = 0.0;
  double longitudeConductor = 0.0;
  @override
  void initState() {
    super.initState();
     _positionStream = LocationService().getRealtimeDeviceLocation().listen(
      (Position pos) {
       latitudeConductor =pos.latitude;
       longitudeConductor = pos.longitude;
       
        if(mounted)setState(() {});
       });
  }

  void _cancelTrip(MapProvider mapProvider) async{
    final DatabaseService dbService = DatabaseService();
    Trip ongoingTrip = mapProvider.ongoingTrip;
    ongoingTrip.chargeId.isNotEmpty ?
    refuseCharge(ongoingTrip.chargeId) : '';
    ongoingTrip.canceled = true;
    dbService.updateTrip(ongoingTrip);
    mapProvider.cancelTrip();

    DocumentSnapshot documentReferenceClient = await FirebaseFirestore.instance.collection("client").doc("client_"+ongoingTrip.passengerId.toString()).get();
     List<String> tokens = [documentReferenceClient['token']];
    _createBuyChat('Su viaje ha sido cancelado',tokens,'Viaje Cancelado',22222);
  }

  String get _merchantBaseUrl => 'https://api.openpay.pe/v1/m0qhimwy1aullokkujfg';
  final String apiKeyPublic = "pk_20261e9590c24c1995bd82c30959d12b";
  final String apiKeyPrivate = "sk_da8b8e48791540958a47dae3488abfa9";
  // String get _merchantBaseUrl => 'https://sandbox-api.openpay.pe/v1/mkq9aic4rs51cybtcdut';
  // final String apiKeyPublic = "pk_92bef45248c34ce7a41d59ca30ab72c1";
  // final String apiKeyPrivate = "sk_41d63faafb4c413581fbf776030771da";
  refuseCharge(String chargeId)async{
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$apiKeyPrivate:'));
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': basicAuth,
      'Accept': 'application/json',
    };
    Response response = await post(Uri.parse('$_merchantBaseUrl/charges/$chargeId/refund'),
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
   Future<bool> _createBuyChat( mensaje,List<String> tokens, String tituloNotification, int push) async {
     String mensajeNotification = mensaje;
        Map<String,dynamic> data = {
          "PUSH": push,
          "click_action": "FLUTTER_NOTIFICATION_CLICK", 
          "sound": "default", "priority": "high", "content_available": true, "mutable_content": true, "time_to_live": 180,
          "apns": { "headers": { "apns-priority": "10" }, "payload": { "aps": { "sound": "default" } } }, "android": { "priority": "high", "notification": { "sound": "default" } },
          "json":true
        };
        String dataJson = jsonEncode(data);
        String tokensJson = jsonEncode(tokens);
        return await createNotification(tokensJson, tituloNotification, mensajeNotification, dataJson);
   }
   String keyNotification1 = "key=AAAAvJkV440:APA91bHgpgFXv0AW0MAKmCcty7I0zP3lW-SWBVHa4nsFfMiKfUcnHmnGxmPW05WoWAfjtSZgfkhs_0oD84gx28IwzHKEfj6ANcz0VyO2qwAg-CerrSmw0kD6SbL2FKygiPN9oBdHGd5X";
  final _notificationBaseUrl = "https://fcm.googleapis.com/fcm/send";

  Future<bool> createNotification(String tokens, String tituloNotification, String mensajeNotification, String data) async {
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
      "notification":{ "title": "$tituloNotification", "body": "$mensajeNotification", "sound": "default" },
      "data": $data
    }""";
    http.Response response = await http.post(Uri.parse('$_notificationBaseUrl'), headers: headers, body: body);
    
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _positionStream.cancel();
    super.dispose();
  }
  double latitude;
  double longitude;
   void _startTrip(Trip ongoingTrip, MapProvider mapProvider, BuildContext context) {
    final DatabaseService dbService = DatabaseService();
    // latitudeConductor = mapProvider.deviceLocation.latitude;
    // longitudeConductor = mapProvider.deviceLocation.longitude; 
    latitude = ongoingTrip.pickupLatitude;
     longitude = ongoingTrip.pickupLongitude;
    
    if(latitude+0.0007701>latitudeConductor && latitudeConductor>latitude-0.0007701 && longitude+0.0007701>longitudeConductor && longitudeConductor>longitude-0.0007701){
     
      ongoingTrip.started = true;
      dbService.updateTrip(ongoingTrip);
      mapProvider.startTrip(ongoingTrip);
    }else ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fuera de lugar de punto de recogida')),
    );
  }

  _llamar(Trip ongoingTrip) async {
    
    String _call = 'tel:'+ ongoingTrip.passengerPhone.toString();
    final Uri _url = Uri.parse(_call);
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication))
      throw 'Could not launch $_url';
  }

  @override
  Widget build(BuildContext context) {
    final MapProvider mapProvider = Provider.of<MapProvider>(
      context,
      listen: false,
    );
    Trip ongoingTrip = mapProvider.ongoingTrip ?? Trip();
    return Visibility(
      visible: mapProvider.mapAction == MapAction.arrived,
      child: Positioned(
        bottom: 15,
        left: 15,
        right: 15,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
             
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recogiendo ...',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  RawMaterialButton(
                    onPressed: (){
                       _llamar(ongoingTrip);
                    },
                    child: prs.iconoLlamar,
                    shape: CircleBorder(),
                    fillColor: prs.colorButtonBackground,
                  )
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ongoingTrip.pickupAddress != null)
                          Column(
                            children: [
                              _buildInfoText(
                                'De: ',
                                ongoingTrip.pickupAddress,
                              ),
                              const SizedBox(height: 2),
                            ],
                          ),
                        if (ongoingTrip.destinationAddress != null)
                          Column(
                            children: [
                              _buildInfoText(
                                'A: ',
                                ongoingTrip.destinationAddress,
                              ),
                              const SizedBox(height: 2),
                            ],
                          ),
                        if (mapProvider.distanceBetweenRoutes != null)
                          _buildInfoText(
                            'Distancia: ',
                            '${mapProvider.distanceBetweenRoutes.toStringAsFixed(2)} Km',
                          )
                        else
                          _buildInfoText(
                            'Distancia: ',
                            '--',
                          ),
                          SizedBox(height: 5,),
                         ongoingTrip.passengerShippingDetail != '' ?
                           _buildInfoText(
                                'Detalles de envio: ',
                                ongoingTrip.passengerShippingDetail,
                              ):SizedBox()
                      ],
                    ),
                  ),
                  if (ongoingTrip.cost != null)
                    Chip(
                      label: Text('\S/.${ongoingTrip.cost.toStringAsFixed(2)}'),
                      backgroundColor: Colors.black,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _startTrip(ongoingTrip, mapProvider,context),
                    child: const Text('Empezar viaje'),
                  ),
                  SizedBox(width: 10,),
                  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red
                  ),
                onPressed: ()=>_cancelTrip(mapProvider),
                child: const Text('Cancelar'),
              )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText(String title, String info) {
    return RichText(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: info,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
