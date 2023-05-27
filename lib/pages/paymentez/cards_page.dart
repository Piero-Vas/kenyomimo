import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mimo/pages/paymentez/agregar_tarjeta.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../bloc/card_bloc.dart';
import '../../card/card_card.dart';
import '../../card/shimmer_card.dart';
import '../../model/card_model.dart';
import '../../model/catalogo_model.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/card_provider.dart';
import '../../providers/catalogo_provider.dart';
import '../../sistema.dart';
import '../../utils/button.dart' as btn;
import '../../utils/cache.dart' as cache;
import '../../utils/dialog.dart' as dlg;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../utils/validar.dart' as val;
import '../delivery/menu_page.dart';
import 'card_page.dart';
final _prefs = PreferenciasUsuario();
class CardsPage extends StatefulWidget {
  final bool isMenu;
  final String title;
  final String idAgencia;
  final String agencia;
  final String img;

  final String monto;
  final String motivo;

  CardsPage(
      {this.idAgencia: '0',
      this.img,
      this.isMenu: false,
      this.title: '',
      this.agencia: '',
      this.monto: '',
      this.motivo: ''})
      : super();

  @override
  _CardsPageState createState() => _CardsPageState();
}
 var id = _prefs.clienteModel.idCliente;
class _CardsPageState extends State<CardsPage> {
  int _value = -1;
  List<dynamic> misTarjetas = [];
  List<dynamic> tarjetas = [];
  

