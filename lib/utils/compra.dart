import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mimo/preference/shared_preferences.dart';

import '../model/cajero_model.dart';
import '../model/compra_promocion_model.dart';
import '../model/despacho_model.dart';
import '../pages/delivery/despacho_page.dart';
import '../utils/personalizacion.dart' as prs;
import '../widgets/compra_promo_widget.dart';
import 'dart:convert';
import 'package:flash/flash.dart';
import 'package:http/http.dart';
import 'package:geolocator/geolocator.dart';

Widget promociones(BuildContext context, compraPromocionStream, _scaffoldKey) {
  return Container(
    width: double.infinity,
    child: StreamBuilder(
      stream: compraPromocionStream,
      builder: (BuildContext context,
          AsyncSnapshot<List<CompraPromocionModel>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0)
            return CompraPromoWidget(
                promociones: snapshot.data, scaffoldKey: _scaffoldKey);
          return Container();
        } else {
          return LinearProgressIndicator(
              backgroundColor: prs.colorLinearProgress);
        }
      },
    ),
  );
}

despachoPage(BuildContext context, CajeroModel cajeroModel, String mensaje, int tipo) {
  /* cajeroModel.lt = double.parse(cajeroModel.lt.toString());
  cajeroModel.lg = double.parse(cajeroModel.lg.toString()); */
  var despacho = DespachoPage(
    tipo,
    cajeroModel: cajeroModel,
    despachoModel: new DespachoModel(
        idCompra: cajeroModel.idCompra,
        idDespachoEstado: 0,
        img: 'assets/no-image.png',
        nombres: mensaje,
        costo: cajeroModel.costo,
        costoEnvio: cajeroModel.costoEnvio,
        lt: 0.0,
        lg: 0.0,
        ltA: cajeroModel.lt,
        lgA: cajeroModel.lg,
        ltB: cajeroModel.ltB,
        lgB: cajeroModel.lgB),
  );
  MaterialPageRoute route = MaterialPageRoute(builder: (context) => despacho);
  Navigator.of(context).pushAndRemoveUntil(route, (Route<dynamic> route) {
    return route.isFirst;
  });
}