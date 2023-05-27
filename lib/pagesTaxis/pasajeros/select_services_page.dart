import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mimo/Core/ProviderModels/MapModel.dart';
import 'package:mimo/model/map_action.dart';
import 'package:mimo/pagesTaxis/map_screen_widgets/detail_trip.dart';
import 'package:mimo/pagesTaxis/map_screen_widgets/driver_arrived.dart';
import 'package:mimo/pagesTaxis/map_screen_widgets/driver_arriving.dart';
import 'package:mimo/pagesTaxis/map_screen_widgets/reached_destination.dart';
import 'package:mimo/pagesTaxis/map_screen_widgets/search_driver.dart';
import 'package:mimo/pagesTaxis/map_screen_widgets/trip_started.dart';
import 'package:mimo/pagesTaxis/UI/PredictionsLIstAutoComplete.dart';
import 'package:mimo/pagesTaxis/UI/NoInternetWidget.dart';
import 'package:mimo/widgets/menu_taxis_widget.dart';
import '../../../utils/personalizacion.dart' as prs;
import 'package:provider/provider.dart';
class SelectService extends StatefulWidget {
  //const SelectService({Key key}) : super(key: key);
  //https://maps.googleapis.com/maps/api/place/autocomplete/json?input=argentina&key=AIzaSyCoizTsNmZ2p8_PyrNMLUK5On3Nwsn3NTk&components=country:pe
  @override
  State<SelectService> createState() => _SelectServiceState();
}

class _SelectServiceState extends State<SelectService> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isVisible = false;
  String modoviaje = "Sin Especificar";
  String metodopago = "Sin Especificar";

  @override
  Widget build(BuildContext context) {
    Provider.of<MapModel>(context, listen: false)
        .initValues(scaffoldKeyParam: scaffoldKey);
    return Consumer<MapModel>(
        builder: (BuildContext context, MapModel mapModel, _) {
      return Scaffold(
        key: scaffoldKey,
        extendBodyBehindAppBar: true,
        drawer: mapModel.mapAction == MapAction.reachedDestination ||
                mapModel.mapAction == MapAction.searchDriver ||
                mapModel.mapAction == MapAction.searchDriverTemp ||
                mapModel.mapAction == MapAction.tripStarted ||
                mapModel.mapAction == MapAction.driverArrived ||
                mapModel.mapAction == MapAction.driverArriving ||
                mapModel.currentPosition == null
            ? SizedBox()
            : MenuWidgetTaxis(),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.white,
          iconTheme: IconThemeData(
            color: prs.colorMorado,
          ),
          elevation: 0,
          leading: mapModel.mapAction == MapAction.reachedDestination ||
                  mapModel.mapAction == MapAction.searchDriver ||
                  mapModel.mapAction == MapAction.searchDriverTemp ||
                  mapModel.mapAction == MapAction.tripStarted ||
                  mapModel.mapAction == MapAction.driverArrived ||
                  mapModel.mapAction == MapAction.driverArriving ||
                  mapModel.currentPosition == null
              ? SizedBox()
              : Builder(
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: GestureDetector(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: Container(
                        child: Image(
                          image: AssetImage("assets/png/menu.png"),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        body: mapModel.currentPosition != null
            ? Stack(
                children: [
                  Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                            target: mapModel.currentPosition,
                            zoom: mapModel.currentZoom),
                        onMapCreated: mapModel.onMapCreated,
                        //mapType: MapType.normal,
                        rotateGesturesEnabled: false,
                        padding: const EdgeInsets.only(bottom: 30),
                        tiltGesturesEnabled: false,
                        zoomControlsEnabled: false,
                        markers: mapModel.markers,
                        onCameraMove: mapModel.onCameraMove,
                        polylines: mapModel.polyLines,
                      ),
                      mapModel.mapAction == MapAction.reachedDestination ||
                              mapModel.mapAction == MapAction.searchDriver ||
                              mapModel.mapAction == MapAction.searchDriverTemp ||
                              mapModel.mapAction == MapAction.tripStarted ||
                              mapModel.mapAction == MapAction.driverArrived ||
                              mapModel.mapAction == MapAction.driverArriving
                          ? Container()
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 100,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Image(
                                                image: AssetImage(
                                                  "assets/png/indicador.png",
                                                ),
                                                width: 25,
                                                height: 25,
                                              ),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.70 -
                                                    10,
                                                child:
                                                    PredictionListAutoComplete(
                                                  data: mapModel
                                                      .pickupPredictions,
                                                  textField: TextField(
                                                    cursorColor: Colors.black,
                                                    enabled: mapModel
                                                        .showPredictionListAutoComplete,
                                                    readOnly: !mapModel
                                                        .showPredictionListAutoComplete,
                                                    //onSubmitted: mapModel.onPickupTextFieldChanged,
                                                    onChanged: mapModel
                                                        .onPickupTextFieldChanged,
                                                    controller: mapModel
                                                        .pickupFormFieldController,
                                                    decoration: InputDecoration(
                                                      hintText: "Ubicación",
                                                      hintStyle: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black45,
                                                          fontFamily:
                                                              "GoldplayRegular"),
                                                      fillColor: prs
                                                          .colorGrisAreaTexto,
                                                      filled: true,
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(14.0),
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(14.0),
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                    ),
                                                  ),
                                                  itemTap: mapModel
                                                      .onPickupPredictionItemClick,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Image(
                                                image: AssetImage(
                                                  "assets/png/indicador2.png",
                                                ),
                                                width: 25,
                                                height: 25,
                                              ),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.70 -
                                                    10,
                                                child:
                                                    PredictionListAutoComplete(
                                                  data: mapModel
                                                      .destinationPredictions,
                                                  textField: TextField(
                                                    enabled: mapModel
                                                        .showPredictionListAutoComplete,
                                                    readOnly: !mapModel
                                                        .showPredictionListAutoComplete,
                                                    cursorColor: Colors.black,
                                                    //onSubmitted: mapModel.onDestinationTextFieldChanged,
                                                    onChanged: mapModel
                                                        .onDestinationTextFieldChanged,
                                                    controller: mapModel
                                                        .destinationFormFieldController,
                                                    decoration: InputDecoration(
                                                      hintText: "¿A dónde vas?",
                                                      hintStyle: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black45,
                                                          fontFamily:
                                                              "GoldplayRegular"),
                                                      fillColor: prs
                                                          .colorGrisAreaTexto,
                                                      filled: true,
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(14.0),
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(14.0),
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                    ),
                                                  ),
                                                  itemTap: mapModel
                                                      .onDestinationPredictionItemClick,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: NoInternetWidget(),
                      ),
                    ],
                  ),
                  ConfirmPickup(mapProvider: mapModel),
                  SearchDriver(mapProvider: mapModel),
                  DriverArriving(mapProvider: mapModel),
                  DriverArrived(mapProvider: mapModel),
                  TripStarted(mapProvider: mapModel),
                  ReachedDestination(mapProvider: mapModel),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      );
    });
  }
}