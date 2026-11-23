import 'dart:convert';

import 'package:decimo_cuatri/core/network/api_client.dart';
import 'package:decimo_cuatri/core/storage/secure_session_storage.dart';
import 'package:decimo_cuatri/screens/login_screen.dart';
import 'package:decimo_cuatri/state/session_controller.dart';
import 'package:decimo_cuatri/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('Registro completo envia POST /clientes y vuelve a Login con correo precargado', (tester) async {
    Map<String, dynamic>? payloadEnviado;

    final mockHttp = MockClient((request) async {
      if (request.url.path.endsWith('/clientes') && request.method == 'POST') {
        payloadEnviado = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'success': true,
              'message': 'Cliente registrado correctamente.',
              'data': {
                'clienteId': 25,
                'usuarioId': 30,
                'cuentaId': 40,
                'numeroCuenta': '9941467045485999',
                'correo': 'carlos.registro@correo.com',
              },
            }),
          ),
          201,
        );
      }
      return http.Response('{}', 404);
    });

    final storage = SecureSessionStorage();
    final apiClient = ApiClient(sessionStorage: storage, httpClient: mockHttp);
    final controller = SessionController(storage: storage, apiClient: apiClient);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: LoginScreen(sessionController: controller),
      ),
    );

    final btnRegistro = find.text('¿No tienes cuenta? Regístrate aquí');
    await tester.ensureVisible(btnRegistro);
    await tester.tap(btnRegistro);
    await tester.pumpAndSettle();

    Future<void> escribir(String label, String valor) async {
      final campo = find.widgetWithText(TextField, label);
      await tester.ensureVisible(campo);
      await tester.pumpAndSettle();
      await tester.enterText(campo, valor);
    }

    await escribir('Primer nombre *', 'Carlos');
    await escribir('Apellido paterno *', 'Ramirez');
    await escribir('Apellido materno *', 'Soto');
    await escribir('CURP (18 caracteres) *', 'RASO000115HDFRRL01');
    await escribir('RFC (12-13 caracteres) *', 'RASO000115AB1');
    await escribir('Fecha de nacimiento (AAAA-MM-DD) *', '2000-01-15');
    await escribir('Correo electrónico *', 'carlos.registro@correo.com');
    await escribir('Teléfono móvil (10 dígitos) *', '5512345678');
    await escribir('Ocupación *', 'Ingeniero');
    await escribir('Empresa *', 'Tech MX');
    await escribir('Ingreso mensual (MXN) *', '20000');

    await escribir('Calle *', 'Av. Reforma');
    await escribir('Número exterior *', '120');
    await escribir('Colonia *', 'Centro');
    await escribir('Municipio / Alcaldía *', 'Cuauhtémoc');
    await escribir('Estado *', 'CDMX');
    await escribir('Código postal (5 dígitos) *', '06000');

    await escribir('Contraseña *', 'Segura2026!');
    await escribir('Confirmar contraseña *', 'Segura2026!');

    final btnEnviar = find.text('Registrar Cuenta');
    await tester.ensureVisible(btnEnviar);
    await tester.pumpAndSettle();
    await tester.tap(btnEnviar);
    await tester.pumpAndSettle();

    expect(find.text('¡Cuenta Registrada!'), findsOneWidget);
    expect(find.text('9941467045485999'), findsOneWidget);
    expect(payloadEnviado, isNotNull);
    expect(payloadEnviado!['curp'], 'RASO000115HDFRRL01');

    await tester.tap(find.text('Ir a Iniciar Sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido a GestoPago'), findsOneWidget);
    expect(find.text('carlos.registro@correo.com'), findsOneWidget);
    expect(find.textContaining('9941467045485999'), findsOneWidget);
  });
}
