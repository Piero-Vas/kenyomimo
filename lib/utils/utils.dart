import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:badges/badges.dart' as bagges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../model/catalogo_model.dart';
import '../model/promocion_model.dart';
import '../preference/shared_preferences.dart';
import '../providers/catalogo_provider.dart';
import '../providers/cliente_provider.dart';
import '../sistema.dart';
import '../utils/global.dart';
import '../utils/permisos.dart' as permisos;
import '../utils/personalizacion.dart' as prs;
import '../widgets/icon_aument_widget.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;

//Agregados
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

Future<dynamic> comprimirImagen(
    String path, int calidad, int elwidth, int elheight) async {
  final ruta = p.join((await path_provider.getTemporaryDirectory()).path,
      '${DateTime.now().millisecondsSinceEpoch}.${p.extension(path)}');

  var result = await FlutterImageCompress.compressAndGetFile(path, ruta,
      quality: calidad, minWidth: elwidth, minHeight: elheight);
  return result;
}

final PreferenciasUsuario _prefs = PreferenciasUsuario();

void registrarse(BuildContext context, _scaffoldKey) {
  final ClienteProvider _clienteProvider = ClienteProvider();
  mostrarProgress(context, barrierDismissible: false);
  _clienteProvider.cerrarSession((estado, error) {
    if (estado == 1) {
      permisos.cerrasSesion(context);
    } else {
      mostrarSnackBar(error, _scaffoldKey, milliseconds: 2500);
      Navigator.pop(context);
      Navigator.pop(context);
    }
  });
}

final AudioPlayer _audioPlayer = AudioPlayer();

play(String audio) async {
  _audioPlayer.play(UrlSource(audio));
}

bool isNumeric(String s) {
  if (s.isEmpty) return false;
  return (num.tryParse(s) == null) ? false : true;
}

String marca;
String modelo;

String so;
String imei;
String iPD;
String pysics;

String clean(String cadena) {
  return cadena
      .toString()
      .replaceAll('’', '')
      .replaceAll('\'', '')
      .replaceAll('\"', '')
      .replaceAll(new RegExp(r"[^\s\w]"), '');
}

get headers => {
      "idaplicativo": '${Sistema.idAplicativo}',
      "vs": "0.0.8",
      "idplataforma": Sistema.isAndroid
          ? '1'
          : Sistema.isIOS
              ? '2'
              : '3',
      "system": Sistema().operatingSystem(),
      "marca": clean(marca),
      "modelo": clean(modelo),
      "so": clean(so),
      "iph": clean(iPD),
      "red": GLOBAL.connectivityResult,
      "referencia": "12.03.91",
      "imei": clean(imei),
      "key": clean(pysics),
    };

String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}

Future<bool> getDeviceDetails({String uuid: ''}) async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> datosGeneral = (await FirebaseFirestore.instance.collection("agency").doc("agency_1").get()).data();

  _prefs.mustUpdate = datosGeneral['version']=='1.0.86'?false:true;
    
  if (Sistema.isAndroid) {
    var build = await deviceInfoPlugin.androidInfo;
    marca = build.manufacturer;
    modelo = build.display;
    so = build.version.sdkInt.toString();
    iPD = build.isPhysicalDevice.toString();
    if (uuid == '') {
      pysics = generateMd5('${build.model}');
      imei = generateMd5('$marca-$pysics-$modelo-${Sistema.idAplicativo}');
    } else {
      pysics = generateMd5('$uuid');
      imei = generateMd5('$marca-$pysics-$modelo-${Sistema.idAplicativo}');
    }
  } else if (Sistema.isIOS) {
    var data = await deviceInfoPlugin.iosInfo;

    marca = data.model;
    modelo = data.name;
    so = data.systemVersion.toString();
    iPD = data.isPhysicalDevice.toString();

    if (uuid == '') {
      pysics = generateMd5('${data.identifierForVendor}');
      imei = generateMd5('$marca-$pysics-$modelo-${Sistema.idAplicativo}');
    } else {
      pysics = generateMd5('$uuid');
      imei = generateMd5('$marca-$pysics-$modelo-${Sistema.idAplicativo}');
    }
  } else if (Sistema.isWeb) {
    imei = generateMd5('$marca-$pysics-$modelo-${Sistema.idAplicativo}');
  }
  return true;
}

mostrarSnackBar(BuildContext context, String mensaje,
    {int milliseconds: 120000}) {
    
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensaje), duration: Duration(microseconds: milliseconds)));
}

void mostrarRadar(BuildContext context, {bool barrierDismissible: true}) {
  showDialog(
    barrierDismissible: barrierDismissible,
    context: context,
    builder: (context) {
      return Center(
        child: CircularProgressIndicator(),
      );
    },
  );
}

void mostrarProgress(BuildContext context, {bool barrierDismissible: false}) {
  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) {
      return Center(child: CircularProgressIndicator());
    },
  );
}

