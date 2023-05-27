// import 'dart:html';

import 'package:mimo/model/notificacion_model.dart';
import 'package:mimo/utils/personalizacion.dart' as prs;
import 'package:flutter/material.dart';
import '../../utils/button.dart' as btn;

class ActualizarPlayStorePage extends StatefulWidget {
  ActualizarPlayStorePage({Key key}) : super(key: key);

  @override
  State<ActualizarPlayStorePage> createState() => _ActualizarPlayStorePageState();
}

class _ActualizarPlayStorePageState extends State<ActualizarPlayStorePage> {
  
NotificacionModel noti = NotificacionModel();
continuar() {
    noti.launchURL("https://play.google.com/store/apps/details?id=com.deliverytaxi.mimo");

  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Container(
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                  children:[
                      prs.textoPantallas("ACTUALIZACIÓN","#F73B3B",40),
                      // prs.textoPantallas("TU","#F7BC45",78),
                      prs.textoPantallas("DISPONIBLE","#800059",40),
                      SizedBox(height: 20,),
                    Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: 'Es necesario ', style: TextStyle(color: Colors.black)),
                          TextSpan(text: 'realizar esta actualización, ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          TextSpan(text: 'debido a los grandes cambios realizados', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'Goldplay'
                      ),
                    ),
                    SizedBox(height:280,),
                    btn.bootonContinuar('Actualizar', continuar),
                  ],
                ),
              
                
                
                
              ),
            
        ),
      )
    );
    
  }
}



