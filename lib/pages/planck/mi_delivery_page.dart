import 'package:mimo/preference/shared_preferences.dart';
import 'package:mimo/utils/personalizacion.dart' as prs;
import 'package:flutter/material.dart';
import '../../utils/button.dart' as btn;

class MiDeliveryPage extends StatefulWidget {
  MiDeliveryPage({Key key}) : super(key: key);

  @override
  State<MiDeliveryPage> createState() => _MiDeliveryPageState();
}

class _MiDeliveryPageState extends State<MiDeliveryPage> {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  continuar() {
    Navigator.pushNamed(context, 'seleccion');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        
        if(_prefs.clienteModel.perfil.toString() == '2'){
            Navigator.pushNamed(context, 'compras_despacho');
        }else{
           Navigator.pushNamed(context, 'catalogo2');
        }
        
      },
      child: Scaffold(
          body: Container(
        // decoration: BoxDecoration(
        //     gradient: LinearGradient(
        //         colors: [prs.hexToColor('#F73B3B'), prs.hexToColor('#FF3270')],
        //         begin: Alignment.topRight,
        //         end: Alignment.bottomLeft)),
        // padding: EdgeInsets.all(20),
        // width: double.infinity,
        // child: Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: [
        //     Stack(
        //       children: <Widget>[
        //         // Stroked text as border.
        //         Text(
        //           'MI DELIVERY',
        //           textAlign: TextAlign.center,
        //           style: TextStyle(
        //               fontFamily: 'GoldPlayBlack',
        //               fontStyle: FontStyle.italic,
        //               fontSize: 60,
        //               foreground: Paint()
        //                 ..style = PaintingStyle.stroke
        //                 ..strokeWidth = 6
        //                 ..color = Colors.white),
        //         ),
        //         // Solid text as fill.
        //         Text(
        //           'MI DELIVERY',
        //           textAlign: TextAlign.center,
        //           style: TextStyle(
        //             fontFamily: 'GoldPlayBlack',
        //             fontStyle: FontStyle.italic,
        //             fontSize: 60,
        //             color: prs.hexToColor('#FA3751'),
        //           ),
        //         ),
        //       ],
        //     ),
        //     Stack(
        //       children: <Widget>[
        //         // Stroked text as border.
        //         Text(
        //           'MI DELIVERY',
        //           textAlign: TextAlign.center,
        //           style: TextStyle(
        //             fontFamily: 'GoldPlayBlack',
        //             fontStyle: FontStyle.italic,
        //             fontSize: 60,
        //             foreground: Paint()
        //               ..style = PaintingStyle.stroke
        //               ..strokeWidth = 6
        //               ..color = prs.hexToColor('#FA3751'),
        //           ),
        //         ),
        //         // Solid text as fill.
        //         Text(
        //           'MI DELIVERY',
        //           textAlign: TextAlign.center,
        //           style: TextStyle(
        //               fontFamily: 'GoldPlayBlack',
        //               fontStyle: FontStyle.italic,
        //               fontSize: 60,
        //               color: Colors.white),
        //         ),
        //       ],
        //     ),
        //     Stack(
        //       children: <Widget>[
        //         // Stroked text as border.
        //         Text(
        //           'MI DELIVERY',
        //           textAlign: TextAlign.center,
        //           style: TextStyle(
        //               fontFamily: 'GoldPlayBlack',
        //               fontStyle: FontStyle.italic,
        //               fontSize: 60,
        //               foreground: Paint()
        //                 ..style = PaintingStyle.stroke
        //                 ..strokeWidth = 6
        //                 ..color = Colors.white),
        //         ),
        //         // Solid text as fill.
        //         Text(
        //           'MI DELIVERY',
        //           textAlign: TextAlign.center,
        //           style: TextStyle(
        //             fontFamily: 'GoldPlayBlack',
        //             fontStyle: FontStyle.italic,
        //             fontSize: 60,
        //             color: prs.hexToColor('#FA3751'),
        //           ),
        //         ),
        //       ],
        //     )
        //   ],
        // ),
      
      )),
    );
  }
}
