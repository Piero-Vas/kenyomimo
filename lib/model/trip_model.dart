class Trip {
  String id;
  String passengerId;
  String passengerName;
  int passengerTrips;
  String passengerPhone;
  String driverColor;
  String driverId;
  String timeTrip;
  String pickupAddress;
  String destinationAddress;
  double pickupLatitude;
  double pickupLongitude;
  double destinationLatitude;
  double destinationLongitude;
  double distance;
  double cost;
  double price;
  bool accepted;
  bool started;
  bool canceled;
  bool arrived;
  bool reachedDestination;
  bool tripCompleted;
  String createat;
  int createatMili;
  int typePayment;
  String passengerImg;
  int paymentStatus;
  bool wasRated;  
  String driverImg;
  String driverName;
  String driverLicensePlate;
  String driverTradeMark;
  String driverModel;
  String driverCalification;
  String passengerCard;
  String chargeId;
  String typeService;
  String passengerShippingDetail;
  String typeVehicle;

  Trip({
    this.id,
    this.passengerId,
    this.driverId,
    this.timeTrip,
    this.pickupAddress,
    this.destinationAddress,
    this.passengerPhone,
    this.driverColor,
    this.pickupLatitude,
    this.pickupLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
    this.price,
    this.distance,
    this.cost,
    this.accepted = false,
    this.started,
    this.canceled = false,
    this.arrived,
    this.reachedDestination,
    this.tripCompleted,
    this.createat,
    this.createatMili,
    this.typePayment,
    this.passengerName,
    this.passengerTrips,
    this.passengerImg,
    this.paymentStatus,
    this.passengerCard,
    this.wasRated = false,
    this.driverImg,
    this.driverName,
    this.driverLicensePlate,
    this.driverTradeMark,
    this.driverModel,
    this.driverCalification,
    this.chargeId,
    this.typeService = "Taxi",
    this.typeVehicle = "",
    this.passengerShippingDetail = "",
  });

  factory Trip.fromJson(Map<String, dynamic> data) => Trip(
        id: data['id'],
        typeVehicle: data['typeVehicle'],
        passengerImg: data['passengerImg'],
        driverCalification: data['driverCalification'],
        passengerCard: data['passengerCard'],
        passengerPhone: data['passengerPhone'],
        driverColor:  data['driverColor'],
        price: data['price'],
        timeTrip: data['timeTrip'],
        passengerName: data['passengerName'],
        passengerTrips: data['passengerTrips'],
        passengerId: data['passengerId'],
        passengerShippingDetail: data['passengerShippingDetail'],
        typeService: data['typeService'],
        driverId: data['driverId'],
        pickupAddress: data['pickupAddress'],
        destinationAddress: data['destinationAddress'],
        pickupLatitude: data['pickupLatitude'],
        pickupLongitude: data['pickupLongitude'],
        destinationLatitude: data['destinationLatitude'],
        destinationLongitude: data['destinationLongitude'],
        distance: data['distance'],
        cost: data['cost'],
        accepted: data['accepted'],
        started: data['started'],
        canceled: data['canceled'],
        arrived: data['arrived'],
        reachedDestination: data['reachedDestination'],
        tripCompleted: data['tripCompleted'],
        createat: data['createat'],
        createatMili: data['createatMili'],
        typePayment: data['typePayment'],
        paymentStatus: data['paymentStatus'],
        wasRated: data['wasRated'],
        driverImg: data['driverImg'],
        driverName: data['driverName'],
        driverLicensePlate: data['driverLicensePlate'],
        driverTradeMark: data['driverTradeMark'],
        driverModel: data['driverModel'],
        chargeId: data['chargeId'],
      );

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {};

    void addNonNull(String key, dynamic value) {
      if (value != null) {
        data[key] = value;
      }
    }
    
    addNonNull('id', id);
    addNonNull('passengerPhone', passengerPhone);
    addNonNull('driverColor', driverColor);
    addNonNull('typeVehicle', typeVehicle);
    addNonNull('typeService', typeService);
    addNonNull('passengerShippingDetail', passengerShippingDetail);
    addNonNull('chargeId', chargeId);
    addNonNull('driverCalification', driverCalification);
    addNonNull('wasRated', wasRated);
    addNonNull('passengerImg', passengerImg);
    addNonNull('passengerName', passengerName);
    addNonNull('passengerTrips', passengerTrips);
    addNonNull('passengerCard', passengerCard);
    addNonNull('price', price);
    addNonNull('timeTrip', timeTrip);
    addNonNull('passengerId', passengerId);
    addNonNull('driverId', driverId);
    addNonNull('pickupAddress', pickupAddress);
    addNonNull('destinationAddress', destinationAddress);
    addNonNull('pickupLatitude', pickupLatitude);
    addNonNull('pickupLongitude', pickupLongitude);
    addNonNull('destinationLatitude', destinationLatitude);
    addNonNull('destinationLongitude', destinationLongitude);
    addNonNull('distance', distance);
    addNonNull('cost', cost);
    addNonNull('accepted', accepted);
    addNonNull('started', started);
    addNonNull('canceled', canceled);
    addNonNull('arrived', arrived);
    addNonNull('reachedDestination', reachedDestination);
    addNonNull('tripCompleted', tripCompleted);
    addNonNull('createat', createat);
    addNonNull('createatMili', createatMili);
    addNonNull('typePayment', typePayment);
    addNonNull('paymentStatus', paymentStatus);
    addNonNull('driverImg', driverImg);
    addNonNull('driverName', driverName);
    addNonNull('driverLicensePlate', driverLicensePlate);
    addNonNull('driverTradeMark', driverTradeMark);
    addNonNull('driverModel', driverModel);
    return data;
 }
}