import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../bloc/card_bloc.dart';
import '../../bloc/carrito_bloc.dart';
import '../../bloc/direccion_bloc.dart';
import '../../bloc/promocion_bloc.dart';
import '../../dialog/carrito_dialog.dart';
import '../../dialog/direccion_dialog.dart';
import '../../model/cajero_model.dart';
import '../../model/card_model.dart';
import '../../model/direccion_model.dart';
import '../../model/promocion_model.dart';
import '../../preference/db_provider.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cajero_provider.dart';
import '../../providers/compra_provider.dart';
import '../../sistema.dart';
import '../../utils/button.dart' as btn;
import '../../utils/conf.dart' as config;
import '../../utils/dialog.dart' as dlg;
import '../../utils/navegar.dart' as navegar;
import '../../utils/permisos.dart' as permisos;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../widgets/carrito_widget.dart';
import '../planck/direccion_page.dart';

class AyudaPage extends StatefulWidget {
  @override
  _AyudaPageState createState() => _AyudaPageState();
}

class _AyudaPageState extends State<AyudaPage> {
  List<PromocionModel> promociones;
  List<CajeroModel> cajeros = [];

  bool _saving = false;

  double costoTotal = 0.0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DireccionModel direccionSeleccionada = DireccionModel();

  @override
  void initState() {
    super.initState();
  }


  bool _radar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        title: Text('Ayuda',
            style: TextStyle(
                color: prs.colorGrisOscuro,
                fontSize: 17,
                fontFamily: 'GoldplayRegular',
                fontWeight: FontWeight.w800)),
        leading: utils.leading(context),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Center(
            child: Container(
          padding: EdgeInsets.all(20),
          child: _body(),
          width: prs.anchoFormulario,
          decoration: BoxDecoration(color: Colors.white),
        )),
      ),
    );
  }
 bool _customIcon1 = false;
  Widget _body() {
    
    return Column(children: <Widget>[
      Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
              child: Column(
                
                children: [
                  prs.titulo('ASISTENCIA'),
                  SizedBox(height: 15,),
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: prs.colorGrisBordes), borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        expands('Los conductores no responden','soporte@mimoperu.com',_customIcon1),
                        Divider(thickness: 1, color: prs.colorGrisBordes,),
                        expands('Dejarle un comentario a un conductor','soporte@mimoperu.com',_customIcon1),
                        Divider(thickness: 1, color: prs.colorGrisBordes,),
                        expands('Quejarse','soporte@mimoperu.com',_customIcon1),
                        Divider(thickness: 1, color: prs.colorGrisBordes,),
                        expands('Encontrar pertenencias que olvidé','soporte@mimoperu.com',_customIcon1),
                        Divider(thickness: 1, color: prs.colorGrisBordes,),
                        expands('Cómo usar el servicio de repartidores','Ubica el destino de llegada, selecciona la opción de envíos posterior a ello seleccione el tipo de vehículo y tipo de pago al final ultimo especifique o detalle el envió. ',_customIcon1),
                        SizedBox(height: 10,)
                      ],
                    ),
                  )
                  ,SizedBox(height: 25,),
                  prs.titulo('RETROLIMENTACIÓN'),
                  SizedBox(height: 15,),
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: prs.colorGrisBordes), borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        expands('Escribir al equipo de soporte','soporte@mimoperu.com',_customIcon1),
                        Divider(thickness: 1, color: prs.colorGrisBordes,),
                        expands('Escribir al correo electrónico','soporte@mimoperu.com',_customIcon1),
                         SizedBox(height: 10,)
                      ],
                    ),
                  )
                  
      ])))
    ]);
  }

 Widget expands(String title,String descripcion, bool _customIcon){
    return Container(
    child: ExpansionTile(
    title: Text(
      title,style: TextStyle(fontSize: 18, fontFamily: 'GoldplayRegular', fontWeight: FontWeight.bold,color: Colors.black),
    ),
    trailing: Icon(Icons.arrow_forward_ios,size: 30,color: Colors.red,),
    children: <Widget>[
      Container(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(child:  GestureDetector(
                                 onLongPress: () {
                      Clipboard.setData(new ClipboardData(text: descripcion));
                    utils.mostrarSnackBar(context, "Texto Copiado",milliseconds: 1000000);
                    },

                                child: Text(descripcion,style: TextStyle(fontSize: 16, fontFamily: 'GoldplayRegular',color: Colors.black),)
                              ),  ),
          ],
        ),
      ),
    ],
  ),
  );
  }
 
  

}
