import 'package:flutter/material.dart';
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;

class TerminosCondicionesConductor extends StatefulWidget {
  const TerminosCondicionesConductor({Key key}) : super(key: key);

  @override
  State<TerminosCondicionesConductor> createState() => _TerminosCondicionesConductorState();
}

class _TerminosCondicionesConductorState extends State<TerminosCondicionesConductor> {
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
              labels(TextAlign.center, 'TERMINOS Y CONDICIONES CONDUCTORES Y/O MOTORIZADOS',
                  30.0, 'GoldplayBlack'),
              labels(
                  TextAlign.start,
                  'ASPECTOS GENERALES:',
                  20.0,
                  'GoldplayRegular',
                  fontw: FontWeight.w700),
              labels(
                  TextAlign.justify,
                  'Mimo S.A.C. es una sociedad anónima cerrada constituida conforme a las leyes de la República del Perú, identificada con RUC N° 20608720589, con domicilio en Av. 26 de noviembre N° 2342, distrito de Villa María, provincia y departamento de Lima, que para los efectos de los presentes Términos & Condiciones de uso de la Plataforma Mimo se denominará “Mimo”.',
                  16.0,
                  'GoldplayRegular'),
              labels(
                  TextAlign.start,
                  'FUNCIONAMIENTO DE LA PLATAFORMA MIMO:',
                  20.0,
                  'GoldplayRegular',
                  fontw: FontWeight.w700),
              labels(
                  TextAlign.justify,
                  '''La Plataforma Mimo es una herramienta tecnológica que, haciendo uso del internet, facilita la intermediación entre motorizado y/o conductor, Aliados Comerciales y los Usuarios, entendiéndose como el “Servicio de entrega”, a la operación que se concreta entre los sujetos antes mencionados. Dicho Servicio de entrega es ejecutado a través de un contrato de mandato, donde el motorizado y/o actúa como mandatario y el Usuario como mandante en dicha relación. Mimo actúa en todo momento como tercero intermediario entre motorizado y/o conductor, Usuarios y Aliados Comerciales.
Asimismo, los conductores y/o vehículos aceptan y entienden que Mimo no presta servicios de reparto, mensajería, transporte ni logística. Por lo tanto, bajo ninguna circunstancia los motorizados y/o conductores serán considerados empleados por Mimo ni por ninguno de sus afiliados. Los motorizados y/o conductores prestan el Servicio por cuenta y riesgo propio y liberan a Mimo de cualquier responsabilidad que pudiera surgir durante la prestación del Servicio de taxi o de delivery.
Los precios, cantidad, disponibilidad y características de los productos y/o servicios exhibidos en la Plataforma Mimo son determinados directamente por los Aliados Comerciales y no por Mimo.
''',
                  16.0,
                  'GoldplayRegular'),
              
