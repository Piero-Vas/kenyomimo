import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mimo/model/driver_map_action.dart';
import 'package:mimo/model/trip_model.dart';
import 'package:mimo/Core/ProviderModels/map_provider.dart';
import 'package:mimo/pagesTaxis/services/driver_database_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/personalizacion.dart' as prs;

class CollectCash extends StatelessWidget {
  const CollectCash({Key key}) : super(key: key);

  void _collectCash(
    BuildContext context,
    Trip ongoingTrip,
    MapProvider mapProvider,
  ) {
    final DatabaseService dbService = DatabaseService();
    ongoingTrip.tripCompleted = true;
    dbService.updateTrip(ongoingTrip);
    mapProvider.completeTrip();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Viaje completado')),
    );
  }
  _llamar(Trip ongoingTrip) async {
    
    String _call = 'tel:'+ ongoingTrip.passengerPhone.toString();
    final Uri _url = Uri.parse(_call);
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication))
      throw 'Could not launch $_url';
  }

  @override
  Widget build(BuildContext context) {
    final MapProvider mapProvider = Provider.of<MapProvider>(
      context,
      listen: false,
    );
    Trip ongoingTrip = mapProvider.ongoingTrip ?? Trip();

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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Destino alcanzado',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  RawMaterialButton(
                    onPressed: (){
                       _llamar(ongoingTrip);
                    },
                    child: prs.iconoLlamar,
                    shape: CircleBorder(),
                    fillColor: prs.colorButtonBackground,
                  )
                  // ElevatedButton(onPressed: _llamar, child: Text("Llamar"))
                ],
              ),
              SizedBox(height: 20),
              if (ongoingTrip.cost != null)
                Center(
                  child: Text(
                    '\S./${ongoingTrip.cost.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 5),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                onPressed: () => _collectCash(
                  context,
                  ongoingTrip,
                  mapProvider,
                ),
                label:
                    ongoingTrip.typeService!=null && ongoingTrip.typePayment=="Envio" ?
                      const Text('Entregar envio')        
                    : ongoingTrip.typePayment!=null ? 
                        ongoingTrip.typePayment>3 
                          ? const Text('Finalizar viaje')
                          : const Text('Realizar cobro')
                      : const Text('Realizar cobro'),
                icon: ongoingTrip.typeService!=null && ongoingTrip.typePayment=="Envio" ?
                      const Icon(Icons.wallet_giftcard_outlined)
                  : ongoingTrip.typePayment!=null ? 
                        ongoingTrip.typePayment>3 
                        ? const Icon(Icons.car_crash_sharp)
                        : const Icon(Icons.payments_outlined)
                      : const Icon(Icons.payments_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}