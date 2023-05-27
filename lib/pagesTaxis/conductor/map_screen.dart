import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mimo/preference/shared_preferences.dart';
import 'package:mimo/widgets/menu_taxis_widget.dart';
import 'package:provider/provider.dart';
import 'package:mimo/model/driver_map_action.dart';
import 'package:mimo/Core/ProviderModels/map_provider.dart';
import 'package:mimo/pagesTaxis/map_screen_widgets/bottom_draggable_sheet.dart';
import 'package:mimo/pagesTaxis/map_screen_widgets/collect_cash.dart';
import 'package:mimo/pagesTaxis/map_screen_widgets/heading_to_passenger.dart';
import 'package:mimo/pagesTaxis/map_screen_widgets/driver_trip_started.dart';
import 'package:mimo/pagesTaxis/map_screen_widgets/start_trip.dart';
import '../../../utils/personalizacion.dart' as prs;

class MapScreen extends StatefulWidget {
  const MapScreen({Key key}) : super(key: key);
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

@override
  void initState() {
    // TODO: implement initState
    clienteOnLine();
    
    
    super.initState();
  }
 
  bool switchs;
  PreferenciasUsuario _prefs = PreferenciasUsuario();
  Future clienteOnLine()async{
    await FirebaseFirestore.instance
          .collection("client")
          .where("id_cliente", isEqualTo: int.parse(_prefs.idCliente) )
          .limit(1)
          .get()
          .then((QuerySnapshot value) {
        if (value.size > 0) {
          Map client_map = value.docs.first.data() as Map;

             if (client_map['on_line'] == 1) {
              
              setState(() {
                   switchs = true;
              });
              
             }  else{
              
              setState(() {
                   switchs = false;
              });
             
             }
          }});
  }

  Widget _rastrear(MapProvider mapProvider) {
    return mapProvider.mapAction == MapAction.tripAccepted ||
            mapProvider.mapAction == MapAction.arrived ||
            mapProvider.mapAction == MapAction.tripStarted ||
            mapProvider.mapAction == MapAction.reachedDestination 
        ? SizedBox()
        : switchs == null ? SizedBox() : switchs
            ? GestureDetector(
                onTap: () {
                  mapProvider.clearPaths();
                  accionSwitch(false);
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: prs.colorGrisAreaTexto,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Color(0xff1ED673))),
                  width: 130,
                  height: 30,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: ShapeDecoration(
                            color: Color(0xff1ED673),
                            shape: StadiumBorder(),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Disponible",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xff1ED673),
                                fontFamily: 'GoldplayRegular',
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
              )
            : GestureDetector(
                onTap: () {
                  accionSwitch(true);
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: prs.colorGrisAreaTexto,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: prs.colorRojo,
                      )),
                  width: 130,
                  height: 30,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Ocupado",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: prs.colorRojo,
                                fontFamily: 'GoldplayRegular',
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: ShapeDecoration(
                            color: prs.colorRojo,
                            shape: StadiumBorder(),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
  }
 actualizarCliente(int valor)async{
    await FirebaseFirestore.instance.collection("client").doc("client_"+_prefs.idCliente.toString()).update({'on_line':valor });
  }
  accionSwitch(bool state) async {
    if (state) {
      actualizarCliente(1);
    } else {
      actualizarCliente(0);
    }
    if (mounted)
      setState(() {
        switchs = state;
      });
  }

  static const String route = '/home';

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    Provider.of<MapProvider>(context, listen: false).initializeMap(
      scaffoldKey: scaffoldKey,
    );

    return Consumer<MapProvider>(
      builder: (BuildContext context, MapProvider mapProvider, _) {
        return Scaffold(
          drawer: mapProvider.mapAction == MapAction.tripAccepted ||
                  mapProvider.mapAction == MapAction.arrived ||
                  mapProvider.mapAction == MapAction.tripStarted ||
                  mapProvider.mapAction == MapAction.reachedDestination ||
                  mapProvider.cameraPos == null
              ? SizedBox()
              : MenuWidgetTaxis(),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            // shadowColor: Colors.black,
            centerTitle: mapProvider.mapAction == MapAction.tripAccepted ||
                    mapProvider.mapAction == MapAction.arrived ||
                    mapProvider.mapAction == MapAction.tripStarted ||
                    mapProvider.mapAction == MapAction.reachedDestination ? true : false,
            title: Text(
              "Solicitudes",
              textAlign: TextAlign.start,
              style: TextStyle(
                  color: Color(0xFF4B4B4E),
                  fontSize: 24,
                  fontFamily: 'GoldplayRegular',
                  fontWeight: FontWeight.w700),
            ),
            iconTheme: IconThemeData(
              color: prs.colorMorado,
            ),
            elevation: 0,
            leading: mapProvider.mapAction == MapAction.tripAccepted ||
                    mapProvider.mapAction == MapAction.arrived ||
                    mapProvider.mapAction == MapAction.tripStarted ||
                    mapProvider.mapAction == MapAction.reachedDestination ||
                    mapProvider.cameraPos == null
                ? SizedBox()
                : Builder(
                    builder: (context) => Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: Image(
                          image: AssetImage("assets/png/menu.png"),
                        ),
                      ),
                    ),
                  ),
            actions: [mapProvider.cameraPos == null ? SizedBox() : _rastrear(mapProvider)],
          ),
          key: scaffoldKey,
          body: SafeArea(
            child: Stack(
              children: [
                mapProvider.cameraPos != null
                    ? GoogleMap(
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        onMapCreated: mapProvider.onMapCreated,
                        initialCameraPosition: mapProvider.cameraPos,
                        compassEnabled: true,
                        onCameraMove: mapProvider.onCameraMove,
                        markers: mapProvider.markers,
                        polylines: mapProvider.polylines,
                        padding: const EdgeInsets.only(bottom: 120),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
                switchs == null ? SizedBox() :
                mapProvider.mapAction == MapAction.browse && switchs
                    ? BottomDraggableSheet()
                    : SizedBox(),
                HeadingToPassenger(key: widget.key),
                StartTrip(key: widget.key,mapProvider:mapProvider),
                DriverTripStarted(key: widget.key,mapProvider:mapProvider),
                CollectCash(key: widget.key),
              ],
            ),
          ),
        );
      },
    );
  }
}