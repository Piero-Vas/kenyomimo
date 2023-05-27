import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mimo/model/map_action.dart';
import 'package:mimo/model/trip_model.dart';
import 'package:mimo/Core/ProviderModels/MapModel.dart';
import 'package:mimo/pagesTaxis/services/database_service.dart';
import 'dart:convert';
import 'package:http/http.dart';

class SearchDriver extends StatelessWidget {
  const SearchDriver({
    Key key,
    this.mapProvider,
  }) : super(key: key);

  final MapModel mapProvider;

  void _cancelTrip() {
    final DatabaseService dbService = DatabaseService();
    Trip ongoingTrip = mapProvider.ongoingTrip;
    ongoingTrip.chargeId.isNotEmpty ?
    refuseCharge(ongoingTrip.chargeId) : '';
    ongoingTrip.canceled = true;
    dbService.updateTrip(ongoingTrip);
    mapProvider.cancelTrip();
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

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: mapProvider.mapAction == MapAction.searchDriver,
      child: Positioned(
        bottom: 15,
        left: 15,
        right: 15,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Text(
                'Buscando conductor',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'GoldPlayRegular',
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Text(
              //   'Distancia: '+mapProvider.distance.toString().split(".")[0]
              //   +"."+(mapProvider.distance.toString().contains(".") 
              //     ? mapProvider.distance.toString().split(".")[1].length>1 
              //       ? mapProvider.distance.toString().split(".")[1].substring(0,1) 
              //       : mapProvider.distance.toString().split(".")[1].substring(0,0)
              //     :"0")+" km" ?? "Distancia: 0.0 km",
              //   style: TextStyle(
              //     fontSize: 14,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // Text(
              //   'Precio: S/.'+mapProvider.cost.toString() ?? "Precio: S/.0",
              //   style: TextStyle(
              //     fontSize: 14,
              //     fontFamily: 'GoldPlayRegular',
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            "Precio: ",
                       style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'GoldPlayRegular',
                  fontWeight: FontWeight.bold,
                ),
                      ),
                      TextSpan(
                        text:
                            "S/."+mapProvider.cost.toString() ?? "S/.0",
                        style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'GoldPlayRegular',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF800059)
                ),
                      ),
                    ],
                  ),
                  
                ),
              Text(
                'Tiempo de viaje: '+mapProvider.timeTrip.toString()+" min. Aprox." ?? "Tiempo: min.",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'GoldPlayRegular',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              const SpinKitPouringHourGlass(
                color: Colors.black,
                duration: Duration(milliseconds: 1500),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: _cancelTrip,
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(fontFamily: 'GoldPlayRegular',color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}