import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart';
import 'package:mimo/Core/Constants/Constants.dart';
import 'package:mimo/Core/Constants/DemoData.dart';
import 'package:mimo/Core/Models/Drivers.dart';
import 'package:mimo/Core/Repository/mapRepository.dart';
import 'package:mimo/Core/Utils/LogUtils.dart';
import 'package:mimo/Core/Utils/Utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as location;
import 'package:geolocator/geolocator.dart';
import 'package:mimo/model/map_action.dart';
import 'package:mimo/model/trip_model.dart';
import 'package:mimo/model/user_model.dart';
import 'package:mimo/pagesTaxis/services/database_service.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:mimo/preference/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart' show rootBundle;

/// A viewModel kind of class for handling Map related information and updating.
/// We are using Provider with notifyListeners() for the sake of simplicity but will update with dynamic approach
/// Provider : https://pub.dev/packages/provider
class MapModel extends ChangeNotifier {
  final mapScreenScaffoldKey = GlobalKey<ScaffoldState>();
  // Tag for Logs
  static const TAG = "MapModel";
  //Current Position and Destination Position and Pickup Point
  LatLng _currentPosition, _destinationPosition, _pickupPosition;
  // Default Camera Zoom
  double currentZoom = 19;
  // Set of all the markers on the map
  Set<Marker> _markers = Set();
  // Set of all the polyLines/routes on the map
  Set<Polyline> _polyLines = Set();
  // Pickup Predictions using Places Api, It is the list of Predictions we get from the textchanges the PickupText field in the mainScreen
  List<Prediction> pickupPredictions = [];
  //Same as PickupPredictions but for destination TextField in mainScreen
  List<Prediction> destinationPredictions = [];
  //Map Controller
  GoogleMapController _mapController;
  // Map Repository for connection to APIs
  MapRepository _mapRepository = MapRepository();
  // FormField Controller for the pickup field
  TextEditingController pickupFormFieldController = TextEditingController();
  // FormField Controller for the destination field
  TextEditingController destinationFormFieldController =
      TextEditingController();
  Completer<GoogleMapController> _controllerComplete = Completer();
  double _costkm, _cost;
  double get cost => _cost;
  double get costkm => _costkm;
  double _distance;
  double get distance => _distance;
  String _timeTrip;
  String get timeTrip => _timeTrip;
  // Location Object to get current Location
  location.Location _location = location.Location();
  // currentPosition Getter
  LatLng get currentPosition => _currentPosition;
  // currentPosition Getter
  LatLng get destinationPosition => _destinationPosition;
  // currentPosition Getter
  LatLng get pickupPosition => _pickupPosition;
  // MapRepository Getter
  MapRepository get mapRepo => _mapRepository;
  // MapController Getter
  GoogleMapController get mapController => _mapController;
  // Markers Getter
  Set<Marker> get markers => _markers;
  // PolyLines Getter
  Set<Polyline> get polyLines => _polyLines;
  get randomZoom => 20.0;
  //VARIABLES TAXI_APP
  Position _deviceLocation;
  Position get deviceLocation => _deviceLocation;
  // String _carPin;
  // String get carPin => _carPin;
  // String _selectionPin;
  // String get selectionPin => _selectionPin;
  GoogleMapController _controller;
  MapAction _mapAction;
  MapAction get mapAction => _mapAction;
  Trip _ongoingTrip;
  Timer _tripCancelTimer;
  StreamSubscription<Trip> _tripStream;
  Marker _remoteMarker;
  Marker get remoteMarker => _remoteMarker;
  String _remoteAddress;
  LatLng _remoteLocation;
  LatLng get remoteLocation => _remoteLocation;
  String _deviceAddress;
  String get deviceAddress => _deviceAddress;
  bool _driverArrivingInit = false;
  String get remoteAddress => _remoteAddress;
  Trip get ongoingTrip => _ongoingTrip;
  DatabaseService _dbService = DatabaseService();
  StreamSubscription<User> _driverStream;
  GlobalKey<ScaffoldState> _scaffoldKey;
  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;
  bool showPredictionListAutoComplete = true;

