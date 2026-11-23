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
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9]).{8,}$',
  );
  static final RegExp emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp curpRegex = RegExp(
    r'^[A-Z][AEIOUX][A-Z]{2}[0-9]{6}[HM][A-Z]{5}[A-Z0-9][0-9]$',
    caseSensitive: false,
  );
  static final RegExp rfcRegex = RegExp(
    r'^[A-Z&Ñ]{3,4}[0-9]{6}[A-Z0-9]{3}$',
    caseSensitive: false,
  );

  static bool esMayorDeEdad(String fechaIso) {
    final limpio = fechaIso.trim();
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(limpio)) {
      return false;
    }
    final partes = limpio.split('-');
    final anio = int.tryParse(partes[0]);
    final mes = int.tryParse(partes[1]);
    final dia = int.tryParse(partes[2]);
    if (anio == null || mes == null || dia == null) return false;
    final nacimiento = DateTime(anio, mes, dia);
    final hoy = DateTime.now();
    final limite = DateTime(hoy.year - 18, hoy.month, hoy.day);
    return !nacimiento.isAfter(limite);
  }

  static String? validarDatosBase(ClientePerfil datos) {
    if (datos.primerNombre.trim().length < 2) {
      return 'El primer nombre debe tener al menos 2 caracteres.';
    }
    if (datos.segundoNombre.trim().isNotEmpty && datos.segundoNombre.trim().length < 2) {
      return 'El segundo nombre debe tener al menos 2 caracteres si decides llenarlo.';
    }
    if (datos.apellidoPaterno.trim().length < 2) {
      return 'El apellido paterno debe tener al menos 2 caracteres.';
    }
    if (datos.apellidoMaterno.trim().length < 2) {
      return 'El apellido materno debe tener al menos 2 caracteres.';
    }
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(datos.fechaNacimiento.trim())) {
      return 'La fecha de nacimiento debe usar el formato AAAA-MM-DD.';
    }
    if (!esMayorDeEdad(datos.fechaNacimiento)) {
      return 'Debes ser mayor de 18 años para operar en GestoPago.';
    }
    if (!emailRegex.hasMatch(datos.correo.trim())) {
      return 'Ingresa un correo electrónico válido.';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(datos.telefonoMovil.trim())) {
      return 'El teléfono móvil debe tener exactamente 10 dígitos.';
    }
    final alt = datos.telefonoAlternativo.trim();
    if (alt.isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(alt)) {
      return 'El teléfono alternativo debe tener 10 dígitos o permanecer vacío.';
    }
    if (datos.ocupacion.trim().isEmpty || datos.empresa.trim().isEmpty) {
      return 'Ocupación y empresa son obligatorios.';
    }
    final ingreso = double.tryParse(datos.ingresoMensual.trim());
    if (ingreso == null || ingreso <= 0) {
      return 'El ingreso mensual debe ser mayor a \$0.00.';
    }
    final dom = datos.domicilio;
    if (dom.calle.trim().isEmpty ||
        dom.numeroExterior.trim().isEmpty ||
        dom.colonia.trim().isEmpty ||
        dom.municipio.trim().isEmpty ||
        dom.estado.trim().isEmpty ||
        dom.pais.trim().isEmpty) {
      return 'Completa los campos obligatorios del domicilio.';
    }
    if (!RegExp(r'^\d{5}$').hasMatch(dom.codigoPostal.trim())) {
      return 'El código postal debe tener exactamente 5 dígitos.';
    }
    return null;
  }

  static String? validarRegistro(
    ClientePerfil datos, {
    required String password,
    required String confirmarPassword,
  }) {
    final errBase = validarDatosBase(datos);
    if (errBase != null) return errBase;
    if (!curpRegex.hasMatch(datos.curp.trim())) {
      return 'La CURP debe tener los 18 caracteres del formato oficial mexicano.';
    }
    if (!rfcRegex.hasMatch(datos.rfc.trim())) {
      return 'El RFC debe tener 12 o 13 caracteres válidos (con homoclave).';
    }
    if (!passwordRegex.hasMatch(password)) {
      return 'La contraseña requiere mínimo 8 caracteres, mayúscula, minúscula, número y símbolo.';
    }
    if (password != confirmarPassword) {
      return 'Las contraseñas no coinciden.';
    }
    return null;
  }
}
