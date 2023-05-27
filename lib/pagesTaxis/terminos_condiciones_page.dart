import 'package:flutter/material.dart';
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;

class TerminosCondicionesPage extends StatefulWidget {
  const TerminosCondicionesPage({Key key}) : super(key: key);

  @override
  State<TerminosCondicionesPage> createState() =>
      _TerminosCondicionesPageState();
}

class _TerminosCondicionesPageState extends State<TerminosCondicionesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // foregroundColor: Colors.transparent,
        elevation: 0,
        leading: utils.leadingTaxi(context, prs.colorMorado),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              labels(TextAlign.center, 'TERMINOS Y CONDICIONES GENERALES MIMO',
                  30.0, 'GoldplayBlack'),
              labels(
                  TextAlign.justify,
                  'INVERSIONES NAVEROS  S.A.C. es una sociedad anónima cerrada constituida conforme a las leyes de la República del Perú, con RUC  N° 20608720589, con domicilio AV 26 de noviembre N° 2342, distrito de villa maria del triunfo, provincia y departamento de Lima, responsable de este sitio web, pone a su disposición de los usuarios el presente documento con la finalidad de proporcionar las condiciones de uso del servicio.',
                  16.0,
                  'GoldplayRegular'),
              labels(
                  TextAlign.start,
                  'INVERSIONES NAVEROS S.A.C, en adelante MIMO',
                  20.0,
                  'GoldplayRegular',
                  fontw: FontWeight.w700),
              labels(
                  TextAlign.justify,
                  '''Mediante el acceso y uso de la plataforma Mimo, manifiesta cumplir y a la vez estar vinculado jurídicamente a estos términos y condiciones aplicables al servicio o negocio, de esa manera entablan la relación contractual.

El usuario que acceda o use la plataforma o algún servicio, lo podrá hacer siempre sujetándose a los presentes términos y condiciones y demás políticas de privacidad que establezca mimo.

Se podrán aplicar condiciones adicionales a determinados Servicios, cuando se dé un servicio extra a lo ya establecido o para alguna promoción que se establezca; asimismo se hará un comunicado previo de estas condiciones de acuerdo a la promoción o servicio que se implemente, o en todo caso se subirá directamente a la plataforma. Las condiciones adicionales se establecen además de las Condiciones, y se considerarán una parte de estas, para los fines de los Servicios aplicables. Las condiciones adicionales primaran sobre las Condiciones en el caso de conflicto con respecto a los Servicios aplicables.

MIMO podrá modificar las condiciones cuando sea necesario u oportuno. Estas modificaciones se harán efectivas después de la publicación de las mismas.

Si los usuarios tuvieran alguna duda de estos términos y condiciones descritos se pueden comunicar a nuestro equipo de atención al cliente o al correo de.

El usuario solo utilizará el Servicio para su uso personal y no tendrá facultades para revender su Cuenta a un tercero.

El usuario no autorizará a terceros a usar su Cuenta.

El usuario no cederá ni transferirá de otro modo su Cuenta a ninguna otra persona o entidad legal.

El usuario no tratará de dañar el Servicio o la Plataforma MIMO de ningún modo, ni accederá a recursos restringidos en la misma.

Asimismo, mimo se reserva el derecho de negarse a prestar los servicios al usuario o negar al Usuario el uso del sitio sin causa alguna, si el usuario no está de acuerdo con estos términos y

Los Servicios y productos solo estarán disponible para usuarios que tengan capacidad legal para contratar. No podrán hacer uso de los servicios las personas que no lo tengan como   o menores de edad sin autorización de sus padres o tutor o Usuarios que hayan sido suspendidos temporalmente o inhabilitados definitivamente.''',
                  16.0,
                  'GoldplayRegular'),
              
              labels(TextAlign.start, 'REGISTRO', 20.0, 'GoldplayRegular',
                  fontw: FontWeight.w700, decoration: TextDecoration.underline),
                  labels(
                  TextAlign.justify,
                  '''Para poder dar uso de nuestra plataforma u alguno de sus servicios, el usuario deberá registrarse y tener su cuenta activa, además el usuario debe asegurarse y garantizar la veracidad de los datos ingresados, en ningún caso Mimo se hace responsable por la certeza de los datos.

La cuenta creada es única e intransferible, está totalmente prohibido que el usuario registre más de una cuenta''',
                  16.0,
                  'GoldplayRegular'),
                  labels(TextAlign.start, 'SERVICIOS', 20.0, 'GoldplayRegular',
                  fontw: FontWeight.w700, decoration: TextDecoration.underline),
                  labels(
                  TextAlign.justify,
                  'Los Servicios constituyen una plataforma de tecnología que permite a los usuarios de aplicaciones móviles de MIMO o páginas web proporcionadas como parte de los Servicios (cada una, una “Aplicación”) organizar y planear el transporte, delivery de comida y/o servicios de logística con terceros proveedores independientes de dichos servicios, incluidos terceros transportistas independientes, terceros repartidores y terceros proveedores logísticos independientes, conforme a un acuerdo con MIMO o algunos afiliados de MIMO (“Terceros proveedores”). A no ser que Mimo lo acepte mediante un contrato separado por escrito con usted, los Servicios se ponen a disposición sólo para su uso personal, no comercial. USTED RECONOCE QUE MIMO NO PRESTA SERVICIOS DE TRANSPORTE, DELIVERY O DE LOGÍSTICA O FUNCIONA COMO UNA EMPRESA DE TRANSPORTES Y QUE DICHOS SERVICIOS DE TRANSPORTE O LOGÍSTICA SE PRESTAN POR TERCEROS CONTRATISTAS INDEPENDIENTES, QUE NO ESTÁN EMPLEADOS POR MIMO NI POR NINGUNA DE SUS AFILIADAS.',
                  16.0,
                  'GoldplayRegular'),
                  labels(TextAlign.start, 'PAGO', 20.0, 'GoldplayRegular',
                  fontw: FontWeight.w700, decoration: TextDecoration.underline),
                  labels(
                  TextAlign.justify,
                  '''El uso de los servicios sea de movilidad, delivery y/o logísticos que reciba de un tercer proveedor, derivará de cargos al usuario correspondientes al servicio u bien recibido. El pago se realizará a través del método de pago ingresado y elegido por el usuario en la plataforma del aplicativo, el pago realizado por el usuario de los servicios obtenidos se considera como el pago efectuado directamente al tercero.; asimismo los precios para los servicios de movilidad u delivery u otros, pueden cambiar periódicamente esto en función de la oferta y la demanda del mercado.

Los pagos incluirán los impuestos aplicables cuando se requiera por ley. Los pagos efectuados por el usuario son definitivos y no reembolsables, a menos que MIMO determine lo contrario.

Este pago realizado debe compensar por los servicios, delivery u otros brindados por el tercero proveedor. MIMO no será responsable de ningún error cometido por los proveedores de servicios de pago electrónico o por los bancos.

Si se determina que el método de pago seleccionado por el usuario esta vencido, no es válido, o no cuenta con fondos suficientes para cubrir el pago del servicio u delivery solicitado, el usuario acepta que MIMO realice el cobro de todos los cargos aplicables a cualquier otra tarjeta u método de pago registrado.

Después que el usuario haya realizado el pago correspondiente a su pedido y/o servicio, MIMO, emitirá el resumen de la transacción con la tarifa cobrada, esto como un comprobante de pago, sin embargo, no será considerada para efectos tributarios.''',
                  16.0,
                  'GoldplayRegular'),
                  labels(TextAlign.start, 'PASARELLA DE PAGOS', 20.0, 'GoldplayRegular',
                  fontw: FontWeight.w700,),
                  labels(
                  TextAlign.justify,
                  '''Nuestro aplicativo cuenta con la psarella de pagos de Openpay BBVA, Ellos nos proporcionan la plataforma de comercio electronico en linea que nos permite ser intermediarios de los productos y servicios que nos pueden adquirir por medio de nuestra plataforma.''',
                  16.0,
                  'GoldplayRegular'),
                  labels(TextAlign.start, 'MODIFICACIONES', 20.0, 'GoldplayRegular',
                  fontw: FontWeight.w700,),
                  labels(
                  TextAlign.justify,
                  '''Mimo podrá dar por terminado los presentes términos y condiciones o cualquier servicio con respecto al usuario, o en general, dejar de dar o negar el acceso a la plataforma, si mimo considera que el usuario ha incurrido cualquier incumplimiento.''',
                  16.0,
                  'GoldplayRegular'),
                  labels(TextAlign.start, 'ATENCION AL CLIENTE', 20.0, 'GoldplayRegular',
                  fontw: FontWeight.w700,),
                  labels(
                  TextAlign.justify,
                  '''Si el Usuario tiene alguna duda respecto de los Términos y Condiciones, Política de Privacidad, uso de la Plataforma o de su Perfil, podrá ponerse en contacto con MIMO vía.

  Correo electrónico:  soporte@mimoperu.com

  WhatsApp: +51 954 200 828

Además, disponemos de nuestras oficinas ubicadas en  AV 26 de noviembre N° 2342, distrito de villa maria del triunfo, provincia y departamento de Lima.''',
                  16.0,
                  'GoldplayRegular'),
                  labels(TextAlign.start, 'CANCELACIONES Y DEVOLUCIONES', 20.0, 'GoldplayRegular',
                  fontw: FontWeight.w700,),
                  labels(
                  TextAlign.justify,
                  '''Una vez enviada la solicitud del pedido y/o conductor, el usuario podrá cancelar sin penalidad alguna, solo si la cancelación se realiza a través de la plataforma MIMO antes que el comercio “tienda” comience a preparar el pedido, o antes que tienda u comercio acepte la orden, o antes que el conductor acepte el servicio. Asimismo, el pedido será visualizado directamente por el usuario a través de la plataforma MIMO.

Si el usuario no efectúa la cancelación en el tiempo estipulado, el usuario estará obligado a abonar el monto total del pedido, esto incluye el monto correspondiente al pago del servicio de reparto y el monto total de los productos solicitados, asimismo el usuario tiene la disposición de luego hacer la devolución del producto directamente con el comercio, el mismo que se regirá con las políticas y reglas del comercio.

Si el usuario recibe un pedido equivocado, por favor reportarlo soporte@mimoperu.com, asimismo estos errores están sujetos a las políticas de devolución de cada comercio y su sucursal.

El Usuario en ningún caso podrá alegar falta de conocimiento de las limitaciones, restricciones y penalidades, dado que las mismas son informadas en forma previa a realizar la solicitud del Servicio de delivery y posterior Cancelación a través de la plataforma de MIMO.''',
                  16.0,
                  'GoldplayRegular'),
            ],
          ),
        ),
      ),
    );
  }

  Widget labels(TextAlign textalign, text, tamanio, familia,
      {TextDecoration decoration, FontWeight fontw}) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              textAlign: textalign,
              style: TextStyle(
                  decoration: decoration,
                  fontSize: tamanio,
                  fontFamily: familia,
                  fontWeight: fontw,
                  color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
