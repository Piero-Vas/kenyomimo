import 'dart:io';
import 'package:mimo/providers/motos_provider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mimo/providers/taxistas_provider.dart';
import '../../model/cliente_model.dart';
import '../../preference/shared_preferences.dart';
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../utils/validar.dart' as val;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class SerMotoPage extends StatefulWidget {
  const SerMotoPage({Key key}) : super(key: key);

  @override
  State<SerMotoPage> createState() => _SerMotoPageState();
}

class _SerMotoPageState extends State<SerMotoPage> {
  String dniValue,marcaValue,modeloValue,placaValue,tipovehiculoValue="A",infoValue;
  final MotosProvider _registromotoProvider = MotosProvider();
  final formkey = GlobalKey<FormState>();
  TextEditingController dni = TextEditingController();
  TextEditingController marca = TextEditingController();
  TextEditingController modelo = TextEditingController();
  TextEditingController placa = TextEditingController();
  TextEditingController infoad = TextEditingController();
  String imagenLicencia = "";
  bool _saving = false;
  bool isChecked = false;
  bool imageLoaded = false;
  Future addImageRegistro(linkfoto) async {
    final refstorange = firebase_storage.FirebaseStorage.instance.ref().child('usuarios')
        .child('/${DateTime.now().millisecondsSinceEpoch.toString()}' + '.jpeg');
    final result = await refstorange.putFile(File(linkfoto));
    final fileurl = await result.ref.getDownloadURL();
    return fileurl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ser Delivery',
            style: TextStyle(
                color: prs.colorGrisOscuro,
                fontSize: 17,
                fontFamily: 'GoldplayRegular',
                fontWeight: FontWeight.w800)),
        centerTitle: true,
        elevation: 0,
        leading: _saving ? SizedBox() : utils.leading(context),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Container(
          height: double.infinity,
          color: Colors.white,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: formkey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "DNI, carnet de extranjeria o CPP",
                          style: TextStyle(
                            fontFamily: 'GoldplayRegular',
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _crearDNI(dni),
                    SizedBox(
                      height: 30,
                    ),
                    // Row(
                    //   children: [
                    //     Text(
                    //       "Tipo Vehiculo",
                    //       style: TextStyle(
                    //         fontFamily: 'GoldplayRegular',
                    //         fontSize: 15,
                    //       ),
                    //       textAlign: TextAlign.justify,
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    // _crearTipoVehiculo(),
                    // SizedBox(
                    //   height: 30,
                    // ),
                    Row(
                      children: [
                        Text(
                          "Marca del vehículo",
                          style: TextStyle(
                            fontFamily: 'GoldplayRegular',
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _crearMarca(marca),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Text(
                          "Modelo del vehículo",
                          style: TextStyle(
                            fontFamily: 'GoldplayRegular',
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _crearModelo(modelo),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Text(
                          "Número de placa",
                          style: TextStyle(
                            fontFamily: 'GoldplayRegular',
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _crearPlaca(placa),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Text(
                          "Número de Licencia",
                          style: TextStyle(
                            fontFamily: 'GoldplayRegular',
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _crearInfo(infoad),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Text(
                          "Sube una foto de tu licencia de conducir",
                          style: TextStyle(
                            fontFamily: 'GoldplayRegular',
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    imagenLicencia==""?
                    Container(
                      decoration: BoxDecoration(
                          color: prs.colorGrisAreaTexto,
                          borderRadius: BorderRadius.circular(10)),
                      width: double.infinity,
                      height: 200,
                      child: Center(
                          child: Container(
                        decoration: BoxDecoration(
                            color: prs.colorRojo,
                            borderRadius: BorderRadius.circular(10)),
                        child: IconButton(
                          onPressed: () async {
                           imageLoaded = false;
                            _saving = true;
                            if (mounted) setState(() {});
                            ImagePicker img = ImagePicker();
                            XFile imagen = await img.pickImage(source: ImageSource.gallery);
                            if(imagen==null){
                              _saving = false;
                              if (mounted) setState(() {});
                              utils.mostrarSnackBar(context, "No selecciono ninguna imagen",milliseconds: 3000000);
                              return;
                            }
                            File file = File(imagen.path);
                            final mb = ((await file.readAsBytes()).lengthInBytes/1024)/1024;
                            if(mb>2.0){
                              _saving = false;
                              if (mounted) setState(() {});
                              utils.mostrarSnackBar(context, "El peso de la imagen es muy grande, por favor seleccione otra imagen",milliseconds: 3000000);
                              return;
                            }
                            final imagenComprimida = await utils.comprimirImagen(imagen.path, 50, 250, 250);
                            imagenLicencia = await addImageRegistro(imagenComprimida.path);
                            Future.wait([Future.value(imagenLicencia)]);
                            _saving = false;
                            imageLoaded = true;
                            if (mounted) setState(() {});
                          },
                          icon: Center(
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )),
                    ) : Container(
                      decoration: BoxDecoration(
                          color: prs.colorGrisAreaTexto,
                          borderRadius: BorderRadius.circular(10)),
                      width: double.infinity,
                      height: 200,
                      child: Center(
                          child: Container(
                        decoration: BoxDecoration(
                            color: prs.colorMorado,
                            borderRadius: BorderRadius.circular(10)),
                        child: Image.network(imagenLicencia),
                        )),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                          Checkbox(
                            value: isChecked,
                            shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0),side: BorderSide(
                                    color: prs.colorRojo, 
                                    width: 1.0,
                                    style: BorderStyle.solid)),
                            activeColor:  prs.colorRojo,
                           onChanged: (newbool){
                            setState(() {
                              isChecked = newbool;
                            });
                          }),
                          Expanded(child: Text('Acepto Término y Condiciones',style: TextStyle(fontFamily: 'GoldplayRegular', fontWeight: FontWeight.w700),))
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child:imageLoaded ? ElevatedButton(
                        onPressed: enviardatos,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            "Enviar solicitud",
                            style: TextStyle(
                                fontSize: 17,
                                fontFamily: 'GoldplayRegular',
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: prs.colorRojo,
                            foregroundColor: Colors.white,
                            elevation: 1.0,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: prs.colorRojo, //Bordes
                                    width: 1.0,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(50.0))),
                      ): SizedBox(),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  enviardatos() async {
    _saving = true;
    if (mounted) setState(() {});
    ClienteModel _cliente = ClienteModel();
    final PreferenciasUsuario prefs = PreferenciasUsuario();
    _cliente = prefs.clienteModel;
    if(!isChecked){
      _saving = false;
      if (mounted) setState(() {});
      utils.mostrarSnackBar(context, "Aceptar Términos y Condiciones", milliseconds : 3000000);
      return;
    }
    if (formkey.currentState.validate()) {
      formkey.currentState.save();
      _registromotoProvider.registrarmotos("M",marcaValue.toString(),modeloValue.toString(),placaValue.toString(),infoValue.toString(),
      dniValue.toString(),imagenLicencia, _cliente, (tipo) {
        if (tipo == 1) {
          _saving = false;
          utils.mostrarSnackBar(context, "Solicitud enviada !", milliseconds : 4000000);
          Navigator.pop(context);
          Navigator.pop(context);
          return true;
        } if (tipo == 0){
          _saving = false;
          utils.mostrarSnackBar(context, "Tiene una Solicitud pendiente", milliseconds : 4000000);
          Navigator.pop(context);
          Navigator.pop(context);
          return true;
        }
        else {
          _saving = false;
          if (mounted) setState(() {});
          showDialog(
              context: context,
              builder: (context) =>
                  StatefulBuilder(builder: (context, setState) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius:BorderRadius.all(Radius.circular(25.0))),
                      contentPadding: EdgeInsets.only(top: 50, right: 20, left: 20, bottom: 25),
                      elevation: 0,
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: [
                            const Center(
                              child: Text(
                                'Ya tienes una solicitud enviada',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Aceptar',
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                  shape: StadiumBorder(),
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  backgroundColor: prs.colorMorado,
                                  foregroundColor: prs.colorMorado)),
                        ),
                        SizedBox(
                          height: 15,
                        )
                      ],
                    );
                  }));
        }
      });
    }
    
  }

  var placaFormatter = MaskTextInputFormatter(mask: '###-###', filter: {"#": RegExp(r"[a-zA-Z0-9]")});

  Widget _crearDNI(control) {
    return TextFormField(
        controller: control,
        // keyboardType: TextInputType.number,
        // maxLength: 8,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        textCapitalization: TextCapitalization.characters,
        decoration: prs.decoration('', null),
        onChanged: (value) => dniValue = value,
        // validator: val.validarNumero,
        );
  }

  List<Map<String, dynamic>> _listValues = [
    {
      'value': 'A',
      'label': 'Automovil',
      'icon': Icon(Icons.car_crash_outlined),
      'textStyle': TextStyle(color: Colors.black),
      'enable': true,
    },
    {
      'value': 'M',
      'label': 'Motocicleta',
      'icon': Icon(Icons.motorcycle_rounded),
      'textStyle': TextStyle(color: Colors.black),
      'enable': true,
    },
  ];

  // Widget _crearTipoVehiculo() {
  //   return SelectFormField(
  //     type: SelectFormFieldType.dropdown,
  //     initialValue: "A",
  //     items: _listValues,
  //     onChanged: (value) => tipovehiculoValue = value,
  //   );
  // }

  Widget _crearMarca(control) {
    return TextFormField(
        controller: control,
        maxLength: 90,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        textCapitalization: TextCapitalization.characters,
        decoration: prs.decoration('', null),
        onChanged: (value) => marcaValue = value,
        validator: val.validarMarca);
  }

  Widget _crearModelo(control) {
    return TextFormField(
        controller: control,
        maxLength: 90,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        textCapitalization: TextCapitalization.characters,
        decoration: prs.decoration('', null),
        onChanged: (value) => modeloValue = value,
        validator: val.validarModelo);
  }

  Widget _crearPlaca(control) {
    return TextFormField(
        controller: control,
        inputFormatters: [placaFormatter],
        maxLength: 90,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        textCapitalization: TextCapitalization.characters,
        decoration: prs.decoration('', null),
        onChanged: (value) => placaValue = value,
        validator: val.validarPlaca);
  }

  Widget _crearInfo(control) {
    return TextFormField(
        controller: control,
        // maxLength: 10,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        textCapitalization:TextCapitalization.characters,
        decoration: prs.decoration('', null),
        onChanged: (value) => infoValue = value,
        // validator: val.validarNumeroLicencia
        );
  }
}