import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mimo/pagesTaxis/services/location_service.dart';
import 'package:mimo/preference/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:mimo/model/trip_model.dart';
import 'package:mimo/Core/ProviderModels/map_provider.dart';
import 'package:mimo/pagesTaxis/services/driver_database_service.dart';
import '../../../utils/personalizacion.dart' as prs;

class BottomDraggableSheet extends StatefulWidget {
  const BottomDraggableSheet({Key key}) : super(key: key);

  @override
  State<BottomDraggableSheet> createState() => _BottomDraggableSheetState();
}

class _BottomDraggableSheetState extends State<BottomDraggableSheet> {
  final DatabaseService _dbService = DatabaseService();
  MapProvider _mapProvider;
  List<Trip> _trips = [];

  final LocationService _locationService = LocationService();
  void getAllTrips() {
    _dbService.getTrips().listen((List<Trip> tripsTemp) async {
      Position posConductor = await _locationService.getLocation();
      List<Trip> trips = tripsTemp.where((Trip trip) {
        
        if (posConductor != null) print(posConductor.latitude);
        
        if (posConductor != null) print(posConductor.longitude);
       
        return trip.pickupLatitude + 0.0430000 > posConductor.latitude &&
                posConductor.latitude>trip.pickupLatitude - 0.0430000 &&
                trip.pickupLongitude + 0.0430000 >posConductor.longitude &&
                posConductor.longitude > trip.pickupLongitude - 0.0430000
            ? true
            : false;
      }).toList();
      if (mounted) {
        setState(() {
          _trips = trips;
        });
      }
    });
  }
  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   // _dbService.getTrips().listen((event) { }).cancel();
  //   miTimer.isActive ?
  //   miTimer.cancel():'';
  //   super.dispose();
  // }

  // Timer miTimer;

  _updateTripCanceled() async{
   
    Timer.periodic(Duration(seconds: 60), (timer) async{
      await FirebaseFirestore.instance.collection("trips")
        .where('canceled', isEqualTo: false)
        .where('accepted', isEqualTo: false)
        .get().then((trips) async{
          
          Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> tripsTemp = await trips.docs.where((tripTemp){
            
             DateTime hoy = DateTime.fromMillisecondsSinceEpoch(tripTemp['createatMili']);
             
           
            hoy.add(Duration(minutes: 2));
             
              
            var retornar = DateTime.now().millisecondsSinceEpoch > tripTemp['createatMili']+120000 ? true : false;
              
            return retornar;
          });
          
        tripsTemp.forEach((trip) async {
          await FirebaseFirestore.instance.collection("trips").doc(trip.id).update({"canceled":true});
        });
    });
    });
  }

  
  void _acceptTrip(Trip trip) async {
    final _prefs = PreferenciasUsuario();
    String id = _prefs.clienteModel.idCliente; 
    String driverLicensePlate = _prefs.clienteModel.driverLicensePlate;
    String driverModel = _prefs.clienteModel.driverModel;
    String driverTradeMark = _prefs.clienteModel.driverTradeMark;
    String driverName = _prefs.clienteModel.nombres + " " + _prefs.clienteModel.apellidos;
    String driverImg = _prefs.clienteModel.img;
    trip.driverImg = driverImg;
    trip.driverName = driverName;
    trip.driverModel = driverModel;
    trip.driverLicensePlate = driverLicensePlate;
    trip.driverColor = _prefs.clienteModel.color;
   
    trip.driverTradeMark = driverTradeMark;
    trip.accepted = true;
    //AQUI DEBES COLOCAR EL ID EN VEZ DE CONDUCTOR
    trip.driverId = id;
    double calification = 0.10000000000001;
    int totalCalification = 0;
   
    await FirebaseFirestore.instance
        .collection("trips")
        .where("driverId",isEqualTo: id).where('tripCompleted', isEqualTo: true)
        .where('wasRated', isEqualTo: true).where('canceled', isEqualTo: false)
        .get()
        .then((QuerySnapshot value) async {
          if(value.size>0){
            totalCalification = value.size;
            double rating = 0;
            value.docs.forEach((QueryDocumentSnapshot element) {
              rating = rating + element['calification'];
            });
            calification = rating / totalCalification;
            setState(() {});
          }
    });
    trip.driverCalification = calification==0.10000000000001 ? "0" : calification.toString();
    await _dbService.updateTrip(trip);
    _mapProvider.acceptTrip(trip);
  }

