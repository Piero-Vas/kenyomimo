import 'package:mimo/utils/personalizacion.dart' as prs;
import 'package:flutter/material.dart';
import '../../utils/button.dart' as btn;

class CambioPassPage extends StatefulWidget {
  CambioPassPage({Key key}) : super(key: key);

  @override
  State<CambioPassPage> createState() => _CambioPassPageState();
}

class _CambioPassPageState extends State<CambioPassPage> {
  
continuar() {
    Navigator.pushNamedAndRemoveUntil(context, 'principal', (route) => false);
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
                      prs.textoPantallas("¡CAMBIO","#F73B3B",45),
                      prs.textoPantallas("REALIZADO","#F7BC45",45),
                      prs.textoPantallas("EXITOSAMENTE!","#800059",40),
                      SizedBox(height: 20,),
                    Column(
                      children: [
                        Text('Cambiaste tu contraseña ', style: TextStyle(color: Colors.black,fontSize: 20,fontFamily: 'GoldplayRegular')),
                        Text( 'correctamente.', style: TextStyle(color: Colors.black,fontSize: 20,fontFamily: 'GoldplaBlack')),
                        Text('Vuelve al inicio de la app e ingresa con tu nueva contraseña',textAlign: TextAlign.center, style: TextStyle(color: Colors.black,fontSize: 22,fontFamily: 'GoldplayRegular')),
                      ],
                    ),
                    SizedBox(height: 200,),
                    btn.bootonContinuar('Continuar', continuar),
                    
                  ],
                ),      
              ),
            
        ),
      )
    );
    
  }
}