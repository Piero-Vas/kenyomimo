import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:mimo/pages/delivery/detalle_producto_page.dart';
import 'package:mimo/preference/shared_preferences.dart';
import 'package:mimo/sistema.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:share/share.dart';

import '../../bloc/catalogo_bloc.dart';
import '../../bloc/promocion_bloc.dart';
import '../../card/shimmer_card.dart';
import '../../model/catalogo_model.dart';
import '../../model/promocion_model.dart';
import '../../providers/catalogo_provider.dart';
import '../../utils/dialog.dart' as dlg;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../widgets/comprar_promo_widget.dart';
import '../../widgets/promociones_promo_widget.dart';
import '../../utils/cache.dart' as cache;
import 'package:http/http.dart' as http;
class MenuPage extends StatefulWidget {
  final CatalogoModel catalogoModel;
  final Function verChat;

  MenuPage(
    this.catalogoModel, {
    Key key,
    this.verChat,
  }) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState(catalogoModel: catalogoModel);
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final CatalogoBloc _catalogoBloc = CatalogoBloc();
  final CatalogoProvider _catalogoProvider = CatalogoProvider();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final PromocionBloc _promocionBloc = PromocionBloc();
  final CatalogoModel catalogoModel;
  ScrollController pageControllerProductosDestacados = ScrollController();

  _MenuPageState({this.catalogoModel});

  bool _buscando = false;
  TextEditingController _textControllerCredito;

  ScrollController pageControllerProductos = ScrollController();
  var tipo;
  @override
  void initState() {
    
    obtenertipo();
    _catalogoBloc.pagina = 0;
    pageControllerProductos.addListener(() async {
      if (_catalogoBloc.consultando != 0) return;
      if (pageControllerProductos.position.pixels >= pageControllerProductos.position.maxScrollExtent - 50) {
        _catalogoBloc.pagina++;
        _catalogoBloc.listarPromociones(catalogoModel.idAgencia.toString(), isClean: false);
      }
    });

    _textControllerCredito = TextEditingController(text: '');

    super.initState();
    if (catalogoModel.idPromocion.toString() != '0')
      _catalogoBloc.listarPromociones(catalogoModel.idAgencia.toString(),
          idPromocion: catalogoModel.idPromocion.toString(), isClean: true);
    else
      _catalogoBloc.listarPromociones(catalogoModel.idAgencia.toString());
    _promocionBloc.carrito();
  }

 Future obtenertipo() async {
  
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection("category").doc("category_"+catalogoModel.idCategoria.toString()).get();
    Map categoryModel = documentSnapshot.data();
    if(mounted){
      setState(() {
        tipo = categoryModel['categoria'];
      });
    }
  }

