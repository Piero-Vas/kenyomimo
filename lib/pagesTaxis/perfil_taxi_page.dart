import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mimo/widgets/menu_taxis_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../bloc/foto_bloc.dart';
import '../../dialog/contrasenia_dialog.dart';
import '../../dialog/foto_perfil_dialog.dart';
import '../../model/cliente_model.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cliente_provider.dart';
import '../../utils/button.dart' as btn;
import '../../utils/cache.dart' as cache;
import '../../utils/dialog.dart' as dlg;
import '../../utils/permisos.dart' as permisos;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../utils/validar.dart' as val;

class PerfilTaxiPage extends StatefulWidget {
  PerfilTaxiPage({Key key}) : super(key: key);

  _PerfilTaxiPageState createState() => _PerfilTaxiPageState();
}

class _PerfilTaxiPageState extends State<PerfilTaxiPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PreferenciasUsuario prefs = PreferenciasUsuario();
  final _fotoBloc = FotoBloc();
  final ClienteProvider _clienteProvider = ClienteProvider();

  ClienteModel _cliente = ClienteModel();
  bool _saving = false;

  @override
  void initState() {
    _fotoBloc.fotoStream.listen((fotoTomada) async {
      if (!fotoTomada) return;
      _cliente.img = prefs.clienteModel.img;
      if (mounted) if (mounted) setState(() {});
    });
    _cliente = prefs.clienteModel;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MenuWidgetTaxis(),
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Mis datos",
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
          leading: Builder(
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
          actions: [
            Padding(
              padding: const EdgeInsets.only(right:15.0),
              child: GestureDetector(
                onTap: (){
                  Navigator.pushNamed(context, "edit_perfil_taxi");
                },
                child: Image(
                image: AssetImage(
                  "assets/png/edit.png",
                ),
                width: 30,
                height: 30,
                        ),
              ),
            ),
          ],
        ),
        
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Center(
            child: Container(child: _body(), width: prs.anchoFormulario)),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(child: SingleChildScrollView(child: _contenido())),
        Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _cerrarSession();
                },
                child: Text(
                  "Cerrar sesión",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(),
                    padding: EdgeInsets.symmetric(vertical: 20,),
                    backgroundColor: prs.colorMorado,
                    foregroundColor: prs.colorMorado),
              ),
            ),
          ),
        ),
      ],
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

  Widget _avatar() {
    Widget _tarjeta = ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(100)),
      child: cache.fadeImage(prefs.clienteModel.img, width: 100, height: 100),
    );
    return Stack(
      children: <Widget>[
        _tarjeta,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(110)),
                splashColor: Colors.blueAccent.withOpacity(0.6),
                onTap: () => () {}),
          ),
        )
      ],
    );
  }

  Widget _contenido() {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      padding: EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
      child: Column(
        children: <Widget>[
          CircularPercentIndicator(
            radius: 57.0,
            lineWidth: 7.0,
            percent: (_cliente.registros > 0)
                ? (_cliente.correctos / _cliente.registros)
                : 1.0,
            center: _avatar(),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: prs.colorMorado, 
          ),
          /* _estrellas(),*/
          SizedBox(
            height: 15,
          ),
          Text("${prefs.clienteModel.nombres+" "+prefs.clienteModel.apellidos}",
              style: TextStyle(fontSize: 20.0, fontFamily: 'GoldplayBlack')),
          SizedBox(height: 20.0),
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                datos(prefs.clienteModel.correo,"email","Correo",false),
                datos(prefs.clienteModel.celular,"celular","Teléfono",false),
                datos(prefs.clienteModel.cedula,"placa2","DNI",false),
                prefs.clienteModel.perfil!="0" ? datos(prefs.clienteModel.driverLicensePlate,"placa2","Placa",false) : SizedBox(),
                prefs.clienteModel.perfil!="0" ? datos(prefs.clienteModel.driverModel,"email","Modelo",false) : SizedBox(),
                prefs.clienteModel.perfil!="0" ? datos(prefs.clienteModel.driverTradeMark,"celular","Marca",false) : SizedBox(),
                prefs.clienteModel.perfil!="0" ? datos(prefs.clienteModel.color,"auto2","Color de vehículo",false) : SizedBox(),
              ],
            ),
          ),
          SizedBox(height: 100.0),
        ],
      ),
    );
  }
}

Widget datos(valor,image,label,share) {
  return Column(
    children: [
      Row(
        children: [
          Image(
            image: AssetImage(
              "assets/png/${image}.png",
            ),
            width: 30,
            height: 30,
          ),
          SizedBox(
            width: 10,
          ),
          prs.labels(label),
        ],
      ),
      SizedBox(
        height: 10,
      ),
      Container(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "$valor",
                  style: TextStyle(
                    color: Color(0xFF4B4B4E),
                    fontSize: 17,
                  ),
                ),
              ),
               share?
              GestureDetector(
                onTap: (){},
                child: Image(
                          image: AssetImage(
                "assets/png/share.png",
                          ),
                          width: 30,
                          height: 30,
                        ),
              ):Container(),
            ],
          )),
      Divider(
        thickness: 1,
        height: 40,
      ),
    ],
  );
}