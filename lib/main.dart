import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mimo/Core/ProviderModels/MapModel.dart';
import 'package:mimo/Core/ProviderModels/map_provider.dart';
import 'package:mimo/pages/planck/actualizar_playstore.dart';
import 'package:mimo/pages/planck/ayuda_page.dart';
import 'package:mimo/pages/planck/cambio_pass_page.dart';
import 'package:mimo/pages/planck/categorias_page.dart';
import 'package:mimo/pages/planck/datos_adicionales_page.dart';
import 'package:mimo/pages/planck/email2_page.dart';
import 'package:mimo/pages/planck/email_page.dart';
import 'package:mimo/pages/planck/ingresa_telf_page.dart';
import 'package:mimo/pages/planck/login2_page.dart';
import 'package:mimo/pages/planck/mi_delivery_page.dart';
import 'package:mimo/pages/planck/nueva_pass_page.dart';
import 'package:mimo/pages/planck/recuperar_pass_page.dart';
import 'package:mimo/pages/planck/seleccion_page.dart';
import 'package:mimo/pages/planck/presentacion_page.dart';
import 'package:mimo/pages/planck/revisar_correo_page.dart';
import 'package:mimo/pages/planck/ser_moto_page.dart';
import 'package:mimo/pages/planck/subcategorias_page.dart';
import 'package:mimo/pages/planck/verificar_telf_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mimo/pages/planck/filtro_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:mimo/pagesTaxis/ayuda_taxi_page.dart';
import 'package:mimo/pagesTaxis/conductor/calificaciones_page.dart';
import 'package:mimo/pagesTaxis/conductor/map_screen.dart';
import 'package:mimo/pagesTaxis/conductor/pagos_page.dart';
import 'package:mimo/pagesTaxis/conductor/solicitudes_page.dart';
import 'package:mimo/pagesTaxis/pasajeros/calificacion_page.dart';
import 'package:mimo/pagesTaxis/pasajeros/metodo_pago_taxi_page.dart';
import 'package:mimo/pagesTaxis/pasajeros/referidos_page.dart';
import 'package:mimo/pagesTaxis/pasajeros/select_services_page.dart';
import 'package:mimo/pagesTaxis/pasajeros/ser_conductor_page.dart';
import 'package:mimo/pagesTaxis/pasajeros/terminos_condiciones_conductor.dart';
import 'package:mimo/pagesTaxis/pasajeros/viajes_page.dart';
import 'package:mimo/pagesTaxis/perfil_taxi_edit_page.dart';
import 'package:mimo/pagesTaxis/perfil_taxi_page.dart';
import 'package:mimo/pagesTaxis/prueba.dart';
import 'package:mimo/pagesTaxis/sobre_app_page.dart';
import 'package:mimo/pagesTaxis/terminos_condiciones_page.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';


import './sistema.dart';
import './utils/permisos.dart' as permisos;
import './utils/personalizacion.dart' as prs;
import './utils/utils.dart' as utils;
import 'pages/admin/agencia_page.dart';
import 'pages/admin/compras_cajero_page.dart';
import 'pages/admin/sucursales_page.dart';
import 'pages/admin/ventas_page.dart';
import 'pages/delivery/carrito_page.dart';
import 'pages/delivery/catalogo_page.dart';
import 'pages/delivery/compras_cliente_page.dart';
import 'pages/delivery/compras_despacho_page.dart';
import 'pages/planck/about_page.dart';
import 'pages/planck/contacto_page.dart';
import 'pages/planck/contrasenia_page.dart';
import 'pages/planck/direcciones_page.dart';
import 'pages/planck/facturas_page.dart';
import 'pages/planck/notificacion_page.dart';
import 'pages/planck/perfil_page.dart';
import 'pages/planck/preregistro_page.dart';
import 'pages/planck/puntos_page.dart';
import 'pages/planck/sessiones_page.dart';
import 'preference/intent_share.dart';
import 'preference/push_provider.dart';
import 'preference/shared_preferences.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';