  bool _saving = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: utils.progressIndicator('Consultando...'),
        inAsyncCall: _saving,
        child: Center(
            child: Container(decoration: BoxDecoration(color: Colors.white), child: _promociones(context), width: prs.ancho)),
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          
          Padding(
            padding: EdgeInsets.only(right: 70.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                heroTag: null,
                backgroundColor: Colors.white,
                elevation: 1.0,
                onPressed: compartirAgencia,
                child: (_prefs.isExplorar || _prefs.clienteModel.direcciones >= 1)
              ? IconButton(
                  // padding: EdgeInsets.only(right: 30.0),
                  icon: StreamBuilder(
                    stream: _promocionBloc.carritoStream,
                    builder:
                        (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.hasData)
                        return utils.iconoCount(snapshot.data);
                      return utils.iconoCount(0);
                    },
                  ),
                  onPressed: irAlCarrito,
                )
              : Container(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              heroTag: null,
              backgroundColor: Colors.white,
              elevation: 1.0,
              onPressed: null,
              child: IconButton(color: prs.colorIconsAppBar, onPressed: () {
                catalogoModel.like = catalogoModel.like==1 ? 0 : 1;
                _catalogoProvider.like(catalogoModel);
                _catalogoBloc.refrezcarFavoritos(); 
                setState(() {});
              }, icon: catalogoModel.like==1 ? Icon(FontAwesomeIcons.solidHeart) : Icon(FontAwesomeIcons.heart))
            ),
          ),
        ],
      ),
    );
  }

  _update() {
    _saving = true;
    if (mounted) if (mounted) setState(() {});
  }

  _complet() {
    _saving = false;
    if (mounted) if (mounted) setState(() {});
  }

  compartirAgencia() async {
    String link =
        await utils.obtenerLinkAgencia(catalogoModel, _update, _complet);
    if (link == null)
      return dlg.mostrar(context,
          'Ups. Lo sentimos ocurrió un problema, intenta de nuevo más tarde.');
    Share.share('$link ');
  }

  compartirPromocion(PromocionModel promocion) async {
    String link = await utils.obtenerLinkAgencia(
        catalogoModel, _update, _complet,
        promocion: promocion);
    if (link == null)
      return dlg.mostrar(context,
          'Ups. Lo sentimos ocurrió un problema, intenta de nuevo más tarde.');
    Share.share('$link ');
  }

  var press = DateTime.now();

  buscar(String value) async {
    if (value.length < 3) return;
    press = DateTime.now();
    Future.delayed(const Duration(milliseconds: 1900), () async {
      final ahora = DateTime.now();
      final difference = ahora.difference(press).inMilliseconds;
      if (difference > 1900) filtrar();
    });
  }

  filtrar() async {
    press = DateTime.now();
    FocusScope.of(context).requestFocus(FocusNode());
    _buscando = true;
    if (mounted) setState(() {});
    await _catalogoBloc.listarPromociones(catalogoModel.idAgencia.toString(),
        alias: _textControllerCredito.text, isClean: true);
    _buscando = false;
    if (mounted) setState(() {});
  }

  Widget _crearBuscador() {
    return Visibility(
      visible: true,
      child: Container(
        padding: EdgeInsets.only(left: 17.0, right: 15.0),
        child: TextField(
            onEditingComplete: filtrar,
            onChanged: (value) {
              buscar(value);
            },
            controller: _textControllerCredito,
            decoration: prs.decorationSearch(
              'Busca en ${catalogoModel.agencia}',
            )),
      ),
    );
  }

  irAlCarrito() async{
    int totalCarrito = await _promocionBloc.getTotal();
    totalCarrito > 0 ? Navigator.pushNamed(context, 'carrito') : utils.mostrarSnackBar(context, "No cuenta con ningun producto",milliseconds: 3000000);
  }

  List<PromocionModel> _listPromociones = [];
  List<PromocionModel> _listProductos = [];

  Widget _promociones(BuildContext context) {
    return StreamBuilder(
      stream: _catalogoBloc.promocionStream,
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.hasData) {
          if (_buscando) return Column(children: [ShimmerCard()]);

          _listPromociones.clear();
          _listProductos.clear();

          snapshot.data.forEach((promo) {
            if (promo.promocion <= 0) {
              _listProductos.add(promo);
            } else {
              _listPromociones.add(promo);
            }
          });

          
          return CustomScrollView(
            controller: pageControllerProductos,
            slivers: <Widget>[
              SliverToBoxAdapter(child: Container(
                padding:EdgeInsets.only(top: 30),
                decoration: BoxDecoration(
                  image: DecorationImage(fit:BoxFit.cover , image: AssetImage('assets/screen/productoFondo2.png'))
                ),
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_outlined, color: Colors.white),
                          onPressed: (){Navigator.pop(context);},
                        ),
                        Expanded(child: Container()),
                        // IconButton(
                        //   icon: Icon(Icons.share_outlined, color: Colors.white),
                        //   onPressed: (){},
                        // ),
                        // IconButton(
                        //   icon: Icon(FontAwesomeIcons.circleExclamation, color: Colors.white),
                        //   onPressed: (){},
                        // ),
                        // IconButton(
                        //   icon: Icon(Icons.search, color: Colors.white),
                        //   onPressed: (){},
                        // ),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Container(
                      padding: EdgeInsets.only(bottom: 10),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children:[
                          Container(
                            width: 80,
                            height: 80,
                            alignment:AlignmentDirectional.center,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.all(Radius.circular(100),),
                              image: DecorationImage(image: NetworkImage(catalogoModel.img),fit: BoxFit.fill)
                            ),
                            
                            // child: cache.fadeImage(catalogoModel.img, width: 80, height: 80),
                            
                            ),
                          SizedBox(width: 15,),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${catalogoModel.agencia}', style: TextStyle(color: Colors.white, fontFamily: 'GoldplayBlack', fontSize: 20,overflow: TextOverflow.ellipsis),),
                                // Text('Hamburguesas', style: TextStyle(color: Colors.white,fontFamily: 'GoldplayRegular', fontSize: 18),)
                               
                                Text('${tipo}', style: TextStyle(color: Colors.white,fontFamily: 'GoldplayRegular', fontSize: 18),)
                              ],
                            )
                        ]                        
                      ),
                    ),
                    SizedBox(height: 30,),
                    Container(
                      padding: EdgeInsets.only(top: 20,bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(50),topRight: Radius.circular(50))
                      ),
                      child: 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // SizedBox(width: 15,),
                          Expanded(child: Container()),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(FontAwesomeIcons.star, color: prs.colorRojo),
                                  SizedBox(width: 10,),
                                  Text( catalogoModel.promedioCalificacion.toStringAsFixed(1), style: TextStyle(fontFamily: 'GoldplayRegular', fontSize: 20, ),)
                                ],
                              ),
                              Text('Calificaciones',style: TextStyle(color: prs.colorGrisOscuro,fontFamily: 'GoldplayRegular',fontWeight: FontWeight.bold),)
                            ],
                          ),
                          Expanded(child: Container()),
                        ],
                      ),
                    )
                  ],
                ),),),
              // SliverToBoxAdapter(child: 
              // Expanded(
              //   child: SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     children: [
              //       Container(
              //         margin: EdgeInsets.only(left: 20),
              //         decoration: BoxDecoration(color: prs.colorGrisAreaTexto, borderRadius: BorderRadius.circular(50)),
              //         padding: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
              //         child: Text('Carta >', style: TextStyle(fontSize: 16, fontFamily: 'GoldplayRegular', ),),
              //       ),
              //       Container(
              //         margin: EdgeInsets.only(left: 20),
              //         decoration: BoxDecoration(color: prs.colorGrisAreaTexto, borderRadius: BorderRadius.circular(50)),
              //         padding: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
              //         child: Text('Ofertas', style: TextStyle(fontSize: 16, fontFamily: 'GoldplayRegular', ),),
              //       ),
              //       Container(
              //         margin: EdgeInsets.only(left: 20),
              //         decoration: BoxDecoration(color: prs.colorGrisAreaTexto, borderRadius: BorderRadius.circular(50)),
              //         padding: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
              //         child: Text('Hamburguesas', style: TextStyle(fontSize: 16, fontFamily: 'GoldplayRegular', ),),
              //       ),
              //       Container(
              //         margin: EdgeInsets.only(left: 20),
              //         decoration: BoxDecoration(color: prs.colorGrisAreaTexto, borderRadius: BorderRadius.circular(50)),
              //         padding: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
              //         child: Text('Favoritos', style: TextStyle(fontSize: 16, fontFamily: 'GoldplayRegular', ),),
              //       )
              //     ],
              //   )),
              // )),
              // SliverToBoxAdapter(
              //   child: _listPromociones.length > 0
              //       ? _titulos('Descuentos')
              //       : Container(),
              // ),
              // SliverToBoxAdapter(
              //   child: _listPromociones.length > 0
              //       ? _subtitulos('Productos con descuento de hasta 70%')
              //       : Container(),
              // ),
              // SliverToBoxAdapter(
              //     child: _listPromociones.length > 0
              //         ? ComprarPromoWidget(
              //             pageControllerProductosDestacados,
              //             promociones: _listPromociones,
              //             isOppen: catalogoModel.abiero.toString() == '1',
              //             agencia: catalogoModel.abiero.toString(),
              //           )
              //         : Container()),
              SliverToBoxAdapter(child: _titulos('Catálogo')),
              SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 500.0,
                    childAspectRatio: 1.9,
                    mainAxisSpacing: 0.0),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return PromocionesPromoWidget(
                        compartirPromocion, catalogoModel, widget.verChat,
                        promocion: _listProductos[index]);
                  },
                  childCount: _listProductos.length,
                ),
              ),
              SliverToBoxAdapter(
                  child: StreamBuilder(
                stream: _catalogoBloc.isConsultandoStream,
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  if (snapshot.hasData && snapshot.data == 1)
                    return ShimmerCard();
                  return SizedBox(height: 80.0);
                },
              )),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 80.0),
              )
            ],
          );
        } else {
          return Column(
            children: [ShimmerCard(), ShimmerCard()],
          );
        }
      },
    );
  }

  Widget _titulos(String titulo) {
    return Container(
      padding: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
      child: Text('$titulo', style: TextStyle(fontSize: 25.0, fontFamily: 'GoldplayBlack', color: prs.colorGrisOscuro)),
    );
  }
}