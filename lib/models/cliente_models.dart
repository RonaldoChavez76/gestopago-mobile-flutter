class DomicilioPerfil {
  const DomicilioPerfil({
    required this.calle,
    required this.numeroExterior,
    required this.numeroInterior,
    required this.colonia,
    required this.municipio,
    required this.estado,
    required this.codigoPostal,
    required this.pais,
  });

  final String calle;
  final String numeroExterior;
  final String numeroInterior;
  final String colonia;
  final String municipio;
  final String estado;
  final String codigoPostal;
  final String pais;

  factory DomicilioPerfil.fromJson(Map<String, dynamic> json) {
    return DomicilioPerfil(
      calle: (json['calle'] ?? '').toString(),
      numeroExterior: (json['numeroExterior'] ?? '').toString(),
      numeroInterior: (json['numeroInterior'] ?? '').toString(),
      colonia: (json['colonia'] ?? '').toString(),
      municipio: (json['municipio'] ?? '').toString(),
      estado: (json['estado'] ?? '').toString(),
      codigoPostal: (json['codigoPostal'] ?? '').toString(),
      pais: (json['pais'] ?? 'México').toString(),
    );
  }

  Map<String, dynamic> toRequestJson() {
    final interiorLimpio = numeroInterior.trim();
    return {
      'calle': calle.trim(),
      'numeroExterior': numeroExterior.trim(),
      'numeroInterior': interiorLimpio.isEmpty ? null : interiorLimpio,
      'colonia': colonia.trim(),
      'municipio': municipio.trim(),
      'estado': estado.trim(),
      'codigoPostal': codigoPostal.trim(),
      'pais': pais.trim(),
    };
  }
}

class ClientePerfil {
  const ClientePerfil({
    required this.id,
    required this.primerNombre,
    required this.segundoNombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.fechaNacimiento,
    required this.curp,
    required this.rfc,
    required this.sexo,
    required this.nacionalidad,
    required this.estadoCivil,
    required this.correo,
    required this.telefonoMovil,
    required this.telefonoAlternativo,
    required this.ocupacion,
    required this.empresa,
    required this.ingresoMensual,
    required this.activo,
    required this.domicilio,
  });

  final int id;
  final String primerNombre;
  final String segundoNombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String fechaNacimiento;
  final String curp;
  final String rfc;
  final String sexo;
  final String nacionalidad;
  final String estadoCivil;
  final String correo;
  final String telefonoMovil;
  final String telefonoAlternativo;
  final String ocupacion;
  final String empresa;
  final String ingresoMensual;
  final bool activo;
  final DomicilioPerfil domicilio;

  String get nombreCompleto {
    return [primerNombre, segundoNombre, apellidoPaterno, apellidoMaterno]
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .join(' ');
  }

