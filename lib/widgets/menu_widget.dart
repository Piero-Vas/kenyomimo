import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../pages/delivery/catalogo_page.dart';
import '../pages/paymentez/cards_page.dart';
import '../preference/shared_preferences.dart';
import '../providers/cliente_provider.dart';
import '../sistema.dart';
import '../../utils/permisos.dart' as permisos;
import '../utils/cache.dart' as cache;
import '../utils/personalizacion.dart' as prs;
import '../utils/utils.dart' as utils;
import '../../utils/button.dart' as btn;
class MenuWidget extends StatefulWidget {
  @override
  _MenuWidgetState createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final ClienteProvider _clienteProvider = ClienteProvider();

  bool _isVentas = false;
  bool _isAgeneciasRegistro = false;
  String perfils ;
  @override
  void initState() {
    perfil();
    super.initState();
  }

  perfil(){
     
     perfils = _prefs.clienteModel.perfil;
    
    try {
      Map<String, dynamic> decodedResp = _prefs.clienteModel.beta=='' ? null : (json.decode(_prefs.clienteModel.beta));
      if (decodedResp != null) {
        _isVentas = (decodedResp['v'] == '1');
      }
    } catch (err) {
      print('Error menu $err');
    } 
    try {
      Map<String, dynamic> decodedResp = _prefs.clienteModel.beta=='' ? null : (json.decode(_prefs.clienteModel.beta));
      if (decodedResp != null) {
        _isAgeneciasRegistro = (decodedResp['ar'] == '1');
      }
    } catch (err) {
      print('Error menu $err');
    }
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
                    Divider(),
                    // Container(
                    //   padding: EdgeInsets.only(left: 15.0),
                    //   child: ListTile(
                    //       dense: true,
                    //       leading: prs.iconoNotificacion,
                    //       title: Text('Notificaciones'),
                    //       onTap: () {
                    //         Navigator.pop(context);
                    //         Navigator.pushNamed(context, 'notificacion');
                    //       }),
                    // ),
                    _elementos(),
                    /* Container(
                      padding: EdgeInsets.only(left: 15.0),
                      child: ListTile(
                          dense: true,
                          leading: prs.iconoPuntos,
                          title: Text('Insignia & Money | Cash'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, 'puntos');
                          }),
                    ), */
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
                      primary: prs.colorButtonSecondary,
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0))),
                  label: Text('CERRAR SESIÓN'),
                  icon: Icon(
                    FontAwesomeIcons.signOutAlt,
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
                            milliseconds: 2500);
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
        Visibility(
          visible: !_prefs.isExplorar,
          child: ListTile(
              dense: true,
              leading: prs.iconoAyuda,
              title: Text('Ayuda'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'ayuda');
              }),
        ),
        // Visibility(
        //   visible: !_prefs.isExplorar &&
        //       Sistema.idAplicativo == Sistema.idAplicativoCuriosity,
        //   child: ListTile(
        //       dense: true,
        //       leading: prs.iconoVentas,
        //       title: Text('Aumenta tus ventas'),
        //       onTap: () {
        //         Navigator.pop(context);
        //         Navigator.pushNamed(context, 'preregistro');
        //       }),
        // ),
        ListTile(
          dense: true,
          leading: prs.iconoExclamacion,
          title: Text('Sobre la app'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, 'sobreapp');
          },
        ),
        ListTile(
          dense: true,
          leading: prs.iconoExclamacion,
          title: Text('Términos y condiciones'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, 'terminoscondiciones');
          },
        ),
        ListTile(
          dense: true,
          leading: prs.iconoCerrarSession,
          title: Text('Cerrar sesión'),
          onTap: () {
             _cerrarSession();
          },
        ),
        ListTile(
          dense: true,
          title: btn.bootonContinuar('IR A TAXI', (){
            // if(_prefs.clienteModel.perfil != 3){
            //   _prefs.isTaxi = false;
            // }else{
            //   _prefs.isTaxi = true;
            // }
            // Navigator.pushNamed(context, "taxis");
            if(_prefs.clienteModel.perfil.toString() != '0'){
               _prefs.isTaxi = true;
                              Navigator.pushNamed(context, 'solicitudes');
                            }else{
                               _prefs.isTaxi = false;
                              Navigator.pushNamed(context, 'taxis');
                            }
          }),
          onTap: () {
          },
        ),
        
        

        /* Divider(),
        SizedBox(height: 4),
        Text('V: ${utils.headers['vs']} Powered by Planck',
            textScaleFactor: 0.8),
        SizedBox(height: 10), */
      ],
    );
  }

  Widget _elementos() {
    switch (_prefs.clienteModel.perfil) {
      case '1':
        return _elementosCajero(context);
      case '2':
        return _elementosDespachador(context);
      default:
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
            /* progressColor: prs.colorButtonSecondary, */
          ),
          SizedBox(width: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  width: 175.0,
                  child: 
                  Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: '¡Buen ', style: TextStyle(color: prs.colorBotones,fontFamily: 'GoldplayBlack',fontSize: 21)),
                          TextSpan(text: 'Día, ', style: TextStyle(color: prs.colorAmarillo,fontFamily: 'GoldplayBlack',fontSize: 21)),
                          TextSpan(text: _prefs.clienteModel.nombres.split(" ")[0] + " " +_prefs.clienteModel.apellidos.split(" ")[0]+'!', style: TextStyle(color: prs.colorMorado,fontFamily: 'GoldplayBlack',fontSize: 20)),
                        ],
                      ),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'Goldplay'
                      ),
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
                utils.mostrarProgress(context);
                _clienteProvider.ver((estado, error, push, notificacionModel) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'perfil');
                });
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
              leading: prs.iconoCasaOutLined,
              title: Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => CatalogoPage()),
                (Route<dynamic> route) {
              return false;
            });
              }),
          ListTile(
          dense: true,
          leading: prs.iconoDirecciones,
          title: Text('Mis direcciones'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, 'direcciones_cliente');
          }),
          ListTile(
              dense: true,
              leading: prs.iconoCompras,
              title: Text('Historial de solicitudes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'compras_cliente');
              }),
          Visibility(
            visible: !_prefs.isExplorar,
            child: ListTile(
                dense: true,
                leading: prs.iconoMenuMetodoPago,
                title: Text('Métodos de pago'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CardsPage(isMenu: true)));
                }),
          ),
          
          ListTile(
              dense: true,
              leading: prs.iconoPersona,
              title: Text('Mis datos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'perfil');
              }),
              perfils == '0'?
              ListTile(
              dense: true,
              leading: Image(
                image: AssetImage("assets/png/moto.png"),
                height: 25,
                width: 25,
              ),
              title: Text('Ser Motorizado'),
              onTap: ()async {
                DocumentSnapshot documentSnapshot = await FirebaseFirestore
                        .instance
                        .collection('request')
                        .doc(_prefs.idCliente)
                        .get();
                    if (documentSnapshot.exists) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Ya cuenta con una solicitud!! ☺☺☺☺')));
                    } else  Navigator.pushNamed(context, 'sermoto');
               
              }):Container(),
          
         /*  Visibility(
            visible: !_prefs.isExplorar,
            child: ListTile(
                dense: true,
                leading: prs.iconoFactura,
                title: Text('Datos de facturas'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'facturas_cliente');
                }),
          ), */
        ],
      ),
    );
  }

  Container _elementosCajero(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12.0),
      child: Column(
        children: <Widget>[
          ListTile(
              dense: true,
              leading: prs.iconoSucursal,
              title: Text('Administración'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'sucursales');
              }),
          Visibility(
            visible: _isAgeneciasRegistro,
            child: ListTile(
                dense: true,
                leading: prs.iconoVentas,
                title: Text('Pre registros'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'agencia');
                }),
          ),
          Visibility(
            visible: _isVentas,
            child: ListTile(
                dense: true,
                leading: prs.iconoPaquetes,
                title: Text('Ventas'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'ventas');
                }),
          ),
          ListTile(
              dense: true,
              leading: prs.iconoCompras,
              title: Text('Solicitar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'catalogo2');
              }),
          ListTile(
              dense: true,
              leading: prs.iconoFactura,
              title: Text('Datos de facturas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'facturas_cliente');
              }),
          ListTile(
              dense: true,
              leading: prs.iconoDirecciones,
              title: Text('Mis direcciones'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'direcciones_cliente');
              }),
        ],
      ),
    );
  }

  Container _elementosDespachador(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12.0),
      child: Column(
        children: <Widget>[
          ListTile(
              dense: true,
              leading: prs.iconoNotificacion,
              title: Text('Notificaciones'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'compras_despacho');
              }),
          ListTile(
              dense: true,
              leading: prs.iconoPersona,
              title: Text('Mis datos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'perfil');
              })
          // ListTile(
          //     dense: true,
          //     leading: prs.iconoCompras,
          //     title: Text('Solicitar'),
          //     onTap: () {
          //       Navigator.pop(context);
          //       Navigator.pushNamed(context, 'catalogo2');
          //     }),
              
          // ListTile(
          //     dense: true,
          //     leading: prs.iconoFactura,
          //     title: Text('Historial de Pedidos'),
          //     onTap: () {
          //       Navigator.pop(context);
          //       Navigator.pushNamed(context, 'compras_despacho');
          //     })
        ],
      ),
    );
  }
}