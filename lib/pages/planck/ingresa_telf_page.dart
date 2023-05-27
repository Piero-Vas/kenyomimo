import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../model/cliente_model.dart';
import '../../preference/shared_preferences.dart';
import '../../utils/button.dart' as btn;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;

class IngresaTelfPage extends StatefulWidget {
  IngresaTelfPage({Key key}) : super(key: key);

  _IngresaTelfPageState createState() => _IngresaTelfPageState();
}

class _IngresaTelfPageState extends State<IngresaTelfPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  /*final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); */

  final PreferenciasUsuario prefs = PreferenciasUsuario();
  FirebaseAuth auth = FirebaseAuth.instance;
  ClienteModel _cliente = ClienteModel();

  bool _saving = false;

  @override
  void initState() {
    if(prefs.skipStep == '0') prefs.clienteModel = null;
    _cliente = prefs.clienteModel;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: _scaffoldKey,
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
                prs.titulo('INGRESA TU NÚMERO'),
                prs.subTitulo(
                    'Te mandaremos un código de confirmación por sms.'),
                SizedBox(
                  height: 20,
                ),
                Form(
                  //key: _formKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20.0),
                      prs.labels('Número de teléfono'),
                      SizedBox(
                        height: 10,
                      ),
                      _crearCelular(),
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
    _saving = true;
    if (mounted) setState(() {});
    if(_cliente.celular.toString().isEmpty||_cliente.celular.toString().length<12|| _cliente.celular[3] != '9'){
      utils.newAlert(context, 'Fallido', 'Por favor valida el numero ingresado','Failure');
      _saving = false;
      if (mounted) setState(() {});
    }
    else {
      _saving = false;
      await _verifyPhoneNumber();
      Future.delayed(Duration(seconds: 2)).then((value) async => await Navigator.pushNamed(context, 'verifica_telf'));
    }
  }

  Widget _crearCelular() {
    return Row(
      children: [
        SizedBox(width: 5.0),
        Expanded(
          child: utils.crearCelular(prefs.simCountryCode, _onChangedCelular,
              celular: _cliente.celular.toString()),
        )
      ],
    );
  }

  _onChangedCelular(phone) {
    
    _cliente.celular = phone.toString();
  }

  _verifyPhoneNumber() async {
    try {
      int resendTokenId;
      prefs.celular = _cliente.celular;
      await auth.verifyPhoneNumber(
          phoneNumber: _cliente.celular,
          timeout: const Duration(seconds: 5),
          verificationCompleted: (PhoneAuthCredential credential) async {
            // await FirebaseAuth.instance.signInWithCredential(credential);
          },
          forceResendingToken: resendTokenId,
          verificationFailed: (FirebaseAuthException exception) {
            
          },
          codeSent: (verificationId, forceResendingToken) {
            prefs.verificationIdReceived = verificationId;
            resendTokenId = forceResendingToken;
            setState(() {});
          },
          codeAutoRetrievalTimeout: (verificationId) {});
    } catch (e) {
      print("Error al verificar el numero");
    }
  }
}