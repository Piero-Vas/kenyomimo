import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

InputDecoration decorationSearch(String labelText) {
  return InputDecoration(
      /* labelStyle: TextStyle(color: colorTextTitle), */
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(20)),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(20)),
      suffixIcon: Icon(Icons.search, size: 27.0, color: colorGrisClaro),
      /* labelText: labelText, */
      hintText: labelText,
      hintStyle: TextStyle(color: colorGrisClaro,fontSize: 13),
      filled: true,
      fillColor: colorGrisAreaTexto);
}

Widget titulo(String label) {
  return Container(
      width: double.infinity,
      alignment: Alignment.bottomLeft,
      child: Text(
        label,
        textAlign: TextAlign.start,
        style: TextStyle(
          color: colorRojo,
          fontFamily: 'GoldplayBlack',
          fontSize: 24,
        ),
      ));
}

Widget tituloTaxi(String label) {
  return Container(
      width: double.infinity,
      alignment: Alignment.bottomLeft,
      child: Text(
        label,
        textAlign: TextAlign.start,
        style: TextStyle(
          color: colorMorado,
          fontFamily: 'GoldplayBlack',
          fontSize: 24,
        ),
      ));
}

Widget subTitulo(String label) {
  return Container(
      width: double.infinity,
      alignment: Alignment.bottomLeft,
      child: Text(
        label,
        textAlign: TextAlign.start,
        style: TextStyle(
            color: colorGrisOscuro,
            fontFamily: 'GoldplayRegular',
            fontSize: 18),
      ));
}

Widget labels(String label) {
  return Container(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Color.fromARGB(151, 0, 0, 0)),
        ),
      ],
    ),
  );
}

InputDecoration decoration(String labelText, Widget prefixIcon,
    {Widget suffixIcon}) {
  return InputDecoration(
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      counterText: '',
      errorStyle: TextStyle(color: Colors.red),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(10)),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(10)),
      contentPadding:
          EdgeInsets.only(bottom: 15.0, left: 15.0, right: 15.0, top: 15),
      hintText: labelText,
      hintStyle: TextStyle(color: Color.fromARGB(151, 0, 0, 0), fontSize: 16),
      filled: true,
      fillColor: colorGrisAreaTexto);
}

InputDecoration decoration2(String labelText, Widget prefixIcon,
    {Widget suffixIcon}) {
  return InputDecoration(
    labelStyle: TextStyle(color: colorTextInputLabel),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    counterText: '',
    errorStyle: TextStyle(color: Colors.red),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: colorLineBorder, width: 1.0),
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: colorLinearProgress, width: 1.0),
    ),
    contentPadding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
    labelText: labelText,
  );
}

Widget textoPantallas(String texto, String color, double size) {
  return Text("$texto".toUpperCase(),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'GoldplayBlack',
        fontSize: size,
        fontStyle: FontStyle.italic,
        color: hexToColor('${color}'),
      ));
}

// const String colorSecondary = '#005b9f'; //Purpura
// get colorAppBar => hexToColor('#005b9f');

//const String colorSecondary = '#673AB7'; //Purpura

/* RojoMimo           = #F73B3B 
   MoradoMimo         = #800059 
   AmarilloMimo       = #F7BC45
   GrisOscuroMimo     = #2D2D31
   GrisAreaTexto      = #F4F4F5
   GrisBordes         = #B1B1B4
   */

const String colorSecondary = '#F73B3B'; //RojoMimo

get colorBotones => hexToColor('#F73B3B'); //RojoMimo

get colorGrisClaro => hexToColor('#97979B');

get colorMorado => hexToColor('#800059'); //MoradoMimo

get colorGrisBordes => hexToColor('#B1B1B4'); //GrisBordes

get colorRojo => hexToColor('#F73B3B'); //RojoMimo

get colorAmarillo => hexToColor('#F7BC45'); //AmarilloMimo

get colorGrisOscuro => hexToColor('#2D2D31'); //GrisOscuroMimo

get colorGrisAreaTexto => hexToColor('#F4F4F5'); //GrisAreaTexto

get colorAppBar => hexToColor('#FFFFFF'); //Blanco

get colorButtonBackground => hexToColor('#FBF9F7'); //Blanco

get colorButtonSecondary => hexToColor(colorSecondary);

get colorButtonPrimary => hexToColor('#FFFFFF'); //Blanco

get colorTextButtonPrimary => hexToColor(colorSecondary);

get colorTextButton => hexToColor(colorSecondary);

get colorCanvas => hexToColor('#F8F8F8'); //gris muy claro

get colorLinearProgress => hexToColor(colorSecondary);

get colorTextTitle => hexToColor('#0E0525'); //Morado oscuro

get colorTextDescription => hexToColor('#212A37'); //Morado mas claro

get colorTextInputLabel => hexToColor(colorSecondary);

get colorLineBorder => hexToColor('#DDDDDD'); //Gris claro

get colorIcons => hexToColor(colorSecondary);

get colorIconsAppBar => hexToColor('#F73B3B'); //RojoMimo

get colorTextAppBar => hexToColor('#000000'); //Negro

