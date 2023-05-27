import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../bloc/foto_bloc.dart';
import '../../model/cliente_model.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cliente_provider.dart';
import '../../utils/button.dart' as btn;
import '../../utils/redes_sociales.dart' as rs;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../utils/validar.dart' as val;

class EmailPage extends StatefulWidget {
  EmailPage({Key key}) : super(key: key);

  _EmailPageState createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PreferenciasUsuario prefs = PreferenciasUsuario();
  final ClienteProvider _clienteProvider = ClienteProvider();

  ClienteModel _cliente = ClienteModel();
  bool _saving = false;

  TextEditingController _textControllerPassword;

  @override
  void initState() {
    prefs.clienteModel = null;
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
            child: btn.bootonContinuar('Continuar',_continuar)),
        SizedBox(height: 20,)
      ],
    );
  }

  Widget _contenido() {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      padding: EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
      child: Column(
        children: <Widget>[
          Container(
            child: Column(
              children: [
          prs.titulo('EMAIL') ,
          prs.subTitulo('Tú relájate, nosotros te llevamos lo que necesites'),
          SizedBox(height: 20,),
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                prs.labels('Correo'),
                SizedBox(height: 10,),
                _crearCorreo(),
                SizedBox(height: 20,),
                prs.labels('Contraseña'),
                SizedBox(height: 10,),
                _crearPassword(),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          Container(
            width: double.infinity,
            alignment: Alignment.topLeft,
            child: TextButton(onPressed: _olvidePass, child: Text('Olvidé mi contraseña',style: TextStyle(color: prs.colorRojo, fontSize: 16,fontFamily: 'GoldplayBlack' )))),
          SizedBox(height: 10,),
          Container(
            width: double.infinity,
            alignment: AlignmentDirectional.center,
            child: Row(
              children: [
                Text('¿Aún no tienes una cuenta? '),
                TextButton(onPressed: _email2, child: Text('Regístrate',style: TextStyle(color: prs.colorRojo, fontSize: 16,fontFamily: 'GoldplayBlack' ))),
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

_olvidePass(){
  Navigator.pushNamed(context, 'recuperarpass');
}
_email2(){
    prefs.skipStep = "0";
    Navigator.pushNamed(context, 'email2');
  }
  Widget _crearCorreo() {
    return TextFormField(
        keyboardType: TextInputType.emailAddress,
        maxLength: 60,
        decoration: prs.decoration('Ingresar Correo', null),
        onChanged: (value) => _cliente.correo = value.trim(),
        validator: val.validarCorreo);
  }

  bool _isObscurePass = true;
  Widget _crearPassword() {
    return TextFormField(
        controller: _textControllerPassword,
        obscureText: _isObscurePass,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        maxLength: 12,
        onChanged: (value) => _cliente.clave = value.trim(),
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

  _continuar(){
    _autenticarClave();
  }

  _autenticarClave() {
    FocusScope.of(context).requestFocus(FocusNode());
    _saving = true;
    if (mounted) setState(() {});
    if (_cliente.clave.toString().length < 6) {
      _formKey.currentState.validate();
      _saving = false;
      if (mounted) setState(() {});
      return;
    }
    _formKey.currentState.save();
    
    _clienteProvider.autenticarClave(_cliente.correo.toString(),
      utils.generateMd5(_cliente.clave.toString()), (estado, clienteModel) {
      _saving = false;
      if (mounted) if (mounted) setState(() {});
      if (estado == 0) return _mostrarSnackBar(clienteModel);
      rs.ingresar(context, clienteModel);
    });
  }

    void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensaje),
    ));
  }
}