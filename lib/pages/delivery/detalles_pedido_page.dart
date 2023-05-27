import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../bloc/card_bloc.dart';
import '../../bloc/carrito_bloc.dart';
import '../../bloc/direccion_bloc.dart';
import '../../bloc/promocion_bloc.dart';
import '../../dialog/carrito_dialog.dart';
import '../../dialog/direccion_dialog.dart';
import '../../model/cajero_model.dart';
import '../../model/card_model.dart';
import '../../model/direccion_model.dart';
import '../../model/promocion_model.dart';
import '../../preference/db_provider.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cajero_provider.dart';
import '../../providers/compra_provider.dart';
import '../../sistema.dart';
import '../../utils/button.dart' as btn;
import '../../utils/conf.dart' as config;
import '../../utils/dialog.dart' as dlg;
import '../../utils/navegar.dart' as navegar;
import '../../utils/permisos.dart' as permisos;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../widgets/carrito_widget.dart';
import '../planck/direccion_page.dart';

class DetallePedidoPage extends StatefulWidget {
 final double costoTotal;
  final double propina;
  final double envio;
  final String descripcion;
  final CompraProvider compraProvider;

   DetallePedidoPage(
      {
        this.descripcion,
        this.costoTotal,this.propina,
      this.envio,
      this.compraProvider})
      : super();

  @override
  _DetallePedidoPageState createState() => _DetallePedidoPageState();
  
}

