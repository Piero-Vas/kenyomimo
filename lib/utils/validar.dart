String validarRePass(String repass,String pass){
  if(repass!=pass) return 'Las contraseñas no coinciden';
  return null;
}

// String validarNombre(String nombre) {
//   String value = nombre.trim();
//   if (value.length < 3) return 'Mínimo 3 caracteres';
//   bool nameValid = RegExp(
//           r"^([A-Za-zÁÉÍÓÚñáéíóúÑ]{0}[A-Za-zÁÉÍÓÚñáéíóúÑ\']+[\s])+([A-Za-zÁÉÍÓÚñáéíóúÑ]{0}?[A-Za-zÁÉÍÓÚñáéíóúÑ\'])+[\s]?([A-Za-zÁÉÍÓÚñáéíóúÑ]{0}?[A-Za-zÁÉÍÓÚñáéíóúÑ\'])+$")
//       .hasMatch(value);
//   if (!nameValid) return 'Nombre inválido';
//   // nameValid = RegExp(r'(.)\1{2}').hasMatch(value);
//   // if (nameValid) return 'Nombre inválido';
//   // var split = value.split(' ');
//   // for (var palabra in split) {
//   //   if (palabra.length <= 1) return 'Nombre inválido';

//   //   nameValid = RegExp(r'[aeiouAEIOUÁÉÍÓÚñáéíóú]').hasMatch(palabra.trim());
//   //   if (!nameValid) return 'Nombre inválido';
//   // }
//   return null;
// }
String validarNombre(String nombre) {
  String value = nombre.trim();
  if (value.length < 3) return 'Mínimo 3 caracteres';
  return null;
}

String validarCorreo(String email) {
  String value = email.trim();
  if (value.length < 8) return 'Mínimo 8 caracteres';
  bool emailValid = RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(value);

  if (!emailValid) return 'Correo inválido';
  return null;
}

String validarNumero(String email) {
  String value = email.trim();
  if (value.length < 8) return 'Mínimo 8 caracteres';
  bool emailValid = RegExp(r"^[0-9+]").hasMatch(value);
  if (!emailValid) return 'Número inválido';
  return null;
}

String validarDni(String email) {
  String value = email.trim();
  if (value.length < 2) return 'Mínimo 1 caracteres';
  return null;
}

String validarDireccion(String email) {
  String value = email.trim();
  if (value.length < 3) return 'Mínimo 3 caracteres';
  return null;
}

String validarNombreLocal(String email) {
  String value = email.trim();
  if (value.length < 5) return 'Mínimo 5 caracteres';
  return null;
}

String validarPlaca(String email) {
  String value = email.trim();
  if (value.length < 7) return 'Mínimo 6 caracteres';
  bool emailValid = RegExp(
          r"^[A-Z0-9]")
      .hasMatch(value);

  if (!emailValid) return 'Solo Mayúsculas';
  return null;
}

String validarMarca(String email) {
  String value = email.trim();
  if (value.length < 3) return 'Mínimo 3 caracteres';
  bool emailValid = RegExp(
          r"^[A-Z]")
      .hasMatch(value);

  if (!emailValid) return 'Solo Mayúsculas';
  return null;
}
String validarModelo(String email) {
  String value = email.trim();
  if (value.length < 3) return 'Mínimo 3 caracteres';
  bool emailValid = RegExp(
          r"^[A-Z]")
      .hasMatch(value);

  if (!emailValid) return 'Solo Mayúsculas';
  return null;
}

String validarNumeroLicencia(String email) {
  String value = email.trim();
  if (value.length < 8) return 'Mínimo 8 caracteres';
  bool emailValid = RegExp(
          r"^[A-Z0-9]")
      .hasMatch(value);

  if (!emailValid) return 'Solo Mayúsculas';
  return null;
}


String validarMinimo8(String email) {
  String value = email.trim();
  if (value.length < 8) return 'Mínimo 8 caracteres';
  return null;
}

String validarMinimo6(String text) {
  String value = text.trim();
  if (value.length < 6) return 'Mínimo 6 caracteres';
  return null;
}

String validarMinimo3(String email) {
  String value = email.trim();
  if (value.length < 3) return 'Mínimo 3 caracteres';
  return null;
}

String validarMinimo10(String email) {
  String value = email.trim();
  if (value.length < 10) return 'Mínimo 10 caracteres';
  return null;
}

String validarMonto(String value) {
  value = value.trim();
  value = value.replaceFirst(',', '.');
  if (value.length < 1) return 'Monto incorrecto';
  bool emailValid = RegExp(r"^[0-9+]").hasMatch(value);
  if (!emailValid) return 'Monto incorrecto';
  try {
    double.parse(value).toStringAsFixed(2);
  } catch (err) {
    return 'Monto incorrecto';
  }
  return null;
}