  factory ClientePerfil.fromJson(Map<String, dynamic> json) {
    final domRaw = json['domicilio'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final ingresoRaw = json['ingresoMensual'];
    final ingresoStr = ingresoRaw is num
        ? ingresoRaw.toString()
        : (ingresoRaw ?? '0').toString();

    return ClientePerfil(
      id: (json['id'] as num?)?.toInt() ?? 0,
      primerNombre: (json['primerNombre'] ?? '').toString(),
      segundoNombre: (json['segundoNombre'] ?? '').toString(),
      apellidoPaterno: (json['apellidoPaterno'] ?? '').toString(),
      apellidoMaterno: (json['apellidoMaterno'] ?? '').toString(),
      fechaNacimiento: (json['fechaNacimiento'] ?? '').toString(),
      curp: (json['curp'] ?? '').toString(),
      rfc: (json['rfc'] ?? '').toString(),
      sexo: (json['sexo'] ?? '').toString(),
      nacionalidad: (json['nacionalidad'] ?? 'Mexicana').toString(),
      estadoCivil: (json['estadoCivil'] ?? '').toString(),
      correo: (json['correo'] ?? '').toString(),
      telefonoMovil: (json['telefonoMovil'] ?? '').toString(),
      telefonoAlternativo: (json['telefonoAlternativo'] ?? '').toString(),
      ocupacion: (json['ocupacion'] ?? '').toString(),
      empresa: (json['empresa'] ?? '').toString(),
      ingresoMensual: ingresoStr,
      activo: json['activo'] as bool? ?? true,
      domicilio: DomicilioPerfil.fromJson(domRaw),
    );
  }

  Map<String, dynamic> toActualizarRequestJson() {
    final segundoLimpio = segundoNombre.trim();
    final altLimpio = telefonoAlternativo.trim();
    final ingreso = double.tryParse(ingresoMensual.trim()) ?? 0.0;

    return {
      'primerNombre': primerNombre.trim(),
      'segundoNombre': segundoLimpio.isEmpty ? null : segundoLimpio,
      'apellidoPaterno': apellidoPaterno.trim(),
      'apellidoMaterno': apellidoMaterno.trim(),
      'fechaNacimiento': fechaNacimiento.trim(),
      'sexo': sexo.trim(),
      'nacionalidad': nacionalidad.trim(),
      'estadoCivil': estadoCivil.trim(),
      'correo': correo.trim().toLowerCase(),
      'telefonoMovil': telefonoMovil.trim(),
      'telefonoAlternativo': altLimpio.isEmpty ? null : altLimpio,
      'ocupacion': ocupacion.trim(),
      'empresa': empresa.trim(),
      'ingresoMensual': ingreso,
      'domicilio': domicilio.toRequestJson(),
    };
  }
}

class RegistroClienteSolicitud {
  const RegistroClienteSolicitud({
    required this.perfil,
    required this.password,
  });

  final ClientePerfil perfil;
  final String password;

  Map<String, dynamic> toRequestJson() {
    return {
      ...perfil.toActualizarRequestJson(),
      'curp': perfil.curp.trim().toUpperCase(),
      'rfc': perfil.rfc.trim().toUpperCase(),
      'password': password,
    };
  }
}

class RegistroClienteResultado {
  const RegistroClienteResultado({
    required this.clienteId,
    required this.usuarioId,
    required this.cuentaId,
    required this.numeroCuenta,
    required this.correo,
  });

  final int clienteId;
  final int usuarioId;
  final int cuentaId;
  final String numeroCuenta;
  final String correo;

  factory RegistroClienteResultado.fromJson(Map<String, dynamic> json) {
    return RegistroClienteResultado(
      clienteId: (json['clienteId'] as num?)?.toInt() ?? 0,
      usuarioId: (json['usuarioId'] as num?)?.toInt() ?? 0,
      cuentaId: (json['cuentaId'] as num?)?.toInt() ?? 0,
      numeroCuenta: (json['numeroCuenta'] ?? '').toString(),
      correo: (json['correo'] ?? '').toString(),
    );
  }
}

class ClienteValidacion {
  ClienteValidacion._();

  static final RegExp passwordRegex = RegExp(
    r'^(?!.*\s)(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9]).{8,72}$',
  );
  static final RegExp emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[A-Za-z]{2,}$');
  static final RegExp curpRegex = RegExp(
    r'^[A-Z][AEIOUX][A-Z]{2}[0-9]{6}[HM][A-Z]{5}[A-Z0-9][0-9]$',
    caseSensitive: false,
  );
  static final RegExp rfcRegex = RegExp(
    r'^[A-Z&Ñ]{3,4}[0-9]{6}[A-Z0-9]{3}$',
    caseSensitive: false,
  );
  static final RegExp soloLetrasRegex = RegExp(
    r'^[A-Za-zÁÉÍÓÚáéíóúÑñÜü]+(?: [A-Za-zÁÉÍÓÚáéíóúÑñÜü]+)*$',
  );
  static final RegExp ocupacionRegex = RegExp(
    r'^[A-Za-zÁÉÍÓÚáéíóúÑñÜü.\-/]+(?: [A-Za-zÁÉÍÓÚáéíóúÑñÜü.\-/]+)*$',
  );
  static final RegExp empresaRegex = RegExp(
    r'^[A-Za-zÁÉÍÓÚáéíóúÑñÜü0-9.,&\-/]+(?: [A-Za-zÁÉÍÓÚáéíóúÑñÜü0-9.,&\-/]+)*$',
  );
  static final RegExp calleRegex = RegExp(
    r'^[A-Za-zÁÉÍÓÚáéíóúÑñÜü0-9.,#\-/]+(?: [A-Za-zÁÉÍÓÚáéíóúÑñÜü0-9.,#\-/]+)*$',
  );
  static final RegExp coloniaRegex = RegExp(
    r'^[A-Za-zÁÉÍÓÚáéíóúÑñÜü0-9.\-]+(?: [A-Za-zÁÉÍÓÚáéíóúÑñÜü0-9.\-]+)*$',
  );
  static final RegExp lugarRegex = RegExp(
    r'^[A-Za-zÁÉÍÓÚáéíóúÑñÜü.\-]+(?: [A-Za-zÁÉÍÓÚáéíóúÑñÜü.\-]+)*$',
  );
  static final RegExp numeroDomicilioRegex = RegExp(r'^[A-Za-z0-9\-/]+$');
  static final RegExp referenciaServicioRegex = RegExp(r'^[A-Za-z0-9\-]{4,40}$');
  static final RegExp cuenta16Regex = RegExp(r'^[0-9]{16}$');
  static final RegExp digitosRepetidos10Regex = RegExp(r'^(\d)\1{9}$');

