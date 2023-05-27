import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mimo/model/categoria_model.dart';
import 'package:mimo/model/cliente_model.dart';
import 'package:mimo/pages/paymentez/cards_page.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../utils/cache.dart' as cache;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;

class PruebaPage extends StatefulWidget {
  const PruebaPage({Key key}) : super(key: key);

  @override
  State<PruebaPage> createState() => _PerfilTaxiPageState();
}

class _PerfilTaxiPageState extends State<PruebaPage> {
  var categorias = [
    {'categoria': 'Restaurante'},
    {'categoria': 'Licores'},
    {'categoria': 'Licores'},
    {'categoria': 'Licores'},
  ];

bool isChecked = false;

  ClienteModel _cliente = ClienteModel();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        // shadowColor: Colors.black,
        centerTitle: true,
        title: Text(
          "Detalles de viaje",
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
        leading: utils.leading(context),
      ),
      body: SafeArea(
        child: 
        Container(
         height: 150,
                  // color: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                  child: 
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text('data datadata data data data data data data  data datadata data data data data data data ')),
                              ],
                            ),
                            Text('data2'),
                            Row(
                              children: [
                               
                               Expanded(
                                 child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red, 
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Text('- 20 %', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 17,),)),
                               ),
                                Expanded(
                                 child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Text('S/ 10.00', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 17,),)),
                               ),
                               Expanded(
                                 child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Text('S/ 10.00', style: TextStyle(decoration: TextDecoration.lineThrough,color: Colors.black, fontSize: 17,),)),
                               ),
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 15,),
                      Container(
                        width: 80,
                        height: 80,
                        color: Colors.amber,
                      )
                    ],
                  )
                )
              ),
    );
  
  }

  Widget _tarjeta(BuildContext context) {
    final tarjeta = Container(
      margin: EdgeInsets.only(top: 5, left: 10.0, right: 10.0, bottom: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black26,
            blurRadius: 0.0,
            spreadRadius: 0.0,
            offset: Offset(0.1, 0.1),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          _contenidoLista(context),
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
              onTap: () async {
              },
            
            ),
          ),
        ),
      ],
    );
  }


Widget _img() {
    return Container(
      width: 142.0,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0), topLeft: Radius.circular(10.0)),
        child: cache.fadeImage("https://firebasestorage.googleapis.com/v0/b/mimo-3ef92.appspot.com/o/productos%2Ftambos.jpeg?alt=media&token=d697a28a-558d-4c39-819b-a5dc7e9e7e0b"),
      ),
    );
  }

  Widget _contenidoLista( BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: <Widget>[
            _img(),
          ],
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(left: 2.0, right: 5.0, top: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('PRODuctos',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                // SizedBox(height: 5.0),
                Text("Tiempo de Preparación: 12",
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.visible,
                    maxLines: 2,
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                // SizedBox(height: 5.0),
                Text("promocion.descripcion",
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.visible,
                    maxLines: 5,
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                SizedBox(height: 5.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    recomendado(context),
                    Expanded(child: Container()),
                    Text('S/. ',
                        style:
                            TextStyle(fontSize: 17.0, color: prs.colorIcons)),
                    SizedBox(width: 5.0),
                  ],
                ),
                Text("Descuento del 12%") ,
                 Text('Promocion: S/. 12',
                        style:
                            TextStyle(fontSize: 17.0, color: prs.colorIcons)),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget recomendado(BuildContext context,) {
      return Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
                child: Row(
              children: [
                Icon(FontAwesomeIcons.share, color: Colors.white, size: 17.0),
                SizedBox(width: 5.0),
                Text('Favorito',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center),
              ],
            )),
          ],
        ),
      );
   
  }

}
