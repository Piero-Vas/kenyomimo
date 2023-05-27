import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mimo/bloc/carrito_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'dart:convert';
import 'package:flash/flash.dart';
import 'package:http/http.dart';
import '../bloc/cajero_bloc.dart';
import '../bloc/card_bloc.dart';
import '../bloc/catalogo_bloc.dart';
import '../bloc/factura_bloc.dart';
import '../bloc/promocion_bloc.dart';
import '../model/cajero_model.dart';
import '../model/card_model.dart';
import '../model/catalogo_model.dart';
import '../model/direccion_model.dart';
import '../model/factura_model.dart';
import '../model/hashtag_model.dart';
import '../model/promocion_model.dart';
import '../pages/admin/compras_cajero_page.dart';
import '../pages/delivery/catalogo_page.dart';
import '../pages/delivery/compras_despacho_page.dart';
import '../pages/delivery/menu_page.dart';
import '../pages/delivery/verificar_celular_page.dart';
import '../pages/paymentez/cards_page.dart';
import '../preference/db_provider.dart';
import '../preference/shared_preferences.dart';
import '../providers/card_provider.dart';
import '../providers/catalogo_provider.dart';
import '../providers/cliente_provider.dart';
import '../providers/compra_provider.dart';
import '../providers/hashtag_provider.dart';
import '../sistema.dart';
import '../utils/button.dart' as btn;
import '../utils/cache.dart' as cache;
import '../utils/compra.dart' as compra;
import '../utils/conf.dart' as config;
import '../utils/dialog.dart' as dlg;
import '../utils/personalizacion.dart' as prs;
import '../utils/utils.dart' as utils;
import '../utils/validar.dart' as val;

class CarritoDialog extends StatefulWidget {
  final double costoTotal;
  final DireccionModel direccionSeleccionadaEntrega;
  final DireccionModel direccionSeleccionadaCliente;
  final CompraProvider compraProvider;
  final List<CajeroModel> cajeros;
  final PromocionModel promocion;
  final int tipo;
  final int total_tiempo_preparacion;
  final double costoEnvio;

  CarritoDialog(this.tipo,
      {this.promocion,
      this.costoTotal,
      this.direccionSeleccionadaEntrega,
      this.direccionSeleccionadaCliente,
      this.compraProvider,
      this.cajeros, this.total_tiempo_preparacion, this.costoEnvio})
      : super();

  CarritoDialogState createState() => CarritoDialogState(tipo,
      direccionSeleccionadaCliente: direccionSeleccionadaCliente,
      promocion: promocion,
      cajeros: cajeros,
      costoTotal: costoTotal,
      direccionSeleccionadaEntrega: direccionSeleccionadaEntrega,
      compraProvider: compraProvider,total_tiempo_preparacion:total_tiempo_preparacion,costoEnvio:costoEnvio);
}

class CarritoDialogState extends State<CarritoDialog> with TickerProviderStateMixin {
  CatalogoProvider _catalogoProvider = CatalogoProvider();
  var a = 12;
  final int total_tiempo_preparacion;
  final double costoEnvio;
  final PromocionModel promocion;
  bool _isLineProgress = false;
  double descuentoPorCupon = 0.0;
  double costoTotal;
  double promocionValor = 0.0;
  int promocionIdAgencia = -1;
  dynamic promocionIdHashtag = -1;
  final List<CajeroModel> cajeros;
  final DireccionModel direccionSeleccionadaCliente;
  final DireccionModel direccionSeleccionadaEntrega;
  final PromocionBloc _promocionBloc = PromocionBloc();
  final CajeroBloc _cajeroBloc = CajeroBloc();
  final _facturaBloc = FacturaBloc();
  final _cardBloc = CardBloc();
  final _cardProvider = CardProvider();
  final CompraProvider compraProvider;
  final CatalogoBloc _catalogoBloc = CatalogoBloc();
  final int tipo;
  final HashtagProvider _hashtagProvider = HashtagProvider();
  final ClienteProvider _clienteProvider = ClienteProvider();
  String _celular = '';
  int _valueMetodoPago = 0;
  String metodopago = "Debitoa";
  final CarritoBloc _carritoBloc = CarritoBloc(); 
  CarritoDialogState(this.tipo,
      {this.total_tiempo_preparacion,
      this.costoEnvio,
      this.promocion,
      this.costoTotal,
      this.direccionSeleccionadaCliente,
      this.direccionSeleccionadaEntrega,
      this.compraProvider,
      this.cajeros});

  TextEditingController _controllerMetodoPago = TextEditingController();
  TextEditingController propinaText = TextEditingController();

  List<dynamic> misTarjetas = [];
  List<dynamic> tarjetas = [];

  getTotal(){
    // total = costoEnvio + propina + costoTotal;
    total = costoEnvio + costoTotal;
    envio = costoEnvio;
    if (mounted) {
      setState(() {
      });
    }
    
  }

