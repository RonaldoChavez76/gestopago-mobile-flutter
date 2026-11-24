import 'dart:convert';

import 'package:decimo_cuatri/core/network/api_client.dart';
import 'package:decimo_cuatri/core/storage/secure_session_storage.dart';
import 'package:decimo_cuatri/models/auth_models.dart';
import 'package:decimo_cuatri/models/cliente_models.dart';
import 'package:decimo_cuatri/models/product_models.dart';
import 'package:decimo_cuatri/screens/catalog_screen.dart';
import 'package:decimo_cuatri/services/auth_service.dart';
import 'package:decimo_cuatri/state/session_controller.dart';
import 'package:decimo_cuatri/theme/app_theme.dart';
import 'package:decimo_cuatri/widgets/bbva_client_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

SessionController _crearSesionCatalogo(http.Client mockHttp) {
  final storage = SecureSessionStorage();
  storage.guardarSesion(
    UserSession.fromJson({
      'accessToken': 'jwt-catalogo-test',
      'tokenType': 'Bearer',
      'expiresIn': 900,
      'plataforma': 'MOVIL',
      'rol': 'CLIENTE',
      'usuarioId': 20,
      'clienteId': 4,
      'nombreCliente': 'Lucía Torres',
      'correo': 'lucia@correo.com',
      'numeroCuenta': '4229215075268914',
      'saldoCuenta': 1450.5,
    }),
  );
  final apiClient = ApiClient(sessionStorage: storage, httpClient: mockHttp);
  return SessionController(
    storage: storage,
    authService: AuthService(apiClient: apiClient),
    apiClient: apiClient,
  );
}

