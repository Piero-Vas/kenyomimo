import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mimo/pagesTaxis/pasajeros/calificacion_page.dart';
import 'package:mimo/pagesTaxis/pasajeros/detalle_viaje_page.dart';
import 'package:mimo/preference/shared_preferences.dart';
import 'package:mimo/widgets/menu_taxis_widget.dart';
import '../../../utils/personalizacion.dart' as prs;

final _prefs = PreferenciasUsuario();
class ViajesPage extends StatefulWidget {
  @override
  _ViajesPageState createState() => _ViajesPageState();
}

class _ViajesPageState extends State<ViajesPage> with AutomaticKeepAliveClientMixin {
  DateTime actual = DateTime.now();
  List<dynamic> misViajes = [];
  List<dynamic> misViajesCancelados = [];
  List<dynamic> viajes = [];
  List<dynamic> viajesCancelados = [];
  var id = _prefs.clienteModel.idCliente;
  @override
  void initState() {
    cargarData();
    getTripsCompletado();
    getTripsCancelado();
    super.initState();
  }

  Future getTripsCompletado() async {
    await FirebaseFirestore.instance
        .collection("trips").where('passengerId', isEqualTo: id.toString()).where('tripCompleted', isEqualTo: true)
        .where('canceled', isEqualTo: false).snapshots().listen((QuerySnapshot<Map<String, dynamic>> result) async {
      misViajes.clear();
      misViajes.addAll(result.docs);
      if (mounted) {
        setState(() {
          viajes = misViajes;
        });
      }
    });
  }

  cargarData() async {
    if (mounted) {
      setState(() {
        actual = DateTime(actual.year, actual.month, actual.day);
      });
    }
  }

