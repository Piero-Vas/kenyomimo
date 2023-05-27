import 'package:flutter/material.dart';
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;

class SobreAppPage extends StatefulWidget {
  const SobreAppPage({Key key}) : super(key: key);

  @override
  State<SobreAppPage> createState() => _SobreAppPageState();
}

class _SobreAppPageState extends State<SobreAppPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // foregroundColor: Colors.transparent,
        elevation: 0,
        leading: utils.leadingTaxi(context, prs.colorMorado),
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/png/quienessomos.jpeg'),
                      fit: BoxFit.cover),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                    ),
                    Text(
                      '¿QUIÉNES SOMOS?',
                      style: TextStyle(
                          fontSize: 30,
                          fontFamily: 'GoldplayBlack',
                          color: Colors.white),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                          'Mimo está en el centro de un mercado que conecta a tres jugadores: clientes, restaurantes y supermercados, y pasajeros. El objetivo principal de esta conexión es facilitar una experiencia de compra inolvidable, de esta forma crecer conjuntamente. Queremos ser una plataforma a la que recurran las personas cuando piensan en comida o taxi.',
                          style: TextStyle(
                              fontSize: 17,
                              fontFamily: 'GoldplayRegular',
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                    SizedBox(
                      height: 100,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'SOMOS MULTIFACÉTICOS',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 30,
                                fontFamily: 'GoldplayBlack',
                                color: prs.colorAmarillo),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                        'Mimo está en el centro de un mercado que conecta a tres jugadores: clientes, restaurantes y supermercados, y pasajeros. El objetivo principal de esta conexión es facilitar una experiencia de compra inolvidable, de esta forma crecer conjuntamente. Queremos ser una plataforma a la que recurran las personas cuando piensan en comida o taxi.',
                        style: TextStyle(
                            fontSize: 17,
                            fontFamily: 'GoldplayRegular',
                            fontWeight: FontWeight.w600,
                            color: prs.colorAmarillo)),
                    SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                color: prs.colorRojo,
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      child: Image(
                        image: AssetImage('assets/png/aplicacion.png'),
                        height: 200,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'APLICACIÓN DE DELIVERY 100 % PERUANA EN TODO LIMA SUR',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 30,
                                fontFamily: 'GoldplayBlack',
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        // height: 200,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30)),
                        padding: EdgeInsets.all(30),
                        child: Text(
                          'Abarcamos: Surco, Barranco, Chorrillos, San Juan de Miraflores, Villa María del Triunfo, Villa El Salvador, Lurín, Pachacamac, Punta Hermosa, Punta Negra.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'GoldplayRegular',
                              color: prs.colorRojo),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'PASARELA DE PAGOS',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 30,
                                fontFamily: 'GoldplayBlack',
                                color: prs.colorMorado),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                        'Nuestro aplicativo cuenta con la psarella de pagos de Openpay BBVA, Ellos nos proporcionan la plataforma de comercio electronico en linea que nos permite ser intermediarios de los productos y servicios que nos pueden adquirir por medio de nuestra plataforma.',
                        style: TextStyle(
                            fontSize: 17,
                            fontFamily: 'GoldplayRegular',
                            fontWeight: FontWeight.w600,
                            color: prs.colorMorado)),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
