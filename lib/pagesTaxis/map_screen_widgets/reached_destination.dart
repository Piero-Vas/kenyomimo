import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mimo/model/map_action.dart';
import 'package:mimo/Core/ProviderModels/MapModel.dart';

class ReachedDestination extends StatelessWidget {
  const ReachedDestination({Key key, this.mapProvider}) : super(key: key);

  final MapModel mapProvider;

  @override
  Widget build(BuildContext context) {
    final MapModel mapProvider = Provider.of<MapModel>(
      context,
      listen: false,
    );

    return Visibility(
      visible: mapProvider.mapAction == MapAction.reachedDestination,
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
                  'Destino alcanzado',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              mapProvider.ongoingTrip!=null && mapProvider.ongoingTrip.typeService=="Envio" ? 
              Center(
                child: Text(
                  'El conductor esta entregando el producto',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ) :    
              Center(
                child: Text(
                  'El conductor está esperando recibir efectivo',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (mapProvider.cost != null)
                Center(
                  child: Chip(
                    label: Text('S/.${mapProvider.cost.toStringAsFixed(2)}'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}