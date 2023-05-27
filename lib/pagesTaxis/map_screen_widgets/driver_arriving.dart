import 'package:flutter/material.dart';
import 'package:mimo/model/map_action.dart';
import 'package:mimo/Core/ProviderModels/MapModel.dart';
import '../../utils/personalizacion.dart' as prs;

class DriverArriving extends StatefulWidget {
  const DriverArriving({Key key, this.mapProvider}) : super(key: key);
  final MapModel mapProvider;
  @override
  State<DriverArriving> createState() => _DriverArrivingState();
}

class _DriverArrivingState extends State<DriverArriving> {

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.mapProvider.mapAction == MapAction.driverArriving,
      child: Positioned(
        bottom: 15,
        left: 15,
        right: 15,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                Expanded(
                  child: Text('El conductor esta en camino',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'GoldplayRegular')),
                ),
                Container()
              ],),
              SizedBox(height: 15,),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.mapProvider.ongoingTrip != null
                          ? widget.mapProvider.ongoingTrip.driverTradeMark !=
                                  null && widget.mapProvider.ongoingTrip.driverTradeMark !=
                                  null
                              ? widget.mapProvider.ongoingTrip.driverTradeMark + ' (' + widget.mapProvider.ongoingTrip.driverColor + ')'
                              : "----"
                          : "----",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'GoldplayRegular'),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.green,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        widget.mapProvider.ongoingTrip != null
                            ? widget.mapProvider.ongoingTrip
                                        .driverLicensePlate !=
                                    null
                                ? widget.mapProvider.ongoingTrip.driverLicensePlate
                                : "----"
                            : "----",
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'GoldplayBlack'),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: prs.colorGrisBordes,
                      ),
                      borderRadius: BorderRadius.circular(30)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.red),
                          child: Image.network(widget.mapProvider.ongoingTrip !=
                                  null
                              ? widget.mapProvider.ongoingTrip.driverImg != null
                                  ? widget.mapProvider.ongoingTrip.driverImg
                                  : "https://climate.onep.go.th/wp-content/uploads/2020/01/default-image.jpg"
                              : "https://climate.onep.go.th/wp-content/uploads/2020/01/default-image.jpg"),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.mapProvider.ongoingTrip != null
                                    ? widget.mapProvider.ongoingTrip
                                                .driverName !=
                                            null
                                        ? widget
                                            .mapProvider.ongoingTrip.driverName
                                        : "----"
                                    : "----",
                                textAlign: TextAlign.start,
                                style: TextStyle(fontFamily: 'GoldplayRegular'),
                              ),
                              Row(
                                children: [
                                  Image(
                                    image: AssetImage("assets/png/star.png"),
                                    height: 25,
                                    width: 25,
                                  ),
                                  Text(widget.mapProvider.ongoingTrip != null
                                    ? widget.mapProvider.ongoingTrip.driverCalification != null
                                        ? widget.mapProvider.ongoingTrip.driverCalification
                                        : "0"
                                    : "0"
                                    ,style: TextStyle(fontFamily: 'GoldplayRegular'),),
                                ],
                              )
                            ],
                          ),
                        ),
                        // Expanded(child: Container()),s
                      ],
                    ),
                  )),
              SizedBox(
                height: 15,
              ),
              Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: prs.colorGrisBordes,
                      ),
                      borderRadius: BorderRadius.circular(30)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.red,
                              image: DecorationImage(
                                  image: AssetImage(widget.mapProvider.ongoingTrip != null
                                    ? widget.mapProvider.ongoingTrip.typePayment !=
                                            null
                                        ? widget.mapProvider.ongoingTrip.typePayment == 1
                                          ? 'assets/png/efectivo.png'
                                          : widget.mapProvider.ongoingTrip.typePayment == 2
                                            ? 'assets/png/yape.png'
                                            : widget.mapProvider.ongoingTrip.typePayment == 3
                                              ? 'assets/png/plin.png'
                                              : 'assets/png/cartera.png'
                                        : 'assets/png/cartera.png'
                                    : 'assets/png/cartera.png'),
                                  fit: BoxFit.cover)),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                               widget.mapProvider.ongoingTrip != null
                                    ? widget.mapProvider.ongoingTrip.cost !=
                                            null
                                        ? 'S/. ${widget.mapProvider.ongoingTrip.cost
                                            .toString()}'
                                        : "----"
                                    : "----",
                                textAlign: TextAlign.start,
                              ),
                              Row(
                                children: [
                                  widget.mapProvider.ongoingTrip != null
                                      ? widget.mapProvider.ongoingTrip.passengerCard != null
                                          ? widget.mapProvider.ongoingTrip.typePayment !=null
                                            ? widget.mapProvider.ongoingTrip.typePayment == 1
                                              // ? Text('Débito •••• ${widget.mapProvider.ongoingTrip.passengerCard}')
                                              ? Text('Pago con Efectivo')
                                              : widget.mapProvider.ongoingTrip.typePayment == 2
                                                ? Text('Pago con Yape')
                                                : widget.mapProvider.ongoingTrip.typePayment == 3 
                                                  ? Text('Pago con Plin')
                                                  : Text('Débito •••• ${widget.mapProvider.ongoingTrip.passengerCard}')

                                            : SizedBox()
                                          :SizedBox()
                                      : SizedBox(),
                                ],
                              )
                            ],
                          ),
                        ),
                        // Expanded(child: Container()),s
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}