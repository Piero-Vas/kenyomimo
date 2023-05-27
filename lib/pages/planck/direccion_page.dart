import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../bloc/catalogo_bloc.dart';
import '../../bloc/direccion_bloc.dart';
import '../../bloc/promocion_bloc.dart';
import '../../dialog/mapa_dialog.dart';
import '../../model/cajero_model.dart';
import '../../model/direccion_model.dart';
import '../../model/urbe_model.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/mapa_provider.dart';
import '../../providers/urbe_provider.dart';
import '../../sistema.dart';
import '../../utils/button.dart' as btn;
import '../../utils/conf.dart' as config;
import '../../utils/dialog.dart' as dlg;
import '../../utils/permisos.dart' as permisos;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../delivery/catalogo_page.dart';
import 'direcciones_page.dart';
import 'package:flutter/services.dart' show rootBundle;
class DireccionPage extends StatefulWidget {
  final DireccionModel direccionModel;
  final CajeroModel cajeroModel;
  final double lt, lg;
  final int pagina;

  DireccionPage({Key key,this.direccionModel,this.cajeroModel,this.lt,this.lg,this.pagina: 0}): super(key: key);
  @override
  State<DireccionPage> createState() => DireccionPageState(direccionModel: direccionModel,cajeroModel: cajeroModel,latitud: lt,longitud: lg,pagina: pagina);
}