void main() async {
  final GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = false;
  }
  WidgetsFlutterBinding.ensureInitialized();
  Wakelock.enable();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PreferenciasUsuario().init();
  final prefs = PreferenciasUsuario();
  await utils.getDeviceDetails();
  IntentShare().initIntentShare();
  PushProvider();
  if (prefs.idCliente == '' || prefs.idCliente == Sistema.ID_CLIENTE) {
    await permisos.ingresar();
  }else{
    
    await permisos.validarActivoCliente();
  }
  try {
    prefs.simCountryCode = await FlutterSimCountryCode.simCountryCode;
  } catch (exception) {
    prefs.simCountryCode = 'PE';
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _prefs = PreferenciasUsuario();

  @override
  Widget build(BuildContext context) {
    String ruta = 'seleccion';
    if (_prefs.mustUpdate) {
      ruta = 'actualizacion';
    }
    else if (_prefs.auth == '' || _prefs.auth=='/LKHJGASLJKHG/97647/LKHGJH/LKGJLH' || _prefs.activoCliente == true) {
      ruta = 'principal';
    } else {
          ruta = 'seleccion';
      
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MapModel>(
          create: (context) => MapModel(),
        ),
        ChangeNotifierProvider.value(value: MapProvider())
      ],
      child: MaterialApp(
        title: Sistema.aplicativoTitle,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [const Locale('es', 'ES')],
        locale: Locale('es', 'ES'),
        initialRoute: ruta,
        debugShowCheckedModeBanner: Sistema.isTestMode,
        routes: {
          '': (BuildContext context) => PresentacionPage(),
          'principal': (BuildContext context) => Login2Page(),
          'compras_cliente': (BuildContext context) => ComprasClientePage(),
          'direcciones_cliente': (BuildContext context) => DireccionesPage(),
          'facturas_cliente': (BuildContext context) => FacturasPage(),
          'carrito': (BuildContext context) => CarritoPage(),
          'compras_cajero': (BuildContext context) => ComprasCajeroPage(),
          'compras_despacho': (BuildContext context) => ComprasDespachoPage(),
          'contrasenia': (BuildContext context) => ContraseniaPage(),
          'perfil': (BuildContext context) => PerfilPage(),
          'contacto': (BuildContext context) => ContactoPage(),
          'puntos': (BuildContext context) => PuntosPage(),
          'sessiones': (BuildContext context) => SessionesPage(),
          'about': (BuildContext context) => AboutPage(),
          'sucursales': (BuildContext context) => SucursalesPage(),
          'catalogo2': (BuildContext context)=> CatalogoPage(isDeeplink: true,),
          'catalogo': (BuildContext context) => PresentacionPage(),
          'preregistro': (BuildContext context) => PreRegistroPage(),
          'ventas': (BuildContext context) => VentasPage(),
          'agencia': (BuildContext context) => AngenciaPage(),
          'notificacion': (BuildContext context) => NotificacionPage(),
          'presentacion': (BuildContext context) =>PresentacionPage(),
          'revisar_correo': (BuildContext context) => RevisaCorreoPage(),
          'seleccion': (BuildContext context) => SeleccionPage(),
          'cambio_pass': (BuildContext context) => CambioPassPage(),
          'delivery': (BuildContext context) => MiDeliveryPage(),
          'email': (BuildContext context) => EmailPage(),
          'email2': (BuildContext context) => Email2Page(),
          'recuperarpass':(BuildContext context) =>RecuperarPassPage(),
          'nueva_pass':(BuildContext context) =>NuevaPassPage(),
          'ingresa_telf':(BuildContext context) =>IngresaTelfPage(),
          'verifica_telf':(BuildContext context) =>VerificarTelfPage(),
          'datos_adicionales':(BuildContext context) =>DatosAdicionalesPage(),
          'filtro': (BuildContext context) => FiltroPage(),
          'sermoto':(BuildContext context) =>SerMotoPage(),
          //Taxis
          'taxis':(BuildContext context) =>SelectService(),
          'viajes':(BuildContext context) =>ViajesPage(),
          'referidos':(BuildContext context) =>ReferidosPage(),
          'cards_taxi':(BuildContext context) =>MetodoPagoTaxi(),
          'solicitudes':(BuildContext context) =>MapScreen(),
          'serconductor':(BuildContext context) =>SerConductorPage(),

          'pagos':(BuildContext context) =>PagosPage(),
          'calificacion':(BuildContext context) =>CalificacionPage(),
          'calificaciones':(BuildContext context) =>CalificacionesPage(),
          'perfil_taxi':(BuildContext context) =>PerfilTaxiPage(),
          'edit_perfil_taxi':(BuildContext context) =>EditPerfilTaxiPage(),
          'sobreapp':(BuildContext context) =>SobreAppPage(),
          'terminoscondiciones':(BuildContext context) =>TerminosCondicionesPage(),
          'ayuda':(BuildContext context) =>AyudaPage(),
          'ayudataxi':(BuildContext context) =>AyudaTaxiPage(),

          'categorias':(BuildContext context) =>CategoriasPage(),
          'sub_categorias':(BuildContext context) =>SubCategoriasPage(),

          'actualizacion':(BuildContext context) =>ActualizarPlayStorePage(),
        },
        theme: ThemeData(
            primaryColor: prs.colorAppBar,
            //fontFamily: "GoldplayRegular",
            appBarTheme: AppBarTheme(
                elevation: 0.7, centerTitle: true, color: prs.colorAppBar,iconTheme: IconThemeData(
      color: prs.colorBotones,))),
      ),
    );
  }
}
