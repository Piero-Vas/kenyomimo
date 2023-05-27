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

class PerfilPage extends StatefulWidget {
  PerfilPage({Key key}) : super(key: key);

  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PreferenciasUsuario prefs = PreferenciasUsuario();
  final _fotoBloc = FotoBloc();
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final ClienteProvider _clienteProvider = ClienteProvider();

  ClienteModel _cliente = ClienteModel();

  bool _saving = false;

  TextEditingController _inputFieldDateController;

  TextEditingController _textControllerPassword;

  @override
  void initState() {
    _fotoBloc.fotoStream.listen((fotoTomada) async {
      if (!fotoTomada) return;
      _cliente.img = prefs.clienteModel.img;
      if (mounted) if (mounted) setState(() {});
    });

    _cliente = prefs.clienteModel;
    _textControllerPassword = TextEditingController(text: _cliente.clave);
    _inputFieldDateController =
        TextEditingController(text: _cliente.fechaNacimiento);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Perfil'),
        leading: utils.leading(context),
        elevation: 0,
        actions: <Widget>[ 
          // Visibility(
          //   visible: !_prefs.isExplorar,
          //   child: IconButton(
          //     icon: Icon(FontAwesomeIcons.userShield,
          //         size: 22.0, color: prs.colorIconsAppBar),
          //     onPressed: () {
          //       Navigator.pushNamed(context, 'sessiones');
          //     },
          //   ),
          // ),
          IconButton(
            icon: Icon(FontAwesomeIcons.signOutAlt,
                size: 22.0, color: prs.colorIconsAppBar),
            onPressed: () {
              _cerrarSession();
            },
          )
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Center(
            child: Container(child: _body(), width: prs.anchoFormulario)),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(child: SingleChildScrollView(child: _contenido())),
        Visibility(
            visible: !_prefs.isExplorar,
            child: btn.bootonContinuar('GUARDAR CAMBIOS', _guardarCambios))
      ],
    );
  }

  _cerrarSession() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: Text(
              'Alerta',
              textAlign: TextAlign.center,
            ),
            content: Text('¿Seguro deseas cerrar sesión?'),
            actions: <Widget>[
              TextButton(
                  child: Text('CANCELAR'),
                  onPressed: () => Navigator.of(context).pop()),
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: prs.colorButtonSecondary,
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0))),
                  label: Text('CERRAR SESIÓN'),
                  icon: Icon(
                    FontAwesomeIcons.signOutAlt,
                    color: Colors.white,
                    size: 15.0,
                  ),
                  onPressed: () {
                    utils.mostrarProgress(context, barrierDismissible: false);
                    _clienteProvider.cerrarSession((estado, error) {
                      if (estado == 1) {
                        permisos.cerrasSesion(context);
                      } else {
                        utils.mostrarSnackBar(context, error,
                            milliseconds: 2500);
                        Navigator.of(context).pop();
                        Navigator.pop(context);
                      }
                    });
                  }),
            ],
          );
        });
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
          prs.titulo('MIS DATOS') ,
          prs.subTitulo('Estos datos nos permite conocerte un poco mejor.'),
          SizedBox(height: 20,),
          CircularPercentIndicator(
            radius: 57.0,
            lineWidth: 7.0,
           /*  animation: true, */
            percent: (_cliente.registros > 0)
                ? (_cliente.correctos / _cliente.registros)
                : 1.0,
            center: _avatar(),
            circularStrokeCap: CircularStrokeCap.round,
            /* progressColor: prs.colorButtonSecondary, */
          ),
          /* _estrellas(),
          Text(
              "Correctas: ${_cliente.correctos} - Canceladas: ${_cliente.canceladas}",
              style: TextStyle(fontSize: 12.0)), */
          SizedBox(height: 20.0),
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                prs.labels('Nombre'),
                SizedBox(height: 10,),
                _crearNombres(),
                SizedBox(height: 20.0),
                prs.labels('Apellido'),
                SizedBox(height: 10,),
                _crearApellidos(),
                SizedBox(height: 20.0),
                prs.labels('Número de teléfono'),
                SizedBox(height: 10,),
                _celular(),
                SizedBox(height: 20.0),
                prs.labels('Correo'),
                SizedBox(height: 10,),
                _crearCorreo(),
                SizedBox(height: 20.0),
                prefs.clienteModel.perfil=="2" ?
                Column(
                  children: [
                prs.labels('Placa'),
                SizedBox(height: 10,),
                _placa(),
                SizedBox(height: 20.0),
                prs.labels('Marca'),
                SizedBox(height: 10,),
                _marca(),
                SizedBox(height: 20.0),
                prs.labels('Modelo'),
                SizedBox(height: 10,),
                _modelo(),
                SizedBox(height: 20.0),
                  ],
                )
                :SizedBox(),
                // Text('Género'),
                // SizedBox(height: 7.0),
                // ToggleSwitch(
                //   minWidth: 130.0,
                //   initialLabelIndex: (_cliente.sexo - 1),
                //   activeBgColor: [prs.colorButtonSecondary],
                //   totalSwitches: 2,
                //   inactiveBgColor: Colors.black12,
                //   activeFgColor: Colors.white,
                //   labels: ['Mujer', 'Hombre'],
                //   onToggle: (index) {
                //     _cliente.sexo = index == 0 ? 1 : 2;
                //     _clienteProvider.genero(_cliente);
                //   },
                // ),
                // SizedBox(height: 20.0),
                // prs.labels('Fecha de nacimiento'),
                // SizedBox(height: 10,),
                // _crearFecha(context),
                // SizedBox(height: 20.0),
                prs.labels('Contraseña'),
                SizedBox(height: 10,),
                _crearPassword(),
              ],
            ),
          ),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }

  Widget _estrellas() {
    return utils.estrellas(
        (_cliente.calificacion / _cliente.calificaciones), (value) {});
  }

  Widget _crearNombres() {
    return TextFormField(
        maxLength: 90,
        initialValue: _cliente.nombres, 
        decoration: prs.decoration(_cliente.nombres, null),
        onChanged: (value) => _cliente.nombres = value,
        validator: val.validarNombre);
  }
  
  Widget _placa() {
    return TextFormField(
      readOnly: true,
        initialValue:prefs.clienteModel.driverLicensePlate, 
        decoration: prs.decoration(prefs.clienteModel.driverLicensePlate, null),
        
        );
  }
  Widget _marca() {
    return TextFormField(
        readOnly: true,
        initialValue:prefs.clienteModel.driverTradeMark, 
        decoration: prs.decoration(prefs.clienteModel.driverTradeMark, null),);
  }
  Widget _modelo() {
    return TextFormField(
        readOnly: true,
        initialValue: prefs.clienteModel.driverModel, 
        decoration: prs.decoration(prefs.clienteModel.driverModel, null),);
  }

  Widget _celular() {
    return TextFormField(
        readOnly: true,
        initialValue: prefs.clienteModel.celular, 
        decoration: prs.decoration(prefs.clienteModel.celular, null),);
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

  bool isCelularValido = true;

  _onChangedCelular(phone) {
    _cliente.celular = phone.toString();
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
      decoration:
          prs.decoration('Contraseña', Icon(Icons.edit, color: prs.colorIcons)),
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
      if (isCelularValido) {
        _saving = true;
        if (mounted) setState(() {});
        if (!_formKey.currentState.validate()) {
          _saving = false;
          if (mounted) setState(() {});
          return;
        }
        if (!isCelularValido) {
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
      }
    });
  }
}
