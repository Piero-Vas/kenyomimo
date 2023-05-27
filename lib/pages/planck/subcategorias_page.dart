// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mimo/model/categoria_model.dart';
import 'package:mimo/sistema.dart';
import '../../utils/cache.dart' as cache;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import 'package:flutter_svg/flutter_svg.dart';

class SubCategoriasPage extends StatefulWidget {
  const SubCategoriasPage({Key key}) : super(key: key);

  @override
  State<SubCategoriasPage> createState() => _SubCategoriasPageState();
}

class _SubCategoriasPageState extends State<SubCategoriasPage> {
  TextEditingController _textControllerBuscar;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        // shadowColor: Colors.black,
        centerTitle: true,
        title: Text(
          "Detalles deaaaaaaaa viaje",
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
        leading: utils.leading(context),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          // height: double.infinity,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(
                        'Restaurantes',
                        style: TextStyle(
                            fontFamily: 'GoldplayRegular',
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                            color: prs.colorRojo),
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width * 0.8 - 30,
                          child: _buscador()),
                      SizedBox(
                        width: 20,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 10.0, right: 10.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: prs.colorGrisAreaTexto),
                        width: MediaQuery.of(context).size.width * 0.2 - 30,
                        child: Container(
                            child: Icon(
                          Icons.filter_alt_rounded,
                          color: prs.colorGrisClaro,
                          size: 27,
                        )),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: double.infinity,
                    // color: Colors.red,
                    height: 150,
                    child: GridView.builder(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 1,
                        childAspectRatio: 1,
                      ),
                      itemCount: 21,
                      itemBuilder: ((context, index) {
                        return Container(
                          // color: Colors.red,
                          child: Column(
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(100),
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            'https://www.pequerecetas.com/wp-content/uploads/2013/07/hamburguesas-caseras-receta.jpg'))),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    'Hamburguesas',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'GoldplayRegular',
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  )),
                                ],
                              )
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Text(
                        'FAVORITOS',
                        style: TextStyle(
                            fontFamily: 'GoldplayBlack',
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                            color: Colors.black),
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 12,
                      itemBuilder: (context, index) => Container(
                        width: 130,
                        height: 200,
                        margin: EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                            // color: Colors.red,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(100),
                              topRight: Radius.circular(100),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            border: Border.all(color: prs.colorLineBorder)),
                        child: Column(
                          children: [
                            Container(
                              height: 120,
                              width: 130,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(100),
                                    topRight: Radius.circular(100),
                                  ),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          'https://www.pequerecetas.com/wp-content/uploads/2013/07/hamburguesas-caseras-receta.jpg'))),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text("Hamburguesas Cuadradas",
                                overflow: TextOverflow.visible,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.black,
                                )),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.red,
                              ),
                              child: Row(children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: Colors.white,
                                ),
                                Text(
                                  '5.0',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'GoldplayRegular',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )
                              ]),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Text(
                        'RECOMENDADOS',
                        style: TextStyle(
                            fontFamily: 'GoldplayBlack',
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                            color: Colors.black),
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 400,
                    child: ListView.builder(
                        // shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount: 10,
                        itemBuilder: ((context, index) => GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, 'categorias');
                              },
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 80,
                                        width: 80,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                    'https://www.pequerecetas.com/wp-content/uploads/2013/07/hamburguesas-caseras-receta.jpg'))),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Expanded(
                                        child: Container(
                                          // color: Colors.red,
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: Text(
                                                    'Hamburguesas Cuadradas',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'GoldplayRegular',
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ))
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.star_rounded,
                                        color: Colors.red,
                                      ),
                                      Text(
                                        '5.0',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'GoldplayRegular',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Divider(
                                    color: Colors.black87,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ),
                            ))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buscador() {
    return Container(
      // padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: TextFormField(
        controller: _textControllerBuscar,
        keyboardType: TextInputType.text,
        decoration: prs.decorationSearch(Sistema.SEARCH_MENSJAE),
        onFieldSubmitted: (value) async {
          FocusScope.of(context).requestFocus(FocusNode());
          _textControllerBuscar.text = '';
          if (value.length <= 2) {
            if (mounted) setState(() {});
            return;
          }
          CategoriaModel _categoria = CategoriaModel();
          _categoria.idCategoria = 0;
          // _onSpeedDialAction(_categoria, criterio: value, isBuscar: true);
        },
      ),
    );
  }
}
