import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mimo/pages/planck/seleccion_page.dart';
import 'package:mimo/pagesTaxis/conductor/map_screen.dart';
import 'package:mimo/pagesTaxis/pasajeros/select_services_page.dart';
import 'package:mimo/utils/personalizacion.dart' as prs;
import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import '../model/cliente_model.dart';
import '../pages/admin/compras_cajero_page.dart';
import '../pages/delivery/catalogo_page.dart';
import '../pages/delivery/compras_despacho_page.dart';
import '../providers/cliente_provider.dart';
import '../sistema.dart';
import '../utils/permisos.dart' as permisos;

final _clienteProvider = ClienteProvider();

autenticarFacebook(BuildContext context, String codigoPais, String smn,
    Function response) async {
  FocusScope.of(context).requestFocus(FocusNode());

  try {
    final facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);
    switch (result.status) {
      case FacebookLoginStatus.success:
        final graphResponse = await http.get(Uri.parse('https://graph.facebook.com/v2.12/me?fields=first_name,last_name,email&access_token=${result.accessToken.token}'));
        final profile = json.decode(graphResponse.body);
        QuerySnapshot documentSnapshot = await FirebaseFirestore.instance.collection('client').where("correo",isEqualTo: profile['email']).limit(1).get();
        if (documentSnapshot.size < 1){
           ClienteModel clienteModel = ClienteModel();
          clienteModel.apellidos = profile['last_name'];
          clienteModel.nombres =  profile['first_name'];
          clienteModel.img = "https://graph.facebook.com/${profile['id']}/picture?type=large";
          clienteModel.correo = profile['email'];
          clienteModel.idCliente = profile['id'];
          
          return response(null,clienteModel);
        }
        _clienteProvider.autenticarFacebook(
            codigoPais,
            smn,
            profile['email'],
            profile['id'],
            profile['first_name'],
            profile['last_name'], (estado, clienteModel) {
          if (estado == 0) return response(false,null);
          
          ingresar(context, clienteModel);
          return response(true);
        });
        facebookLogin.logOut();
        break;
      default:
        
        return response(false,null);
    }
  } catch (err) {
    print(err);
    return response(false,null);
  }
}

Future<bool> autenticarApple(BuildContext context, String codigoPais, String smn) async {
  FocusScope.of(context).requestFocus(FocusNode());
  final AuthorizationResult result = await TheAppleSignIn.performRequests([
    AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
  ]);
  switch (result.status) {
    case AuthorizationStatus.authorized:
      bool respuesta = await _clienteProvider.autenticarApple(
          codigoPais,
          smn,
          result.credential.email.toString(),
          result.credential.user.toString(),
          result.credential.fullName.givenName.toString(),
          result.credential.fullName.familyName.toString(),
          (estado, clienteModel) {
        if (estado == 0) return;
        ingresar(context, clienteModel);
      });
      return respuesta;
    case AuthorizationStatus.error:
    case AuthorizationStatus.cancelled:
    default:
      
      return false;
  }
}

Future<bool> autenticarGoogle(
    BuildContext context,
    GoogleSignIn googleSignIn,
    String codigoPais,
    String smn,
    correo,
    img,
    idGoogle,
    nombres,
    apellidos) async {
  FocusScope.of(context).requestFocus(FocusNode());
  await _clienteProvider.autenticarGoogle(
      codigoPais,
      smn,
      correo,
      img.toString().replaceAll('=s96-c', ''),
      idGoogle,
      '$nombres',
      '$apellidos', (estado, clienteModel) {
    googleSignIn.signOut();
    if (estado == 0)
      return; //En caso de error lo registramos con el formulario lleno;
    ingresar(context, clienteModel);
  });
  return false;
}

ingresar(BuildContext context, ClienteModel clienteModel) {
  
  if (Sistema.isWeb) {
    String routeName = '';
    if (clienteModel.perfil == "1") {
      routeName = 'compras_cajero';
    } else if (clienteModel.perfil == "2") {
      routeName = 'compras_despacho';
    }
    Navigator.pushNamed(context, routeName);
  } else {
    
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => SeleccionPage()),
          (Route<dynamic> route) {
        return false;
      });
     
      
      return;
    }
}

autlogin(BuildContext context, {bool isRedirec: false}) async {
  final ClienteModel _cliente = await permisos.ingresar();
  ingresar(context, _cliente);
  return;
}

Widget buttonGoogle(String text, Icon icon, Function onPressed) {
  return RawMaterialButton(
    onPressed: onPressed,
    child: icon,
    shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: prs.colorBotones,
                    width: 1.0,
                    style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(50.0)),
    elevation: 1.0,
    fillColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
  );
}

Widget buttonFacebook(String text, Icon icon, Function onPressed) {
  return RawMaterialButton(
    onPressed: onPressed,
    child: icon,
    shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: prs.hexToColor('#1977F3'),
                    width: 1.0,
                    style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(50.0)),
    elevation: 1.0,
    fillColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
  );
}

Widget buttonApple(String text, Icon icon, Function onPressed) {
  return RawMaterialButton(
    onPressed: onPressed,
    child: icon,
    shape: CircleBorder(),
    elevation: 1.0,
    fillColor: Colors.black,
    padding: const EdgeInsets.all(13.0),
  );
}