class _DetallePedidoPageState extends State<DetallePedidoPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PromocionBloc _promocionBloc = PromocionBloc();
  final DireccionBloc _direccionBloc = DireccionBloc();
  final CarritoBloc _carritoBloc = CarritoBloc();
  List<PromocionModel> promociones;
  final CajeroProvider _cajeroProvider = CajeroProvider();
  final CompraProvider _compraProvider = CompraProvider();
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final TextEditingController _typeControllerDireccion =
      TextEditingController();
  final _cardBloc = CardBloc();
  List<CajeroModel> cajeros = [];

  bool _saving = false;
  String _title = 'Consultando costo';

  double costoTotal = 0.0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DireccionModel direccionSeleccionada = DireccionModel();

  @override
  void initState() {
    cargarPromociones();
    _typeControllerDireccion.text = direccionSeleccionada.alias;
    super.initState();
    cambiarDireccion();

    _direccionBloc.direccionStream.listen((direcccion) {
      _seleccionarDireccionDesde(_direccionBloc.direccionSeleccionada);
    });
  }

  _seleccionarDireccionDesde(DireccionModel direccion) {
    _typeControllerDireccion.text = direccion.alias;
    direccionSeleccionada = direccion;

    if (!mounted) return;
    if (mounted) setState(() {});
    cambiarDireccion();
  }

  Future<List<PromocionModel>> cargarPromociones() async {
    if (direccionSeleccionada.idUrbe <= 0)
      promociones = await _carritoBloc.listar(_prefs.idUrbe);
    else {
      promociones = await _carritoBloc.listar(direccionSeleccionada.idUrbe);
    }
    return promociones;
  }

  bool _radar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        title: Text('Detalles del pedido',
            style: TextStyle(
                color: prs.colorGrisOscuro,
                fontSize: 17,
                fontFamily: 'GoldplayRegular',
                fontWeight: FontWeight.w800)),
        leading: utils.leading(context),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Center(
            child: Container(
          padding: EdgeInsets.all(20),
          child: _body(),
          width: prs.anchoFormulario,
          decoration: BoxDecoration(color: Colors.white),
        )),
      ),
    );
  }

  Widget _body() {
    return Column(children: <Widget>[
      Expanded(
          child: SingleChildScrollView(
              child: Column(children: [
        Container(
          padding: EdgeInsets.all(20),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    color: prs.colorRojo,
                    borderRadius: BorderRadius.circular(100)),
              ),
              SizedBox(
                width: 10,
              ),
              Text('King B',style: TextStyle(
                        fontFamily: 'GoldplayBlack',
                        fontSize: 17,),)
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: prs.colorGrisBordes)),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Colors.amber[300])),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Combo Papas',
                              style: TextStyle(fontSize: 16,fontFamily: 'GoldplayRegular',fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 20,),
                            Text('S/.10.32', style: TextStyle(
                              color: prs.colorRojo,
                        fontFamily: 'GoldplayRegular',
                        fontSize: 16,
                        ),)
                          ],
                        ),
                        Container(
                          child: Text('Hamburguesa de carne ',
                              style: TextStyle(fontSize: 15)),
                        )
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                thickness: 1,
                color: prs.colorGrisBordes,
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complementos',
                    textAlign: TextAlign.start,
                    style: TextStyle(color: prs.colorGrisClaro, fontWeight: FontWeight.bold),
                  ),
                  Text('Papas artesanales medianas',
                      textAlign: TextAlign.start,style: TextStyle(color: prs.colorGrisClaro),),
                  SizedBox(
                    height: 10,
                  ),
                  Text('Bebidas', textAlign: TextAlign.start,style: TextStyle(color: prs.colorGrisClaro,fontWeight: FontWeight.bold),),
                  Text(
                      'Inka Cola 500ml, Coca Cola Sabor Original 500ml, Inka Cola sabor original 500ml',
                      textAlign: TextAlign.start,style: TextStyle(color: prs.colorGrisClaro),),
                  SizedBox(
                    height: 10,
                  ),
                  Text('Salsas', textAlign: TextAlign.start,style: TextStyle(color: prs.colorGrisClaro,fontWeight: FontWeight.bold),),
                  Text('Ají ranchero, Mostazam, Ketchup, Aceitunas',
                      textAlign: TextAlign.start,style: TextStyle(color: prs.colorGrisClaro),),
                ],
              )),
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: prs.colorGrisBordes)),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Resumen de Pago',
                    style: TextStyle(
                        fontFamily: 'GoldplayRegular',
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Expanded(child: Container())
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                thickness: 1,
                color: prs.colorGrisBordes,
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text('Productos',
                      style: TextStyle(
                          fontFamily: 'GoldplayRegular', fontSize: 16)),
                  Expanded(child: Container()),
                  Text('S/.15.90',
                      style: TextStyle(
                          fontFamily: 'GoldplayRegular', fontSize: 16))
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text('Envio',
                      style: TextStyle(
                          fontFamily: 'GoldplayRegular', fontSize: 16)),
                  Expanded(child: Container()),
                  Text('S/.3.49',
                      style: TextStyle(
                          fontFamily: 'GoldplayRegular', fontSize: 16))
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text('Propina',
                      style: TextStyle(
                          fontFamily: 'GoldplayRegular', fontSize: 16)),
                  Expanded(child: Container()),
                  Text('S/.5.00',
                      style: TextStyle(
                          fontFamily: 'GoldplayRegular', fontSize: 16))
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text('TOTAL',
                      style: TextStyle(
                          fontFamily: 'GoldplayBlack',
                          fontSize: 16,
                          color: prs.colorRojo)),
                  Expanded(child: Container()),
                  Text('S/.23.53',
                      style: TextStyle(
                          fontFamily: 'GoldplayBlack',
                          fontSize: 16,
                          color: prs.colorRojo))
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: prs.colorGrisBordes)),
            child: Column(children: [
              Row(
                children: [
                  Text(
                    'Forma de pago',
                    style: TextStyle(
                        fontFamily: 'GoldplayRegular',
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Expanded(child: Container())
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                thickness: 1,
                color: prs.colorGrisBordes,
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: prs.hexToColor('#1746A2')),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Debito ***** 4213',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Text('Piero Vasquez Riveros',
                          style: TextStyle(
                            fontSize: 17,
                          ))
                    ],
                  )
                ],
              ),
            ])),
        SizedBox(
          height: 20,
        ),
        Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: prs.colorGrisBordes)),
            child: Column(children: [
              Row(
                children: [
                  Text(
                    'Dirección de entrega',
                    style: TextStyle(
                        fontFamily: 'GoldplayRegular',
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Expanded(child: Container())
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                thickness: 1,
                color: prs.colorGrisBordes,
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Colors.amber[300])),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Av. Fondo del Pantano',
                          style: TextStyle(fontSize: 17),
                        ),
                        Text('referencia', style: TextStyle(fontSize: 17))
                      ],
                    ),
                  )
                ],
              ),
            ]))
      ])))
    ]);
  }

  cambiarDireccion({bool mostrarResumen: true}) async {
    if (direccionSeleccionada.idDireccion <= 0) return;

    _update('Consultando costo');
    await cargarPromociones();
    final idsAgencias = [];
    final idsPromociones = [];
    promociones.forEach((promocion) {
      idsAgencias.add(promocion.idAgencia.toString());
      idsPromociones.add(promocion.idPromocion.toString());
    });
    List<String> agencias = LinkedHashSet<String>.from(idsAgencias).toList();

    cajeros = await _cajeroProvider.verCostoPromocion(
        config.COMPRA_TIPO_CATALOGO,
        direccionSeleccionada,
        agencias.toString(),
        idsPromociones.toString());

    if (cajeros == null) {
      direccionSeleccionada = DireccionModel();
      _typeControllerDireccion.text = '';
      if (!mounted) return;
      _complet();
      dlg.mostrar(context, config.MENSAJE_INTERNET);
      return;
    }

    if (cajeros.length != agencias.length) {
      for (var idAgencia in agencias) {
        bool isCorrect = false;
        for (var cajero in cajeros) {
          if (idAgencia == cajero.idAgencia.toString()) {
            isCorrect = true;
            break;
          }
        }
        if (!isCorrect) {
          await DBProvider.db.eliminarPromocionPorAgencia(idAgencia);
          await cargarPromociones();
        }
      }
    }
    await evaluarCosto();
    if (mostrarResumen) _confirmarIniciarCompra(context);
    _complet();
  }

  int _cantidadProductos = 0;

  evaluarCosto() async {
    costoTotal = 0.0;
    _cantidadProductos = 0;
    await cargarPromociones();
    final idsAgencias = [];
    promociones.forEach((promocion) {
      costoTotal += promocion.costoTotal;
      _cantidadProductos++;
      idsAgencias.add(promocion.idAgencia.toString());
    });
    List<String> agencias = LinkedHashSet<String>.from(idsAgencias).toList();
    if (direccionSeleccionada.idDireccion > 0 && cajeros != null) {
      List<CajeroModel> cajerosAux = [];
      for (var item in cajeros) {
        if (agencias.contains(item.idAgencia.toString())) {
          costoTotal = costoTotal + item.costoEnvio;
          cajerosAux.add(item);
        }
      }
      cajeros.clear();
      cajeros.addAll(cajerosAux);
    }
    _promocionBloc.costoSink(costoTotal);
  }

  Widget createExpanPanel(BuildContext context) {
    return Form(
      key: _formKey,
      child: InkWell(
          onTap: _mostrarDirecciones,
          child: Container(
            padding: EdgeInsets.only(left: 10, top: 10, right: 10.0),
            child: TextFormField(
              validator: (bal) {
                if (direccionSeleccionada.idDireccion <= 0) {
                  return 'Selecciona una dirección de entrega';
                }
                return null;
              },
              enabled: false,
              controller: this._typeControllerDireccion,
              decoration: prs.decoration(
                  'Selecciona una dirección de entrega', prs.iconoDespachor),
            ),
          )),
    );
  }

  _mostrarDirecciones() async {
    if (_verificarExplorardor()) return;
    if (_direccionBloc.direcciones.isEmpty) {
      utils.mostrarProgress(context, barrierDismissible: false);
      await _direccionBloc.listar();
      Navigator.pop(context);
    }
    showDialog(
        context: context,
        builder: (context) {
          return DireccionDialog(_direccionBloc.direcciones, _onselecDireccion);
        });
  }

  _onselecDireccion(DireccionModel direccion) {
    Navigator.pop(context);
    if (direccion.idDireccion <= 0) {
      _requestGps();
    } else {
      if (_prefs.isExplorar) {
        return regresar();
      }
      _typeControllerDireccion.text = direccion.alias;
      direccionSeleccionada = direccion;
      cambiarDireccion();
      _promocionBloc.listar(idUrbe: direccionSeleccionada.idUrbe.toString());
      _formKey.currentState.validate();
    }
  }

  regresar() {
    return utils.registrarse(context, _scaffoldKey);
  }

  _requestGps() async {
    permisos.localizarTo(context, (lt, lg) {
      if (lt == 2.2)
        return; //Este estado significa q se mostro dialogo para localizar
      _irADireccion(lt, lg);
    });
  }

  _irADireccion(lt, lg) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DireccionPage(
            lt: lt,
            lg: lg,
            direccionModel: DireccionModel(),
            cajeroModel: null,
            pagina: config.PAGINA_CARRITO),
      ),
    );
  }

  Widget botonCarrito(data) {
    return Column(
      children: [
        Text.rich(
          TextSpan(
            children: <TextSpan>[
              TextSpan(
                  text: 'Sub total: ',
                  style: TextStyle(
                      color: prs.colorGrisOscuro,
                      fontFamily: 'GoldplayRegular',
                      fontWeight: FontWeight.w600,
                      fontSize: 18)),
              TextSpan(
                  text: 'S/. ${data}',
                  style: TextStyle(
                      color: prs.colorRojo,
                      fontFamily: 'GoldplayRegular',
                      fontWeight: FontWeight.w800,
                      fontSize: 18)),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20.0, fontFamily: 'GoldplayRegular'),
        ),
        btn.bootonContinuar('Continuar', _comprar),
      ],
    );
  }

  Widget _botonComprar(BuildContext context) {
    if (direccionSeleccionada.idDireccion > 0)
      return StreamBuilder(
        stream: _promocionBloc.costoStream,
        builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
          if (snapshot.hasData) {
            return botonCarrito(snapshot.data.toStringAsFixed(2));
          } else {
            return btn.bootonContinuar(
                '↑Selecciona una dirección de entrega↑', _comprar);
          }
        },
      );
    return btn.bootonContinuar(
        '↑Selecciona una dirección de entrega↑', _comprar);
  }

  _comprar() {
    if (_verificarExplorardor()) return;
    _confirmarIniciarCompra(context);
  }

  _verificarExplorardor() {
    if (_prefs.isExplorar) {
      utils.registrarse(context, _scaffoldKey);
      return true;
    }
    return false;
  }

  _confirmarIniciarCompra(BuildContext context) async {
    if (!_formKey.currentState.validate() ||
        direccionSeleccionada.idDireccion <= 0) {
      _mostrarDirecciones();
      if (mounted) setState(() {});
      return;
    }

    if (costoTotal <= 0)
      return dlg.mostrar(context, 'No hay productos agregados en el carrito.');

    int superado = _cantidadProductos - 20;
    if (superado > 0)
      return dlg.mostrar(context,
          'Has superado el límite de 20 promociones por transacción.\n\nElimina al menos $superado ${(superado > 1) ? 'promociones' : 'promoción'}.');

    List<CajeroModel> _eliminar = [];
    bool _isEliminar = true;
    for (var cajero in cajeros) {
      for (var promo in promociones) {
        if (cajero.idAgencia.toString() == promo.idAgencia.toString()) {
          _isEliminar = false;
          break;
        }
      }
      if (_isEliminar) {
        _eliminar.add(cajero);
      }
    }
    cajeros.removeWhere((element) => _eliminar.contains(element));
    _cardBloc.actualizar(CardModel(
        modo: Sistema.EFECTIVO,
        number: Sistema.EFECTIVO,
        type: Sistema.EFECTIVO,
        holderName: 'Pagar en efectivo'));
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return CarritoDialog(config.COMPRA_TIPO_CATALOGO,
              cajeros: cajeros,
              costoTotal: costoTotal,
              direccionSeleccionadaEntrega: direccionSeleccionada,
              compraProvider: _compraProvider);
        });
  }

  _update(mensaje) {
    _title = mensaje;
    _saving = true;
    if (mounted) setState(() {});
  }

  _complet() {
    _saving = false;
    _promocionBloc.carrito();
    if (mounted) if (mounted) setState(() {});
  }

  verMenu(PromocionModel promocion) async {
    _update('Cargando...');
    await navegar.verMenu(context, promocion.idAgencia);
    _complet();
  }

  Widget _promociones(BuildContext context) {
    return StreamBuilder(
      stream: _carritoBloc.promocionStream,
      builder:
          (BuildContext context, AsyncSnapshot<List<PromocionModel>> snapshot) {
        if (snapshot.data != null && snapshot.data.length > 0) {
          return CarritoWidget(cambiarDireccion, evaluarCosto, verMenu,
              promociones: snapshot.data);
        } else {
          return Container(
            padding: EdgeInsets.all(50.0),
            child: Center(
              child: Image(
                  image: AssetImage('assets/screen/carrito.png'),
                  fit: BoxFit.cover),
            ),
          );
        }
      },
    );
  }
}
