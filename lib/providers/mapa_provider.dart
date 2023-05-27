import 'dart:convert';

import 'package:http/http.dart' as http;

import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class MapaProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlLugaresCercanos1 = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=';
  final String _urlLugaresCercanos2 = '&radius=90000&strictbounds&key=AIzaSyCoizTsNmZ2p8_PyrNMLUK5On3Nwsn3NTk&components=country:pe';
  final String _urlUrl = 'mapa/localizar-url';
  final String _urlLocalizar = 'https://maps.googleapis.com/maps/api/geocode/json?place_id=';
  final String _urlTrazar = 'mapa/trazar';

  trazar(dynamic ltO, dynamic lgO, dynamic ltD, dynamic lgD, String waypoints,
      Function response) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlTrazar),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'auth': _prefs.auth,
          'ltO': ltO.toString(),
          'lgO': lgO.toString(),
          'ltD': ltD.toString(),
          'lgD': lgD.toString(),
          'waypoints': waypoints,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    return response(decodedResp);
  }

  Future<List> lugaresCercanos(double lt, double lg, dynamic criterio) async {
    if (criterio.length <= 2) return [];
    try {
      final resp = await http.get(Uri.parse(_urlLugaresCercanos1+criterio+"&location="+lt.toStringAsFixed(5).toString()+','+lg.toStringAsFixed(5).toString()+_urlLugaresCercanos2 ));
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      List suggestionsService = decodedResp['predictions'];
      List suggestions = [];
      suggestionsService.forEach((Mapelement) {
        Map temp = {};
        temp['place_id'] = Mapelement['place_id']; 
        temp['main'] = Mapelement['structured_formatting']['main_text']; 
        temp['secondary'] = Mapelement['structured_formatting']['secondary_text']; 
        temp['types'] = Mapelement['types'];
        suggestions.add(temp);
      });
      return suggestions;
    } catch (err) {
      
    }
    return [];
  }

  url(String url, Function callback) async {
    try {
      final resp = await http.post(Uri.parse(Sistema.dominio + _urlUrl),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'url': url,
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1)
        return callback(1, decodedResp['lt'], decodedResp['lg']);
    } catch (err) {
      
    }
    return callback(-1, 0.0, 0.0);
  }

  Future localizar(dynamic placeId, String main, String secondary) async {
    final resp = await http.get(Uri.parse(_urlLocalizar+placeId.toString()+"&key=AIzaSyCoizTsNmZ2p8_PyrNMLUK5On3Nwsn3NTk"));
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    return decodedResp["results"][0]["geometry"]["location"];
  }
}