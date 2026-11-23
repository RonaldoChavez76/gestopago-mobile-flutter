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
