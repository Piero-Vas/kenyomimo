import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mimo/providers/cliente_provider.dart';
import 'package:mimo/providers/registro_provider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:timer_builder/timer_builder.dart';
import '../../utils/redes_sociales.dart' as rs;
import '../../model/cliente_model.dart';
import '../../preference/shared_preferences.dart';
import '../../utils/button.dart' as btn;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
//Agregado
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

class VerificarTelfPage extends StatefulWidget {
  VerificarTelfPage({Key key}) : super(key: key);
  _VerificarTelfPageState createState() => _VerificarTelfPageState();
}

class _VerificarTelfPageState extends State<VerificarTelfPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PreferenciasUsuario prefs = PreferenciasUsuario();
  final RegistroProvider _registroProvider = RegistroProvider();
  bool _saving = false;
  ClienteModel _cliente = ClienteModel();

  FirebaseAuth auth = FirebaseAuth.instance;
  String _code;
  TextEditingController otpctl = TextEditingController();
  bool view = false;
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
  var tarjetaFormatter = MaskTextInputFormatter(
    mask: '#        #        #        #        #        #', filter: {"#": RegExp(r"[0-9]")});
  Widget _crearNumeroTarjeta(control) {
  return TextFormField(
    // maxLength: 16,
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 18),
    controller: control,
    inputFormatters: [tarjetaFormatter],
    keyboardType: TextInputType.number,
    // autovalidateMode: AutovalidateMode.onUserInteraction,
    decoration: InputDecoration(
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: prs.colorRojo),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: prs.colorRojo),
      ),
      hintText: 'Codigo de Verificación',
      hintStyle: TextStyle(color: Color.fromARGB(151, 0, 0, 0), fontSize: 16),
      
      ),
    onChanged: (pin) {
      _code = pin.replaceAll(RegExp(r' '), '');
      setState(() {
        print("Changed: " + pin.replaceAll(RegExp(r' '), ''));
      });
    },
    // validator: val.validarNombre
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
                prs.titulo('VERIFICA TU NÚMERO'),
                prs.subTitulo('Ingresa el código que recibiste'),
                SizedBox(
                  height: 20,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      // OTPTextField(
                      //   controller: otpctl,
                      //   length: 6,
                      //   width: MediaQuery.of(context).size.width,
                      //   fieldWidth: MediaQuery.of(context).size.width / 8,
                      //   style: TextStyle(fontSize: 17),
                      //   textFieldAlignment: MainAxisAlignment.spaceAround,
                      //   fieldStyle: FieldStyle.underline,
                      //   onChanged: (pin) {
                      //     _code = pin;
                      //     setState(() {
                      //       print("Changed: " + pin);
                      //     });
                      //   },
                      // ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: _crearNumeroTarjeta(otpctl)),
                      SizedBox(height: 20),
                      _timer()
                      /* TextButton(
                          onPressed: () {
                            _verifyPhoneNumber();
                          },
                          child: Text("Reenviar")) */
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

  _verifyPhoneNumber() async {
    prefs.fechaCodigo = DateTime.now().toIso8601String();
    try {
      int resendTokenId;
      await auth.verifyPhoneNumber(
          phoneNumber: _cliente.celular,
          timeout: const Duration(seconds: 5),
          verificationCompleted: (PhoneAuthCredential credential) async {
            //await FirebaseAuth.instance.signInWithCredential(credential);
          },
          forceResendingToken: resendTokenId,
          verificationFailed: (FirebaseAuthException exception) {
            print(exception.message);
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
    setState(() {});
  }
  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensaje),
    ));
  }

  String formatDuration(Duration d) {
    String f(int n) {
      return n.toString().padLeft(2, '0');
    }

    d += Duration(microseconds: 999999);
    return "Solicita un nuevo código en: ${f(d.inMinutes)}:${f(d.inSeconds % 60)}";
  }

  static const int _seconds = 35;

  Widget _timer() {
    DateTime alert = DateTime.parse(prefs.fechaCodigo).add(Duration(seconds: _seconds));

    return TimerBuilder.scheduled([alert], builder: (context) {
      var now = DateTime.now();
      bool _inicioTimer = now.compareTo(alert) >= 0;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            !_inicioTimer
                ? TimerBuilder.periodic(Duration(seconds: 1),
                    alignment: Duration.zero, builder: (context) {
                    // This function will be called every second until the alert time
                    var now = DateTime.now();
                    Duration remaining = alert.difference(now);
                    return Text(
                      formatDuration(remaining),
                      style: TextStyle(fontSize: 17.0,fontFamily: 'GoldplayRegular'),
                    );
                  })
                : TextButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('¡Reenviar!',
                          style: TextStyle(color: Colors.blue.shade900)),
                    ],
                  ),
                  onPressed: () => _verifyPhoneNumber(),
                )
          ],
        ),
      );
    });
  }

  _continuar() async {
    final ClienteProvider _clienteProvider = ClienteProvider();
    
    try{
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: prefs.verificationIdReceived, smsCode: _code);
    await auth.signInWithCredential(credential).then((value)
        async{

            QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("client")
          .where("celular", isEqualTo: _cliente.celular.toString())
          .limit(1)
          .get();
      if (querySnapshot.size > 0) {
         
        _clienteProvider.autenticarTelefono(_cliente.celular.toString(), (estado, clienteModel) {
      if (estado == 0) return _mostrarSnackBar(clienteModel);
      rs.ingresar(context, clienteModel);
    });
      }else{
        if(prefs.skipStep == '1'){
          _cliente.nombres = prefs.clienteModel.nombres;
          _cliente.apellidos = prefs.clienteModel.apellidos;
          _cliente.correo = prefs.clienteModel.correo;
          _cliente.clave = prefs.clave;
          _cliente.cedula = prefs.clienteModel.cedula;
          
          Future.delayed(const Duration(milliseconds: 400), () async {
            
            _formKey.currentState.save();
            _registroProvider.registrar(_cliente, '+51', "",
            (estado, ClienteModel clienteModel) {
            _saving = false;
            if (mounted) setState(() {});
            if (estado == 0) return utils.mostrarSnackBar(context, clienteModel.toString());
            if(estado == 1){
              
            }
            Navigator.pushNamed(context, 'seleccion');
          });
        });
      }else{
        prefs.celular = _cliente.celular;
        prefs.skipStep = '1';
        Navigator.pushNamed(context, 'email2');
      }
      }   
    });
    }catch(e){
      utils.newAlert(context, 'Fallido', 'Por favor validar el codigo ingresado', 'Failure');
    }
  }
}