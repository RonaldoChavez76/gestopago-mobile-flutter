import 'dart:convert';

import 'package:decimo_cuatri/core/network/api_client.dart';
import 'package:decimo_cuatri/core/storage/secure_session_storage.dart';
import 'package:decimo_cuatri/models/auth_models.dart';
import 'package:decimo_cuatri/screens/executive_screen.dart';
import 'package:decimo_cuatri/screens/home_shell_screen.dart';
import 'package:decimo_cuatri/services/auth_service.dart';
import 'package:decimo_cuatri/state/session_controller.dart';
import 'package:decimo_cuatri/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, dynamic> _clienteInactivoFixture({bool activo = false}) {
  return {
    'id': 7,
    'primerNombre': 'Mario',
    'segundoNombre': '',
    'apellidoPaterno': 'Salazar',
    'apellidoMaterno': 'Vega',
    'fechaNacimiento': '1992-05-14',
    'curp': 'SAVA920514HDFRRL01',
    'rfc': 'SAVA920514AB1',
    'sexo': 'MASCULINO',
    'nacionalidad': 'Mexicana',
    'estadoCivil': 'Soltero',
    'correo': 'mario.salazar@correo.com',
    'telefonoMovil': '5511223344',
    'telefonoAlternativo': '',
    'ocupacion': 'Ingeniero',
    'empresa': 'Tech MX',
    'ingresoMensual': 28000,
    'activo': activo,
    'fechaCreacion': '2026-10-10T10:00:00Z',
    'domicilio': {
      'calle': 'Reforma',
      'numeroExterior': '100',
      'numeroInterior': '',
      'colonia': 'Juárez',
      'municipio': 'Cuauhtémoc',
      'estado': 'Ciudad de México',
      'codigoPostal': '06600',
      'pais': 'México',
    },
  };
}

SessionController _crearController({
  required String rol,
  required bool cuentaActiva,
  required http.Client mockHttp,
}) {
  final storage = SecureSessionStorage();
  storage.guardarSesion(
    UserSession.fromJson({
      'accessToken': 'jwt-movil-reactivacion',
      'tokenType': 'Bearer',
      'expiresIn': 900,
      'plataforma': 'MOVIL',
      'rol': rol,
      'cuentaActiva': cuentaActiva,
      'usuarioId': 15,
      'clienteId': 3,
      'nombreCliente': 'Ana Prueba',
      'correo': 'ana.prueba@example.com',
      'numeroCuenta': '9941467045485002',
      'saldoCuenta': 3680.0,
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
  testWidgets('HomeShellScreen restringe movimientos cuando cuentaActiva es false y permite reactivar', (tester) async {
    var activaEnServidor = false;
    final reactivaciones = <Map<String, dynamic>>[];

    final mockHttp = MockClient((request) async {
      final path = request.url.path;
      if (path.endsWith('/clientes/reactivar') && request.method == 'PUT') {
        reactivaciones.add(jsonDecode(request.body) as Map<String, dynamic>);
        activaEnServidor = true;
        return http.Response.bytes(
          utf8.encode(jsonEncode({'success': true, 'message': 'Cliente reactivado', 'data': null})),
          200,
        );
      }
      if (path.endsWith('/auth/sesion')) {
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'success': true,
              'data': {
                'activa': true,
                'usuarioId': 15,
                'clienteId': 3,
                'nombreCliente': 'Ana Prueba',
                'correo': 'ana.prueba@example.com',
                'numeroCuenta': '9941467045485002',
                'saldoCuenta': 3680.0,
                'rol': 'CLIENTE',
                'cuentaActiva': activaEnServidor,
              },
            }),
          ),
          200,
        );
      }
      return http.Response('{}', 404);
    });

    final controller = _crearController(
      rol: 'CLIENTE',
      cuentaActiva: false,
      mockHttp: mockHttp,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: HomeShellScreen(sessionController: controller),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tu cuenta está dada de baja temporalmente'), findsOneWidget);
    expect(find.text('Catálogo'), findsNothing);
    expect(find.text('Perfil'), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextField, 'Escribe ACTIVAR para reactivar tu cuenta'),
      'ACTIVAR',
    );
    await tester.pump();

    await tester.tap(find.text('Reactivar mi cuenta'));
    await tester.pumpAndSettle();

    expect(reactivaciones, hasLength(1));
    expect(reactivaciones.first['clienteId'], 3);
    expect(find.text('Catálogo'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('ExecutiveScreen bloquea edición en clientes inactivos y permite reactivarlos', (tester) async {
    var clienteActivo = false;
    final reactivaciones = <Map<String, dynamic>>[];

    final mockHttp = MockClient((request) async {
      final path = request.url.path;
      final body = request.body.isNotEmpty
          ? jsonDecode(request.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (path.endsWith('/clientes/busqueda')) {
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'success': true,
              'data': {
                'content': [_clienteInactivoFixture(activo: clienteActivo)],
                'page': 0,
                'size': 10,
                'totalElements': 1,
                'totalPages': 1,
                'first': true,
                'last': true,
              },
            }),
          ),
          200,
        );
      }
      if (path.endsWith('/clientes/reactivar') && request.method == 'PUT') {
        reactivaciones.add(body);
        clienteActivo = true;
        return http.Response.bytes(
          utf8.encode(jsonEncode({'success': true, 'message': 'Cliente reactivado', 'data': null})),
          200,
        );
      }
      return http.Response('{}', 404);
    });

    final controller = _crearController(
      rol: 'EJECUTIVO',
      cuentaActiva: true,
      mockHttp: mockHttp,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: ExecutiveScreen(sessionController: controller)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mario Salazar Vega'), findsOneWidget);
    expect(find.text('Editar'), findsNothing);
    expect(find.text('Dar de baja'), findsNothing);
    expect(find.text('Reactivar'), findsOneWidget);

    await tester.ensureVisible(find.text('Reactivar'));
    await tester.tap(find.text('Reactivar'));
    await tester.pumpAndSettle();

    expect(find.text('Reactivar Cliente #7'), findsOneWidget);
    await tester.tap(find.text('Reactivar Cliente'));
    await tester.pumpAndSettle();

    expect(reactivaciones, hasLength(1));
    expect(reactivaciones.first['clienteId'], 7);
    expect(find.text('Editar'), findsOneWidget);
  });
}
