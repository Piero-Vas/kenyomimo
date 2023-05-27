import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mimo/pagesTaxis/pasajeros/agregar_tarjeta_page.dart';
import 'package:mimo/widgets/menu_taxis_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../model/card_model.dart';
import '../../preference/shared_preferences.dart';
import '../../utils/button.dart' as btn;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;

final _prefs = PreferenciasUsuario();

class MetodoPagoTaxi extends StatefulWidget {
  // final String idAgencia;
  // final Function verificarTarjetaOtp;
  const MetodoPagoTaxi({Key key}) : super(key: key);

  @override
  State<MetodoPagoTaxi> createState() => _MetodoPagoTaxiState();
}

class _MetodoPagoTaxiState extends State<MetodoPagoTaxi> {
  int _value = -1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  CardModel _cardModel = CardModel();
  final prefs = PreferenciasUsuario();
  String creditCardNumber = '';
  IconData brandIcon;
  bool _saving = false;

  @override
  void initState() {
    getAllCards();
    super.initState();
  }

  List<dynamic> misTarjetas = [];
  List<dynamic> tarjetas = [];
  var id = _prefs.clienteModel.idCliente;

  Future getAllCards() async {
    return FirebaseFirestore.instance
        .collection("cards")
        .where("idCliente", isEqualTo: id.toString())
        .where("eliminado", isEqualTo: false)
        .snapshots()
        .listen((QuerySnapshot<Map<String, dynamic>> result) async {
      misTarjetas.clear();
      misTarjetas.addAll(result.docs);
      if (mounted) {
        setState(() {
          tarjetas = misTarjetas;
        });
      }
      int i = 0;
      _value = -1; 
      for(var tarjeta in tarjetas){
        if(tarjeta['seleccionado']) _value = i;
        i++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuWidgetTaxis(),
      appBar: AppBar(
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
        centerTitle: true,
        title: Text(
          "Métodos de pago",
          style: TextStyle(
              color: Color(0xFF4B4B4E),
              fontSize: 20,
              fontFamily: 'GoldplayRegular',
              fontWeight: FontWeight.w700),
        ),
        iconTheme: IconThemeData(
          color: prs.colorMorado,
        ),
        elevation: 0,
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

  Widget _body() {
    return Column(
      children: <Widget>[
        Container(child: _contenido()),
      ],
    );
  }

  Widget _contenido() {
    return Column(
      children: <Widget>[
        tarjetas.length>2 ? SizedBox() : SizedBox(
          height: 20,
        ),
        tarjetas.length>2 ? SizedBox(): btn.bootonContinuarTaxi('+ Añadir nueva método', () {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AgregarTarjetaPage();
             });
}),
        SizedBox(
          height: 20,
        ),
        Container(
          padding: EdgeInsets.only(bottom: 10,top: 10, right: 0, left: 0),
          decoration: BoxDecoration(
              border: Border.all(color: prs.colorGrisBordes),
              borderRadius: BorderRadius.circular(20)),
          child: ListTile(
              leading: Image(
                height: 50,
                width: 50,
                image: AssetImage(
                  "assets/png/efectivo.png",
                ),
              ),
              title: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Efectivo",
                      style: TextStyle(
                          fontFamily: "GoldplayRegular",
                          fontWeight: FontWeight.w600,
                          fontSize: 17),
                    ),
                  ],
                ),
              ),
              ),
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          padding: EdgeInsets.only(bottom: 10,top: 10, right: 0, left: 0),
          decoration: BoxDecoration(
              border: Border.all(color: prs.colorGrisBordes),
              borderRadius: BorderRadius.circular(20)),
          child: ListTile(
              leading: Image(
                height: 50,
                width: 50,
                image: AssetImage(
                  "assets/png/yape.png",
                ),
              ),
              title: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Yape",
                      style: TextStyle(
                          fontFamily: "GoldplayRegular",
                          fontWeight: FontWeight.w600,
                          fontSize: 17),
                    ),
                  ],
                ),
              ),
              ),
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          padding: EdgeInsets.only(bottom: 10,top: 10, right: 0, left: 0),
          decoration: BoxDecoration(
              border: Border.all(color: prs.colorGrisBordes),
              borderRadius: BorderRadius.circular(20)),
          child: ListTile(
              leading: Image(
                height: 50,
                width: 50,
                image: AssetImage(
                  "assets/png/plin.png",
                ),
              ),
              title: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Plin",
                      style: TextStyle(
                          fontFamily: "GoldplayRegular",
                          fontWeight: FontWeight.w600,
                          fontSize: 17),
                    ),
                  ],
                ),
              ),
              ),
        ),
        SizedBox(
          height: 15,
        ),
        Expanded(
          child: SlidableAutoCloseBehavior(
            closeWhenOpened: true,
            child: ListView.builder(
              itemCount: tarjetas.length,
              itemBuilder: (context, i) {
                return Slidable(
                  startActionPane: ActionPane(
                    motion: StretchMotion(),
                    children: [
                      SlidableAction(
                        backgroundColor: prs.colorRojo,
                        icon: Icons.delete,
                        label: 'Eliminar',
                        onPressed: (context) async{
                          DocumentSnapshot documentSnapshot = tarjetas[i];
                          await FirebaseFirestore.instance.collection("cards").doc(documentSnapshot.id).update({"eliminado":true});
                        })
                    ],
                  ),
                  child: Container(
                    padding:
                        EdgeInsets.only(bottom: 10, top: 10, right: 0, left: 0),
                    margin: EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                        border: Border.all(color: prs.colorGrisBordes),
                        borderRadius: BorderRadius.circular(20)),
                    child: ListTile(
                        leading: Image(
                          height: 50,
                          width: 50,
                          image: AssetImage(
                            "assets/png/tarjetadecredito.png",
                          ),
                        ),
                        // title: Text.rich(
                        //   TextSpan(
                        //     children: [
                        //       TextSpan(
                        //         text: "Débito •••• •••• •••• ",
                        //         style: TextStyle(
                        //             fontFamily: "GoldplayRegular",
                        //             fontWeight: FontWeight.w600,
                        //             fontSize: 17),
                        //       ),
                        //       TextSpan(
                        //         text: tarjetas[i]['tarjeta'],
                        //         style: TextStyle(
                        //             fontFamily: "GoldplayRegular",
                        //             fontWeight: FontWeight.w600,
                        //             fontSize: 17),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        title: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: tarjetas[i]['alias'],
                                style: TextStyle(
                                    fontFamily: "GoldplayRegular",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17),
                              ),
                            ],
                          ),
                        ),
                        trailing: Radio(
                            value: i,
                            groupValue: _value,
                            onChanged: (value) {
                              setState(() {
                                _value = i;
                                confirmar(i);
                              });
                            })
                        ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  confirmar(value) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      context: context,
      builder: (context) => Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              Text(
                '¿Seguro quieres establecer este nuevo método como predeterminado?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'GoldplayRegular',
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    DocumentSnapshot documentSnapshot = tarjetas[value];
                    await FirebaseFirestore.instance.collection("cards").where("seleccionado",isEqualTo: true)
                    .where("idCliente",isEqualTo: id).limit(1).get().then((QuerySnapshot value) async{
                      if(value.size>0)
                        await FirebaseFirestore.instance.collection("cards").doc(value.docs.first.id).update({"seleccionado":false});
                    });
                    Navigator.pop(context);
                    await FirebaseFirestore.instance.collection("cards").doc(documentSnapshot.id).update({"seleccionado":true});
                    _value = value;
                  },
                  child: Text(
                    "Sí, seguro",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      padding: EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: prs.colorMorado,
                      foregroundColor: prs.colorMorado),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _value = -1;
                    });
                  },
                  child: Text(
                    "Cancelar",
                    style: TextStyle(color: prs.colorMorado),
                  ),
                  style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      side: BorderSide(color: prs.colorMorado, width: 1),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: Colors.transparent,
                      foregroundColor: prs.colorMorado),
                ),
              ),
            ],
          ),
        ),
      ]),
);
}
}