  Future getAllCards() async {
    return FirebaseFirestore.instance
        .collection("cards")
        .where("idCliente", isEqualTo: id.toString())
        .where("eliminado", isEqualTo: false)
        .snapshots()
        .listen((QuerySnapshot<Map<String, dynamic>> result) async {
      misTarjetas.clear();
      misTarjetas.addAll(result.docs);
      if (mounted) {
        setState(() {
          tarjetas = misTarjetas;
        });
      }
      int i = 0;
      _value = -1; 
      for(var tarjeta in tarjetas){
        if(tarjeta['seleccionado']) _value = i;
        i++;
      }
    });
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CardBloc _cardBloc = CardBloc();
  TextEditingController _textControllerMonto;
  TextEditingController _textControllerMotivo;
  String img;
  bool _saving = false;

  _CardsPageState();

  @override
  void initState() {
    _textControllerMonto = TextEditingController(text: widget.monto);
    _textControllerMotivo = TextEditingController(text: widget.motivo);
    img = cache.img(widget.img);
    _cardBloc.listar(widget.idAgencia);
    getAllCards();
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        /* title: Text('${widget.idAgencia == '0' ? '' : 'Pay '}${widget.title}'), */
        leading: utils.leading(context),
        elevation: 0,
        // actions: [
        //   Visibility(
        //     visible: widget.idAgencia == '0',
        //     child: IconButton(
        //       icon: prs.iconoObsequio,
        //        onPressed: _canjearRegalo,
        //     ),
        //   ),
        // ],
      ),
      key: _scaffoldKey,
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: utils.progressIndicator('Cargando...'),
        inAsyncCall: _saving,
        child: Container( child: _contenido(),padding: EdgeInsets.all(20), width: prs.anchoFormulario,decoration: BoxDecoration(color: Colors.white),),
      ),
    );
  }

  void _canjearRegalo() {
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
                Text('${Sistema.aplicativo} GIFT'),
                SizedBox(height: 10.0),
                Form(
                  key: _formKeyGIFT,
                  child: _crearNombres(),
                ),
                SizedBox(height: 15.0),
                Text('Aplican términos y condiciones.',
                    style: TextStyle(fontSize: 12.0),
                    textAlign: TextAlign.justify),
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
                label: Text('CANJEAR'),
                icon: Icon(
                  FontAwesomeIcons.handHoldingHeart,
                  size: 18.0,
                ),
                onPressed: _canejar,
              ),
            ],
          );
        });
  }

  _canejar() async {
    if (!_formKeyGIFT.currentState.validate()) return;
    FocusScope.of(context).requestFocus(FocusNode());
    _formKeyGIFT.currentState.save();
    Navigator.of(context).pop();
    _saving = true;
    if (mounted) setState(() {});
    await _cardBloc.canejar(_codigo, _analizarRespuesta);
  }

  _analizarRespuesta(estado, String mensaje, CardModel cardModel) {
    _saving = false;
    if (mounted) setState(() {});
    if (estado == 1) {
      fBotonIDerecha() {
        _cardBloc.actualizar(cardModel);
        Navigator.pop(context);
        _irAmenu(cardModel.idAgencia.toString());
      }

      dlg.mostrar(context, mensaje,
          mIzquierda: 'CANCELAR',
          mBotonDerecha: 'VER MENU',
          color: prs.colorButtonSecondary,
          icon: FontAwesomeIcons.store,
          fBotonIDerecha: fBotonIDerecha);
    } else {
      dlg.mostrar(context, mensaje);
    }
  }

  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final GlobalKey<FormState> _formKeyGIFT = GlobalKey<FormState>();
  String _codigo = '';

  Widget _crearNombres() {
    return TextFormField(
      maxLength: 90,
      autofocus: true,
      textCapitalization: TextCapitalization.characters,
      decoration: prs.decoration('Código GIFT', null),
      onSaved: (value) => _codigo = value,
      validator: val.validarMinimo8,
    );
  }

  final int estadoTarjetaProximamente = 0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String montoAtrasferir = '0';

  Widget _body() {
    return Column(
      children: <Widget>[
        _contenido(),
      ],
    );
  }

  Widget _contenido() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          prs.titulo('MÉTODOS DE PAGO'),
          prs.subTitulo('Establece como predeterminado, añade o elimina algún metodo de pago.'),
          // _prefs.isExplorar || _prefs.isDemo
          //     ? Container()
          //     : btn.bootonContinuar('+ Añadir nueva método',
          //         () {
          //         // if (_prefs.estadoTc == estadoTarjetaProximamente)
          //         //   return dlg.mostrar(context, _prefs.mensajeTc);
          //         showDialog(
          //             barrierDismissible: false,
          //             context: context,
          //             builder: (context) {
          //               // return CardPage(widget.idAgencia, _verificarTarjeta);
          //               return AgregarTarjetaDelivery();
          //             });
          //       }),

          tarjetas.length>2 ? SizedBox() : SizedBox(
          height: 20,
        ),
        tarjetas.length>2 ? SizedBox(): btn.bootonContinuar('+ Añadir nueva método', () {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AgregarTarjetaDelivery();
             });
}),


          SizedBox(height: 20,),
          // Efectivo Primera Version
          // _listaCar(),
          SizedBox(
            height: 20,
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: prs.colorGrisBordes),
                borderRadius: BorderRadius.circular(20)),
            child: ListTile(
                leading: Image(
                  height: 50,
                  width: 50,
                  image: AssetImage(
                    "assets/png/efectivo.png",
                  ),
                ),
                title: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Efectivo",
                        style: TextStyle(
                            fontFamily: "GoldplayRegular",
                            fontWeight: FontWeight.w600,
                            fontSize: 17),
                      ),
                    ],
                  ),
                ),
                // trailing: Radio(
                //     value: 1,
                //     groupValue: _value,
                //     onChanged: (value) {
                //       setState(() {
                //         _value = value;
                //       });
                //       confirmar(1);
                //     })
                // trailing: Container(decoration: BoxDecoration(border: Border.all(color:prs.colorGrisBordes )),)
                ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: prs.colorGrisBordes),
                borderRadius: BorderRadius.circular(20)),
            child: ListTile(
                leading: Image(
                  height: 50,
                  width: 50,
                  image: AssetImage(
                    "assets/png/yape.png",
                  ),
                ),
                title: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Yape",
                        style: TextStyle(
                            fontFamily: "GoldplayRegular",
                            fontWeight: FontWeight.w600,
                            fontSize: 17),
                      ),
                    ],
                  ),
                ),
                // trailing: Radio(
                //     value: 2,
                //     groupValue: _value,
                //     onChanged: (value) {
                //       setState(() {
                //         _value = value;
                //       });
                //       confirmar(2);
                //     })
                // trailing: Container(decoration: BoxDecoration(border: Border.all(color:prs.colorGrisBordes )),)
                ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: prs.colorGrisBordes),
                borderRadius: BorderRadius.circular(20)),
            child: ListTile(
                leading: Image(
                  height: 50,
                  width: 50,
                  image: AssetImage(
                    "assets/png/plin.png",
                  ),
                ),
                title: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Plin",
                        style: TextStyle(
                            fontFamily: "GoldplayRegular",
                            fontWeight: FontWeight.w600,
                            fontSize: 17),
                      ),
                    ],
                  ),
                ),
                // trailing: Radio(
                //     value: 3,
                //     groupValue: _value,
                //     onChanged: (value) {
                //       setState(() {
                //         _value = value;
                //       });
                //       confirmar(3);
                //     })
                // trailing: Container(decoration: BoxDecoration(border: Border.all(color:prs.colorGrisBordes )),)
                ),
          ),
          SizedBox(
            height: 15,
          ),
          SlidableAutoCloseBehavior(
             closeWhenOpened: true,
            child: ListView.builder(
            shrinkWrap: true,
            // physics: BouncingScrollPhysics(),
            itemCount: tarjetas.length,
            itemBuilder: (context, i) {
            return Slidable(
              startActionPane: ActionPane(
                    motion: StretchMotion(),
                    children: [
                      SlidableAction(
                        backgroundColor: prs.colorRojo,
                        icon: Icons.delete,
                        label: 'Eliminar',
                        onPressed: (context) async{
                          DocumentSnapshot documentSnapshot = tarjetas[i];
                          await FirebaseFirestore.instance.collection("cards").doc(documentSnapshot.id).update({"eliminado":true});
                        })
                    ],
                  ),
              child: Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                  border: Border.all(color: prs.colorGrisBordes),
                  borderRadius: BorderRadius.circular(20)),
                child: ListTile(
                    leading: Image(
                      height: 50,
                      width: 50,
                      image: AssetImage(
                        "assets/png/tarjetadecredito.png",
                      ),
                    ),
                    // title: 
                    // Text.rich(
                    //   TextSpan(
                    //     children: [
                    //       TextSpan(
                    //         text: "Débito •••• •••• •••• ",
                    //         style: TextStyle(
                    //             fontFamily: "GoldplayRegular",
                    //             fontWeight: FontWeight.w600,
                    //             fontSize: 17),
                    //       ),
                    //       TextSpan(
                    //         text: tarjetas[i]['tarjeta'],
                    //         style: TextStyle(
                    //             fontFamily: "GoldplayRegular",
                    //             fontWeight: FontWeight.w600,
                    //             fontSize: 17),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    title: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: tarjetas[i]['alias'],
                            style: TextStyle(
                                fontFamily: "GoldplayRegular",
                                fontWeight: FontWeight.w600,
                                fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                    trailing: Radio(
                        value: i,
                        groupValue: _value,
                        onChanged: (value) {
                          setState(() {
                            _value = i;
                            
                            confirmar(i);
                          });
                        })
                    // trailing: Container(decoration: BoxDecoration(border: Border.all(color:prs.colorGrisBordes )),)
                    ),
              ),
            );
            },
            ),
          ),
        
          ],
      ),
    );
  }

    confirmar(value) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      context: context,
      builder: (context) => Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              Text(
                '¿Seguro quieres establecer este nuevo método como predeterminado?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'GoldplayRegular',
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    DocumentSnapshot documentSnapshot = tarjetas[value];
                    await FirebaseFirestore.instance.collection("cards").where("seleccionado",isEqualTo: true)
                    .where("idCliente",isEqualTo: id).limit(1).get().then((QuerySnapshot value) async{
                      if(value.size>0)
                        await FirebaseFirestore.instance.collection("cards").doc(value.docs.first.id).update({"seleccionado":false});
                    });
                    await FirebaseFirestore.instance.collection("cards").doc(documentSnapshot.id).update({"seleccionado":true});
                    Navigator.pop(context);
                    setState(() {
                      _value = value;
                    });
                  },
                  child: Text(
                    "Sí, seguro",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      padding: EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: prs.colorRojo,
                      foregroundColor: prs.colorRojo),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _value = 1;
                    });
                  },
                  child: Text(
                    "Cancelar",
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
            ],
          ),
        ),
      ]),
    );
  }


  Widget _listaCar() {
    return StreamBuilder(
      stream: _cardBloc.cardStream,
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0)
            return createListView(context, snapshot);
          return Container();
        } else {
          return ShimmerCard();
        }
      },
    );
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        return _card(context, snapshot.data[index]);
      },
    );
  }

  mostraCargando() {
    _saving = true;
    if (mounted) setState(() {});
  }

  quitarCargando() {
    _saving = false;
    if (mounted) setState(() {});
  }

  CatalogoProvider _catalogoProvider = CatalogoProvider();

  _onTap(CardModel cardModel) async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (cardModel.isValid()) {
      if (widget.idAgencia.toString() == '0') {
        _cardBloc.actualizar(cardModel);
        if (widget.isMenu) {
          if (cardModel.type.toString().toUpperCase() ==
              Sistema.CUPON.toUpperCase()) {
            _irAmenu(cardModel.idAgencia.toString());
          }
        } else {
          Navigator.pop(context);
        }
      } else {
        if (!_formKey.currentState.validate() ||
            cardModel.modo.toUpperCase() != Sistema.TARJETA.toUpperCase())
          return;
        _cardBloc.actualizar(cardModel);
        _formKey.currentState.save();
      }
    } else {
      _cardBloc.listar(widget.idAgencia);
      if (cardModel.isReview()) {
        dlg.mostrar(context,
            'Tarjeta en revisión por favor espera que la misma sea aprobada.');
      } else if (cardModel.isPendig()) {
        _cardBloc.actualizar(cardModel);
        final String idTransaccion =
            '0'; //No hay idTransaccion pues es registro
        _verificarTarjeta(idTransaccion);
      }
    }
  }

  _evaluar(status, idTransaccion, mensaje) async {
    _cardBloc.listar(widget.idAgencia);
    _saving = false;
    if (mounted) setState(() {});
    if (status.toString() == Sistema.IS_ACREDITADO.toString()) {
      
      _textControllerMonto.text = '';
      _textControllerMotivo.text = '';
      montoAtrasferir = '';
      if (mounted) setState(() {});
      dlg.mostrar(context, mensaje);
    } else if (status == Sistema.IS_TOKEN) {
      
      _verificarTarjeta(idTransaccion);
    } else {
      dlg.mostrar(context, mensaje);
    }
  }

  void _verificarTarjeta(dynamic idTransaccion) {
    showDialog(
        barrierDismissible: false,
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
                  if (widget.idAgencia.toString() == '0') {
                    await _cardProvider.verificar(
                        _cardBloc.cardSeleccionada, _otp, _evaluar);
                  } else {
                    await _cardProvider.autorizar(_cardBloc.cardSeleccionada,
                        _otp, idTransaccion, _evaluar);
                  }
                },
              ),
            ],
          );
        });
  }

  CardProvider _cardProvider = CardProvider();

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

  _irAmenu(String idAgencia) async {
    _saving = true;
    if (mounted) setState(() {});
    CatalogoModel catalogoModel = await _catalogoProvider.ver(idAgencia);
    _saving = false;
    if (mounted) setState(() {});
    if (catalogoModel == null) return;
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => MenuPage(catalogoModel)));
  }

  Widget _card(BuildContext context, CardModel cardModel) {
    return Slidable(
      key: ValueKey(cardModel.token),
      child: CardCard(cardModel: cardModel, onTab: _onTap),
      startActionPane: ActionPane(
        // A motion is a widget used to control how the pane animates.
        motion: const ScrollMotion(),
        // A pane can dismiss the Slidable.
        dismissible: DismissiblePane(onDismissed: () {}),
        // All actions are defined in the children parameter.
        children: [
        SlidableAction(
          label: 'Eliminar',
          icon: Icons.delete,
          backgroundColor: Colors.red,
          onPressed: (context) {
            _enviarCancelar() async {
              Navigator.of(context).pop();
              mostraCargando();
              await _cardBloc.eliminar(cardModel);
              quitarCargando();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Card eliminado correctamente')));
            }

            dlg.mostrar(context, 'Esta acción no se puede revertir!',
                fBotonIDerecha: _enviarCancelar, mBotonDerecha: 'ELIMINAR');
          },
        ),
        ]));
  }
}
