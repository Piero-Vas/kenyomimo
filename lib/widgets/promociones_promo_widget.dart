import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../bloc/catalogo_bloc.dart';
import '../bloc/promocion_bloc.dart';
import '../dialog/productos_dialog.dart';
import '../model/catalogo_model.dart';
import '../model/promocion_model.dart';
import '../preference/db_provider.dart';
import '../utils/cache.dart' as cache;
import '../utils/dialog.dart' as dlg;
import '../utils/personalizacion.dart' as prs;
import '../utils/utils.dart' as utils;

class PromocionesPromoWidget extends StatefulWidget {
  final PromocionModel promocion;
  final Function compartirPromocion;

  final CatalogoModel catalogoModel;
  final Function verChat;

  PromocionesPromoWidget(
      this.compartirPromocion, this.catalogoModel, this.verChat,
      {@required this.promocion});

  @override
  _PromocionesPromoWidgetState createState() => _PromocionesPromoWidgetState();
}

class _PromocionesPromoWidgetState extends State<PromocionesPromoWidget> {
  final PromocionBloc _promocionBloc = PromocionBloc();
  final CatalogoBloc _catalogoBloc = CatalogoBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _tarjeta(context,widget.promocion);
    // return _card(context, widget.promocion);
  }

  

  Widget _card(BuildContext context, PromocionModel promocion) {
    return Slidable(
      key: ValueKey(promocion.idPromocion.toString()),
      child: _tarjeta(context, promocion),
      startActionPane: ActionPane(
      children:
      [
        SlidableAction(
          backgroundColor: Colors.green,
          label: 'Compartir',
          icon: Icons.share,
          onPressed: (context) {
            widget.compartirPromocion(promocion);
          },
        ),
      ],
    ));
  }

  Widget _tarjeta(BuildContext context, PromocionModel promocion) {
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
          _contenidoLista(promocion, context),
          promocion.isComprada ? utils.modalAgregadoAlCarrito() : Container()
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
                if (promocion.estado <= 0) {
                  return dlg.mostrar(context, promocion.mensaje);
                }

                if (promocion.tipo == 5) {
                  Navigator.of(context).pop();
                  widget.verChat(widget.catalogoModel.idAgencia);
//                  return dlg.mostrar(context, 'Chat');
                  return;
                }

                if (widget.catalogoModel.abiero == '1') {
                  /* if (promocion.productos != null &&
                      promocion.productos.lP != null &&
                      promocion.productos.lP.length > 0) {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return ProductosDialog(promocion: promocion);
                        });
                    return;
                  } else { */
                  
                  List promotions = await _promocionBloc.getPromotions(promocion.idAgencia);
                  if(!promocion.isComprada && promotions.length>0){
                    dlg.mostrar(context, "Usted cuenta con productos de otra agencia.",
                      titulo: 'Fallo al agregar');
                  }else{
                    promocion.isComprada = !promocion.isComprada;
                    _promocionBloc.actualizar(promocion);
                    _catalogoBloc.actualizar(promocion);
                    
                    if (promocion.isComprada) {
                      await DBProvider.db.agregarPromocion(promocion);
                    } else {
                      await DBProvider.db.eliminarPromocion(promocion);
                    }
                    _promocionBloc.carrito();
                  }
                  //}
                } else {
                  dlg.mostrar(context, widget.catalogoModel.abiero,
                      titulo: 'Local cerrado');
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _img(PromocionModel promocion) {
    return Container(
      width: 142.0,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0), topLeft: Radius.circular(10.0)),
        child: cache.fadeImage(promocion.imagen),
      ),
    );
  }

  Widget _contenidoLista(PromocionModel promocion, BuildContext context) {
    return Container(
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text("${promocion.producto}", style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold
                                  ),)),
                                ],
                              ),
                              SizedBox(height: 5,),
                              promocion.descripcion.length < 130 ?
                              Row(
                                children: [
                                  Expanded(child: Text("${promocion.descripcion}", style: TextStyle(
                                    // overflow: TextOverflow.ellipsis,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),)),
                                ],
                              ):Row(
                                children: [
                                  Expanded(child: Text("${promocion.descripcion}", style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),)),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                children: [
                                  Expanded(child: Text("Tiempo preparación : ${promocion.tiempo_preparacion} min",style: TextStyle(
                                    // overflow: TextOverflow.ellipsis,
                                    fontSize: 13,
                                    // color: Colors.black,
                                  ))),
                                ],
                              ),
                              SizedBox(height: 15,),
                              promocion.tieneDescuento?
                              Row(
                                children: [
                                 
                                 Expanded(
                                   child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red, 
                                      borderRadius: BorderRadius.circular(20)
                                    ),
                                    padding: EdgeInsets.all(10),
                                    child: Text('- ${(double.parse(promocion.descuento.toString()))} %', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 15,),)),
                                 ),
                                 Expanded(
                                   child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Text('S/ ${(double.parse(promocion.precio.toString())).toStringAsFixed(2)}',textAlign: TextAlign.center, style: TextStyle(decoration: TextDecoration.lineThrough,color: Colors.black, fontSize: 15,),)),
                                 ),
                                  Expanded(
                                   child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Text('S/ ${(double.parse(promocion.precioPromocion.toString())).toStringAsFixed(2)}',textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15,),)),
                                 ),
                                 
                                ],
                              ):
                              Row(
                                children: [
                                  Expanded(
                                   child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Text('S/ ${(double.parse(promocion.precio .toString())).toStringAsFixed(2)}', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 17,),)),
                                 ),
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 15,),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                            width: 100,
                            height: 100,
                            child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image(image: NetworkImage(promocion.imagen),fit: BoxFit.cover,)
                            // cache.fadeImage(promocion.imagen),
                              ),
                              ),
                          ],
                        )
          // Expanded(
          //   child: Container(
          //     padding: EdgeInsets.only(left: 2.0, right: 5.0, top: 10.0),
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       children: [
          //         Text(promocion.producto,
          //             textAlign: TextAlign.center,
          //             maxLines: 2,
          //             overflow: TextOverflow.visible,
          //             style:
          //                 TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          //         // SizedBox(height: 5.0),
          //         Text("Tiempo de Preparación: ${promocion.tiempo_preparacion}",
          //             textAlign: TextAlign.center,
          //             overflow: TextOverflow.visible,
          //             maxLines: 2,
          //             style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
          //         // SizedBox(height: 5.0),
          //         Text(promocion.descripcion,
          //             textAlign: TextAlign.center,
          //             overflow: TextOverflow.visible,
          //             maxLines: 5,
          //             style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
          //         SizedBox(height: 5.0),
          //         Row(
          //           crossAxisAlignment: CrossAxisAlignment.end,
          //           children: <Widget>[
          //             recomendado(context, promocion),
          //             Expanded(child: Container()),
          //             Text('S/. '+(double.parse(promocion.precio.toString())).toStringAsFixed(2),
          //                 style:
          //                     TextStyle(fontSize: 17.0, color: prs.colorIcons)),
          //             SizedBox(width: 5.0),
          //           ],
          //         ),
          //         promocion.tieneDescuento ? Text("Descuento del ${promocion.descuento}%") : Container(),
          //             promocion.tieneDescuento ?  Text('Promocion: S/. '+(double.parse(promocion.precioPromocion.toString())).toStringAsFixed(2),
          //                 style:
          //                     TextStyle(fontSize: 17.0, color: prs.colorIcons)) : Container(),
          //       ],
          //     ),
          //   ),
          // ),
        
          // Stack(
          //   children: <Widget>[
          //     _img(promocion),
          //     etiqueta(context, promocion),
          //     cerrado(context, promocion),
          //   ],
          // ),
          
        ],
      ),
    );
  }

  Widget recomendado(BuildContext context, PromocionModel promocionModel) {
    if (widget.catalogoModel.idPromocion.toString() ==
        promocionModel.idPromocion.toString())
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
    return Container();
  }

  Widget etiqueta(BuildContext context, PromocionModel promocionModel) {
    if (promocionModel.incentivo == '') return Container();
    return Positioned(
      bottom: 10.0,
      left: 0,
      child: Container(
        padding: EdgeInsets.all(8.0),
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

  Widget cerrado(BuildContext context, PromocionModel promocion) {
    if (promocion.estado > 0) return Container();
    return Positioned(
      top: 10.0,
      left: -55,
      child: Transform.rotate(
        alignment: FractionalOffset.center,
        angle: 345.0,
        child: Container(
          height: 40.0,
          width: 200.0,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(promocion.mensaje,
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}