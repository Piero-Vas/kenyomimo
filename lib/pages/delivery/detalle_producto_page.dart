import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:mimo/widgets/icon_add_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:percent_indicator/circular_percent_indicator.dart';
// import 'package:toggle_switch/toggle_switch.dart';

import '../../bloc/foto_bloc.dart';
import '../../dialog/contrasenia_dialog.dart';
// import '../../dialog/foto_perfil_dialog.dart';
import '../../model/cliente_model.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cliente_provider.dart';
import '../../utils/button.dart' as btn;
// import '../../utils/cache.dart' as cache;
// import '../../utils/dialog.dart' as dlg;
// import '../../utils/permisos.dart' as permisos;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../utils/validar.dart' as val;

class DetalleProductoPage extends StatefulWidget {
  DetalleProductoPage({Key key}) : super(key: key);

  _DetalleProductoPageState createState() => _DetalleProductoPageState();
}

class _DetalleProductoPageState extends State<DetalleProductoPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PreferenciasUsuario prefs = PreferenciasUsuario();
  final _fotoBloc = FotoBloc();
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final ClienteProvider _clienteProvider = ClienteProvider();

  ClienteModel _cliente = ClienteModel();

  bool _saving = false;

  TextEditingController _inputFieldDateController;

  TextEditingController _textControllerPassword;

  @override
  void initState() {
    _fotoBloc.fotoStream.listen((fotoTomada) async {
      if (!fotoTomada) return;
      _cliente.img = prefs.clienteModel.img;
      if (mounted) if (mounted) setState(() {});
    });

    _cliente = prefs.clienteModel;
    _textControllerPassword = TextEditingController(text: '');
    _inputFieldDateController =
        TextEditingController(text: _cliente.fechaNacimiento);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: utils.leading(context),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: prs.colorRojo),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.favorite_border, color: prs.colorRojo),
            onPressed: () {},
          ),
        ],
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

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(child: SingleChildScrollView(child: _contenido())),
        Container(child: btn.bootonContinuar('Continuar', _continuar)),
        SizedBox(
          height: 20,
        )
      ],
    );
  }

  Widget _contenido() {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      child: Text(
                        'COMBO CON PAPAS',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: prs.colorRojo,
                          fontFamily: 'GoldplayBlack',
                          fontSize: 24,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                            color: prs.colorRojo,
                            borderRadius: BorderRadius.circular(50)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.white),
                            Text('1',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            Icon(Icons.minimize, color: Colors.white)
                          ],
                        ))
                  ],
                ),
                prs.subTitulo(
                    'Hamburguesa de carne con queso, tocino y papas fritas + 3 bebidas de 500 ml'),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                          color: prs.colorRojo,
                          borderRadius: BorderRadius.circular(50)),
                      child: Text('-20%',
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Text('S/. 10.32',
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: prs.colorRojo)),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Text('S/. 12.90',
                          style: TextStyle(
                              fontSize: 18.0,
                              decoration: TextDecoration.lineThrough,
                              color: prs.colorGrisOscuro)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
              width: double.infinity,
              height: 200,
              child: Image.asset(
                'assets/png/fondoProducto.png',
                fit: BoxFit.cover,
              )),
          SizedBox(
            height: 15,
          ),
          Card1('Elige 1 complemento', 'Papas artesanales medianas'),
          SizedBox(
            height: 15,
          ),
          Card1('Elige 3 bebidas', 'Inka Cola'),
          SizedBox(
            height: 15,
          ),
          Card1('Elige Salsas','Ají,Mostasa'),
        ],
      ),
    );
  }

  Widget Card1(titulo,subtitulo){
    return ExpandableNotifier(
        child: Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: prs.colorGrisBordes)),
          child: Column(
            children: <Widget>[
              ScrollOnExpand(
                scrollOnExpand: true,
                scrollOnCollapse: false,
                child: ExpandablePanel(
                  theme: const ExpandableThemeData(
                    headerAlignment: ExpandablePanelHeaderAlignment.center,
                    tapBodyToCollapse: true,
                  ),
                  header: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        titulo,
                        style: TextStyle(
                            fontFamily: 'GoldplayBlack',
                            fontSize: 17,
                            color: prs.colorRojo),
                      )),
                  collapsed: Row(
                    children: [
                      Text(
                        subtitulo,
                        style: TextStyle(color: prs.colorGrisClaro),
                      ),
                      Expanded(child: Container()),
                      Text(
                        '+S/.5.90',
                        style: TextStyle(color: prs.colorRojo),
                      ),
                    ],
                  ),
                  expanded: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Text(
                            'Papas artesanales mediana',
                            style: TextStyle(color: prs.colorGrisClaro),
                          ),
                          Expanded(child: Container()),
                          Text(
                            '+S/.5.90',
                            style: TextStyle(color: prs.colorRojo),
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      Row(
                        children: [
                          Text('Papas clasicas regulares'),
                          Expanded(child: Container()),
                          Radio(value: 1, groupValue: 1, onChanged: (value) {})
                        ],
                      ),
                      Divider(
                        height: 30,
                        thickness: 2,
                      ),
                      Row(
                        children: [
                          Text('Papas artesanales regulares'),
                          Expanded(child: Container()),
                          Radio(value: 2, groupValue: 1, onChanged: (value) {})
                        ],
                      ),
                      Divider(
                        height: 30,
                        thickness: 2,
                      ),
                      Row(
                        children: [
                          Text('Papas clásicas medianas'),
                          Expanded(child: Container()),
                          Radio(value: 3, groupValue: 1, onChanged: (value) {})
                        ],
                      ),
                    ],
                  ),
                  builder: (_, collapsed, expanded) {
                    return Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: Expandable(
                        collapsed: collapsed,
                        expanded: expanded,
                        theme: const ExpandableThemeData(crossFadePoint: 0),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  _continuar() {
    Navigator.pushNamed(context, 'carrito');
  }
}
