import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:mimo/preference/shared_preferences.dart';
import 'package:mimo/Core/Constants/Constants.dart';
import 'package:mimo/model/driver_map_action.dart';
import 'package:mimo/model/trip_model.dart';
import 'package:mimo/pagesTaxis/services/driver_database_service.dart';
import 'package:mimo/pagesTaxis/services/location_service.dart';
import 'package:flutter/services.dart' show rootBundle;
class MapProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
   GlobalKey<ScaffoldState> _scaffoldKey;
   CameraPosition _cameraPos;
   GoogleMapController _controller;
   Position _deviceLocation;
   String _deviceAddress;
   BitmapDescriptor _selectionPin;
   BitmapDescriptor _personPin;
   Set<Marker> _markers;
   Set<Polyline> _polylines;
   MapAction _mapAction;
   Trip _ongoingTrip;
   double _distanceBetweenRoutes;
   StreamSubscription<Position> _positionStream;
   Completer<GoogleMapController> _controllerComplete = Completer();

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;
  CameraPosition get cameraPos => _cameraPos;
  GoogleMapController get controller => _controller;
  Position get deviceLocation => _deviceLocation;
  String get deviceAddress => _deviceAddress;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  MapAction get mapAction => _mapAction;
  Trip get ongoingTrip => _ongoingTrip;
    CameraPosition _posten ;
  CameraPosition get posten => _posten;
  double get distanceBetweenRoutes => _distanceBetweenRoutes;
  StreamSubscription<Position> get positionStream => _positionStream;

  MapProvider() {
    _scaffoldKey = null;
    _mapAction = MapAction.browse;
    _cameraPos = null;
    _deviceLocation = null;
    _deviceAddress = null;
    _markers = {};
    _polylines = {};
    _ongoingTrip = null;
    _distanceBetweenRoutes = null;
    _positionStream = null;
    setCustomPin();

    if (kDebugMode) {
      print('=====///=============///=====');
      print('Map provider loaded');
      print('///==========///==========///');
    }
  }

  void setScaffoldKey(GlobalKey<ScaffoldState> scaffoldKey) {
    _scaffoldKey = scaffoldKey;
  }

  Future<void> setCustomPin() async {
    _selectionPin = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 0.5, size: Size(10, 10)),
      'images/pin.png',
    );
    _personPin = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 0.5, size: Size(10, 10)),
      'images/map-person.png',
    );
  }

  Future<void> initializeMap({GlobalKey<ScaffoldState> scaffoldKey}) async {
    Position deviceLocationInit;
    LatLng cameraLatLng;

    setScaffoldKey(scaffoldKey);

    if (await _locationService.checkLocationIfPermanentlyDisabled()) {
      showDialog(
        context: _scaffoldKey.currentContext,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text(
              'El permiso de ubicación está deshabilitado permanentemente. Habilítelo desde la configuración de la aplicación',
            ),
            actions: [
              TextButton(
                onPressed: () => Geolocator.openAppSettings(),
                child: const Text('Abrir la configuración de la aplicación'),
              ),
            ],
          );
        },
      );
    } else {
      if (await _locationService.checkLocationPermission()) {
        // try {
          try {
            deviceLocationInit = await _locationService.getLocation().timeout(Duration(seconds: 3));
          } catch (e) {
             deviceLocationInit = Position(longitude:-77.042485 , latitude:-12.049816 , timestamp: DateTime.now(), accuracy: 0.0, altitude: 0.0, heading: 0.0, speed: 0.0, speedAccuracy: 0.0);
          }
          cameraLatLng = LatLng(
            deviceLocationInit.latitude,
            deviceLocationInit.longitude,
          );
          setDeviceLocation(deviceLocationInit);
          setDeviceLocationAddress(
            deviceLocationInit.latitude,
            deviceLocationInit.longitude,
          );
        
      }
    }

    if (deviceLocation == null) {
      cameraLatLng = const LatLng(-12.048898, -77.041260);
    }

    setCameraPosition(cameraLatLng);

    notifyListeners();
  }

  void onMapCreated(GoogleMapController controller)async {
      _controller = controller;

      rootBundle.loadString('assets/mapStyle.txt').then((string) {
      _controller.setMapStyle(string);
    }); 
PreferenciasUsuario _pref = PreferenciasUsuario();
    QuerySnapshot<Map<String, dynamic>> querySnapshotTrip = await FirebaseFirestore
                  .instance
                  .collection("trips")
                  .where('driverId', isEqualTo: _pref.idCliente.toString())
                  .orderBy("createatMili", descending: true)
                  .limit(1)
                  .get();
    Map<String, dynamic> lastTripMap = querySnapshotTrip.size>0 ?
              querySnapshotTrip.docs
              .first
              .data() : {};
          Trip lastTrip = Trip.fromJson(lastTripMap);
    bool success = false;
    if(lastTrip.timeTrip!=null){
      int timeTripInt = int.parse(lastTrip.timeTrip)==0 ? 2 : int.parse(lastTrip.timeTrip)*2;
      DateTime dateTimeTrip = DateTime.fromMillisecondsSinceEpoch(lastTrip.createatMili).add(Duration(minutes: timeTripInt));
      if(dateTimeTrip.millisecondsSinceEpoch>DateTime.now().millisecondsSinceEpoch) success=true;
      }


          if (((lastTrip.accepted != null && lastTrip.accepted && lastTrip.canceled == false) ||
              (lastTrip.arrived != null && lastTrip.arrived && lastTrip.canceled == false) ||
              (lastTrip.started != null && lastTrip.started) ||
              (lastTrip.reachedDestination != null &&
                  lastTrip.reachedDestination)) && lastTrip.tripCompleted == null && success) {
            if (lastTrip.accepted != null && lastTrip.accepted) {
              await acceptTrip(lastTrip);
              if (lastTrip.arrived != null && lastTrip.arrived) {
                await arrivedToPassenger(
                    lastTrip, lastTrip.typeService == 'Envio');
                if (lastTrip.started != null && lastTrip.started) {
                  await startTrip(lastTrip);
                  if (lastTrip.reachedDestination != null &&
                      lastTrip.reachedDestination)
                    await reachedDestination(
                        ongoingTrip, ongoingTrip.typeService == 'Envio');
                }
              }
            }
          }


  }


  void onCameraMove(CameraPosition pos) {
    if (kDebugMode) {
      
    }
    _posten = pos;
  }

  void setCameraPosition(LatLng latLng, {double zoom = 15}) {
    _cameraPos = CameraPosition(
      target: LatLng(latLng.latitude, latLng.longitude),
      zoom: zoom,
    );
  }

  void setDeviceLocation(Position location) {
    _deviceLocation = location;
  }

  void listenToPositionStream() {
    _positionStream = LocationService().getRealtimeDeviceLocation().listen(
      (Position pos) {
        if (kDebugMode) {
          
        }
         _controller.animateCamera(
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
        updateUserLocation(pos);
        setDeviceLocation(pos);
        setDeviceLocationAddress(
          pos.latitude,
          pos.longitude,
        );

        if (mapAction == MapAction.tripAccepted) {
          updateRoutes(
            LatLng(pos.latitude, pos.longitude),
            LatLng(
              _ongoingTrip.pickupLatitude,
              ongoingTrip.pickupLongitude,
            ),
          );
        } else if (mapAction == MapAction.tripStarted) {
          updateRoutes(
            LatLng(pos.latitude, pos.longitude),
            LatLng(
              _ongoingTrip.destinationLatitude,
              ongoingTrip.destinationLongitude,
            ),
          );
        }
      },
    );
  }

  void setDeviceLocationAddress(double latitude, double longitude) {
    placemarkFromCoordinates(latitude, longitude)
        .then((List<Placemark> places) {
      _deviceAddress = places[2].name;

      if (kDebugMode) {
        
      }
    });
  }

  void updateUserLocation(Position pos) {
    final _prefs = PreferenciasUsuario();
    String id = _prefs.clienteModel.idCliente;
    String name = _prefs.clienteModel.nombres + " " +(_prefs.clienteModel.apellidos == null? "" : _prefs.clienteModel.apellidos);
    String email = _prefs.clienteModel.correo;
    
    DatabaseService().updateUser({
      'id': id,
      'username': name,
      'email': email,
      'userType': "driver",
      'heading': pos.heading,
      'userLatitude': pos.latitude,
      'userLongitude': pos.longitude,
    });
  }

  Future<void> updateRoutes(LatLng firstPoint, LatLng lastPoint) async {
    PolylineResult result = await setPolyline(
      firstPoint: firstPoint,
      lastPoint: lastPoint,
    );

    if (_markers.isNotEmpty) {
      calcuDistanceBetweenRoutes(result.points);
      notifyListeners();
    }
  }

  void addMarker(LatLng pos, BitmapDescriptor pin) {
    _markers.add(
      Marker(
        markerId: MarkerId(const Uuid().v4()),
        icon: pin,
        position: pos,
      ),
    );
  }

  Future<PolylineResult> setPolyline({
    LatLng firstPoint,
    LatLng lastPoint,
  }) async {
    _polylines.clear();

    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
      Constants.mapApiKey,
      PointLatLng(firstPoint.latitude, firstPoint.longitude),
      PointLatLng(lastPoint.latitude, lastPoint.longitude),
    );

    if (kDebugMode) {
      
    }

    if (result.points.isNotEmpty) {
      final String polylineId = const Uuid().v4();

      _polylines.add(
        Polyline(
          polylineId: PolylineId(polylineId),
          color: Colors.black87,
          points: result.points
              .map((PointLatLng point) =>
                  LatLng(point.latitude, point.longitude))
              .toList(),
          width: 4,
        ),
      );
    }

    return result;
  }

  void clearPaths() {
    _markers.clear();
    _polylines.clear();
  }

  void changeMapAction(MapAction mapAction) {
    _mapAction = mapAction;
  }

  void resetMapAction() {
    _mapAction = MapAction.browse;
  }

  LatLng getNorthEastLatLng(LatLng firstPoint, LatLng lastPoint) => LatLng(
        firstPoint.latitude >= lastPoint.latitude
            ? firstPoint.latitude
            : lastPoint.latitude,
        firstPoint.longitude >= lastPoint.longitude
            ? firstPoint.longitude
            : lastPoint.longitude,
      );

  LatLng getSouthWestLatLng(LatLng firstPoint, LatLng lastPoint) => LatLng(
        firstPoint.latitude <= lastPoint.latitude
            ? firstPoint.latitude
            : lastPoint.latitude,
        firstPoint.longitude <= lastPoint.longitude
            ? firstPoint.longitude
            : lastPoint.longitude,
      );

  Future<void> showTrip(LatLng pickup, LatLng destination) async {
    _markers.clear();

    addMarker(pickup, _personPin);
    addMarker(destination, _selectionPin);
    await setPolyline(firstPoint: pickup, lastPoint: destination);

    notifyListeners();
    _controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: getNorthEastLatLng(pickup, destination),
          southwest: getSouthWestLatLng(pickup, destination),
        ),
        160,
      ),
    );
  }

  void updateOngoingTrip(Trip trip) {
    _ongoingTrip = trip;
  }

  void calcuDistanceBetweenRoutes(List<PointLatLng> points) {
    double distance = 0;

    for (int i = 0; i < points.length - 1; i++) {
      distance += Geolocator.distanceBetween(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }

    _distanceBetweenRoutes = distance / 1000;
  }

  Future<void> acceptTrip(Trip trip) async {
    changeMapAction(MapAction.tripAccepted);
    clearPaths();
    updateOngoingTrip(trip);
    addMarker(
      LatLng(trip.pickupLatitude, trip.pickupLongitude),
      _personPin,
    );
    PolylineResult polylines = await setPolyline(
      firstPoint: LatLng(trip.pickupLatitude, trip.pickupLongitude),
      lastPoint: LatLng(_deviceLocation.latitude, _deviceLocation.longitude),
    );
    calcuDistanceBetweenRoutes(polylines.points);
    listenToPositionStream();
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            _deviceLocation.latitude,
            _deviceLocation.longitude,
          ),
          bearing: _deviceLocation.heading,
          // tilt: 30,
          zoom: 19,
        ),
      ),
    );

    notifyListeners();
  }

  Future<void> arrivedToPassenger(Trip trip, bool envio) async {
    changeMapAction(MapAction.arrived);
    updateOngoingTrip(trip);
    clearPaths();
    addMarker(
      LatLng(trip.destinationLatitude, trip.destinationLongitude),
      _selectionPin,
    );
    PolylineResult result = await setPolyline(
      firstPoint: LatLng(
        trip.destinationLatitude,
        trip.destinationLongitude,
      ),
      lastPoint: LatLng(
        _deviceLocation.latitude,
        _deviceLocation.longitude,
      ),
    );
    calcuDistanceBetweenRoutes(result.points);
    if(!envio){
      _positionStream.cancel();
      _positionStream = null;
    }

    _controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: getNorthEastLatLng(
            LatLng(trip.destinationLatitude, trip.destinationLongitude),
            LatLng(
              _deviceLocation.latitude,
              _deviceLocation.longitude,
            ),
          ),
          southwest: getSouthWestLatLng(
            LatLng(trip.destinationLatitude, trip.destinationLongitude),
            LatLng(
              _deviceLocation.latitude,
              _deviceLocation.longitude,
            ),
          ),
        ),
        160,
      ),
    );

    notifyListeners();
  }

  Future<void> startTrip(Trip trip) async {
    updateOngoingTrip(trip);
    changeMapAction(MapAction.tripStarted);

    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            _deviceLocation.latitude,
            _deviceLocation.longitude,
          ),
          bearing: _deviceLocation.heading,
          tilt: 30,
          zoom: 17,
        ),
      ),
    );

    notifyListeners();
  }

  void reachedDestination(Trip trip, bool envio) {
    updateOngoingTrip(trip);
    changeMapAction(MapAction.reachedDestination);
    clearPaths();
    _distanceBetweenRoutes = null;

    if(envio){
      _positionStream.cancel();
    _positionStream = null;
    }
    notifyListeners();

    animateCameraToPos(
      LatLng(_deviceLocation.latitude, _deviceLocation.longitude),
      16,
    );
  }

  void completeTrip() {
    resetMapAction();
    _ongoingTrip = null;

    notifyListeners();
  }

  void animateCameraToPos(LatLng pos, [double zoom = 15]) {
    _controller.animateCamera(CameraUpdate.newLatLngZoom(pos, zoom));
  }
  void cancelTrip() {
     resetMapAction();
     clearPaths();
     _ongoingTrip = null;
     notifyListeners();
  }

}