void main() {
  test('CatalogProduct genera URL oficial getServiceLogo cuando falta logoUrl', () {
    final producto = CatalogProduct.fromJson({
      'idProducto': 701,
      'idServicio': 133,
      'producto': 'Recarga Telcel 100',
      'servicio': 'Telcel',
      'precio': 100,
      'tipoFront': '1',
      'active': true,
    });

    expect(
      producto.logoUrl,
      'https://gestopago.portalventas.net/sistema/images/gestopago/servicios/133.png',
    );

    final personalizado = CatalogProduct.fromJson({
      'idProducto': 702,
      'idServicio': 133,
      'producto': 'CFE Recibo',
      'precio': 0,
      'logoUrl': 'https://cdn.ejemplo.com/cfe.png',
    });

    expect(personalizado.logoUrl, 'https://cdn.ejemplo.com/cfe.png');
  });

  testWidgets(
    'CatalogScreen pagina 25 productos en 2 columnas móviles, alterna a lista y filtra',
    (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final listaMock = List<Map<String, dynamic>>.generate(25, (i) {
        final n = (i + 1).toString().padLeft(2, '0');
        return {
          'idProducto': 14000 + i + 1,
          'idServicio': i.isEven ? 79 : 99,
          'producto': 'Servicio Demo $n',
          'servicio': i.isEven ? 'CFE' : 'Telcel',
          'precio': i.isEven ? 120.0 : 0.0,
          'tipoFront': i.isEven ? '1' : '2',
          'active': true,
        };
      });

      final mockHttp = MockClient((request) async {
        if (request.url.path.endsWith('/api/gestopago/catalogo')) {
          return http.Response.bytes(
            utf8.encode(jsonEncode({'success': true, 'data': listaMock})),
            200,
          );
        }
        return http.Response('{}', 404);
      });

      final controller = _crearSesionCatalogo(mockHttp);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: CatalogScreen(sessionController: controller),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Mostrando 25 productos (1-12)'), findsOneWidget);
      expect(find.text('Página 1 de 3'), findsOneWidget);
      expect(find.text('Servicio Demo 01'), findsOneWidget);
      expect(find.text('Servicio Demo 13'), findsNothing);

      final btnSiguiente = find.text('Siguiente');
      await tester.ensureVisible(btnSiguiente);
      await tester.tap(btnSiguiente);
      await tester.pumpAndSettle();

      expect(find.text('Mostrando 25 productos (13-24)'), findsOneWidget);
      expect(find.text('Página 2 de 3'), findsOneWidget);
      expect(find.text('Servicio Demo 13'), findsOneWidget);

      await tester.tap(find.byTooltip('Vista en lista amplia'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byTooltip('Vista en cuadrícula (2 columnas)'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Buscar producto, marca o ID...'),
        'Demo 25',
      );
      await tester.pumpAndSettle();

      expect(find.text('Mostrando 1 productos (1-1)'), findsOneWidget);
      expect(find.text('Página 1 de 1'), findsOneWidget);
      expect(find.text('Servicio Demo 25'), findsOneWidget);
    },
  );

  testWidgets('BbvaClientCard oculta saldo y número y copia cuenta al portapapeles', (
    tester,
  ) async {
    String? copiadoPortapapeles;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          final args = call.arguments as Map<dynamic, dynamic>?;
          copiadoPortapapeles = args?['text']?.toString();
        }
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: BbvaClientCard(
              nombreTitular: 'Ana López García',
              correo: 'ana@correo.com',
              plataforma: 'MOVIL',
              numeroCuenta: '4229215075268914',
              saldoCuenta: 1450.5,
              curp: 'LOGA960512MDFRRL09',
              rfc: 'LOGA960512AB1',
              clienteId: 12,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ana López García'), findsOneWidget);
    expect(find.text('\$1450.50 MXN'), findsOneWidget);
    expect(find.text('4229 2150 7526 8914'), findsOneWidget);
    expect(find.text('Rol: CLIENTE'), findsOneWidget);
    expect(find.text('Cuenta Activa'), findsOneWidget);
    expect(find.text('CURP: LOGA960512MDFRRL09'), findsOneWidget);
    expect(find.text('RFC: LOGA960512AB1'), findsOneWidget);

    await tester.tap(find.text('Ocultar saldo'));
    await tester.pump();
    expect(find.text('\$ •••••• MXN'), findsOneWidget);
    expect(find.text('Mostrar saldo'), findsOneWidget);

    await tester.tap(find.text('Ocultar número'));
    await tester.pump();
    expect(find.text('•••• •••• •••• 8914'), findsOneWidget);
    expect(find.text('Ver número'), findsOneWidget);

    await tester.tap(find.text('Copiar cuenta'));
    await tester.pump();
    expect(copiadoPortapapeles, '4229215075268914');
    expect(find.text('Copiado'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Copiar cuenta'), findsOneWidget);
  });

  test('ClienteValidacion aplica longitudes mínimas, sin espacios, edad 18-120 y pago', () {
    const perfilValidoCorto = ClientePerfil(
      id: 1,
      primerNombre: 'Al',
      segundoNombre: 'Yu',
      apellidoPaterno: 'Li',
      apellidoMaterno: 'Su',
      fechaNacimiento: '1998-05-12',
      curp: 'LISA980512MDFRRL01',
      rfc: 'LISA980512AB1',
      sexo: 'FEMENINO',
      nacionalidad: 'Surcoreana',
      estadoCivil: 'Soltero',
      correo: 'al.yu@correo.com',
      telefonoMovil: '5512345678',
      telefonoAlternativo: '5587654321',
      ocupacion: 'UX',
      empresa: 'B2',
      ingresoMensual: '25000.50',
      activo: true,
      domicilio: DomicilioPerfil(
        calle: 'Sol',
        numeroExterior: '10-A',
        numeroInterior: '2B',
        colonia: 'Sur',
        municipio: 'Oax',
        estado: 'DF',
        codigoPostal: '06600',
        pais: 'Mex',
      ),
    );

    final erroresOcupacionCorta = ClienteValidacion.validarCamposBase(perfilValidoCorto);
    expect(erroresOcupacionCorta.keys, ['ocupacion']);

    const perfilValidoCompleto = ClientePerfil(
      id: 1,
      primerNombre: 'Al',
      segundoNombre: 'Yu',
      apellidoPaterno: 'Li',
      apellidoMaterno: 'Su',
      fechaNacimiento: '1998-05-12',
      curp: 'LISA980512MDFRRL01',
      rfc: 'LISA980512AB1',
      sexo: 'FEMENINO',
      nacionalidad: 'Mex',
      estadoCivil: 'Sol',
      correo: 'al.yu@correo.com',
      telefonoMovil: '5512345678',
      telefonoAlternativo: '5587654321',
      ocupacion: 'UXD',
      empresa: 'B2',
      ingresoMensual: '25000.50',
      activo: true,
      domicilio: DomicilioPerfil(
        calle: 'Sol',
        numeroExterior: '10-A',
        numeroInterior: '2B',
        colonia: 'Sur',
        municipio: 'Oax',
        estado: 'DF',
        codigoPostal: '06600',
        pais: 'Mex',
      ),
    );

    expect(ClienteValidacion.validarCamposBase(perfilValidoCompleto), isEmpty);

    const perfilInvalido = ClientePerfil(
      id: 1,
      primerNombre: 'A',
      segundoNombre: '1',
      apellidoPaterno: 'Lopez9',
      apellidoMaterno: 'X',
      fechaNacimiento: '2000-02-31',
      curp: 'MALO',
      rfc: 'MALO',
      sexo: 'FEMENINO',
      nacionalidad: 'Mx',
      estadoCivil: 'S',
      correo: 'con espacio@correo.com',
      telefonoMovil: '1111111111',
      telefonoAlternativo: '1111111111',
      ocupacion: 'Dev 99',
      empresa: 'X',
      ingresoMensual: '0',
      activo: true,
      domicilio: DomicilioPerfil(
        calle: 'Ab',
        numeroExterior: '12 A',
        numeroInterior: 'B 1',
        colonia: 'Xy',
        municipio: 'Al',
        estado: 'A',
        codigoPostal: '123',
        pais: 'Mx',
      ),
    );

    final errores = ClienteValidacion.validarCamposRegistro(
      perfilInvalido,
      password: 'Pass 123!',
      confirmarPassword: 'otra',
    );

    expect(
      errores.keys,
      containsAll(<String>[
        'primerNombre',
        'segundoNombre',
        'apellidoPaterno',
        'apellidoMaterno',
        'fechaNacimiento',
        'nacionalidad',
        'estadoCivil',
        'correo',
        'telefonoMovil',
        'telefonoAlternativo',
        'ocupacion',
        'empresa',
        'ingresoMensual',
        'domicilio.calle',
        'domicilio.numeroExterior',
        'domicilio.numeroInterior',
        'domicilio.colonia',
        'domicilio.municipio',
        'domicilio.estado',
        'domicilio.codigoPostal',
        'domicilio.pais',
        'curp',
        'rfc',
        'password',
        'confirmarPassword',
      ]),
    );

    const perfilMenorDeEdad = ClientePerfil(
      id: 1,
      primerNombre: 'Luis',
      segundoNombre: '',
      apellidoPaterno: 'Pérez',
      apellidoMaterno: 'Díaz',
      fechaNacimiento: '2014-01-01',
      curp: 'PEDL140101HDFRRL01',
      rfc: 'PEDL140101AB1',
      sexo: 'MASCULINO',
      nacionalidad: 'Mexicana',
      estadoCivil: 'Soltero',
      correo: 'luis@correo.com',
      telefonoMovil: '5512345678',
      telefonoAlternativo: '',
      ocupacion: 'Estudiante',
      empresa: 'Escuela',
      ingresoMensual: '5000',
      activo: true,
      domicilio: DomicilioPerfil(
        calle: 'Reforma',
        numeroExterior: '10',
        numeroInterior: '',
        colonia: 'Centro',
        municipio: 'Cuauhtémoc',
        estado: 'CDMX',
        codigoPostal: '06600',
        pais: 'México',
      ),
    );

    expect(
      ClienteValidacion.validarCamposBase(perfilMenorDeEdad).containsKey('fechaNacimiento'),
      isTrue,
    );

    expect(ClienteValidacion.validarCorreo('con espacio@correo.com'), isNotNull);
    expect(ClienteValidacion.validarPassword('Pass 123!'), isNotNull);
    expect(ClienteValidacion.validarCuenta16('1234567890'), isNotNull);
    expect(ClienteValidacion.validarCuenta16('4229215075268914'), isNull);
    expect(ClienteValidacion.validarReferenciaServicio('AB'), isNotNull);
    expect(ClienteValidacion.validarReferenciaServicio('REF-2026-001'), isNull);
  });
}
