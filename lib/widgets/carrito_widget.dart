import 'package:flutter/material.dart';
import '../dialog/instruccion_dialog.dart';
import '../model/promocion_model.dart';
import '../utils/personalizacion.dart' as prs;
import 'icon_add_widget.dart';

class CarritoWidget extends StatefulWidget {
  final List<PromocionModel> promociones;
  final Function consultarPrecio;
  final Function evaluarCosto;
  final Function verMenu;

  CarritoWidget(this.consultarPrecio, this.evaluarCosto, this.verMenu,
      {@required this.promociones});

  @override
  _CarritoWidgetState createState() => _CarritoWidgetState();
}

class _CarritoWidgetState extends State<CarritoWidget> {
  @override
  Widget build(BuildContext context) {
    return lista();
  }

  Widget lista() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: widget.promociones.length,
      itemBuilder: (context, i) => _tarjeta(context, widget.promociones[i]),
    );
  }

  Container _tarjeta(BuildContext context, PromocionModel promocion) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40.0),
        border: Border.all(color: prs.colorGrisBordes),
      ),
      child: _card2(promocion, context),
    );
  }

  Widget etiqueta(BuildContext context, PromocionModel promocionModel) {
    if (promocionModel.incentivo == '') return Container();
    return Positioned(
      bottom: 10.0,
      left: 0,
      child: Container(
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: prs.colorButtonSecondary,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
                child: Text(promocionModel.incentivo,
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }

  Widget _card2(PromocionModel promocion, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
      child: _contenido(promocion, context),
    );
  }

  Column _contenido(PromocionModel promocion, BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: [
            Container(
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), image: DecorationImage(image: NetworkImage(promocion.imagen))),
                  ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    promocion.producto,
                    style: TextStyle(
                        fontSize: 14.0,
                        color: prs.colorIcons,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 7.0),
                  Text(
                    promocion.descripcion,
                    maxLines: 2,
                    textAlign: TextAlign.justify,
                    style: TextStyle(color: prs.colorTextDescription),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10.0),
        Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Text(
                            'S/. ' + promocion.precio.toStringAsFixed(2),
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: prs.colorRojo)),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              IconAddWidget(widget.evaluarCosto, promocionModel: promocion),
            ]),
        SizedBox(height: 15.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: prs.colorButtonSecondary,
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0))),
              label: Text('Instrucciones'),
              icon: Icon(Icons.message, size: 18.0),
              onPressed: () {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return InstruccionDialog(promocion: promocion);
                    });
              },
            ),
          ],
        ), 
      ],
    );
  }
}