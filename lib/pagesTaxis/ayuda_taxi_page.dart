import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../model/cajero_model.dart';
import '../../model/direccion_model.dart';
import '../../model/promocion_model.dart';
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;

class AyudaTaxiPage extends StatefulWidget {
  @override
  _AyudaTaxiPageState createState() => _AyudaTaxiPageState();
}

class _AyudaTaxiPageState extends State<AyudaTaxiPage> {
  List<PromocionModel> promociones;
  List<CajeroModel> cajeros = [];

  bool _saving = false;
  String _title = 'Consultando costo';

  double costoTotal = 0.0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DireccionModel direccionSeleccionada = DireccionModel();

  @override
  void initState() {
    super.initState();
  }

  bool _radar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        title: Text('Ayuda',
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
        prs.tituloTaxi('ASISTENCIA'),
        SizedBox(
          height: 15,
        ),
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: prs.colorGrisBordes),
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              ayuda('Los conductores no responden'),
              Divider(
                thickness: 1,
                color: prs.colorGrisBordes,
              ),
              ayuda('Dejarle un comentario a un conductor'),
              Divider(
                thickness: 1,
                color: prs.colorGrisBordes,
              ),
              ayuda('Quejarse'),
              Divider(
                thickness: 1,
                color: prs.colorGrisBordes,
              ),
              ayuda('Encontrar pertenencias que olvidé'),
              Divider(
                thickness: 1,
                color: prs.colorGrisBordes,
              ),
              ayuda('Cómo usar el servicio de repartidores.'),
              SizedBox(
                height: 15,
              )
            ],
          ),
        ),
        SizedBox(
          height: 25,
        ),
        prs.tituloTaxi('RETROLIMENTACIÓN'),
        SizedBox(
          height: 15,
        ),
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: prs.colorGrisBordes),
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              ayuda('Escribir al equipo de soporte'),
              Divider(
                thickness: 1,
                color: prs.colorGrisBordes,
              ),
              ayuda('Escribir al correo electrónico'),
            ],
          ),
        )
      ])))
    ]);
  }

  Widget ayuda(texto) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(children: [
        Expanded(
            child: Text(
          texto,
          style: TextStyle(fontSize: 16, fontFamily: 'GoldplayRegular'),
        )),
        // Expanded(child: Container()),
        IconButton(
            onPressed: () {},
            icon: Icon(Icons.arrow_forward_ios, color: prs.colorMorado))
      ]),
    );
  }
}
