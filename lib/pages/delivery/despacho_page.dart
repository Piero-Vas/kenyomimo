import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_touch_spin/flutter_touch_spin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mimo/Core/Repository/mapRepository.dart';
import 'package:mimo/pages/delivery/catalogo_page.dart';
import 'package:mimo/pages/delivery/detalles_pedido_page.dart';
import 'package:mimo/pages/planck/ayuda_page.dart';
import 'package:mimo/pagesTaxis/services/location_service.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:share/share.dart';
import 'package:slider_button/slider_button.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:mimo/Core/Utils/Utils.dart';
import '../../utils/button.dart' as btn;
import '../../bloc/cajero_bloc.dart';
import '../../bloc/compras_despacho_bloc.dart';
import '../../model/cajero_model.dart';
import '../../model/chat_compra_model.dart';
import '../../model/chat_despacho_model.dart';
import '../../model/cliente_model.dart';
import '../../model/despacho_model.dart';
import '../../preference/push_provider.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cajero_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/despacho_provider.dart';
import '../../sistema.dart';
import '../../utils/cache.dart' as cache;
import '../../utils/conexion.dart';
import '../../utils/conf.dart' as conf;
import '../../utils/decode.dart' as decode;
import '../../utils/dialog.dart' as dlg;
import '../../utils/marker.dart' as marker;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/rastreo.dart';
import '../../utils/utils.dart' as utils;
import '../../widgets/icon_aument_widget.dart';
import 'calificacioncompra_page.dart';
import 'calificaciondespacho_page.dart';
import 'chat_despacho_page.dart';
import 'compras_despacho_page.dart';
import 'package:flutter/services.dart' show rootBundle;
class DespachoPage extends StatefulWidget {
  final DespachoModel despachoModel;
  final CajeroModel cajeroModel;
  final int tipo;

  DespachoPage(this.tipo, {Key key, this.despachoModel, this.cajeroModel})
      : super(key: key);

  @override
  State<DespachoPage> createState() => DespachoPageState(tipo,
      despachoModel: despachoModel, cajeroModel: cajeroModel);
}

class DespachoPageState extends State<DespachoPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  DespachoModel despachoModel;
  CajeroModel cajeroModel;
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final DespachoProvider _despachoProvider = DespachoProvider();
  final PushProvider _pushProvider = PushProvider();
  final _clienteProvider = ClienteProvider();
  final navigatorKey = GlobalKey<NavigatorState>();
  final _cajeroProvider = CajeroProvider();
  final ComprasDespachoBloc _comprasDespachoBloc = ComprasDespachoBloc();
  String preparandose = '15';
  final int tipoNotificacionPreparacion = 1;
  final int tipoNotificacionFuera = 2;

  DespachoPageState(this.tipo, {this.despachoModel, this.cajeroModel});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _rastrear = true;
  bool _saving = false;
  String _mensajeProgreso = 'Cargando...';
  final int tipo;

  Completer<GoogleMapController> _controller = Completer();

  double _zoom = 18.0, lt = 0.0, lg = 0.0;

  CameraPosition _cameraPosition;

  final Set<Marker> _markers = Set<Marker>();

  Marker markerPool =
      Marker(position: LatLng(0.0, 0.0), markerId: MarkerId('POOL'));

  Marker markerDesde =
      Marker(position: LatLng(0.0, 0.0), markerId: MarkerId('DESDE'));

  Marker markerHasta =
      Marker(position: LatLng(0.0, 0.0), markerId: MarkerId('HASTA'));

  bool _cargando = true;
  bool succes;
  Set<Polyline> _polyline = {};
  //final Conexion _conexion = Conexion();
  final CajeroBloc _cajeroBloc = CajeroBloc();
  StreamSubscription<Position> _positionStream;

    

    _updateDispatch2(int iddespacho)async {
    DocumentReference documentReferenceTemp =await FirebaseFirestore.instance.collection("despacho").doc("despacho_"+iddespacho.toString());
    Map agencyTemp = (await documentReferenceTemp.get()).data() as Map;

    if (agencyTemp['id_conductor'] == int.parse(_prefs.idCliente.toString()) ) {
      Map<String, dynamic> data = {"id_conductor":int.parse(_prefs.idCliente.toString()) };
      await FirebaseFirestore.instance.collection('despacho').doc("despacho_"+iddespacho.toString()).update(data);
       return true;
    } else {
      return false;
    }
  }

  validacion()async{
    succes = await _updateDispatch2(despachoModel.idDespacho);
    if(!succes) {
      return Navigator.pushNamedAndRemoveUntil(context, 'compras_despacho', (route) => false);
    };
  }

  @override
  void initState() {
    validacion();
    
    
    WidgetsBinding.instance.addObserver(this);
    //Descartamos pues el despacho viene con todos los datos cuando es desde el despachador
    _cameraPosition = CameraPosition(
        target: LatLng(double.parse(despachoModel.ltA.toString()),
            double.parse(despachoModel.lgA.toString())),
        zoom: 18.0);
    //_conexion.stream.listen(_rastrearVehiculo);
    _markers.add(markerPool);
    _initUbicar();
    super.initState();
    _pushProvider.chatsCompra.listen((ChatCompraModel chatCompra) {
      
      if (!mounted) return;
      if (cajeroModel.idCompra == chatCompra.idCompra) {
        if (chatCompra.idCompraEstado == conf.COMPRA_CANCELADA) {
          cajeroModel.idCompraEstado = chatCompra.idCompraEstado;
          cajeroModel.calificarCliente = 1;
          cajeroModel.calificarCajero = 1;
          _cajeroBloc.actualizarPorCajero(cajeroModel);
          _irAcalificar();
        }
      }
    });

    _pushProvider.chatsDespacho.listen((ChatDespachoModel chatDespacho) {
      
      if (!mounted) return;
      if (despachoModel.idDespacho.toString() != chatDespacho.idDespacho.toString()) return;
      despachoModel.sinLeerCliente += 1;
      despachoModel.sinLeerConductor += 1;
      if (chatDespacho.idDespachoEstado == conf.DESPACHO_ENTREGADO) {
       
        despachoModel.idDespachoEstado = conf.DESPACHO_ENTREGADO;
        cajeroModel.idCompraEstado = conf.COMPRA_ENTREGADA;
        cajeroModel.calificarCliente = 1;
        _cajeroBloc.actualizarPorCajero(cajeroModel);
        _irAcalificar();
      } else if (chatDespacho.idDespachoEstado == conf.DESPACHO_CANCELADA) {
       
       despachoModel.idDespachoEstado = conf.DESPACHO_CANCELADA;
        cajeroModel.idCompraEstado = conf.COMPRA_CANCELADA;
        _irAcalificar();
      } else if (despachoModel.idDespachoEstado !=
          chatDespacho.idDespachoEstado) {
        
        _ver();
      } 
      despachoModel.idDespachoEstado = chatDespacho.idDespachoEstado;
      if (mounted) setState(() {});
    });

    _pushProvider.objects.listen((despacho) {
      
      if (!mounted) return;
      DespachoModel _despacho = despacho;
      
      if (cajeroModel.idCompra.toString() == _despacho.idCompra.toString()) {
        despachoModel = despacho;
        cajeroModel.idDespacho = despachoModel.idDespacho;
        _cajeroBloc.actualizarPorDespacho(despacho, conf.COMPRA_DESPACHADA);
        _cargando = false;
        if (mounted) setState(() {});
        _ver();
      }
    });
    _ver();
    _cargarPosition();
  }

  



