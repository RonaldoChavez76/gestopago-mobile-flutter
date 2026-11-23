import 'dart:convert';

import 'package:decimo_cuatri/core/network/api_client.dart';
import 'package:decimo_cuatri/core/storage/secure_session_storage.dart';
import 'package:decimo_cuatri/models/auth_models.dart';
import 'package:decimo_cuatri/models/product_models.dart';
import 'package:decimo_cuatri/screens/catalog_screen.dart';
import 'package:decimo_cuatri/screens/login_screen.dart';
import 'package:decimo_cuatri/screens/profile_screen.dart';
import 'package:decimo_cuatri/screens/purchase_screen.dart';
import 'package:decimo_cuatri/screens/two_factor_screen.dart';
import 'package:decimo_cuatri/services/auth_service.dart';
import 'package:decimo_cuatri/services/catalog_service.dart';
import 'package:decimo_cuatri/state/session_controller.dart';
import 'package:decimo_cuatri/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _FakeCatalogServicePrecioAlto extends CatalogService {
  _FakeCatalogServicePrecioAlto()
      : super(apiClient: ApiClient(sessionStorage: SecureSessionStorage()));

  @override
  Future<List<CatalogProduct>> obtenerCatalogoProductos() async {
    return [
      CatalogProduct.fromJson({
        'idProducto': '14302',
        'idServicio': '99',
        'producto': 'ABIB 100',
        'servicio': 'ABIB',
        'tipoFront': '2',
        'precio': 100.0,
        'active': true,
        'legend': 'Pago de servicio ABIB.',
      }),
    ];
  }
}

