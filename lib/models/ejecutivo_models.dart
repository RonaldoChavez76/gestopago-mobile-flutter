import 'cliente_models.dart';

class PageResponse<T> {
  const PageResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
  });

  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) mapper,
  ) {
    final contentRaw = json['content'];
    final items = contentRaw is List
        ? contentRaw.whereType<Map<String, dynamic>>().map(mapper).toList()
        : <T>[];
    final page = (json['page'] as num?)?.toInt() ?? 0;
    final size = (json['size'] as num?)?.toInt() ?? 10;
    final totalElements = (json['totalElements'] as num?)?.toInt() ?? items.length;
    final totalPagesRaw = (json['totalPages'] as num?)?.toInt() ?? 1;
    final totalPages = totalPagesRaw < 1 ? 1 : totalPagesRaw;

    return PageResponse<T>(
      content: items,
      page: page,
      size: size,
      totalElements: totalElements,
      totalPages: totalPages,
      first: json['first'] as bool? ?? page <= 0,
      last: json['last'] as bool? ?? (page + 1 >= totalPages),
    );
  }
}

class ClienteResumenEjecutivo {
  const ClienteResumenEjecutivo({
    required this.perfil,
    this.fechaCreacion,
  });

  final ClientePerfil perfil;
  final String? fechaCreacion;

  factory ClienteResumenEjecutivo.fromJson(Map<String, dynamic> json) {
    return ClienteResumenEjecutivo(
      perfil: ClientePerfil.fromJson(json),
      fechaCreacion: json['fechaCreacion']?.toString(),
    );
  }
}

class CuentaResumenEjecutivo {
  const CuentaResumenEjecutivo({
    required this.id,
    required this.numeroCuenta,
    required this.clienteId,
    required this.saldo,
    required this.estatus,
    this.fechaApertura,
  });

  final int id;
  final String numeroCuenta;
  final int clienteId;
  final double saldo;
  final String estatus;
  final String? fechaApertura;

  factory CuentaResumenEjecutivo.fromJson(Map<String, dynamic> json) {
    return CuentaResumenEjecutivo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      numeroCuenta: (json['numeroCuenta'] ?? '').toString(),
      clienteId: (json['clienteId'] as num?)?.toInt() ?? 0,
      saldo: (json['saldo'] as num?)?.toDouble() ?? 0.0,
      estatus: (json['estatus'] ?? 'ACTIVA').toString(),
      fechaApertura: json['fechaApertura']?.toString(),
    );
  }
}

class UsuarioResumenEjecutivo {
  const UsuarioResumenEjecutivo({
    required this.id,
    required this.correo,
    required this.activo,
    this.clienteId,
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  final int id;
  final int? clienteId;
  final String correo;
  final bool activo;
  final String? fechaCreacion;
  final String? fechaActualizacion;

  factory UsuarioResumenEjecutivo.fromJson(Map<String, dynamic> json) {
    final cid = (json['clienteId'] as num?)?.toInt();
    return UsuarioResumenEjecutivo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      clienteId: (cid != null && cid > 0) ? cid : null,
      correo: (json['correo'] ?? '').toString(),
      activo: json['activo'] as bool? ?? true,
      fechaCreacion: json['fechaCreacion']?.toString(),
      fechaActualizacion: json['fechaActualizacion']?.toString(),
    );
  }
}

enum EstadoActivoFiltro { todos, activos, inactivos }

class FiltroBusquedaClientes {
  const FiltroBusquedaClientes({
    this.nombre = '',
    this.curp = '',
    this.rfc = '',
    this.correo = '',
    this.numeroCuenta = '',
    this.clienteId = '',
    this.estadoActivo = EstadoActivoFiltro.todos,
    this.registradoDesde = '',
    this.registradoHasta = '',
    this.page = 0,
    this.size = 10,
  });

  final String nombre;
  final String curp;
  final String rfc;
  final String correo;
  final String numeroCuenta;
  final String clienteId;
  final EstadoActivoFiltro estadoActivo;
  final String registradoDesde;
  final String registradoHasta;
  final int page;
  final int size;