  static DateTime? parsearFechaIsoValida(String fechaIso) {
    final limpio = fechaIso.trim();
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(limpio)) {
      return null;
    }
    final partes = limpio.split('-');
    final anio = int.tryParse(partes[0]);
    final mes = int.tryParse(partes[1]);
    final dia = int.tryParse(partes[2]);
    if (anio == null || mes == null || dia == null) return null;
    final nacimiento = DateTime(anio, mes, dia);
    if (nacimiento.year != anio || nacimiento.month != mes || nacimiento.day != dia) {
      return null;
    }
    return nacimiento;
  }

  static bool esMayorDeEdad(String fechaIso) {
    final nacimiento = parsearFechaIsoValida(fechaIso);
    if (nacimiento == null) return false;
    final hoy = DateTime.now();
    final limite18 = DateTime(hoy.year - 18, hoy.month, hoy.day);
    final limite120 = DateTime(hoy.year - 120, hoy.month, hoy.day);
    return !nacimiento.isAfter(limite18) && !nacimiento.isBefore(limite120);
  }

  static String? validarCorreo(String correo) {
    final limpio = correo.trim();
    if (limpio.length < 6 || limpio.length > 100 || RegExp(r'\s').hasMatch(limpio)) {
      return 'Ingresa un correo electrónico válido sin espacios (6 a 100 caracteres).';
    }
    if (!emailRegex.hasMatch(limpio)) {
      return 'Ingresa un correo electrónico válido.';
    }
    return null;
  }

  static String? validarPassword(String password) {
    if (!passwordRegex.hasMatch(password)) {
      return 'La contraseña requiere 8 a 72 caracteres sin espacios, mayúscula, minúscula, número y símbolo.';
    }
    return null;
  }

  static String? validarTelefono10(String telefono) {
    final limpio = telefono.trim();
    if (!RegExp(r'^\d{10}$').hasMatch(limpio) || digitosRepetidos10Regex.hasMatch(limpio)) {
      return 'El teléfono debe tener exactamente 10 dígitos numéricos válidos.';
    }
    return null;
  }

  static String? validarCuenta16(String cuenta) {
    final limpio = cuenta.trim();
    if (limpio.isEmpty) {
      return 'Ingresa el número de cuenta bancaria.';
    }
    if (!cuenta16Regex.hasMatch(limpio)) {
      return 'La cuenta bancaria debe tener exactamente 16 dígitos numéricos.';
    }
    return null;
  }

  static String? validarReferenciaServicio(String referencia) {
    final limpio = referencia.trim();
    if (limpio.isEmpty) {
      return 'Ingresa la referencia del servicio.';
    }
    if (!referenciaServicioRegex.hasMatch(limpio)) {
      return 'La referencia debe contener de 4 a 40 caracteres alfanuméricos o guión sin espacios.';
    }
    return null;
  }