Widget iconoCount(int count) {
  if (count == 0)
    return Icon(FontAwesomeIcons.basketShopping,
        color: prs.colorIconsAppBar, size: 30.0);
  return bagges.Badge(
    position: bagges.BadgePosition.topEnd(top: -10),
    animationDuration: Duration(milliseconds: 300),
    animationType: bagges.BadgeAnimationType.slide,
    badgeContent: Text(count.toString(), style: TextStyle(color: Colors.white)),
    child:
        Icon(FontAwesomeIcons.basketShopping, color: prs.colorIconsAppBar, size: 30.0),
  );
}

Widget modalProductoAgregadoAlCarrito() {
  return Positioned.fill(
    child: Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconAumentWidget(prs.iconoCarritoProducto, size: 22),
          ],
        ),
      ),
    ),
  );
}

Widget modalAgregadoAlCarrito() {
  return Positioned.fill(
    child: Container(
      height: 350,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            prs.iconoCarrito,
            Container(
              padding: EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                  color: Colors.grey[900].withOpacity(0.8),
                  borderRadius: BorderRadius.circular(2.0)),
              child: Text(
                'Agregado al carrito',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget progressIndicator(String mensaje) {
  return Container(
    width: 400.0,
    padding: EdgeInsets.all(50.0),
    child: Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black26,
              offset: Offset(1.0, 1.0),
            ),
          ],
        ),
        height: 70.0,
        child: Row(
          children: <Widget>[
            SizedBox(width: 20.0),
            CircularProgressIndicator(),
            SizedBox(width: 25.0),
            Text(mensaje),
          ],
        ),
      ),
    ),
  );
}

Widget progressRadar() {
  return Center(
    child: CircularProgressIndicator(),
  );
}

Widget crearCelular(String simCountryCode, Function onInputChanged,
    {String celular: ''}) {
  return InternationalPhoneNumberInput(
    onInputChanged: (PhoneNumber phoneNumber) {
      _prefs.simCountryCode = phoneNumber.isoCode;
      onInputChanged(phoneNumber.phoneNumber);
    },
    inputDecoration: prs.decoration('Celular', null),
    ignoreBlank: true,
    countries: ['PE'],
    autoValidateMode: AutovalidateMode.onUserInteraction,
    formatInput: false,
    maxLength: 9,
    onInputValidated: (a) => true,
    selectorConfig: SelectorConfig(selectorType: PhoneInputSelectorType.DIALOG),
    errorMessage: 'Celular incorrecto',
    initialValue: PhoneNumber(isoCode: simCountryCode, phoneNumber: celular),
    validator: (value) {
      
      return value.isEmpty || value.length < 9 || value[0] != '9'
          ? 'Numero invalido'
          : null;
    },
  );
}

Widget leading(BuildContext context, {String path: '#'}) {
  if (!Sistema.isWeb) return null;

  String routeName;
  if (path != '#')
    routeName = path;
  else if (_prefs.clienteModel.perfil.toString() == '1') {
    routeName = 'compras_cajero';
  } else if (_prefs.clienteModel.perfil.toString() == '2') {
    routeName = 'compras_despacho';
  } else {
    routeName = '';
  }
  return IconButton(
    icon: Icon(
      Icons.arrow_back,
      color: prs.colorIconsAppBar,
    ),
    onPressed: () => Navigator.pushNamed(context, routeName),
  );
}

Widget leadingTaxi(BuildContext context,Color color, {String path: '#'}) {
  if (!Sistema.isWeb) return null;

  String routeName;
  if (path != '#')
    routeName = path;
  else if (_prefs.clienteModel.perfil.toString() == '1') {
    routeName = 'compras_cajero';
  } else if (_prefs.clienteModel.perfil.toString() == '2') {
    routeName = 'compras_despacho';
  } else {
    routeName = '';
  }
  return IconButton(
    icon: Icon(
      Icons.arrow_back,
      color: color,
    ),
    onPressed: () => Navigator.pushNamed(context, routeName),
  );
}

accionLeading(BuildContext context) {
  String path = '#';
  if (!Sistema.isWeb) return null;
  String routeName;
  if (path != '#')
    routeName = path;
  else if (_prefs.clienteModel.perfil.toString() == '1') {
    routeName = 'compras_cajero';
  } else if (_prefs.clienteModel.perfil.toString() == '2') {
    routeName = 'compras_despacho';
  } else {
    routeName = '';
  }
  Navigator.pushNamed(context, routeName);
}

Widget bandaDerecha(bool end, ScrollController pageController) {
  if (end || !Sistema.isWeb) return Container();
  return Positioned(
    right: 0.0,
    child: InkWell(
        child: Container(
          height: 150,
          color: Colors.white38,
          child:
              Icon(Icons.keyboard_arrow_right, size: 50, color: Colors.black),
        ),
        splashColor: Colors.black.withOpacity(0.6),
        onTap: () {
          pageController?.animateTo(pageController.position.pixels + 270,
              duration: new Duration(milliseconds: 900), curve: Curves.ease);
        }),
  );
}

