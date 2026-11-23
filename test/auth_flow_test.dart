import 'package:decimo_cuatri/core/storage/secure_session_storage.dart';
import 'package:decimo_cuatri/main.dart';
import 'package:decimo_cuatri/models/auth_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Renderiza Login limpio sin credenciales precargadas y navega a registro', (tester) async {
    await tester.pumpWidget(const AuthShellApp());

    expect(find.text('Bienvenido a GestoPago'), findsOneWidget);
    expect(find.text('Iniciar Sesión con 2FA'), findsOneWidget);
    expect(find.text('Cargar credenciales de prueba (Ana)'), findsNothing);

    final botonRegistro = find.text('¿No tienes cuenta? Regístrate aquí');
    await tester.ensureVisible(botonRegistro);
    await tester.pumpAndSettle();
    await tester.tap(botonRegistro);
    await tester.pumpAndSettle();

    expect(find.text('Registro de Nuevo Cliente'), findsOneWidget);
  });

  test('Parsea correctamente ConflictoSesion (409) y UserSession', () {
    final conflicto = ConflictoSesion.fromJson({
      'sesionActivaExistente': true,
      'plataformaActiva': 'MOVIL',
      'fechaInicio': '2026-11-09T18:30:00',
      'accionRequerida': 'Cerrar sesión previa',
    });

    expect(conflicto.sesionActivaExistente, isTrue);
    expect(conflicto.plataformaActiva, 'MOVIL');

    final sesion = UserSession.fromJson({
      'accessToken': 'jwt-token',
      'tokenType': 'Bearer',
      'expiresIn': 900,
      'sessionId': 'sess-123',
      'plataforma': 'WEB',
      'clienteId': 3,
      'nombreCliente': 'Ana María López García',
      'correo': 'ana.lopez.prueba@example.com',
      'numeroCuenta': '4229215075268914',
      'saldoCuenta': 4990.0,
    });

    final storage = SecureSessionStorage();
    storage.guardarSesion(sesion);
    expect(storage.currentSession?.numeroCuenta, '4229215075268914');
    expect(storage.currentSession?.plataforma, 'WEB');
  });
}
