import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mimo/pagesTaxis/pasajeros/viajes_page.dart';
import '../../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;

class CalificacionPage extends StatefulWidget {
  final DocumentSnapshot trip;
  const CalificacionPage({Key key, this.trip}) : super(key: key);

  @override
  State<CalificacionPage> createState() => _CalificacionPageState();
}

class _CalificacionPageState extends State<CalificacionPage> {
  TextEditingController description = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                "Calificación",
                style: TextStyle(
                    color: Color(0xFF4B4B4E),
                    fontSize: 24,
                    fontFamily: 'GoldplayRegular',
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                // color: Colors.red,
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.0),
                  child: Image.asset(
                    "assets/png/calificacion.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Gonzalo Torres",
                style: TextStyle(
                    // color: Color(0xFF4B4B4E),
                    fontSize: 18,
                    fontFamily: 'GoldplayRegular',
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 20,
              ),
              _estrellasTaxis(),
              SizedBox(
                height: 20,
              ),
              Text(
                "Toca una estrella para calificar",
                style: TextStyle(
                    color: prs.colorGrisClaro,
                    fontSize: 14,
                    fontFamily: 'GoldplayRegular',
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: description,
                minLines: 4,
                maxLines: 6,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: prs.colorGrisAreaTexto,
                  hintText: 'Escribe una reseña (opcional)',
                  hintStyle: TextStyle(
                      fontFamily: 'GoldplayRegular', color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(20)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(20)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
              ),
              SizedBox(
                height: 180,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Map trip = widget.trip.data() as Map;
                    trip['wasRated'] = true;
                    DateTime dateTripTemp = DateTime.fromMillisecondsSinceEpoch(trip['createatMili']);
                    DateTime dateTrip = DateTime(dateTripTemp.year, dateTripTemp.month, dateTripTemp.day);
                    trip['createatDate'] = dateTrip.toString().substring(0, 10);
                    trip['createatMiliShort'] = dateTrip.millisecondsSinceEpoch;
                    trip['calification'] = score;
                    trip['description'] = description.text;
                    await FirebaseFirestore.instance.collection("trips").doc(widget.trip.id).set(trip);
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => ViajesPage()),
                        (Route<dynamic> route) {
                      return false;
                    });
                  },
                  child: Text(
                    "Confirmar",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'GoldplayRegular',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      padding: EdgeInsets.symmetric(
                        vertical: 20,
                      ),
                      backgroundColor: prs.colorMorado,
                      foregroundColor: prs.colorMorado),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancelar",
                    style: TextStyle(
                      color: prs.colorMorado,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'GoldplayRegular',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      side: BorderSide(color: prs.colorMorado, width: 1),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: Colors.transparent,
                      foregroundColor: prs.colorMorado),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

double score = 1;
onRatingChanged(double value) {
  score = value;
}

Widget _estrellasTaxis() {
  return utils.estrellasTaxis((2 / 2), onRatingChanged);
}