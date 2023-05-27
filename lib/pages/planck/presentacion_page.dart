import 'package:mimo/utils/personalizacion.dart' as prs;
import 'package:flutter/material.dart';
import '../../utils/button.dart' as btn;

class PresentacionPage extends StatefulWidget {
  PresentacionPage({Key key}) : super(key: key);

  @override
  State<PresentacionPage> createState() => _PresentacionPageState();
}

class _PresentacionPageState extends State<PresentacionPage> {
  
continuar() {
    Navigator.pushNamed(context, 'principal');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
        width: double.infinity,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children:[
              textoPantallas("SIEMPRE","#800059"),
              textoPantallas("SIEMPRE","#F7BC45"),
              textoPantallas("SIEMPRE","#F73B3B"),
              textoPantallas("CONTIGO","#F73B3B"),
              textoPantallas("CONTIGO","#F7BC45"),
              textoPantallas("CONTIGO","#800059"),
            Text(
              "Este equipo, comprometido a brindarte un servicio de calidad, te da la bienvenida.",
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontFamily: 'GoldplayRegular',
                ),
              textAlign: TextAlign.center,
              
            ),
            SizedBox(height: 20,),
            btn.bootonContinuar('Continuar', continuar),
          ],
        ),
      
        )
        
        
        
      )
    );
    
  }
}



Widget textoPantallas(String texto,String color){
  return Text("$texto".toUpperCase(), textAlign:TextAlign.center,
    style:TextStyle(
      fontFamily: 'GoldplayBlack',
      fontSize: 76,
      fontStyle: FontStyle.italic,
      color: prs.hexToColor('${color}'),
    ));
}