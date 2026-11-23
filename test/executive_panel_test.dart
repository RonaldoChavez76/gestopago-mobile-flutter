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

Map<String, dynamic> _clienteFixture({
  int id = 7,
  String primerNombre = 'Mario',
  bool activo = true,
}) {
  return {
    'id': id,
    'primerNombre': primerNombre,
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

SessionController _crearControllerConRol(String rol, http.Client mockHttp) {
  final storage = SecureSessionStorage();
  storage.guardarSesion(
    UserSession.fromJson({
      'accessToken': 'jwt-movil-rol',
      'tokenType': 'Bearer',
      'expiresIn': 900,
      'plataforma': 'MOVIL',
      'rol': rol,
      'usuarioId': 15,
      'clienteId': 3,
      'nombreCliente': rol == 'EJECUTIVO' ? 'Ronaldo Ejecutivo' : 'Ana Cliente',
      'correo': rol == 'EJECUTIVO' ? 'ejecutivo@gestopago.com' : 'ana@gestopago.com',
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
  testWidgets('HomeShellScreen oculta pestaña Ejecutivo cuando rol es CLIENTE', (tester) async {
    final mockHttp = MockClient((request) async => http.Response('{}', 404));
    final controller = _crearControllerConRol('CLIENTE', mockHttp);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: HomeShellScreen(sessionController: controller),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rol: CLIENTE'), findsOneWidget);
    expect(find.text('Ejecutivo'), findsNothing);
    expect(find.text('Abrir Panel Ejecutivo'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('HomeShellScreen muestra pestaña Ejecutivo y CTA cuando rol es EJECUTIVO', (tester) async {
    final mockHttp = MockClient((request) async => http.Response('{}', 404));
    final controller = _crearControllerConRol('EJECUTIVO', mockHttp);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: HomeShellScreen(sessionController: controller),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rol: EJECUTIVO'), findsOneWidget);
    expect(find.text('Ejecutivo'), findsOneWidget);
    expect(find.text('Abrir Panel Ejecutivo'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('ExecutiveScreen busca, edita, da de baja clientes, consulta cuentas y audita usuarios', (tester) async {
    final busquedasClientes = <Map<String, dynamic>>[];
    final busquedasCuentas = <Map<String, dynamic>>[];
    final actualizaciones = <Map<String, dynamic>>[];
    final bajas = <Map<String, dynamic>>[];
    var clienteActivo = true;

    final mockHttp = MockClient((request) async {
      final path = request.url.path;
      final body = request.body.isNotEmpty
          ? jsonDecode(request.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (path.endsWith('/clientes/busqueda')) {
        busquedasClientes.add(body);
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'success': true,
              'data': {
                'content': [_clienteFixture(id: 7, primerNombre: 'Mario', activo: clienteActivo)],
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

      if (path.endsWith('/clientes/consulta')) {
        return http.Response.bytes(
          utf8.encode(jsonEncode({'success': true, 'data': _clienteFixture(id: 7)})),
          200,
        );
      }

      if (path.endsWith('/clientes/actualizar') && request.method == 'PUT') {
        actualizaciones.add(body);
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'success': true,
              'data': _clienteFixture(id: 7, primerNombre: 'Mario Editado'),
            }),
          ),
          200,
        );
      }

      if (path.endsWith('/clientes/baja') && request.method == 'DELETE') {
        bajas.add(body);
        clienteActivo = false;
        return http.Response.bytes(
          utf8.encode(jsonEncode({'success': true, 'message': 'Baja aplicada', 'data': null})),
          200,
        );
      }

      if (path.endsWith('/cuentas/busqueda')) {
        busquedasCuentas.add(body);
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'success': true,
              'data': {
                'content': [
                  {
                    'id': 14,
                    'numeroCuenta': '9941467045485002',
                    'clienteId': 7,
                    'saldo': 2500.5,
                    'estatus': 'ACTIVA',
                  },
                ],
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

      if (path.endsWith('/usuarios/consulta')) {
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'success': true,
              'data': {
                'id': 22,
                'clienteId': 7,
                'correo': 'mario.salazar@correo.com',
                'activo': true,
              },
            }),
          ),
          200,
        );
      }

      if (path.endsWith('/api/gestopago/transacciones/historial/exitosas')) {
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'success': true,
              'data': [
                {
                  'exitoso': true,
                  'upc': '7509988776655',
                  'idTx': '998877',
                  'idServicio': 299,
                  'idProducto': 299,
                  'nombreProducto': 'Recarga \$100 Auditoría',
                  'tipoOperacion': 'RECARGA',
                  'monto': 100,
                  'numeroCuenta': '9941467045485002',
                  'telefono': '5512345678',
                },
              ],
            }),
          ),
          200,
        );
      }

      return http.Response('{}', 404);
    });

    final controller = _crearControllerConRol('EJECUTIVO', mockHttp);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: ExecutiveScreen(sessionController: controller)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Panel Operativo Ejecutivo'), findsOneWidget);
    expect(find.text('Mario Salazar Vega'), findsOneWidget);
    expect(busquedasClientes.first.containsKey('curp'), isFalse);

    final nombreFiltro = find.widgetWithText(TextField, 'Nombre o apellidos');
    await tester.enterText(nombreFiltro, 'Mario');
    await tester.ensureVisible(find.text('Buscar clientes'));
    await tester.tap(find.text('Buscar clientes'));
    await tester.pumpAndSettle();

    expect(busquedasClientes.last['nombre'], 'Mario');

    await tester.ensureVisible(find.text('Editar'));
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    expect(find.text('Editar Cliente #7'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Primer nombre *'), 'Mario Editado');
    await tester.ensureVisible(find.text('Guardar Cambios'));
    await tester.tap(find.text('Guardar Cambios'));
    await tester.pumpAndSettle();

    expect(actualizaciones, hasLength(1));

    await tester.ensureVisible(find.text('Dar de baja'));
    await tester.tap(find.text('Dar de baja'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Escribe BAJA para confirmar'), 'BAJA');
    await tester.pump();
    await tester.tap(find.text('Aplicar Baja'));
    await tester.pumpAndSettle();

    expect(bajas, hasLength(1));
    expect(bajas.first['clienteId'], 7);

    final btnTabCuentas = find.text('Cuentas').first;
    await tester.ensureVisible(btnTabCuentas);
    await tester.tap(btnTabCuentas);
    await tester.pumpAndSettle();

    expect(find.text('9941467045485002'), findsOneWidget);
    expect(busquedasCuentas.first['soloActivas'], isTrue);

    await tester.ensureVisible(find.text('Auditar compras'));
    await tester.tap(find.text('Auditar compras'));
    await tester.pumpAndSettle();

    expect(find.text('Recarga \$100 Auditoría'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'ID de usuario *'), '22');
    await tester.ensureVisible(find.text('Consultar usuario'));
    await tester.tap(find.text('Consultar usuario'));
    await tester.pumpAndSettle();

    expect(find.text('Usuario #22'), findsOneWidget);
  });
}
