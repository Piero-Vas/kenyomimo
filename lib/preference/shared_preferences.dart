import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../model/cliente_model.dart';
import '../model/direccion_model.dart';
import '../sistema.dart';

class PreferenciasUsuario {
  static PreferenciasUsuario _instancia;

  PreferenciasUsuario._internal();

  factory PreferenciasUsuario() {
    if (_instancia == null) {
      _instancia = PreferenciasUsuario._internal();
    }
    return _instancia;
  }

  init() async {
    try {
      _instancia._prefs = await SharedPreferences.getInstance();
    } catch (err) {
      print(err);
    }
  }

  SharedPreferences _prefs;
  set correoTemp(String value) {
    _prefs.setString('correoTemp', value);
  }

  get correoTemp {
    return _prefs.getString('correoTemp') ?? '';
  }
  set claveTemp(String value) {
    _prefs.setString('claveTemp', value);
  }

  get claveTemp {
    return _prefs.getString('claveTemp') ?? '';
  }
   set mustUpdate(bool value) {
    _prefs.setBool('mustUpdate', value);
  }

  get mustUpdate {
    return _prefs.getBool('mustUpdate') ?? false;
  }

   set activoCliente(bool value) {
    _prefs.setBool('activoCliente', value);
  }
  get activoCliente {
    return _prefs.getBool('activoCliente') ?? false;
  }

  

  set idGoogle(String value) {
    _prefs.setString('idGoogle', value);
  }

  get idGoogle {
    return _prefs.getString('idGoogle') ?? '';
  }

  set idFacebook (String value) {
    _prefs.setString('idFacebook', value);
  }

  get idFacebook {
    return _prefs.getString('idFacebook') ?? '';
  }

  set driverImg(String value) {
    _prefs.setString('driverImg', value);
  }

  get driverImg {
    return _prefs.getString('driverImg') ?? '';
  }

  set driverName(String value) {
    _prefs.setString('driverName', value);
  }

  get driverName {
    return _prefs.getString('driverName') ?? '';
  }

  set driverModel(String value) {
    _prefs.setString('driverModel', value);
  }

  get driverModel {
    return _prefs.getString('driverModel') ?? '';
  }

  set driverLicensePlate(String value) {
    _prefs.setString('driverLicensePlate', value);
  }

  get driverLicensePlate {
    return _prefs.getString('driverLicensePlate') ?? '';
  }

  set driverTradeMark(String value) {
    _prefs.setString('driverTradeMark', value);
  }

  get driverTradeMark {
    return _prefs.getString('driverTradeMark') ?? '';
  }

  set testig(bool value) {
    _prefs.setBool('testig', value);
  }

  get testig {
    return _prefs.getBool('testig') ?? false;
  }

  set isTaxi(bool value) {
    _prefs.setBool('isTaxi', value);
  }

  get isTaxi {
    return _prefs.getBool('isTaxi') ?? true;
  }

  get param {
    return _prefs.getString('param') ?? '';
  }

  set param(String value) {
    _prefs.setString('param', value);
  }

  get auth {
    return _prefs.getString('auth') ?? '';
  }

  set auth(String value) {
    _prefs.setString('auth', value);
  }

  get sms {
    return _prefs.getString('sms') ?? '';
  }

  set sms(String value) {
    _prefs.setString('sms', value);
  }

  get solicitados {
    return _prefs.getInt('solicitados') ?? 0;
  }

  set solicitados(int value) {
    _prefs.setInt('solicitados', value);
  }

  get fechaCodigo {
    return _prefs.getString('fechaCodigo') ?? DateTime.now().toIso8601String();
  }

  set fechaCodigo(String value) {
    _prefs.setString('fechaCodigo', value);
  }

  get estadoTc {
    return _prefs.getInt('estadoTc') ?? 0;
  }

  set estadoTc(int value) {
    _prefs.setInt('estadoTc', value);
  }

  get mensajeTc {
    return _prefs.getString('mensajeTc') ??
        'Próximamente podrás pagar con tus tarjetas favoritas.';
  }

  set mensajeTc(String value) {
    _prefs.setString('mensajeTc', value);
  }

  get imagen {
    return _prefs.getString('imagen') ??
        'Próximamente podrás pagar con tus tarjetas favoritas.';
  }

