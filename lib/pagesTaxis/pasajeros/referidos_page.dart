import 'package:flutter/material.dart';
import 'package:mimo/widgets/menu_taxis_widget.dart';
import '../../../utils/personalizacion.dart' as prs;

class ReferidosPage extends StatefulWidget {
  const ReferidosPage({Key key}) : super(key: key);

  @override
  State<ReferidosPage> createState() => _ReferidosPageState();
}

class _ReferidosPageState extends State<ReferidosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuWidgetTaxis(),
      appBar: AppBar(
        // backgroundColor: Colors.white,
        // shadowColor: Colors.black,
        leading: Builder(builder: (context)=> Padding(
          padding: const EdgeInsets.all(15.0),
          child: GestureDetector(onTap: () {
            Scaffold.of(context).openDrawer();
          }, child: Image(image: AssetImage("assets/png/menu.png"),),),
        ),),
        centerTitle: true,
        title: Text(
          "Referidos",
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
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        color: Colors.white,
        width: prs.anchoFormulario,
        child: Column(
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Recibe un  ",
                    style: TextStyle(
                      fontFamily: "GoldplayRegular",
                      fontSize: 17,
                    ),
                  ),
                  TextSpan(
                    text: "descuento en tus envíos ",
                    style: TextStyle(
                        fontFamily: "GoldplayRegular",
                        fontWeight: FontWeight.w600,
                        color: prs.colorMorado,
                        fontSize: 17),
                  ),
                  TextSpan(
                    text:
                        "por cada amigo que haga su primer pedido con tu código; a cambio, ellos también recibirán un descuento en su primer pedido.",
                    style: TextStyle(
                      fontFamily: "GoldplayRegular",
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(color: prs.colorGrisBordes),
                  borderRadius: BorderRadius.circular(22)),
              child: Column(
                children: [
                  Text(
                    "Tu código",
                    style: TextStyle(
                      fontFamily: "GoldplayRegular",
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Expanded(child: Container()),
                      Text(
                        "xt8005666pt".toUpperCase(),
                        style: TextStyle(
                          fontFamily: "GoldplayBlack",
                          fontSize: 28,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.copy),
                        color: prs.colorMorado,
                      )
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Compartir en:",
              style: TextStyle(
                fontFamily: "GoldplayRegular",
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: (){},
                    child: Image(
                  image: AssetImage(
                    "assets/png/whatsapp.png",
                  ),
                  height: 60,
                )),
                GestureDetector(
                  child: Image(
                    image: AssetImage(
                      "assets/png/facebook.png",
                    ),
                    height: 60,
                  ),
                ),
                GestureDetector(
                  child: Image(
                    image: AssetImage(
                      "assets/png/messenger.png",
                    ),
                    height: 60,
                  ), 
                ),
                GestureDetector(
                  child: Image(
                    image: AssetImage(
                      "assets/png/more.png",
                    ),
                    height: 60,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