  static String? _validarNombre(String valor, String etiqueta, {required bool obligatorio}) {
    final limpio = valor.trim();
    if (limpio.isEmpty) {
      return obligatorio ? 'El $etiqueta es obligatorio.' : null;
    }
    if (limpio.length < 2 || limpio.length > 50) {
      return obligatorio
          ? 'El $etiqueta debe tener entre 2 y 50 caracteres.'
          : 'El $etiqueta debe tener entre 2 y 50 caracteres si decides llenarlo.';
    }
    if (!soloLetrasRegex.hasMatch(limpio)) {
      return 'El $etiqueta solo debe contener letras y espacios simples.';
    }
    return null;
  }

  static Map<String, String> validarCamposBase(ClientePerfil datos) {
    final errores = <String, String>{};

    final errPrimer = _validarNombre(datos.primerNombre, 'primer nombre', obligatorio: true);
    if (errPrimer != null) errores['primerNombre'] = errPrimer;

    final errSegundo = _validarNombre(datos.segundoNombre, 'segundo nombre', obligatorio: false);
    if (errSegundo != null) errores['segundoNombre'] = errSegundo;

    final errPaterno = _validarNombre(datos.apellidoPaterno, 'apellido paterno', obligatorio: true);
    if (errPaterno != null) errores['apellidoPaterno'] = errPaterno;

    final errMaterno = _validarNombre(datos.apellidoMaterno, 'apellido materno', obligatorio: true);
    if (errMaterno != null) errores['apellidoMaterno'] = errMaterno;

    final fechaStr = datos.fechaNacimiento.trim();
    if (parsearFechaIsoValida(fechaStr) == null) {
      errores['fechaNacimiento'] =
          'La fecha de nacimiento debe ser válida y usar el formato AAAA-MM-DD.';
    } else if (!esMayorDeEdad(fechaStr)) {
      errores['fechaNacimiento'] = 'Debes tener entre 18 y 120 años para operar en GestoPago.';
    }

    final sexo = datos.sexo.trim();
    if (sexo.isEmpty || sexo.length > 20 || !soloLetrasRegex.hasMatch(sexo)) {
      errores['sexo'] = 'Ingresa un sexo válido (solo letras, máx. 20 caracteres).';
    }

    final nac = datos.nacionalidad.trim();
    if (nac.length < 3 || nac.length > 40 || !soloLetrasRegex.hasMatch(nac)) {
      errores['nacionalidad'] = 'La nacionalidad debe tener entre 3 y 40 letras.';
    }

    final estCiv = datos.estadoCivil.trim();
    if (estCiv.length < 3 || estCiv.length > 30 || !soloLetrasRegex.hasMatch(estCiv)) {
      errores['estadoCivil'] = 'El estado civil debe tener entre 3 y 30 letras.';
    }

    final errCorreo = validarCorreo(datos.correo);
    if (errCorreo != null) {
      errores['correo'] = errCorreo;
    }

    final errMovil = validarTelefono10(datos.telefonoMovil);
    if (errMovil != null) {
      errores['telefonoMovil'] = errMovil;
    }

    final alt = datos.telefonoAlternativo.trim();
    if (alt.isNotEmpty) {
      final errAlt = validarTelefono10(alt);
      if (errAlt != null) {
        errores['telefonoAlternativo'] =
            'El teléfono alternativo debe tener 10 dígitos válidos o permanecer vacío.';
      } else if (alt == datos.telefonoMovil.trim()) {
        errores['telefonoAlternativo'] =
            'El teléfono alternativo debe ser distinto al móvil principal.';
      }
    }

    final ocupacion = datos.ocupacion.trim();
    if (ocupacion.length < 3 || ocupacion.length > 80 || !ocupacionRegex.hasMatch(ocupacion)) {
      errores['ocupacion'] = 'La ocupación debe tener entre 3 y 80 caracteres y no incluir números.';
    }

    final empresa = datos.empresa.trim();
    if (empresa.length < 2 || empresa.length > 100 || !empresaRegex.hasMatch(empresa)) {
      errores['empresa'] = 'La empresa debe tener entre 2 y 100 caracteres válidos.';
    }

    final ingresoStr = datos.ingresoMensual.trim();
    final ingreso = double.tryParse(ingresoStr);
    if (!RegExp(r'^[0-9]+(?:\.[0-9]{1,2})?$').hasMatch(ingresoStr) ||
        ingreso == null ||
        ingreso <= 0 ||
        ingreso > 99999999.99) {
      errores['ingresoMensual'] =
          'El ingreso mensual debe ser positivo con máximo 2 decimales (hasta \$99,999,999.99).';
    }

    final dom = datos.domicilio;
    final calle = dom.calle.trim();
    if (calle.length < 3 || calle.length > 100 || !calleRegex.hasMatch(calle)) {
      errores['domicilio.calle'] = 'La calle debe tener entre 3 y 100 caracteres válidos.';
    }

    final numExt = dom.numeroExterior.trim();
    if (numExt.isEmpty || numExt.length > 20 || !numeroDomicilioRegex.hasMatch(numExt)) {
      errores['domicilio.numeroExterior'] =
          'El número exterior debe tener de 1 a 20 caracteres alfanuméricos sin espacios.';
    }

    final numInt = dom.numeroInterior.trim();
    if (numInt.isNotEmpty && (numInt.length > 20 || !numeroDomicilioRegex.hasMatch(numInt))) {
      errores['domicilio.numeroInterior'] =
          'El número interior debe tener máx. 20 caracteres alfanuméricos sin espacios.';
    }

    final colonia = dom.colonia.trim();
    if (colonia.length < 3 || colonia.length > 80 || !coloniaRegex.hasMatch(colonia)) {
      errores['domicilio.colonia'] = 'La colonia debe tener entre 3 y 80 caracteres válidos.';
    }

    final municipio = dom.municipio.trim();
    if (municipio.length < 3 || municipio.length > 80 || !lugarRegex.hasMatch(municipio)) {
      errores['domicilio.municipio'] =
          'El municipio o alcaldía debe tener entre 3 y 80 caracteres (solo letras).';
    }

    final estado = dom.estado.trim();
    if (estado.length < 2 || estado.length > 60 || !lugarRegex.hasMatch(estado)) {
      errores['domicilio.estado'] = 'El estado debe tener entre 2 y 60 caracteres (solo letras).';
    }

    if (!RegExp(r'^\d{5}$').hasMatch(dom.codigoPostal.trim())) {
      errores['domicilio.codigoPostal'] =
          'El código postal debe tener exactamente 5 dígitos numéricos sin espacios.';
    }

    final pais = dom.pais.trim();
    if (pais.length < 3 || pais.length > 50 || !soloLetrasRegex.hasMatch(pais)) {
      errores['domicilio.pais'] = 'El país debe tener entre 3 y 50 letras.';
    }

    return errores;
  }