get iconoFacebook => Icon(FontAwesomeIcons.facebookF,
    color: hexToColor('#1977F3'), size: 30.0); //AzulFB

get iconoGoogle =>
    Icon(FontAwesomeIcons.google, color: colorBotones, size: 30.0);

get iconoApple => Icon(FontAwesomeIcons.apple, color: Colors.white, size: 30.0);

get iconoCorreo => Icon(Icons.email, color: colorIcons);

get iconoNombres => Icon(FontAwesomeIcons.peopleArrows, color: colorIcons);

get anchoFormulario {
  return 500.0;
}

get ancho {
  return 1100.0;
}

get iconoApp => Icon(FontAwesomeIcons.opencart, color: colorIcons, size: 55.0);

get iconoCheck => Icon(FontAwesomeIcons.fingerprint, color: colorIcons);

get iconoCompras => Icon(FontAwesomeIcons.opencart, color: colorIcons);

get iconoPaquetes => Icon(FontAwesomeIcons.handHoldingDollar, color: colorIcons);

get iconoVentas => Icon(FontAwesomeIcons.handHoldingHeart, color: colorIcons);

get iconoRegistrar => Icon(Icons.touch_app, color: colorIcons);

get iconoIngresar => Icon(Icons.beenhere, color: colorIcons);

get iconoCelular => Icon(Icons.phone_android, color: colorIcons);

get iconoLink => Icon(FontAwesomeIcons.link, color: colorIcons);

get iconoCahs => Icon(FontAwesomeIcons.wallet, color: colorIcons, size: 22.0);

get iconoMoney =>
    Icon(FontAwesomeIcons.moneyBillWave, color: colorIcons, size: 22.0);

get iconoCredito =>
    Icon(FontAwesomeIcons.creditCard, color: colorIcons, size: 22.0);

get iconoContrasenia =>
    Icon(FontAwesomeIcons.key, color: colorIcons, size: 22.0);

get iconoPolitica => Icon(FontAwesomeIcons.userLock, color: colorIcons);

get iconoTerminos => Icon(FontAwesomeIcons.book, color: colorIcons);

get iconoContraseniaNueva =>
    Icon(FontAwesomeIcons.unlock, color: colorIcons, size: 22.0);

get iconoCarrito =>
    Icon(Icons.add_shopping_cart, color: Colors.white, size: 35.0);

get iconoCarritoProducto =>
    Icon(Icons.add_shopping_cart, color: Colors.white, size: 25.0);

get iconoAgregarCarrito =>
    Icon(FontAwesomeIcons.cartArrowDown, color: colorIcons, size: 22.0);

get iconoAgregarCarritoPromo =>
    Icon(FontAwesomeIcons.cartArrowDown, color: colorIcons, size: 27.0);

get iconoAgregarCarritoProducto =>
    Icon(FontAwesomeIcons.cartArrowDown, color: colorIcons, size: 16.0);

get iconoCerrarSession => Icon(FontAwesomeIcons.arrowRightFromBracket, color: colorIcons);

get iconoCerrarSessionTaxi => Icon(FontAwesomeIcons.arrowRightFromBracket, color: colorMorado);

get iconoSalir => Icon(FontAwesomeIcons.doorOpen, color: colorIcons);

get iconoBuscar => Icon(FontAwesomeIcons.magnifyingGlassPlus, color: colorIcons);

get iconoDetalle =>
    Icon(FontAwesomeIcons.fileSignature, color: colorIcons, size: 25.0);

get iconoAbout => Icon(FontAwesomeIcons.atlassian, color: colorIcons);

get iconoRegistroFoto => Icon(FontAwesomeIcons.cameraRetro, color: colorIcons);

get iconoPromocion => Icon(Icons.card_giftcard, color: colorIcons, size: 29.0);

get iconoDirecciones =>
    Icon(FontAwesomeIcons.map, color: colorIcons, size: 22.0);

get iconoDespachar => Icon(FontAwesomeIcons.route, color: Colors.white);

get iconoDespachando => Icon(FontAwesomeIcons.rocket, color: Colors.green);

get iconoContactanos =>
    Icon(FontAwesomeIcons.envelopeOpenText, color: colorIcons, size: 21.0);

get iconoPuntos => Icon(FontAwesomeIcons.award, color: colorIcons, size: 25.0);

get iconoNotificacion =>
    Icon(FontAwesomeIcons.bell, color: colorIcons, size: 25.0);

get iconoComprar =>
    Icon(FontAwesomeIcons.moneyBillWave, color: colorIcons, size: 21.0);

get iconoDinero => Icon(Icons.attach_money, color: colorIcons, size: 22.0);

get iconoObsequio =>
    Icon(FontAwesomeIcons.gift, color: colorIconsAppBar, size: 30.0);

get iconoMenuMetodoPago =>
    Icon(FontAwesomeIcons.creditCard, color: colorIcons, size: 22.0);

get iconoPay => Icon(FontAwesomeIcons.qrcode, color: colorIcons, size: 22.0);

