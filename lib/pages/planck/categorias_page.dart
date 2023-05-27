import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mimo/bloc/cajero_bloc.dart';
import 'package:mimo/bloc/catalogo_bloc.dart';
import 'package:mimo/bloc/direccion_bloc.dart';
import 'package:mimo/bloc/promocion_bloc.dart';
import 'package:mimo/dialog/direccion_dialog.dart';
import 'package:mimo/model/catalogo_model.dart';
import 'package:mimo/model/categoria_model.dart';
import 'package:mimo/model/chat_compra_model.dart';
import 'package:mimo/model/chat_despacho_model.dart';
import 'package:mimo/model/despacho_model.dart';
import 'package:mimo/model/direccion_model.dart';
import 'package:mimo/pages/delivery/menu_page.dart';
import 'package:mimo/pages/delivery/solicitud_page.dart';
import 'package:mimo/pages/planck/direccion_page.dart';
import 'package:mimo/preference/deep_link.dart';
import 'package:mimo/preference/push_provider.dart';
import 'package:mimo/preference/shared_preferences.dart';
import 'package:mimo/providers/categoria_provider.dart';
import 'package:mimo/providers/cliente_provider.dart';
import 'package:mimo/sistema.dart';
import 'package:mimo/utils/conexion.dart';
import '../../card/shimmer_card.dart';
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/menu_widget.dart';
import '../../utils/permisos.dart' as permisos;
import '../../utils/conf.dart' as config;
import '../../utils/conf.dart' as conf;
import '../../widgets/comprar_catalogo_widget.dart';
import '../../utils/dialog.dart' as dlg;

