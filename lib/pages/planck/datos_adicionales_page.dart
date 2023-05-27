     import 'package:flutter/material.dart';
import 'package:mimo/providers/registro_provider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../bloc/foto_bloc.dart';
import '../../model/cliente_model.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cliente_provider.dart';
import '../../utils/button.dart' as btn;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/redes_sociales.dart' as rs;
import '../../utils/utils.dart' as utils;
import '../../utils/validar.dart' as val;

class DatosAdicionalesPage extends StatefulWidget {
  DatosAdicionalesPage({Key key}) : super(key: key);

  _DatosAdicionalesPageState createState() => _DatosAdicionalesPageState();
}

class _DatosAdicionalesPageState extends State<DatosAdicionalesPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); 

  final PreferenciasUsuario prefs = PreferenciasUsuario();
  final _fotoBloc = FotoBloc();
  final ClienteProvider _clienteProvider = ClienteProvider();

  ClienteModel _cliente = ClienteModel();
  final RegistroProvider _registroProvider = RegistroProvider();
  bool _saving = false;

  @override
  void initState() {
    _fotoBloc.fotoStream.listen((fotoTomada) async {
      if (!fotoTomada) return;
      _cliente.img = prefs.clienteModel.img;
      if (mounted) if (mounted) setState(() {});
    });

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
            child: Container(child: _body(), width: prs.anchoFormulario,decoration: BoxDecoration(color: Colors.white))),
      ),
    );
  }

  Widget _body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(child: SingleChildScrollView(child: _contenido())),
        Container(
            child: btn.bootonContinuar('Continuar',  _continuar)),
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
          prs.titulo('DATOS ADICIONALES') ,
          prs.subTitulo('Ayuda a nuestros repartidores a llegar hasta tu puerta'),
          SizedBox(height: 20,),
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                prs.labels('Dirección'),
                SizedBox(height: 10,),
                _crearNombres(),
                SizedBox(height: 20.0),
                prs.labels('Referencia'),
                SizedBox(height: 10,),
                _crearNombres(),
                SizedBox(height: 20,),
                prs.labels('Indicación extra'),
                SizedBox(height: 10,),
                _crearNombres(),
                 SizedBox(height: 20,),
                prs.labels('Elige una etiqueta'),
                SizedBox(height: 10,),
                ToggleSwitch(
                  minWidth: 130.0,
                  initialLabelIndex: (_cliente.sexo - 1),
                  activeBgColor: [prs.colorButtonSecondary],
                  totalSwitches: 2,
                  inactiveBgColor: Colors.black12,
                  activeFgColor: Colors.white,
                  labels: ['Casa', 'Departamento','Otro'],
                  onToggle: (index) {
                    _cliente.sexo = index == 0 ? 1 : 2 ;
                    _clienteProvider.genero(_cliente);
                  },
                ),
              ],
            ),
          ),          
          
        ],
      ),
    );
  }

 _continuar(){
    Future.delayed(const Duration(milliseconds: 400), () async {
        _registroProvider.registrar(_cliente, '+51', '',
            (estado, clienteModel) {
          _saving = false;
          if (mounted) setState(() {});
          if (estado == 0) return utils.mostrarSnackBar(context, clienteModel);
          rs.ingresar(context, clienteModel);
        });
    });
    Navigator.pushNamed(context, 'taxis');
  }

  Widget _crearNombres() {
    return TextFormField(
        maxLength: 90,
        /* initialValue: _cliente.nombres, */
        decoration: prs.decoration(' ', null),
        onSaved: (value) => _cliente.nombres = value,
        validator: val.validarNombre);
  }
}
