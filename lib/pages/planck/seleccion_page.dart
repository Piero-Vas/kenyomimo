import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mimo/model/cliente_model.dart';
import 'package:mimo/pages/planck/mi_delivery_page.dart';
import 'package:mimo/pages/planck/mi_movil_page.dart';
import 'package:mimo/preference/shared_preferences.dart';
import 'package:mimo/utils/personalizacion.dart' as prs;
import 'package:flutter/material.dart';

final PreferenciasUsuario _prefs = PreferenciasUsuario();
class SeleccionPage extends StatefulWidget {
  SeleccionPage({Key key}) : super(key: key);

  @override
  State<SeleccionPage> createState() => _SeleccionPageState();
}

class _SeleccionPageState extends State<SeleccionPage> {
  ClienteModel clienteModel = ClienteModel();
  @override
  void initState() {
    //  _updateTripCanceled();
    super.initState();
  }

  _updateTripCanceled() async{
  await FirebaseFirestore.instance.collection("trips")
        .where('canceled', isEqualTo: false)
        .where('accepted', isEqualTo: false)
        .get().then((trips) async{
          Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> tripsTemp = await trips.docs.where((tripTemp){
            return DateTime.now().millisecondsSinceEpoch > tripTemp['createatMili']+120000 ? true : false;
          });
        tripsTemp.forEach((trip) async {
          await FirebaseFirestore.instance.collection("trips").doc(trip.id).update({"canceled":true});
        });
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:PageView(
        
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        controller: PageController(initialPage: 1),
        children: [
          // MiDeliveryPage(),
          Container(
            child: Stack(
              children: [
                Container(        
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFF7F7F7)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter
                    )
                  ),
                  width: double.maxFinite,
                  height: double.maxFinite,
                  child: 
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        
                        width: double.infinity,
                        child: Image(
                          fit: BoxFit.cover,
                          image: AssetImage(
                              'assets/png/seleccion4.png'),
                        )),
                      
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical:40,horizontal: 20),
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [                      
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('MI',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: prs.colorBotones,
                              fontFamily: 'GoldplayBlack',
                              fontSize: 22
                            ),),
                                SizedBox(height: 8,),
                                Text('DELIVERY',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: prs.colorBotones,
                              fontFamily: 'GoldplayBlack',
                              fontSize: 22
                            ),),
                              ],
                            ),
                          ),
                          SizedBox(width: 10,),
                           ElevatedButton(onPressed: (){
                             if(_prefs.clienteModel.perfil.toString() == '2'){
                            Navigator.pushNamed(context,  'compras_despacho');
                            }else{
                              Navigator.pushNamed(context, 'catalogo2');
                            }
                           }, 
                                                   style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(),
                            backgroundColor: prs.colorRojo
                                                   ),
                                                   child: Container(
                            margin: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                            child: Row(
                              children: [
                                Text('Ir a Delivery',style: TextStyle(
                                      // color: prs.colorMorado, 
                                      fontFamily: 'GoldplayRegular',
                                      fontWeight: FontWeight.w800,
                                      fontSize:20)),
                                      SizedBox(width: 10,),
                                Icon(Icons.arrow_forward_ios_sharp)
                              ],
                            ),
                                                   )),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Text.rich(
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(text: 'Presiona el botón ', 
                              style: TextStyle(
                                color: prs.colorBotones, 
                                fontFamily: 'GoldplayRegular',
                                fontWeight: FontWeight.w800,
                                fontSize: 17)),
                              TextSpan(text: 'si quieres hacer el pedido de algún producto, ya sea comida, medicamentos, accesorios, etc. ', 
                              style: TextStyle(
                                fontFamily: 'GoldplayRegular',
                                color: Colors.black,
                                fontSize: 17)),
                            ],
                          ),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Goldplay'
                          ),
                        ),
                      // SizedBox(height: 10,),
                      // Row(
                      //   children: [
                      //     ElevatedButton(onPressed: (){}, 
                      //         style: ElevatedButton.styleFrom(
                      //           shape: StadiumBorder(),
                      //           backgroundColor: prs.colorRojo
                      //         ),
                      //         child: Row(
                      //           children: [
                      //             Text('Ir Delivery',style: TextStyle(
                      //                   // color: prs.colorMorado, 
                      //                   fontFamily: 'GoldplayRegular',
                      //                   fontWeight: FontWeight.w800,
                      //                   fontSize: 17)),
                      //             SizedBox(width: 10,),
                      //         Icon(Icons.arrow_forward_ios_sharp,)
                      //           ],
                      //         )),
                      //   ],
                      // ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical:40,horizontal: 20),
                  alignment: Alignment.bottomRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     ElevatedButton(onPressed: (){}, 
                      //         style: ElevatedButton.styleFrom(
                      //           shape: StadiumBorder(),
                      //           backgroundColor: prs.colorMorado
                      //         ),
                      //         child: Row(
                      //           children: [
                      //             Text('Ir Taxi',style: TextStyle(
                      //                   // color: prs.colorMorado, 
                      //                   fontFamily: 'GoldplayRegular',
                      //                   fontWeight: FontWeight.w800,
                      //                   fontSize: 17)),
                      //             SizedBox(width: 10,),
                      //         Icon(Icons.arrow_forward_ios_sharp)
                      //           ],
                      //         )),
                      //   ],
                      // ),
                      //           SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(onPressed: (){
                            if(_prefs.clienteModel.perfil.toString() != '0'){
                              _prefs.isTaxi = true;
                              Navigator.pushNamed(context, 'solicitudes');
                            }else{
                                   _prefs.isTaxi = false;
                              Navigator.pushNamed(context, 'taxis');
                            }
                          }, 
                          style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(),
                            backgroundColor: prs.colorMorado
                          ),
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                            child: Row(
                              children: [
                                Text('Ir a Taxi',style: TextStyle(
                                      // color: prs.colorMorado, 
                                      fontFamily: 'GoldplayRegular',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20)),
                                      SizedBox(width: 10,),
                                Icon(Icons.arrow_forward_ios_sharp)
                              ],
                            ),
                          )),
                          SizedBox(width: 20,),
                          Expanded(
                            child: Text('MI MÓVIL',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color: prs.colorMorado,
                                  fontFamily: 'GoldplayBlack',
                                  fontSize: 25
                                ),),
                          ),
                         
                        ],
                      ),
                      SizedBox(height: 10,),
                      Text.rich(
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(text: 'Presiona el botón ', 
                              style: TextStyle(
                                color: prs.colorMorado, 
                                fontFamily: 'GoldplayRegular',
                                fontWeight: FontWeight.w800,
                                fontSize: 17)),
                              TextSpan(text: 'si quiere pedir un taxi o realizar envios', 
                              style: TextStyle(
                                fontFamily: 'GoldplayRegular',
                                color: Colors.black,
                                fontSize: 17)),
                            ],
                          ),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Goldplay'
                          ),
                        ),
                        SizedBox(height: 10,)
                    ],
                  ),
                ),
              ],
            ),
          ),
          // MiMovilPage()
        ],
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
    
  }
}



