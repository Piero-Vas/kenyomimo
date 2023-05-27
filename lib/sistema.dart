import 'dart:io';

import 'package:universal_platform/universal_platform.dart';

class Sistema {
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  //OJO esta IP http://10.0.2.2/ es util para quienes estan levantando el servidor de recursos en la misma maquina donde tambien
  //Estan corriendo el APP en el emulador dejo link para mas detalles https://stackoverflow.com/questions/6760585/accessing-localhostport-from-android-emulator
  static const String DOMINIO_GLOBAL = 'http://104.248.1.138/';

  //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  static const int MINUMUN_VERSION = 0;

  static const String ID_CLIENTE = 'AAAAA';
  static String idUuid = '100050-GV@TXP5S&CI3RC020EWWTQYT7-2-1000001/JP';
  static const String AUTH_CLIENTE = '/LKHJGASLJKHG/97647/LKHGJH/LKGJLH';

  static const String SEARCH_MENSJAE = '¿Qué estás buscando?';

  static const String MESAJE_SHARE_LINK =
      'Descarga gratis Mimo y encuentra promociones exclusivas.';

  static const String MESAJE_CATALOGO =
      'Registra la dirección donde enviaremos tu compra.';

  static const bool ID_VERIFICAR_URBE = true;
  static const bool IS_BACKGROUND = false;
  static const String ID_URBE = '1';

  static const int TARGET_WIDTH_PERFIL = 400;
  static const int TARGET_WIDTH_CHAT = 600;
  static const int TARGET_WIDTH_PROMO = 800;

  static const int IS_ACREDITADO = 200;
  static const int IS_TOKEN = 300;

  static const String EFECTIVO = 'Efectivo';
  static const String TARJETA = 'Tarjeta';
  static const String ID_FOMRA_PAGO_TARJETA = '23';
  static const String CUPON = 'Cupón';

  //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  static bool isTestMode = false;
  static const String MENSAJE_NUEVA_CAR = ''; //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  static const String CLIENT_APP_CODE = ""; //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  static const String CLIENTE_APP_KEY = ""; //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  static const sloganCuriosity =
      'Mimo, para las personas que quieren más.';
  static const aplicativoCuriosity = 'MIMO';
  static const idAplicativoCuriosity = 1000001;
  static const aplicativoTitleCuriosity = 'Mimo';
  static const packageNameCuriosity = 'com.deliverytaxi.mimo';
  static const appStoreIdCuriosity = '1488624281';
  static const uriDynamicCuriosity = 'https://TU.DOMINIO.COM/WEB';
  static const double lt = -9.646501;
  static const double lg = -77.094415;

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  static const _aplicativo = aplicativoCuriosity;
  static const _idAplicativo = idAplicativoCuriosity;
  static const _packageName = packageNameCuriosity;
  static const _appStoreId = appStoreIdCuriosity;
  static const _slogan = sloganCuriosity;
  static const _uriDynamic = uriDynamicCuriosity;
  static const aplicativoTitle = aplicativoTitleCuriosity;

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  static String get dominio => DOMINIO_GLOBAL;

  static String get slogan => _slogan;

  static String get aplicativo => _aplicativo;

  static int get idAplicativo => _idAplicativo;

  static get storage => 'https://firebasestorage.googleapis.com/v0/b/';

  static get uriPrefix =>
      'https://${aplicativo.toLowerCase()}.TU.DOMINIO.COM'; //La barra al final causa problemas en iOS

  static get uriDynamic => _uriDynamic;

  static get packageName => _packageName;

  static get appStoreId => _appStoreId; //bundleId

  static get isAndroid => UniversalPlatform.isAndroid;

  static get isIOS => UniversalPlatform.isIOS;

  static get isWeb => UniversalPlatform.isWeb;

  String operatingSystem() {
    return (Sistema.isAndroid
            ? Platform.operatingSystem
            : Sistema.isIOS
                ? Platform.operatingSystem
                : 'WEB')
        .toString();
  }
  //   Compra 
  // 1. Iniciada = Cuando presiona "Realizar Pedido"
  // 2. Consultando = A la espera de un motorizado
  // 3. Comprada = Cuando el conductor acepta 
  // 4. Despachado = Cuando presiona el boton de recogido
  // 200. Entregado = Cuando presiona el boton de entregado 
  // 100. Cancelado

  // Despacho
  // 1. Procesando = Listado de solicitudes
  // 2. Viajando = Cuando el conductor acepta 
  // 3. Recogido = Cuando presiona el boton de recogido
  // 4. Entregado = Cuando presiona el boton de entregado
  // 100. Cancelada = Cuando el cliente o motorizado cancela
}
