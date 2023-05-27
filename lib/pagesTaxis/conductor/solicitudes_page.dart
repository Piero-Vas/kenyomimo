import 'package:flutter/material.dart';
import 'package:mimo/pagesTaxis/conductor/detalle_solicitud_page.dart';
import 'package:mimo/widgets/menu_taxis_widget.dart';
import '../../../utils/personalizacion.dart' as prs;

class SolicitudesTaxiPage extends StatefulWidget {
  const SolicitudesTaxiPage({Key key}) : super(key: key);

  @override
  State<SolicitudesTaxiPage> createState() => _SolicitudesTaxiPageState();
}

class _SolicitudesTaxiPageState extends State<SolicitudesTaxiPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuWidgetTaxis(),
        appBar: AppBar(
          // backgroundColor: Colors.white,
          // shadowColor: Colors.black,
          centerTitle: true,
          title: Text(
            "Solicitudes",
            style: TextStyle(
                color: Color(0xFF4B4B4E),
                fontSize: 24,
                fontFamily: 'GoldplayRegular',
                fontWeight: FontWeight.w700),
          ),
          iconTheme: IconThemeData(
            color: prs.colorMorado,
          ),
          elevation: 0,
          leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.all(15.0),
            child: GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: Image(
                image: AssetImage("assets/png/menu.png"),
              ),
            ),
          ),
        ),
          actions: [
            GestureDetector(
              onTap: (){},
              child: Image(
                        image: AssetImage("assets/png/config.png"),
                        height: 25,
                        width: 25,
                      ),
            ),
          ],
        ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            solicitudes(context, 11, 1, true),
            Divider(
              thickness: 1,
            ),
            solicitudes(context, 13, 2, false),
            Divider(
              thickness: 1,
            ),
            solicitudes(context, 10, 3, false),
            Divider(
              thickness: 1,
            ),
            solicitudes(context, 20, 4, false)
          ],
        ),
      ),
    );
  }
}

Widget solicitudes(context, precio, tipo, espera) {
  return GestureDetector(
    onTap: (){
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  DetalleSolicitudPage()));
    },
    child: Container(
      padding: EdgeInsets.only(top: 10, right: 20, left: 20),
      child: Row(
        children: [
          Container(
            // color: Colors.red,
            width: MediaQuery.of(context).size.width * 0.7 - 20,
            child: Column(
              children: [
                Row(
                  children: [
                    Image(
                      image: AssetImage("assets/png/indicador.png"),
                      height: 25,
                      width: 25,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: 150,
                      child: Text(
                        "Av.Larco 304",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'GoldplayRegular',
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Image(
                      image: AssetImage("assets/png/indicador2.png"),
                      height: 25,
                      width: 25,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: 200,
                      child: Text(
                        "Open Plaza Los Jardines",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'GoldplayRegular',
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: tipo == 1
                          ? BoxDecoration(
                              color: Color(0xFF15AC6D),
                              borderRadius: BorderRadius.circular(20))
                          : tipo == 2
                              ? BoxDecoration(
                                  color: Color(0xFF1746A2),
                                  borderRadius: BorderRadius.circular(20))
                              : tipo == 3
                                  ? BoxDecoration(
                                      color: Color(0xFF841195),
                                      borderRadius: BorderRadius.circular(20))
                                  : tipo == 4
                                      ? BoxDecoration(
                                          color: Color(0xFF3CB3AE),
                                          borderRadius: BorderRadius.circular(20))
                                      : BoxDecoration(
                                          color: Color(0xFF15AC6D),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                      child: Text(
                        tipo == 1
                            ? "S/$precio, Pago con efectivo"
                            : tipo == 2
                                ? "S/$precio, Pago con tarjeta"
                                : tipo == 3
                                    ? "S/$precio, Pago con Yape"
                                    : tipo == 4
                                        ? "S/$precio, Pago con Plin"
                                        : "Linea 115",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'GoldplayRegular',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    espera
                        ? Image(
                            image: AssetImage("assets/png/clock.png"),
                            height: 25,
                            width: 25,
                          )
                        : Container(),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      "500 m",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: prs.colorGrisClaro,
                        fontSize: 14,
                        fontFamily: 'GoldplayRegular',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            // color: Colors.green,
            width: MediaQuery.of(context).size.width * 0.3 - 20,
            child: Column(
              children: [
                Container(
                  // color: Colors.red,
                  width: 90,
                  height: 90,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14.0),
                    child: Image.asset(
                      "assets/png/calificacion.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Text(
                  "Luis Pérez",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    // color: prs.colorGrisAreaTexto,
                    fontSize: 14,
                    fontFamily: 'GoldplayRegular',
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      color: prs.colorMorado,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "4.2",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'GoldplayBlack',
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "(200)",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'GoldplayRegular',
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    ),
  );
}