  set imagen(String value) {
    _prefs.setString('imagen', value);
  }

  get conf {
    return _prefs.getString('conf') ?? 'null';
  }

  set conf(String value) {
    _prefs.setString('conf', value);
  }

  get verificationIdReceived {
    return _prefs.getString('verificationIdReceived') ?? 'null';
  }

  set verificationIdReceived(String value) {
    _prefs.setString('verificationIdReceived', value);
  }

  get celular {
    return _prefs.getString('celular') ?? '';
  }

  set celular(String value) {
    _prefs.setString('celular', value);
  }
  get clave {
    return _prefs.getString('clave') ?? '';
  }

  set clave(String value) {
    _prefs.setString('clave', value);
  }

  set clienteModel(ClienteModel cliente) {
    _prefs.setString('idUrbe', cliente==null ? '' : cliente.idUrbe.toString());
    _prefs.setString('link', cliente==null ? '' : cliente.link.toString());
    _prefs.setString('nombres', cliente==null ? '' : cliente.nombres.toString());
    _prefs.setString('apellidos', cliente==null ? '' : cliente.apellidos.toString());
    _prefs.setString('correo', cliente==null ? '' : cliente.correo.toString());
    _prefs.setString('idCliente', cliente==null ? '' : cliente.idCliente.toString());
    _prefs.setString('cedula', cliente==null ? '' : cliente.cedula.toString());
    _prefs.setString('celular', cliente==null ? '' : cliente.celular.toString());
    _prefs.setString('img', cliente==null ? '' : cliente.img.toString());
    _prefs.setString('perfil', cliente==null ? '' : cliente.perfil.toString());
    _prefs.setString('beta', cliente==null ? '' : cliente.beta.toString());
    _prefs.setString('color', cliente==null ? '' : cliente.color.toString());

    _prefs.setInt('celularValidado', cliente==null ? -1 : cliente.celularValidado);
    _prefs.setInt('sexo', cliente==null ? -1 : cliente.sexo);
    _prefs.setDouble('calificacion', cliente==null ? -1.0 : cliente.calificacion);
    _prefs.setInt('calificaciones', cliente==null ? -1 : cliente.calificaciones);
    _prefs.setInt('registros', cliente==null ? -1 : cliente.registros);
    _prefs.setInt('puntos', cliente==null ? -1 : cliente.puntos);
    _prefs.setInt('direcciones', cliente==null ? -1 : cliente.direcciones);
    _prefs.setInt('correctos', cliente==null ? -1 : cliente.correctos);
    _prefs.setInt('canceladas', cliente==null ? -1 : cliente.canceladas);
    _prefs.setString('fechaNacimiento', cliente==null ? '' : cliente.fechaNacimiento);
    _prefs.setString('driverModel', cliente==null ? '' : cliente.driverModel==null ? "" : cliente.driverModel);
    _prefs.setString('driverLicensePlate',  cliente==null ? '' : cliente.driverLicensePlate);
    _prefs.setString('driverTradeMark',  cliente==null ? '' : cliente.driverTradeMark);
    _prefs.setString('typeVehicle',  cliente==null ? '' : cliente.typeVehicle);
    _prefs.setString('token',  cliente==null ? '' : cliente.token);
  }

  get clienteModel {
    final cliente = ClienteModel();
    cliente.link = _prefs.getString('link') ?? '';
    cliente.nombres = _prefs.getString('nombres') ?? '';
    cliente.apellidos = _prefs.getString('apellidos') ?? '';
    cliente.correo = _prefs.getString('correo') ?? '';
    cliente.idCliente = _prefs.getString('idCliente') ?? '';
    cliente.cedula = _prefs.getString('cedula') ?? '';
    cliente.celular = _prefs.getString('celular') ?? '';
    cliente.img = _prefs.getString('img') ?? '';
    cliente.perfil = _prefs.getString('perfil') ?? '';
    cliente.beta = _prefs.getString('beta') ?? '';
    cliente.color = _prefs.getString('color') ?? '';

    cliente.celularValidado = _prefs.getInt('celularValidado') ?? 0;
    cliente.sexo = _prefs.getInt('sexo') ?? 0;
    cliente.calificacion = _prefs.getDouble('calificacion') ?? 0.0;
    cliente.calificaciones = _prefs.getInt('calificaciones') ?? 0;
    cliente.registros = _prefs.getInt('registros') ?? 0;
    cliente.puntos = _prefs.getInt('puntos') ?? 0;
    cliente.direcciones = _prefs.getInt('direcciones') ?? 0;
    cliente.correctos = _prefs.getInt('correctos') ?? 0;
    cliente.canceladas = _prefs.getInt('canceladas') ?? 0;
    cliente.fechaNacimiento = _prefs.getString('fechaNacimiento') ?? '';
    cliente.driverModel =_prefs.getString('driverModel') ?? '';
    cliente.driverLicensePlate =_prefs.getString('driverLicensePlate') ?? '';
    cliente.driverTradeMark =_prefs.getString('driverTradeMark') ?? '';
    cliente.typeVehicle =_prefs.getString('typeVehicle') ?? '';
    cliente.token =_prefs.getString('token') ?? '';
    return cliente;
  }

