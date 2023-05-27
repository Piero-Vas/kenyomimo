import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import '../../model/cliente_model.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cliente_provider.dart';
import '../../utils/button.dart' as btn;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/redes_sociales.dart' as rs;
import '../../utils/utils.dart' as utils;

class Login2Page extends StatefulWidget {
  Login2Page({Key key}) : super(key: key);

  _Login2PageState createState() => _Login2PageState();
}

class _Login2PageState extends State<Login2Page> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ClienteProvider _clienteProvider = ClienteProvider();
  final prefs = PreferenciasUsuario();
  String smn = '';

  final Future<bool> _isAvailableFuture = TheAppleSignIn.isAvailable();

  ClienteModel cliente = ClienteModel();
  bool _saving = false;

  GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _escucharLoginGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: ModalProgressHUD(
          inAsyncCall: _saving,
          child: SingleChildScrollView(
            child: Center(
                child: Container(
                    color: Colors.white,
                    child: _contenido(),
                    width: double.infinity)),
          ),
        ));
  }

  Column _contenido() {
    return Column(
      children: <Widget>[
        SizedBox(height: 5.0),
        Container(
          child: Stack(
            children: [
              Column(
                children: <Widget>[
                  SizedBox(
                      width: double.infinity,
                      child: Image(
                          image: AssetImage('assets/png/login.png'),
                          fit: BoxFit.cover,
                          width: double.infinity)),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                    child: Column(
                      children: [
                        SizedBox(height: 20.0),
                        Center(
                          child: Text('Continúa con:',
                              style: TextStyle(
                                  color: prs.colorTextTitle,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600)),
                        ),
                        SizedBox(height: 20.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FutureBuilder<bool>(
                              future: _isAvailableFuture,
                              builder: (context, isAvailableSnapshot) {
                                if (!isAvailableSnapshot.hasData) {
                                  return Container(
                                    width: 0.0,
                                  );
                                }
                                return isAvailableSnapshot.data
                                    ? rs.buttonApple('Continuar con Apple',
                                        prs.iconoApple, _autenticarApple)
                                    : Container(
                                        width: 0.0,
                                      );
                              },
                            ),
                            rs.buttonFacebook('Continuar con Facebook',
                                prs.iconoFacebook, _autenticarFacebook),
                            SizedBox(width: 20.0),
                            rs.buttonGoogle('Continuar con Google',
                                prs.iconoGoogle, _iniciarSessionGoogle),
                          ],
                        ),
                        SizedBox(height: 20.0),
                        btn.bootonContinuar('Número de teléfono', _telefono),
                        SizedBox(height: 10.0),
                        btn.booton('Otro metodo de Ingreso', _email),
                      ],
                    ),
                  ),
                ],
              ),
              // Container(
              //   padding: EdgeInsets.all(20),
              //   alignment: Alignment.topRight,
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.end,
              //     mainAxisAlignment: MainAxisAlignment.end,
              //     children: [
              //       Visibility(
              //         // visible: Sistema.isIOS,
              //         child: TextButton(
              //           child: Column(
              //             children: <Widget>[
              //               Text('Omitir',
              //                   style: TextStyle(
              //                       color: prs.colorBotones,
              //                       fontWeight: FontWeight.w700)),
              //             ],
              //           ),
              //           onPressed: () async {
              //             _saving = true;
              //             if (mounted) setState(() {});
              //             await rs.autlogin(context);
              //             _saving = false;
              //             if (mounted) setState(() {});
              //           },
              //         ),
              //       ),
              //     ],
              //   ),
              // )
            ],
          ),
        ),
      ],
    );
  }

  String codigoPais = '+51';

  _telefono() {
    prefs.skipStep = "0";
    Navigator.pushNamed(context, 'ingresa_telf');
  }

  _email() {
    prefs.skipStep = "0";
    Navigator.pushNamed(context, 'email');
  }

  void _autenticarFacebook() async {
    _saving = true;
    if (mounted) setState(() {});
    await rs.autenticarFacebook(context, codigoPais, smn,
        (login, ClienteModel clienteModel) {
      if (login == null) {
        prefs.idFacebook = clienteModel.idCliente;
        clienteModel.idCliente = null;
        prefs.clienteModel = clienteModel;
        utils.mostrarSnackBar(
            context, "El correo no esta registrado, por favor registrate",
            milliseconds: 2000000);
        Navigator.pushNamed(context, "email2");
      }
      _saving = false;
      if (mounted) if (mounted) setState(() {});
    });
  }

  void _autenticarApple() async {
    _saving = true;
    if (mounted) setState(() {});
    bool respuesta = await rs.autenticarApple(context, codigoPais, smn);
    _saving = false;
    if (mounted) if (mounted) setState(() {});
    if (!respuesta)
      _mostrarSnackBar('Necesitamos información del correo electrónico.');
  }

  void _autenticarGoogle(
      context, correo, img, idGoogle, nombres, apellidos) async {
    _saving = true;
    if (mounted) setState(() {});
    await rs.autenticarGoogle(context, _googleSignIn, codigoPais, smn, correo,
        img, idGoogle, nombres, apellidos);
    _saving = false;
    if (mounted) if (mounted) setState(() {});
  }

  Future<void> _iniciarSessionGoogle() async {
    _saving = true;
    if (mounted) setState(() {});
    try {
      await _googleSignIn.signIn();
      
    } catch (err) {
      print('login_page error: $err');
    } finally {
      _saving = false;
      if (mounted) if (mounted) setState(() {});
    }
  }

  _escucharLoginGoogle() {
    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount currentUser) async {
      if (currentUser != null) {
        var nombres = currentUser.displayName.split(' ');
        String nombre = '';
        if (nombres.length > 0) {
          nombre = nombres[0];
        }
        String apellido = '';
        if (nombres.length > 1) {
          for (var i = 1; i < nombres.length; i++) {
            apellido += nombres[i] + ' ';
          }
        }
        QuerySnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection('client')
            .where("correo", isEqualTo: currentUser.email)
            .limit(1)
            .get();
        if (documentSnapshot.size < 1) {
          utils.mostrarSnackBar(
              context, "El correo no esta registrado, por favor registrate",
              milliseconds: 2000000);
          ClienteModel clienteModel = ClienteModel();
          clienteModel.apellidos = apellido;
          clienteModel.nombres = nombre;
          clienteModel.img = currentUser.photoUrl;
          clienteModel.correo = currentUser.email;
          prefs.idGoogle = currentUser.id;
          prefs.clienteModel = clienteModel;
          Navigator.pushNamed(context, "email2");
        } else {
          _autenticarGoogle(context, currentUser.email, currentUser.photoUrl,
              currentUser.id, nombre, apellido);
        }
      }
    });
  }

  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensaje),
      action: SnackBarAction(
        label: 'Recuperar cuenta',
        onPressed: () => Navigator.pushNamed(context, 'contrasenia'),
      ),
    ));
  }
}
