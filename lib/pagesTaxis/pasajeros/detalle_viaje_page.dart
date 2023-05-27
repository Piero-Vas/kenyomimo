import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;

class DetalesViajePage extends StatefulWidget {
  final String fecha ;
  final String desde;
  final String hasta;
  final double precio;
  final String nombre;
  final String placa;
  final double distancia;
  final int tipopayment;
  final String img;
  final String marca;
  final String modelo;
  final String card;
  final String nameCard;
  const DetalesViajePage(this.fecha, this.desde,this.hasta, this.precio,this.nombre,this.placa,this.distancia,this.tipopayment,this.img,this.marca,this.modelo,this.card,this.nameCard);

  @override
  State<DetalesViajePage> createState() => _DetalesViajePageState();
}

class _DetalesViajePageState extends State<DetalesViajePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        // shadowColor: Colors.black,
        centerTitle: true,
        title: Text(
          "Detalles de viaje",
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
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(width: 70,height: 70,child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network('${widget.img}'),
                  ),),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Expanded(child: Text('${widget.nombre}',textAlign: TextAlign.center,style: TextStyle(fontFamily: 'GoldplayRegular', fontSize: 24, fontWeight: FontWeight.w700),)),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Container(
                      // padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: prs.colorGrisBordes)),
                      child: Column(children: [
                        Container(
                          margin: EdgeInsets.only(top: 20, left: 20),
                          child: Row(
                            children: [
                              Text(
                                'Información',
                                style: TextStyle(
                                    fontFamily: 'GoldplayBlack',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Container())
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(
                          thickness: 1,
                          color: prs.colorGrisBordes,
                        ),
                        Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(children: [
datos('Fecha', '${widget.fecha}', 'viajes'),
                        datos('Desde', '${widget.desde}', 'indicador'),
                        datos('Hasta', '${widget.hasta}', 'indicador2'),
                        datos('Precio', 'S/. ${widget.precio}', 'referidos'),
                        // datos('Nombre Conductor', '${widget.nombre}', 'datos'),
                        
                        Row(
                          children: [
                            SizedBox(
                                width: 30,
                                height: 30,
                                child: Icon(FontAwesomeIcons.road,
                                    color: prs.colorMorado)),
                                    SizedBox(width: 10,),
                            Text('Distancia :',style: TextStyle(fontFamily: 'GoldplayRegular', fontSize: 16, fontWeight: FontWeight.w700),),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Container(),
                            Expanded(
                                child: Container(
                              child: Text(
                                  '${widget.distancia.toStringAsFixed(2)} Km',style: TextStyle(fontFamily: 'GoldplayRegular', fontSize: 15,),),
                            )),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        datos('Placa de vehiculo', '${widget.placa}', 'placa'),
                        Row(
                          children: [
                            SizedBox(
                                width: 30,
                                height: 30,
                                child: Icon(FontAwesomeIcons.car,
                                    color: prs.colorMorado)),
                                    SizedBox(width: 10,),
                            Text('Marca :',style: TextStyle(fontFamily: 'GoldplayRegular', fontSize: 16, fontWeight: FontWeight.w700),),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Container(),
                            Expanded(
                                child: Container(
                              child: Text(
                                  '${widget.marca}',style: TextStyle(fontFamily: 'GoldplayRegular', fontSize: 15,),),
                            )),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),

                        Row(
                          children: [
                            SizedBox(
                                width: 30,
                                height: 30,
                                child: Icon(FontAwesomeIcons.car,
                                    color: prs.colorMorado)),
                                    SizedBox(width: 10,),
                            Text('Modelo :',style: TextStyle(fontFamily: 'GoldplayRegular', fontSize: 16, fontWeight: FontWeight.w700),),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Container(),
                            Expanded(
                                child: Container(
                              child: Text(
                                  '${widget.modelo} Km',style: TextStyle(fontFamily: 'GoldplayRegular', fontSize: 15,),),
                            )),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        // Row(
                        //   children: [
                        //     SizedBox(
                        //         width: 30,
                        //         height: 30,
                        //         child: Icon(FontAwesomeIcons.idCard,
                        //             color: prs.colorMorado)),
                        //             SizedBox(width: 10,),
                        //     Text('Distancia :',style: TextStyle(fontFamily: 'GoldplayRegular', fontSize: 16, fontWeight: FontWeight.w700),),
                        //   ],
                        // ),
                        // Row(
                        //   children: [
                        //     Container(),
                        //     Expanded(
                        //         child: Container(
                        //       child: Text(
                        //           '2asdaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',style: TextStyle(fontFamily: 'GoldplayRegular', fontSize: 15,),),
                        //     )),
                        //   ],
                        // ),
                        
                            ],),),
                        
                      ])),
                  SizedBox(height: 15,),
                  Container(
                      // padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: prs.colorGrisBordes)),
                      child: Column(children: [
                        Container(
                          margin: EdgeInsets.only(top: 20, left: 20),
                          child: Row(
                            children: [
                              Text(
                                'Forma de pago',
                                style: TextStyle(
                                    fontFamily: 'GoldplayBlack',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              
                              Expanded(child: Container())
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(
                          thickness: 1,
                          color: prs.colorGrisBordes,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: 10, left: 20, bottom: 20, right: 20),
                          child: Row(
                            children: [
                               if(widget.tipopayment == 1)
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                 
                                    image: DecorationImage(
                                        image: AssetImage(
                                          'assets/png/efectivo.png',
                                        ),
                                        fit: BoxFit.cover),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    color: prs.hexToColor('#1746A2')),
                              )
                              else if(widget.tipopayment == 2)
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                 
                                    image: DecorationImage(
                                        image: AssetImage(
                                          'assets/png/yape.png',
                                        ),
                                        fit: BoxFit.cover),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    color: prs.hexToColor('#1746A2')),
                              )
                              else if(widget.tipopayment == 3)
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                 
                                    image: DecorationImage(
                                        image: AssetImage(
                                          'assets/png/plin.png',
                                        ),
                                        fit: BoxFit.cover),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    color: prs.hexToColor('#1746A2')),
                              )
                              else if(widget.tipopayment == 4)
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                 
                                    image: DecorationImage(
                                        image: AssetImage(
                                          'assets/png/tarjetadecredito.png',
                                        ),
                                        fit: BoxFit.cover),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    color: prs.hexToColor('#1746A2')),
                              )
                              ,
                              SizedBox(
                                width: 20,
                              ),
                              if(widget.tipopayment == 1)
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pago con efectivo',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    ),
                                   
                                  ],
                                ),
                              )
                              else if(widget.tipopayment == 2)
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pago con Yape',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    ),
                                   
                                  ],
                                ),
                              )
                              else if(widget.tipopayment == 3)
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pago con Plin',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    ),
                                   
                                  ],
                                ),
                              )
                              else if(widget.tipopayment == 4)
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Debito ***** ${widget.card}',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text('${widget.nameCard}',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontSize: 17,
                                        )),
                                  ],
                                ),
                              )
                              
                              
                            ],
                          ),
                        ),
                      ])),
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
    Widget datos(titulo, subtitlo, imagen) {
    return Column(
      children: [
        Row(
          children: [
            Image(
              image: AssetImage(
                'assets/png/$imagen.png',
              ),
              width: 30,
              height: 30,
            ),
            SizedBox(width: 10,),
            Text('$titulo :',style: TextStyle(fontFamily: 'GoldplayRegular', fontSize: 16, fontWeight: FontWeight.w700),),
          ],
        ),
        SizedBox(height: 10,),
        Row(
          children: [
            Container(),
            Expanded(
                child: Container(
              child: Text(subtitlo,style: TextStyle(fontFamily: 'GoldplayRegular', fontSize: 15,),),
            )),
          ],
        ),
        SizedBox(height: 10,),
      ],
    );
  }

}