StreamSubscription<Map<String,dynamic>> _driverStream;
  _cargarPosition(){
    
    if(tipo==conf.TIPO_CONDCUTOR)
    _positionStream = LocationService().getRealtimeDeviceLocation().listen(
      (Position pos) {
      
      _clienteProvider.updateUser({
      'id': _prefs.clienteModel.idCliente,
      'username': _prefs.clienteModel.nombres,
      'email': _prefs.clienteModel.correo,
      'userType': "driver",
      'heading': pos.heading,
      'userLatitude': pos.latitude,
      'userLongitude': pos.longitude,
      });

      Map data = {
        "lt": pos.latitude,
        "lg": pos.longitude
      };
      _rastrearVehiculo(data);
      
    });
    
  }

  _escucharRastreo(dynamic idRastreo) async {
    if (tipo == conf.TIPO_CONDCUTOR) return;
    
    if (despachoModel.idDespachoEstado <= conf.DESPACHO_RECOGIDO) {
      if (idRastreo != null) {
        
        _driverStream = _clienteProvider.escuchar(idRastreo.toString()).listen(
        (Map<String,dynamic> driver) async {
          if (!mounted) return;
          
          Map data = {
          "lt": driver['userLatitude'],
          "lg": driver['userLongitude']
          };
          _rastrearVehiculo(data);
          
        }
      );
    }
    } else {
      //Nos desuscribimos
      _driverStream==null ? "" : _driverStream.cancel();
      _driverStream = null;
    }
  }

  _ver() async {
    DespachoModel despacho;
    despacho = await _despachoProvider.ver(cajeroModel.idDespacho, tipo);
    if (tipo != conf.TIPO_CONDCUTOR) cajeroModel = await _cajeroProvider.ver(despacho.idCompra);
    if (despacho == null) return;
    despachoModel = despacho;
    _escucharRastreo(despachoModel.idConductor);
    _cargando = false;
    //_ubiarVehiculo(despachoModel.lt, despachoModel.lg);
    _initUbicar();
    _irAcalificar();
  }

  _irAcalificar() {
    if (tipo == conf.TIPO_CONDCUTOR) {
      if (despachoModel.calificarConductor == 1 ||
          ((despachoModel.idDespachoEstado == conf.DESPACHO_ENTREGADO ||
                  despachoModel.idDespachoEstado == conf.DESPACHO_CANCELADA) &&
              despachoModel.calificarConductor <= 1)) {
        return _naverACalificar();
      }
    } else if (tipo == conf.TIPO_CLIENTE) {
      if (cajeroModel.calificarCliente == 1 ||
          ((cajeroModel.idCompraEstado == conf.COMPRA_CANCELADA ||
                  cajeroModel.idCompraEstado == conf.COMPRA_ENTREGADA) &&
              cajeroModel.calificarCliente <= 1)) {
        return _naverACalificar();
      }
    } else if (tipo == conf.TIPO_ASESOR) {
      if (cajeroModel.calificarCajero == 1 ||
          ((cajeroModel.idCompraEstado == conf.COMPRA_CANCELADA ||
                  cajeroModel.idCompraEstado == conf.COMPRA_ENTREGADA) &&
              cajeroModel.calificarCajero <= 1)) {
        return _naverACalificar();
      }
    }
  }

  _naverACalificar() {
    if (tipo == conf.TIPO_CONDCUTOR) {
      // Navigator.of(context).pushAndRemoveUntil(
      //     MaterialPageRoute(
      //         builder: (context) =>
      //             CalificaciondespachoPage(despachoModel: despachoModel)),
      //     (Route<dynamic> route) {
      //   return route.isFirst;
      // });
    } else {
      
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) =>
                  CalificacioncompraPage(cajeroModel: cajeroModel, tipo: tipo,)),
          (Route<dynamic> route) {
        return route.isFirst;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionStream==null ? "" : _positionStream.cancel();
    _positionStream = null;
    _driverStream==null ? "" : _driverStream.cancel();
    _driverStream = null;
    super.dispose();
    //  _comprasDespachoBloc.listarCompras(0, 'hola Jaimito');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _ver();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  void _cancelar() async {
     DocumentSnapshot<Map<String, dynamic>> cliente  = await FirebaseFirestore.instance
        .collection("client")
        .doc("client_"+_prefs.idCliente.toString())
        .get();
      Map<String, dynamic> clienteMap = cliente.data();
      
    
    showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              title: Text('CANCELAR COMPRA'),
              content: SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(
                child: Text('¿Seguro deseas cancelar la compra?',
                        style: TextStyle(fontSize: 16)),
              ),
              despachoModel.idConductor != null ?Center(
                child: Text('Tiene '+clienteMap['canceladas'].toString()+' de 10 canceladas, será baneado durante 2 días si excede el limite',
                        style: TextStyle(fontSize: 13)),
              ):SizedBox(),
                    ],
                  )),
              actions: <Widget>[
                TextButton(
                  child: Text('NO, REGRESAR'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: prs.colorButtonSecondary,
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0))),
                  label: Text('SI, CANCELAR'),
                  icon: Icon(Icons.cancel, size: 18.0),
                  onPressed: () {
                    _enviarCancelar(clienteMap['canceladas']);
                  },
                ),
              ],
            );
          },
        );
        
     
  }
  
  Future _updateClient(int cancelados)async {
    DateTime now = DateTime.now();
    DocumentReference documentReferenceTemp =await FirebaseFirestore.instance.collection("client").doc("client_"+_prefs.idCliente.toString());
    Map agencyTemp = (await documentReferenceTemp.get()).data() as Map;
    Map<String, dynamic> data = cancelados == 9 ? {"canceladas":agencyTemp['canceladas']+1, 'fecha_cancelado': now.toString(), 'fecha_cancelado_mili':now.millisecondsSinceEpoch} :{"canceladas":agencyTemp['canceladas']+1 };
    await FirebaseFirestore.instance.collection('client').doc("client_"+_prefs.idCliente.toString()).update(data);
  }

  Future _updateDispatch(int iddespacho)async {
    DocumentReference documentReferenceTemp =await FirebaseFirestore.instance.collection("despacho").doc("despacho_"+iddespacho.toString());
    Map agencyTemp = (await documentReferenceTemp.get()).data() as Map;

    if (agencyTemp['id_despacho_estado'] == 1) {
      Map<String, dynamic> data = {"id_despacho_estado":100};
      await FirebaseFirestore.instance.collection('despacho').doc("despacho_"+iddespacho.toString()).update(data);
       return true;
    } else {
      return false;
    }
  
    
  }

  void _enviarCancelar(int cancelados) async {
    bool succes = tipo == conf.TIPO_CLIENTE ? await _updateDispatch(despachoModel.idDespacho) : true;
    if(!succes) return;
     despachoModel.idConductor != null ? _updateClient(cancelados) : '';
    Navigator.pop(context);
    _saving = true;
    if (mounted) setState(() {});
    int _chatEnvia = conf.CHAT_ENVIA_CAJERO;
    var route = CatalogoPage();
    if (tipo == conf.TIPO_CLIENTE) {
      
      _chatEnvia = conf.CHAT_ENVIA_CLIENTE;
      cajeroModel.idCompraEstado = conf.COMPRA_CANCELADA;
      //route = CalificacioncompraPage(cajeroModel: cajeroModel, tipo: tipo);
      CajeroModel cajero = await _cajeroProvider.cancelar(
          cajeroModel, cajeroModel.idCliente, cajeroModel.idCajero, _chatEnvia);
      if (cajero.typePayment > 3) await refuseCharge(cajero.chargeId);
      cajeroModel = cajero;
      cajeroModel.calificarCajero = 1;
    } else {
      
      despachoModel.idDespachoEstado = conf.DESPACHO_CANCELADA;
      // route = CalificaciondespachoPage(despachoModel: despachoModel);
      // _comprasDespachoBloc.actualizarPorDespacho(despachoModel);
      await _despachoProvider.cancelar(despachoModel, despachoModel.idCliente,
          despachoModel.idConductor, tipo);
    }
    _saving = false;
    // Navigator.push(context, MaterialPageRoute(builder: (context) => route));
    
    if (_prefs.clienteModel.perfil.toString() == '2') {
      //  _comprasDespachoBloc.listarCompras(0, 'hola Jaimito');
      Navigator.pushNamed(context, 'compras_despacho');
    } else {
      Navigator.pushNamed(context, 'catalogo2');
    }
  }

  //String get _merchantBaseUrl => 'https://api.openpay.pe/v1/m0qhimwy1aullokkujfg';
  // final String apiKeyPublic = "pk_20261e9590c24c1995bd82c30959d12b";
  // final String apiKeyPrivate = "sk_da8b8e48791540958a47dae3488abfa9";
  String get _merchantBaseUrl =>
      'https://sandbox-api.openpay.pe/v1/mkq9aic4rs51cybtcdut';
  final String apiKeyPublic = "pk_92bef45248c34ce7a41d59ca30ab72c1";
  final String apiKeyPrivate = "sk_41d63faafb4c413581fbf776030771da";

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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              
              if (_prefs.clienteModel.perfil.toString() == '2') {
                Navigator.pushNamed(context, 'compras_despacho');
              } else {
                Navigator.pushNamed(context, 'catalogo2');
              }
            },
          ),
          title: Text(
            '${despachoModel.estado}',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            _prefs.clienteModel.perfil == '2'?
            IconButton(
                    icon: Icon(FontAwesomeIcons.phone, size: 26.0),
                    onPressed: _llamar,
                  ):SizedBox()
          ],
          // actions: <Widget>[
          //   _prefs.clienteModel.perfil == '2'?
          //   tipo != conf.TIPO_ASESOR &&
          //           despachoModel.idDespachoEstado > 0 &&
          //           despachoModel.idDespachoEstado <= conf.DESPACHO_ASIGNADO &&
          //           despachoModel.preparandose <= 0
          //       ? IconButton(
          //           icon: Icon(FontAwesomeIcons.xmark, size: 26.0),
          //           onPressed: _cancelar,
          //         )
          //       : Container():tipo != conf.TIPO_ASESOR &&
          //           despachoModel.idDespachoEstado > 0 &&
          //           despachoModel.idDespachoEstado == 1 &&
          //           despachoModel.preparandose <= 0
          //       ? IconButton(
          //           icon: Icon(FontAwesomeIcons.xmark, size: 26.0),
          //           onPressed: _cancelar,
          //         )
          //       : Container()
            // (tipo == conf.TIPO_ASESOR)
            //     ? IconButton(
            //         icon: Icon(FontAwesomeIcons.shareAlt, size: 26.0),
            //         onPressed: _irRutaGoogleMaps,
            //       )
            //     : Container(),
            // tipo == conf.TIPO_CONDCUTOR &&
            //         despachoModel.idDespachoEstado == conf.DESPACHO_ASIGNADO
            //     ? ElevatedButton.icon(
            //         style: ElevatedButton.styleFrom(
            //             primary: Colors.white10, onPrimary: Colors.white),
            //         label: Text('P.  RECOGIDA'),
            //         icon: cache.fadeImage('assets/pool/ingreso_0.png',
            //             height: 40.0),
            //         onPressed: _irPuntoRecogida,
            //       )
            //     : Container(),
            // tipo == conf.TIPO_CONDCUTOR &&
            //         despachoModel.idDespachoEstado == conf.DESPACHO_RECOGIDO
            //     ? ElevatedButton.icon(
            //         style: ElevatedButton.styleFrom(
            //             primary: Colors.white10, onPrimary: Colors.white),
            //         label: Text('P.  ENTREGA'),
            //         icon:
            //             cache.fadeImage('assets/pool/salida_0.png', height: 40.0),
            //         onPressed: _irPuntoEntrega,
            //       )
            //     : Container(),
            // tipo == conf.TIPO_CONDCUTOR &&
            //         despachoModel.idDespachoEstado == conf.DESPACHO_ENTREGADO
            //     ? ElevatedButton.icon(
            //         style: ElevatedButton.styleFrom(
            //             primary: Colors.white10, onPrimary: Colors.white),
            //         label: Text('REVERSAR'),
            //         icon: Icon(Icons.undo_sharp, size: 32.0),
            //         onPressed: _reversar,
            //       )
            //     : Container(),
          // ],
        ),
        body: SafeArea(
          child: ModalProgressHUD(
            color: Colors.black,
            opacity: 0.4,
            progressIndicator: utils.progressIndicator(_mensajeProgreso),
            inAsyncCall: _saving,
            child: _contenido(),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: GestureDetector(
          onVerticalDragEnd: _onVerticalDragEnd,
          onVerticalDragUpdate: _onVerticalDragUpdate,
          child: _avatar(),
        ),
        bottomSheet: SolidBottomSheet(
          canUserSwipe: true,
          autoSwiped: true,
          draggableBody: true,
          showOnAppear: _estadoAvatar,
          controller: _solidController,
          onShow: () {
            _estadoAvatar = true;
          },
          onHide: () {
            _estadoAvatar = false;
          },
          maxHeight: 500.0,
          minHeight: 100.0,
          headerBar: _floatingActionButtonPool(),
          body: _contenidoPool(),
        ),
      ),
    );
  }

  _reversar() {
    dlg.mostrar(context,
        'Esta acción conlleva una sanción económica.\n\nPermitiendo obtener los datos del cliente al regresar el despacho al estado recogido.',
        mBotonDerecha: 'REVERSAR',
        mIzquierda: ' CANCELAR ',
        fIzquierda: _cancelarReversar,
        icon: Icons.undo_sharp,
        fBotonIDerecha: _confirarReversar);
  }

  _confirarReversar() async {
    Navigator.pop(context);
    _saving = true;
    if (mounted) setState(() {});
    despachoModel = await _despachoProvider.reversar(despachoModel);
    _saving = false;
    if (mounted) setState(() {});
  }

  _cancelarReversar() {
    Navigator.pop(context);
  }

  void _onVerticalDragUpdate(data) {
    if (((_solidController.height - data.delta.dy) > 0) &&
        ((_solidController.height - data.delta.dy) < 135)) {
      _solidController.height -= data.delta.dy;
    }
  }

  void _onVerticalDragEnd(data) {
    _solidController.isOpened
        ? _solidController.hide()
        : _solidController.show();
  }

  Widget _floatingActionButtonPool() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        color: prs.colorIcons,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          // Expanded(child: _botonChat()),
          Expanded(
              child: Container(
            height: 30,
          )),
          // Spacer(flex: 1),
          // Expanded(child: _botonLlamar())
        ],
      ),
    );
  }

  Widget _botonChat() {
    if (despachoModel.idConductor == null ||
        despachoModel.idDespacho <= 0 ||
        despachoModel.idDespachoEstado >= conf.DESPACHO_ENTREGADO ||
        tipo == conf.TIPO_ASESOR) return Container(height: 40.0);

    int sinLeer =
        despachoModel.idConductor.toString() == _prefs.idCliente.toString()
            ? despachoModel.sinLeerConductor
            : despachoModel.sinLeerCliente;

    Widget _sinLeer = badges.Badge(
      position: badges.BadgePosition.topEnd(end: 1),
      badgeColor: Colors.red,
      badgeContent: Text('$sinLeer', style: TextStyle(color: Colors.white)),
      child: IconButton(icon: prs.iconoChatActivo, onPressed: null),
    );

    return RawMaterialButton(
      onPressed: () {
        _chat(despachoModel, null);
      },
      child: (sinLeer > 0 ? _sinLeer : prs.iconoChat),
      shape: CircleBorder(),
      fillColor: prs.colorButtonBackground,
    );
  }

  Widget _botonLlamar() {
    if (tipo == conf.TIPO_CLIENTE ||
        despachoModel.idDespachoEstado >= conf.DESPACHO_ENTREGADO)
      return Container();

    if (despachoModel.correctos > 0)
      return RawMaterialButton(
        onPressed: _llamar,
        child: prs.iconoLlamar,
        shape: CircleBorder(),
        fillColor: prs.colorButtonBackground,
      );

    return RawMaterialButton(
      onPressed: _llamar,
      shape: CircleBorder(),
      child: IconAumentWidget(
        Icon(FontAwesomeIcons.phoneSlash, size: 40.0, color: Colors.red),
        size: 40.0,
      ),
      fillColor: prs.colorButtonBackground,
    );
  }

  _llamar() async {
    String _call = 'tel:${despachoModel.celular}';
    final Uri _url = Uri.parse(_call);
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication))
      throw 'Could not launch $_url';
  }

  bool _estadoAvatar = true;
  final SolidController _solidController = new SolidController();
  var tipodepago = '';  
  var agenciaImagen = '';
  imagenAgencia()async{
    try {
      await FirebaseFirestore.instance.collection("compra").where("id_compra",isEqualTo:int.parse(despachoModel.idCompra.toString())  )
      .get().then((agency){
        if(agency.size>0){
          
          agency.docs.forEach((address) async{
            
            Map addressMap = address.data();
            Map<String, dynamic> datosAgencia = (await FirebaseFirestore.instance.collection("agency").doc("agency_"+addressMap['id_sucursal'].toString()).get()).data();
            agenciaImagen = datosAgencia['img'];
           });
        }
      });
    } catch (err) {
      print('error img agenci: $err');
    } 
  }
  Widget _contenidoPool() {
    imagenAgencia();
    // var comentarioPedido = cajeroModel.detalle.split('/ ')[3] ?? '';
    var productoPedido = cajeroModel.detalle;
    // var cantidadProductos = cajeroModel.detalle.split('/ ')[0] ?? '';
    if(despachoModel.typePayment == 1 ){
      tipodepago = 'Efectivo';
    }else if(despachoModel.typePayment == 2 ){
      tipodepago = 'Yape';
    }else if(despachoModel.typePayment == 3 ){
      tipodepago = 'Plin';
    }else if(despachoModel.typePayment == 4 ){
      tipodepago = 'Tarjeta';
    }
    
    return Container(
      color: Colors.white30,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // SizedBox(
            //   height: 40,
            // ),
            // Container(
            //     width: double.infinity,
            //     child: Text(
            //       '${despachoModel.label}',
            //       style: TextStyle(fontSize: 27, fontFamily: 'GoldplayBlack'),
            //       textAlign: TextAlign.center,
            //     )),
            // SizedBox(
            //   height: 15,
            // ),
            // Container(
            //   padding: EdgeInsets.all(15),
            //   decoration: BoxDecoration(
            //       border: Border.all(color: prs.colorGrisBordes),
            //       borderRadius: BorderRadius.circular(20)),
            //   child: Row(
            //     children: [
            //       _avatarInfo(),
            //       SizedBox(
            //         width: 10,
            //       ),
            //       Column(
            //         mainAxisAlignment: MainAxisAlignment.start,
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text('${despachoModel.label}'),
            //           _prefs.clienteModel.perfil.toString() == '2'
            //               ? Text('Encargado del pedido')
            //               : Text('Encargado de la entrega'),
            //         ],
            //       ),
            //       Expanded(child: Container()),
            //       // _botonChat()
            //     ],
            //   ),
            // ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(child: 
                Text('${despachoModel.estado}',textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 22, fontFamily: 'GoldplayBlack',),))
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                       
                      (despachoModel.idDespachoEstado > 0 && despachoModel.idDespachoEstado != 100) ?
                      Image(image: AssetImage('assets/png/lapiz.png'),width: 40, height: 40,)
                      :Image(image: AssetImage('assets/png/lapiz2.png'),width: 40, height: 40,),
                      Expanded(child:Divider(thickness: 1,height: 1,color: Colors.red,),),
                      (despachoModel.idDespachoEstado > 1 && despachoModel.idDespachoEstado != 100) ?
                      Image(image: AssetImage('assets/png/cocina.png'),width: 40, height: 40,)
                      :Image(image: AssetImage('assets/png/cocina2.png'),width: 40, height: 40,),
                      Expanded(child:Divider(thickness: 1,height: 1,color: Colors.red,),),
                      (despachoModel.idDespachoEstado > 2 && despachoModel.idDespachoEstado != 100) ?
                      Image(image: AssetImage('assets/png/repartidor.png'),width: 40, height: 40,)
                      :Image(image: AssetImage('assets/png/repartidor2.png'),width: 40, height: 40,),
                      Expanded(child:Divider(thickness: 1,height: 1,color: Colors.red,),),
                      (despachoModel.idDespachoEstado > 3 && despachoModel.idDespachoEstado != 100) ?
                      Image(image: AssetImage('assets/png/destino.png'),width: 40, height: 40,)
                      :Image(image: AssetImage('assets/png/destino2.png'),width: 40, height: 40,),
                   
                    ],
                  ),
                )
                
                
              ],
            ),
            SizedBox(
              height: 25,
            ),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: prs.colorGrisBordes)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,

                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.red,image: DecorationImage(fit: BoxFit.cover, image: NetworkImage(agenciaImagen ?? 'https://firebasestorage.googleapis.com/v0/b/mimo-3ef92.appspot.com/o/default-image.png?alt=media&token=9b400614-9d8a-4fc4-8919-4fa59cedc8cd'))),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        child: FittedBox(
                          child: Text(
                            '${cajeroModel.sucursal}'.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, fontFamily: 'GoldplayRegular', fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      _botonChat()
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: prs.colorGrisBordes)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${cajeroModel.sucursal}'.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 17, fontFamily: 'GoldplayRegular', fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),SizedBox(height: 5,),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Text('${productoPedido}',
                        textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16, fontFamily: 'GoldplayRegular', fontWeight: FontWeight.w600),),
                      ),
                      // SizedBox(width: 10,),
                      // Text('S/.${despachoModel.efectivoProdcuto()?? ''}',style: TextStyle(
                      //         fontSize: 16, fontFamily: 'GoldplayRegular'),)
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Tarifa de Envio :',
                            style: TextStyle(
                              fontSize: 16, fontFamily: 'GoldplayRegular', fontWeight: FontWeight.w600),),
                      ),
                      SizedBox(width: 10,),
                      Text('S/.${despachoModel.efectivoEnvio() ?? ''}',style: TextStyle(
                              fontSize: 16, fontFamily: 'GoldplayRegular'))
                    ],
                  ),SizedBox(height: 5,),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Propina (Entrega directa):',
                            style: TextStyle(
                              fontSize: 16, fontFamily: 'GoldplayRegular', fontWeight: FontWeight.w600),),
                      ),
                      SizedBox(width: 10,),
                      Text('S/.${despachoModel.propina ?? ''}',style: TextStyle(
                              fontSize: 16, fontFamily: 'GoldplayRegular'))
                    ],
                  ),SizedBox(height: 5,),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     Text('Comentario :',
                  //         style: TextStyle(
                  //             fontSize: 16, fontFamily: 'GoldplayRegular', fontWeight: FontWeight.w600)),
                  //     SizedBox(width: 10,),
                  //     Expanded(child: Text('${comentarioPedido}',textAlign: TextAlign.end, style: TextStyle(
                  //             fontSize: 16, fontFamily: 'GoldplayRegular')))
                  //   ],
                  // ),SizedBox(height: 5,),
                  Divider(thickness: 1,height: 1,color: Colors.red,),SizedBox(height: 5,),
                  Row(
                    children: [
                      Expanded(
                        child: Text('TOTAL',style: TextStyle(
                              fontSize: 16, fontFamily: 'GoldplayRegular', fontWeight: FontWeight.w600)),
                      ),
                      SizedBox(width: 10,),
                      Text('S/.${despachoModel.efectivoTotal()}',style: TextStyle(
                              fontSize: 16, fontFamily: 'GoldplayBlack', color: Colors.black))
                    ],
                  ),
                  // Text('${cajeroModel.sucursal}'),
                  // Text('${cajeroModel.detalle.split('/')[1]}'),
                  // Text('${cajeroModel.detalle.split('/')[0].split('Detalle:')[1]}'),
                  // Text('${cajeroModel.detalle.split('/')[2]}'),
                  // Text('${cajeroModel.detalle.split('/')[3]}'),

                  // Text('${despachoModel.efectivoTotal()}'),
                  // Text('${despachoModel.efectivoProdcuto()}'),
                  // Text('${despachoModel.efectivoEnvio()}'),
                  //      Text('${despachoModel.typePayment}'),
                  //       Text('${cajeroModel.propina}'),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: prs.colorGrisBordes)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Detalle del pedido',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontFamily: 'GoldplayRegular', fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),SizedBox(height: 5,),
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('Dirección :',style: TextStyle(
                              fontSize: 16, fontFamily: 'GoldplayRegular', fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10,),
                       Expanded(
                         child: Text('${cajeroModel.alias}',
                         textAlign: TextAlign.end,style: TextStyle(
                              fontSize: 16, fontFamily: 'GoldplayRegular')),
                       ),
                    ],
                  ),SizedBox(height: 5,),
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('Referencia:',style: TextStyle(
                              fontSize: 16, fontFamily: 'GoldplayRegular', fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10,),
                       Expanded(
                         child: Text('${cajeroModel.referencia}',
                         textAlign: TextAlign.end,style: TextStyle(
                              fontSize: 16, fontFamily: 'GoldplayRegular')),
                       ),
                    ],
                  ),SizedBox(height: 5,),
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Row(
                          children: [
                            Expanded(
                              child:  _prefs.clienteModel.perfil.toString() == '2' ?Text('Nombre Cliente:',
                              style: TextStyle(
                              fontSize: 16, fontFamily: 'GoldplayRegular', fontWeight: FontWeight.w600)):
                              Text('Nombre Repartidor:',
                              style: TextStyle(
                              fontSize: 16, fontFamily: 'GoldplayRegular', fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10,),
                       Expanded(
                         child: Text('${despachoModel.label}',textAlign: TextAlign.end ,style: TextStyle(
                              fontSize: 16, fontFamily: 'GoldplayRegular')),
                       ),
                    ],
                  ),SizedBox(height: 5,),
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('Método de entrega :',style: TextStyle(
                              fontSize: 16, fontFamily: 'GoldplayRegular', fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10,),
                       Expanded(
                         child: Text('Entregar el pedido en la puerta',
                         textAlign: TextAlign.end,style: TextStyle(
                              fontSize: 16, fontFamily: 'GoldplayRegular')),
                       ),
                    ],
                  ),SizedBox(height: 5,),
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('Método de pago :',style: TextStyle(
                              fontSize: 16, fontFamily: 'GoldplayRegular', fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10,),
                       Expanded(
                         child: Text('${tipodepago}',
                         textAlign: TextAlign.end,style: TextStyle(
                              fontSize: 16, fontFamily: 'GoldplayRegular')),
                       ),
                    ],
                  ),
                ],
              ),
            ),
            _prefs.clienteModel.perfil == '2'?
            (tipo != conf.TIPO_ASESOR &&
                    despachoModel.idDespachoEstado > 0 &&
                    despachoModel.idDespachoEstado <= conf.DESPACHO_ASIGNADO &&
                    despachoModel.preparandose <= 0) 
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    btn.bootonContinuar('Cancelar', _cancelar),
                    SizedBox(width: 10,),
                    despachoModel.idDespachoEstado == conf.DESPACHO_ASIGNADO ?
                    btn.bootonContinuar('Recogido', _confirmarRecogidaDesdeConductor): 
                     Container() ,
                  ],
                )
                : Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        padding: EdgeInsets.all(10.0),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: prs.colorBotones,
                                onPrimary: Colors.white,
                                elevation: 1.0,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: prs.colorBotones, //Bordes
                                        width: 1.0,
                                        style: BorderStyle.solid),
                                    borderRadius: BorderRadius.circular(50.0))),
                            child: Container(
                              margin: EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.headset_mic_outlined,
                                      color: Colors.white),
                                  SizedBox(width: 10),
                                  Text(
                                    'Ayuda',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'GoldplayRegular',
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AyudaPage(),
                                ),
                              );
                            }),
                      ),
                    SizedBox(width: 10,),
                     btn.bootonContinuar('Entregado', _confirmarEntrega)
                  ],
                ):(tipo != conf.TIPO_ASESOR &&
                    despachoModel.idDespachoEstado > 0 &&
                    despachoModel.idDespachoEstado == 1 &&
                    despachoModel.preparandose <= 0) 
                ? btn.bootonContinuar('Cancelar', _cancelar)
                : Container(
                    padding: EdgeInsets.all(10.0),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: prs.colorBotones,
                            onPrimary: Colors.white,
                            elevation: 1.0,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: prs.colorBotones, //Bordes
                                    width: 1.0,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(50.0))),
                        child: Container(
                          margin: EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.headset_mic_outlined,
                                  color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                'Ayuda',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'GoldplayRegular',
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AyudaPage(),
                            ),
                          );
                        }),
                  ),
            // Text('${cajeroModel.referencia}'),
            // Text('${cajeroModel.nombres}'),
            // Text('${cajeroModel.detalle}'),
            // Text('${cajeroModel.sucursal}'),
            // Text('${despachoModel.nombres}'),
            // Text('${despachoModel.referenciaJson}'),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.end,
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: <Widget>[
            //     despachoModel.iconoFormaPago(),
            //     Expanded(child: Container()),
            //     Text(
            //       '${(despachoModel.costoProducto).toStringAsFixed(2)}',
            //       style: TextStyle(fontSize: 16.0, color: prs.colorIcons),
            //     ),
            //     SizedBox(width: 10),
            //     Icon(FontAwesomeIcons.cartPlus,
            //         size: 19.0, color: prs.colorIcons),
            //     SizedBox(width: 20),
            //     Text(
            //       '${(despachoModel.costoEnvio).toStringAsFixed(2)}',
            //       style: TextStyle(fontSize: 16.0, color: prs.colorIcons),
            //     ),
            //     SizedBox(width: 10),
            //     Icon(FontAwesomeIcons.peopleCarry,
            //         size: 20, color: prs.colorIcons),
            //     SizedBox(width: 30),
            //   ],
            // ),
            // SizedBox(height: 8),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.end,
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: <Widget>[
            //     Text(
            //       '${(despachoModel.costo).toStringAsFixed(2)}',
            //       style: TextStyle(fontSize: 16.0, color: prs.colorIcons),
            //     ),
            //     SizedBox(width: 10),
            //     Icon(FontAwesomeIcons.dollarSign,
            //         size: 20.0, color: prs.colorIcons),
            //     SizedBox(width: 30),
            //   ],
            // ),
            // SizedBox(height: 8),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.end,
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: <Widget>[
            //     Text(
            //       'En efectivo: ${despachoModel.efectivoTotal()}',
            //       style: TextStyle(fontSize: 17.0, color: prs.colorIcons),
            //     ),
            //     SizedBox(width: 10),
            //     Icon(FontAwesomeIcons.moneyBillWave,
            //         size: 20.0, color: prs.colorIcons),
            //     SizedBox(width: 30),
            //   ],
            // ),

            // Text('Detalle:',
            //     style: TextStyle(color: prs.colorIcons),
            //     overflow: TextOverflow.ellipsis),
            // SizedBox(height: 4.0),
            // Text('${cajeroModel.detalle}',
            //     maxLines: 30,
            //     style: TextStyle(color: prs.colorTextDescription),
            //     overflow: TextOverflow.ellipsis),
            // SizedBox(height: 3.0),
            // Text('Referencia:',
            //     style: TextStyle(color: prs.colorIcons),
            //     overflow: TextOverflow.ellipsis),
            // SizedBox(height: 4.0),
            // Text('${cajeroModel.referencia}',
            //     maxLines: 3,
            //     style: TextStyle(color: prs.colorTextDescription),
            //     overflow: TextOverflow.ellipsis),
            // SizedBox(height: 40.0),
            // _crearIdentificacion(),
            SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }

  Widget _crearIdentificacion() {
    if (despachoModel.idDespachoEstado >= conf.DESPACHO_ENTREGADO &&
        Sistema.idAplicativo == Sistema.idAplicativoCuriosity) {
      String identificacion =
          '${utils.generateMd5(('${despachoModel.idCompra}.J-P.${despachoModel.idDespacho}'))}';
      return TextFormField(
        readOnly: true,
        initialValue: identificacion,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(FontAwesomeIcons.whatsapp),
            onPressed: () async {
              _notificar(
                  '${despachoModel.idCompra}-$identificacion-${despachoModel.idDespacho}');
            },
          ),
          hintText: 'Identificación',
          labelText: 'Identificación',
        ),
      );
    }
    return Container();
  }

  _notificar(String identificacion) async {
    try {
      String url =
          'https://api.whatsapp.com/send?phone=593968424853&text=Hola, mi identificación es: $identificacion. ';
      final Uri _url = Uri.parse(url);
      if (!await launchUrl(_url, mode: LaunchMode.externalApplication))
        throw 'Could not launch $_url';
    } catch (err) {
      print(err);
    }
  }

  _rastrearVehiculo(data) async {
    if (!mounted) return;
    double lt = double.parse(data['lt'].toString());
    double lg = double.parse(data['lg'].toString());
    _ubiarVehiculo(lt, lg);
  }

  MapRepository _mapRepository = MapRepository();
       MapRepository get mapRepo => _mapRepository;

  _ubiarVehiculo(double lt, double lg) async {
    if (despachoModel.idDespachoEstado == conf.DESPACHO_RECOGIDO || despachoModel.idDespachoEstado == conf.DESPACHO_ASIGNADO) {
      _markers.remove(markerPool);
      final Uint8List salida = await marker.getBytesFromCanvas(
          "assets/png/entrega2.png", cajeroModel.acronimo);
      var imagSalida = BitmapDescriptor.fromBytes(salida);
      markerPool = Marker(
          icon: imagSalida,
          position: LatLng(lt, lg),
          markerId: MarkerId('POOL'));
      if (_rastrear) {
        _cameraPosition = CameraPosition(target: LatLng(lt, lg), zoom: _zoom);
        _moverCamaraMapa(_cameraPosition);
      }
      _markers.add(markerPool);
      if (!mounted) return;
      if (mounted) setState(() {});
      
       await mapRepo
        .getRouteCoordinates(LatLng(lt, lg), despachoModel.idDespachoEstado == conf.DESPACHO_ASIGNADO ? LatLng(despachoModel.ltA, despachoModel.lgA) : LatLng(despachoModel.ltB, despachoModel.lgB))
        // .getRouteCoordinates(LatLng(lt, lg),LatLng(despachoModel.ltA, despachoModel.lgA))
        .then((route) async {
        _polyline.clear();
        _polyline.add(Polyline(
        width: 3,
        geodesic: true,
        points: Utils.convertToLatLng(Utils.decodePoly(route)),
        color: Color.fromARGB(255, 34, 8, 201), polylineId: PolylineId("PoligonoID")));
      });
    }
  }

  Widget _avatar() {
    Widget _avatar = Container(
      height: 82,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 3, color: prs.colorGrisAreaTexto)),
      child: Column(
        children: [
          Text('Llegada estimada',
              style: TextStyle(fontSize: 15, fontFamily: 'GoldplayRegular')),
          SizedBox(
            height: 5,
          ),
          Text(
            despachoModel.tiempoEntrega.toString() + " min.",
            style: TextStyle(
                color: prs.colorRojo,
                fontSize: 20,
                fontFamily: 'GoldplayBlack'),
          )
        ],
      ),
    );
    return Stack(
      children: <Widget>[
        _avatar,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(60)),
                splashColor: Colors.blueAccent.withOpacity(0.6),
                onTap: () async {
                  if (_solidController.isOpened) return _solidController.hide();
                  _solidController.show();
                }),
          ),
        ),
      ],
    );
  }

  Widget _avatarInfo() {
    
    Widget _avatar = Container(
      width: 60,
      height: 60,
      margin: EdgeInsets.only(left: 10),
      child: ClipOval(
        child: Image(width: 70,height: 70 , fit: BoxFit.fill, image: NetworkImage('${cache.img(despachoModel.img)}')),
      ),
      // child: ClipRRect( child:Image(image: AssetImage(despachoModel.img), height: 70,width: 70,), )
    );
    return Stack(
      children: <Widget>[
        _avatar,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(110)),
                splashColor: Colors.blueAccent.withOpacity(0.6),
                onTap: () async {
                  final GoogleMapController controller =
                      await _controller.future;
                  controller.animateCamera(CameraUpdate.newLatLngBounds(
                      despachoModel.latLngBounds, 150.0));
                }),
          ),
        )
      ],
    );
  }

  Widget _infoPool() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: EdgeInsets.all(20),
        height: 70,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(50)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  blurRadius: 20,
                  offset: Offset.zero,
                  color: Colors.grey.withOpacity(0.5))
            ]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _avatarInfo(),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('${despachoModel.label}'),
                    Text('${despachoModel.estado}')
                  ],
                ),
              ),
            ),
            tipo == conf.TIPO_CLIENTE || despachoModel.idDespacho <= 0
                ? Container()
                : _botonDespachador(),
          ],
        ),
      ),
    );
  }

  Widget _botonDespachador() {
    if (cajeroModel.idCompraEstado == conf.COMPRA_CANCELADA ||
        cajeroModel.idCompraEstado == conf.COMPRA_ENTREGADA) return Container();

    if (tipo == conf.TIPO_ASESOR &&
        despachoModel.idDespachoEstado >= conf.DESPACHO_ASIGNADO) {
      Icon icon = Icon(FontAwesomeIcons.hands, color: Colors.white);
      return Container(
        width: 80.0,
        child: RawMaterialButton(
          padding:
              EdgeInsets.only(left: 10.0, top: 15.0, bottom: 15.0, right: 15.0),
          onPressed: () {},
          child: icon,
          shape: CircleBorder(),
          fillColor: Colors.teal,
        ),
      );
    }

    if (despachoModel.idDespachoEstado == conf.DESPACHO_ASIGNADO)
      return Container(
        width: 80.0,
        child: RawMaterialButton(
          // padding:
          //     EdgeInsets.only(left: 10.0, top: 15.0, bottom: 15.0, right: 15.0),
          onPressed: _confirmarRecogidaDesdeConductor,
          child: Icon(Icons.check,color: Colors.white,size: 30,) ,
          shape: CircleBorder(),
          fillColor: Colors.teal,
        ),
      );
    if (despachoModel.idDespachoEstado == conf.DESPACHO_RECOGIDO)
      return Container(
        width: 80.0,
        child: RawMaterialButton(
          padding:
              EdgeInsets.only(left: 10.0, top: 15.0, bottom: 15.0, right: 15.0),
          onPressed: _confirmarEntrega,
          child: prs.iconoDespachador,
          shape: CircleBorder(),
          fillColor: prs.colorButtonSecondary,
        ),
      );
    return Container();
  }

  void _confirmarRecogidaDesdeConductor() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0.0),
            title: Text('RECOGER PEDIDO', textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text('${despachoModel.detalleJson}'),
                ),
                SizedBox(height: 10.0),
                _contenidoDialog(),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CANCELAR'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: prs.colorButtonSecondary,
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0))),
                  label: Text('CONFIRMAR'),
                  icon: Icon(FontAwesomeIcons.hands, size: 18.0),
                  onPressed: _enviarConfirmarRecogida),
            ],
          );
        });
  }

  _enviarConfirmarRecogida() async {
    Navigator.pop(context);
    _saving = true;
    _mensajeProgreso = 'Notificando...';
      
    if (mounted) setState(() {});
    
    // await Rastreo().notificarUbicacion();
    
    DespachoModel _despacho = await _despachoProvider.confirmarRecogida(
        despachoModel,
        despachoModel.idCliente,
        despachoModel.idConductor,
        conf.CHAT_ENVIA_CAJERO);
    
    despachoModel = _despacho;
    _saving = false;
    if (!mounted) return;
    if (mounted) setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      content: Text(
        'En hora buena. Se notificó que has recogido el pedido.',
        style: TextStyle(color: Colors.white),
      ),
    ));
  }

  void _confirmarEntrega() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0.0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text('${despachoModel.detalleJson}'),
                ),
                SizedBox(height: 10.0),
                _contenidoDialog(),
                
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CANCELAR'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    primary: prs.colorButtonSecondary,
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0))),
                label: Text('CONFIRMAR'),
                icon: Icon(
                  FontAwesomeIcons.peopleCarry,
                  size: 18.0,
                ),
                onPressed: _enviarConfirmarEntrega,
              ),
            ],
          );
        });
  }

  Widget _contenidoDialog() {
    double efectivo_productos =  double.parse( despachoModel.efectivoTotal()) - double.parse(despachoModel.efectivoEnvio());
    
    return DataTable(
      showCheckboxColumn: false,
      columnSpacing: 10.0,
      headingRowHeight: 0.0,
      columns: [
        DataColumn(
          label: Text(''),
          numeric: false,
        ),
        DataColumn(
          label: Text(''),
          numeric: true,
        ),
      ],
      rows: [
        // DataRow(cells: [
        //   DataCell(Text('Productos')),
        //   DataCell(Text('${(despachoModel.costoProducto).toStringAsFixed(2)}')),
        // ]),
        // DataRow(cells: [
        //   DataCell(Text('Envío')),
        //   DataCell(Text('${(despachoModel.costoEnvio).toStringAsFixed(2)}')),
        // ]),
        DataRow(cells: [
          DataCell(Text('Forma de pago')),
          DataCell(Text(
            despachoModel.typePayment==1 ? "Efectivo" : despachoModel.typePayment==2 ? "Yape" : despachoModel.typePayment==3 ? "Plin" : "Tarjeta",
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          )),
        ]),
        DataRow(cells: [
          DataCell(Text('Propina')),
          DataCell(Text(
            '${despachoModel.propina}',
            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
         )),
]),
        // DataRow(cells: [
        //   DataCell(Text('Forma de pago')),
        //   DataCell(Text(
        //     despachoModel.formaPago,
        //     style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        //   )),
        // ]),
        DataRow(cells: [
          DataCell(Text('Efectivo productos')),
          DataCell(Text(
            '${despachoModel.efectivoProdcuto()}',
            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
          )),
        ]),
        DataRow(cells: [
          DataCell(Text('Efectivo envío')),
          DataCell(Text(
            '${despachoModel.efectivoEnvio()}',
            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
          )),
        ]),
        DataRow(cells: [
          DataCell(Text('Total efectivo')),
          DataCell(Text(
            '${despachoModel.efectivoTotal()}',
            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
          )),
        ]),
      ],
    );
  }

  _enviarConfirmarEntrega() async {
    Navigator.pop(context);
    _saving = true;
    _mensajeProgreso = 'Notificando...';
    if (mounted) setState(() {});
    // await Rastreo().notificarUbicacion();
    await _despachoProvider.entregarProducto(despachoModel);
    _saving = false;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ComprasDespachoPage()),
        (Route<dynamic> route) {
      return false;
    });
  }

  _irRutaGoogleMaps() async {
    var ubucacionSucursal =
        'https://www.google.com/maps/dir//${cajeroModel.lt},${cajeroModel.lg}/@${cajeroModel.lt},${cajeroModel.lg},17.82z/';

    var ubucacionCliente =
        'https://www.google.com/maps/dir//${cajeroModel.ltB},${cajeroModel.lgB}/@${cajeroModel.ltB},${cajeroModel.lgB},17.82z/';

    Share.share(
        '*Nueva Compra*  \nSucursal ${cajeroModel.sucursal}: \n$ubucacionSucursal \nCliente ${cajeroModel.nombres}: \n$ubucacionCliente \n*Contacto:* ${cajeroModel.celular} \n*Costo total:* ${cajeroModel.costo} \n*Pedido:* ${cajeroModel.detalle} \n*Referencia:* ${cajeroModel.referencia}');
  }

  _initUbicar() async {
    _markers.remove(markerDesde);

    if (despachoModel.tipo != conf.COMPRA_TIPO_COMPRA) {
      final Uint8List ingreso = await marker.getBytesFromCanvas(
          "assets/png/negocio2.png", cajeroModel.acronimoSucursal);
      var imagIngreso = BitmapDescriptor.fromBytes(ingreso);

      markerDesde = Marker(
          infoWindow: InfoWindow(
              title: '${cajeroModel.sucursal}', onTap: _irPuntoRecogida),
          markerId: MarkerId(despachoModel.ltA.toString()),
          icon: imagIngreso,
          position: LatLng(double.parse(despachoModel.ltA.toString()),
              double.parse(despachoModel.lgA.toString())));
      _markers.add(markerDesde);
    }

    _markers.remove(markerHasta);
    if (tipo == conf.TIPO_CLIENTE) {
      ClienteModel _clienteModel = _prefs.clienteModel;
      final Uint8List salida = await marker.getBytesFromCanvas(
          "assets/png/persona2.png", _clienteModel.acronimo);
      var imagSalida = BitmapDescriptor.fromBytes(salida);
      markerHasta = Marker(
          onTap: () {},
          infoWindow: InfoWindow(title: '${_clienteModel.nombres}'),
          markerId: MarkerId(despachoModel.lgA.toString()),
          icon: imagSalida,
          position: LatLng(despachoModel.ltB, despachoModel.lgB));
    } else {
      if (despachoModel.idDespachoEstado < conf.DESPACHO_ENTREGADO) {
        if (despachoModel.tipo == conf.COMPRA_TIPO_TARIFARIO) {
          circles = Set.from([
            Circle(
              circleId: CircleId('2'),
              center: LatLng(despachoModel.ltB, despachoModel.lgB),
              radius: 850.0,
              fillColor: Colors.blue.withOpacity(0.4),
              strokeWidth: 2,
              strokeColor: prs.colorButtonSecondary,
            )
          ]);
        } else if (despachoModel.tipo == conf.COMPRA_TIPO_MULTIPLE) {
          circles = Set.from([
            Circle(
              circleId: CircleId('2'),
              center: LatLng(despachoModel.ltB, despachoModel.lgB),
              radius: 5350.0,
              fillColor: Colors.blue.withOpacity(0.15),
              strokeWidth: 2,
              strokeColor: prs.colorButtonSecondary,
            )
          ]);
        } else {
          final Uint8List salida = await marker.getBytesFromCanvas(
              "assets/png/persona2.png", cajeroModel.acronimo);
          var imagSalida = BitmapDescriptor.fromBytes(salida);

          markerHasta = Marker(
              infoWindow: InfoWindow(
                  title: '${cajeroModel.nombres}', onTap: _irPuntoEntrega),
              markerId: MarkerId(despachoModel.lgA.toString()),
              icon: imagSalida,
              position: LatLng(despachoModel.ltB, despachoModel.lgB));
        }
      } else {
        circles = Set.from([
          Circle(
            circleId: CircleId('1'),
            center: LatLng(despachoModel.ltA, despachoModel.lgA),
            radius: decode.getKilometros(despachoModel.ltA, despachoModel.lgA,
                despachoModel.ltB, despachoModel.lgB),
            fillColor: Colors.blueAccent.withOpacity(0.1),
            strokeWidth: 1,
            strokeColor: prs.colorButtonSecondary,
          )
        ]);
      }
    }

    _markers.add(markerHasta);

    Future.delayed(const Duration(milliseconds: 900), () async {
      final GoogleMapController controller = await _controller.future;
      if (!mounted) return;
      controller.animateCamera(
          CameraUpdate.newLatLngBounds(despachoModel.latLngBounds, 150.0));
    });
    if (!mounted) return;
    if (mounted) setState(() {});
  }

  Set<Circle> circles = Set.from([]);

  _chat(poolModel, rutaModel) {
    if (tipo == conf.TIPO_ASESOR || despachoModel.idDespacho <= 0) return;

    despachoModel.sinLeerCliente = 0;
    despachoModel.sinLeerConductor = 0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDespachoPage(despachoModel: despachoModel),
      ),
    );
  }

  _irPuntoEntrega() async {
    var ubucacion =
        'https://www.google.com/maps/dir//${despachoModel.ltB},${despachoModel.lgB}/@${despachoModel.ltB},${despachoModel.lgB},17.82z/';
    final Uri _url = Uri.parse(ubucacion);
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication))
      throw 'Could not launch $_url';
  }

  _irPuntoRecogida() async {
    if (despachoModel.tipo == conf.COMPRA_TIPO_COMPRA)
      return dlg.mostrar(
          context, 'No especificado\n\n ${despachoModel.detalleJson}');
    var ubucacion =
        'https://www.google.com/maps/dir//${despachoModel.ltA},${despachoModel.lgA}/@${despachoModel.ltA},${despachoModel.lgA},17.82z/';
    final Uri _url = Uri.parse(ubucacion);
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication))
      throw 'Could not launch $_url';
  }

  _contenido() {
    return Container(
      child: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            minMaxZoomPreference: MinMaxZoomPreference(6, 20),
            compassEnabled: true,
            // myLocationEnabled: true,
            indoorViewEnabled: true,
            tiltGesturesEnabled: true,
            myLocationButtonEnabled: false,
            initialCameraPosition: _cameraPosition,
            // onCameraMove: (CameraPosition cameraPosition) {
            //   lt = cameraPosition.target.latitude;
            //   lg = cameraPosition.target.longitude;
            //   _zoom = cameraPosition.zoom;
            // },
            onMapCreated: (GoogleMapController controller) async {
              if (!_controller.isCompleted) {
                await _controller.complete(controller);
              }
              rootBundle.loadString('assets/mapStyle.txt').then((string) {
              controller.setMapStyle(string);
            }); 
            },
            // circles: circles,
            markers: _markers,
            polylines: _polyline,
          ),
          // Visibility(
          //     visible: tipo == conf.TIPO_CONDCUTOR &&
          //         despachoModel.tipo != conf.COMPRA_TIPO_COMPRA,
          //     child: Positioned(
          //       top: 110.0,
          //       right: 25.0,
          //       child: ElevatedButton.icon(
          //         style: ElevatedButton.styleFrom(
          //             primary: despachoModel.tipo == conf.COMPRA_TIPO_ENCOMIENDA
          //                 ? Colors.green
          //                 : prs.colorButtonSecondary,
          //             elevation: 2.0,
          //             shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(20.0))),
          //         label: Icon(
          //             despachoModel.tipo == conf.COMPRA_TIPO_ENCOMIENDA
          //                 ? FontAwesomeIcons.peopleCarry
          //                 : FontAwesomeIcons.store,
          //             size: 27.0),
          //         icon: Icon(FontAwesomeIcons.phoneAlt, size: 27.0),
          //         onPressed: _llamarLocal,
          //       ),
          //     )),
          // Visibility(
          //     visible: tipo == conf.TIPO_CONDCUTOR &&
          //         despachoModel.tipo == conf.COMPRA_TIPO_CATALOGO,
          //     child: Positioned(
          //       top: 190.0,
          //       right: 25.0,
          //       child: ElevatedButton.icon(
          //         style: ElevatedButton.styleFrom(
          //             primary: despachoModel.tipo == conf.COMPRA_TIPO_ENCOMIENDA
          //                 ? Colors.green
          //                 : prs.colorButtonSecondary,
          //             elevation: 2.0,
          //             shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(20.0))),
          //         label: Icon(FontAwesomeIcons.store, size: 27.0),
          //         icon: Icon(FontAwesomeIcons.whatsapp, size: 27.0),
          //         onPressed: () async {
          //           String url =
          //               'https://api.whatsapp.com/send?phone=${despachoModel.telSuc.toString().replaceAll('+', '')}&text=Hola de ${Sistema.aplicativoTitle} un pedido de: ${cajeroModel.detalle}';
          //           final Uri _url = Uri.parse(url);
          //           if (!await launchUrl(_url,
          //               mode: LaunchMode.externalApplication))
          //             throw 'Could not launch $_url';
          //         },
          //       ),
          //     )),
          Visibility(
              visible: _cargando && tipo != conf.TIPO_CONDCUTOR,
              child: LinearProgressIndicator(
                  backgroundColor: prs.colorLinearProgress)),
          // _infoPool(),
          _buscando(),
          // _productoPreparandose(),
          _enLugar(),
        ],
      ),
    );
  }

  Widget _enLugar() {
    //Si no se carga el despacho o ya se dio tiempo de preparacion no se muestra
    if (despachoModel == null ||
        tipo != conf.TIPO_CONDCUTOR ||
        despachoModel.tipo == conf.COMPRA_TIPO_ENCOMIENDA ||
        despachoModel.tipo == conf.COMPRA_TIPO_TARIFARIO ||
        despachoModel.tipo == conf.COMPRA_TIPO_MULTIPLE) return Container();
    // if (despachoModel.idDespachoEstado == conf.DESPACHO_RECOGIDO) {
    //   return Positioned(
    //     top: 117.0,
    //     left: 0.0,
    //     child: SliderButton(
    //       dismissible: false,
    //       boxShadow: BoxShadow(
    //         color: Colors.black,
    //         blurRadius: 0.1,
    //       ),
    //       baseColor: Colors.white,
    //       shimmer: false,
    //       radius: 10.0,
    //       height: 35.0,
    //       width: 230.0,
    //       action: () {
    //         _enviarConfirmarEnLugar();
    //       },
    //       label: Text(
    //         "Pedir al cliente salir",
    //         style: TextStyle(
    //             color: Colors.white, fontWeight: FontWeight.w500, fontSize: 17),
    //       ),
    //       backgroundColor: Colors.green,
    //       buttonSize: 35.0,
    //       dismissThresholds: 0.6,
    //       icon: Icon(
    //         FontAwesomeIcons.bullhorn,
    //         size: 20.0,
    //         color: Colors.green,
    //       ),
    //     ),
    //   );
    // }
    return Container();
  }

  bool isNotificado = false;
  DateTime notificado = DateTime.now().subtract(Duration(seconds: 28));

  _enviarConfirmarEnLugar() async {
    if (isNotificado || DateTime.now().difference(notificado).inSeconds <= 30) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          'Para volver a notificar deben pasar al menos 30 segundos y solo han transcurrido ${DateTime.now().difference(notificado).inSeconds}',
          style: TextStyle(color: Colors.white),
        ),
      ));

      return;
    }
    isNotificado = true;
    _saving = true;
    _mensajeProgreso = 'Notificando...';
    if (mounted) setState(() {});
    await Rastreo().notificarUbicacion(
        isEvaluar: true, lt: despachoModel.ltB, lg: despachoModel.lgB);
    DespachoModel _despacho = await _despachoProvider.confirmarNoticicacion(
        despachoModel,
        despachoModel.idCliente,
        despachoModel.idConductor,
        conf.CHAT_ENVIA_CAJERO,
        preparandose,
        tipoNotificacionFuera);
    isNotificado = false;
    notificado = DateTime.now();
    despachoModel = _despacho;
    _comprasDespachoBloc.actualizarPorDespacho(_despacho);
    _saving = false;
    if (!mounted) return;
    if (mounted) setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      content: Text(
        'Notificamos que te encuentras fuera del lugar de entrega.',
        style: TextStyle(color: Colors.white),
      ),
    ));
  }

  Widget _productoPreparandose() {
    //Si no se carga el despacho o ya se dio tiempo de preparacion no se muestra
    if (despachoModel == null ||
        despachoModel.preparandose > 0 ||
        tipo != conf.TIPO_CONDCUTOR ||
        despachoModel.idDespachoEstado >= conf.DESPACHO_RECOGIDO ||
        despachoModel.tipo == conf.COMPRA_TIPO_ENCOMIENDA ||
        despachoModel.tipo == conf.COMPRA_TIPO_TARIFARIO ||
        despachoModel.tipo == conf.COMPRA_TIPO_MULTIPLE) return Container();
    return Stack(
      children: [
        Positioned(
          top: 160.0,
          left: 0.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: Colors.white,
            ),
            child: TouchSpin(
              displayFormat: NumberFormat.currency(
                  locale: "es_ES", symbol: "min", decimalDigits: 0),
              min: 3,
              max: 120,
              step: 3,
              value: int.parse(preparandose),
              textStyle: TextStyle(fontSize: 30),
              iconSize: 49.0,
              addIcon: Icon(Icons.add_circle_outline),
              subtractIcon: Icon(Icons.remove_circle_outline),
              iconActiveColor: Colors.green,
              iconDisabledColor: Colors.grey,
              iconPadding: EdgeInsets.only(left: 10.0, right: 10.0),
              onChanged: (val) {
                preparandose = val.toString();
              },
            ),
          ),
        ),
        Positioned(
          top: 117.0,
          left: 0.0,
          child: SliderButton(
            dismissible: false,
            boxShadow: BoxShadow(
              color: Colors.black,
              blurRadius: 0.1,
            ),
            baseColor: Colors.white,
            shimmer: false,
            radius: 10.0,
            height: 35.0,
            width: 230.0,
            action: () {
              _enviarConfirmarPreparacion();
            },
            label: Text(
              "Orden preparándose",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 17),
            ),
            backgroundColor: prs.colorButtonSecondary,
            buttonSize: 35.0,
            dismissThresholds: 0.6,
            icon: Icon(
              FontAwesomeIcons.utensils,
              size: 16.0,
              color: prs.colorButtonSecondary,
            ),
          ),
        )
      ],
    );
  }

  _enviarConfirmarPreparacion() async {
    _saving = true;
    _mensajeProgreso = 'Notificando...';
    if (mounted) setState(() {});
    await Rastreo().notificarUbicacion();
    DespachoModel _despacho = await _despachoProvider.confirmarNoticicacion(
        despachoModel,
        despachoModel.idCliente,
        despachoModel.idConductor,
        conf.CHAT_ENVIA_CAJERO,
        preparandose,
        tipoNotificacionPreparacion);
    despachoModel = _despacho;
    _comprasDespachoBloc.actualizarPorDespacho(_despacho);
    _saving = false;
    if (!mounted) return;
    if (mounted) setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      content: Text(
        'Has notificado que la orden se está preparando.',
        style: TextStyle(color: Colors.white),
      ),
    ));
  }

  Widget _botonLlamarUrbe(String zona, String celular, String costo) {
    return Container(
      width: 250.0,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            primary: despachoModel.tipo == conf.COMPRA_TIPO_ENCOMIENDA
                ? Colors.green
                : prs.colorButtonSecondary,
            elevation: 2.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0))),
        label: Container(
          width: 150.0,
          child: Text('$celular $costo $zona'),
        ),
        icon: Icon(FontAwesomeIcons.phoneAlt, size: 27.0),
        onPressed: () {
          _call(celular);
        },
      ),
    );
  }

  _call(String tel) async {
    final Uri _url = Uri.parse(tel);
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication))
      throw 'Could not launch $_url';
  }

  _llamarLocal() async {
    if (despachoModel.tipo == conf.COMPRA_TIPO_MULTIPLE) {
      List<Widget> widgetlist = [];
      if (widgetlist.length != 0)
        for (var i = 0; i < despachoModel.numerosJson.length; i++) {
          widgetlist.add(_botonLlamarUrbe(
            despachoModel.numerosJson[i]['zona'],
            despachoModel.numerosJson[i]['celular'],
            despachoModel.numerosJson[i]['costo'],
          ));
        }
      Widget _contenido = SingleChildScrollView(
        child: Column(
          children: widgetlist,
          mainAxisSize: MainAxisSize.min,
        ),
      );
      dlg.llamar(context, _contenido);
      return;
    }
    String _call = 'tel:${despachoModel.telSuc}';
    final Uri _url = Uri.parse(_call);
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication))
      throw 'Could not launch $_url';
  }

  Widget _buscando() {
    if (cajeroModel.idDespacho <= 0)
      return Stack(
        children: <Widget>[
          Positioned(
            bottom: 0,
            right: 0,
            child: Opacity(
              opacity: 0.9,
              child: CircularProgressIndicator(),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Opacity(
              opacity: 0.9,
              child: CircularProgressIndicator(),
            ),
          )
        ],
      );
    return Container();
  }

  _moverCamaraMapa(_kLake) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