              labels(TextAlign.start, 'ACEPTACIÓN DE LOS TÉRMINOS & CONDICIONES:', 20.0, 'GoldplayRegular',
                  fontw: FontWeight.w700, 
                  // decoration: TextDecoration.underline
                  ),
                  labels(
                  TextAlign.justify,
                  '''El CONDUCTOR Y/O MOTORIZADO reconoce que al momento del uso del aplicativo MIMOPERU está manifestando su aceptación de manera expresa e informada     del contenido de los presentes términos y condiciones en su totalidad, por lo tanto, se obliga irrevocablemente a éstos. Esto quiere decir, que el Conductor y/o Motorizado declara haber leído y entendido todas las condiciones en la Política de Privacidad y en los presentes Términos & Condiciones, manifestando su conformidad y aceptación al registrarse y hacer uso de la Plataforma Mimo.
Los presentes términos y Condiciones son aplicables para todos los conductores MIMO y motorizados MIMO 
Cualquier persona que no acepte o se encuentre en desacuerdo con estos Términos & Condiciones, los cuales tienen un carácter obligatorio y vinculante, deberá abstenerse de utilizar la Plataforma Mimo, asimismo MIMO se reserva el derecho de negarse a permitir el acceso al conductor y/o motorizados que no acepten nuestros términos y condiciones.
Los presentes Términos & Condiciones de Uso de la Plataforma Mimo, regulan la relación contractual entre los Conductores y Motorizados con Mimo; asimismo, los presentes términos y condiciones están sujetos a modificaciones en cualquier momento. El servicio se encuentra dirigido exclusivamente a residentes en la zona de cobertura de Mimo en la República de Perú.  Los conductores y motorizados deben visitar frecuentemente la página web y/o la aplicación de MIMOPERU.       
Si el conductor y/o motorizado elige y utiliza los servicios de MIMOPERU, se considera que el socio ha leído, entiende u acepta todos y cada uno de los términos establecidos en este documento, además de aceptar que los términos y condiciones son vinculantes tanto al conductor como al motorizado.
El conductor y/o motorizado entiende que antes o después de haberle proporcionado su información a MIMO, MIMO se reserva el derecho de no prestarle lo servicios de MIMO por criterios internos de MIMO u otros factores, establecidos por MIMO.
''',
                  16.0,
                  'GoldplayRegular'),
                  labels(TextAlign.start, 'SERVICIOS', 20.0, 'GoldplayRegular',
                  fontw: FontWeight.w700, ),
                  labels(
                  TextAlign.justify,
                  'Los conductores y motorizados aceptan que la empresa no provee servicios de transporte, logísticos, etc. y que los servicios de MIMO son de intermediación. Los servicios de taxi, envíos, delivery, etc., dichos servicios se prestan por terceros contratistas independientes que no son empleados de MIMO. La capacidad del conductor o motorizado en tener que entrar en contacto con un usuario para la prestación del servicio de delivery, de taxi o de envío a través de MIMO, no constituye a MIMO como proveedor de Servicios.Los servicios serán prestados exclusivamente por los conductores y motorizados, quienes serán los responsables plenamente de la prestación de los servicios y la consecuencia que derive de ello',
                  16.0,
                  'GoldplayRegular'),
                  labels(TextAlign.start, 'OBLIGACIONES DEL CONDUCTOR Y/O MOTORIZADO:', 20.0, 'GoldplayRegular',
                  fontw: FontWeight.w700, ),
                  labels(
                  TextAlign.justify,
                  '''Notificar a Mimo respecto de cualquier uso no autorizado de su cuenta al interior de la Plataforma Mimo.
Tendrán que cumplir con todos los requerimientos o condiciones obligatorias que solicite MIMO de acuerdo a ley.
Abstenerse de utilizar la Plataforma Mimo para realizar actos contrarios a la moral, la ley, el orden público, y las buenas costumbres en contra de Mimo, los Repartidores Independientes, Aliados Comerciales, y/o de terceros.
Registrar los métodos de pago de conformidad con el proceso de verificación al interior de la Plataforma Mimo.
Informarse sobre las instrucciones de uso y consumo de los productos solicitados a través de la Plataforma Mimo.
El CONDUCTOR Y/O MOTORIZADO no realizará acciones contrarias a la moral o el orden público incluyendo fumar, beber alcohol, u otras conductas similares al prestar sus servicios. 
El CONDUCTOR Y/O MOTORIZADO no debe realizar conductas que atenten en contra del funcionamiento de la Plataforma Mimo.
El CONDUCTOR Y/O MOTORIZADO debe de tratar respetuosamente a los Repartidores Independientes, al personal del servicio al cliente y a los usuarios.
EL CONDUCTOR Y/O MOTORIZADO no exhibirá o publicará información a ninguna persona y para ningún propósito, toda la información de los usuarios o de otro conductor y/o motorizado, excepto que la información sea recolectada de algún medio que no infrinja las leyes aplicables del Perú.
EL CONDUCTOR Y/O MOTORIZADO, prestarán los servicios solo con los vehículos que se han registrado exitosamente en la plataforma de MIMO.
Ante el incumplimiento de cualquiera de las obligaciones contenidas en la presente sección, Mimo se reserva el derecho de bloquear definitivamente la cuenta del conductor y/o Motorizado en la Plataforma Mimo.
Es obligación del conductor y/o motorizado mantener el software del dispositivo móvil actualizado, MIMO no se hace responsable de los problemas que puedan surgir cuando el conductor y/o motorizado no utilice la versión mas actualizada de MIMO, asimismo MIMO no se hace responsable si el conductor y/o motorizado no utilizan un dispositivo móvil que cumpla con los requisitos necesarios para poder utilizar el aplicativo de MIMO.
''',
                  16.0,
                  'GoldplayRegular'),
                  labels(TextAlign.start, 'PAGO', 20.0, 'GoldplayRegular',
                  fontw: FontWeight.w700,),
                  labels(
                  TextAlign.justify,
                  '''El CONDUCTOR Y/O MOTORIZADO entiende que el uso de los servicios que ofrece MIMO puede derivar en cargos o también entendidas como comisiones por los servicios o bienes que reciba de un tercer proveedor, además incluyendo los cargos por peajes. Los servicios que se usen a través de la plataforma funcionan con un mecanismo que tiene en cuenta una tarifa base y demás aspectos que se le indican al conductor y/o motorizado en el momento del registro, asimismo la tarifa sugerida puede variar dependiendo fechas, la cantidad de demanda o a discreción de MIMO
El conductor deberá transferir y/o depositar a MIMO el monto de las comisiones de los servicios realizados en un plazo máximo de 24 horas después de usar los servicios, de lo contrario MIMO se reserva el derecho de desactivarle el uso del aplicativo.
Los cargos que se hagan por medio de tarjetas de crédito o débito, derivaran directo por la plataforma de cobros de MIMO, quien reembolsara a los conductores y/o motorizados en un plazo máximo de 48 horas.
''',
                  16.0,
                  'GoldplayRegular'),
                  labels(TextAlign.start, 'CANCELACIONES Y RESPONSABILIDAD', 20.0, 'GoldplayRegular',
                  fontw: FontWeight.w700,),
                  labels(
                  TextAlign.justify,
                  '''MIMO sanciona cualquier acción que tuviera el conductor después de aceptar una solicitud recibida a través de MIMO, que el conductor intente incitar al usuario a cancelar la solicitud, MIMO sanciona esas conductas de manera muy estricta, a no ser que el usuario ponga en peligro al conductor.
Los daños y perjuicios derivados de la no prestación del servicio del conductor hacían el usuario serán responsabilidad del conductor. 
Una incitación a cancelación será entendida como un fraude.
Si el conductor realiza más de ocho cancelaciones de solicitudes, automáticamente MIMO dará por bloqueada la cuenta del conductor.
''',
                  16.0,
                  'GoldplayRegular'),
                  labels(TextAlign.start, 'POLÍTICAS DE USO DE LA PLATAFORMA MIMO', 20.0, 'GoldplayRegular',
                  fontw: FontWeight.w700,),
                  labels(
                  TextAlign.justify,
                  '''Mimo tendrá las facultades para denegar o restringir el uso a la Plataforma Mimo a cualquier conductor y/o motorizado en caso de incumplimiento de los presentes Términos & Condiciones, sin que ello genere perjuicio alguno. El CONDUCTOR Y/O MOTORIZADO se compromete a hacer un uso adecuado y lícito de la Plataforma Mimo de conformidad con la legislación aplicable, los presentes Términos & Condiciones, la moral y buenas costumbres generalmente aceptadas y el orden público. Además de las obligaciones de los Usuarios, detalladas en los presentes Términos & Condiciones, al utilizar la Plataforma Mimo el Usuario acuerda que:
No autorizará a terceros a usar su Cuenta.
No cederá ni transferirá de otro modo su Cuenta a ninguna otra persona o entidad legal.
No usará la plataforma con fines ilícitos, ilegales, contrarios a lo establecido en los presentes Términos & Condiciones, a la buena fe y al orden público, lesivos de los derechos e intereses de terceros incluyendo, sin limitación, el transporte de material ilegal o con fines fraudulentos.
El conductor y/o motorizado     no tratará de dañar el Servicio o la Plataforma Mimo de ningún modo, ni accederá a recursos restringidos en la misma.
Guardará de forma segura y confidencial la contraseña de su Cuenta y cualquier identificación facilitada para permitirle acceder al Servicio y la Plataforma Mimo.
El conductor y/o motorizado no utilizará el Servicio o la Plataforma Mimo con un dispositivo incompatible o no autorizado.
No intentará acceder, utilizar y/o manipular los datos de Mimo, motorizados y/o comercios otros Usuarios.
No introducirá ni difundirá virus informáticos o cualesquiera otros sistemas físicos o lógicos que sean susceptibles de provocar daños en la Plataforma Mimo.
Se aclara que, los reclamos o quejas ingresadas por los Usuarios a través del Centro de Ayuda disponible en la Plataforma Mimo y/o el Libro de Reclamaciones, serán atendidos en un plazo no mayor a quince (15) días hábiles.
''',
                  16.0,
                  'GoldplayRegular'),
                  labels(TextAlign.start, 'GARANTÍAS ', 20.0, 'GoldplayRegular',
                  fontw: FontWeight.w700,),
                  labels(
                  TextAlign.justify,
                  '''Los equipos, vehículos o implementos que se usen para la prestación de los servicios deberán tener todos sus componentes y que estos estén funcionando de manera correcta, los conductores y/o motorizados se comprometen a usar de manera adecuada el vehículo o implementos necesarios para su servicio.
Los vehículos o equipos usados por los conductores y/o motorizado deben tener todos sus complementos, limpios, ordenados, sin desgastes, ni malos olores, asimismo los asientos estarán limpios y libres de desgaste que impliquen algún deterioro o pliegue, además de cualquier otro aspecto que este prevista por la ley. 

Los conductores prestaran los servicios de manera que no se ponga en peligro en ningún momento al usuario.
''',
                  16.0,
                  'GoldplayRegular'),
                  labels(TextAlign.start, 'POLÍTICAS DE USO Y GARANTÍA DE LA PLATAFORMA MIMO', 20.0, 'GoldplayRegular',
                  fontw: FontWeight.w700,),
                  labels(
                  TextAlign.justify,
                  '''Mimo como plataforma de navegación, comunica a sus CONDUCTORES Y/O MOTORIZADOS que el aplicativo podría presentar inconvenientes sea para ingresar o para continuar su uso de funcionamiento esto por razones de mantenimiento o motivos que estén fuera del control de MIMO. Cuando surjan estos inconvenientes MIMO actuará a la brevedad tomando las acciones que se encuentren a su alcance para reestablecer el uso adecuado del aplicativo. Asimismo, informa a los CONDUCTORES que deben tomar las precauciones correspondientes, siendo así que MIMO no será responsable por daños o perjuicios que provengan de los siguientes motivos: A) la falta de disponibilidad o accesibilidad a la Plataforma Mimo por las razones antes expuestas; B) la interrupción en el funcionamiento de la Plataforma Mimo o fallos informáticos ajenos al control de Mimo, averías telefónicas, desconexiones, retrasos o bloqueos causados por deficiencias o sobrecargas en las líneas telefónicas, centros de datos, en el sistema de Internet o en otros sistemas electrónicos, producidos en el curso de su funcionamiento; y, C) otros daños que puedan ser causados por terceros mediante intromisiones no autorizadas ajenas al control de MIMO.
MIMO instaura todas las medidas de seguridad que sean necesarias para el funcionamiento óptimo de la plataforma. Sin embargo, como lo expuesto líneas arriba, existen otros factores externos de terceros que pueden dañar la plataforma como virus (ataques cibernéticos) u algún tipo de elemento que introduzcan al aplicativo y cause perjuicio del mismo u alteraciones, como consecuencia de ello MIMO no se hace responsable de los daños y perjuicios que devengan de ellos. 

''',
                  16.0,
                  'GoldplayRegular'),
                  labels(TextAlign.start, 'POLÍTICA DE PROPIEDAD INTELECTUAL ', 20.0, 'GoldplayRegular',
                  fontw: FontWeight.w700,),
                  labels(
                  TextAlign.justify,
                  '''El contenido de la plataforma incluyendo, sin limitación, el software proporcionado, los productos, marcas, logotipos, nombres comerciales, diseños, imágenes, videos, información, música, sonidos y otra propiedad intelectual de cualquier naturaleza e industrias que forme parte del contenido de la aplicación; MIMO y sus afiliados son titulares de los todos los derechos de propiedad intelectual. En consecuencia,
LOS CONDUCTORES Y/O MOTORIZADOS reconoce y acepta que todos los derechos de propiedad intelectual e industrial sobre los contenidos y/o cualesquiera otros elementos insertados en la Plataforma MIMO (incluyendo, sin limitación, marcas, logotipos, nombres comerciales, lemas comerciales textos, imágenes, gráficos, diseños, sonidos, bases de datos, software, diagramas de flujo, presentación, audio y vídeo y/o cualquier otro derecho de propiedad intelectual e industrial de cualquier naturaleza que éstos sean), pertenecen y son de propiedad exclusiva de MIMO. Por lo tanto, MIMO autoriza al CONDUCTOR Y/O MOTORIZADO a utilizar, visualizar, imprimir, descargar y almacenar los contenidos y/o los elementos insertados en la Plataforma MIMO exclusivamente para su uso personal, privado y no lucrativo, absteniéndose de realizar sobre los mismos cualquier acto de descompilación, ingeniería inversa, modificación, divulgación o suministro. Cualquier otro uso o explotación de cualesquiera contenidos y/u otros elementos insertados en la Plataforma MIMO distinto de los aquí expresamente previstos estará sujeto a la autorización previa de MIMO.

Bajo ningún concepto se entenderá que el acceso a la Plataforma MIMO y/o la aceptación de los Términos & Condiciones generar algún derecho de cesión a favor de los CONDUCTORES Y/O MOTORIZADOS ni de cualquier tercero.

''',
                  16.0,
                  'GoldplayRegular'),
                  labels(TextAlign.start, 'PROTECCIÓN DE DATOS PERSONALES ', 20.0, 'GoldplayRegular',
                  fontw: FontWeight.w700,),
                  labels(
                  TextAlign.justify,
                  '''Los datos personales que los CONDUCTORES Y/O MOTORIZADOS proporcionen en el Registro, serán almacenados y tratados según lo dispone la Ley N° 29733, Ley de Protección de Datos Personales, su Reglamento, aprobado mediante Decreto Supremo N° 003-2013-JUS, demás normas conexas y la Política de Privacidad de MIMO y Tratamiento de Datos Personales que aceptan los Usuarios al momento del Registro.

En ese sentido, MIMO se obliga al cumplimiento estricto de las normas anteriormente mencionadas, así como a mantener los estándares máximos de seguridad, protección, resguardo, conservación y confidencialidad de la información recibida o enviada.

Los CONDUCTORES Y/O MOTORIZADOS declaran que los datos personales han sido entregados de forma absolutamente libre y voluntaria, sin ningún tipo de presión, obligación o condición de por medio.

''',
                  16.0,
                  'GoldplayRegular'),
                  labels(TextAlign.start, 'CESIÓN ', 20.0, 'GoldplayRegular',
                  fontw: FontWeight.w700,),
                  labels(
                  TextAlign.justify,
                  '''El CONDUCTOR Y/O MOTORIZADO no podrá ceder sus derechos y obligaciones dimanantes de los presentes Términos & Condiciones sin el previo consentimiento escrito de MIMO. Asimismo, MIMO podrá ceder, sin necesidad de recabar el consentimiento previo del Usuario, los presentes Términos & Condiciones a cualquier entidad comprendida dentro de su grupo de sociedades, en todo el mundo, así como a cualquier persona o entidad que le suceda en el ejercicio de su negocio por cualesquiera títulos.''',
                  16.0,
                  'GoldplayRegular'),
                  labels(TextAlign.start, '  LEY APLICABLE Y JURISDICCIÓN ', 20.0, 'GoldplayRegular',
                  fontw: FontWeight.w700,),
                  labels(
                  TextAlign.justify,
                  '''Los presentes Términos & Condiciones, así como la relación entre MIMO y el CONDUCTOR Y/O MOTORIZADO, se regirán e interpretarán con arreglo a la legislación vigente en la República del Perú.
Los Términos & Condiciones específicos para cada botón que se encuentran descritos a continuación, deberán interpretarse junto con los Términos & Condiciones generales de MIMO, así como con los específicamente desarrollados por MIMO para promociones, campañas y otras actividades que se realicen a través de la plataforma virtual.
''',
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
