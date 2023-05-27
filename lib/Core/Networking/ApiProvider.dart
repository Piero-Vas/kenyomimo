import 'package:mimo/Core/Constants/DemoData.dart';
import 'package:mimo/Core/Models/Drivers.dart';

class ApiProvider {
  static List<Driver> getNearbyDrivers() {
    //somehow get the list of nearby drivers
    return DemoData.nearbyDrivers;
  }
}
