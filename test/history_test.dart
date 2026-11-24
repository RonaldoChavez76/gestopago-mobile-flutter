import 'package:decimo_cuatri/core/network/api_client.dart';
import 'package:decimo_cuatri/core/storage/secure_session_storage.dart';
import 'package:decimo_cuatri/models/transaction_models.dart';
import 'package:decimo_cuatri/screens/history_screen.dart';
import 'package:decimo_cuatri/services/transaction_service.dart';
import 'package:decimo_cuatri/state/session_controller.dart';
import 'package:decimo_cuatri/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHistoryTransactionService extends TransactionService {
  _FakeHistoryTransactionService()
      : super(apiClient: ApiClient(sessionStorage: SecureSessionStorage()));

  @override
  Future<List<PurchaseTransactionResult>> obtenerHistorialComprasExitosas({
    int? clienteId,
    String? numeroCuenta,
  }) async {
    return [
      PurchaseTransactionResult.fromJson({
        'upc': 'TX1A18913184248',
        'tipoOperacion': 'RECARGA',
        'idProducto': 582,
        'idServicio': 133,
        'nombreProducto': 'Recarga Telcel \$10',
        'exitoso': true,
        'estado': 'EXITOSA',
        'codigo': '01',
        'mensaje': 'Operacion realizada con exito',
        'idTx': '826364546',
        'numAutorizacion': '18596434',
        'monto': 10.0,
        'telefono': '5512345678',
        'numeroCuenta': '4229215075268914',
        'fecha': '29/Oct/2026 19:11:32',
      }),
    ];
  }

  @override
  Future<List<PurchaseTransactionResult>> obtenerHistorialCompleto({
    int? clienteId,
    String? numeroCuenta,
  }) {
    return obtenerHistorialComprasExitosas(
      clienteId: clienteId,
      numeroCuenta: numeroCuenta,
    );
  }

  @override
  Future<PurchaseTransactionResult> consultarDetallePorUpc(String upc) async {
    final items = await obtenerHistorialComprasExitosas();
    return items.first;
  }
}

class _FakeMixedHistoryTransactionService extends TransactionService {
  _FakeMixedHistoryTransactionService()
      : super(apiClient: ApiClient(sessionStorage: SecureSessionStorage()));

  final List<PurchaseTransactionResult> _items = [
    PurchaseTransactionResult.fromJson({
      'upc': 'TX_EX_50',
      'tipoOperacion': 'RECARGA',
      'idProducto': 582,
      'idServicio': 133,
      'nombreProducto': 'Recarga Telcel \$50',
      'exitoso': true,
      'estado': 'EXITOSA',
      'codigo': '01',
      'mensaje': 'Operacion realizada con exito',
      'idTx': '826364546',
      'numAutorizacion': '18596434',
      'monto': 50.0,
      'telefono': '5512345678',
      'numeroCuenta': '4229215075268914',
      'fecha': '24/Nov/2026 00:10:00',
    }),
    PurchaseTransactionResult.fromJson({
      'upc': 'RJ_SALDO_150',
      'tipoOperacion': 'PAGO_SERVICIO',
      'idProducto': 205,
      'idServicio': 76,
      'nombreProducto': 'Pago CFE \$150',
      'exitoso': false,
      'estado': 'RECHAZADA',
      'codigo': 'SALDO_INS',
      'mensaje': 'Saldo insuficiente en cuenta bancaria.',
      'motivoRechazo': 'Saldo insuficiente en cuenta bancaria.',
      'monto': 150.0,
      'referencia': '2572038100',
      'numeroCuenta': '4229215075268914',
      'fechaRegistro': '2026-11-24T00:12:00',
    }),
  ];

  @override
  Future<List<PurchaseTransactionResult>> obtenerHistorialCompleto({
    int? clienteId,
    String? numeroCuenta,
  }) async {
    return _items;
  }

  @override
  Future<PurchaseTransactionResult> consultarDetallePorUpc(String upc) async {
    return _items.firstWhere((item) => item.upc == upc, orElse: () => _items.last);
  }
}

void main() {
  testWidgets('Renderiza HistoryScreen con operaciones exitosas y muestra el detalle al tocar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: HistoryScreen(
            sessionController: SessionController(),
            transactionService: _FakeHistoryTransactionService(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Operaciones Exitosas: 1'), findsOneWidget);
    expect(find.text('Recarga Telcel \$10'), findsOneWidget);

    await tester.tap(find.text('Recarga Telcel \$10'));
    await tester.pumpAndSettle();

    expect(find.text('¡Compra Exitosa!'), findsOneWidget);
    expect(find.text('18596434'), findsOneWidget);
  });

  testWidgets('HistoryScreen muestra compras rechazadas con motivo y filtra por Rechazadas', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: HistoryScreen(
            sessionController: SessionController(),
            transactionService: _FakeMixedHistoryTransactionService(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Operaciones Exitosas: 1'), findsOneWidget);
    expect(find.text('Rechazadas: 1'), findsOneWidget);
    expect(find.text('Total operado: \$50.00 MXN'), findsOneWidget);
    expect(find.text('Pago CFE \$150'), findsOneWidget);
    expect(find.text('Motivo: Saldo insuficiente en cuenta bancaria.'), findsOneWidget);

    await tester.tap(find.text('Rechazadas'));
    await tester.pumpAndSettle();

    expect(find.text('Pago CFE \$150'), findsOneWidget);
    expect(find.text('Recarga Telcel \$50'), findsNothing);

    await tester.tap(find.text('Pago CFE \$150'));
    await tester.pumpAndSettle();

    expect(find.text('Compra Rechazada'), findsOneWidget);
    expect(find.text('Motivo específico del rechazo'), findsOneWidget);
    expect(find.text('Saldo insuficiente en cuenta bancaria.'), findsOneWidget);
    expect(find.text('SALDO_INS'), findsOneWidget);
  });
}

