import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../preference/shared_preferences.dart';
import '../../utils/button.dart' as btn;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../utils/validar.dart' as val;

class NuevaPassPage extends StatefulWidget {
  NuevaPassPage({Key key}) : super(key: key);

  _NuevaPassPageState createState() => _NuevaPassPageState();
}

class _NuevaPassPageState extends State<NuevaPassPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PreferenciasUsuario prefs = PreferenciasUsuario();
  bool _saving = false;
  TextEditingController _textControllerPassword;

  @override
  void initState() {
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
            child: Container(child: _body(), width: prs.anchoFormulario,decoration: BoxDecoration(color: Colors.white),)),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(child: SingleChildScrollView(child: _contenido())),
        Container(
            child: btn.bootonContinuar('Continuar',_continuar))
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
          prs.titulo('CREAR UNA NUEVA CONTRASEÑA') ,
          Container(
              width: double.infinity,
              alignment: Alignment.bottomLeft,
              child:
                Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: 'Asegúrate de que contenga almenos ', style: TextStyle(color: prs.colorGrisOscuro, fontFamily: 'GoldplayRegular',fontSize: 18 )),
                          TextSpan(text: 'una mayúscula ', style: TextStyle(color: prs.colorRojo, fontWeight: FontWeight.bold,fontSize: 18)),
                          TextSpan(text: 'y ', style: TextStyle(color: prs.colorGrisOscuro, fontFamily: 'GoldplayRegular',fontSize: 18 )),
                          TextSpan(text: 'un número', style: TextStyle(color: prs.colorRojo, fontWeight: FontWeight.bold,fontSize: 18)),
                        ],
                      ),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'GoldplayRegular'
                      ),
                    ),
            ),
          SizedBox(height: 20,),
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
               SizedBox(height: 20,),
                prs.labels('Nueva contraseña'),
                SizedBox(height: 10,),
                _crearPassword(),
                 SizedBox(height: 20,),
                prs.labels('Confirmar contraseña'),
                SizedBox(height: 10,),
                _crearRePassword(),
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

_continuar()async{
    _saving = true;
    if (mounted) setState(() {});
    if (_formKey.currentState.validate()) {
      String documentId = (await FirebaseFirestore.instance.collection("client").where("correo",isEqualTo: prefs.correoTemp).get()).docs.first.id;
      await FirebaseFirestore.instance.collection("client").doc(documentId).update({"clave":utils.generateMd5(_textControllerPassword.text)});
      Navigator.pushNamed(context, 'cambio_pass');
      _saving = false;
      if (mounted) setState(() {});
    }else {
      utils.newAlert(
          context, 'Fallido', 'Por favor validar todos los campos', 'Failure');
      _saving = false;
      if (mounted) setState(() {});
    }
  }

  TextEditingController _textControllerRePassword = TextEditingController();
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