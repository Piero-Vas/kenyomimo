import 'package:mimo/preference/shared_preferences.dart';
import 'package:mimo/utils/personalizacion.dart' as prs;
import 'package:flutter/material.dart';
import '../../utils/button.dart' as btn;

class RevisaCorreoPage extends StatefulWidget {
  RevisaCorreoPage({Key key}) : super(key: key);
  @override
  State<RevisaCorreoPage> createState() => _RevisaCorreoPageState();
}

class _RevisaCorreoPageState extends State<RevisaCorreoPage> {
  final PreferenciasUsuario prefs = PreferenciasUsuario();
  String _claveValue = "";
continuar() {
    if(prefs.claveTemp == _claveValue){
      Navigator.pushNamed(context, 'nueva_pass');
    }else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.0),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/png/cancelar.png',
                  height: 50.0,
                ),
                const SizedBox(
                  height: 12.0,
                ),
                Row(
                  children: [
                    Text(
                      "El codigo no es valido",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.normal,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5090FE),
                ),
                child: const Text("Aceptar"),
              )
            ],
          );
        },
      );
    }
  }

  Widget _crearClave() {
    return TextFormField(
        maxLength: 8,
        decoration: prs.decoration('Ingrese Codigo', null),
        onChanged: (value) => _claveValue = value.trim()
      );
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
                      prs.textoPantallas("¡REVISA","#F73B3B",78),
                      prs.textoPantallas("TU","#F7BC45",78),
                      prs.textoPantallas("CORREO!","#800059",78),
                      SizedBox(height: 20,),
                    Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: 'Ve a tu ', style: TextStyle(color: Colors.black)),
                          TextSpan(text: 'bandeja de entrada, ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          TextSpan(text: 'revisa el correo enviado por nuestro equipo e ingresa el codigo de recuperación,', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'Goldplay'
                      ),
                    ),
                    SizedBox(height:70,),
                    _crearClave(),
                    SizedBox(height:70,),
                    btn.bootonContinuar('Continuar', continuar),
                  ],
                ),  
              ),
            
        ),
      )
    );
    
  }
}