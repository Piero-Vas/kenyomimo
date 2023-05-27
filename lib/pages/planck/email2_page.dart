import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mimo/providers/registro_provider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../model/cliente_model.dart';
import '../../preference/shared_preferences.dart';
import '../../utils/button.dart' as btn;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../utils/validar.dart' as val;

class Email2Page extends StatefulWidget {
  Email2Page({Key key}) : super(key: key);
  _Email2PageState createState() => _Email2PageState();
}

class _Email2PageState extends State<Email2Page> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PreferenciasUsuario prefs = PreferenciasUsuario();
  final RegistroProvider _registroProvider = RegistroProvider();
  ClienteModel _cliente = ClienteModel();

  bool _saving = false;
  String _nombres, _apellidos, _cedula, _correo;
  TextEditingController _textControllerPassword;
  TextEditingController _textControllerRePassword;
  bool isChecked = false;
  @override
  void initState() {
    _cliente = prefs.clienteModel;
    _cliente.codigoPais = '+51';
    _nombres = _cliente.nombres;
    _apellidos = _cliente.apellidos;
    _correo = _cliente.correo;
    _textControllerPassword = TextEditingController(text: '');
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
                decoration: BoxDecoration(color: Colors.white))),
      ),
    );
  }

  Widget _body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(child: SingleChildScrollView(child: _contenido())),
        Container(child: btn.bootonContinuar('Continuar', _continuar)),
        SizedBox(
          height: 20,
        )
      ],
    );
  }

  Widget _contenido() {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      padding: EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
      child: Column(
        children: <Widget>[
          prs.titulo('REGISTRO'),
          prs.subTitulo('Tú relájate, nosotros te llevamos lo que necesites'),
          SizedBox(
            height: 20,
          ),
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                prs.labels('Nombres'),
                SizedBox(
                  height: 10,
                ),
                _crearNombres(),
                SizedBox(height: 20.0),
                prs.labels('Apellidos'),
                SizedBox(
                  height: 10,
                ),
                _crearApellidos(),
                SizedBox(height: 20.0),
                prs.labels('DNI, carnet de extranjeria o CPP'),
                SizedBox(
                  height: 10,
                ),
                _crearCedula(),
                SizedBox(height: 20.0),
                prs.labels('Correo'),
                SizedBox(
                  height: 10,
                ),
                _crearCorreo(),
                SizedBox(
                  height: 20,
                ),
                prs.labels('Contraseña'),
                SizedBox(
                  height: 10,
                ),
                _crearPassword(),
                SizedBox(
                  height: 20,
                ),
                prs.labels('Confirmar contraseña'),
                SizedBox(
                  height: 10,
                ),
                _crearRePassword(),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Checkbox(
                        value: isChecked,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: BorderSide(
                                color: prs.colorRojo,
                                width: 1.0,
                                style: BorderStyle.solid)),
                        activeColor: prs.colorRojo,
                        onChanged: (newbool) {
                          setState(() {
                            isChecked = newbool;
                          });
                        }),
                    Expanded(
                        child: Text(
                      'Acepto Término y Condiciones',
                      style: TextStyle(
                          fontFamily: 'GoldplayRegular',
                          fontWeight: FontWeight.w700),
                    ))
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _continuar() async {
    FocusScope.of(context).requestFocus(FocusNode());
    _saving = true;
    if (mounted) setState(() {});
    if(!isChecked){
      _saving = false;
      if (mounted) setState(() {});
      utils.mostrarSnackBar(context, "Aceptar Términos y Condiciones", milliseconds : 3000000);
      return;
    }
    if (_formKey.currentState.validate()) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("client")
          .where("correo", isEqualTo: _correo)
          .limit(1)
          .get();
      if (querySnapshot.size > 0) {
        utils.newAlert(context, 'Fallido', 'El correo ya existe', 'Failure');
        _saving = false;
        if (mounted) setState(() {});
        return;
      }
      querySnapshot = await FirebaseFirestore.instance
          .collection("client")
          .where("cedula", isEqualTo: _cedula)
          .limit(1)
          .get();
      if (querySnapshot.size > 0) {
        utils.newAlert(context, 'Fallido', 'El DNI ya existe', 'Failure');
        _saving = false;
        if (mounted) setState(() {});
        return;
      }
      _cliente.nombres = _nombres;
      _cliente.apellidos = _apellidos;
      _cliente.correo = _correo;
      _cliente.cedula = _cedula;
      _cliente.clave = _textControllerPassword.text;
      if (prefs.skipStep == '1') {
        _cliente.celular = prefs.celular;
        prefs.clienteModel = _cliente;
        Future.delayed(const Duration(milliseconds: 400), () async {
          _formKey.currentState.save();
          _registroProvider.registrar(_cliente, '+51', "",
              (estado, clienteModel) {
            _saving = false;
            if (mounted) setState(() {});
            if (estado == 0)
              return utils.mostrarSnackBar(context, 'Falta rellenar datos (nombres, correo o celular)');
            if (estado == 1) {
              
            }
            Navigator.pushNamed(context, 'seleccion');
          });
        });
      } else {
        prefs.clienteModel = _cliente;
        prefs.clave = _textControllerPassword.text;
        prefs.skipStep = '1';
        Navigator.pushNamed(context, 'ingresa_telf');
      }
    } else {
      utils.newAlert(
          context, 'Fallido', 'Por favor validar todos los campos', 'Failure');
      _saving = false;
    }
  }

  Widget _crearCorreo() {
    return TextFormField(
        initialValue: _cliente.correo,
        keyboardType: TextInputType.emailAddress,
        maxLength: 60,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: prs.decoration('Correo', null),
        onChanged: (value) => _correo = value.trim(),
        validator: val.validarCorreo);
  }

  Widget _crearNombres() {
    return TextFormField(
        maxLength: 90,
        initialValue: _cliente.nombres,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        textCapitalization: TextCapitalization.words,
        decoration: prs.decoration('Nombre', null),
        onChanged: (value) => _nombres = value.trim(),
        validator: val.validarNombre);
  }

  Widget _crearApellidos() {
    return TextFormField(
        maxLength: 90,
        initialValue: _cliente.apellidos,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        textCapitalization: TextCapitalization.words,
        decoration: prs.decoration('Apellidos', null),
        onChanged: (value) => _apellidos = value.trim(),
        validator: val.validarNombre);
  }

  Widget _crearCedula() {
    return TextFormField(
        // maxLength: 8,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        textCapitalization: TextCapitalization.characters,
        // keyboardType: TextInputType.number,
        decoration: prs.decoration('DNI', null),
        onChanged: (value) => _cedula = value.trim(),
        validator: val.validarDni
        );
  }

  bool _isObscurePass = true;
  Widget _crearPassword() {
    return TextFormField(
        controller: _textControllerPassword,
        obscureText: _isObscurePass,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        maxLength: 12,
        decoration: prs.decoration('Contraseña', null,
            suffixIcon: IconButton(
              icon: Icon(_isObscurePass
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              color: prs.colorRojo,
              onPressed: () {
                setState(() {
                  _isObscurePass = !_isObscurePass;
                });
              },
            )),
        validator: val.validarMinimo6);
  }

  bool _isObscureRePass = true;
  Widget _crearRePassword() {
    return TextFormField(
      controller: _textControllerRePassword,
      obscureText: _isObscureRePass,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLength: 12,
      decoration: prs.decoration('Confirmar Contraseña', null,
          suffixIcon: IconButton(
            icon: Icon(_isObscureRePass
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined),
            color: prs.colorRojo,
            onPressed: () {
              setState(() {
                _isObscureRePass = !_isObscureRePass;
              });
            },
          )),
      validator: (value) {
        return val.validarRePass(value, _textControllerPassword.text);
      },
    );
  }
}
