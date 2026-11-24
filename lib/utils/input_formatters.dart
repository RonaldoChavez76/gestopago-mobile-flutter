import 'package:flutter/services.dart';

class ValidacionFormatters {
  ValidacionFormatters._();

  static final TextInputFormatter soloLetras =
      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-zÁÉÍÓÚáéíóúÑñÜü ]'));
  static final TextInputFormatter fechaIso =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]'));
  static final TextInputFormatter sinEspacios =
      FilteringTextInputFormatter.deny(RegExp(r'\s'));
  static final TextInputFormatter soloDigitos = FilteringTextInputFormatter.digitsOnly;
  static final TextInputFormatter decimal =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'));
  static final TextInputFormatter curp =
      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'));
  static final TextInputFormatter rfc =
      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9&Ññ]'));
  static final TextInputFormatter ocupacion =
      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-zÁÉÍÓÚáéíóúÑñÜü.\-/ ]'));
  static final TextInputFormatter empresa =
      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-zÁÉÍÓÚáéíóúÑñÜü0-9.,&\-/ ]'));
  static final TextInputFormatter calle =
      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-zÁÉÍÓÚáéíóúÑñÜü0-9.,#\-/ ]'));
  static final TextInputFormatter colonia =
      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-zÁÉÍÓÚáéíóúÑñÜü0-9.\- ]'));
  static final TextInputFormatter lugar =
      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-zÁÉÍÓÚáéíóúÑñÜü.\- ]'));
  static final TextInputFormatter numeroDomicilio =
      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-/]'));
}