  static Map<String, String> validarCamposRegistro(
    ClientePerfil datos, {
    required String password,
    required String confirmarPassword,
  }) {
    final errores = validarCamposBase(datos);
    if (!curpRegex.hasMatch(datos.curp.trim())) {
      errores['curp'] =
          'La CURP debe tener exactamente 18 caracteres del formato oficial mexicano sin espacios.';
    }
    if (!rfcRegex.hasMatch(datos.rfc.trim())) {
      errores['rfc'] = 'El RFC debe tener 12 o 13 caracteres válidos sin espacios (con homoclave).';
    }
    final errPass = validarPassword(password);
    if (errPass != null) {
      errores['password'] = errPass;
    }
    if (confirmarPassword.isEmpty || password != confirmarPassword) {
      errores['confirmarPassword'] = 'Las contraseñas no coinciden.';
    }
    return errores;
  }

  static String? validarDatosBase(ClientePerfil datos) {
    final errores = validarCamposBase(datos);
    if (errores.isEmpty) return null;
    return errores.values.first;
  }

  static String? validarRegistro(
    ClientePerfil datos, {
    required String password,
    required String confirmarPassword,
  }) {
    final errores = validarCamposRegistro(
      datos,
      password: password,
      confirmarPassword: confirmarPassword,
    );
    if (errores.isEmpty) return null;
    return errores.values.first;
  }
}
