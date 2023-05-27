import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:mimo/model/trip_model.dart';
import 'package:mimo/model/user_model.dart' as user;
import 'package:mimo/preference/shared_preferences.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  PreferenciasUsuario _prefs = PreferenciasUsuario();
  Future<bool> checkIfDriver(String email) async {
    Map<String, dynamic> data =
        (await _firestore.collection('registeredUsers').doc('drivers').get())
            .data();

    if (kDebugMode) {
      print(data);
    }

    if (data['registeredEmails'] == null) {
      return false;
    } else if ((data['registeredEmails'] as List).contains(email)) {
      return true;
    }

    return false;
  }

  Future<void> storeUser(user.User user) async {
    await _firestore.collection('passengers').doc(user.id).set(user.toMap());
    _firestore.collection('registeredUsers').doc('passengers').set({
      'registeredEmails': FieldValue.arrayUnion([user.email]),
    });
  }

  Future<int> getTotalTripsByPassenger(String id) async {
    int totalTrips = 0;
    await _firestore.collection("trips").where("passengerId",isEqualTo: id).where("accepted",isEqualTo: true).get().then(
      (value) => {
        totalTrips = value.size
      }
    );
    return totalTrips;
  }

  Stream<user.User> getDriver$(String driverId) {
    return _firestore.collection('drivers').doc(driverId).snapshots().map(
          (DocumentSnapshot snapshot) => user.User.fromJson(
            snapshot.data() as Map<String, dynamic>,
          ),
        );
  }

  Future<String> startTrip(Trip trip) async {
    
    String docId = _firestore.collection('trips')
    .doc(DateTime.now().millisecondsSinceEpoch.toString()+'_'+_prefs.clienteModel.idCliente.toString()).id;
    
    trip.id = docId;
    await _firestore.collection('trips').doc(docId).set(trip.toMap());

    return trip.id;
  }

  Future<void> updateTrip(Trip trip) async {
    await _firestore.collection('trips').doc(trip.id).update(trip.toMap());
  }

  Future<List<Trip>> getCompletedTrips() async {
    return (await _firestore
            .collection('trips')
            .where(
              'passengerId',
              isEqualTo: FirebaseAuth.instance.currentUser.uid,
            )
            .where('tripCompleted', isEqualTo: true)
            .get())
        .docs
        .map(
          (QueryDocumentSnapshot snapshot) =>
              Trip.fromJson(snapshot.data() as Map<String, dynamic>),
        )
        .toList();
  }

  Stream<Trip> getTrip$(Trip trip) {
    return _firestore.collection('trips').doc(trip.id).snapshots().map(
          (DocumentSnapshot snapshot) =>
              Trip.fromJson(snapshot.data() as Map<String, dynamic>),
        );
  }
}