get iconoCodigo =>
    Icon(FontAwesomeIcons.hashtag, color: colorIcons, size: 18.0);

get iconoPresionar => Icon(FontAwesomeIcons.handPointUp, color: colorIcons);

get iconoChat => Icon(FontAwesomeIcons.solidCommentDots, color: Colors.green);

get iconoLlamar => Icon(FontAwesomeIcons.phone, color: Colors.green);

get iconoActivo => Icon(FontAwesomeIcons.userCheck, color: Colors.green);

get iconoDesActivo => Icon(FontAwesomeIcons.userSlash, color: Colors.red);

get iconoChatActivo => Icon(FontAwesomeIcons.commentsDollar, color: Colors.red);

get iconoRuta => Icon(FontAwesomeIcons.route, color: colorIcons);

get iconoArrastrar => Icon(FontAwesomeIcons.bars, color: Colors.black);

get iconoAgencia => Icon(FontAwesomeIcons.city, color: colorIcons);

get iconoPreRegistroAgencia =>
    Icon(FontAwesomeIcons.hubspot, color: colorIcons);

get iconoSucursal =>
    Icon(FontAwesomeIcons.store, color: colorIcons, size: 20.0);

get iconoTurno => Icon(FontAwesomeIcons.bell, color: colorIcons);

get iconoHorario => Icon(FontAwesomeIcons.calendarDay, color: colorIcons);

get iconoCasa => Icon(Icons.home, color: colorIcons);

get iconoCasaOutLined =>
    Icon(Icons.home_outlined, color: colorIcons, size: 25.0);

get iconoLocationBuscar =>
    Icon(Icons.location_searching, color: colorIcons, size: 25.0);

get iconoLocationCentro =>
    Icon(Icons.location_searching, color: colorIcons, size: 30.0);

get iconoGuardarDireccion => Icon(Icons.save, color: colorIcons);

get iconoGuardarRuta => Icon(Icons.save, color: colorIcons);

get iconoSolicitarCalificar =>
    Icon(FontAwesomeIcons.faceGrinBeam, color: colorIcons);

get iconoCancelada => Icon(FontAwesomeIcons.faceFrown, color: Colors.blueGrey);

get iconoRecibirDinero =>
    Icon(FontAwesomeIcons.handHoldingDollar, color: Colors.white);

get iconoMetodoPago =>
    Icon(FontAwesomeIcons.handHoldingDollar, color: colorIcons, size: 21.0);

get iconoFactura => Icon(FontAwesomeIcons.penToSquare, color: colorIcons, size: 20.0);

get iconoTarjeta =>
    Icon(FontAwesomeIcons.creditCard, color: colorIcons, size: 30.0);

get iconoButtonTarjeta => Icon(FontAwesomeIcons.creditCard, color: colorIcons);

get iconoPagoTarjeta =>
    Icon(FontAwesomeIcons.creditCard, color: Colors.redAccent, size: 35.0);

get iconoPagoCupon =>
    Icon(FontAwesomeIcons.gift, color: Colors.redAccent, size: 35.0);

get iconoPagoEfefcivo =>
    Icon(FontAwesomeIcons.moneyBillWave, color: Colors.green, size: 35.0);

get iconoCompartir => Icon(FontAwesomeIcons.share, color: colorIcons);

get iconoDespachor => Icon(FontAwesomeIcons.peopleCarryBox, color: colorIcons);

get iconoDespachador => Icon(FontAwesomeIcons.peopleCarryBox, color: Colors.white);

get iconoRecoger => Icon(FontAwesomeIcons.hands, color: Colors.white);

get iconoDespachadorGreen =>
    Icon(FontAwesomeIcons.peopleCarryBox, color: Colors.green);

get iconoCancelar =>
    Icon(FontAwesomeIcons.circleXmark, color: Colors.red, size: 25.0);

get iconoTomarFoto => Icon(Icons.camera_alt, color: colorIcons);

get iconoSubirFoto => Icon(FontAwesomeIcons.image, color: colorIcons);

get iconoEnviarMensaje => Icon(Icons.send, color: colorIcons);

get iconoViajeIniciado =>
    Icon(FontAwesomeIcons.satelliteDish, color: colorIcons);

get iconoViaje => Icon(FontAwesomeIcons.road, color: colorIcons);

get iconoPoolConfirmado =>
    Icon(FontAwesomeIcons.handshake, color: Colors.green, size: 21.0);

get iconoPool =>
    Icon(FontAwesomeIcons.userClock, color: Colors.red, size: 21.0);

get iconoIniciarViaje => Icon(FontAwesomeIcons.car, color: Colors.green);

get iconoClienteAbordo =>
    Icon(FontAwesomeIcons.handshakeAngle, color: Colors.green);

get iconoClienteLlego =>
    Icon(FontAwesomeIcons.handHoldingDollar, color: Colors.green);

get iconoPersona => Icon(Icons.person_outlined, color: colorIcons);

get iconoAyuda => Icon(Icons.headset_mic_outlined, color: colorIcons);

get iconoExclamacion =>
    Icon(FontAwesomeIcons.circleExclamation, color: colorIcons);