class CategoriasPage extends StatefulWidget {
  final bool isDeeplink;
  const CategoriasPage({Key key, this.isDeeplink: false}) : super(key: key);
  @override
  State<CategoriasPage> createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage>
    with WidgetsBindingObserver {
  void disposeStreams() {
    _cambios?.close();
  }

  @override
  void initState() {
    bool _init = false;
    _cambios.stream.listen((internet) {
      if (!mounted) return;
      if (internet && _init) {
        _catalogoBloc.listarAgencias(_selectedIndex,
            direccionModel: _direccionBloc.direccionSeleccionada);
      }
      _direccionBloc.listar();
      _init = true;
      _refrezcar();
    });
    _typeControllerDireccion.text = _direccionBloc.direccionSeleccionada.alias;
    Conexion();
    WidgetsBinding.instance.addObserver(this);
    if (_direccionBloc.direccionSeleccionada.idUrbe <= 0) {
      _direccionBloc.direccionSeleccionada.idUrbe = int.parse(_prefs.idUrbe);
    }
    _catalogoBloc.listarAgencias(_selectedIndex,
        direccionModel: _direccionBloc.direccionSeleccionada);
    _direccionBloc.listar();
    _promocionBloc.listar();
    super.initState();
    _pushProvider.context = context;
    _pushProvider.chatsCompra.listen((ChatCompraModel chatCompraModel) {
      if (!mounted) return;
      _cajeroBloc.actualizarPorChat(chatCompraModel);
    });
    _pushProvider.objects.listen((despacho) {
      if (!mounted) return;
      DespachoModel _despacho = despacho;
      _cajeroBloc.actualizaridDespacho(
          _despacho.idCompra, _despacho.idDespacho, conf.COMPRA_DESPACHADA);
    });
    _pushProvider.chatsDespacho.listen((ChatDespachoModel chatDespacho) {
      if (!mounted) return;
      if (chatDespacho.idDespachoEstado == conf.DESPACHO_ENTREGADO) {
        _cajeroBloc.actualizarPorEntrega(
            chatDespacho.idDespacho, conf.COMPRA_ENTREGADA);
      }
    });
    _clienteProvider.actualizarToken().then((isActualizo) {
      permisos.verificarSession(context);
    });
    _promocionBloc.carrito();
    deeplink.initDynamicLinks(widget.isDeeplink, context, _start, _end);
    _cargarCategorias(_prefs.idUrbe);
    _pushProvider.cancelAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        permisos.verificarSession(context);
        _refrezcar();
        _pushProvider.cancelAll();
        break;
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  _refrezcar() {
    _promocionBloc.listar(
        isClena: true,
        idUrbe: _direccionBloc.direccionSeleccionada.idUrbe,
        categoria: _categoriaModelSelect.idCategoria);
    switch (_selectedIndex) {
      case 0:
        _catalogoBloc
            .listarAgencias(_selectedIndex,
                direccionModel: _direccionBloc.direccionSeleccionada,
                categoria: _categoriaModelSelect.idCategoria)
            .then((value) {
          if (mounted) if (mounted) setState(() {});
        });
        break;
      case 1:
        _cajeroBloc.listarEnCamino();
        break;
    }
  }

  _start() {
    _saving = true;
    if (mounted) setState(() {});
  }

  _end() {
    _saving = false;
    if (mounted) setState(() {});
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final DeepLink deeplink = DeepLink();
  final CajeroBloc _cajeroBloc = CajeroBloc();
  bool _direccion = false;
  final DireccionBloc _direccionBloc = DireccionBloc();
  ScrollController pageControllerFavoritos = ScrollController();
  StreamController<bool> _cambios = StreamController<bool>.broadcast();

  _mostrarDirecciones() async {
    FocusScope.of(context).requestFocus(FocusNode());
    utils.mostrarProgress(context, barrierDismissible: false);
    await _direccionBloc.listar();
    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (context) {
          return DireccionDialog(_direccionBloc.direcciones, _onselecDireccion);
        });
    _direccion = !_direccion;
  }

  _requestGps() async {
    permisos.localizarTo(context, (lt, lg) {
      if (lt == 2.2)
        return; //Este estado significa q se mostro dialogo para localizar
      _irADireccion(lt, lg);
    }, isForce: false);
  }

  _irADireccion(lt, lg) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DireccionPage(
            lt: lt,
            lg: lg,
            direccionModel: DireccionModel(),
            cajeroModel: null,
            pagina: config.PAGINA_COMPRAS),
      ),
    );
  }

  final CategoriaProvider _categoriaProvider = CategoriaProvider();
  final ClienteProvider _clienteProvider = ClienteProvider();
  final TextEditingController _typeControllerDireccion =
      TextEditingController();
  final PushProvider _pushProvider = PushProvider();
  List<CategoriaModel> categoriasResponse;
  _cargarCategorias(idUrbe) async {
    categoriasResponse = null;
    if (mounted) setState(() {});
    categoriasResponse = await _categoriaProvider.listar(idUrbe);
    if (mounted) setState(() {});
  }

  bool _saving = false;
  _update(mensaje) {
    _saving = true;
    if (mounted) setState(() {});
  }

  _complet() {
    _saving = false;
    if (mounted) if (mounted) setState(() {});
  }

  int _selectedIndex =
      Sistema.idAplicativo != Sistema.idAplicativoCuriosity ? 0 : 0;
  final CatalogoBloc _catalogoBloc = CatalogoBloc();
  consultarDirecciones() async {
    _update('Consultando costo');
    switch (_selectedIndex) {
      case 0:
        await _catalogoBloc.listarAgencias(_selectedIndex,
            direccionModel: _direccionBloc.direccionSeleccionada,
            isConsultar: true);
        break;
      case 1:
        break;
    }
    _direccion = false;
    _complet();
  }

  final PromocionBloc _promocionBloc = PromocionBloc();
  CategoriaModel _categoriaModelSelect = CategoriaModel();
  _onselecDireccion(DireccionModel direccion) {
    Navigator.pop(context);
    if (direccion.idDireccion <= 0) {
      return _requestGps();
    }
    String idUrbe = direccion.idUrbe.toString();
    _promocionBloc.listar(idUrbe: idUrbe);
    if (_prefs.idUrbe != idUrbe) {
      _categoriaModelSelect = CategoriaModel();
      _cargarCategorias(idUrbe);
    }
    _prefs.alias = direccion.alias.toString();
    _clienteProvider.urbe(idUrbe);
    _typeControllerDireccion.text = direccion.alias;
    _direccionBloc.direccionSeleccionada = direccion;
    consultarDirecciones();
    _prefs.idUrbe = idUrbe; //Guardamos la urbe en pereferencias
  }

  irAlCarrito() {
    Navigator.pushNamed(context, 'carrito');
  }

  Widget _label(String titulo, String subTitulo) {
    return Container(
      padding: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('$titulo',
              style: TextStyle(
                color: prs.colorGrisOscuro,
                fontFamily: 'GoldplayBlack',
                fontSize: 24,
              )),
          /* SizedBox(width: 3.0),
          Text(subTitulo, style: TextStyle(color: prs.colorGrisAreaTexto)), */
        ],
      ),
    );
  }

  Widget createListViewTusFavoritos(
      BuildContext context, AsyncSnapshot<List<CatalogoModel>> snapshot) {
    if (snapshot.data.length <= 0 || snapshot.data[0].idAgencia == -100) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _label('Tus favoritos', 'Tu ordenas'),
        ComprarCatalogoWidget(pageControllerFavoritos,
            snapshot: snapshot, onTapCatalogo: _onTapCatalogo),
      ],
    );
  }

  verChat(dynamic idAgencia) {
    _onItemTapped(2, idAgencia: idAgencia);
  }

  _onItemTapped(int index, {dynamic idAgencia: -1}) {
    switch (index) {
      case 0:
        _refrezcar();
        _catalogoBloc.listarAgencias(index,
            direccionModel: _direccionBloc.direccionSeleccionada,
            categoria: _categoriaModelSelect.idCategoria,
            isConsultar: _selectedIndex != index);
        break;
      case 1:
        _cajeroBloc.listarEnCamino();
        break;
    }
    _selectedIndex = index;
    if (mounted) setState(() {});
  }

  _onTapCatalogo(CatalogoModel catalogoModel) {
    FocusScope.of(context)?.requestFocus(FocusNode());
    //Si es de tipo
    if (catalogoModel.tipo == 1) {
      if (catalogoModel.abiero == '1') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuPage(catalogoModel, verChat: verChat),
          ),
        );
      } else {
        _enviarVER() async {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuPage(catalogoModel, verChat: verChat),
            ),
          );
        }

        dlg.mostrar(context, catalogoModel.abiero,
            icon: Icons.menu,
            color: prs.colorBotones,
            fBotonIDerecha: _enviarVER,
            titulo: 'Local cerrado',
            mBotonDerecha: 'VER PRODUCTOS',
            mIzquierda: 'REGRESAR');
      }
    } else if (catalogoModel.tipo == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SolicitudPage(
            _prefs.direccionModel.lt,
            _prefs.direccionModel.lg,
            catalogoModel: catalogoModel,
            pagina: config.PAGINA_SOLICITUD,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MenuWidget(),
      appBar: AppBar(
        elevation: 0,
        leading: utils.leading(context),
        title: Container(
          child: TextButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Text(
                    '¡ Cerca de ${_prefs.alias} !',
                    style:
                        TextStyle(color: prs.colorTextAppBar, fontSize: 16.0),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    softWrap: false,
                  ),
                  width: 150.0,
                ),
                _direccion
                    ? Icon(Icons.keyboard_arrow_up,
                        color: prs.colorRojo, size: 32.0)
                    : Icon(Icons.keyboard_arrow_down,
                        color: prs.colorRojo, size: 32.0)
              ],
            ),
            onPressed: _mostrarDirecciones,
          ),
        ),
        actions: <Widget>[
          (_prefs.isExplorar || _prefs.clienteModel.direcciones >= 1)
              ? IconButton(
                  padding: EdgeInsets.only(right: 30.0),
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
              : Container()
        ],
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          height: double.infinity,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                  SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          '¡Siempre atentos a ti!',
                          style: TextStyle(
                              fontFamily: 'GoldplayRegular',
                              fontWeight: FontWeight.w600,
                              fontSize: 22,
                              color: prs.colorRojo),
                        )),
                      ],
                    ),
                  ),
                  /* SizedBox(
                    height: 20,
                  ), */
                  SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          'CATEGORÍAS',
                          style: TextStyle(
                              fontFamily: 'GoldplayBlack',
                              fontWeight: FontWeight.w600,
                              fontSize: 22,
                              color: Colors.black),
                        )),
                      ],
                    ),
                  ),
                  /* SizedBox(
                    height: 20,
                  ), */
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      height: 400,
                      child: GridView.builder(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: categoriasResponse != null
                            ? categoriasResponse.length
                            : 0,
                        itemBuilder: ((context, index) {
                          if (categoriasResponse.length < 1)
                            return CircularProgressIndicator();
                          return Container(
                            height: 300,
                            width: 150,
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, 'sub_categorias');
                                  },
                                  child: Container(
                                    // width: 150.0,
                                    child: Card(
                                      color: Colors.white,
                                      elevation: 1.0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0)),
                                      child: Container(
                                        alignment: AlignmentDirectional.center,
                                        child: Stack(
                                          children: [
                                            categoriasResponse[index].nombre ==
                                                    'Licores'
                                                ? SvgPicture.asset(
                                                    'assets/svg/fondoCategorias.svg',
                                                    width: double.infinity,
                                                    color: Colors.red)
                                                : SvgPicture.asset(
                                                    'assets/svg/fondoCategorias.svg',
                                                    width: double.infinity,
                                                    color: Color(
                                                            (Random().nextDouble() *
                                                                        0xFFFFFF)
                                                                    .toInt() <<
                                                                0)
                                                        .withOpacity(1.0),
                                                  ),
                                            Container(
                                              width: double.infinity,
                                              alignment:
                                                  AlignmentDirectional.center,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(height: 20.0),
                                                  Container(
                                                    child: Text(
                                                        "${categoriasResponse[index].nombre}",
                                                        overflow:
                                                            TextOverflow.visible,
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          fontSize: 20.0,
                                                          color: Colors.black,
                                                        )),
                                                  ),
                                                  SizedBox(height: 15.0),
                                                  Container(
                                                    alignment:
                                                        AlignmentDirectional
                                                            .center,
                                                    width: 190.0,
                                                    height: 100.0,
                                                    decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  40)),
                                                    ),
                                                    child: Container(
                                                        child: Image(
                                                      image: NetworkImage(
                                                        categoriasResponse[index].img,
                                                      ),
                                                      width: 200,
                                                    )
                                                        ),
                                                  ),
                                                  SizedBox(height: 3.0),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  /* SizedBox(
                    height: 20,
                  ), */
                  SliverToBoxAdapter(
                    child: StreamBuilder(
                      stream: _catalogoBloc.favoritoStream,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.length <= 0) return Container();
                          return createListViewTusFavoritos(context, snapshot);
                        }
                        return ShimmerCard();
                      },
                    ),
                  ),
                ],
            ),
          ),
        ),
      ),
    );
  }
}