  MapModel() {
    _polyLines = {};
    _markers = {};
    markers.clear();
    polyLines.clear();
    pickupPredictions = [];
    pickupFormFieldController.text = "";
    destinationPredictions = [];
    destinationFormFieldController.text = "";
    _pickupPosition = null;
    _destinationPosition = null;
  }

  /// Default Constructor
  initValues({scaffoldKeyParam}) {
    _polyLines = {};
    _markers = {};
    markers.clear();
    polyLines.clear();
    pickupPredictions = [];
    pickupFormFieldController.text = "";
    destinationPredictions = [];
    destinationFormFieldController.text = "";
    _pickupPosition = null;
    _destinationPosition = null;
    setScaffoldKey(scaffoldKeyParam);
    //getting user Current Location

    _getUserLocation(isInit: true);
    // :'';
    //fetchNearbyDrivers(DemoData.nearbyDrivers);
    //A listener on _location to always get current location and update it.
    _location.onLocationChanged.listen((event) async {
      _currentPosition = LatLng(event.latitude, event.longitude);
      markers.removeWhere((marker) {
        return marker.markerId.value == Constants.currentLocationMarkerId;
      });
      markers.remove(
          Marker(markerId: MarkerId(Constants.currentLocationMarkerId)));
      markers.add(Marker(
          markerId: MarkerId(Constants.currentLocationMarkerId),
          position: _currentPosition,
          rotation: event.heading - 78,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(
            await Utils.getBytesFromAsset(
                "assets/png/currentUserIcon.png", 150),
          )));
      notifyListeners();
    });
  }

  ///Callback whenever data in Pickup TextField is changed
  ///onChanged()
  onPickupTextFieldChanged(String string) async {
    if (string.isEmpty) {
      pickupPredictions = null;
    } else {
      try {
        await mapRepo.getAutoCompleteResponse(string).then((response) {
          updatePickupPointSuggestions(response.predictions);
        });
      } catch (e) {
        print(e);
      }
    }
  }

  void setScaffoldKey(GlobalKey<ScaffoldState> scaffoldKey) {
    _scaffoldKey = scaffoldKey;
  }

  ///Callback whenever data in destination TextField is changed
  ///onChanged()
  onDestinationTextFieldChanged(String string) async {
    if (string.isEmpty) {
      destinationPredictions = null;
    } else {
      try {
        await mapRepo.getAutoCompleteResponse(string).then((response) {
          updateDestinationSuggestions(response.predictions);
        });
      } catch (e) {
        print(e);
      }
    }
  }

  ///Getting current Location : Works only one time
  void _getUserLocation({isCancel: false, isInit: false}) async {
    PreferenciasUsuario _pref = PreferenciasUsuario();
    QuerySnapshot<Map<String, dynamic>> querySnapshotTrip = await FirebaseFirestore
                  .instance
                  .collection("trips")
                  .where('passengerId', isEqualTo: _pref.idCliente.toString())
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

_location.getLocation().then((data) async {
    if (((lastTrip.accepted != null &&
                lastTrip.accepted &&
                lastTrip.canceled == false) ||
            (lastTrip.arrived != null &&
                lastTrip.arrived &&
                lastTrip.canceled == false) ||
            (lastTrip.started != null && lastTrip.started) ||
            (lastTrip.reachedDestination != null &&
                lastTrip.reachedDestination)) &&
        lastTrip.tripCompleted == null && isInit && success) {
          
      await setOngoingTrip(lastTrip);
      await startListeningToTrip();
      if (lastTrip.accepted != null && lastTrip.accepted) {
        await triggerDriverArriving();
        if (lastTrip.arrived != null && lastTrip.arrived) {
          await triggerDriverArrived();
          if (lastTrip.started != null && lastTrip.started) {
            await triggerTripStarted();
            if (lastTrip.reachedDestination != null &&
                lastTrip.reachedDestination) await triggerReachedDestination();
          }
        }
      }
    }
     else {
      _currentPosition = LatLng(data.latitude, data.longitude);
      _pickupPosition = _currentPosition;
      isCancel
          ? mapController.animateCamera(
              CameraUpdate.newLatLngZoom(_pickupPosition, randomZoom))
          : "";
      /* _deviceLocation = Position(longitude: _currentPosition.longitude, latitude: _currentPosition.latitude, timestamp: DateTime.now(),
      accuracy: 0.0, altitude: 0.0, heading: 0.0, speed: 0.0, speedAccuracy: 0.0); */
      _deviceAddress = await mapRepo
          .getPlaceNameFromLatLng(LatLng(data.latitude, data.longitude));
      pickupFormFieldController.text = _deviceAddress;
      updatePickupMarker();
      notifyListeners();
    }
    });
  }

