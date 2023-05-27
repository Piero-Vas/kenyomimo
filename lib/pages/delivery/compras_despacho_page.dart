import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mimo/pagesTaxis/services/location_service.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../bloc/compras_despacho_bloc.dart';
import '../../card/chat_despacho_card.dart';
import '../../card/shimmer_card.dart';
import '../../model/cajero_model.dart';
import '../../model/chat_despacho_model.dart';
import '../../model/despacho_model.dart';
import '../../preference/push_provider.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/despacho_provider.dart';
import '../../utils/conexion.dart';
import '../../utils/conf.dart' as conf;
import '../../utils/dialog.dart' as dlg;
import '../../utils/permisos.dart' as permisos;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/rastreo.dart';
import '../../utils/utils.dart' as utils;
import '../../widgets/en_linea_widget.dart';
import '../../widgets/menu_widget.dart';
import 'calificaciondespacho_page.dart';
import 'despacho_page.dart';

//INIT MOTORIZADO
class ComprasDespachoPage extends StatefulWidget {
  @override
  _ComprasDespachoPageState createState() => _ComprasDespachoPageState();
}

class _ComprasDespachoPageState extends State<ComprasDespachoPage>
    with WidgetsBindingObserver {
  final ClienteProvider _clienteProvider = ClienteProvider();
  final ComprasDespachoBloc _comprasDespachoBloc = ComprasDespachoBloc();
  final DespachoProvider _despachoProvider = DespachoProvider();
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final PushProvider _pushProvider = PushProvider();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _saving = false;
  StreamController<bool> _cambios = StreamController<bool>.broadcast();

  void disposeStreams() {
    _cambios?.close();
    super.dispose();
  }

  bool _init = false;
  StreamSubscription<Position> _positionStream;
  Position posConductor = Position(longitude:-77.042485 , latitude:-12.049816 , timestamp: DateTime.now(), accuracy: 0.0, altitude: 0.0, heading: 0.0, speed: 0.0, speedAccuracy: 0.0);
  @override
  void initState() {
   _positionStream = LocationService().getRealtimeDeviceLocation().listen(
      (Position pos) {
      if(!mounted) return;
      posConductor = pos;
    });
    FirebaseFirestore.instance.collection("despacho").snapshots().listen((event) { 
       
      _comprasDespachoBloc.listarCompras(_selectedIndex, _dateTime.toString(),posConductor);
    });
      clienteOnLine();
    _cambios.stream.listen((internet) {
    
      if (!mounted) return;
      if (internet && _init) {
        _comprasDespachoBloc.listarCompras(_selectedIndex, _dateTime.toString(),posConductor);
      }
      _init = true;
    });
    WidgetsBinding.instance.addObserver(this);
    validateStatus();
    _comprasDespachoBloc.listarCompras(_selectedIndex, _dateTime.toString(), posConductor);
    super.initState();
    
    _clienteProvider.actualizarToken().then((isActualizo) {
      permisos.verificarSession(context);
    });
    
    if (_prefs.rastrear) Rastreo().start(context, isRadar: false);
  }

  DateTime fecha_desbaneo;
  bool isCancelado = false;
  validateStatus() async {
    PreferenciasUsuario _prefs = PreferenciasUsuario();
    await FirebaseFirestore.instance
        .collection("client")
        .doc("client_" + _prefs.idCliente.toString())
        .snapshots()
        .listen((DocumentSnapshot cliente) async {
      Map<String, dynamic> clienteMap = cliente.data();
      if (clienteMap['canceladas'] > 7) {
        int fecha_cancelado_mili = clienteMap['fecha_cancelado_mili'] ?? 0;
        int fecha_desbaneo_mili = fecha_cancelado_mili + 172800000;
        fecha_desbaneo = DateTime.fromMillisecondsSinceEpoch(fecha_desbaneo_mili);
        if (fecha_desbaneo_mili > DateTime.now().millisecondsSinceEpoch)
          isCancelado = true;
        else {
          await FirebaseFirestore.instance
              .collection("client")
              .doc("client_" + _prefs.idCliente.toString())
              .update({
            "fecha_cancelado_mili": null,
            "fecha_cancelado": null,
            "canceladas": 0
          });
          isCancelado = false;
        }
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionStream==null ? "" : _positionStream.cancel();
    _positionStream = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        permisos.verificarSession(context);
        if (_prefs.rastrear) Rastreo().start(context, isRadar: false);
        _comprasDespachoBloc.listarCompras(_selectedIndex, _dateTime.toString(), posConductor);
        //_pushProvider.cancelAll();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  String title = 'Solicitudes';

  

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
              
               _prefs.rastrear = true;
             }  else{
              
              _prefs.rastrear = false;
             }
          }});
  }

  Widget _rastrear() {
    return _prefs.rastrear
        ? Container(
            color: Colors.green,
            child: IconButton(
              icon: Icon(FontAwesomeIcons.peopleCarry,
                  size: 26.0, color: Colors.white),
              onPressed: () {
                accionSwitch(false);
              },
            ),
          )
        : Container(
            color: Colors.red,
            child: IconButton(
              icon: Icon(FontAwesomeIcons.bed, size: 26.0, color: Colors.white),
              onPressed: () {
                accionSwitch(true);
              },
            ),
          );
  }

  actualizarCliente(int valor)async{
    await FirebaseFirestore.instance.collection("client").doc("client_"+_prefs.idCliente.toString()).update({'on_line':valor });
  }

  accionSwitch(bool state) async {
    if (state) {
      _saving = true;
      if (mounted) setState(() {});
      await Rastreo().start(context);
      _comprasDespachoBloc.listarCompras(
        _selectedIndex, _dateTime.toString(),posConductor);
      actualizarCliente(1);
      _saving = false;
      if (mounted) setState(() {});
    } else {
      _saving = true;
      if (mounted) setState(() {});
      await Rastreo().stop();
      
     _comprasDespachoBloc.listarCompras(
        _selectedIndex, _dateTime.toString(),posConductor);
      actualizarCliente(0);
     
      _saving = false;
      if (mounted) setState(() {});
      
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_prefs.clienteModel.perfil == '0')
      return Container(child: Center(child: Text('Cliente no autorizado')));
    
    return Scaffold(
      key: _scaffoldKey,
      drawer: MenuWidget(),
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[_rastrear()],
      ),
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: utils.progressIndicator('Procesando...'),
        inAsyncCall: _saving,
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              EnLineaWidget(cambios: _cambios),
              _crearFecha(context),
              Expanded(child: isCancelado && _selectedIndex == 0 ? Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: MediaQuery.of(context).size.width * 0.25,
                    decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(
                                                  'assets/png/mimo.png',
                                                ),
                                                fit: BoxFit.cover)),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    child: Text("Te encuentras bloqueado hasta ${fecha_desbaneo.toString().substring(0,16)} por superar el limite de cancelados",textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24,fontFamily: 'GoldplayRegular', color: Color.fromARGB(221, 18, 17, 17),fontWeight: FontWeight.w600)),
                    padding: EdgeInsets.only(left: 25,right: 20),
                  ),
                ],
              )) : _listaCar(context))
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.peopleCarry), label: 'Solicitudes'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Historial'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: prs.colorButtonSecondary,
        onTap: _onItemTapped,
      ),
    );
  }

  int _selectedIndex = 0;
  DateTime _dateTime = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  void _onItemTapped(int index) {
    _dateTime = DateTime.now();
    _selectedIndex = index;
    if (index == 0)
      title = 'Solicitudes';
    else
      title = 'Historial';
    _onRefresh();
  }

  Widget _crearFecha(BuildContext context) {
    return Visibility(
      visible: _selectedIndex == 1,
      child: TableCalendar(
        calendarFormat: CalendarFormat.month,
        firstDay: DateTime.utc(2019, 1, 1),
        lastDay: DateTime.utc(2069, 1, 1),
        focusedDay: _focusedDay,
        calendarStyle: CalendarStyle(
                          isTodayHighlighted: true,
                          todayDecoration: BoxDecoration(
                              color: prs.colorAmarillo,
                              shape: BoxShape.circle),
                          selectedDecoration: BoxDecoration(
                              color: prs.colorAmarillo,
                              shape: BoxShape.circle),
                          selectedTextStyle: TextStyle(color: Colors.white)),
        locale: 'es',
        onDaySelected: (selectedDay, focusedDay) {
          _dateTime = selectedDay;
          _focusedDay = focusedDay;
          _onRefresh();
        },
      ),
    );
  }

  Widget _listaCar(context) {
    return StreamBuilder(
      stream: _comprasDespachoBloc.comprasStream,
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.hasData) {
          if ((snapshot.data.length > 0 && _prefs.rastrear && _selectedIndex == 0) || ( _selectedIndex == 1 && snapshot.data.length > 0 ) )
            return createListView(context, snapshot);
          return Container(
            // margin: EdgeInsets.all(60.0),
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Image(
                  width: double.infinity,
                  image: AssetImage(_prefs.rastrear || _selectedIndex == 1
                      ? 'assets/png/login.png'
                      : 'assets/screen/ofline.png'),
                  fit: BoxFit.cover),
            ),
          );
        } else {
          return ShimmerCard();
        }
      },
    );
  }

  Future _onRefresh() async {
    _saving = true;
    if (mounted) setState(() {});
    // await _comprasDespachoBloc.listarCompras(
     _comprasDespachoBloc.listarCompras(
        _selectedIndex, _dateTime.toString(),posConductor);
    _saving = false;
    if (mounted) setState(() {});
    return;
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    return RefreshIndicator(
      onRefresh: () => _comprasDespachoBloc.listarCompras(
          _selectedIndex, _dateTime.toString(),posConductor),
      child: ListView.builder(
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context, int index) {
          DespachoModel despachoModelList = snapshot.data[index];
          double distanceDispatch = calculateDistance([LatLng(despachoModelList.ltA, despachoModelList.lgA),LatLng(despachoModelList.ltB, despachoModelList.lgB)]);
          return ChatDespachoCard(
              despachoModel: despachoModelList,
              onTab: _onTab,
              enviarPostular: _enviarPostular,
              isChatDespacho: true,
              distanceDispatch: distanceDispatch);
        },
      ),
    );
  }

  double calculateDistance(List<LatLng> points) {
    double distance = 0;
    for (int i = 0; i < points.length - 1; i++) {
      distance += Geolocator.distanceBetween(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }
    distance = distance / 1000;
    return distance;
  }

  _onTab(DespachoModel despachoModel) async {
    if(despachoModel.idDespachoEstado==100){
      utils.mostrarSnackBar(context, "La compra fue cancelada",milliseconds: 2000000);
      return;
      }
    else if(despachoModel.idDespachoEstado==4){
      utils.mostrarSnackBar(context, "La compra fue entregada",milliseconds: 2000000);
      return;
    }
    else if (despachoModel.idDespachoEstado > 1) {
      _iraDespacho(despachoModel);
    } else {
      utils.mostrarSnackBar(context, 'Desliza para postular ->',
          milliseconds: 2000);
    }
  }

  _updateDispatch(int iddespacho)async {
    DocumentReference documentReferenceTemp =await FirebaseFirestore.instance.collection("despacho").doc("despacho_"+iddespacho.toString());
    Map agencyTemp = (await documentReferenceTemp.get()).data() as Map;

    if (agencyTemp['id_despacho_estado'] == 1) {
      Map<String, dynamic> data = {"id_despacho_estado":2,"id_conductor":int.parse(_prefs.idCliente.toString()) };
      await FirebaseFirestore.instance.collection('despacho').doc("despacho_"+iddespacho.toString()).update(data);
       return true;
    } else {
      return false;
    }
  }
    

  _enviarPostular(DespachoModel despachoModel) async {
    if (despachoModel.idDespachoEstado > 1) {
      _iraDespacho(despachoModel);
    } else {
      bool succes = await _updateDispatch(despachoModel.idDespacho);
    if(!succes) return;

      _saving = true;
        if (mounted) setState(() {});
        Rastreo().notificarUbicacion();
        await _despachoProvider.iniciar(despachoModel,
            (estado, error, DespachoModel despacho) {
          _saving = false;
          if (mounted) setState(() {});
          if (estado == 0) {
            // _comprasDespachoBloc.eliminar(despachoModel);
            return dlg.mostrar(context, error);
          }
          
          despachoModel = despacho;
          _comprasDespachoBloc.actualizarPorDespacho(despacho);
          _iraDespacho(despacho);
        });
    }
  }




  _iraDespacho(DespachoModel despacho) async {
     DocumentSnapshot documentReferenceBuy = await FirebaseFirestore.instance.collection("compra").doc("compra_"+ despacho.idDespacho.toString()).get();
    Map buyModel = documentReferenceBuy.data();
    if (despacho.calificarConductor == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CalificaciondespachoPage(despachoModel: despacho),
        ),
      );
    } else {

      CajeroModel _cajero = new CajeroModel(
          estado: 'Confirmado',
          idDespacho: despacho.idDespacho,
          nombres: despacho.nombres,
          detalle: despacho.detalleJson,
          referencia: despacho.referenciaJson,
          alias: buyModel['alias'],
          costo: despacho.costo,
          costoEnvio: despacho.costoEnvio,
          sucursal: despacho.sucursalJson);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DespachoPage(conf.TIPO_CONDCUTOR,
              cajeroModel: _cajero, despachoModel: despacho),
        ),
      );
    }
    _saving = false;
  }
}