import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../bloc/foto_bloc.dart';
import '../../dialog/contrasenia_dialog.dart';
import '../../dialog/foto_perfil_dialog.dart';
import '../../model/cliente_model.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cliente_provider.dart';
import '../../utils/button.dart' as btn;
import '../../utils/cache.dart' as cache;
import '../../utils/dialog.dart' as dlg;
import '../../utils/permisos.dart' as permisos;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../utils/validar.dart' as val;

class EditPerfilTaxiPage extends StatefulWidget {
  EditPerfilTaxiPage({Key key}) : super(key: key);

  _EditPerfilTaxiPageState createState() => _EditPerfilTaxiPageState();
}

class _EditPerfilTaxiPageState extends State<EditPerfilTaxiPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PreferenciasUsuario prefs = PreferenciasUsuario();
  final _fotoBloc = FotoBloc();
  final ClienteProvider _clienteProvider = ClienteProvider();

  ClienteModel _cliente = ClienteModel();

  bool _saving = false;

  TextEditingController _inputFieldDateController;

  TextEditingController _textControllerPassword;

  @override
  void initState() {
    _fotoBloc.fotoStream.listen((fotoTomada) async {
      if (!fotoTomada) return;
      _cliente.img = prefs.imagen;
      if (mounted) setState(() {});
      return;
    });
    _cliente = prefs.clienteModel;
    prefs.imagen = _cliente.img;
    _textControllerPassword = TextEditingController(text: _cliente.clave);
    _inputFieldDateController = TextEditingController(text: _cliente.fechaNacimiento);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Perfil'),
        leading: utils.leadingTaxi(context,prs.colorMorado),
        elevation: 0,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Center(
            child: Container(color: Colors.white, child: _body(), width: prs.anchoFormulario)),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(child: SingleChildScrollView(child: _contenido())),
        Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(          
                onPressed: () {
                  _guardarCambios();
                },
                child: Text(
                  "Guardar cambios",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(),
                    padding: EdgeInsets.symmetric(vertical: 20,),
                    backgroundColor: prs.colorMorado,
                    foregroundColor: prs.colorMorado),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatar() {
    Widget _tarjeta = ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(100)),
      child: cache.fadeImage(_cliente.img, width: 100, height: 100),
    );
    return Stack(
      children: <Widget>[
        _tarjeta,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(110)),
                splashColor: Colors.blueAccent.withOpacity(0.6),
                onTap: () => _cambiarFoto()),
          ),
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
          CircularPercentIndicator(
            radius: 57.0,
            lineWidth: 7.0,
            percent: (_cliente.registros > 0)
                ? (_cliente.correctos / _cliente.registros)
                : 1.0,
            center: _avatar(),
            circularStrokeCap: CircularStrokeCap.round,
             progressColor: prs.colorMorado,
          ),
          SizedBox(height: 20.0),
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                prs.labels('Nombres'),
                SizedBox(height: 10,),
                _crearNombres(),
                SizedBox(height: 20.0),
                prs.labels('Apellidos'),
                SizedBox(height: 10,),
                _crearApellidos(),
                SizedBox(height: 20.0),
                prs.labels('Correo'),
                SizedBox(height: 10,),
                _crearCorreo(),
                SizedBox(height: 20.0),
                prs.labels('Contraseña'),
                SizedBox(height: 10,),
                _crearPassword(),
              ],
            ),
          ),
          SizedBox(height: 100.0),
        ],
      ),
    );
  }

  Widget _crearNombres() {
    return TextFormField(
        maxLength: 90,
        initialValue: _cliente.nombres, 
        textCapitalization: TextCapitalization.words,
        decoration: prs.decoration(_cliente.nombres, null),
        onChanged: (value) => _cliente.nombres = value,
        validator: val.validarNombre);
  }

  Widget _crearApellidos() {
    return TextFormField(
        maxLength: 90,
        initialValue: _cliente.apellidos, 
        textCapitalization: TextCapitalization.words,
        decoration: prs.decoration(_cliente.apellidos, null),
        onChanged: (value) => _cliente.apellidos = value,
        validator: val.validarNombre);
  }

  Widget _crearCorreo() {
    return TextFormField(
        keyboardType: TextInputType.emailAddress,
        maxLength: 60,
        initialValue: _cliente.correo, 
        decoration: prs.decoration(_cliente.correo, null),
        onChanged: (value) => _cliente.correo = value,
        validator: val.validarCorreo);
  }

  Widget _crearFecha(BuildContext context) {
    return TextField(
      enableInteractiveSelection: false,
      controller: _inputFieldDateController,
      decoration: prs.decoration('Fecha de nacimiento',
          Icon(Icons.calendar_today, color: prs.colorIcons)),
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        _selectDate(context);
      },
    );
  }

  final f = new DateFormat('yyyy-MM-dd');

  _selectDate(BuildContext context) async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1940),
        lastDate: DateTime.now(),
        locale: Locale('es', 'ES'));
    if (picked != null) {
      setState(() {
        _cliente.fechaNacimiento = f.format(picked);
        _inputFieldDateController.text = f.format(picked);
      });
    }
  }

  Widget _crearPassword() {
    return TextFormField(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        _cambiarContrasenia();
      },
      controller: _textControllerPassword,
      obscureText: true,
      maxLength: 12,
      decoration: prs.decoration('Contraseña', Icon(Icons.edit, color: prs.colorMorado)),
    );
  }

  _cambiarContrasenia() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ContraseniaDialog(cliente: _cliente);
        });
  }

  _cambiarFoto() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return FotoPerfilDialog(cliente: _cliente);
        });
  }

  _guardarCambios() {
    FocusScope.of(context).requestFocus(FocusNode());
    _formKey.currentState.validate();
    _formKey.currentState.save();
    Future.delayed(const Duration(milliseconds: 400), () async {
        _saving = true;
        if (mounted) setState(() {});
        if (!_formKey.currentState.validate()) {
          _saving = false;
          if (mounted) setState(() {});
          return;
        }
        _formKey.currentState.save();
        _clienteProvider.editar(_cliente, (estado, error) {
          _saving = false;
          if (mounted) setState(() {});
          dlg.mostrar(context, error);
        });
    });
  }
}