  ///Creating a Route
  void createCurrentRoute(String encodedPoly) {
    _polyLines.add(Polyline(
        polylineId: PolylineId(Constants.currentRoutePolylineId),
        width: 3,
        geodesic: true,
        points: Utils.convertToLatLng(Utils.decodePoly(encodedPoly)),
        color: Color.fromARGB(255, 34, 8, 201)));
    notifyListeners();
  }

  ///Adding or updating Destination Marker on the Map
  updateDestinationMarker() async {
    if (destinationPosition == null) return;
    Marker markerDestination = Marker(
        markerId: MarkerId(Constants.destinationMarkerId),
        position: destinationPosition,
        draggable: true,
        onDragEnd: onDestinationMarkerDragged,
        anchor: Offset(0.5, 0.5),
        infoWindow: InfoWindow(title: "Fin"),
        icon: BitmapDescriptor.fromBytes(
            await Utils.getBytesFromAsset("assets/png/indicador2.png", 80)));
    markers.add(markerDestination);
    _remoteMarker = markerDestination;
    notifyListeners();
  }

  ///Adding or updating Destination Marker on the Map
  updatePickupMarker() async {
    if (pickupPosition == null) return;
    
    _markers.add(Marker(
        markerId: MarkerId(Constants.pickupMarkerId),
        position: pickupPosition,
        draggable: true,
        onDragEnd: onPickupMarkerDragged,
        anchor: Offset(0.5, 0.5),
        infoWindow: InfoWindow(title: "Inicio"),
        icon: BitmapDescriptor.fromBytes(
            await Utils.getBytesFromAsset("assets/png/indicador.png", 80))));

    notifyListeners();
  }

  ///Updating Pickup Suggestions
  updatePickupPointSuggestions(List<Prediction> predictions) {
    pickupPredictions = predictions;
    notifyListeners();
  }

  ///Updating Destination
  updateDestinationSuggestions(List<Prediction> predictions) {
    destinationPredictions = predictions;
    notifyListeners();
  }

  ///on Destination predictions item clicked
  onDestinationPredictionItemClick(Prediction prediction) async {
    
    updateDestinationSuggestions(null);
    _remoteAddress = prediction.description;
    destinationFormFieldController.text = prediction.description;
    _destinationPosition =
        await mapRepo.getLatLngFromAddress(prediction.description);
    onDestinationPositionChanged();
    notifyListeners();
  }

  ///on Pickup predictions item clicked
  onPickupPredictionItemClick(Prediction prediction) async {
    updatePickupPointSuggestions(null);
    _deviceAddress = prediction.description;
    pickupFormFieldController.text = prediction.description;
    _pickupPosition =
        await mapRepo.getLatLngFromAddress(prediction.description);
    onPickupPositionChanged();
    notifyListeners();
  }

  // ! SEND REQUEST
  void sendRouteRequest(bool isPickup) async {
    if (_pickupPosition == null) {
      pickupFormFieldController.text = "Es requerido";
      return;
    } else if (_destinationPosition == null) {
      destinationFormFieldController.text = "Es requerido";
      return;
    }
    changeMapAction(MapAction.tripSelected);
    notifyListeners();
    await mapRepo
        .getRouteCoordinates(_pickupPosition, _destinationPosition)
        .then((route) async {
      isPickup
          ? setDeviceAddress(_pickupPosition)
          : setRemoteAddress(_destinationPosition);
      createCurrentRoute(route);
      calculateDistance(Utils.convertToLatLng(Utils.decodePoly(route)));
      notifyListeners();
    });
  }