  set direccionModel(DireccionModel direccion) {
    _prefs.setInt('idDireccion', direccion.idDireccion);
    _prefs.setDouble('lt', direccion.lt);
    _prefs.setDouble('lg', direccion.lg);
    _prefs.setString('direccion', direccion.alias.toString());
  }

  get direccionModel {
    final direccion = DireccionModel();
    direccion.idDireccion = _prefs.getInt('idDireccion') ?? -1;
    direccion.lt = _prefs.getDouble('lt') ?? Sistema.lt;
    direccion.lg = _prefs.getDouble('lg') ?? Sistema.lg;
    direccion.alias = _prefs.getString('direccion') ?? '';
    return direccion;
  }

  get isDemo {
    return clienteModel.correo ==
            'explorar@${Sistema.aplicativoTitle.toLowerCase()}.com' ||
        isExplorar;
  }

  get isExplorar {
    return '' == _prefs.getString('idCliente') ||
        _prefs.getString('idCliente') == Sistema.ID_CLIENTE;
  }

  get idCliente {
    return _prefs.getString('idCliente') ?? '';
  }

  set idCliente(String value) {
    if (_prefs != null) _prefs.setString('idCliente', value);
  }

  get uuid {
    if (_prefs.getString('uuid') == null) {
      _prefs.setString('uuid', Uuid().v4());
    }
    return _prefs.getString('uuid');
  }

  set uuid(String value) {
    if (uuid != null) _prefs.setString('uuid', value);
  }

  get imei {
    return _prefs.getString('imei') ?? '';
  }

  set imei(String value) {
    if (_prefs != null) _prefs.setString('imei', value);
  }

  get token {
    if (_prefs == null) return '';
    return _prefs.getString('token') ?? '';
  }

  set token(String value) {
    if (_prefs != null) _prefs.setString('token', value);
  }

  get empezamos {
    if (_prefs == null) return false;
    return _prefs.getBool('empezamos') ?? false;
  }

  set empezamos(bool value) {
    if (_prefs != null) _prefs.setBool('empezamos', value);
  }

  get idUrbe {
    return _prefs.getString('idUrbe') ?? '1';
  }

  set idUrbe(String value) {
    if (_prefs != null) _prefs.setString('idUrbe', value);
  }

  get skipStep {
    return _prefs.getString('skipStep') ?? '0';
  }

  set skipStep(String value) {
    if (_prefs != null) _prefs.setString('skipStep', value);
  }

  get alias {
    return _prefs.getString('alias') ?? '?';
  }

  set alias(String value) {
    if (_prefs != null) _prefs.setString('alias', value);
  }

  get idAgencia {
    return _prefs.getString('idAgencia') ?? '0';
  }

  set idAgencia(String value) {
    if (_prefs != null) _prefs.setString('idAgencia', value);
  }

  get simCountryCode {
    return _prefs.getString('simCountryCode') ?? 'PE';
  }

  set simCountryCode(String value) {
    if (_prefs != null) _prefs.setString('simCountryCode', value.toUpperCase());
  }

  get rastrear {
    return _prefs.getBool('rastrear') ?? false;
  }

  set rastrear(bool value) {
    if (_prefs != null) _prefs.setBool('rastrear', value);
  }

  get optimizado {
    return _prefs.getBool('optimizado') ?? false;
  }

  set optimizado(bool value) {
    if (_prefs != null) _prefs.setBool('optimizado', value);
  }
}