import 'dart:async';

import '../model/direccion_model.dart';
import '../providers/direccion_provider.dart';

class DireccionBloc {
  final DireccionProvider _direccionProvider = DireccionProvider();
  DireccionModel direccionSeleccionada = DireccionModel();

  List<DireccionModel> direcciones = [];

  static DireccionBloc _instancia;

  DireccionBloc._internal();

  factory DireccionBloc() {
    if (_instancia == null) {
      _instancia = DireccionBloc._internal();
    }
    return _instancia;
  }

  final direccionesStreamController =
      StreamController<List<DireccionModel>>.broadcast();

  Function(List<DireccionModel>) get direccionSink =>
      direccionesStreamController.sink.add;

  Stream<List<DireccionModel>> get direccionStream =>
      direccionesStreamController.stream;

  Future<List<DireccionModel>> listar() async {
    final direccionesResponse = await _direccionProvider.listarDirecciones();
    direcciones.clear();
    direcciones.addAll(direccionesResponse);
    direcciones.add(new DireccionModel(
        alias: 'Crear nueva dirección',
        referencia: 'Toca para crear una dirección',
        img: 'assets/screen/direcciones.png'));
    direccionSink(direcciones);
    return direccionesResponse;
  }

  Future<List<DireccionModel>> filtrar(String pattern) async {
    if (direcciones.isEmpty) {
      await listar();
    }
    direcciones.sort((a, b) =>
        (a.alias.toString().toUpperCase().contains(pattern.toUpperCase())
            ? 0
            : 1));
    return direcciones;
  }

  Future crear(DireccionModel direccionModel) async {
    final Map direccionMap = await _direccionProvider.crearDireccion(direccionModel);
    direccionModel.idDireccion = direccionMap['id_direccion'];
    direccionModel.alias = direccionMap['alias'];
    direccionModel.fechaRegistro = direccionMap['fecha_registro'];
    direccionModel.idCliente = direccionMap['id_cliente'];
    direccionModel.idUrbe = direccionMap['id_urbe'];
    direccionModel.img = direccionMap['img'];
    direccionModel.lg = direccionMap['lg'];
    direccionModel.lt = direccionMap['lt'];
    direccionModel.referencia = direccionMap['referencia'];
    direcciones.add(direccionModel);
    direcciones.sort((a, b) => b.idUrbe.compareTo(a.idUrbe));
    direccionSink(direcciones);
  }

  Future editar(DireccionModel direccionModel) async {
    await _direccionProvider.editarDireccion(direccionModel);
    direccionSink(direcciones);
  }

  Future eliminar(DireccionModel direccionModel) async {
    await _direccionProvider.eliminarDireccion(direccionModel);
    direcciones.remove(direccionModel);
    direccionSink(direcciones);
    return;
  }

  void disposeStreams() {
    direccionesStreamController?.close();
  }
}