  /// listening to camera moving event
  void onCameraMove(CameraPosition position) {
    //ProjectLog.logIt(TAG, "onCameraMove", position.target.toString());
    currentZoom = position.zoom;
    notifyListeners();
  }

  /// when map is created
  void onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    _controller = controller;

    // Cambiar Estilo del mapa
    rootBundle.loadString('assets/mapStyle.txt').then((string) {
      _mapController.setMapStyle(string);
    });

    notifyListeners();
  }

  bool checkDestinationOriginForNull() {
    if (pickupPosition == null || destinationPosition == null)
      return false;
    else
      return true;
  }

  void onMyLocationFabClicked() {
    // check if ride is ongoing or not, if not that show current position
    // else we will show the camera at the mid point of both locations
    ProjectLog.logIt(TAG, "Moving to Current Position", "...");
    mapController.animateCamera(CameraUpdate.newLatLngZoom(
        currentPosition, 15.0 + Random().nextInt(4)));
  }

  void fetchNearbyDrivers(List<Driver> list) {
    if (list != null && list.isNotEmpty)
      list.forEach((driver) async {
        markers.add(Marker(
            markerId: MarkerId(driver.driverId),
            infoWindow: InfoWindow(title: driver.carDetail.carCompanyName),
            position: driver.currentLocation,
            anchor: Offset(0.5, 0.5),
            icon: BitmapDescriptor.fromBytes(
                await Utils.getBytesFromAsset("assets/png/auto.png", 80))));
        notifyListeners();
      });
  }

  void onDestinationPositionChanged() {
    updateDestinationMarker();
    mapController.animateCamera(
        CameraUpdate.newLatLngZoom(destinationPosition, randomZoom));
    if (pickupPosition != null) sendRouteRequest(false);
    notifyListeners();
  }

  void onPickupPositionChanged() {
    updatePickupMarker();
    mapController
        .animateCamera(CameraUpdate.newLatLngZoom(pickupPosition, randomZoom));
    if (destinationPosition != null) sendRouteRequest(true);
    notifyListeners();
  }

  void onPickupMarkerDragged(LatLng value) async {
    _pickupPosition = value;
    _deviceAddress = await mapRepo.getPlaceNameFromLatLng(value);
    pickupFormFieldController.text = _deviceAddress;
    onPickupPositionChanged();
    notifyListeners();
  }

  void onDestinationMarkerDragged(LatLng latLng) async {
    _destinationPosition = latLng;
    _remoteAddress = await mapRepo.getPlaceNameFromLatLng(latLng);
    destinationFormFieldController.text = _remoteAddress;
    onDestinationPositionChanged();
    notifyListeners();
  }

  void panelIsOpened() {
    if (checkDestinationOriginForNull()) {
      animateCameraForOD();
    }
  }

  Future<PolylineResult> setPolyline(LatLng remotePoint) async {
    _polyLines.clear();
    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
        Constants.mapApiKey,
        PointLatLng(_currentPosition.latitude, _currentPosition.longitude),
        PointLatLng(remotePoint.latitude, remotePoint.longitude),
        optimizeWaypoints: true);
    if (result.points.isNotEmpty) {
      final String polylineId = Constants.currentRoutePolylineId;
      _polyLines.add(
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

  Future<PolylineResult> setPolylineMulti(
      LatLng pickupPoint, LatLng destinationPoint) async {
    _polyLines.clear();
    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
        Constants.mapApiKey,
        PointLatLng(pickupPoint.latitude, pickupPoint.longitude),
        PointLatLng(destinationPoint.latitude, destinationPoint.longitude),
        optimizeWaypoints: true);
    if (result.points.isNotEmpty) {
      final String polylineId = Constants.currentRoutePolylineId;
      _polyLines.add(
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

  void calculateDistance(List<dynamic> points) async {
    double distance = 0;
    for (int i = 0; i < points.length - 1; i++) {
      distance += Geolocator.distanceBetween(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }
    _distance = distance / 1000;
  }

  setCost(double costTrip) {
    _costkm = costTrip;
    notifyListeners();
  }

  void calculateCost() {
    _cost = _distance * _costkm;
    /* if (_distance < 4.0) {
      _cost = _costkm * 4.0;
    } */
    if (_cost < 6.5) {
      _cost = 6.5;
    }
    int fac = pow(10, 1);
    _cost = (_cost * fac).round() / fac;
    notifyListeners();
  }

  void calculateTime() {
    _timeTrip = ((_distance / 22) * 60).round().toString();
    notifyListeners();
  }

  void animateCameraForOD() {
    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
          LatLngBounds(
              northeast: pickupPosition, southwest: destinationPosition),
          100),
    );
  }

  void panelIsClosed() {
    onMyLocationFabClicked();
  }

//METODOS TAXI_APP
  void resetMapAction() {
    _mapAction = MapAction.selectTrip;
    notifyListeners();
  }

  void changeMapAction(MapAction mapAction) {
    _mapAction = mapAction;
  }

  void changeMapActionTemp(MapAction mapAction) {
    _mapAction = mapAction;
    notifyListeners();
  }

  void clearRoutes([bool shouldClearDistanceCost = true, bool listen = false]) {
    _remoteMarker = null;
    _polyLines = {};
    _markers = {};
    markers.clear();
    polyLines.clear();
    if (!listen) {
      pickupPredictions = [];
      pickupFormFieldController.text = "";
      destinationPredictions = [];
      destinationFormFieldController.text = "";
      _pickupPosition = null;
      _destinationPosition = null;
    }
    if (shouldClearDistanceCost) {
      _distance = null;
      _cost = null;
      _timeTrip = null;
    }
    clearRemoteAddress();

    if (mapAction != MapAction.tripStarted) {
      _getUserLocation(isCancel: true);
    }
  }

  void clearRemoteAddress() {
    _remoteAddress = null;
    _remoteLocation = null;
  }

  void stopListeningToTrip() {
    if (_tripStream != null) {
      _tripStream.cancel();
      _tripStream = null;
    }
  }

  void stopAutoCancelTimer() {
    if (_tripCancelTimer != null) {
      _tripCancelTimer.cancel();
      _tripCancelTimer = null;
    }
  }

  void setOngoingTrip(Trip trip) {
    _ongoingTrip = trip;
    notifyListeners();
  }

  void triggerDriverArriving() {
    changeMapAction(MapAction.driverArriving);
    stopAutoCancelTimer();
    startListeningToDriver();
    _distance = null;
    notifyListeners();
  }

  void triggerDriverArrived() {
    changeMapAction(MapAction.driverArrived);
    stopListeningToDriver();
    _polyLines.clear();
    _distance = null;
    notifyListeners();
    animateCameraToPos(
      LatLng(_currentPosition.latitude, _currentPosition.longitude),
      17,
    );
  }

  Future<void> triggerTripStarted() async {
    clearRoutes(false, true);
    changeMapAction(MapAction.tripStarted);
    await setRemoteAddress(
      LatLng(
        _ongoingTrip.destinationLatitude,
        _ongoingTrip.destinationLongitude,
      ),
    );
    if (_ongoingTrip.typeService == "Envio") {
      startListeningToDriver();
      notifyListeners();
    } else {
      addMarker(
        LatLng(
          _ongoingTrip.destinationLatitude,
          _ongoingTrip.destinationLongitude,
        ),
        "assets/png/indicador2.png",
        isDraggable: false,
      );
      if (_pickupPosition != null) {
        PolylineResult polylineResult = await setPolyline(
          LatLng(
            _ongoingTrip.destinationLatitude,
            _ongoingTrip.destinationLongitude,
          ),
        );
        await calculateDistance(polylineResult.points);
      }
      notifyListeners();
      animateCameraToBounds(
        firstPoint: LatLng(_pickupPosition.latitude, _pickupPosition.longitude),
        secondPoint: LatLng(_ongoingTrip.destinationLatitude,
            _ongoingTrip.destinationLongitude),
        padding: 150,
      );
    }
  }

  void triggerReachedDestination() {
    changeMapAction(MapAction.reachedDestination);
    clearRoutes(false);
    notifyListeners();
    if (_ongoingTrip.typeService == "Envio") {
      stopListeningToDriver();
      notifyListeners();
      animateCameraToPos(
          LatLng(ongoingTrip.destinationLatitude,
              ongoingTrip.destinationLongitude),
          17);
    } else {
      animateCameraToPos(
          LatLng(_currentPosition.latitude, _currentPosition.longitude), 17);
    }
  }

  void triggerTripCompleted() {
    resetMapAction();
    cancelTrip();
    ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(
      const SnackBar(content: Text('Viaje Completado ☺☺ !!')),
    );

    notifyListeners();
  }

  void addMarker(
    LatLng latLng,
    String pin, {
    bool isDraggable = true,
    double heading,
  }) async {
    final String markerId = const Uuid().v4();
    final Marker newMarker = Marker(
      markerId: MarkerId(markerId),
      position: latLng,
      draggable: isDraggable,
      onDragEnd: (LatLng newPos) async {
        await updateMarkerPos(newPos);
      },
      rotation: heading ?? 0.0,
      //icon: pin,
      icon: await BitmapDescriptor.fromAssetImage(ImageConfiguration(), pin),
      zIndex: 3,
    );
    _markers.add(newMarker);
    _remoteMarker = newMarker;
  }

  Future<void> updateMarkerPos(LatLng newPos) async {
    if (mapAction == MapAction.tripSelected) {
      Marker marker = _remoteMarker;
      clearRoutes();
      _markers.remove(marker);
      marker = marker.copyWith(positionParam: newPos);
      _markers.add(marker);
      _remoteMarker = marker;
      notifyListeners();
      Future.delayed(const Duration(milliseconds: 500), () async {
        await setRemoteAddress(newPos);
        if (_deviceLocation != null) {
          PolylineResult polylineResult = await setPolyline(newPos);
          calculateDistance(polylineResult.points);
        }
        notifyListeners();
      });
    }
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

  void triggerAutoCancelTrip({
    VoidCallback tripDeleteHandler,
    VoidCallback snackbarHandler,
  }) {
    stopAutoCancelTimer();
    _tripCancelTimer = Timer(
      const Duration(seconds: 120),
      () {
        tripDeleteHandler();
        cancelTrip();
        snackbarHandler();
      },
    );
  }

  void animateCameraToBounds({
    LatLng firstPoint,
    LatLng secondPoint,
    double padding,
  }) {
    _controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: getNorthEastLatLng(firstPoint, secondPoint),
          southwest: getSouthWestLatLng(firstPoint, secondPoint),
        ),
        padding,
      ),
    );
  }

  Future<void> setRemoteAddress(LatLng pos) async {
    _remoteLocation = pos;
    /*_remoteAddress = await mapRepo.getPlaceNameFromLatLng(LatLng(pos.latitude, pos.longitude));
     List<Placemark> places = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );
    _remoteAddress = places[0].street+" "+places[0].subLocality; */
  }

  void animateCameraToPos(LatLng pos, [double zoom = 17]) {
    _controller.animateCamera(CameraUpdate.newLatLngZoom(pos, zoom));
  }

  Future<void> setDeviceAddress(LatLng pos) async {
    _deviceLocation = Position(
        longitude: pos.longitude,
        latitude: pos.latitude,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        floor: 64,
        heading: 0.0,
        isMocked: true,
        speed: 0.0,
        speedAccuracy: 0.0);
    /*_deviceAddress = await mapRepo.getPlaceNameFromLatLng(LatLng(pos.latitude, pos.longitude));
     List<Placemark> places = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );
    _deviceAddress = places[2].name; */
  }

  void startListeningToDriver() {
    
    _driverStream = _dbService.getDriver$(_ongoingTrip.driverId).listen(
      (User driver) async {
        if (driver.userLatitude != null && driver.userLongitude != null) {
          if (mapAction == MapAction.tripStarted) {
            if (_driverArrivingInit) {
              animateCameraToBounds(
                firstPoint: LatLng(
                  driver.userLatitude,
                  driver.userLongitude,
                ),
                secondPoint: LatLng(_ongoingTrip.destinationLatitude,
                    _ongoingTrip.destinationLongitude),
                padding: 120,
              );
              _driverArrivingInit = false;
            }
            clearRoutes(false, true);

            addMarker(
              LatLng(driver.userLatitude, driver.userLongitude),
              "assets/png/indicador2.png",
              isDraggable: false,
              heading: driver.heading,
            );
            addMarker(
              LatLng(
                _ongoingTrip.destinationLatitude,
                _ongoingTrip.destinationLongitude,
              ),
              "assets/png/indicador2.png",
              isDraggable: false,
            );
            mapController.animateCamera(CameraUpdate.newLatLngZoom(
                LatLng(driver.userLatitude, driver.userLongitude), 17));
            notifyListeners();
            PolylineResult polylineResult = await setPolylineMulti(
                LatLng(driver.userLatitude, driver.userLongitude),
                LatLng(
                  _ongoingTrip.destinationLatitude,
                  _ongoingTrip.destinationLongitude,
                ));
            calculateDistance(polylineResult.points);
            notifyListeners();
          } else {
            if (mapAction == MapAction.driverArriving && !_driverArrivingInit) {
              animateCameraToBounds(
                firstPoint: LatLng(
                  _currentPosition.latitude,
                  _currentPosition.longitude,
                ),
                secondPoint: LatLng(driver.userLatitude, driver.userLongitude),
                padding: 120,
              );
              _driverArrivingInit = true;
            }
            clearRoutes(false, true);
            addMarker(
              LatLng(driver.userLatitude, driver.userLongitude),
              "assets/png/indicador2.png",
              isDraggable: false,
              heading: driver.heading,
            );
            notifyListeners();
            PolylineResult polylineResult = await setPolyline(
              LatLng(
                driver.userLatitude,
                driver.userLongitude,
              ),
            );
            calculateDistance(polylineResult.points);
            notifyListeners();
          }
        }
      },
    );
  }

  void stopListeningToDriver() {
    if (_driverStream != null) {
      _driverStream.cancel();
      _driverStream = null;
    }
  }

  void startListeningToTrip() {
    _tripStream = _dbService.getTrip$(_ongoingTrip).listen((Trip trip) {
      setOngoingTrip(trip);
      
      if (trip.canceled != null && trip.canceled) {
        if (mapAction != MapAction.driverArrived) {
          _driverStream.cancel();
        }
        cancelTrip();
      } else if (trip.tripCompleted != null && trip.tripCompleted) {
        triggerTripCompleted();
      } else if (trip.reachedDestination != null && trip.reachedDestination) {
        triggerReachedDestination();
      } else if (trip.started != null && trip.started) {
        triggerTripStarted();
      } else if (trip.arrived != null && trip.arrived) {
        triggerDriverArrived();
      } else if (trip.accepted) {
        triggerDriverArriving();
      }
    });
  }

  void toggleMarkerDraggable() {
    _markers.remove(_remoteMarker);
    _remoteMarker = _remoteMarker.copyWith(
      draggableParam: false,
    );
    _markers.add(_remoteMarker);
  }

  void confirmTrip(Trip trip) {
    changeMapAction(MapAction.searchDriver);
    toggleMarkerDraggable();
    setOngoingTrip(trip);
    startListeningToTrip();
    notifyListeners();
  }

  void cancelTrip() {
    resetMapAction();
    clearRoutes();
    _ongoingTrip = null;
    _driverArrivingInit = false;
    stopListeningToTrip();
    stopAutoCancelTimer();

    notifyListeners();
  }
}
