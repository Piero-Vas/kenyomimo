// import 'package:mimo/preference/shared_preferences.dart';
// import 'package:mimo/utils/personalizacion.dart' as prs;
// import 'package:flutter/material.dart';

// class MiMovilPage extends StatefulWidget {
//   MiMovilPage({Key key}) : super(key: key);

//   @override
//   State<MiMovilPage> createState() => _MiMovilPageState();
// }

// class _MiMovilPageState extends State<MiMovilPage> {
//   continuar(){
//     final _prefs = PreferenciasUsuario();
//         if (_prefs.auth == '' || _prefs.auth=='/LKHJGASLJKHG/97647/LKHGJH/LKGJLH') {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Debe registrarse!",style: TextStyle(color: Colors.white),)
//           ,duration: Duration(seconds: 3),backgroundColor: prs.colorBotones,));
//           Navigator.pushNamed(context, 'principal');
//         }else{
//           _prefs.isTaxi = false;
//           Navigator.pushNamed(context, 'taxis');
//         }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: continuar,
//       child: Scaffold(
//         body: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   prs.hexToColor('#E3006D'),
//                   prs.hexToColor('#800059')
//                 ],
//                 begin: Alignment.topRight,
//                 end: Alignment.bottomLeft
//               )
//             ),
//             padding: EdgeInsets.all(20),
//             width: double.infinity,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Stack(
//                 children: <Widget>[
//                   // Stroked text as border.
//                   Text(
//                     'MI MÓVIL',
//                     style: TextStyle(
//                       fontFamily: 'GoldPlayBlack',
//                       fontStyle: FontStyle.italic,
//                       fontSize: 70,
//                       foreground: Paint()
//                         ..style = PaintingStyle.stroke
//                         ..strokeWidth = 6
//                         ..color = Colors.white
//                     ),
//                   ),
//                   // Solid text as fill.
//                   Text(
//                     'MI MÓVIL',
//                     style: TextStyle(
//                       fontFamily: 'GoldPlayBlack',
//                       fontStyle: FontStyle.italic,
//                       fontSize: 70,
//                       color: prs.hexToColor('#B60264'),
//                     ),
//                   ),
//                 ],
//               ),
//               Stack(
//                 children: <Widget>[
//                   Text(
//                     'MI MÓVIL',
//                     style: TextStyle(
//                       fontFamily: 'GoldPlayBlack',
//                       fontStyle: FontStyle.italic,
//                       fontSize: 70,
//                       color: Colors.white
//                     ),
//                   ),
//                 ],
//               ),
//               Stack(
//                 children: <Widget>[
//                   // Stroked text as border.
//                   Text(
//                     'MI MÓVIL',
//                     style: TextStyle(
//                       fontFamily: 'GoldPlayBlack',
//                       fontStyle: FontStyle.italic,
//                       fontSize: 70,
//                       foreground: Paint()
//                         ..style = PaintingStyle.stroke
//                         ..strokeWidth = 6
//                         ..color = Colors.white
//                     ),
//                   ),
//                   // Solid text as fill.
//                   Text(
//                     'MI MÓVIL',
//                     style: TextStyle(
//                       fontFamily: 'GoldPlayBlack',
//                       fontStyle: FontStyle.italic,
//                       fontSize: 70,
//                       color: prs.hexToColor('#A30161'),
//                     ),
//                   ),
//                 ],
//               )
    
//               ],
//             ),
            
//           ),
//       ),
//     );
    
//   }
// }