import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

import '../model/catalogo_model.dart';
import '../pages/delivery/menu_page.dart';
import '../providers/catalogo_provider.dart';
import '../providers/cliente_provider.dart';
import 'shared_preferences.dart';

class DeepLink {
  static DeepLink _instancia;
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  DeepLink._internal();

  factory DeepLink() {
    if (_instancia == null) {
      _instancia = DeepLink._internal();
    }
    return _instancia;
  }

  static PendingDynamicLinkData data;

  void initDynamicLinks(bool isInit, BuildContext context, Function update,
      Function complet) async {
    if (isInit) {
      data = await FirebaseDynamicLinks.instance.getInitialLink();
      final Uri deepLink = data?.link;
      if (deepLink != null) {
        _case(context, update, complet, deepLink.queryParameters);
      }
    }

    dynamicLinks.onLink.listen((dynamicLinkData) {
      if (dynamicLinkData == null) return;
      final Uri deepLink = dynamicLinkData?.link;
      if (deepLink == null) return;
      _case(context, update, complet, deepLink.queryParameters);
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });
  }

  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  _case(BuildContext context, Function update, Function complet,
      queryParameters) {
    String param;
    if (queryParameters.containsKey('auth')) {
      param = queryParameters['auth'];
      if (param == _prefs.param) return;
      _registrarPuntos(param);
    } else if (queryParameters.containsKey('catalogo')) {
      String idCatalogo = queryParameters['catalogo'];
      String idPromocion =
          queryParameters.containsKey('idP') ? queryParameters['idP'] : "0";
      _verCatalogo(context, idCatalogo, idPromocion, update, complet);
    }
    _prefs.param = param;
  }

  CatalogoProvider _catalogoProvider = CatalogoProvider();

  _verCatalogo(BuildContext context, String idCatalogo, String idPromocion,
      Function update, Function complet) async {
    update();
    CatalogoModel catalogoModel = await _catalogoProvider.ver(idCatalogo);
    if (idPromocion.toString().length > 1)
      catalogoModel.idPromocion = idPromocion;
    complet();
    if (catalogoModel == null) return;
    _catalogoProvider.referido(catalogoModel, idP: idPromocion);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MenuPage(catalogoModel)),
        (Route<dynamic> route) {
      return route.isFirst;
    });
  }

  ClienteProvider _clienteProvider = ClienteProvider();

  _registrarPuntos(dynamic idClienteRefiere) async {
    int tipo = 1; //Tipo uno es por referido
    _clienteProvider.canjear(idClienteRefiere, tipo);
  }
}
