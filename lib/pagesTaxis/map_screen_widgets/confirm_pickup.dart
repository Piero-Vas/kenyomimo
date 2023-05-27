import 'package:flutter/material.dart';
import 'package:mimo/model/map_action.dart';
import 'package:mimo/model/trip_model.dart';
import 'package:mimo/Core/ProviderModels/MapModel.dart';

import 'package:mimo/pagesTaxis/services/database_service.dart';

class ConfirmPickup extends StatelessWidget {
  const ConfirmPickup({Key key, this.mapProvider}) : super(key: key);

  final MapModel mapProvider;

  Future<void> _startTrip(BuildContext context) async {
    final DatabaseService dbService = DatabaseService();

    Trip newTrip = Trip(
      pickupAddress: mapProvider.deviceAddress,
      destinationAddress: mapProvider.remoteAddress,
      pickupLatitude: mapProvider.pickupPosition.latitude,
      pickupLongitude: mapProvider.pickupPosition.longitude,
      destinationLatitude: mapProvider.remoteLocation.latitude,
      destinationLongitude: mapProvider.remoteLocation.longitude,
      distance: mapProvider.distance,
      cost: mapProvider.cost,
      passengerId: "",
    );

    String tripId = await dbService.startTrip(newTrip);
    newTrip.id = tripId;
    mapProvider.confirmTrip(newTrip);

    mapProvider.triggerAutoCancelTrip(
      tripDeleteHandler: () {
        newTrip.canceled = true;
        dbService.updateTrip(newTrip);
      },
      snackbarHandler: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ningun conductor acepto el viaje.'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: mapProvider.mapAction == MapAction.tripSelected &&
          mapProvider.remoteMarker != null,
      child: Positioned(
        bottom: 15,
        left: 15,
        right: 15,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              mapProvider.remoteLocation != null
                  ? Column(
                      children: [
                        if (mapProvider.remoteAddress != null)
                          Text(
                            mapProvider.remoteAddress,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 5),
                        if (mapProvider.distance != null)
                          Text(
                            'Distancia: ${mapProvider.distance.toStringAsFixed(2)} km',
                          ),
                        if (mapProvider.cost != null)
                          Text(
                            'El viaje costara: S/.${mapProvider.cost.toStringAsFixed(2)}',
                          ),
                        if (mapProvider.timeTrip != null)
                          Text(
                            'El tiempo es: ${mapProvider.timeTrip} minutos',
                          ),
                        const SizedBox(height: 5),
                      ],
                    )
                  : const Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: Center(
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: () => _startTrip(context),
                  child: const Text('CONFIRMAR VIAJE'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: () => mapProvider.cancelTrip(),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
