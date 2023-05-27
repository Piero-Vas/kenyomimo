import 'package:mimo/Core/Enums/Enums.dart';
import 'package:mimo/Core/Models/CarTypeMenu.dart';
import 'package:mimo/Core/Models/Drivers.dart';
import 'package:mimo/Core/Models/UserDetails.dart';
import 'package:mimo/Core/Models/UserPlaces.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DemoData {
  static List<Driver> nearbyDrivers = [
    Driver(
        "First",
        "https://cbsnews2.cbsistatic.com/hub/i/r/2017/12/20/205852a8-1105-48b5-98d4-d9ec18a577e0/thumbnail/1200x630/8cb0b627b158660d1e0a681a76fb012c/uber-europe-uk-851372958.jpg",
        4,
        "FirstId",
        CarDetail(
            "firstCarId", "firstCarCompany", "firstCarModel", " firstCarName"),
        LatLng(-8.0484787,-78.9989531)),
    Driver(
        "Second",
        "https://cbsnews2.cbsistatic.com/hub/i/r/2017/12/20/205852a8-1105-48b5-98d4-d9ec18a577e0/thumbnail/1200x630/8cb0b627b158660d1e0a681a76fb012c/uber-europe-uk-851372958.jpg",
        3,
        "Second",
        CarDetail("secondCarId", "secondCarCompany", "secondCarModel",
            " secondCarName"),
        LatLng(-8.0784475,-79.0193359)),
    Driver(
        "Third",
        "https://cbsnews2.cbsistatic.com/hub/i/r/2017/12/20/205852a8-1105-48b5-98d4-d9ec18a577e0/thumbnail/1200x630/8cb0b627b158660d1e0a681a76fb012c/uber-europe-uk-851372958.jpg",
        4,
        "ThirdId",
        CarDetail(
            "thirdCarId", "thirdCarCompany", "thirdCarModel", " thridCarName"),
        LatLng(-8.1115668,-79.0432528)),
  ];
  static List<String> previousRides = [
    "dsgffdsgdsagfds",
    "fdsafdsafas",
    "fdsafasffasd"
  ];

  static List<UserPlaces> favPlaces = [
    UserPlaces(
        "India Gate", "India Gate, New Delhi", LatLng(28.612912, 77.227321)),
    UserPlaces(
        "fdsagdsa rewfw", "nfdsbf, New Delhi", LatLng(29.612912, 70.227321)),
    UserPlaces(
        "dsagasdsa", "kldnwkvn, New Delhi", LatLng(22.612912, 70.227321)),
    UserPlaces(
        "dsafagdgg", "wqkjegcq, New Delhi", LatLng(38.612912, 67.227321)),
    UserPlaces(
        "jdskdsaksasaf", "cqucqjuwq, New Delhi", LatLng(28.012912, 77.297321)),
  ];

  static UserDetails currentUserDetails = UserDetails(
      "FDSfdfdsafFtt324sdf",
      "https://i.pinimg.com/originals/61/36/8f/61368f9b0c3b7fcd22a4a1fbd4c28864.jpg",
      "Sahdeep Singh",
      "sahdeepsingh98@gmail.com",
      "0123456789",
      null,
      previousRides,
      favPlaces);
  static List<CarTypeMenu> typesOfCar = [
    CarTypeMenu("images/affordableCarIcon.png", "Affordable Car in Budget",
        RideType.Affordable),
    CarTypeMenu("images/classicCarIcon.png",
        "Classic Car for your daily Commute ", RideType.Classic),
    CarTypeMenu("images/sedanCarIcon.png",
        " Car with extra leg Space and Storage", RideType.Sedan),
    CarTypeMenu("images/suvCarIcon.png",
        " Suv's for travelling with big Family", RideType.Suv),
    CarTypeMenu("images/luxuryCarIcon.png", "Luxury Cars for any occasion",
        RideType.Luxury),
  ];
}
