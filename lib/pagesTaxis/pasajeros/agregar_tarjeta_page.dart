import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../preference/shared_preferences.dart';
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'package:http/http.dart';
import 'package:openpay_bbva/openpay_bbva.dart';

class AgregarTarjetaPage extends StatefulWidget {
  const AgregarTarjetaPage({Key key}) : super(key: key);

  @override
  State<AgregarTarjetaPage> createState() => _AgregarTarjetaPageState();
}

class _AgregarTarjetaPageState extends State<AgregarTarjetaPage> {
  bool _saving = false;
  OpenpayBBVA openpay = OpenpayBBVA(
    // m0qhimwy1aullokkujfg
      "mkq9aic4rs51cybtcdut", // Replace this with your MERCHANT_ID
      "pk_92bef45248c34ce7a41d59ca30ab72c1", // Replace this with your PUBLIC_API_KEY
      productionMode: true, // True if you want production mode on
      opCountry: OpCountry.Peru);

  Future<void> initDeviceSession() async {
    String deviceID;
    try {
      deviceID = await openpay.getDeviceID() ??
          'Error al obtener el ID de sesión del dispositivo';
    } catch (e) {
      rethrow;
    }
    setState(() {
      _deviceID = deviceID;
    });
    
  }

  getCardToken(
      String nombre, String cardId, String mes, String anio, String cvv) async {
    String token;
    try {
      token = await openpay.getCardToken(nombre, cardId, mes, anio, cvv) ??
          'Error al obtener el token de la tarjeta';
    } catch (e) {
      rethrow;
    }
    
    (token);
    return token;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initDeviceSession();
  }
  TextEditingController aliasTarjeta = TextEditingController();
  TextEditingController nombreTarjeta = TextEditingController();
  TextEditingController numeroTarjeta = TextEditingController();
  TextEditingController fechaTarjeta = TextEditingController();
  TextEditingController codigoTarjeta = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Tarjeta',
            style: TextStyle(
                color: prs.colorGrisOscuro,
                fontSize: 17,
                fontFamily: 'GoldplayRegular',
                fontWeight: FontWeight.w800)),
        centerTitle: true,
        elevation: 0,
        leading: _saving ? SizedBox() : utils.leading(context),
      ),
      body: Container(
        height: double.infinity,
        color: Colors.white,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Te cobraremos un monto aleatorio para validar tu tarjeta. Este monto te será devuelto de inmediato.",
                        style: TextStyle(
                          fontFamily: 'GoldplayRegular',
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Text(
                      "Alias",
                      style: TextStyle(
                        fontFamily: 'GoldplayRegular',
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                _crearAlias(aliasTarjeta),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Text(
                      "Nombre completo",
                      style: TextStyle(
                        fontFamily: 'GoldplayRegular',
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                _crearNombres(nombreTarjeta),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Text(
                      "Número de la tarjeta",
                      style: TextStyle(
                        fontFamily: 'GoldplayRegular',
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                _crearNumeroTarjeta(numeroTarjeta),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Text(
                      "Fecha de vencimiento",
                      style: TextStyle(
                        fontFamily: 'GoldplayRegular',
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                _crearFecha(fechaTarjeta),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Text(
                      "Código de seguridad (CVV)",
                      style: TextStyle(
                        fontFamily: 'GoldplayRegular',
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                _crearCVV(codigoTarjeta),
                SizedBox(
                  height: 40,
                ),
                _saving
                    ? CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final _prefs = PreferenciasUsuario();
                            String id = _prefs.clienteModel.idCliente;
                            if (numeroTarjeta.text.length == 19 &&
                                aliasTarjeta.text != "" &&
                                nombreTarjeta.text != "" &&
                                fechaTarjeta.text.length == 5 &&
                                codigoTarjeta.text.length == 3) {
                              setState(() {
                                _saving = true;
                              });
                              String tarjetaEncriptada =
                                  encriptarTexto(numeroTarjeta.text);
                              await FirebaseFirestore.instance
                                  .collection("cards")
                                  .where("tarjetaEncriptada",
                                      isEqualTo: tarjetaEncriptada)
                                  .where("eliminado", isEqualTo: false)
                                  .where("idCliente", isEqualTo: id)
                                  .get()
                                  .then((value) async {
                                if (value.size > 0) {
                                  setState(() {
                                    _saving = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Tarjeta agregada previamente"),
                                          duration: Duration(seconds: 3)));
                                } else {
                                  final _prefs = PreferenciasUsuario();
                                  String id = _prefs.clienteModel.idCliente;
                                  String ultimosdigitos = numeroTarjeta.text
                                      .toString()
                                      .substring(15, 19);
                                  List<String> fechaArray =
                                      fechaTarjeta.text.split("/");
                                  String tarjeta = numeroTarjeta.text
                                      .replaceAll(RegExp(" "), "");
                                  String mes = fechaArray[0];
                                  String anio = fechaArray[1];
                                  String token = await getCardToken(
                                      nombreTarjeta.text,
                                      tarjeta,
                                      mes,
                                      anio,
                                      codigoTarjeta.text);
                                  String cardTemp = await createCard(token);
                                  Map card = jsonDecode(cardTemp) as Map;
                                  String cardId = card['id'];
                                  agregartarjeta(
                                      aliasTarjeta.text.toString(),
                                      nombreTarjeta.text.toString(),
                                      ultimosdigitos.toString(),
                                      id.toString(),
                                      cardId,
                                      tarjetaEncriptada);
                                  setState(() {
                                    _saving = false;
                                  });
                                  Navigator.pop(context);
                                }
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("Datos incorrectos"),
                                      duration: Duration(seconds: 3)));
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Text(
                              "Agregar Tarjeta",
                              style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'GoldplayRegular',
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: prs.colorMorado,
                              foregroundColor: Colors.white,
                              elevation: 1.0,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: prs.colorMorado, //Bordes
                                      width: 1.0,
                                      style: BorderStyle.solid),
                                  borderRadius: BorderRadius.circular(50.0))),
                        ),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

encriptarTexto(tarjetaEncriptada) {
  final key = encrypt.Key.fromLength(32);
  final iv = encrypt.IV.fromLength(8);
  final encrypter = encrypt.Encrypter(encrypt.Salsa20(key));
  final encrypted = encrypter.encrypt(tarjetaEncriptada, iv: iv);
  String textEncrypted1 = encrypted.base64.substring(0, 6);
  String textEncrypted2 = encrypted.base64.substring(7);
  String textEncrypted = utils.generateMd5(textEncrypted2) + textEncrypted1;
  return textEncrypted;
}

String _deviceID = '';
  // String get _merchantBaseUrl => 'https://api.openpay.pe/v1/m0qhimwy1aullokkujfg';
  // final String apiKeyPublic = "pk_20261e9590c24c1995bd82c30959d12b";
  // final String apiKeyPrivate = "sk_da8b8e48791540958a47dae3488abfa9";
String get _merchantBaseUrl =>
    'https://sandbox-api.openpay.pe/v1/mkq9aic4rs51cybtcdut';

/// Your public API Key
final String apiKeyPublic = "pk_92bef45248c34ce7a41d59ca30ab72c1";
final String apiKeyPrivate = "sk_41d63faafb4c413581fbf776030771da";

Future<String> createCard(String tokenTemp) async {
  String basicAuth = 'Basic ' + base64Encode(utf8.encode('$apiKeyPrivate:'));
  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Authorization': basicAuth,
    'Accept': 'application/json',
  };
  String body = """{
      "token_id": "$tokenTemp",
      "register_frequent": true,
      "device_session_id": "$_deviceID"
    }""";
  Response response = await post(Uri.parse('$_merchantBaseUrl/cards'),
      headers: headers, body: body);
  if (response.statusCode == 201) {
    return response.body;
  } else {
    throw Exception('Error ${response.statusCode}, ${response.body}');
  }
}

var tarjetaFormatter = MaskTextInputFormatter(
    mask: '#### #### #### ####', filter: {"#": RegExp(r"[0-9]")});
var fechaFormatter =
    MaskTextInputFormatter(mask: '##/##', filter: {"#": RegExp(r"[0-9]")});

Widget _crearNombres(control) {
  return TextFormField(
    controller: control,
    maxLength: 90,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    textCapitalization: TextCapitalization.words,
    decoration: prs.decoration('', null),
    // onChanged: (value) => _nombres = value,
    // validator: val.validarNombre
  );
}

Widget _crearAlias(control) {
  return TextFormField(
    controller: control,
    maxLength: 90,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    textCapitalization: TextCapitalization.words,
    decoration: prs.decoration('Tarjeta Principal o Secundaria', null),
    // onChanged: (value) => _nombres = value,
    // validator: val.validarNombre
  );
}

Widget _crearNumeroTarjeta(control) {
  return TextFormField(
    maxLength: 19,
    controller: control,
    inputFormatters: [tarjetaFormatter],
    keyboardType: TextInputType.number,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    textCapitalization: TextCapitalization.words,
    decoration: prs.decoration('', null),
    // onChanged: (value) => _nombres = value,
    // validator: val.validarNombre
  );
}

Widget _crearFecha(control) {
  return TextFormField(
    controller: control,
    keyboardType: TextInputType.number,
    inputFormatters: [fechaFormatter],
    maxLength: 5,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    textCapitalization: TextCapitalization.words,
    decoration: prs.decoration('01/24', null),
    // onChanged: (value) => _nombres = value,
    // validator: val.validarNombre
  );
}

Widget _crearCVV(control) {
  return TextFormField(
    controller: control,
    maxLength: 3,
    keyboardType: TextInputType.number,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    textCapitalization: TextCapitalization.words,
    decoration: prs.decoration('', null),
    // onChanged: (value) => _nombres = value,
    // validator: val.validarNombre
  );
}

void agregartarjeta(
    alias,propietario, tarjeta, idcliente, token, tarjetaEncriptada) async {
  DocumentReference documentReference =
      FirebaseFirestore.instance.collection('cards').doc('--stats--');
  return FirebaseFirestore.instance.runTransaction((transaction) async {
    // Get the document
    DocumentSnapshot snapshot = await transaction.get(documentReference);
    if (!snapshot.exists) {
      throw Exception("Tarjeta no Existe!");
    }
    dynamic cantidadCards = snapshot.get('cantidadTarjetas') + 1;
    DocumentReference documentReferenceCards = FirebaseFirestore.instance
        .collection('cards')
        .doc('card_$cantidadCards');
    transaction.set(documentReference, {
      'cantidadTarjetas': cantidadCards,
    });
    DateTime now = DateTime.now();
    transaction.set(documentReferenceCards, {
      'idCliente': idcliente,
      'propietario': propietario,
      // 'tarjeta': tarjeta,
      'alias':alias,
      'token': token,
      'device': _deviceID,
      'fechacreacion': now.toString(),
      'fechacreacionmili': now.millisecondsSinceEpoch.toString(),
      'tarjetaEncriptada': tarjetaEncriptada,
      'seleccionado': false,
      'eliminado': false
    });
    return cantidadCards;
  }).catchError((error) {
    // Navigator.pop(context);
    print('error');
});
}