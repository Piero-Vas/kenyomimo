import 'package:flutter/material.dart';

import 'package:mimo/model/map_action.dart';
import 'package:mimo/Core/ProviderModels/MapModel.dart';

class TripStarted extends StatelessWidget {
  const TripStarted({Key key, this.mapProvider}) : super(key: key);

  final MapModel mapProvider;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: mapProvider.mapAction == MapAction.tripStarted,
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
              const Center(
                child: Text(
                  'El viaje ha empezado',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              if (mapProvider.remoteAddress != null)
                Column(
                  children: [
                    _buildInfoText(
                      'En dirección a: ',
                      mapProvider.remoteAddress,
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
              // if (mapProvider.distance != null)
              //   _buildInfoText(
              //     'Distancia: ',
              //     'Distancia: '+mapProvider.distance.toString().split(".")[0]
              //   +"."+(mapProvider.distance.toString().contains(".") 
              //     ? mapProvider.distance.toString().split(".")[1].substring(0,2)
              //     :"0")+" km" ?? "0.0 km",
              //   )
              // else
              //   _buildInfoText(
              //     'Distancia: ',
              //     '0.0 km',
              //   ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText(String title, String info) {
    return RichText(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: info,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}