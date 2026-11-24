import 'dart:async';

import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../services/cliente_service.dart';
import '../state/session_controller.dart';
import '../widgets/bbva_client_card.dart';
import 'catalog_screen.dart';
import 'executive_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'purchase_screen.dart';

class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({
    required this.sessionController,
    super.key,
  });

  static const routeName = '/home';

  final SessionController sessionController;

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _selectedIndex = 0;
  Timer? _sessionMonitorTimer;

  @override
  void initState() {
    super.initState();
    widget.sessionController.addListener(_onSessionChange);
    _sessionMonitorTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      widget.sessionController.verificarVigenciaSesion();
    });
  }

  void _onSessionChange() {
    if (!mounted) return;
    if (!widget.sessionController.estaAutenticado) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginScreen(sessionController: widget.sessionController),
        ),
        (route) => false,
      );
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _sessionMonitorTimer?.cancel();
    widget.sessionController.removeListener(_onSessionChange);
    super.dispose();
  }

  Future<void> _confirmarCierreSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión segura'),
        content: const Text(
          '¿Deseas finalizar tu sesión activa en este dispositivo? Esto liberará tu cuenta para iniciar sesión en Web o Móvil.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      await widget.sessionController.cerrarSesion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sesion = widget.sessionController.sesionActual;
    if (sesion == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final esPantallaAncha = constraints.maxWidth >= 860;
        final colorScheme = Theme.of(context).colorScheme;
        final esEjecutivo = sesion.esEjecutivo;
        final cuentaActiva = sesion.cuentaActiva;

        final paginas = <Widget>[
          _PanelResumenSesion(
            sessionController: widget.sessionController,
            onIrACatalogo: () => setState(() => _selectedIndex = 1),
            onIrAHistorial: () => setState(() => _selectedIndex = 2),
            onIrAPerfil: () => setState(() => _selectedIndex = 3),
            onIrAEjecutivo: esEjecutivo ? () => setState(() => _selectedIndex = 4) : null,
          ),
          CatalogScreen(
            sessionController: widget.sessionController,
            onProductoSeleccionado: (producto) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PurchaseScreen(
                    producto: producto,
                    sessionController: widget.sessionController,
                    onVerHistorial: () {
                      setState(() => _selectedIndex = 2);
                    },
                  ),
                ),
              );
            },
          ),
          HistoryScreen(
            sessionController: widget.sessionController,
          ),
          ProfileScreen(
            sessionController: widget.sessionController,
          ),
          if (esEjecutivo)
            ExecutiveScreen(
              sessionController: widget.sessionController,
            ),
        ];

        final indiceActual = _selectedIndex >= paginas.length ? 0 : _selectedIndex;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    constraints.maxWidth >= 600
                        ? 'Ecosistema Digital GestoPago'
                        : 'GestoPago',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cuentaActiva
                        ? colorScheme.primaryContainer
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        cuentaActiva
                            ? (sesion.plataforma == 'WEB'
                                ? Icons.computer_rounded
                                : Icons.smartphone_rounded)
                            : Icons.lock_outline,
                        size: 15,
                        color: cuentaActiva
                            ? colorScheme.onPrimaryContainer
                            : const Color(0xFF991B1B),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        cuentaActiva ? 'Sesión ${sesion.plataforma}' : 'Cuenta Inactiva',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: cuentaActiva
                              ? colorScheme.onPrimaryContainer
                              : const Color(0xFF991B1B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Verificar vigencia de sesión en el servidor',
                onPressed: () async {
                  final activa = await widget.sessionController.verificarVigenciaSesion();
                  if (!context.mounted) return;
                  if (activa) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sesión única verificada y activa en el servidor.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.sync_lock_rounded),
              ),
              IconButton(
                tooltip: 'Cerrar sesión',
                onPressed: _confirmarCierreSesion,
                icon: const Icon(Icons.logout_rounded),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Row(
            children: [
              if (esPantallaAncha && cuentaActiva)
                NavigationRail(
                  extended: constraints.maxWidth >= 1120,
                  selectedIndex: indiceActual,
                  onDestinationSelected: (idx) {
                    setState(() => _selectedIndex = idx);
                    widget.sessionController.verificarVigenciaSesion();
                  },
                  destinations: [
                    const NavigationRailDestination(
                      icon: Icon(Icons.verified_user_outlined),
                      selectedIcon: Icon(Icons.verified_user),
                      label: Text('Mi Cuenta y Sesión'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.storefront_outlined),
                      selectedIcon: Icon(Icons.storefront),
                      label: Text('Catálogo y Compras'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.receipt_long_outlined),
                      selectedIcon: Icon(Icons.receipt_long),
                      label: Text('Historial Exitoso'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.manage_accounts_outlined),
                      selectedIcon: Icon(Icons.manage_accounts),
                      label: Text('Mi Perfil'),
                    ),
                    if (esEjecutivo)
                      const NavigationRailDestination(
                        icon: Icon(Icons.admin_panel_settings_outlined),
                        selectedIcon: Icon(Icons.admin_panel_settings),
                        label: Text('Panel Ejecutivo'),
                      ),
                  ],
                ),
              if (esPantallaAncha && cuentaActiva) const VerticalDivider(width: 1),
              Expanded(
                child: cuentaActiva
                    ? paginas[indiceActual]
                    : _PanelCuentaInactiva(
                        sessionController: widget.sessionController,
                        onCerrarSesion: _confirmarCierreSesion,
                      ),
              ),
            ],
          ),
          bottomNavigationBar: (!cuentaActiva || esPantallaAncha)
              ? null
              : NavigationBar(
                  selectedIndex: indiceActual,
                  onDestinationSelected: (idx) {
                    setState(() => _selectedIndex = idx);
                    widget.sessionController.verificarVigenciaSesion();
                  },
                  destinations: [
                    const NavigationDestination(
                      icon: Icon(Icons.verified_user_outlined),
                      selectedIcon: Icon(Icons.verified_user),
                      label: 'Mi Sesión',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.storefront_outlined),
                      selectedIcon: Icon(Icons.storefront),
                      label: 'Catálogo',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.receipt_long_outlined),
                      selectedIcon: Icon(Icons.receipt_long),
                      label: 'Historial',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.manage_accounts_outlined),
                      selectedIcon: Icon(Icons.manage_accounts),
                      label: 'Perfil',
                    ),
                    if (esEjecutivo)
                      const NavigationDestination(
                        icon: Icon(Icons.admin_panel_settings_outlined),
                        selectedIcon: Icon(Icons.admin_panel_settings),
                        label: 'Ejecutivo',
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class _PanelResumenSesion extends StatelessWidget {
  const _PanelResumenSesion({
    required this.sessionController,
    required this.onIrACatalogo,
    required this.onIrAHistorial,
    required this.onIrAPerfil,
    this.onIrAEjecutivo,
  });

  final SessionController sessionController;
  final VoidCallback onIrACatalogo;
  final VoidCallback onIrAHistorial;
  final VoidCallback onIrAPerfil;
  final VoidCallback? onIrAEjecutivo;

  @override
  Widget build(BuildContext context) {
    final sesion = sessionController.sesionActual!;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BbvaClientCard(
                nombreTitular: sesion.nombreCliente ?? sesion.correo,
                correo: sesion.correo,
                plataforma: sesion.plataforma,
                numeroCuenta: sesion.numeroCuenta,
                saldoCuenta: sesion.saldoCuenta,
                esEjecutivo: sesion.esEjecutivo,
                cuentaActiva: sesion.cuentaActiva,
                clienteId: sesion.clienteId,
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.security_rounded, color: colorScheme.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Estado de Sesión Única Activa',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tu sesión se encuentra protegida con JWT y vinculada exclusivamente a la plataforma ${sesion.plataforma}. '
                        'Si intentas iniciar sesión desde otro dispositivo, el servidor detectará esta sesión activa y solicitará confirmación antes de reemplazarla.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: onIrACatalogo,
                            icon: const Icon(Icons.storefront_outlined),
                            label: const Text('Explorar Catálogo de Productos'),
                          ),
                          OutlinedButton.icon(
                            onPressed: onIrAHistorial,
                            icon: const Icon(Icons.receipt_long_outlined),
                            label: const Text('Consultar Historial de Compras'),
                          ),
                          OutlinedButton.icon(
                            onPressed: onIrAPerfil,
                            icon: const Icon(Icons.manage_accounts_outlined),
                            label: const Text('Editar Perfil y Cuenta'),
                          ),
                          if (onIrAEjecutivo != null)
                            FilledButton.tonalIcon(
                              onPressed: onIrAEjecutivo,
                              icon: const Icon(Icons.admin_panel_settings_outlined),
                              label: const Text('Abrir Panel Ejecutivo'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PanelCuentaInactiva extends StatefulWidget {
  const _PanelCuentaInactiva({
    required this.sessionController,
    required this.onCerrarSesion,
  });

  final SessionController sessionController;
  final VoidCallback onCerrarSesion;

  @override
  State<_PanelCuentaInactiva> createState() => _PanelCuentaInactivaState();
}

class _PanelCuentaInactivaState extends State<_PanelCuentaInactiva> {
  final _confirmacionCtrl = TextEditingController();
  bool _reactivando = false;
  String? _error;

  @override
  void dispose() {
    _confirmacionCtrl.dispose();
    super.dispose();
  }

  Future<void> _reactivarCuenta() async {
    if (_confirmacionCtrl.text.trim().toUpperCase() != 'ACTIVAR') {
      setState(() => _error = 'Escribe ACTIVAR para confirmar la reactivación.');
      return;
    }

    setState(() {
      _reactivando = true;
      _error = null;
    });
    try {
      var clienteId = widget.sessionController.sesionActual?.clienteId;
      if (clienteId == null) {
        await widget.sessionController.verificarVigenciaSesion();
        clienteId = widget.sessionController.sesionActual?.clienteId;
      }
      if (clienteId == null) {
        if (!mounted) return;
        setState(() => _error = 'No se identificó el cliente asociado.');
        return;
      }

      final clienteService = ClienteService(apiClient: widget.sessionController.apiClient);
      await clienteService.reactivarCliente(clienteId);
      widget.sessionController.marcarCuentaActivaLocal(true);
      await widget.sessionController.verificarVigenciaSesion();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'No fue posible reactivar tu cuenta en este momento.');
    } finally {
      if (mounted) {
        setState(() => _reactivando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sesion = widget.sessionController.sesionActual;
    if (sesion == null) {
      return const SizedBox.shrink();
    }

    final habilitar = _confirmacionCtrl.text.trim().toUpperCase() == 'ACTIVAR' && !_reactivando;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lock_person_outlined, size: 32, color: Color(0xFFB45309)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tu cuenta está dada de baja temporalmente',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Mientras permanezca inactiva no puedes realizar compras, movimientos ni editar tus datos o contraseña.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Titular: ${sesion.nombreCliente ?? sesion.correo}'),
                        Text('Correo: ${sesion.correo}'),
                        if (sesion.numeroCuenta != null) Text('Cuenta: ${sesion.numeroCuenta}'),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Color(0xFF991B1B)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmacionCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Escribe ACTIVAR para reactivar tu cuenta',
                      hintText: 'ACTIVAR',
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: habilitar ? _reactivarCuenta : null,
                    icon: const Icon(Icons.restore_outlined),
                    label: Text(_reactivando ? 'Reactivando...' : 'Reactivar mi cuenta'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _reactivando ? null : widget.onCerrarSesion,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Cerrar sesión'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
