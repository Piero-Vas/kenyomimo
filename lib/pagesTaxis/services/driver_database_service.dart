import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mimo/model/trip_model.dart';
import 'package:mimo/preference/shared_preferences.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; 

//AQUI VA A IR LOS CONDUCTORES
  void updateUser(Map<String, dynamic> data) {
    _firestore
        .collection('drivers')
        .doc(data['id'])
        .set(data);
  }

  Stream<List<Trip>> getTrips() {
    final _prefs = PreferenciasUsuario();
    String id = _prefs.clienteModel.idCliente;
    String typeVehicle = _prefs.clienteModel.typeVehicle;
    
    return _firestore
        .collection('trips')
        .where('canceled', isEqualTo: false)
        .where('accepted', isEqualTo: false)
        .where('typeVehicle', isEqualTo: typeVehicle)
        .snapshots()
        .map((QuerySnapshot snapshot) => snapshot.docs
          .where((QueryDocumentSnapshot element) {
            Map trip = element.data() as Map;
            return trip['passengerId']==id ? false : true;
            })
          .map((QueryDocumentSnapshot doc) => Trip.fromJson(doc.data() as Map<String, dynamic>))
          .toList()
        );
  }

  Future<void> updateTrip(Trip trip) async {
    await _firestore.collection('trips').doc(trip.id).update(trip.toMap());
  }
}