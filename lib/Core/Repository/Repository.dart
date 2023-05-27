import 'dart:async';

import 'package:mimo/Core/Enums/Enums.dart';
import 'package:mimo/Core/Models/Drivers.dart';
import 'package:mimo/Core/Models/UserPlaces.dart';
import 'package:mimo/Core/Networking/ApiProvider.dart';

class Repository {
  static Future<AuthStatus> isUserAlreadyAuthenticated() async {
    return AuthStatus.Authenticated;
  }

  static void getNearbyDrivers(
      StreamController<List<Driver>> nearbyDriverStreamController) {
    nearbyDriverStreamController.sink.add(ApiProvider.getNearbyDrivers());
  }

  static void addFavPlacesToDataBase(List<UserPlaces> data) {
    //
  }
}
