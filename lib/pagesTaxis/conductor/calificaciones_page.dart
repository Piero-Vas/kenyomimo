import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mimo/preference/shared_preferences.dart';
import 'package:mimo/widgets/menu_taxis_widget.dart';
import '../../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class CalificacionesPage extends StatefulWidget {
  const CalificacionesPage({Key key}) : super(key: key);

  @override
  State<CalificacionesPage> createState() => _CalificacionesPageState();
}

class _CalificacionesPageState extends State<CalificacionesPage> {
  double calification = 0.0;
  int totalTrips = 0;
  int totalCalification = 0;
  double total = 0.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _saving = false;
  List<dynamic> miscalificaciones = [];

  @override
  void initState() {
    loadData();
    super.initState();
  }

  loadData()async{
    final _prefs= PreferenciasUsuario();
    String id = _prefs.clienteModel.idCliente;
    await FirebaseFirestore.instance.collection("trips")
    .where("driverId",isEqualTo: id)
    .where('tripCompleted', isEqualTo: true)
    .where('canceled', isEqualTo: false)
    .snapshots()
    .listen((QuerySnapshot value) async {
      if(value.size<1){
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No cuentas con ninguna calificacion.'),
            ),
          );
        Navigator.pop(context);
        return;
      }
      totalTrips = value.size;
      double revenue = 0;
      value.docs.forEach((QueryDocumentSnapshot element) { 
        revenue = revenue + element['cost'];
      });
      total = revenue/totalTrips;
      setState(() {});
    });
    await FirebaseFirestore.instance.collection("trips").where("driverId",isEqualTo: id).where('tripCompleted', isEqualTo: true)
    .where('wasRated', isEqualTo: true).where('canceled', isEqualTo: false).snapshots().listen((QuerySnapshot value) async {
      totalCalification = value.size;
      double rating = 0;
      value.docs.forEach((QueryDocumentSnapshot element) { 
        rating = rating + element['calification'];
      });
      calification = rating/totalCalification;
      miscalificaciones.clear();
      miscalificaciones.addAll(value.docs);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuWidgetTaxis(),
      appBar: AppBar(
        // backgroundColor: Colors.white,
        // shadowColor: Colors.black,
        centerTitle: true,
        title: Text(
          "Calificaciones",
          style: TextStyle(
              color: Color(0xFF4B4B4E),
              fontSize: 18,
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
        /* actions: [
          TextButton(
              onPressed: () {},
              child: Text(
                "Ordenar",
                style: TextStyle(
                    color: prs.colorMorado,
                    fontSize: 17,
                    fontFamily: 'GoldplayRegular',
                    fontWeight: FontWeight.w600),
              ))
        ], */
      ),
      key: _scaffoldKey,
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: utils.progressIndicator('Cargando...'),
        inAsyncCall: _saving,
        child: Center(
            child: Container(
          padding: EdgeInsets.all(20),
          child: _contenido(),
          width: prs.anchoFormulario,
          decoration: BoxDecoration(color: Colors.white),
        )),
      ),
    );
  }


  Widget _contenido() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: prs.colorAmarillo,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    calification.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontFamily: 'GoldplayRegular'),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  totalTrips.toString(),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                      fontFamily: 'GoldplayBlack'),
                ),
                Text(
                  "Viajes",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'GoldplayRegular'),
                )
              ],
            ),
            Column(
              children: [
                Text(
                  '${miscalificaciones.length}',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                      fontFamily: 'GoldplayBlack'),
                ),
                Text(
                  "Calificaciones",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'GoldplayRegular'),
                )
              ],
            ),
            Column(
              children: [
                Text(
                  total.toString().split(".")[0]+"."+(total.toString().contains(".") 
                  ? total.toString().split(".")[1].substring(0,1):""),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                      fontFamily: 'GoldplayBlack'),
                ),
                Text(
                  "Pago",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'GoldplayRegular'),
                )
              ],
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),

        SizedBox(
          height: 15,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: miscalificaciones.length,
            itemBuilder: (context, i) {
              return Container(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Container(
                          child: Image(
                            image: AssetImage('assets/png/user2.png'),
                            height: 30,
                            width: 30,
                          ),
                        ),
                        _estrellas(miscalificaciones[i]['calification']),
                        Expanded(child: Container(child: Text(miscalificaciones[i]['createatDate'], textAlign: TextAlign.end,)))
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Container(
                          width: 30,
                        ),
                        Expanded(
                            child: Text(miscalificaciones[i]['description'],
                                style: TextStyle(
                                    color: Colors.black,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    fontFamily: 'GoldplayRegular')))
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _estrellas( puntos) {
    return utils.estrellasTaxis2((puntos / 1), (value){});
}
}