  Future getTripsCancelado() async {
    return FirebaseFirestore.instance
        .collection("trips").where('passengerId', isEqualTo: id.toString()).where('canceled', isEqualTo: true)
        // .where('tripCompleted', isEqualTo: false)
        .snapshots().listen((result) async {
      misViajesCancelados.clear();
      misViajesCancelados.addAll(result.docs);
      if (mounted) {
        setState(() {
          viajesCancelados = misViajesCancelados;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool calificado = false;
    bool isborrar = true;
    super.build(context);
    return Scaffold(
        drawer: MenuWidgetTaxis(),
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Mis viajes",
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
          // actions: [
          //   TextButton(
          //       onPressed: () {
          //         setState(() {
          //           isborrar = false;
          //         });
          //       },
          //       child: Text(
          //         "Administrar",
          //         style: TextStyle(
          //             color: prs.colorMorado,
          //             fontSize: 17,
          //             fontFamily: 'GoldplayRegular',
          //             fontWeight: FontWeight.w600),
          //       ))
          // ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                  flex: 1,
                  child: DefaultTabController(
                    length: 2,
                    child: Scaffold(
                      backgroundColor: Colors.white,
                      body: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            height: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: prs.colorGrisAreaTexto,
                              ),
                              child: TabBar(
                                labelStyle: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'GoldplayRegular',
                                    fontWeight: FontWeight.w800),
                                labelColor: Colors.white,
                                unselectedLabelColor:
                                    Color.fromRGBO(30, 30, 31, 1),
                                indicator: BoxDecoration(
                                  color: prs.colorAmarillo,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                tabs: [
                                  Tab(
                                    text: 'Completados',
                                  ),
                                  Tab(
                                    text: 'Cancelados',
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Expanded(
                            flex: 1,
                            child: TabBarView(
                              physics: BouncingScrollPhysics(),
                              children: [
                                Container(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                            physics: BouncingScrollPhysics(),
                                            itemCount: viajes.length,
                                            itemBuilder: (context, i) {
                                              return Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 10),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.0),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: prs
                                                                  .colorGrisBordes),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      25)),
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        20,
                                                                    horizontal:
                                                                        20),
                                                            child: Row(
                                                              children: [
                                                                Column(
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Image(
                                                                          image:
                                                                              AssetImage("assets/png/indicador.png"),
                                                                          height:
                                                                              25,
                                                                          width:
                                                                              25,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Container(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.6,
                                                                          child:
                                                                              Text(
                                                                            misViajes[i]['pickupAddress'],
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 18,
                                                                              fontFamily: 'GoldplayRegular',
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          15,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Image(
                                                                          image:
                                                                              AssetImage("assets/png/indicador2.png"),
                                                                          height:
                                                                              25,
                                                                          width:
                                                                              25,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Container(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.6,
                                                                          child:
                                                                              Text(
                                                                            misViajes[i]['destinationAddress'],
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 18,
                                                                              fontFamily: 'GoldplayRegular',
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                                Expanded(
                                                                    child:
                                                                        Container()),
                                                                IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      showModalBottomSheet(
                                                                        isScrollControlled:
                                                                            true,
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
                                                                        context:
                                                                            context,
                                                                        builder: (context) => StatefulBuilder(builder: (BuildContext
                                                                                context,
                                                                            StateSetter
                                                                                mystate) {
                                                                          return Column(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 5),
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      SizedBox(
                                                                                        height: 30,
                                                                                      ),
                                                                                      misViajes[i]['wasRated']
                                                                                          ? SizedBox()
                                                                                          : Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                                              children: [
                                                                                                Expanded(
                                                                                                    child: TextButton(
                                                                                                        onPressed: () {
                                                                                                          Navigator.push(context, MaterialPageRoute(builder: (context) => CalificacionPage(trip: misViajes[i])));
                                                                                                        },
                                                                                                        style: TextButton.styleFrom(shape: StadiumBorder(), elevation: 0, padding: EdgeInsets.symmetric(vertical: 20), backgroundColor: Colors.transparent, foregroundColor: prs.colorMorado),
                                                                                                        child: Text(
                                                                                                          "Calificar Viaje",
                                                                                                          style: TextStyle(color: prs.colorMorado, fontFamily: 'GoldplayRegular', fontSize: 18, fontWeight: FontWeight.w600),
                                                                                                        )))
                                                                                              ],
                                                                                            ),
                                                                                      Divider(
                                                                                        color: prs.colorGrisBordes,
                                                                                      ),
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Expanded(
                                                                                              child: TextButton(
                                                                                                  onPressed: () {
                                                                                                    Navigator.push(
                                                                                                      context,
                                                                                                      MaterialPageRoute(
                                                                                                        builder: (context) => DetalesViajePage(
                                                                                                          misViajes[i]['createat'],
                                                                                                          misViajes[i]['pickupAddress'],
                                                                                                          misViajes[i]['destinationAddress'],
                                                                                                          misViajes[i]['cost'],
                                                                                                          misViajes[i]['driverName'],
                                                                                                          misViajes[i]['driverLicensePlate'],
                                                                                                          misViajes[i]['distance'],
                                                                                                          misViajes[i]['typePayment'],
                                                                                                           misViajes[i]['driverImg'],
                                                                                                            misViajes[i]['driverTradeMark'],
                                                                                                             misViajes[i]['driverModel'],
                                                                                                                misViajes[i]['passengerCard'],
                                                                                                                  misViajes[i]['passengerName'],
                                                                                                                
                                                                                                             
                                                                                                        ),
                                                                                                      ),
                                                                                                    );
                                                                                                  },
                                                                                                  style: TextButton.styleFrom(shape: StadiumBorder(), elevation: 0, padding: EdgeInsets.symmetric(vertical: 20), backgroundColor: Colors.transparent, foregroundColor: prs.colorMorado),
                                                                                                  child: Text(
                                                                                                    "Detalles de Viaje",
                                                                                                    style: TextStyle(color: prs.colorMorado, fontFamily: 'GoldplayRegular', fontSize: 18, fontWeight: FontWeight.w600),
                                                                                                  )))
                                                                                        ],
                                                                                      ),
                                                                                      SizedBox(
                                                                                        height: 20,
                                                                                      ),
                                                                                      SizedBox(
                                                                                        width: double.infinity,
                                                                                        child: ElevatedButton(
                                                                                          onPressed: () {
                                                                                            Navigator.pop(context);
                                                                                          },
                                                                                          child: Text(
                                                                                            "Cancelar",
                                                                                            style: TextStyle(
                                                                                              color: prs.colorMorado,
                                                                                              fontSize: 15,
                                                                                              fontWeight: FontWeight.w600,
                                                                                              fontFamily: 'GoldplayRegular',
                                                                                            ),
                                                                                          ),
                                                                                          style: ElevatedButton.styleFrom(shape: StadiumBorder(), side: BorderSide(color: prs.colorMorado, width: 1), elevation: 0, padding: EdgeInsets.symmetric(vertical: 20), backgroundColor: Colors.transparent, foregroundColor: prs.colorMorado),
                                                                                        ),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ]);
                                                                        }),
                                                                      );
                                                                    },
                                                                    icon: Icon(
                                                                      Icons
                                                                          .arrow_forward_ios,
                                                                      color: prs
                                                                          .colorMorado,
                                                                    )),
                                                              ],
                                                            ),
                                                          ),
                                                          Divider(
                                                            thickness: 1,
                                                            color: prs
                                                                .colorGrisBordes,
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        20,
                                                                    horizontal:
                                                                        20),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Column(
                                                                  children: [
                                                                    pagos(
                                                                        misViajes[i]
                                                                            [
                                                                            'typePayment'],
                                                                        misViajes[i]
                                                                            [
                                                                            'cost']),
                                                                    Text(
                                                                      misViajes[
                                                                              i]
                                                                          [
                                                                          'createat'],
                                                                      textAlign:
                                                                          TextAlign
                                                                              .end,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            17,
                                                                        fontFamily:
                                                                            'GoldplayRegular',
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                misViajes[i][
                                                                        'wasRated']
                                                                    ? Row(
                                                                        children: [
                                                                          Icon(
                                                                            Icons.star,
                                                                            color:
                                                                                prs.colorMorado,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                10,
                                                                          ),
                                                                          Text(
                                                                            misViajes[i]['calification'].toString(),
                                                                            style:
                                                                                TextStyle(fontSize: 17),
                                                                          )
                                                                        ],
                                                                      )
                                                                    : SizedBox(),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Column(
                                    children: [
                                      Expanded(
                                          child: ListView.builder(
                                        physics: BouncingScrollPhysics(),
                                        itemCount: viajesCancelados.length,
                                        itemBuilder: (context, i) {
                                          return Container(
                                            margin: EdgeInsets.only(bottom: 10),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.0),
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                      // color: Colors.red,
                                                      border: Border.all(
                                                          color: prs
                                                              .colorGrisBordes),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25)),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 20,
                                                                horizontal: 20),
                                                        child: Row(
                                                          children: [
                                                            Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Image(
                                                                      image: AssetImage(
                                                                          "assets/png/indicador.png"),
                                                                      height:
                                                                          25,
                                                                      width: 25,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.6,
                                                                      child:
                                                                          Text(
                                                                        misViajesCancelados[i]
                                                                            [
                                                                            'pickupAddress'],
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontFamily:
                                                                              'GoldplayRegular',
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 15,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Image(
                                                                      image: AssetImage(
                                                                          "assets/png/indicador2.png"),
                                                                      height:
                                                                          25,
                                                                      width: 25,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.6,
                                                                      child:
                                                                          Text(
                                                                        misViajesCancelados[i]
                                                                            [
                                                                            'destinationAddress'],
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontFamily:
                                                                              'GoldplayRegular',
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                            Expanded(
                                                                child:
                                                                    Container()),
                                                            // Stack(
                                                            //   children: [
                                                            //     IconButton(
                                                            //         onPressed:
                                                            //             () {
                                                            //           showModalBottomSheet(
                                                            //             isScrollControlled:
                                                            //                 true,
                                                            //             shape: RoundedRectangleBorder(
                                                            //                 borderRadius:
                                                            //                     BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
                                                            //             context:
                                                            //                 context,
                                                            //             builder: (context) => StatefulBuilder(builder: (BuildContext
                                                            //                     context,
                                                            //                 StateSetter
                                                            //                     mystate) {
                                                            //               return Column(
                                                            //                   mainAxisSize: MainAxisSize.min,
                                                            //                   children: [
                                                            //                     Padding(
                                                            //                       padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 5),
                                                            //                       child: Column(
                                                            //                         crossAxisAlignment: CrossAxisAlignment.start,
                                                            //                         children: [
                                                            //                           SizedBox(
                                                            //                             height: 30,
                                                            //                           ),
                                                            //                           Row(
                                                            //                             mainAxisAlignment: MainAxisAlignment.center,
                                                            //                             children: [
                                                            //                               Expanded(
                                                            //                                   child: TextButton(
                                                            //                                       onPressed: () {},
                                                            //                                       style: TextButton.styleFrom(shape: StadiumBorder(), elevation: 0, padding: EdgeInsets.symmetric(vertical: 20), backgroundColor: Colors.transparent, foregroundColor: prs.colorMorado),
                                                            //                                       child: Text(
                                                            //                                         "Calificar Viaje",
                                                            //                                         style: TextStyle(color: prs.colorMorado, fontFamily: 'GoldplayRegular', fontSize: 18, fontWeight: FontWeight.w600),
                                                            //                                       )))
                                                            //                             ],
                                                            //                           ),
                                                            //                           Divider(
                                                            //                             color: prs.colorGrisBordes,
                                                            //                           ),
                                                            //                           Row(
                                                            //                             mainAxisAlignment: MainAxisAlignment.center,
                                                            //                             children: [
                                                            //                               Expanded(
                                                            //                                   child: TextButton(
                                                            //                                       onPressed: () {},
                                                            //                                       style: TextButton.styleFrom(shape: StadiumBorder(), elevation: 0, padding: EdgeInsets.symmetric(vertical: 20), backgroundColor: Colors.transparent, foregroundColor: prs.colorMorado),
                                                            //                                       child: Text(
                                                            //                                         "Detalles de Viaje",
                                                            //                                         style: TextStyle(color: prs.colorMorado, fontFamily: 'GoldplayRegular', fontSize: 18, fontWeight: FontWeight.w600),
                                                            //                                       )))
                                                            //                             ],
                                                            //                           ),
                                                            //                           SizedBox(
                                                            //                             height: 20,
                                                            //                           ),
                                                            //                           SizedBox(
                                                            //                             width: double.infinity,
                                                            //                             child: ElevatedButton(
                                                            //                               onPressed: () {
                                                            //                                 Navigator.pop(context);
                                                            //                               },
                                                            //                               child: Text(
                                                            //                                 "Cancelar",
                                                            //                                 style: TextStyle(
                                                            //                                   color: prs.colorMorado,
                                                            //                                   fontSize: 15,
                                                            //                                   fontWeight: FontWeight.w600,
                                                            //                                   fontFamily: 'GoldplayRegular',
                                                            //                                 ),
                                                            //                               ),
                                                            //                               style: ElevatedButton.styleFrom(shape: StadiumBorder(), side: BorderSide(color: prs.colorMorado, width: 1), elevation: 0, padding: EdgeInsets.symmetric(vertical: 20), backgroundColor: Colors.transparent, foregroundColor: prs.colorMorado),
                                                            //                             ),
                                                            //                           )
                                                            //                         ],
                                                            //                       ),
                                                            //                     ),
                                                            //                   ]);
                                                            //             }),
                                                            //           );
                                                            //         },
                                                            //         icon: Icon(
                                                            //           Icons
                                                            //               .arrow_forward_ios,
                                                            //           color: prs
                                                            //               .colorMorado,
                                                            //         )),
                                                            //   ],
                                                            // ),
                                                          
                                                          ],
                                                        ),
                                                      ),
                                                      Divider(
                                                        thickness: 1,
                                                        color:
                                                            prs.colorGrisBordes,
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 20,
                                                                horizontal: 20),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Column(
                                                              children: [
                                                                pagos(
                                                                    misViajesCancelados[i]['typePayment'],
                                                                    misViajesCancelados[i]['cost']),
                                                                Text(
                                                                  misViajesCancelados[i]['createat'],
                                                                  textAlign:TextAlign.end,
                                                                  style:TextStyle(
                                                                    fontSize:17,
                                                                    fontFamily:'GoldplayRegular',
                                                                  ),
                                                                )
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                      ))
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ))
            ],
          ),
        ));
  }
  @override
  bool get wantKeepAlive => true;
}

Widget pagos(tipo, monto) {
  return Text.rich(
    TextSpan(
      children: [
        if (tipo == 1)
          TextSpan(
            text: "Pago con efectivo",
            style: TextStyle(
                fontFamily: "GoldplayRegular",
                fontWeight: FontWeight.w600,
                fontSize: 17),
          )
        else if (tipo == 2)
          TextSpan(
            text: "Pago con Yape",
            style: TextStyle(
                fontFamily: "GoldplayRegular",
                fontWeight: FontWeight.w600,
                fontSize: 17),
          )
        else if (tipo == 3)
          TextSpan(
            text: "Pago con Plin",
            style: TextStyle(
                fontFamily: "GoldplayRegular",
                fontWeight: FontWeight.w600,
                fontSize: 17),
          )
        else if (tipo == 4)
          TextSpan(
            text: "Pago con Tarjeta",
            style: TextStyle(
                fontFamily: "GoldplayRegular",
                fontWeight: FontWeight.w600,
                fontSize: 17),
          ),
        if (tipo == 1)
          TextSpan(
            text: " • S/$monto",
            style: TextStyle(
                fontFamily: "GoldplayRegular",
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: Color(0xFF15AC6D)),
          )
        else if (tipo == 2)
          TextSpan(
            text: " • S/$monto",
            style: TextStyle(
                fontFamily: "GoldplayRegular",
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: Color(0xFF841195)),
          )
        else if (tipo == 3)
          TextSpan(
            text: " • S/$monto",
            style: TextStyle(
                fontFamily: "GoldplayRegular",
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: Color(0xFF3CB3AE)),
          )
        else if (tipo == 4)
          TextSpan(
            text: " • S/$monto",
            style: TextStyle(
                fontFamily: "GoldplayRegular",
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: Color(0xFF1746A2)),
          ),
      ],
    ),
  );
}