Widget bandaIzquierda(bool start, ScrollController pageController) {
  if (start || !Sistema.isWeb) return Container();
  return Positioned(
    left: 0.0,
    child: InkWell(
        child: Container(
          height: 150,
          color: Colors.white38,
          child: Icon(Icons.keyboard_arrow_left, size: 50, color: Colors.black),
        ),
        splashColor: Colors.black.withOpacity(0.6),
        onTap: () {
          pageController?.animateTo(pageController.position.pixels - 270,
              duration: new Duration(milliseconds: 900), curve: Curves.ease);
        }),
  );
}

Widget estrellas(double initialRating, Function onRatingChanged,
    {double size: 45.0}) {
  return Center(
      child: RatingBar.builder(
    initialRating: initialRating,
    minRating: 1,
    direction: Axis.horizontal,
    allowHalfRating: true,
    itemCount: 5,
    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
    itemBuilder: (context, _) => Icon(
      Icons.star,
      color: Colors.amber,
    ),
    onRatingUpdate: onRatingChanged,
  ));
}

Widget estrellasTaxis(double initialRating, Function onRatingChanged,
    {double size: 45.0}) {
  return Center(
      child: RatingBar.builder(
    initialRating: initialRating,
    minRating: 1,
    direction: Axis.horizontal,
    allowHalfRating: true,
    itemCount: 5,
    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
    itemBuilder: (context, _) => Icon(
      Icons.star_border_rounded,
      color: prs.colorMorado,
    ),
    onRatingUpdate: onRatingChanged,
  ));
}
Widget estrellasTaxis2(double initialRating, Function onRatingChanged,
    {double size: 20.0}) {
  return Center(
      child: RatingBar.builder(
    initialRating: initialRating,
    minRating: 1,
    direction: Axis.horizontal,
    allowHalfRating: true,
    ignoreGestures: true,
    itemCount: 5,
    itemPadding: EdgeInsets.symmetric(horizontal: 0.1),
    itemBuilder: (context, _) => Icon(
      Icons.star_border_rounded,
      color: prs.colorMorado,
    ),
    onRatingUpdate: onRatingChanged,
  ));
}

Future<String> obtenerLinkAgencia(
    CatalogoModel catalogo, Function update, Function complet,
    {bool isEncomiendas = false, PromocionModel promocion}) async {
  if (promocion == null) {
    if (catalogo.link.length > 10) return catalogo.link;
  } else {
    if (promocion.link.length > 10) return promocion.link;
  }

  update();
  String link;
  String url = '';
  if (promocion == null)
    url =
        '${Sistema.uriDynamic}?store=${catalogo.agencia}&catalogo=${catalogo.idAgencia}&key=${new DateTime.now().millisecondsSinceEpoch}';
  else
    url =
        '${Sistema.uriDynamic}?store=${catalogo.agencia}&catalogo=${catalogo.idAgencia}&idP=${promocion.idPromocion}&key=${new DateTime.now().millisecondsSinceEpoch}';
  //Esto para las encomiendas q es otra vista
  if (isEncomiendas)
    url =
        '${Sistema.uriDynamic}?store=${catalogo.agencia}&agencia=${catalogo.idAgencia}&key=${new DateTime.now().millisecondsSinceEpoch}';

  url += '&push=${_prefs.idCliente}#store';

  String imgPromo =
      promocion == null ? catalogo.img.toString() : promocion.imagen.toString();

  try {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: Sistema.uriPrefix,
      link: Uri.parse(url),
      socialMetaTagParameters: SocialMetaTagParameters(
          title: catalogo.agencia,
          imageUrl: Uri.parse(imgPromo),
          description:
              promocion == null ? catalogo.observacion : promocion.producto),
      androidParameters: AndroidParameters(
          packageName: Sistema.packageName,
          minimumVersion: Sistema.MINUMUN_VERSION),
      googleAnalyticsParameters: GoogleAnalyticsParameters(
          campaign: 'store-${Sistema.aplicativo}',
          medium: 'social',
          source: 'orkut'),
    );

    
    final shortenedLink =
        await FirebaseDynamicLinks.instance.buildShortLink(parameters);

    link = shortenedLink.shortUrl.toString();

    link = link.toString().replaceFirst('/', '', link.toString().length - 1);

    if (promocion == null) {
      catalogo.link = link;
      CatalogoProvider().like(catalogo, isShare: true);
    } else {
      CatalogoProvider()
          .like(catalogo, isShare: true, idP: promocion.idPromocion);
      promocion.link = link;
    }
  } catch (err) {
    print('utils.utils _obtenerLink err $err');
  }
  complet();
  return link;
}

Map contentdict = {
  'Failure': ContentType.failure,
  'Help': ContentType.help,
  'Success': ContentType.success,
  'Warning': ContentType.warning,
};

newAlert(context, title, message, content) {
  var snackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: title,
      message: message,
      contentType: contentdict[content],
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
