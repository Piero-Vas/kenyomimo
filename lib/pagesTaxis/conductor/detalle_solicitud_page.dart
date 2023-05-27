import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../utils/personalizacion.dart' as prs;

class DetalleSolicitudPage extends StatefulWidget {
  const DetalleSolicitudPage({Key key}) : super(key: key);

  @override
  State<DetalleSolicitudPage> createState() => _DetalleSolicitudPageState();
}

class _DetalleSolicitudPageState extends State<DetalleSolicitudPage> {
  Set<Marker> _markers = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(-16.375360, -71.544627),
              zoom: 15,
            ),
            mapType: MapType.normal,
            markers: _markers,
            // onTap: (LatLng posicion) {
            //   Marker miMarcadorNuevo = Marker(
            //     markerId: MarkerId(_markers.length.toString()),
            //     position: posicion,
            //   );
            //   _markers.add(miMarcadorNuevo);
            //   setState(() {});
            // },
          ),
          Column(
            children: [
              Expanded(
                child: Container(),
              ),
              Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      solicitudes(context, 20, 4, false),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigator.of(context).pushAndRemoveUntil(
                              //     MaterialPageRoute(builder: (context) => CatalogoPage()),
                              //     (Route<dynamic> route) {
                              //   return false;
                              // });
                            },
                            child: Text(
                              "Aceptar solicitud",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                                shape: StadiumBorder(),
                                padding: EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                backgroundColor: prs.colorMorado,
                                foregroundColor: prs.colorMorado),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Cerrar",
                              style: TextStyle(color: prs.colorMorado),
                            ),
                            style: ElevatedButton.styleFrom(
                                shape: StadiumBorder(),
                                side: BorderSide(
                                    color: prs.colorMorado, width: 1),
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 20),
                                backgroundColor: Colors.transparent,
                                foregroundColor: prs.colorMorado),
                          ),
                        ),
                      ),
                    ],
                  ))
            ],
          )
        ],
      )),
    );
  }
}

Widget solicitudes(context, precio, tipo, espera) {
  return Container(
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
  );
}