  Future getAllCards() async {
    try {
      final _prefs = PreferenciasUsuario();
      var id = _prefs.clienteModel.idCliente;
      return FirebaseFirestore.instance
          .collection("cards")
          .where("idCliente", isEqualTo: id.toString())
          .where("eliminado", isEqualTo: false)
          .where('seleccionado', isEqualTo: true)
          .snapshots()
          .listen((result) async {
        misTarjetas.clear();
        misTarjetas.addAll(result.docs);
        if (mounted) {
          setState(() {
            tarjetas = misTarjetas;
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  // TARJETA PAGAR Y RECHAZAR

  //String get _merchantBaseUrl => 'https://api.openpay.pe/v1/m0qhimwy1aullokkujfg';
  // final String apiKeyPublic = "pk_20261e9590c24c1995bd82c30959d12b";
  // final String apiKeyPrivate = "sk_da8b8e48791540958a47dae3488abfa9";
  String get _merchantBaseUrl =>
      'https://sandbox-api.openpay.pe/v1/mkq9aic4rs51cybtcdut';
  final String apiKeyPublic = "pk_92bef45248c34ce7a41d59ca30ab72c1";
  final String apiKeyPrivate = "sk_41d63faafb4c413581fbf776030771da";
  Future<Map> createCharge(
      String source_id,
      double amount,
      String name,
      String last_name,
      String phone_number,
      String email,
      String _deviceID) async {
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$apiKeyPrivate:'));
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': basicAuth,
      'Accept': 'application/json',
    };
    String body = """{  
      "source_id": "$source_id",
      "method": "card",
      "amount": $amount,
      "currency": "PEN",
      "description": "Cargo Taxi",
      "device_session_id": "$_deviceID",
      "customer":{
        "name" : "$name",
        "last_name" : "$last_name",
        "phone_number" : "$phone_number",
        "email" : "$email" 
      }
    }""";
    Response response = await post(Uri.parse('$_merchantBaseUrl/charges'),
        headers: headers, body: body);
    Map responseReturn = {'body': response.body};
    if (response.statusCode == 201 || response.statusCode == 200) {
      responseReturn['status'] = true;
      return responseReturn;
    } else {
      responseReturn['status'] = false;
      return responseReturn;
    }
  }

  double envio = 0.00;
  double propina = 0.00;
  double total = 0.0;
  bool switchs = true;
  bool switchs1 = true;
  bool switchs2 = true;
  bool switchotro = true;
  @override
  void initState() {
    _listarProductos(cajeros);
    getAllCards();
    _celular = _prefs.clienteModel.celular;
    super.initState();
    getTotal();
    _controllerMetodoPago.text = _cardBloc.cardSeleccionada.number;
    _inputFieldDateController = TextEditingController(text: '');
    //_facturaBloc.facturaSeleccionada = FacturaModel();
    //_facturaBloc.obtener();
    /* _cardBloc.cardSeleccionadaStream.listen((CardModel card) {
      descuentoPorCupon = 0.0;
      if (card?.modo.toString().toUpperCase() == Sistema.CUPON.toUpperCase()) {
        if (!mounted) return;
        _evaluarCupon(card);
      } else {
        _agregarFormaPagoCajero(card);
      }
      if (mounted) if (mounted) setState(() {});
    }); */
    if (_cardBloc.cardSeleccionada.modo.toString().toUpperCase() ==
        Sistema.CUPON.toUpperCase()) {
      _isLineProgress = true;
      if (mounted) setState(() {});
      if (descuentoPorCupon <= 0) {
        Future.delayed(const Duration(milliseconds: 1150), () async {
          _cardBloc.actualizar(_cardBloc.cardSeleccionada);
          _isLineProgress = false;
          if (mounted) setState(() {});
        });
      }
    }
    
  }

  @override
  void dispose() {
    listarCarrito();
    super.dispose();
  }

  listarCarrito(){
    _carritoBloc.listar("1");
  }

 /*  _agregarFormaPagoCajero(CardModel card) {
    cajeros.forEach((cajero) {
      cajero.cardModel = card;
    });
  }

  _evaluarCupon(CardModel card) {
    if (card?.modo.toString().toUpperCase() == Sistema.CUPON.toUpperCase()) {
      _cardBloc.cardSeleccionada = card;
      bool isCuponvalido = false;
      cajeros.forEach((CajeroModel cajero) {
        if (cajero.idAgencia.toString() == card.idAgencia.toString()) {
          isCuponvalido = true;
          cajero.cardModel = card;
          descuentoPorCupon =
              cajero.total() > card.cupon ? card.cupon : cajero.total();
          cajero.credito = descuentoPorCupon;
          cajero.creditoEnvio = descuentoPorCupon >= cajero.costoEnvio
              ? cajero.costoEnvio
              : descuentoPorCupon;
          double creditoProducto = descuentoPorCupon - cajero.costoEnvio;
          cajero.creditoProducto = descuentoPorCupon >= cajero.total()
              ? cajero.costo
              : creditoProducto <= 0
                  ? 0
                  : creditoProducto;
        } else {
          cajero.cardModel = CardModel();
        }
      });
      if (!isCuponvalido) {
        _cardBloc.actualizar(CardModel());
        fBotonDerecha() async {
          Navigator.of(context).pop();
          _update();
          CatalogoModel catalogoModel =
              await _catalogoProvider.ver(card.idAgencia);
          _cardBloc.cardSeleccionada = card;
          _complet();
          Navigator.of(context).pop();
          if (catalogoModel == null) return;
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => MenuPage(catalogoModel)),
              (Route<dynamic> route) {
            return route.isFirst;
          });
        }

        fIzquierda() async {
          Navigator.of(context).pop();
        }

        dlg.mostrar(context, card.mensaje,
            mBotonDerecha: 'VER CATÁLOGO',
            fBotonIDerecha: fBotonDerecha,
            fIzquierda: fIzquierda,
            mIzquierda: 'CANCELAR',
            icon: Icons.touch_app,
            color: prs.colorButtonSecondary);
      }
    }
  }
 */
  bool _saving = false;
  TextEditingController _inputFieldDateController;

/*   Widget _crearCodigo() {
    return TextFormField(
      controller: _inputFieldDateController,
      textCapitalization: TextCapitalization.words,
      decoration: prs.decoration('Hashtag promocional', prs.iconoCodigo),
    );
  } */

  _canjer(String codigo) async {
    FocusScope.of(context)?.requestFocus(FocusNode());
    promocionIdAgencia = -1;
    promocionValor = 0.0;
    promocionIdHashtag = -1;
    _update();
    HashtagModel _hashtag =
        await _hashtagProvider.ver(codigo.toLowerCase().trim(), cajeros);
    _complet();

    //Cuando no hay internet, paso algo y no se respondio status 200 desde servidor
    if (_hashtag.estado == -2) {
      return dlg.mostrar(context, _hashtag.error);
    }
    //Cuando el codigo es errone pero se respondio desde servidor correctamtnete
    else if (_hashtag.estado == -1) {
      //Cuanod el # es incorrecto y se confirma la compra cerramos el dialog
      dlg.mostrar(context,
          'Por favor revisa su escritura o continua con la compra simplemente tocando de nuevo el botón (COMPRAR)',
          titulo: 'Hashtag incorrecto',
          mIzquierda: 'ACEPTAR',
          color: prs.colorButtonSecondary);
      return;
    }
    //Cuando el codigo es correcto pero de agencia diferente
    else if (_hashtag.estado == 2) {
      fBotonDerecha() async {
        Navigator.of(context).pop();
        _update();

        CatalogoModel catalogoModel =
            await _catalogoProvider.ver(_hashtag.idAgencia);
        Navigator.of(context).pop();
        _complet();
        if (catalogoModel == null) return;
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => MenuPage(catalogoModel)),
            (Route<dynamic> route) {
          return route.isFirst;
        });
      }

      return dlg.mostrar(context, _hashtag.error,
          mBotonDerecha: _hashtag.mBotonDerecha,
          fBotonIDerecha: _hashtag.isBotonDerecha() ? fBotonDerecha : null,
          mIzquierda: _hashtag.mIzquierda,
          icon: Icons.touch_app,
          color: prs.colorButtonSecondary);
    }
    //Codigo correcto
    else if (_hashtag.estado == 1) {
      promocionIdAgencia = _hashtag.idAgencia;
      promocionValor = _hashtag.promocion;
      promocionIdHashtag = _hashtag.idHashtag;
      relizarCompra(_valueMetodoPago, "");
    }
    if (mounted) setState(() {});
  }

  bool _isEfectivo = true;

  String _costoMostrado = '0.00';
  List<String> _compraSucursal = [];
  List<String> _compraCosto = [];
  List<String> _compraEnvio = [];
  List<String> _compraDetalle = [];
  List<String> _imgs = [];
  double _pay = 0.0;

  _listarProductos(List<CajeroModel> cajeros) async {
    _compraSucursal.clear();
    for (CajeroModel cajero in cajeros) {
      _compraSucursal.add('${cajero.sucursal}');
    }
  }

  Future<List<DataRow>> _costoProductos(List<CajeroModel> cajeros) async {
    // _isEfectivo = _controllerMetodoPago.text == Sistema.efectivo;
    List<PromocionModel> promocionesAComprar;
    double _saldo = cajeros[0].saldoMoney;
    double _costoTotal = costoTotal;
    double _moneyDescontado = 0.0;
    List<DataRow> rows = [];
    _costoMostrado = '0.00';
    _compraSucursal.clear();
    _compraCosto.clear();
    _compraEnvio.clear();
    _compraDetalle.clear();
    _pay = 0.0;
    for (CajeroModel cajero in cajeros) {
      _pay = cajero.pay; //Guaramos en una variable el pay que posee el cliente.
      cajero.costo = 0.0;
      cajero.evaluar(_saldo);
      _saldo = _saldo - cajero.costoEnvio;
      if (_saldo <= 0) _saldo = 0.0;

      promocionesAComprar =
          await DBProvider.db.listarPorAgencia(cajero.idAgencia);

      _compraDetalle.add('${cajero.sucursal}');

      for (var promocion in promocionesAComprar) {
        cajero.costo += promocion.costoTotal;
        _compraDetalle.add(
            '${promocion.cantidad} ${promocion.producto} ${promocion.costoTotal.toStringAsFixed(2)}');
      }
      _costoTotal = _costoTotal - cajero.descontado + cajero.costoPorcentaje(_isEfectivo);

      //Costo en esta linea importante
      _compraSucursal.add('${cajero.sucursal}');
      _compraCosto.add('${cajero.costo.toStringAsFixed(2)}');
      _compraEnvio.add('${cajero.costoEnvio.toStringAsFixed(2)}');

      rows.add(DataRow(cells: [
        DataCell(Text(cajero.sucursal)),
        DataCell(Text(cajero.isTarjeta == 0 ? '💵' : '💳 💵')),
        DataCell(Text(cajero.costoFormaPago(_isEfectivo).toStringAsFixed(2))),
        DataCell(Text('${cajero.costoEnvio.toStringAsFixed(2)}')),
      ]));

      _moneyDescontado = _moneyDescontado + cajero.descontado;
    }

    if (_moneyDescontado > 0) {
      rows.add(DataRow(
          onSelectChanged: (select) {
            return dlg.mostrar(context,
                'Se descuenta automáticamente para cubrir el costo o parte del costo de entrega.\n\nAl invitar a tus amigos a usar Mimo tienes mayor probabilidad de obtener money.\n\nVe al Menú, (Insignia & Money) para aprender más.',
                titulo: 'Mimo Money');
          },
          cells: [
            DataCell(Text('Mimo Money (Descuento exclusivo)')),
            DataCell(Text('')),
            DataCell(Text('')),
            DataCell(Text(
              '-${_moneyDescontado.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            )),
          ]));
    }

    if (_pay > 0) {
      rows.add(DataRow(
          onSelectChanged: (select) {
            return dlg.mostrar(context,
                'Tienes S/.${_pay.toStringAsFixed(2)} de Cash.\n\nEste dinero permite pagar productos y envío',
                titulo: 'Mimo Cash');
          },
          cells: [
            DataCell(Text('Mimo Cash')),
            DataCell(Text('')),
            DataCell(Text('')),
            DataCell(Text(
              '-${_pay.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            )),
          ]));
    }

    if (descuentoPorCupon > 0) {
      rows.add(DataRow(
          onSelectChanged: (select) {
            return dlg.mostrar(context, _cardBloc.cardSeleccionada.terminos);
          },
          cells: [
            DataCell(Text(
              _cardBloc.cardSeleccionada.number,
              style: TextStyle(color: Colors.deepPurple),
            )),
            DataCell(Text('')),
            DataCell(Text(
              _cardBloc.cardSeleccionada.holderName,
              style: TextStyle(color: Colors.deepPurple),
            )),
            DataCell(Text(
              '${_cardBloc.cardSeleccionada.cupon.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple),
            )),
          ]));
      _costoTotal = _costoTotal - descuentoPorCupon;
    }

    _costoTotal = _costoTotal - _pay;
    if (_costoTotal < 0) _costoTotal = 0.0;

    _costoMostrado = _costoTotal.toStringAsFixed(2);
    rows.add(DataRow(cells: [
      DataCell(Text('Total a pagar',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold))),
      DataCell(Text('')),
      DataCell(Text('')),
      DataCell(Text(
        '$_costoMostrado',
        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      )),
    ]));

    return rows;
  }

  Widget _table(List<CajeroModel> cajeros) {
    return FutureBuilder<List<DataRow>>(
      future: _costoProductos(cajeros),
      builder: (context, isAvailableSnapshot) {
        if (!isAvailableSnapshot.hasData) {
          return Container();
        }
        return DataTable(
            dividerThickness: 2.0,
            showCheckboxColumn: false,
            columnSpacing: 10.0,
            columns: [
              DataColumn(
                  label: Text("Local",
                      style: TextStyle(
                        color: prs.colorTextTitle,
                        fontSize: 15.0,
                      ))),
              DataColumn(
                  label: Text(
                    "Acepta",
                    style: TextStyle(
                      color: prs.colorTextTitle,
                      fontSize: 15.0,
                    ),
                  ),
                  numeric: true),
              DataColumn(
                  label: Text(
                    "Prod..",
                    style: TextStyle(
                      color: prs.colorTextTitle,
                      fontSize: 15.0,
                    ),
                  ),
                  numeric: true),
              DataColumn(
                  label: Text(
                    "Envío",
                    style: TextStyle(
                      color: prs.colorTextTitle,
                      fontSize: 15.0,
                    ),
                  ),
                  numeric: true),
            ],
            rows: isAvailableSnapshot.data);
      },
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Información de Pago',
          style: TextStyle(color: prs.colorGrisOscuro),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: prs.colorRojo,
          ),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, "catalogo2", (route) => false);
          },
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Center(
            child: Container(
          child: _body(),
          width: prs.anchoFormulario,
          decoration: BoxDecoration(color: Colors.white),
        )),
      ),
    );
  }

  _comprar() async{
    if (_valueMetodoPago > 3) {
      String source_id = "";
      String _deviceID = "";
      await FirebaseFirestore.instance
          .collection("cards")
          .where("idCliente", isEqualTo: _prefs.clienteModel.idCliente)
          .where("eliminado", isEqualTo: false)
          .where("seleccionado", isEqualTo: true)
          .get()
          .then(
        (value) {
          _deviceID = value.docs.first['device'];
          source_id = value.docs.first['token'];
        },
      );
      Map chargeTemp = await createCharge(
          source_id,
          total.roundToDouble(),
          _prefs.clienteModel.nombres,
          (_prefs.clienteModel.apellidos == null
              ? ""
              : _prefs.clienteModel.apellidos),
          _prefs.clienteModel.celular,
          _prefs.clienteModel.correo,
          _deviceID);
      
      if (chargeTemp['status']) {
        Map charge = jsonDecode(chargeTemp['body']) as Map;
        showFlash(
            context: context,
            duration: Duration(seconds: 3),
            builder: (context, controller) {
              return Flash(
                controller: controller,
                behavior: FlashBehavior.fixed,
                position: FlashPosition.top,
                boxShadows: kElevationToShadow[0],
                // horizontalDismissDirection: HorizontalDismissDirection.horizontal,
                backgroundColor: Color.fromRGBO(37, 217, 194, 1),
                // borderRadius: BorderRadius.only(topLeft: Radius.zero,topRight: Radius.zero,bottomLeft: Radius.circular(500),bottomRight: Radius.circular(500)),
                child: FlashBar(
                  content: Container(
                      constraints: BoxConstraints(minHeight: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_box_outlined,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            constraints: BoxConstraints(maxWidth: 250),
                            child: Text("Se realizo el cargo a su tarjeta con exito",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ],
                      )),
                ),
              );
            });
        final String codigo = _inputFieldDateController.text;
        _inputFieldDateController.text = '';
        if (codigo.length > 0)
          _canjer(codigo);
        else
          relizarCompra(_valueMetodoPago, charge['id']);
      } else {
        showFlash(
            context: context,
            duration: Duration(seconds: 3),
            builder: (context, controller) {
              return Flash(
                controller: controller,
                behavior: FlashBehavior.fixed,
                position: FlashPosition.top,
                boxShadows: kElevationToShadow[0],
                // horizontalDismissDirection: HorizontalDismissDirection.horizontal,
                backgroundColor: Color.fromARGB(255, 217, 37, 37),
                // borderRadius: BorderRadius.only(topLeft: Radius.zero,topRight: Radius.zero,bottomLeft: Radius.circular(500),bottomRight: Radius.circular(500)),
                child: FlashBar(
                  content: Container(
                      constraints: BoxConstraints(minHeight: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            constraints: BoxConstraints(maxWidth: 250),
                            child: Text("Se rechazo su tarjeta",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ],
                      )),
                ),
              );
            });
      }
    } else{
      final String codigo = _inputFieldDateController.text;
        _inputFieldDateController.text = '';
        if (codigo.length > 0)
          _canjer(codigo);
        else
          relizarCompra(_valueMetodoPago, "");
    }
    
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Visibility(
            visible: _isLineProgress,
            child: LinearProgressIndicator(
                backgroundColor: prs.colorLinearProgress)),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              child: Text(
                                '${_compraSucursal[0]}',
                                // '12',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontFamily: 'GoldplayBlack',
                                ),
                              ),
                            ),
                            Text('Tiempo de entrega',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontFamily: 'GoldeplayRegular',
                                )),
                            Text(total_tiempo_preparacion.toString()+" min.",
                                style: TextStyle(
                                    fontSize: 19,
                                    fontFamily: 'GoldeplayRegular',
                                    fontWeight: FontWeight.w700)),
                          ],
                        )
                      ],
                    )),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      Container(
                          margin: EdgeInsets.only(top: 15),
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                            border: Border.all(color: prs.colorGrisBordes),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text('Lugar de entrega',
                                      style: TextStyle(
                                          fontFamily: 'GoldplayRegular',
                                          fontSize: 17)),
                                  Expanded(child: Container()),
                                  //Icon(Icons.edit, color: prs.colorRojo)
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          color: prs.colorAmarillo,
                                          image: DecorationImage(
                                              image: AssetImage(
                                                'assets/png/mapa.png',
                                              ),
                                              fit: BoxFit.cover))),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${direccionSeleccionadaEntrega.alias}',
                                            style: TextStyle(fontSize: 17),
                                          ),
                                          Text(
                                              '${direccionSeleccionadaEntrega.referencia}',
                                              style: TextStyle(fontSize: 17))
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ))
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                            border: Border.all(color: prs.colorGrisBordes),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text('Forma de pago',
                                      style: TextStyle(
                                          fontFamily: 'GoldplayRegular',
                                          fontSize: 17)),
                                  Expanded(child: Container()),
                                  IconButton(
                                      onPressed: () {
                                        int _value = _valueMetodoPago;
                                        showModalBottomSheet(
                                            isScrollControlled: true,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(30),
                                                    topRight:
                                                        Radius.circular(30))),
                                            context: context,
                                            builder: (context) =>
                                                StatefulBuilder(builder:
                                                    (BuildContext context,
                                                        StateSetter
                                                            myStateMetodoPago) {
                                                  return Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 20,
                                                                  right: 20,
                                                                  bottom: 20,
                                                                  top: 5),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                height: 30,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    "Método de pago",
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          "GoldplayRegular",
                                                                      fontSize:
                                                                          17,
                                                                    ),
                                                                  ),
                                                                  GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        "Cancelar",
                                                                        style: TextStyle(
                                                                            color:
                                                                                prs.colorMorado,
                                                                            fontSize: 17),
                                                                      )),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 30,
                                                              ),
                                                              ListTile(
                                                                  leading:
                                                                      Image(
                                                                    height: 50,
                                                                    width: 50,
                                                                    image:
                                                                        AssetImage(
                                                                      "assets/png/efectivo.png",
                                                                    ),
                                                                  ),
                                                                  title:
                                                                      Text.rich(
                                                                    TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                              "Efectivo",
                                                                          style: TextStyle(
                                                                              fontFamily: "GoldplayRegular",
                                                                              fontWeight: FontWeight.w600,
                                                                              fontSize: 17),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  trailing: Radio(
                                                                      value: 1,
                                                                      groupValue: _value,
                                                                      onChanged: (value) {
                                                                        myStateMetodoPago(
                                                                            () {
                                                                          _value =
                                                                              value;
                                                                        });
                                                                      })
                                                                  // trailing: Container(decoration: BoxDecoration(border: Border.all(color:prs.colorGrisBordes )),)
                                                                  ),
                                                              Divider(
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                              ListTile(
                                                                  leading:
                                                                      Image(
                                                                    height: 50,
                                                                    width: 50,
                                                                    image:
                                                                        AssetImage(
                                                                      "assets/png/yape.png",
                                                                    ),
                                                                  ),
                                                                  title:
                                                                      Text.rich(
                                                                    TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                              "Yape",
                                                                          style: TextStyle(
                                                                              fontFamily: "GoldplayRegular",
                                                                              fontWeight: FontWeight.w600,
                                                                              fontSize: 17),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  trailing: Radio(
                                                                      value: 2,
                                                                      groupValue: _value,
                                                                      onChanged: (value) {
                                                                        myStateMetodoPago(
                                                                            () {
                                                                          _value =
                                                                              value;
                                                                        });
                                                                      })
                                                                  // trailing: Container(decoration: BoxDecoration(border: Border.all(color:prs.colorGrisBordes )),)
                                                                  ),
                                                              Divider(
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                              ListTile(
                                                                  leading:
                                                                      Image(
                                                                    height: 50,
                                                                    width: 50,
                                                                    image:
                                                                        AssetImage(
                                                                      "assets/png/plin.png",
                                                                    ),
                                                                  ),
                                                                  title:
                                                                      Text.rich(
                                                                    TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                              "Plin",
                                                                          style: TextStyle(
                                                                              fontFamily: "GoldplayRegular",
                                                                              fontWeight: FontWeight.w600,
                                                                              fontSize: 17),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  trailing: Radio(
                                                                      value: 3,
                                                                      groupValue: _value,
                                                                      onChanged: (value) {
                                                                        myStateMetodoPago(
                                                                            () {
                                                                          _value =
                                                                              value;
                                                                        });
                                                                      })
                                                                  // trailing: Container(decoration: BoxDecoration(border: Border.all(color:prs.colorGrisBordes )),)
                                                                  ),
                                                              Divider(
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                              if (tarjetas
                                                                      .length !=
                                                                  0)
                                                                ListTile(
                                                                    leading:
                                                                        Image(
                                                                      height:
                                                                          50,
                                                                      width: 50,
                                                                      image:
                                                                          AssetImage(
                                                                        "assets/png/tarjetadecredito.png",
                                                                      ),
                                                                    ),
                                                                    // title: Text
                                                                    //     .rich(
                                                                    //   TextSpan(
                                                                    //     children: [
                                                                    //       TextSpan(
                                                                    //         text:
                                                                    //             "Débito •••• •••• ••••",
                                                                    //         style: TextStyle(
                                                                    //             fontFamily: "GoldplayRegular",
                                                                    //             fontWeight: FontWeight.w600,
                                                                    //             fontSize: 17),
                                                                    //       ),
                                                                    //       TextSpan(
                                                                    //         text:
                                                                    //             misTarjetas[0]['tarjeta'],
                                                                    //         style: TextStyle(
                                                                    //             fontFamily: "GoldplayRegular",
                                                                    //             fontWeight: FontWeight.w600,
                                                                    //             fontSize: 17),
                                                                    //       ),
                                                                    //     ],
                                                                    //   ),
                                                                    // ),
                                                                    title:
                                                                        Text.rich(
                                                                      TextSpan(
                                                                        children: [
                                                                          TextSpan(
                                                                            text:
                                                                                misTarjetas[0]['alias'],
                                                                            style: TextStyle(
                                                                                fontFamily: "GoldplayRegular",
                                                                                fontWeight: FontWeight.w600,
                                                                                fontSize: 17),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    trailing: Radio(
                                                                        value: 4,
                                                                        groupValue: _value,
                                                                        onChanged: (value) {
                                                                          myStateMetodoPago(
                                                                              () {
                                                                            _value =
                                                                                value;
                                                                          });
                                                                        })
                                                                    // trailing: Container(decoration: BoxDecoration(border: Border.all(color:prs.colorGrisBordes )),)
                                                                    ),
                                                              SizedBox(
                                                                height: 20,
                                                              ),
                                                              SizedBox(
                                                                width: double
                                                                    .infinity,
                                                                child:
                                                                    ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      if (_value ==  0) {
                                                                        return null;
                                                                      } else {
                                                                        if (_value ==1) {
                                                                          metodopago = "Efectivo";
                                                                        }
                                                                        if (_value == 2) {
                                                                          metodopago ="Yape";
                                                                        }
                                                                        if (_value == 3) {
                                                                          metodopago = "Plin";
                                                                        }
                                                                        if (_value == 4) {
                                                                          metodopago = "Debito";
                                                                        }
                                                                        _valueMetodoPago =
                                                                            _value;
                                                                        myStateMetodoPago(
                                                                            () {});
                                                                        Navigator.pop(
                                                                            context);
                                                                      }
                                                                    });
                                                                  },
                                                                  child: Text(
                                                                    "Confirmar",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                  style: ElevatedButton.styleFrom(
                                                                      shape:
                                                                          StadiumBorder(),
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              20),
                                                                      backgroundColor: _value == 0
                                                                          ? Colors
                                                                              .grey
                                                                              .shade400
                                                                          : prs
                                                                              .colorMorado,
                                                                      foregroundColor:
                                                                          prs.colorMorado),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ]);
                                                }));
                                      },
                                      icon: Icon(Icons.edit,
                                          color: prs.colorRojo))
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  if (metodopago == 'Debito')
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          // color: prs.hexToColor('#1746A2'),

                                          image: DecorationImage(
                                              image: AssetImage(
                                                'assets/png/tarjetadecredito.png',
                                              ),
                                              fit: BoxFit.cover)),
                                    )
                                  else if (metodopago == 'Efectivo')
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          // color: prs.hexToColor('#1746A2'),

                                          image: DecorationImage(
                                              image: AssetImage(
                                                'assets/png/efectivo.png',
                                              ),
                                              fit: BoxFit.cover)),
                                    )
                                  else if (metodopago == 'Yape')
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          // color: prs.hexToColor('#1746A2'),

                                          image: DecorationImage(
                                              image: AssetImage(
                                                'assets/png/yape.png',
                                              ),
                                              fit: BoxFit.cover)),
                                    )
                                  else if (metodopago == 'Plin')
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          // color: prs.hexToColor('#1746A2'),

                                          image: DecorationImage(
                                              image: AssetImage(
                                                'assets/png/plin.png',
                                              ),
                                              fit: BoxFit.cover)),
                                    )
                                  else
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          // color: prs.hexToColor('#1746A2'),

                                          image: DecorationImage(
                                              image: AssetImage(
                                                'assets/png/tarjetadecredito.png',
                                              ),
                                              fit: BoxFit.cover)),
                                    ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        if (metodopago == 'Debito')
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: 
                                                Text(
                                            tarjetas[0]
                                                              ['alias'],
                                                              textAlign: TextAlign.center,
                                            style: TextStyle(
                                                              fontFamily:
                                                                  "GoldplayRegular",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 17),
                                          )
                                                
                                              ),
                                            ],
                                          )
                                        else if (metodopago == 'Efectivo')
                                          Text(
                                            "Pago con Efectivo",
                                            style: TextStyle(
                                                fontFamily: "GoldplayRegular",
                                                fontWeight: FontWeight.w600,
                                                fontSize: 17),
                                          )
                                        else if (metodopago == 'Yape')
                                          Text(
                                            "Pago con Yape",
                                            style: TextStyle(
                                                fontFamily: "GoldplayRegular",
                                                fontWeight: FontWeight.w600,
                                                fontSize: 17),
                                          )
                                        else if (metodopago == 'Plin')
                                          Text(
                                            "Pago con Plin",
                                            style: TextStyle(
                                                fontFamily: "GoldplayRegular",
                                                fontWeight: FontWeight.w600,
                                                fontSize: 17),
                                          )
                                        else
                                          Text(
                                            "Seleccione una forma de pago",
                                            style: TextStyle(
                                                fontFamily: "GoldplayRegular",
                                                fontWeight: FontWeight.w600,
                                                fontSize: 17),
                                          ),
                                        if (metodopago == 'Debito')
                                          if (tarjetas.length != 0)
                                            Text(tarjetas[0]['propietario'],
                                                style: TextStyle(
                                                  fontSize: 17,
                                                ))
                                          else
                                            Text('',
                                                style: TextStyle(
                                                  fontSize: 17,
                                                ))
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              // SizedBox(
                              //   height: 30,
                              // ),
                              // GestureDetector(
                              //   onTap: () => showModalBottomSheet(
                              //       isScrollControlled: true,
                              //       shape: RoundedRectangleBorder(
                              //           borderRadius: BorderRadius.only(
                              //               topLeft: Radius.circular(30),
                              //               topRight: Radius.circular(30))),
                              //       context: context,
                              //       builder: (context) => agregarCupon()),
                              //   child: Container(
                              //     width: double.infinity,
                              //     alignment: AlignmentDirectional.center,
                              //     child: Row(
                              //       mainAxisAlignment: MainAxisAlignment.center,
                              //       children: [
                              //         Icon(
                              //           FontAwesomeIcons.ticket,
                              //           color: prs.colorRojo,
                              //         ),
                              //         SizedBox(
                              //           width: 5,
                              //         ),
                              //         Text(
                              //           'Agregar cupón',
                              //           style: TextStyle(color: prs.colorRojo),
                              //         )
                              //       ],
                              //     ),
                              //   ),
                              // )
                            ],
                          ))
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                            border: Border.all(color: prs.colorGrisBordes),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text('Propina',
                                      style: TextStyle(
                                          fontFamily: 'GoldplayRegular',
                                          fontSize: 17)),
                                  Expanded(child: Container()),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                        'Entrega Directa',
                                        style: TextStyle(
                                            fontFamily: 'GoldplayRegular',
                                            fontSize: 15,
                                            color: prs.colorGrisClaro)),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              
                              Row(
                                children: [
                                  Expanded(
                                  child: SingleChildScrollView(
                                      physics: BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          switchs
                                              ? GestureDetector(
                                                  // onTap: accionSwitch(false,0.0),
                                                  onTap: () {
                                                    if (mounted)
                                                      setState(() {
                                                        switchs = false;
                                                        switchs1 = true;
                                                        switchs2 = true;
                                                        switchotro = true;
                                                        propina = 0.0;
                                                        // total = envio +
                                                        //     propina +
                                                        //     widget.costoTotal;
                                                            total = envio +
                                                            widget.costoTotal;
                                                      });
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: prs
                                                            .colorGrisAreaTexto,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50)),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 30,
                                                            vertical: 10),
                                                    child: Text(
                                                      'Sin propina',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'GoldplayRegular',
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : GestureDetector(
                                                  onTap: () {
                                                    if (mounted)
                                                      setState(() {
                                                        switchs = true;
                                                        propina = 0.0;
                                                        total = envio +
                                                            widget.costoTotal;
                                                      });
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: prs.colorRojo,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50)),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 30,
                                                            vertical: 10),
                                                    child: Text(
                                                      'Sin propina',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'GoldplayRegular',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                          switchs1
                                              ? GestureDetector(
                                                  onTap: () {
                                                    if (mounted)
                                                      setState(() {
                                                        switchs1 = false;
                                                        switchs = true;
                                                        switchs2 = true;
                                                        switchotro = true;
                                                        propina = 1.0;
                                                        total = envio +
                                                            widget.costoTotal;
                                                      });
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 20),
                                                    decoration: BoxDecoration(
                                                        color: prs
                                                            .colorGrisAreaTexto,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50)),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 30,
                                                            vertical: 10),
                                                    child: Text(
                                                      'S/1',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'GoldplayRegular',
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : GestureDetector(
                                                  onTap: () {
                                                    if (mounted)
                                                      setState(() {
                                                        switchs1 = true;
                                                        propina = 0.0;
                                                        total = envio +
                                                            widget.costoTotal;
                                                      });
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 20),
                                                    decoration: BoxDecoration(
                                                        color: prs.colorRojo,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50)),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 30,
                                                            vertical: 10),
                                                    child: Text(
                                                      'S/1',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'GoldplayRegular',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                          switchs2
                                              ? GestureDetector(
                                                  onTap: () {
                                                    if (mounted)
                                                      setState(() {
                                                        switchs2 = false;
                                                        switchs = true;
                                                        switchs1 = true;
                                                        switchotro = true;
                                                        propina = 2.0;
                                                        total = envio +
                                                            widget.costoTotal;
                                                      });
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 20),
                                                    decoration: BoxDecoration(
                                                        color: prs
                                                            .colorGrisAreaTexto,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50)),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 30,
                                                            vertical: 10),
                                                    child: Text(
                                                      'S/2',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'GoldplayRegular',
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : GestureDetector(
                                                  onTap: () {
                                                    if (mounted)
                                                      setState(() {
                                                        switchs2 = true;
                                                        propina = 0.0;
                                                        total = envio +
                                                            widget.costoTotal;
                                                      });
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 20),
                                                    decoration: BoxDecoration(
                                                        color: prs.colorRojo,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50)),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 30,
                                                            vertical: 10),
                                                    child: Text(
                                                      'S/2',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'GoldplayRegular',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                          switchotro
                                              ? GestureDetector(
                                                  onTap: () =>
                                                      showModalBottomSheet(
                                                    isScrollControlled: true,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        30),
                                                                topRight: Radius
                                                                    .circular(
                                                                        30))),
                                                    context: context,
                                                    builder: (context) =>
                                                        agregarPropina(),
                                                  ),
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 20),
                                                    decoration: BoxDecoration(
                                                        color: prs
                                                            .colorGrisAreaTexto,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50)),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 30,
                                                            vertical: 10),
                                                    child: Text(
                                                      'Otros',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'GoldplayRegular',
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : GestureDetector(
                                                  onTap: () {
                                                    if (mounted)
                                                      setState(() {
                                                        switchotro = true;
                                                        propina = 0.0;
                                                        total = envio +
                                                            widget.costoTotal;
                                                      });
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 20),
                                                    decoration: BoxDecoration(
                                                        color: prs.colorRojo,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50)),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 30,
                                                            vertical: 10),
                                                    child: Text(
                                                      'Otros',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'GoldplayRegular',
                                                      ),
                                                    ),
                                                  ),
                                                )
                                        ],
                                      )),
                                ),
                              
                                ],
                              )
                            
                            ],
                          ))
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Resumen',
                            style: TextStyle(
                                fontFamily: 'GoldplayRegular',
                                fontSize: 17,
                                fontWeight: FontWeight.w700),
                          ),
                          Expanded(child: Container())
                        ],
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
                          Text('S/.${costoTotal.toStringAsFixed(2)}',
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
                          Text('S/.${costoEnvio.toStringAsFixed(2)}',
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
                          Text('S/.${propina}',
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
                          Text('S/.${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontFamily: 'GoldplayBlack',
                                  fontSize: 16,
                                  color: prs.colorRojo))
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        btn.confirmar('Hacer pedido (S/.${total.toStringAsFixed(2)})',
            !_isLineProgress && _valueMetodoPago != 0 ? _comprar : null)
      ],
    );
  }

  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final GlobalKey<FormState> _formKeyOTP = GlobalKey<FormState>();
  String _otp = '';

  Widget _crearOTP() {
    return TextFormField(
      maxLength: 6,
      autofocus: true,
      textCapitalization: TextCapitalization.characters,
      decoration: prs.decoration('Código OTP', null),
      onSaved: (value) => _otp = value,
      validator: val.validarMinimo3,
    );
  }

  void _verificarTarjeta(dynamic idTransaccion) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(10.0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20.0),
                Text(
                    'Ingresa el código de seguridad OTP que tu banco debió enviarte'),
                SizedBox(height: 10.0),
                Form(
                  key: _formKeyOTP,
                  child: _crearOTP(),
                ),
                SizedBox(height: 15.0),
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
                label: Text('VERIFICAR'),
                icon: Icon(
                  FontAwesomeIcons.handHoldingHeart,
                  size: 18.0,
                ),
                onPressed: () async {
                  if (!_formKeyOTP.currentState.validate()) return;
                  FocusScope.of(context).requestFocus(FocusNode());
                  _formKeyOTP.currentState.save();
                  Navigator.of(context).pop();
                  _saving = true;
                  if (mounted) setState(() {});
                  await _cardProvider.autorizar(_cardBloc.cardSeleccionada,
                      _otp, idTransaccion, _evaluar);
                },
              ),
            ],
          );
        });
  }

  _evaluar(status, idTransaccion, mensaje) async {
    _saving = false;
    if (mounted) setState(() {});
    if (status == Sistema.IS_ACREDITADO) {
      

      //Cuanod no es validado el celular pero es de tipo tarjeta enviamos a cervidor el celular ingresado por el cliente
      if (_prefs.clienteModel.celularValidado != 1) {
        _clienteProvider.validadCelular(_celular);
      }

      _agregarCreditoYConfirmarRelaizarCompra(idTransaccion);
    } else if (status == Sistema.IS_TOKEN) {
      
      _verificarTarjeta(idTransaccion);
    } else {
      dlg.mostrar(context, mensaje);
    }
  }

  _agregarCreditoYConfirmarRelaizarCompra(String idCash) {
    for (CajeroModel cajero in cajeros) {
      cajero.cash = cajero
          .total(); //Todo el pago se realiza con cash pues la forma de pago de credito cubre todo.
      cajero.credito = cajero.total();
      cajero.creditoEnvio = cajero.costoEnvio;
      cajero.creditoProducto = cajero.costo;
      cajero.idCash = idCash;
    }
    _confirmarRelizarCompra(_valueMetodoPago, "");
  }

  relizarCompra(int typePayment, String chargeId) async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (_cardBloc.cardSeleccionada.isTarjeta()) {
      if (!_formKey.currentState.validate()) {
        return;
      }
      _update();
      String costofinal = total.toStringAsFixed(2);
      double _costo = double.parse(costofinal);
      double _regalo = 0.0;
      for (CajeroModel cajero in cajeros) {
        if (cajero.idAgencia == promocionIdAgencia) {
          _regalo =
              promocionValor; //El valor del money no se suma por que el valor q se muestra ya lo resta
          if (_regalo > cajero.costoEnvio) _regalo = cajero.costoEnvio;
          _costo = _costo - _regalo + cajero.descontado;
        }
      }

      if (_costo <= 0) _costo = 0.0;
      await _cardProvider.debitar(
          _cardBloc.cardSeleccionada,
          _costo.toStringAsFixed(2),
          _pay.toStringAsFixed(2),
          _compraSucursal,
          _compraCosto,
          _compraEnvio,
          _compraDetalle,
          _evaluar);
    } else {
      _confirmarRelizarCompra(typePayment, chargeId);
    }
  }

  _agregarDescuentosYconfirmarCompra(int typePayment, String chargeId) {
    //Asignamos cash en cero para no evaluar en el bucle el credito peusto  esto se hace un recargo al final total con l a tarjeta
    double _auxCash = _cardBloc.cardSeleccionada.isTarjeta() ? 0.0 : _pay;
    int indicador = 0;
    for (CajeroModel cajero in cajeros) {
      if (cajero.idAgencia == promocionIdAgencia) {
        cajero.idHashtag = promocionIdHashtag;
        cajero.descuento = promocionValor;
      }
      if (_auxCash > 0) {
        double _usoCash =
            _auxCash >= cajero.total() ? cajero.total() : _auxCash;
        _auxCash = _auxCash - _usoCash;
        _usoCash = _usoCash - cajero.credito - cajero.descontado;
        if (_usoCash < 0) _usoCash = 0.0;
        cajero.cash = _usoCash;
        cajero.credito = _usoCash;
        //Este no necesita validacion por que ya se controla q el credito sea cero y no menor de cero
        cajero.creditoEnvio = cajero.credito >= cajero.costoEnvio
            ? cajero.costoEnvio
            : cajero.credito;
        //En este punto costo mantiene el costo del producto y total es la suma del costo mas envio credito seria lo mismo
        cajero.creditoProducto = cajero.credito >= cajero.total()
            ? cajero.costo
            : cajero.credito - cajero.costoEnvio;
        if (cajero.creditoProducto < 0) cajero.creditoProducto = 0.0;
      }
      
      cajero.costoEnvio = costoEnvio;
      _confirmar(cajero, direccionSeleccionadaEntrega, typePayment,chargeId);
      indicador++;
      
    }
  }

  _confirmarRelizarCompra(int typePayment, String chargeId) {
/*     if (_prefs.clienteModel.celularValidado == 1 ||
        _cardBloc.cardSeleccionada.isTarjeta()) {
         */
      _agregarDescuentosYconfirmarCompra(typePayment,chargeId);
/*     } else {
      _accionCelularVerificado() {
        _agregarDescuentosYconfirmarCompra();
      }
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  VerificarCelularPage(_accionCelularVerificado)));
    } */
  }

  _update() {
    _saving = true;
    if (mounted) if (mounted) setState(() {});
  }

  _complet() {
    _saving = false;
    if (mounted) if (mounted) setState(() {});
  }

  _confirmar(CajeroModel cajeroModel, DireccionModel direccionEntrega, int typePayment, String chargeId) async {
    
    _update();
    double costo = 0.0;
    List<PromocionModel> promocionesAComprar;
    //La promocion viende desde serviicois help
    if (promocion == null) {
      promocionesAComprar = await DBProvider.db.listarPorAgencia(cajeroModel.idAgencia);
    } else {
      promocionesAComprar = [];
      promocionesAComprar.add(promocion);
    }

    promocionesAComprar.forEach((PromocionModel promocion) {
      costo += promocion.costoTotal;
    });
    _cardBloc.cardSeleccionada = CardModel();
    
    compraProvider.iniciar(tipo, cajeroModel.idCajero, cajeroModel.idSucursal,
        direccionSeleccionadaEntrega, cajeroModel.costoEnvio.toStringAsFixed(2),typePayment, chargeId,
        (estado, mensaje, CajeroModel nuevoCajeroModel) {
          
            if (estado == -100) {
        _complet();
        if (mounted) dlg.mostrar(context, mensaje);
        return;
      }
      if (estado <= 0) {
        _fAceptar() {
          _complet();
          if (_prefs.clienteModel.perfil.toString() ==
              config.TIPO_CLIENTE.toString()) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => CatalogoPage()),
                (Route<dynamic> route) {
              return false;
            });
          } else if (_prefs.clienteModel.perfil.toString() ==
              config.TIPO_ASESOR.toString()) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => ComprasCajeroPage()),
                (Route<dynamic> route) {
              return false;
            });
          } else {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => ComprasDespachoPage()),
                (Route<dynamic> route) {
              return false;
            });
          }
        }

        return dlg.mostrar(context, mensaje,
            fIzquierda: _fAceptar,
            mIzquierda: 'CANCELAR',
            mBotonDerecha: 'COMPRAR',
            color: prs.colorButtonSecondary,
            icon: Icons.monetization_on);
      }
      _limpiarCarrito();
      _verDespacho(nuevoCajeroModel);
    },
        cajero: cajeroModel,
        direccionCliente: direccionSeleccionadaCliente,
        facturaModel: _facturaBloc.facturaSeleccionada,
        promociones: promocionesAComprar,
        costoTotal: total,
        costo: costo,
        tiempo_preparacion: total_tiempo_preparacion,
        propina: propina);
  }

  _verDespacho(CajeroModel cajeroModel) {
    String mensaje = 'Solicitud confirmada';
    compra.despachoPage(context, cajeroModel, mensaje, config.TIPO_CLIENTE);
  }

  _limpiarCarrito() async {
    for (var i = 0; i < _promocionBloc.promociones.length; i++) {
      if (_promocionBloc.promociones[i].isComprada) {
        _promocionBloc.promociones[i].isComprada = false;
        _promocionBloc.actualizar(_promocionBloc.promociones[i]);
      }
    }

    for (var i = 0; i < _catalogoBloc.promociones.length; i++) {
      if (_catalogoBloc.promociones[i].isComprada) {
        _catalogoBloc.promociones[i].isComprada = false;
        _catalogoBloc.actualizar(_catalogoBloc.promociones[i]);
      }
    }

    await DBProvider.db.eliminarPromocionPorUrbe(direccionSeleccionadaEntrega.idUrbe);
    _promocionBloc.carrito();
    _cajeroBloc.listarEnCamino();
  }

  /* Widget _facturas(BuildContext context) {
    return StreamBuilder(
      stream: _facturaBloc.facturaStream,
      builder:
          (BuildContext context, AsyncSnapshot<List<FacturaModel>> snapshot) {
        if (snapshot.hasData) {
          return createExpanPanel(snapshot.data);
        } else {
          return Container(child: Center(child: CircularProgressIndicator()));
        }
      },
    );
  } */

  /* Widget createExpanPanel(List<FacturaModel> facturas) {
    return DropdownButtonFormField(
      isDense: true,
      decoration: prs.decoration('', prs.iconoFactura),
      validator: (value) {
        if (_facturaBloc.facturaSeleccionada.idFactura <= 0)
          return 'Datos de factura';
        return null;
      },
      hint: (_facturaBloc.facturaSeleccionada.idFactura <= 0)
          ? Text('Datos de factura')
          : Text(_facturaBloc.facturaSeleccionada.dni),
      items: facturas.map((FacturaModel factura) {
        if (factura.idFactura <= 0)
          return DropdownMenuItem<FacturaModel>(
            value: factura,
            child: Text('Datos de factura'),
          );
        return DropdownMenuItem<FacturaModel>(
          value: factura,
          child: Text('Facturar a: ${factura.dni}'),
        );
      }).toList(),
      onChanged: (FacturaModel value) {
        _facturaBloc.facturaSeleccionada = value;
        if (value.idFactura <= 0)
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return FacturaDialog(facturaModel: value);
              });
      },
    );
  }
 */
  accionSwitch(bool state, double val) {
    // if (mounted)
    setState(() {
      switchs = state;
      propina = val;
    });
  }

  Widget agregarPropina() => Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'MONTO PERSONALIZADO',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: prs.colorGrisOscuro),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                'Monto mínimo S/1 - monto máximo S/30 ',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16, color: prs.colorGrisClaro),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: propinaText,
                maxLength: 30,
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.number,
                decoration: prs.decoration('Propina', prs.iconoCodigo),
              ),
              SizedBox(
                height: 30,
              ),
              btn.bootonContinuar('Añadir monto', () {
                setState(() {
                  switchotro = false;
                  switchs = true;
                  switchs1 = true;
                  switchs2 = true;
                  propina = double.parse(propinaText.text);
                  total = envio + widget.costoTotal;
                });
                Navigator.pop(context);
              })
            ],
          ),
        ),
      ]);
}