import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../bloc/foto_bloc.dart';
import '../../model/cliente_model.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cliente_provider.dart';
import '../../utils/button.dart' as btn;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../utils/validar.dart' as val;
import 'package:http/http.dart' as http;

class RecuperarPassPage extends StatefulWidget {
  RecuperarPassPage({Key key}) : super(key: key);

  _RecuperarPassPageState createState() => _RecuperarPassPageState();
}

class _RecuperarPassPageState extends State<RecuperarPassPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PreferenciasUsuario prefs = PreferenciasUsuario();

  ClienteModel _cliente = ClienteModel();

  bool _saving = false;
  TextEditingController _emailValue = TextEditingController();

  @override
  void initState() {
    _cliente = prefs.clienteModel;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: utils.leading(context),
        elevation: 0,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Center(
            child: Container(
          child: _body(),
          width: prs.anchoFormulario,
          decoration: BoxDecoration(color: Colors.white),
        )),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(child: SingleChildScrollView(child: _contenido())),
        Container(child: btn.bootonContinuar('Continuar', _continuar))
      ],
    );
  }

  Widget _contenido() {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      padding: EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Column(
              children: [
                prs.titulo('RECUPERAR CONTRASEÑA'),
                prs.subTitulo('Ingresa tu correo'),
                SizedBox(
                  height: 20,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      prs.labels('Correo'),
                      SizedBox(
                        height: 10,
                      ),
                      _crearCorreo(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

_continuar() async {
    QuerySnapshot documentSnapshot = await FirebaseFirestore.instance.collection('client').where("correo",isEqualTo: _emailValue.text.trim()).limit(1).get();
    if (documentSnapshot.size > 0){
      final _random = Random();
      final _availableChars ='AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
      final randomString = List.generate(8,(index) =>_availableChars[_random.nextInt(_availableChars.length)]).join();
      prefs.claveTemp = randomString;
      prefs.correoTemp = _emailValue.text.trim();
      sendEmail(_emailValue.text.trim(), randomString);
      Navigator.pushNamed(context, 'revisar_correo');
    }
    else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.0),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/png/cancelar.png',
                  height: 50.0,
                ),
                const SizedBox(
                  height: 12.0,
                ),
                Row(
                  children: [
                    Text(
                      "El correo no es valido",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.normal,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5090FE),
                ),
                child: const Text("Aceptar"),
              )
            ],
          );
        },
      );
    }
  }
  
  Widget _crearCorreo() {
    return TextFormField(
        controller: _emailValue,
        keyboardType: TextInputType.emailAddress,
        maxLength: 60,
        /* initialValue: _cliente.correo, */
        decoration: prs.decoration('Ingresar Correo', null),
        onChanged: (value) => _cliente.correo = value.trim(),
        validator: val.validarCorreo);
  }
}

Future sendEmail(String email, String pass) async {
  const subject = "Mimo - Recuperación de Contraseña";
  // var message = pass;
  const serviceId = "service_bikf2f6";
  const templateId = "template_a985zwa";
  const userId = "Th7r0vyu8KQbDJyKP";

  final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
  final response = await http.post(url,
      headers: {
        'origin': "http://localhost",
        'Content-Type': 'application/json'
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'user_subject': subject,
          'to_email': email,
          'mensaje': pass
        }
      }));
}