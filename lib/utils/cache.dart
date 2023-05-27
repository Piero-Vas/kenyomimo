import 'package:flutter/material.dart';

// import 'package:flutter_advanced_networkimage/provider.dart';

import '../sistema.dart';
import '../utils/personalizacion.dart' as prs;

String img(String img) {
  if (img == null) return 'S/N';
  return (img.contains('https://', 0)
      ? img
      : img.length > 10
          ? ('${Sistema.storage}$img?alt=media')
          : '');
}

Widget acronicmo(String acronimo,
    {double width,
    double height,
    double fontSize: 30.0,
    Color color: Colors.white,
    int days: 90,
    int minutes: 0}) {
  return Container(
    color: color,
    width: width,
    height: height,
    child: Center(
      child: Text(
        acronimo,
        style: TextStyle(fontSize: fontSize, color: prs.colorTextDescription, fontFamily: 'GoldplayRegular', fontWeight: FontWeight.bold),
      ),
    ),
  );
}

Widget fadeImage(String img,
    {double width,
    double height,
    String acronimo: 'S/N',
    double fontSize: 30.0,
    Color color: Colors.white,
    int days: 90,
    int minutes: 0,
    bool despacho: false
    }) {

    
  if (img != null && img.contains('assets/', 0)){
     despacho ? print(img) : '';
    return FadeInImage(
        width: width,
        height: height,
        image: AssetImage(img),
        placeholder: AssetImage(img),
        fit: BoxFit.fill);
  }
  if (img == null || img.toString().length <= 10 && acronimo == 'S/N'){
       despacho ? print(img) : '';
    return FadeInImage(
        width: width,
        height: height,
        image: AssetImage('assets/noimage.png'),
        placeholder: AssetImage('assets/noimage.png'),
        fit: BoxFit.fill);
  }
  if (img == null || img.toString().length <= 10){
       despacho ? print(img) : '';
    return Container(
        color: color,
        width: width,
        height: height,
        child: Center(
          child: Text(
            acronimo,
            style:
                TextStyle(fontSize: fontSize, color: prs.colorTextDescription),
          ),
        ));
  }
  despacho ? print(img) : '';
  return Container(
    width: width,
    height: height,
    child: FadeInImage(
      width: width,
      height: height,
      imageErrorBuilder:
          (BuildContext context, Object exception, StackTrace stackTrace) {
        return Container(child: Image.asset('assets/no-image.png'));
      },
      placeholder: AssetImage('assets/no-image.png'),
      image: NetworkImage(img),
      fit: BoxFit.fill,
    ),
  );
}

ImageProvider image(String img) {
  if (img == null || img.toString().length <= 10)
    return AssetImage('assets/screen/direcciones.png');
  return FadeInImage(
    imageErrorBuilder:
        (BuildContext context, Object exception, StackTrace stackTrace) {
      return Container(child: Image.asset('assets/no-image.png'));
    },
    placeholder: AssetImage('assets/no-image.png'),
    image: NetworkImage(img),
    fit: BoxFit.cover,
  ).image;
}
