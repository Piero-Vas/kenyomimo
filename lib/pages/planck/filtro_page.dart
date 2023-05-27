import 'package:flutter/material.dart';
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;

class FiltroPage extends StatefulWidget {
  const FiltroPage({Key key}) : super(key: key);

  @override
  State<FiltroPage> createState() => _FiltroPageState();
}

class _FiltroPageState extends State<FiltroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          TextButton(
              onPressed: () {},
              child: Text(
                'Deshacer todo  ',
                style: TextStyle(
                    color: prs.colorRojo,
                    fontSize: 17,
                    fontFamily: 'GoldplayRegular',
                    fontWeight: FontWeight.w700),
              ))
        ],
        leading: utils.leading(context),
      ),
      body: Container(
        height: double.infinity,
        color: Colors.white,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Ordenar Por",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'GoldplayRegular',
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.50 - 30,
                        child: boton('', 'Sugeridos')),
                    SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.50 - 30,
                        child: boton('', 'Puntuación'))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.50 - 30,
                        child: boton('', 'Tiempo de entrega')),
                    SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.50 - 30,
                        child: boton('', 'Cercanía'))
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Row(
                  children: [
                    Text(
                      "Filtrar Por",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'GoldplayRegular',
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.60 - 30,
                        child: boton("assets/png/clock.png",
                            "Llega en menos de 30 min.")),
                    SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.40 - 30,
                        child: boton("assets/png/star.png", "Más de 4"))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.50 - 30,
                        child:
                            boton("assets/png/recien.png", "Recien Llegado")),
                    SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.50 - 30,
                        child: boton(
                            "assets/png/porcentaje.png", "Con hasta 80% dcto"))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: boton(
                            "assets/png/recojo.png", "Con hasta 80% dcto"))
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Row(
                  children: [
                    Text(
                      "Filtrar Por",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'GoldplayRegular',
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.30 - 10,
                        child: boton("", "Chifa.")),
                    SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.30 - 10,
                        child: boton("", "Carnes")),
                    SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.30 - 10,
                        child: boton("", "Postres"))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.30 - 10,
                        child: boton("", "Saludable")),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget boton(img, texto) {
  return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          backgroundColor: Colors.transparent,
          elevation: 0,
          side: BorderSide(width: 1, color: Color(0xFF2D2D31)),
          shape: StadiumBorder()),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          img != ''
              ? Image(
                  image: AssetImage(img),
                  width: 25,
                )
              : Container(),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: Text(
            texto,
            style: TextStyle(
                fontSize: 15,
                fontFamily: 'GoldplayRegular',
                color: Colors.black),
          ))
        ],
      ));
}
