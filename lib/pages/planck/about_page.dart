import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/* import '../../sistema.dart'; */
import '../../utils/button.dart' as btn;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;

class AboutPage extends StatefulWidget {
  AboutPage({Key key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  _AboutPageState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acerca de'),
        leading: utils.leading(context),
      ),
      body:
          Center(child: Container(child: _body(), width: prs.anchoFormulario)),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(child: SingleChildScrollView(child: _contenido())),
        btn.confirmar('POWERED BY PLANCK', () {
          _launchURL('https://www.planck.biz/');
        }),
      ],
    );
  }

  Column _contenido() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 35.0),
              Image(
                  image: AssetImage('assets/png/login.png'),
                  width: 270.0,
                  fit: BoxFit.cover),
              SizedBox(height: 40.0),
              Text(
                  'Mimo permite generar un acercamiento entre el vendedor y sus clientes mediante un chat interactivo con opciones para envío de imágenes y audio, así como la geolocalización del usuario para el despacho de su producto.',
                  textAlign: TextAlign.center),
              SizedBox(height: 20.0),
              Text(
                  'También te presentamos opciones para visualizar y comprar promociones, historial de compras y un sistema de puntos para calificar y premiar a los mejores usuarios del aplicativo',
                  textAlign: TextAlign.center),
              SizedBox(height: 20.0),
              btn.booton('Política de privacidad', _politicas),
              btn.booton('Términos y condiciones', _terminos),
              SizedBox(height: 80.0),
            ],
          ),
        ),
      ],
    );
  }

  _politicas() {
    _launchURL('https://www.planck.biz/politica-de-privacidad');
  }

  _terminos() {
    _launchURL('https://www.planck.biz/terminos-y-condiciones');
  }

  _launchURL(url) async {
    final Uri _url = Uri.parse(url);
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication))
      throw 'Could not launch $_url';
  }
}
