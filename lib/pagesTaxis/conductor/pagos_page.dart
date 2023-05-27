import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mimo/preference/shared_preferences.dart';
import 'package:mimo/widgets/menu_taxis_widget.dart';
import '../../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;

// import 'package:shared_preferences/shared_preferences.dart';
final _prefs = PreferenciasUsuario();

class PagosPage extends StatefulWidget {
  @override
  _PagosPageState createState() => _PagosPageState();
}

class _PagosPageState extends State<PagosPage>
    with AutomaticKeepAliveClientMixin {
  DateTime actual = DateTime.now();

  @override
  void initState() {
    // cargarData();
    getPaymentsLiberados();
    getPaymentsPagados();
    getPaymentsEnProceso();
    getPaymentsConTarjeta();
    getPaymentsSinTarjeta();
    super.initState();
  }

  cargarData() async {
    if (mounted) {
      setState(() {
        actual = DateTime(actual.year, actual.month, actual.day);
      });
    }
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> liberados = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> liberadosres = [];
  List<dynamic> pagados = [];
  List<dynamic> pagadosres = [];
  List<dynamic> procesos = [];

  var id = _prefs.clienteModel.idCliente;
  // 86400000 = 1 dia sinceEpoch milisegundos
  Future getPaymentsEnProceso() async {
    int dateMili = actual.millisecondsSinceEpoch;

    return FirebaseFirestore.instance
        .collection("trips")
        .where('driverId', isEqualTo: id.toString())
        .where('paymentStatus', isEqualTo: 0)
        .where('canceled', isEqualTo: false)
        .orderBy("createatMili",descending: true)
        .get()
        // .snapshots()
        .then((value) {
      procesos.clear();
      value.docs.forEach((element) {
        
        if (element.data()['createatMili'] + (172800000) >= dateMili) {
          procesos.add(element.data());
          
        } else {
          
        }
      });
      setState(() {});
    });
  }

  List<double> totalConTarjeta = [];
  double totaltarjeta = 0.0;
  Future getPaymentsConTarjeta() async {
    int dateMili = actual.millisecondsSinceEpoch;

    return FirebaseFirestore.instance
        .collection("trips")
        .where('driverId', isEqualTo: id.toString())
        .where('paymentStatus', isEqualTo: 0)
        .where('canceled', isEqualTo: false)
        .where('typePayment', isEqualTo: 4)
        .get()
        .then((value) async {
      
      value.docs.forEach((element) {
        
        if (element.data()['createatMili'] + (86400000 * 2) < dateMili) {
          totalConTarjeta.add(element.data()['cost'] * 0.95);
          
        } else {
          
        }
      });
      setState(() {});
      totaltarjeta =
          totalConTarjeta.reduce((value, element) => value + element);
    });
  }

  List<double> totalSinTarjeta = [];
  double totalsintarjeta = 0.0;
  Future getPaymentsSinTarjeta() async {
    int dateMili = actual.millisecondsSinceEpoch;

    return FirebaseFirestore.instance
        .collection("trips")
        .where('driverId', isEqualTo: id.toString())
        .where('paymentStatus', isEqualTo: 0)
        .where('canceled', isEqualTo: false)
        .where('typePayment', isNotEqualTo: 4)
        .get()
        .then((value) async {
      
      value.docs.forEach((element) {
        
        if (element.data()['createatMili'] + (86400000 * 2) < dateMili) {
          totalSinTarjeta.add(element.data()['cost'] * 0.095);
          
        } else {
          print("sin datos");
        }
      });
      setState(() {});
      totalsintarjeta =
          totalSinTarjeta.reduce((value, element) => value + element);
    });
  }

  Future getPaymentsLiberados() async {
    int dateMili = actual.millisecondsSinceEpoch;

    return FirebaseFirestore.instance
        .collection("trips")
        .where('driverId', isEqualTo: id.toString())
        .where('paymentStatus', isEqualTo: 0)
        .where('canceled', isEqualTo: false)
        .orderBy("createatMili",descending: true)
        .get()
        // .snapshots()
        .then((value) async {
      List<QueryDocumentSnapshot<Map<String, dynamic>>> query;

     
      query = await value.docs.where((QueryDocumentSnapshot element) {
        
        return element['createatMili'] + 172800000 < dateMili ? true : false;
      }).toList();
      
      liberados.clear();
      liberados.addAll(query);
      if (mounted) {
        setState(() {
          liberadosres = liberados;
        });
      }

      
    });
    
  }

  Future getPaymentsPagados() async {
    return FirebaseFirestore.instance
        .collection("trips")
        .where('driverId', isEqualTo: id.toString())
        .where('paymentStatus', isEqualTo: 2)
        .where('canceled', isEqualTo: false)
        .orderBy("createatMili",descending: true)
        // .snapshots()
        .get()
        .then((result) async {
      pagados.clear();
      pagados.addAll(result.docs);
      if (mounted) {
        setState(() {
          pagadosres = pagados;
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
            "Pagos",
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
          
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                  flex: 1,
                  child: DefaultTabController(
                    length: 3,
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
                                  color: prs.colorMorado,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                tabs: [
                                  Tab(
                                    text: 'En proceso',
                                  ),
                                  Tab(
                                    text: 'Liberados',
                                  ),
                                  Tab(
                                    text: 'Pagados',
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
                                // Container(
                                //   child: Column(
                                //     children: [
                                //       Expanded(
                                //         child: ListView.builder(
                                //             physics: BouncingScrollPhysics(),
                                //             itemCount: liberadosres.length,
                                //             itemBuilder: (context, i) {
                                //               return Container(
                                //                 margin:
                                //                     EdgeInsets.only(bottom: 10),
                                //                 padding: EdgeInsets.symmetric(
                                //                     horizontal: 10.0),
                                //                 child: Column(
                                //                   children: [
                                //                     Container(
                                //                       width: double.infinity,
                                //                       decoration: BoxDecoration(
                                //                           // color: Colors.red,
                                //                           border: Border.all(
                                //                               color: prs
                                //                                   .colorGrisBordes),
                                //                           borderRadius:
                                //                               BorderRadius
                                //                                   .circular(
                                //                                       25)),
                                //                       child: Column(
                                //                         children: [
                                //                           Padding(
                                //                             padding: EdgeInsets
                                //                                 .symmetric(
                                //                                     vertical:
                                //                                         20,
                                //                                     horizontal:
                                //                                         20),
                                //                             child: Row(
                                //                               children: [
                                //                                 Column(
                                //                                   children: [
                                //                                     Row(
                                //                                       children: [
                                //                                         Image(
                                //                                           image:
                                //                                               AssetImage("assets/png/indicador.png"),
                                //                                           height:
                                //                                               25,
                                //                                           width:
                                //                                               25,
                                //                                         ),
                                //                                         SizedBox(
                                //                                           width:
                                //                                               10,
                                //                                         ),
                                //                                         Container(
                                //                                           width:
                                //                                               MediaQuery.of(context).size.width * 0.6,
                                //                                           child:
                                //                                               Text(
                                //                                             liberadosres[i]['pickupAddress'],
                                //                                             style:
                                //                                                 TextStyle(
                                //                                               fontSize: 18,
                                //                                               fontFamily: 'GoldplayRegular',
                                //                                             ),
                                //                                           ),
                                //                                         )
                                //                                       ],
                                //                                     ),
                                //                                     SizedBox(
                                //                                       height:
                                //                                           15,
                                //                                     ),
                                //                                     Row(
                                //                                       children: [
                                //                                         Image(
                                //                                           image:
                                //                                               AssetImage("assets/png/indicador2.png"),
                                //                                           height:
                                //                                               25,
                                //                                           width:
                                //                                               25,
                                //                                         ),
                                //                                         SizedBox(
                                //                                           width:
                                //                                               10,
                                //                                         ),
                                //                                         Container(
                                //                                           width:
                                //                                               MediaQuery.of(context).size.width * 0.6,
                                //                                           child:
                                //                                               Text(
                                //                                             liberadosres[i]['destinationAddress'],
                                //                                             style:
                                //                                                 TextStyle(
                                //                                               fontSize: 18,
                                //                                               fontFamily: 'GoldplayRegular',
                                //                                             ),
                                //                                           ),
                                //                                         )
                                //                                       ],
                                //                                     )
                                //                                   ],
                                //                                 ),
                                //                                 Expanded(
                                //                                     child:
                                //                                         Container()),
                                //                               ],
                                //                             ),
                                //                           ),
                                //                           Divider(
                                //                             thickness: 1,
                                //                             color: prs
                                //                                 .colorGrisBordes,
                                //                           ),
                                //                           Padding(
                                //                             padding: EdgeInsets
                                //                                 .symmetric(
                                //                                     vertical:
                                //                                         20,
                                //                                     horizontal:
                                //                                         20),
                                //                             child: Row(
                                //                               mainAxisAlignment:
                                //                                   MainAxisAlignment
                                //                                       .end,
                                //                               children: [
                                //                                 Column(
                                //                                   children: [
                                //                                     pagos(
                                //                                         liberadosres[i]
                                //                                             [
                                //                                             'typePayment'],
                                //                                         liberadosres[i]
                                //                                             [
                                //                                             'cost']),
                                //                                     Text(
                                //                                       liberadosres[i]['createat'],
                                //                                       textAlign:
                                //                                           TextAlign
                                //                                               .end,
                                //                                       style:
                                //                                           TextStyle(
                                //                                         fontSize:
                                //                                             17,
                                //                                         fontFamily:
                                //                                             'GoldplayRegular',
                                //                                       ),
                                //                                     )
                                //                                   ],
                                //                                 ),
                                //                               ],
                                //                             ),
                                //                           )
                                //                         ],
                                //                       ),
                                //                     )
                                //                   ],
                                //                 ),
                                //               );
                                //             }),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                Container(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                            physics: BouncingScrollPhysics(),
                                            itemCount: procesos.length,
                                            itemBuilder: (context, i) {
                                              var costo85 = (procesos[i]['cost'] * 0.905) + procesos[i]['cost'];
                                              var costo15 = procesos[i]['cost'] - (procesos[i]['cost'] * 0.095);
                                              var eldescuento85 = (procesos[i]['cost'] * 0.905).toStringAsFixed(1);
                                              var eldescuento15 =(procesos[i]['cost'] * 0.095).toStringAsFixed(1);
                                              var descuento85 = costo85.toStringAsFixed(1);
                                              var descuento15 = costo15.toStringAsFixed(1);
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
                                                          // color: Colors.red,
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
                                                                            procesos[i]['pickupAddress'],
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
                                                                            procesos[i]['destinationAddress'],
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
                                                                      .end,
                                                              children: [
                                                                procesos[i]['typePayment'] ==
                                                                        4
                                                                    ? Row(
                                                                        children: [
                                                                          Column(
                                                                            children: [
                                                                              Container(
                                                                                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                                                                                padding: EdgeInsets.only(top: 5, bottom: 5, left: 0, right: 12),
                                                                                width: 80,
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Icon(
                                                                                      Icons.arrow_drop_up,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                    Text(
                                                                                      '90.5%',
                                                                                      style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'GoldplayRegular', fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 8,
                                                                              ),
                                                                              Text(
                                                                                'S/.${eldescuento85}',
                                                                                style: TextStyle(fontFamily: 'GoldplayBlack', color: Colors.green),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : Row(
                                                                        children: [
                                                                          Column(
                                                                            children: [
                                                                              Container(
                                                                                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                                                                                padding: EdgeInsets.only(top: 5, bottom: 5, left: 0, right: 12),
                                                                                width: 80,
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Icon(
                                                                                      Icons.arrow_drop_down,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                    Text(
                                                                                      '9.5%',
                                                                                      style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'GoldplayRegular', fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 8,
                                                                              ),
                                                                              Text(
                                                                                'S/.${eldescuento15}',
                                                                                style: TextStyle(fontFamily: 'GoldplayBlack', color: Colors.red),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    children: [
                                                                      pagos(
                                                                          procesos[i]
                                                                              [
                                                                              'typePayment'],
                                                                          procesos[i]
                                                                              [
                                                                              'cost']),
                                                                      Text(
                                                                        procesos[i]
                                                                            [
                                                                            'createat'],
                                                                        textAlign:
                                                                            TextAlign.end,
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
                                                                ),
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
                                      SizedBox(
                                        height: 100,
                                      )
                                    ],
                                  ),
                                ),

                                Stack(
                                  children: [
                                    Container(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: ListView.builder(
                                                physics:
                                                    BouncingScrollPhysics(),
                                                itemCount: liberadosres.length,
                                                itemBuilder: (context, i) {
                                                  var costo85 = (liberadosres[i]['cost'] * 0.905) +liberadosres[i]['cost'];
                                                  var costo15 = liberadosres[i]['cost'] - (liberadosres[i]['cost'] * 0.095);
                                                  var eldescuento85 = (liberadosres[i]['cost'] * 0.905).toStringAsFixed(1);
                                                  var eldescuento15 = (liberadosres[i]['cost'] * 0.095) .toStringAsFixed(1);
                                                  var descuento85 = costo85 .toStringAsFixed(1);
                                                  var descuento15 = costo15 .toStringAsFixed(1);
                                                  return Container(
                                                    margin: EdgeInsets.only(
                                                        bottom: 10),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10.0),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          decoration:
                                                              BoxDecoration(
                                                                  // color: Colors.red,
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
                                                                              image: AssetImage("assets/png/indicador.png"),
                                                                              height: 25,
                                                                              width: 25,
                                                                            ),
                                                                            SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            Container(
                                                                              width: MediaQuery.of(context).size.width * 0.6,
                                                                              child: Text(
                                                                                liberadosres[i]['pickupAddress'],
                                                                                style: TextStyle(
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
                                                                              image: AssetImage("assets/png/indicador2.png"),
                                                                              height: 25,
                                                                              width: 25,
                                                                            ),
                                                                            SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            Container(
                                                                              width: MediaQuery.of(context).size.width * 0.6,
                                                                              child: Text(
                                                                                liberadosres[i]['destinationAddress'],
                                                                                style: TextStyle(
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
                                                                          .end,
                                                                  children: [
                                                                    liberadosres[i]['typePayment'] ==
                                                                            4
                                                                        ? Row(
                                                                            children: [
                                                                              Column(
                                                                                children: [
                                                                                  Container(
                                                                                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                                                                                    padding: EdgeInsets.only(top: 5, bottom: 5, left: 0, right: 12),
                                                                                    width: 80,
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Icon(
                                                                                          Icons.arrow_drop_up,
                                                                                          color: Colors.white,
                                                                                        ),
                                                                                        Text(
                                                                                          '90.5%',
                                                                                          style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'GoldplayRegular', fontWeight: FontWeight.bold),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 8,
                                                                                  ),
                                                                                  Text(
                                                                                    'S/.${eldescuento85}',
                                                                                    style: TextStyle(fontFamily: 'GoldplayBlack', color: Colors.green),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          )
                                                                        : Row(
                                                                            children: [
                                                                              Column(
                                                                                children: [
                                                                                  Container(
                                                                                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                                                                                    padding: EdgeInsets.only(top: 5, bottom: 5, left: 0, right: 12),
                                                                                    width: 80,
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Icon(
                                                                                          Icons.arrow_drop_down,
                                                                                          color: Colors.white,
                                                                                        ),
                                                                                        Text(
                                                                                          '9.5%',
                                                                                          style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'GoldplayRegular', fontWeight: FontWeight.bold),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 8,
                                                                                  ),
                                                                                  Text(
                                                                                    'S/.${eldescuento15}',
                                                                                    style: TextStyle(fontFamily: 'GoldplayBlack', color: Colors.red),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          pagos(
                                                                              liberadosres[i]['typePayment'],
                                                                              liberadosres[i]['cost']),
                                                                          Text(
                                                                            liberadosres[i]['createat'],
                                                                            textAlign:
                                                                                TextAlign.end,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 17,
                                                                              fontFamily: 'GoldplayRegular',
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
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
                                          SizedBox(
                                            height: 100,
                                          )
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Expanded(child: Container()),
                                        
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black45,
                                                // offset: Offset(-1,-2),
                                                blurRadius: 1
                                              )
                                            ]
                                          ),
                                          
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 15),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Detalles de Pagos',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'GoldplayRegular',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Saldo a Favor: ',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'GoldplayRegular',
                                                        fontSize: 17),
                                                  ),
                                                  Text(
                                                    '+ S/. ${totaltarjeta.toStringAsFixed(1)}',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'GoldplayRegular',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 17,
                                                        color: Colors.green),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Saldo en Contra: ',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'GoldplayRegular',
                                                        fontSize: 17),
                                                  ),
                                                  Text(
                                                    '- S/. ${totalsintarjeta.toStringAsFixed(1)}',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'GoldplayRegular',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 17,
                                                        color: Colors.red),
                                                  )
                                                ],
                                              ),
                                              Divider(),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Total: ',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'GoldplayRegular',
                                                        fontSize: 17),
                                                  ),
                                                  totaltarjeta-totalsintarjeta < 0?
                                                  Text(
                                                    '- S/. ${(totaltarjeta-totalsintarjeta).toStringAsFixed(1)}',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'GoldplayRegular',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 17,
                                                        color: Colors.red),
                                                  ):
                                                  Text(
                                                    '+ S/. ${(totaltarjeta-totalsintarjeta).toStringAsFixed(1)}',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'GoldplayRegular',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 17,
                                                        color: Colors.green),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                Container(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                            physics: BouncingScrollPhysics(),
                                            itemCount: pagadosres.length,
                                            itemBuilder: (context, i) {
                                              var costo85 = (pagadosres[i]['cost'] *0.905) +pagadosres[i]['cost'];
                                              var costo15 = pagadosres[i]['cost'] - (pagadosres[i]['cost'] * 0.095);
                                              var eldescuento15 = (pagadosres[i]['cost'] * 0.095).toStringAsFixed(1);
                                              var eldescuento85 = (pagadosres[i]['cost'] * 0.905).toStringAsFixed(1);
                                              var descuento85 = costo85.toStringAsFixed(1);
                                              var descuento15 = costo15.toStringAsFixed(1);
                                              
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
                                                          // color: Colors.red,
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
                                                                            pagadosres[i]['pickupAddress'],
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
                                                                            pagadosres[i]['destinationAddress'],
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
                                                                      .end,
                                                              children: [
                                                                pagadosres[i][
                                                                            'typePayment'] ==
                                                                        4
                                                                    ? Row(
                                                                        children: [
                                                                          Column(
                                                                            children: [
                                                                              Container(
                                                                                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                                                                                padding: EdgeInsets.only(top: 5, bottom: 5, left: 0, right: 12),
                                                                                width: 80,
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Icon(
                                                                                      Icons.arrow_drop_up,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                    Text(
                                                                                      '90.5%',
                                                                                      style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'GoldplayRegular', fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 8,
                                                                              ),
                                                                              Text(
                                                                                'S/.${eldescuento85}',
                                                                                style: TextStyle(fontFamily: 'GoldplayBlack', color: Colors.green),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : Row(
                                                                        children: [
                                                                          Column(
                                                                            children: [
                                                                              Container(
                                                                                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                                                                                padding: EdgeInsets.only(top: 5, bottom: 5, left: 0, right: 12),
                                                                                width: 80,
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Icon(
                                                                                      Icons.arrow_drop_down,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                    Text(
                                                                                      '9.5%',
                                                                                      style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'GoldplayRegular', fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 8,
                                                                              ),
                                                                              Text(
                                                                                'S/.${eldescuento15}',
                                                                                style: TextStyle(fontFamily: 'GoldplayBlack', color: Colors.red),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    children: [
                                                                      pagos(
                                                                          pagadosres[i]
                                                                              [
                                                                              'typePayment'],
                                                                          pagadosres[i]
                                                                              [
                                                                              'cost']),
                                                                      Text(
                                                                        pagadosres[i]
                                                                            [
                                                                            'createat'],
                                                                        textAlign:
                                                                            TextAlign.end,
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
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                              // : Center(
                                              //     child: Text(
                                              //         "No Cuentas con viajes pagados"),
                                              //   );
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
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
                fontSize: 14),
          )
        else if (tipo == 2)
          TextSpan(
            text: "Pago con Yape",
            style: TextStyle(
                fontFamily: "GoldplayRegular",
                fontWeight: FontWeight.w600,
                fontSize: 14),
          )
        else if (tipo == 3)
          TextSpan(
            text: "Pago con Plin",
            style: TextStyle(
                fontFamily: "GoldplayRegular",
                fontWeight: FontWeight.w600,
                fontSize: 14),
          )
        else if (tipo == 4)
          TextSpan(
            text: "Pago con Tarjeta",
            style: TextStyle(
                fontFamily: "GoldplayRegular",
                fontWeight: FontWeight.w600,
                fontSize: 14),
          ),
        if (tipo == 1)
          TextSpan(
            text: " • S/$monto",
            style: TextStyle(
                fontFamily: "GoldplayRegular",
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF15AC6D)),
          )
        else if (tipo == 2)
          TextSpan(
            text: " • S/$monto",
            style: TextStyle(
                fontFamily: "GoldplayRegular",
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF841195)),
          )
        else if (tipo == 3)
          TextSpan(
            text: " • S/$monto",
            style: TextStyle(
                fontFamily: "GoldplayRegular",
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF3CB3AE)),
          )
        else if (tipo == 4)
          TextSpan(
            text: " • S/$monto",
            style: TextStyle(
                fontFamily: "GoldplayRegular",
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1746A2)),
          ),
      ],
    ),
  );
}