class DireccionPageState extends State<DireccionPage> with TickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PromocionBloc _promocionBloc = PromocionBloc();
  final DireccionBloc _direccionBloc = DireccionBloc();
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final UrbeProvider _urbeProvider = UrbeProvider();
  final MapaProvider _mapaProvider = MapaProvider();
  final TextEditingController _typeAheadController = TextEditingController();
  UrbeModel _urbeModel = UrbeModel();
  final DireccionModel direccionModel;
  final CajeroModel cajeroModel;
  double latitud;
  double longitud;
  int pagina;
  final Set<Marker> _markers = Set<Marker>();
  GoogleMapController _controller;
  CameraPosition _cameraPosition = CameraPosition(target: LatLng(-8.1053276, -79.0321475), zoom: 13);
  bool isLocalizado = true;
  bool _isLineProgress = false;
  DireccionPageState({this.direccionModel,this.cajeroModel,this.latitud,this.longitud,this.pagina});

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _initUbicar();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  _initUbicar() async {
    if (direccionModel.idDireccion != null) {
      Marker marker = Marker(position: LatLng(latitud, longitud), markerId: MarkerId('A'));
      _markers.add(marker);
      _cameraPosition = CameraPosition(
          target: LatLng(latitud, longitud),
          zoom: latitud == Sistema.lt && longitud == Sistema.lg ? 7 : 15);
    } else {
      _moverCamaraMapa(latitud, longitud);
    }
    direccionModel.lt = latitud;
    direccionModel.lg = longitud;
    _localizarUrbe(latitud, longitud);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(backgroundColor: Colors.white, shadowColor: Colors.white,iconTheme: IconThemeData(
    color: prs.colorBotones,), elevation: 0,),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: _contenido(),
      ),
      // floatingActionButton: Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: <Widget>[
      //     RawMaterialButton(
      //       onPressed: _localizar,
      //       child: prs.iconoLocationCentro,
      //       shape: CircleBorder(),
      //       elevation: 10.0,
      //       fillColor: prs.colorButtonBackground,
      //       padding: const EdgeInsets.all(10.0),
      //     ),
      //     SizedBox(height: 100.0),
      //   ],
      // ),
    );
  }

  Container _contenido() {
    return Container(
      child: Stack(
        children: <Widget>[
          GoogleMap(
            minMaxZoomPreference: MinMaxZoomPreference(1, 20),
            initialCameraPosition: _cameraPosition,
            compassEnabled: false,
            myLocationEnabled: true,
            indoorViewEnabled: true,
            tiltGesturesEnabled: false,
            myLocationButtonEnabled: false,
            onCameraMove: (CameraPosition cameraPosition) {
              _typeAheadController.text = '';
              direccionModel.lt = cameraPosition.target.latitude;
              direccionModel.lg = cameraPosition.target.longitude;
            },
            markers: _markers,
            onMapCreated: (GoogleMapController controller) { 
              _controller = controller; 
              rootBundle.loadString('assets/mapStyle.txt').then((string) {
      controller.setMapStyle(string);
    });
              },
          ),
          Center(child: prs.iconoLocationCentro),
          Visibility(visible: _isLineProgress, child: LinearProgressIndicator(backgroundColor: prs.colorLinearProgress)),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                boxShadow: <BoxShadow>[
                  BoxShadow(blurRadius: 20,offset: Offset.zero,color: Colors.grey.withOpacity(0.5))
                ]),
            child: Container(
              padding: EdgeInsets.all(10.0),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text('Ingresa tu dirección'.toUpperCase(),  
                      style: TextStyle(fontSize: 20, color: prs.colorBotones, fontFamily: 'GoldplayBlack'),)],
                  ),
                  Container(
                      child: Text('Coloca el pin sobre la ubicación o ingresa el nombre de la dirección.',textAlign: TextAlign.left,  
                        style: TextStyle(fontSize: 16, fontFamily: 'GoldplayRegular',),),
                    ),
                  SizedBox(height: 20),
                  createExpanPanel(context),
                ],
              ), 
            ),
          ),
          Positioned(
              bottom: 10.0,
              child: btn.confirmar('ESTABLECER UBICACIÓN', _confirmarDireccion))
        ],
      ),
    );
  }

  Widget createExpanPanel(BuildContext context) {
    return InkWell(
      onTap: _mostrarDirecciones,
      child: TextFormField(
        enabled: false,
        controller: this._typeAheadController,
        decoration:
            prs.decoration2('Buscar un lugar cerca de ⤵', prs.iconoBuscar),
      ),
    );
  }

  _mostrarDirecciones() async {
    if (_direccionBloc.direcciones.isEmpty) {
      utils.mostrarProgress(context, barrierDismissible: false);
      await _direccionBloc.listar();
      Navigator.pop(context);
    }
    showDialog(
        context: context,
        builder: (context) {
          return MapaDialog(_onSelectMapa, direccionModel.lt, direccionModel.lg);
        });
  }

  _onSelectMapa(suggestion) {
    Navigator.pop(context);
    this._typeAheadController.text = suggestion['main'];
    _consultarPosision(suggestion['place_id'], suggestion['main'], suggestion['secondary']);
  }

  _consultarPosision(String placeId, String main, String secondary) async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_urbeModel.idUrbe == 0 && Sistema.ID_VERIFICAR_URBE) return utils.mostrarSnackBar(context, 'Lo sentimos no trabajamos en esta zona');
    utils.mostrarRadar(context);
    var local = await _mapaProvider.localizar(placeId, main, secondary);
    if (local.length > 0) {
      double lt = local['lat'];
      double lg = local['lng'];
      _moverCamaraMapa(lt, lg);
      _localizarUrbe(lt, lg);
    } else {
      utils.mostrarSnackBar(context, 'Lugar $main no localizada',milliseconds: 3000);
    }
    Navigator.pop(context);
  }

  bool _saving = false;

  Future<UrbeModel> _localizarUrbe(double lt, double lg) async {
    _urbeModel = UrbeModel(idUrbe: 1);
    /* if (!Sistema.ID_VERIFICAR_URBE) {
      _urbeModel = UrbeModel(idUrbe: 1000);
      return _urbeModel;
    }

    await _urbeProvider.localizar(lt, lg, (estado, urbe) {
      if (estado == 1) {
        _urbeModel = urbe;
      } else {
        _urbeModel = UrbeModel();
        _urbeModel.urbe = 'Zona no cubierta';
      }
      if (!mounted) return;
      if (mounted) setState(() {});
    }); */
    return _urbeModel;
  }

  _localizar() async {
    if (_saving) return;
    isLocalizado = await permisos.localizar(context, _moverCamaraMapa);
  }

  void _confirmarDireccion() async {
    
    if (_prefs.isExplorar) return utils.registrarse(context, _scaffoldKey);
    if (_saving) return;
    if (direccionModel.lt == null ||
        direccionModel.lg == null ||
        direccionModel.lg == 0 ||
        direccionModel.lt == 0) {
      dlg.mostrar(context, 'Por favor ubica la dirección exacta en el mapa');
      
      return;
    }
    _saving = true;
    if (mounted) setState(() {});
    await _localizarUrbe(direccionModel.lt, direccionModel.lg);
    _saving = false;
    if (mounted) setState(() {});
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(10.0),
            title: Text('Detalla una referencia'),
            content: SingleChildScrollView(
              child: Container(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          initialValue: direccionModel.alias,
                          maxLength: 65,
                          decoration: InputDecoration(
                            labelText: 'Calle y numero',
                            hintText: 'e.g: Calle Magnolias 300',
                          ),
                          onSaved: (value) => direccionModel.alias = value,
                          validator: (value) {
                            if (value.trim().length < 3)
                              return 'Mínimo 3 caracteres';
                            return null;
                          }),
                      TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          initialValue: direccionModel.referencia,
                          maxLength: 65,
                          decoration: InputDecoration(
                            labelText: 'Referencia o caracteristicas de casa',
                            hintText: 'e.g: Casa de dos pisos color blanca',
                          ),
                          onSaved: (value) => direccionModel.referencia = value,
                          validator: (value) {
                            if (value.trim().length < 4)
                              return 'Mínimo 4 caracteres';
                            return null;
                          })
                    ],
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CANCELAR'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor : prs.colorButtonSecondary,
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0))),
                label: Text('ACEPTAR'),
                icon: Icon(
                  Icons.local_library,
                  size: 18.0,
                ),
                onPressed: () {
                  utils.mostrarProgress(context);
                  _enviarConfirmar(context);
                },
              ),
            ],
          );
        });
  }

  final ClienteProvider _clienteProvider = ClienteProvider();
  final CatalogoBloc _catalogoBloc = CatalogoBloc();

  void _enviarConfirmar(context) async {
    direccionModel.idUrbe = _urbeModel.idUrbe;
    FocusScope.of(context).requestFocus(FocusNode());
    if (!_formKey.currentState.validate()) {
      Navigator.of(context).pop();
      return;
    }
    _formKey.currentState.save();
    
    //Cuando la direccion no esta creada se crea
    if (direccionModel.idDireccion == -1) {
      await _direccionBloc.crear(direccionModel);
    } else {
      await _direccionBloc.editar(direccionModel);
    }
    _direccionBloc.direccionSeleccionada = direccionModel;
    String idUrbe = direccionModel.idUrbe.toString();
    _prefs.idUrbe = idUrbe;
    _prefs.alias = direccionModel.alias.toString();
    _clienteProvider.urbe(idUrbe);
    int _selectedIndex = 0;
    _catalogoBloc.listarAgencias(_selectedIndex, direccionModel: _direccionBloc.direccionSeleccionada);
    _promocionBloc.listar(idUrbe: _direccionBloc.direccionSeleccionada.idUrbe.toString());
    Navigator.of(context).pop();

    if (cajeroModel == null) {
      MaterialPageRoute route;
      if (pagina == config.PAGINA_COMPRAS) {
        route = MaterialPageRoute(builder: ((BuildContext context) => CatalogoPage()));
      } else if (pagina == config.PAGINA_RUTAS_DIRECCION_DESDE ||
          pagina == config.PAGINA_RUTAS_DIRECCION_HASTA) {
        Navigator.pop(context);
        Navigator.pop(context);
        return;
      } else if (pagina == config.PAGINA_SOLICITUD) {
        Navigator.pop(context);
        Navigator.pop(context);
        return;
      } else if (pagina == config.PAGINA_CARRITO) {
        Navigator.pop(context);
        Navigator.pop(context);
        return;
      } else {
        route = MaterialPageRoute(builder: ((BuildContext context) => DireccionesPage()));
      }
      Navigator.of(context).pushAndRemoveUntil(route, (Route<dynamic> route) {
        return route.isFirst;
      });
      return;
    }
  }

  Future<void> _moverCamaraMapa(double lt, double lg) async {
    _cameraPosition = CameraPosition(target: LatLng(lt, lg), zoom: 17.2);
    _controller.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
  }
}