void main() {
  testWidgets('Tarjeta de catalogo muestra precio completo y ids de producto y servicio', (tester) async {
    final sessionController = SessionController();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CatalogScreen(
            sessionController: sessionController,
            catalogService: _FakeCatalogServicePrecioAlto(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('ABIB 100'), findsOneWidget);
    expect(find.text('\$100.00 MXN'), findsOneWidget);
    expect(find.text('Prod #14302 • Serv #99'), findsOneWidget);
    expect(find.text('Detalle'), findsOneWidget);
    expect(find.text('Comprar'), findsOneWidget);
  });

  testWidgets('TwoFactorScreen oculta vista previa OTP y muestra aviso cuando se envia por correo', (tester) async {
    final sessionController = SessionController();
    final challenge = Login2faChallenge(
      requiere2FA: true,
      correo: 'chavezronaldo675@gmail.com',
      numeroCuenta: '4229215075268914',
      plataforma: 'MOVIL',
      codigoOtp: '',
      expiraEnSegundos: 300,
      mensaje: 'Código enviado por correo.',
      correoEnviado: true,
      correoDestinoEnmascarado: 'ch***5@gmail.com',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: TwoFactorScreen(
          sessionController: sessionController,
          challenge: challenge,
          correo: 'chavezronaldo675@gmail.com',
          password: 'Prueba2026!',
          plataforma: 'MOVIL',
          forzarCierreSesion: false,
        ),
      ),
    );

    expect(
      find.textContaining('ch***5@gmail.com'),
      findsOneWidget,
    );
    expect(find.text('Usar código'), findsNothing);
  });

  testWidgets('PurchaseScreen muestra confirmacion de envio por correo cuando el backend oculta el OTP', (tester) async {
    final mockHttp = MockClient((request) async {
      if (request.url.path.endsWith('/api/seguridad/2fa/solicitar')) {
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'success': true,
              'data': {
                'numeroCuenta': '4229215075268914',
                'expiraEnSegundos': 300,
                'codigoOtp': null,
                'correoEnviado': true,
                'correoDestinoEnmascarado': 'ch***5@gmail.com',
              },
            }),
          ),
          200,
        );
      }
      return http.Response('{}', 404);
    });

    final storage = SecureSessionStorage();
    storage.guardarSesion(
      UserSession.fromJson({
        'accessToken': 'jwt-movil',
        'tokenType': 'Bearer',
        'expiresIn': 900,
        'plataforma': 'MOVIL',
        'usuarioId': 10,
        'clienteId': 1,
        'correo': 'chavezronaldo675@gmail.com',
        'numeroCuenta': '4229215075268914',
        'saldoCuenta': 3990.0,
      }),
    );

    final apiClient = ApiClient(sessionStorage: storage, httpClient: mockHttp);
    final controller = SessionController(
      storage: storage,
      authService: AuthService(apiClient: apiClient),
      apiClient: apiClient,
    );

    final producto = CatalogProduct.fromJson({
      'idProducto': '582',
      'idServicio': '133',
      'producto': 'Recarga Telcel \$50',
      'servicio': 'Telcel',
      'tipoFront': '1',
      'precio': 50.0,
      'active': true,
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: PurchaseScreen(
          producto: producto,
          sessionController: controller,
        ),
      ),
    );

    final btnOtp = find.text('Generar OTP');
    await tester.ensureVisible(btnOtp);
    await tester.tap(btnOtp);
    await tester.pumpAndSettle();

    expect(find.textContaining('ch***5@gmail.com'), findsOneWidget);
    expect(find.textContaining('autocompletado'), findsNothing);
  });

  testWidgets('ProfileScreen edita datos, cambia contrasena y ejecuta baja logica con confirmacion BAJA', (tester) async {
    final clienteBase = {
      'id': 7,
      'primerNombre': 'Ana',
      'segundoNombre': 'María',
      'apellidoPaterno': 'López',
      'apellidoMaterno': 'García',
      'fechaNacimiento': '1996-05-12',
      'curp': 'LOGA960512MDFRRL09',
      'rfc': 'LOGA960512ABC',
      'sexo': 'FEMENINO',
      'nacionalidad': 'Mexicana',
      'estadoCivil': 'Soltera',
      'correo': 'ana.lopez@correo.com',
      'telefonoMovil': '5511223344',
      'telefonoAlternativo': '',
      'ocupacion': 'Ingeniera',
      'empresa': 'Tech MX',
      'ingresoMensual': 25000.0,
      'activo': true,
      'domicilio': {
        'calle': 'Av. Reforma',
        'numeroExterior': '100',
        'numeroInterior': '',
        'colonia': 'Centro',
        'municipio': 'Cuauhtémoc',
        'estado': 'Ciudad de México',
        'codigoPostal': '06000',
        'pais': 'México',
      },
    };

    var updatedCalled = false;
    var passwordCalled = false;
    var bajaCalled = false;

    final mockHttp = MockClient((request) async {
      final path = request.url.path;
      if (path.endsWith('/clientes/consulta')) {
        return http.Response.bytes(
          utf8.encode(jsonEncode({'success': true, 'data': clienteBase})),
          200,
        );
      }
      if (path.endsWith('/clientes/actualizar') && request.method == 'PUT') {
        updatedCalled = true;
        final actualizado = Map<String, dynamic>.from(clienteBase)
          ..['correo'] = 'ana.editada@correo.com';
        return http.Response.bytes(
          utf8.encode(jsonEncode({'success': true, 'data': actualizado})),
          200,
        );
      }
      if (path.endsWith('/usuarios/password') && request.method == 'PUT') {
        passwordCalled = true;
        return http.Response.bytes(
          utf8.encode(jsonEncode({'success': true, 'message': 'Contraseña actualizada correctamente.'})),
          200,
        );
      }
      if (path.endsWith('/clientes/baja') && request.method == 'DELETE') {
        bajaCalled = true;
        return http.Response.bytes(
          utf8.encode(jsonEncode({'success': true, 'message': 'Cliente dado de baja.'})),
          200,
        );
      }
      return http.Response('{}', 404);
    });

    final storage = SecureSessionStorage();
    storage.guardarSesion(
      UserSession.fromJson({
        'accessToken': 'jwt-movil-perfil',
        'tokenType': 'Bearer',
        'expiresIn': 900,
        'plataforma': 'MOVIL',
        'usuarioId': 15,
        'clienteId': 7,
        'nombreCliente': 'Ana María López García',
        'correo': 'ana.lopez@correo.com',
        'numeroCuenta': '4229215075268914',
        'saldoCuenta': 3990.0,
      }),
    );

    final apiClient = ApiClient(sessionStorage: storage, httpClient: mockHttp);
    final controller = SessionController(
      storage: storage,
      authService: AuthService(apiClient: apiClient),
      apiClient: apiClient,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        routes: {
          LoginScreen.routeName: (_) => const Scaffold(body: Text('Pantalla Login')),
        },
        home: Scaffold(
          body: ProfileScreen(sessionController: controller),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('CURP: LOGA960512MDFRRL09'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Correo electrónico *'),
      'ana.editada@correo.com',
    );
    final btnGuardar = find.text('Guardar Cambios de Perfil');
    await tester.ensureVisible(btnGuardar);
    await tester.tap(btnGuardar);
    await tester.pumpAndSettle();

    expect(updatedCalled, isTrue);
    expect(controller.sesionActual?.correo, 'ana.editada@correo.com');

    await tester.enterText(
      find.widgetWithText(TextField, 'Contraseña actual *'),
      'Prueba2026!',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Nueva contraseña *'),
      'NuevaPass2026\$',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirmar nueva contraseña *'),
      'NuevaPass2026\$',
    );
    final btnPass = find.text('Actualizar Contraseña');
    await tester.ensureVisible(btnPass);
    await tester.tap(btnPass);
    await tester.pumpAndSettle();

    expect(passwordCalled, isTrue);
    expect(find.text('Contraseña actualizada correctamente.'), findsOneWidget);

    final btnBaja = find.text('Dar de baja mi cuenta');
    await tester.ensureVisible(btnBaja);
    await tester.tap(btnBaja);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Escribe BAJA para confirmar'),
      'BAJA',
    );
    await tester.pump();
    await tester.tap(find.text('Confirmar baja definitiva'));
    await tester.pumpAndSettle();

    expect(bajaCalled, isTrue);
    expect(controller.sesionActual, isNull);
    expect(find.text('Pantalla Login'), findsOneWidget);
  });
}
