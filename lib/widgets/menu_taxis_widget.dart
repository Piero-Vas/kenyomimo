import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mimo/pagesTaxis/conductor/map_screen.dart';
import 'package:mimo/pagesTaxis/pasajeros/select_services_page.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../preference/shared_preferences.dart';
import '../providers/cliente_provider.dart';
import '../../utils/permisos.dart' as permisos;
import '../utils/cache.dart' as cache;
import '../utils/personalizacion.dart' as prs;
import '../utils/utils.dart' as utils;

class MenuWidgetTaxis extends StatefulWidget {
  @override
  _MenuWidgetTaxisState createState() => _MenuWidgetTaxisState();
}

class _MenuWidgetTaxisState extends State<MenuWidgetTaxis> {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final ClienteProvider _clienteProvider = ClienteProvider();

  String perfils;
  @override
  void initState() {
    perfil();
    super.initState();
  }

  perfil() {
    perfils = _prefs.clienteModel.perfil.toString();
    
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _encabezado(context),
                    _elementos(),
                  ],
                ),
              ),
            ),
            _pie(),
          ],
        ),
      ),
    );
  }

  _cerrarSession() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: Text(
              'Alerta',
              textAlign: TextAlign.center,
            ),
            content: Text('¿Seguro deseas cerrar sesión?'),
            actions: <Widget>[
              TextButton(
                  child: Text('CANCELAR'),
                  onPressed: () => Navigator.of(context).pop()),
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: prs.colorMorado,
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0))),
                  label: Text('CERRAR SESIÓN'),
                  icon: Icon(
                    FontAwesomeIcons.rightFromBracket,
                    color: Colors.white,
                    size: 15.0,
                  ),
                  onPressed: () {
                    utils.mostrarProgress(context, barrierDismissible: false);
                    _clienteProvider.cerrarSession((estado, error) {
                      if (estado == 1) {
                        permisos.cerrasSesion(context);
                      } else {
                        utils.mostrarSnackBar(context, error,
                            milliseconds: 2000000);
                        Navigator.of(context).pop();
                        Navigator.pop(context);
                      }
                    });
                  }),
            ],
          );
        });
  }

  Widget _pie() {
    return Column(
      children: [
        ListTile(
            dense: true,
            leading: Image(
              image: AssetImage("assets/png/ayuda.png"),
              height: 25,
              width: 25,
            ),
            title: Text('Ayuda'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, 'ayudataxi');
            }),
        ListTile(
            dense: true,
            leading: Image(
              image: AssetImage("assets/png/sobreapp.png"),
              height: 25,
              width: 25,
            ),
            title: Text('Términos y Condiciones '),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, 'terminoscondiciones');
            }),
        ListTile(
            dense: true,
            leading: Image(
              image: AssetImage("assets/png/sobreapp.png"),
              height: 25,
              width: 25,
            ),
            title: Text('Sobre el app '),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, 'sobreapp');
            }),
        ListTile(
          dense: true,
          leading: prs.iconoCerrarSessionTaxi,
          title: Text('Cerrar sesión'),
          onTap: () {
            _cerrarSession();
          },
        ),
        perfils != '0'
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_prefs.isTaxi) {
                        _prefs.isTaxi = false;
                        setState(() {});
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => SelectService()),
                            (Route<dynamic> route) {
                          return route.isFirst;
                        });
                      } else {
                        _prefs.isTaxi = true;
                        setState(() {});
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => MapScreen()),
                            (Route<dynamic> route) {
                          return route.isFirst;
                        });
                      }
                    },
                    child: Text(
                      _prefs.isTaxi ? "MODO PASAJERO" : "MODO CONDUCTOR",
                      style: TextStyle(color: prs.colorMorado),
                    ),
                    style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        side: BorderSide(color: prs.colorMorado, width: 1),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: Colors.transparent,
                        foregroundColor: prs.colorMorado),
                  ),
                ),
              )
            : SizedBox(
                height: 15,
              ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                
                if (_prefs.clienteModel.perfil.toString() == '2') {
                  Navigator.pushNamed(context, 'compras_despacho');
                } else {
                  Navigator.pushNamed(context, 'catalogo2');
                }
              },
              child: Text(
                "IR A DELIVERY",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(
                    vertical: 20,
                  ),
                  backgroundColor: prs.colorMorado,
                  foregroundColor: prs.colorMorado),
            ),
          ),
        ),
      ],
    );
  }

  Widget _elementos() {
    if (perfils != "0") {
      switch (_prefs.isTaxi) {
        case true:
          return _elementosTaxista(context);
        case false:
          return _elementosCliente(context);
      }
    } else {
      return _elementosCliente(context);
    }
  }

  Widget _encabezado(BuildContext context) {
    Container tarjeta = Container(
      margin: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 10),
          CircularPercentIndicator(
            radius: 33.0,
            lineWidth: 3.0,
            animation: true,
            percent: _prefs.clienteModel.registros > 0
                ? (_prefs.clienteModel.correctos /
                    _prefs.clienteModel.registros)
                : 1.0,
            center: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: cache.fadeImage(_prefs.clienteModel.img,
                  width: 60, height: 60),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: prs.colorMorado,
          ),
          SizedBox(width: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 175.0,
                child: Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                          text: '¡Buen ',
                          style: TextStyle(
                              color: prs.colorBotones,
                              fontFamily: 'GoldplayBlack',
                              fontSize: 21)),
                      TextSpan(
                          text: 'Día, ',
                          style: TextStyle(
                              color: prs.colorAmarillo,
                              fontFamily: 'GoldplayBlack',
                              fontSize: 21)),
                      TextSpan(
                          text:_prefs.clienteModel.nombres.split(" ")[0] + " " +_prefs.clienteModel.apellidos.split(" ")[0]+'!',
                          style: TextStyle(
                              color: prs.colorMorado,
                              fontFamily: 'GoldplayBlack',
                              fontSize: 20)),
                    ],
                  ),
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 20.0, fontFamily: 'Goldplay'),
                ),
              ),
            ],
          )
        ],
      ),
    );

    return Stack(
      children: <Widget>[
        tarjeta,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.blueAccent.withOpacity(0.6),
              onTap: () {
                //utils.mostrarProgress(context);
                //_clienteProvider.ver((estado, error, push, notificacionModel) {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'perfil_taxi');
                //});
              },
            ),
          ),
        ),
      ],
    );
  }

  Container _elementosCliente(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15.0),
      child: Column(
        children: <Widget>[
          ListTile(
              dense: true,
              leading: Image(
                image: AssetImage("assets/png/solicitudes.png"),
                height: 25,
                width: 25,
              ),
              title: Text('Inicio '),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'taxis');
              }),
          ListTile(
              dense: true,
              leading: Image(
                image: AssetImage("assets/png/viajes.png"),
                height: 25,
                width: 25,
              ),
              title: Text('Mis Viajes '),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'viajes');
              }),
          ListTile(
              dense: true,
              leading: Image(
                image: AssetImage("assets/png/cartera2.png"),
                height: 25,
                width: 25,
              ),
              title: Text('Métodos de pago'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'cards_taxi');
              }),
          ListTile(
              dense: true,
              leading: Image(
                image: AssetImage("assets/png/datos.png"),
                height: 25,
                width: 25,
              ),
              title: Text('Mis datos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'perfil_taxi');
              }),
          perfils == '0'
              ? ListTile(
                  dense: true,
                  leading: Image(
                    image: AssetImage("assets/png/conductor.png"),
                    height: 25,
                    width: 25,
                  ),
                  title: Text('Ser Conductor'),
                  onTap: () async {
                    DocumentSnapshot documentSnapshot = await FirebaseFirestore
                        .instance
                        .collection('request')
                        .doc(_prefs.idCliente)
                        .get();
                    if (documentSnapshot.exists) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Ya cuenta con una solicitud!! ☺☺☺☺')));
                    } else
                      Navigator.pushNamed(context, 'serconductor');
                  })
              : SizedBox()
        ],
      ),
    );
  }

  Container _elementosTaxista(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15.0),
      child: Column(
        children: <Widget>[
          ListTile(
              dense: true,
              leading: Image(
                image: AssetImage("assets/png/solicitudes.png"),
                height: 25,
                width: 25,
              ),
              title: Text('Solicitudes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'solicitudes');
              }),
          ListTile(
              dense: true,
              leading: Image(
                image: AssetImage("assets/png/pagos.png"),
                height: 25,
                width: 25,
              ),
              title: Text('Pagos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'pagos');
              }),
          ListTile(
              dense: true,
              leading: Image(
                image: AssetImage("assets/png/estrella.png"),
                height: 25,
                width: 25,
              ),
              title: Text('Calificaciones'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'calificaciones');
              }),
          ListTile(
              dense: true,
              leading: Image(
                image: AssetImage("assets/png/datos.png"),
                height: 25,
                width: 25,
              ),
              title: Text('Mis datos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'perfil_taxi');
              }),
        ],
      ),
    );
  }
}