  @override
  void initState() {
    _mapProvider = Provider.of<MapProvider>(
      context,
      listen: false,
    );
    getAllTrips();
    super.initState();
    // _updateTripCanceled();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.1,
      maxChildSize: 1,
      builder: (BuildContext context, ScrollController controller) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey[200],
                offset: const Offset(0, -2),
                blurRadius: 4,
                spreadRadius: 2,
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Colors.white,
          ),
          child: ListView.builder(
            controller: controller,
            itemCount: _trips.isNotEmpty ? _trips.length + 1 : 2,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Center(
                  child: Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.only(bottom: 5),
                  ),
                );
              } else if (index == 1 && _trips.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Center(
                    child: Text(
                      'No hay solicitudes de viajes',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }

              Trip trip = _trips[index - 1];
              return _buildTripPanel(trip);
            },
          ),
        );
      },
    );
  }

  Widget _buildTripPanel(Trip trip) {
    return GestureDetector(
      onTap: () {
         mostrarShowDialog(trip);
      },
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[50],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            solicitudes(context, trip, false),
            ],
        ),
      ),
    );
  }

  String imgDefault = "https://cdn.icon-icons.com/icons2/1378/PNG/512/avatardefault_92824.png";

  Widget solicitudes(BuildContext context, Trip trip, bool espera) {
    return GestureDetector(
      onTap: () {
        mostrarShowDialog(trip);
      },
      child: Container(
        padding: EdgeInsets.only(top: 10, right: 10, left: 10),
        child: Row(
          children: [
            Container(
              // color: Colors.red,
              width: MediaQuery.of(context).size.width * 0.6 - 20,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: (){
                      mostrarShowDialog(trip);
                    },
                    child: Row(
                      children: [
                        Image(
                          image: AssetImage("assets/png/indicador.png"),
                          height: 20,
                          width: 20,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            trip.pickupAddress,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'GoldplayRegular',
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      mostrarShowDialog(trip);
                    },
                    child: Row(
                      children: [
                        Image(
                          image: AssetImage("assets/png/indicador2.png"),
                          height: 20,
                          width: 20,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            trip.destinationAddress,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'GoldplayRegular',
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: (){
                      mostrarShowDialog(trip);
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: trip.typePayment == 1
                          ? BoxDecoration(
                              color: Color(0xFF15AC6D),
                              borderRadius: BorderRadius.circular(20))
                          : trip.typePayment == 2
                              ? BoxDecoration(
                                  color: Color(0xFF841195),
                                  borderRadius: BorderRadius.circular(20))
                              : trip.typePayment == 3
                                  ? BoxDecoration(
                                      color: Color(0xFF3CB3AE),
                                      borderRadius: BorderRadius.circular(20))
                                  : BoxDecoration(
                                      color: Color(0xFF1746A2),
                                      borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        trip.typePayment == 1
                            ? "S/${trip.cost}, Pago con efectivo"
                            : trip.typePayment == 2
                                ? "S/${trip.cost}, Pago con Yape"
                                : trip.typePayment == 3
                                    ? "S/${trip.cost}, Pago con Plin"
                                    : "S/${trip.cost}, Pago con Tarjeta",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'GoldplayRegular',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  espera
                      ? Image(
                          image: AssetImage("assets/png/clock.png"),
                          height: 25,
                          width: 25,
                        )
                      : Container(),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      // Text(
                      //   trip.distance.toString().split(".")[0] +
                      //       "." +
                      //       (trip.distance.toString().contains(".")
                      //           ? trip.distance
                      //               .toString()
                      //               .split(".")[1]
                      //               .substring(0, 2)
                      //           : "0") +
                      //       " km",
                      //   textAlign: TextAlign.start,
                      //   style: TextStyle(
                      //     color: prs.colorGrisClaro,
                      //     fontSize: 14,
                      //     fontFamily: 'GoldplayRegular',
                      //   ),
                      // ),
                      SizedBox(width: 10),
                      trip.typeService=="Taxi"
                      ? Image(
                          image: AssetImage("assets/png/taxi.jpg"),
                          height: 25,
                          width: 25,
                        )
                      : Image(
                          image: AssetImage("assets/png/envio.jpg"),
                          height: 25,
                          width: 25,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.3 - 10,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      mostrarShowDialog(trip);
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: Image.network(
                          trip.passengerImg == ""
                              ? imgDefault
                              : trip.passengerImg ?? imgDefault,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    trip.passengerName,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'GoldplayRegular',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Viajes " + trip.passengerTrips.toString(),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'GoldplayRegular',
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  mostrarShowDialog(trip){
    return showDialog(
            context: context,
            builder: (context) => StatefulBuilder(builder: (context, setState) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0))),
                    contentPadding: EdgeInsets.only(
                        top: 20, right: 20, left: 20, bottom: 25),
                    elevation: 0,
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: [
                          Row(children: [
                            Expanded(child: Container()),
                            GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  Icons.cancel_rounded,
                                  color: Colors.grey[300],
                                ))
                          ]),
                          const Center(
                            child: Text(
                              'Seleccione una opcion',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _acceptTrip(trip);
                            },
                            child: const Text('Aceptar solicitud',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                                shape: StadiumBorder(),
                                padding: EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                backgroundColor: prs.colorMorado,
                                foregroundColor: prs.colorMorado)),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _mapProvider.showTrip(
                              LatLng(trip.pickupLatitude, trip.pickupLongitude),
                              LatLng(trip.destinationLatitude,
                                  trip.destinationLongitude),
                            );
                          },
                          child: Text('Mostrar en mapa',
                              style: TextStyle(color: prs.colorMorado)),
                          style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(),
                              side:
                                  BorderSide(color: prs.colorMorado, width: 1),
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 20),
                              backgroundColor: Colors.transparent,
                              foregroundColor: prs.colorMorado),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      )
                    ],
                  );
                }));
      
  }

}