  FiltroBusquedaClientes copyWith({
    String? nombre,
    String? curp,
    String? rfc,
    String? correo,
    String? numeroCuenta,
    String? clienteId,
    EstadoActivoFiltro? estadoActivo,
    String? registradoDesde,
    String? registradoHasta,
    int? page,
    int? size,
  }) {
    return FiltroBusquedaClientes(
      nombre: nombre ?? this.nombre,
      curp: curp ?? this.curp,
      rfc: rfc ?? this.rfc,
      correo: correo ?? this.correo,
      numeroCuenta: numeroCuenta ?? this.numeroCuenta,
      clienteId: clienteId ?? this.clienteId,
      estadoActivo: estadoActivo ?? this.estadoActivo,
      registradoDesde: registradoDesde ?? this.registradoDesde,
      registradoHasta: registradoHasta ?? this.registradoHasta,
      page: page ?? this.page,
      size: size ?? this.size,
    );
  }

  String? validar() {
    final idLimpio = clienteId.trim();
    if (idLimpio.isNotEmpty) {
      final parsed = int.tryParse(idLimpio);
      if (parsed == null || parsed <= 0) {
        return 'El ID de cliente debe ser un número entero positivo.';
      }
    }
    final desde = registradoDesde.trim();
    final hasta = registradoHasta.trim();
    if (desde.isNotEmpty && !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(desde)) {
      return 'La fecha inicial debe usar formato AAAA-MM-DD.';
    }
    if (hasta.isNotEmpty && !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(hasta)) {
      return 'La fecha final debe usar formato AAAA-MM-DD.';
    }
    if (desde.isNotEmpty && hasta.isNotEmpty && desde.compareTo(hasta) > 0) {
      return 'La fecha inicial de registro no puede ser posterior a la fecha final.';
    }
    return null;
  }

  Map<String, dynamic> toRequestJson() {
    final payload = <String, dynamic>{
      'page': page,
      'size': size,
    };

    void asignarTexto(String clave, String valor, [String Function(String)? transformar]) {
      final limpio = valor.trim();
      if (limpio.isNotEmpty) {
        payload[clave] = transformar != null ? transformar(limpio) : limpio;
      }
    }

    asignarTexto('nombre', nombre);
    asignarTexto('curp', curp, (v) => v.toUpperCase());
    asignarTexto('rfc', rfc, (v) => v.toUpperCase());
    asignarTexto('correo', correo, (v) => v.toLowerCase());
    asignarTexto('numeroCuenta', numeroCuenta);

    final idLimpio = clienteId.trim();
    if (idLimpio.isNotEmpty) {
      final parsed = int.tryParse(idLimpio);
      if (parsed != null && parsed > 0) {
        payload['clienteId'] = parsed;
      }
    }

    if (estadoActivo == EstadoActivoFiltro.activos) {
      payload['activo'] = true;
    } else if (estadoActivo == EstadoActivoFiltro.inactivos) {
      payload['activo'] = false;
    }

    asignarTexto('registradoDesde', registradoDesde);
    asignarTexto('registradoHasta', registradoHasta);

    return payload;
  }
}

class FiltroBusquedaCuentas {
  const FiltroBusquedaCuentas({
    this.numeroCuenta = '',
    this.clienteId = '',
    this.soloActivas = true,
    this.page = 0,
    this.size = 10,
  });

  final String numeroCuenta;
  final String clienteId;
  final bool soloActivas;
  final int page;
  final int size;

  FiltroBusquedaCuentas copyWith({
    String? numeroCuenta,
    String? clienteId,
    bool? soloActivas,
    int? page,
    int? size,
  }) {
    return FiltroBusquedaCuentas(
      numeroCuenta: numeroCuenta ?? this.numeroCuenta,
      clienteId: clienteId ?? this.clienteId,
      soloActivas: soloActivas ?? this.soloActivas,
      page: page ?? this.page,
      size: size ?? this.size,
    );
  }

  String? validar() {
    final idLimpio = clienteId.trim();
    if (idLimpio.isNotEmpty) {
      final parsed = int.tryParse(idLimpio);
      if (parsed == null || parsed <= 0) {
        return 'El ID de cliente para cuentas debe ser un entero positivo.';
      }
    }
    return null;
  }

  Map<String, dynamic> toRequestJson() {
    final payload = <String, dynamic>{
      'soloActivas': soloActivas,
      'page': page,
      'size': size,
    };

    final cuentaLimpia = numeroCuenta.trim();
    if (cuentaLimpia.isNotEmpty) {
      payload['numeroCuenta'] = cuentaLimpia;
    }

    final idLimpio = clienteId.trim();
    if (idLimpio.isNotEmpty) {
      final parsed = int.tryParse(idLimpio);
      if (parsed != null && parsed > 0) {
        payload['clienteId'] = parsed;
      }
    }

    return payload;
  }
}
