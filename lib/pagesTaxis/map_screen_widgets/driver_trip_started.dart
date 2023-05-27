import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mimo/pagesTaxis/services/location_service.dart';
import 'package:provider/provider.dart';
import 'package:mimo/model/driver_map_action.dart';
import 'package:mimo/model/trip_model.dart';
import 'package:mimo/Core/ProviderModels/map_provider.dart';
import 'package:mimo/pagesTaxis/services/driver_database_service.dart';
import '../../utils/utils.dart' as utils;
class DriverTripStarted extends StatefulWidget {
  final MapProvider mapProvider;
  const DriverTripStarted({Key key,this.mapProvider}) : super(key: key);

  @override
  State<DriverTripStarted> createState() => _DriverTripStartedState();
}

class _DriverTripStartedState extends State<DriverTripStarted> {
 StreamSubscription<Position> _positionStream;
 double ltConductor;
 double lgConductor ;
  @override
  void initState() {
    // TODO: implement initState
   
    super.initState();
      // Position posten = Position(longitude: 0.0, latitude: latitude, timestamp: DateTime.now(), accuracy: 0.0, altitude: 0.0, heading: 0.0, speed: 0.0, speedAccuracy: 0.0);
     _positionStream = LocationService().getRealtimeDeviceLocation().listen(
      (Position pos) {
        if (widget.mapProvider.controller != null) {
            widget.mapProvider.controller.animateCamera(
              CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(
                  pos.latitude,
                  pos.longitude,
                ),
                bearing: pos.heading,
                tilt: 30,
                zoom: 17,
              ),
            ),
            );
        }
        
       latitudeConductor =pos.latitude;
       longitudeConductor = pos.longitude;
        ltConductor = pos.latitude;
        lgConductor = pos.longitude;
        if(mounted)setState(() {});
        

        if (widget.mapProvider.mapAction == MapAction.tripStarted) {
        widget.mapProvider.updateRoutes(LatLng(pos.latitude,pos.longitude),LatLng(widget.mapProvider.ongoingTrip.destinationLatitude,widget.mapProvider.ongoingTrip.destinationLongitude));
        }
       });
  }




  double latitudeConductor = 0.0;
  double longitudeConductor = 0.0;
  double latitude;
  double longitude;
   void _reachedDestination(Trip ongoingTrip, MapProvider mapProvider,BuildContext context) {
    final DatabaseService dbService = DatabaseService();
    
    latitude = ongoingTrip.destinationLatitude;
    longitude = ongoingTrip.destinationLongitude;
    

    if(latitude+0.0007701>latitudeConductor && latitudeConductor>latitude-0.0007701 
    && longitude+0.0007701>longitudeConductor && longitudeConductor>longitude-0.0007701){
      ongoingTrip.reachedDestination = true;
      dbService.updateTrip(ongoingTrip);
      mapProvider.reachedDestination(ongoingTrip,ongoingTrip.typeService=='Envio');
    }else ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Esta lejos del punto final')),
    );
  }


  @override
  void dispose() {
    // TODO: implement dispose
  _positionStream.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final MapProvider mapProvider = Provider.of<MapProvider>(
      context,
      listen: false,
    );
    Trip ongoingTrip = mapProvider.ongoingTrip ?? Trip();

   
    
    return Visibility(
      visible: mapProvider.mapAction == MapAction.tripStarted,
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
              
              // ElevatedButton(onPressed: (){
                
              // }, child: Text("aaa")),
              // Text("Conductor"),
              // Text('${latitudeConductor}'),
              // Text('${longitudeConductor}'),
              // Text("Destino"),
              // Text('${latitude}'),
              // Text('${longitude}'),
              const Center(
                child: Text(
                  'Viaje iniciado',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ongoingTrip.destinationAddress != null)
                          Column(
                            children: [
                              GestureDetector(
                                 onLongPress: () {
                      Clipboard.setData(new ClipboardData(text: ongoingTrip.destinationAddress));
                    utils.mostrarSnackBar(context, "Texto Copiado",milliseconds: 1000000);
                    },

                                child: _buildInfoText(
                                  'En dirección a: ',
                                  ongoingTrip.destinationAddress,
                                ),
                              ),
                              const SizedBox(height: 2),
                            ],
                          ),
                        if (mapProvider.distanceBetweenRoutes != null)
                          _buildInfoText(
                            'Distancia restante: ',
                            '${mapProvider.distanceBetweenRoutes.toStringAsFixed(2)} Km',
                          )
                        else
                          _buildInfoText(
                            'Distancia restante: ',
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
              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: () => _reachedDestination(ongoingTrip, mapProvider,context),
                child: const Text('DESTINO ALCANZADO'),
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