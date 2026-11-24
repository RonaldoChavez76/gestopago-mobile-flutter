import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/network/api_client.dart';
import '../models/cliente_models.dart';
import '../models/ejecutivo_models.dart';
import '../models/transaction_models.dart';
import '../services/cliente_service.dart';
import '../services/ejecutivo_service.dart';
import '../services/transaction_service.dart';
import '../state/session_controller.dart';
import '../utils/input_formatters.dart';
import '../widgets/responsive_form_grid.dart';
import 'purchase_screen.dart';

enum _SeccionEjecutivo { clientes, cuentas, usuarios }

class ExecutiveScreen extends StatefulWidget {
  const ExecutiveScreen({
    required this.sessionController,
    this.ejecutivoService,
    this.clienteService,
    this.transactionService,
    super.key,
  });

  final SessionController sessionController;
  final EjecutivoService? ejecutivoService;
  final ClienteService? clienteService;
  final TransactionService? transactionService;

  @override
  State<ExecutiveScreen> createState() => _ExecutiveScreenState();
}

class _ExecutiveScreenState extends State<ExecutiveScreen> {
  late final EjecutivoService _ejecutivoService;
  late final ClienteService _clienteService;
  late final TransactionService _transactionService;

  _SeccionEjecutivo _seccion = _SeccionEjecutivo.clientes;
  String? _avisoGlobal;
  String? _errorGlobal;

  final _cliNombreCtrl = TextEditingController();
  final _cliCurpCtrl = TextEditingController();
  final _cliRfcCtrl = TextEditingController();
  final _cliCorreoCtrl = TextEditingController();
  final _cliCuentaCtrl = TextEditingController();
  final _cliIdCtrl = TextEditingController();
  final _cliDesdeCtrl = TextEditingController();
  final _cliHastaCtrl = TextEditingController();
  EstadoActivoFiltro _cliEstadoActivo = EstadoActivoFiltro.todos;
  int _cliPage = 0;
  bool _cargandoClientes = false;
  PageResponse<ClienteResumenEjecutivo>? _clientesPage;

  final _ctaNumeroCtrl = TextEditingController();
  final _ctaClienteIdCtrl = TextEditingController();
  bool _ctaSoloActivas = true;
  int _ctaPage = 0;
  bool _cargandoCuentas = false;
  PageResponse<CuentaResumenEjecutivo>? _cuentasPage;

  final _usrIdCtrl = TextEditingController();
  bool _cargandoUsuario = false;
  UsuarioResumenEjecutivo? _usuarioConsultado;

  final _audClienteIdCtrl = TextEditingController();
  final _audCuentaCtrl = TextEditingController();
  final _audUpcCtrl = TextEditingController();
  bool _cargandoAuditoria = false;
  bool _auditoriaConsultada = false;
  List<PurchaseTransactionResult> _comprasAuditadas = const [];

  @override
  void initState() {
    super.initState();
    final apiClient = widget.sessionController.apiClient;
    _ejecutivoService = widget.ejecutivoService ?? EjecutivoService(apiClient: apiClient);
    _clienteService = widget.clienteService ?? ClienteService(apiClient: apiClient);
    _transactionService = widget.transactionService ?? TransactionService(apiClient: apiClient);
    _buscarClientes();
  }

  @override
  void dispose() {
    _cliNombreCtrl.dispose();
    _cliCurpCtrl.dispose();
    _cliRfcCtrl.dispose();
    _cliCorreoCtrl.dispose();
    _cliCuentaCtrl.dispose();
    _cliIdCtrl.dispose();
    _cliDesdeCtrl.dispose();
    _cliHastaCtrl.dispose();
    _ctaNumeroCtrl.dispose();
    _ctaClienteIdCtrl.dispose();
    _usrIdCtrl.dispose();
    _audClienteIdCtrl.dispose();
    _audCuentaCtrl.dispose();
    _audUpcCtrl.dispose();
    super.dispose();
  }

  FiltroBusquedaClientes _construirFiltrosClientes(int page) {
    return FiltroBusquedaClientes(
      nombre: _cliNombreCtrl.text,
      curp: _cliCurpCtrl.text,
      rfc: _cliRfcCtrl.text,
      correo: _cliCorreoCtrl.text,
      numeroCuenta: _cliCuentaCtrl.text,
      clienteId: _cliIdCtrl.text,
      estadoActivo: _cliEstadoActivo,
      registradoDesde: _cliDesdeCtrl.text,
      registradoHasta: _cliHastaCtrl.text,
      page: page,
      size: 10,
    );
  }

  Future<void> _buscarClientes({int? page}) async {
    final targetPage = page ?? _cliPage;
    final filtros = _construirFiltrosClientes(targetPage);
    final err = filtros.validar();
    if (err != null) {
      setState(() => _errorGlobal = err);
      return;
    }

    setState(() {
      _cliPage = targetPage;
      _cargandoClientes = true;
      _errorGlobal = null;
    });
    try {
      final res = await _ejecutivoService.buscarClientes(filtros);
      if (!mounted) return;
      setState(() => _clientesPage = res);
    } on ApiException catch (e) {
      if (e.statusCode == 401 || !mounted) return;
      setState(() => _errorGlobal = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorGlobal = 'No fue posible consultar clientes en el servidor.');
    } finally {
      if (mounted) {
        setState(() => _cargandoClientes = false);
      }
    }
  }

  void _limpiarFiltrosClientes() {
    _cliNombreCtrl.clear();
    _cliCurpCtrl.clear();
    _cliRfcCtrl.clear();
    _cliCorreoCtrl.clear();
    _cliCuentaCtrl.clear();
    _cliIdCtrl.clear();
    _cliDesdeCtrl.clear();
    _cliHastaCtrl.clear();
    setState(() {
      _cliEstadoActivo = EstadoActivoFiltro.todos;
      _cliPage = 0;
    });
    _buscarClientes(page: 0);
  }

  Future<void> _buscarCuentas({int? page}) async {
    final targetPage = page ?? _ctaPage;
    final filtros = FiltroBusquedaCuentas(
      numeroCuenta: _ctaNumeroCtrl.text,
      clienteId: _ctaClienteIdCtrl.text,
      soloActivas: _ctaSoloActivas,
      page: targetPage,
      size: 10,
    );
    final err = filtros.validar();
    if (err != null) {
      setState(() => _errorGlobal = err);
      return;
    }

    setState(() {
      _ctaPage = targetPage;
      _cargandoCuentas = true;
      _errorGlobal = null;
    });
    try {
      final res = await _ejecutivoService.buscarCuentas(filtros);
      if (!mounted) return;
      setState(() => _cuentasPage = res);
    } on ApiException catch (e) {
      if (e.statusCode == 401 || !mounted) return;
      setState(() => _errorGlobal = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorGlobal = 'No fue posible consultar las cuentas bancarias.');
    } finally {
      if (mounted) {
        setState(() => _cargandoCuentas = false);
      }
    }
  }

  void _limpiarFiltrosCuentas() {
    _ctaNumeroCtrl.clear();
    _ctaClienteIdCtrl.clear();
    setState(() {
      _ctaSoloActivas = true;
      _ctaPage = 0;
    });
    _buscarCuentas(page: 0);
  }

  Future<void> _consultarUsuario() async {
    final idLimpio = _usrIdCtrl.text.trim();
    final id = int.tryParse(idLimpio);
    if (id == null || id <= 0) {
      setState(() => _errorGlobal = 'Ingresa un ID de usuario numérico positivo.');
      return;
    }

    setState(() {
      _cargandoUsuario = true;
      _errorGlobal = null;
      _usuarioConsultado = null;
    });
    try {
      final usr = await _ejecutivoService.consultarUsuarioPorId(id);
      if (!mounted) return;
      setState(() => _usuarioConsultado = usr);
    } on ApiException catch (e) {
      if (e.statusCode == 401 || !mounted) return;
      setState(() => _errorGlobal = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorGlobal = 'No fue posible consultar el usuario solicitado.');
    } finally {
      if (mounted) {
        setState(() => _cargandoUsuario = false);
      }
    }
  }

  Future<void> _consultarAuditoriaCompras() async {
    final idLimpio = _audClienteIdCtrl.text.trim();
    final cuentaLimpia = _audCuentaCtrl.text.trim();

    if (idLimpio.isEmpty && cuentaLimpia.isEmpty) {
      setState(() => _errorGlobal = 'Ingresa al menos un ID de cliente o número de cuenta.');
      return;
    }
    int? clienteId;
    if (idLimpio.isNotEmpty) {
      clienteId = int.tryParse(idLimpio);
      if (clienteId == null || clienteId <= 0) {
        setState(() => _errorGlobal = 'El ID de cliente para auditoría debe ser positivo.');
        return;
      }
    }

    setState(() {
      _cargandoAuditoria = true;
      _errorGlobal = null;
    });
    try {
      final lista = await _transactionService.obtenerHistorialComprasExitosas(
        clienteId: clienteId,
        numeroCuenta: cuentaLimpia.isEmpty ? null : cuentaLimpia,
      );
      if (!mounted) return;
      setState(() {
        _comprasAuditadas = lista;
        _auditoriaConsultada = true;
      });
    } on ApiException catch (e) {
      if (e.statusCode == 401 || !mounted) return;
      setState(() => _errorGlobal = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorGlobal = 'No fue posible consultar las compras exitosas.');
    } finally {
      if (mounted) {
        setState(() => _cargandoAuditoria = false);
      }
    }
  }

  Future<void> _consultarPorUpc() async {
    final upc = _audUpcCtrl.text.trim();
    if (upc.isEmpty) {
      setState(() => _errorGlobal = 'Ingresa un folio UPC para consultar el comprobante.');
      return;
    }

    setState(() {
      _cargandoAuditoria = true;
      _errorGlobal = null;
    });
    try {
      final detalle = await _transactionService.consultarDetallePorUpc(upc);
      if (!mounted) return;
      await _abrirComprobante(detalle);
    } on ApiException catch (e) {
      if (e.statusCode == 401 || !mounted) return;
      setState(() => _errorGlobal = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorGlobal = 'No fue posible consultar el folio UPC en el servidor.');
    } finally {
      if (mounted) {
        setState(() => _cargandoAuditoria = false);
      }
    }
  }

  Future<void> _abrirEdicionCliente(int clienteId) async {
    setState(() => _errorGlobal = null);
    try {
      final detalle = await _clienteService.consultarPerfil(clienteId);
      if (!mounted) return;
      if (!detalle.activo) {
        setState(() {
          _errorGlobal =
              'El cliente #${detalle.id} está dado de baja. Reactívalo primero antes de editar sus datos.';
        });
        return;
      }
      final actualizado = await Navigator.of(context).push<ClientePerfil>(
        MaterialPageRoute(
          builder: (_) => _ExecutiveClientEditScreen(
            cliente: detalle,
            clienteService: _clienteService,
          ),
        ),
      );
      if (actualizado != null && mounted) {
        setState(() {
          _avisoGlobal =
              'Expediente del cliente #${actualizado.id} (${actualizado.nombreCompleto}) actualizado.';
        });
        await _buscarClientes(page: _cliPage);
      }
    } on ApiException catch (e) {
      if (e.statusCode == 401 || !mounted) return;
      setState(() => _errorGlobal = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorGlobal = 'No fue posible cargar el expediente del cliente.');
    }
  }

  Future<void> _confirmarReactivarCliente(ClientePerfil cliente) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reactivar Cliente #${cliente.id}'),
        content: Text(
          'Se reactivará al cliente ${cliente.nombreCompleto}, su usuario de acceso y sus cuentas bancarias inactivas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.restore_outlined),
            label: const Text('Reactivar Cliente'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    setState(() => _errorGlobal = null);
    try {
      await _clienteService.reactivarCliente(cliente.id);
      if (!mounted) return;
      setState(() {
        _avisoGlobal =
            'Cliente #${cliente.id} (${cliente.nombreCompleto}) reactivado correctamente.';
      });
      await _buscarClientes(page: _cliPage);
    } on ApiException catch (e) {
      if (e.statusCode == 401 || !mounted) return;
      setState(() => _errorGlobal = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorGlobal = 'No fue posible reactivar al cliente.');
    }
  }

  Future<void> _confirmarBajaCliente(ClientePerfil cliente) async {
    String confirmacion = '';
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('Baja Lógica Cliente #${cliente.id}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Se desactivará al cliente ${cliente.nombreCompleto}, su acceso y cuentas bancarias asociadas.',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Escribe BAJA para confirmar',
                    hintText: 'BAJA',
                  ),
                  onChanged: (valor) => setModalState(() => confirmacion = valor),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: confirmacion.trim().toUpperCase() == 'BAJA'
                  ? () => Navigator.pop(ctx, true)
                  : null,
              child: const Text('Aplicar Baja'),
            ),
          ],
        ),
      ),
    );

    if (confirmar != true || !mounted) return;

    setState(() => _errorGlobal = null);
    try {
      await _clienteService.darDeBaja(cliente.id);
      if (!mounted) return;
      setState(() {
        _avisoGlobal =
            'Baja lógica aplicada al cliente #${cliente.id} (${cliente.nombreCompleto}).';
      });
      await _buscarClientes(page: _cliPage);
    } on ApiException catch (e) {
      if (e.statusCode == 401 || !mounted) return;
      setState(() => _errorGlobal = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorGlobal = 'No fue posible dar de baja al cliente.');
    }
  }

  void _irACuentasDeCliente(int clienteId) {
    _ctaNumeroCtrl.clear();
    _ctaClienteIdCtrl.text = clienteId.toString();
    setState(() {
      _ctaSoloActivas = false;
      _seccion = _SeccionEjecutivo.cuentas;
    });
    _buscarCuentas(page: 0);
  }

  void _irAAuditoria({int? clienteId, String? numeroCuenta}) {
    _audClienteIdCtrl.text = clienteId != null ? clienteId.toString() : '';
    _audCuentaCtrl.text = numeroCuenta ?? '';
    setState(() => _seccion = _SeccionEjecutivo.usuarios);
    _consultarAuditoriaCompras();
  }

  Future<void> _abrirComprobante(PurchaseTransactionResult compra) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _AuditoriaReceiptDialog(
        compraInicial: compra,
        transactionService: _transactionService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0F172A),
                      colorScheme.primary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.admin_panel_settings, color: Color(0xFFFDE68A), size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Panel Operativo Ejecutivo',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Administra clientes, cuentas bancarias, usuarios y auditoría transaccional.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.88)),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE68A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Rol Autorizado: EJECUTIVO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF78350F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<_SeccionEjecutivo>(
                selected: {_seccion},
                onSelectionChanged: (seleccion) {
                  final nueva = seleccion.first;
                  setState(() {
                    _seccion = nueva;
                    _errorGlobal = null;
                  });
                  if (nueva == _SeccionEjecutivo.cuentas &&
                      _cuentasPage == null &&
                      !_cargandoCuentas) {
                    _buscarCuentas(page: 0);
                  }
                },
                segments: const [
                  ButtonSegment(
                    value: _SeccionEjecutivo.clientes,
                    icon: Icon(Icons.people_outline),
                    label: Text('Clientes'),
                  ),
                  ButtonSegment(
                    value: _SeccionEjecutivo.cuentas,
                    icon: Icon(Icons.credit_card_outlined),
                    label: Text('Cuentas'),
                  ),
                  ButtonSegment(
                    value: _SeccionEjecutivo.usuarios,
                    icon: Icon(Icons.verified_user_outlined),
                    label: Text('Usuarios'),
                  ),
                ],
              ),
              if (_avisoGlobal != null) ...[
                const SizedBox(height: 12),
                _MensajeBanner(
                  mensaje: _avisoGlobal!,
                  esError: false,
                  onCerrar: () => setState(() => _avisoGlobal = null),
                ),
              ],
              if (_errorGlobal != null) ...[
                const SizedBox(height: 12),
                _MensajeBanner(
                  mensaje: _errorGlobal!,
                  esError: true,
                  onCerrar: () => setState(() => _errorGlobal = null),
                ),
              ],
              const SizedBox(height: 16),
              if (_seccion == _SeccionEjecutivo.clientes) _construirSeccionClientes(context),
              if (_seccion == _SeccionEjecutivo.cuentas) _construirSeccionCuentas(context),
              if (_seccion == _SeccionEjecutivo.usuarios) _construirSeccionUsuarios(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirSeccionClientes(BuildContext context) {
    final page = _clientesPage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Búsqueda Combinada de Clientes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _cliNombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre o apellidos',
                    hintText: 'Ej. Ana López',
                  ),
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final anchoCampo = constraints.maxWidth >= 720
                        ? (constraints.maxWidth - 20) / 3
                        : constraints.maxWidth >= 480
                            ? (constraints.maxWidth - 10) / 2
                            : constraints.maxWidth;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        SizedBox(
                          width: anchoCampo,
                          child: TextField(
                            controller: _cliCurpCtrl,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(labelText: 'CURP'),
                          ),
                        ),
                        SizedBox(
                          width: anchoCampo,
                          child: TextField(
                            controller: _cliRfcCtrl,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(labelText: 'RFC'),
                          ),
                        ),
                        SizedBox(
                          width: anchoCampo,
                          child: TextField(
                            controller: _cliCorreoCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(labelText: 'Correo electrónico'),
                          ),
                        ),
                        SizedBox(
                          width: anchoCampo,
                          child: TextField(
                            controller: _cliCuentaCtrl,
                            decoration: const InputDecoration(labelText: 'Número de cuenta'),
                          ),
                        ),
                        SizedBox(
                          width: anchoCampo,
                          child: TextField(
                            controller: _cliIdCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(labelText: 'ID de cliente'),
                          ),
                        ),
                        SizedBox(
                          width: anchoCampo,
                          child: DropdownButtonFormField<EstadoActivoFiltro>(
                            isExpanded: true,
                            initialValue: _cliEstadoActivo,
                            decoration: const InputDecoration(labelText: 'Estado'),
                            items: const [
                              DropdownMenuItem(
                                value: EstadoActivoFiltro.todos,
                                child: Text('Todos', overflow: TextOverflow.ellipsis),
                              ),
                              DropdownMenuItem(
                                value: EstadoActivoFiltro.activos,
                                child: Text('Solo activos', overflow: TextOverflow.ellipsis),
                              ),
                              DropdownMenuItem(
                                value: EstadoActivoFiltro.inactivos,
                                child: Text('Solo inactivos', overflow: TextOverflow.ellipsis),
                              ),
                            ],
                            onChanged: (valor) {
                              if (valor != null) {
                                setState(() => _cliEstadoActivo = valor);
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: anchoCampo,
                          child: TextField(
                            controller: _cliDesdeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Desde (AAAA-MM-DD)',
                            ),
                          ),
                        ),
                        SizedBox(
                          width: anchoCampo,
                          child: TextField(
                            controller: _cliHastaCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Hasta (AAAA-MM-DD)',
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: _cargandoClientes ? null : () => _buscarClientes(page: 0),
                      icon: const Icon(Icons.search),
                      label: Text(_cargandoClientes ? 'Buscando...' : 'Buscar clientes'),
                    ),
                    OutlinedButton(
                      onPressed: _cargandoClientes ? null : _limpiarFiltrosClientes,
                      child: const Text('Limpiar filtros'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (_cargandoClientes)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (page == null || page.content.isEmpty)
          const Card(
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No se encontraron clientes con los filtros indicados.'),
            ),
          )
        else ...[
          Text(
            'Resultados de Clientes (${page.totalElements})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...page.content.map((item) {
            final p = item.perfil;
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Chip(label: Text('ID #${p.id}')),
                        Text(
                          p.nombreCompleto.isEmpty ? 'Cliente #${p.id}' : p.nombreCompleto,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Chip(
                          backgroundColor: p.activo ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                          label: Text(p.activo ? 'Activo' : 'Inactivo'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Correo: ${p.correo} • Tel: ${p.telefonoMovil}'),
                    Text('CURP: ${p.curp} • RFC: ${p.rfc}'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (p.activo)
                          OutlinedButton.icon(
                            onPressed: () => _abrirEdicionCliente(p.id),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Editar'),
                          ),
                        OutlinedButton.icon(
                          onPressed: () => _irACuentasDeCliente(p.id),
                          icon: const Icon(Icons.credit_card_outlined, size: 18),
                          label: const Text('Cuentas'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _irAAuditoria(clienteId: p.id),
                          icon: const Icon(Icons.receipt_long_outlined, size: 18),
                          label: const Text('Auditoría'),
                        ),
                        if (p.activo)
                          OutlinedButton.icon(
                            onPressed: () => _confirmarBajaCliente(p),
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Dar de baja'),
                          )
                        else
                          FilledButton.tonalIcon(
                            onPressed: () => _confirmarReactivarCliente(p),
                            icon: const Icon(Icons.restore_outlined, size: 18),
                            label: const Text('Reactivar'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          if (page.totalPages > 1)
            _BarraPaginacion(
              page: page.page,
              totalPages: page.totalPages,
              first: page.first,
              last: page.last,
              deshabilitado: _cargandoClientes,
              onAnterior: () => _buscarClientes(page: page.page - 1),
              onSiguiente: () => _buscarClientes(page: page.page + 1),
            ),
        ],
      ],
    );
  }

  Widget _construirSeccionCuentas(BuildContext context) {
    final page = _cuentasPage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Búsqueda de Cuentas Bancarias',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _ctaNumeroCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Número de cuenta',
                    hintText: 'Ej. 9941467045485002',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _ctaClienteIdCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'ID de cliente titular'),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Solo cuentas activas'),
                  value: _ctaSoloActivas,
                  onChanged: (valor) => setState(() => _ctaSoloActivas = valor),
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: _cargandoCuentas ? null : () => _buscarCuentas(page: 0),
                      icon: const Icon(Icons.search),
                      label: Text(_cargandoCuentas ? 'Buscando...' : 'Buscar cuentas'),
                    ),
                    OutlinedButton(
                      onPressed: _cargandoCuentas ? null : _limpiarFiltrosCuentas,
                      child: const Text('Limpiar filtros'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (_cargandoCuentas)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (page == null || page.content.isEmpty)
          const Card(
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No se encontraron cuentas con los criterios seleccionados.'),
            ),
          )
        else ...[
          Text(
            'Cuentas Encontradas (${page.totalElements})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...page.content.map(
            (cuenta) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          cuenta.numeroCuenta,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Chip(label: Text(cuenta.estatus)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Saldo: \$${cuenta.saldo.toStringAsFixed(2)} MXN • Titular Cliente #${cuenta.clienteId}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _abrirEdicionCliente(cuenta.clienteId),
                          icon: const Icon(Icons.person_outline, size: 18),
                          label: const Text('Ver titular'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _irAAuditoria(
                            clienteId: cuenta.clienteId,
                            numeroCuenta: cuenta.numeroCuenta,
                          ),
                          icon: const Icon(Icons.receipt_long_outlined, size: 18),
                          label: const Text('Auditar compras'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (page.totalPages > 1)
            _BarraPaginacion(
              page: page.page,
              totalPages: page.totalPages,
              first: page.first,
              last: page.last,
              deshabilitado: _cargandoCuentas,
              onAnterior: () => _buscarCuentas(page: page.page - 1),
              onSiguiente: () => _buscarCuentas(page: page.page + 1),
            ),
        ],
      ],
    );
  }

  Widget _construirSeccionUsuarios(BuildContext context) {
    final usuario = _usuarioConsultado;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Consulta de Usuario del Sistema',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _usrIdCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'ID de usuario *',
                    hintText: 'Ej. 2',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _cargandoUsuario ? null : _consultarUsuario,
                  icon: const Icon(Icons.search),
                  label: Text(_cargandoUsuario ? 'Consultando...' : 'Consultar usuario'),
                ),
                if (usuario != null) ...[
                  const SizedBox(height: 14),
                  const Divider(),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Chip(label: Text('Usuario #${usuario.id}')),
                      Text(usuario.correo, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Chip(label: Text(usuario.activo ? 'Activo' : 'Inactivo')),
                    ],
                  ),
                  if (usuario.clienteId != null) ...[
                    const SizedBox(height: 6),
                    Text('Cliente asociado #${usuario.clienteId}'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _abrirEdicionCliente(usuario.clienteId!),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Editar titular'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _irAAuditoria(clienteId: usuario.clienteId),
                          icon: const Icon(Icons.receipt_long_outlined, size: 18),
                          label: const Text('Auditar compras del titular'),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Auditoría de Compras Exitosas y Folio UPC',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _audClienteIdCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'ID de cliente a auditar'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _audCuentaCtrl,
                  decoration: const InputDecoration(labelText: 'Número de cuenta (opcional)'),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: _cargandoAuditoria ? null : _consultarAuditoriaCompras,
                  icon: const Icon(Icons.history_edu_outlined),
                  label: Text(
                    _cargandoAuditoria ? 'Consultando...' : 'Consultar historial exitoso',
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                TextField(
                  controller: _audUpcCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Folio UPC directo',
                    hintText: 'Ej. 7501234567890',
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _cargandoAuditoria ? null : _consultarPorUpc,
                  icon: const Icon(Icons.qr_code_scanner_outlined),
                  label: const Text('Consultar detalle UPC'),
                ),
              ],
            ),
          ),
        ),
        if (_auditoriaConsultada) ...[
          const SizedBox(height: 14),
          Text(
            'Operaciones Exitosas Encontradas (${_comprasAuditadas.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_comprasAuditadas.isEmpty)
            const Card(
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No existen compras exitosas para ese cliente o cuenta.'),
              ),
            )
          else
            ..._comprasAuditadas.map(
              (compra) => Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    compra.nombreProducto ?? compra.upc,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('UPC: ${compra.upc} • ${compra.fechaMostrar}'),
                  trailing: Text(
                    '\$${compra.monto.toStringAsFixed(2)} MXN',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () => _abrirComprobante(compra),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _MensajeBanner extends StatelessWidget {
  const _MensajeBanner({
    required this.mensaje,
    required this.esError,
    required this.onCerrar,
  });

  final String mensaje;
  final bool esError;
  final VoidCallback onCerrar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: esError ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            esError ? Icons.error_outline : Icons.check_circle_outline,
            color: esError ? const Color(0xFF991B1B) : const Color(0xFF065F46),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(
                color: esError ? const Color(0xFF991B1B) : const Color(0xFF065F46),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: onCerrar,
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }
}

class _BarraPaginacion extends StatelessWidget {
  const _BarraPaginacion({
    required this.page,
    required this.totalPages,
    required this.first,
    required this.last,
    required this.deshabilitado,
    required this.onAnterior,
    required this.onSiguiente,
  });

  final int page;
  final int totalPages;
  final bool first;
  final bool last;
  final bool deshabilitado;
  final VoidCallback onAnterior;
  final VoidCallback onSiguiente;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            onPressed: (first || deshabilitado) ? null : onAnterior,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Anterior'),
          ),
          Flexible(
            child: Text(
              'Página ${page + 1} / $totalPages',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          OutlinedButton.icon(
            onPressed: (last || deshabilitado) ? null : onSiguiente,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Siguiente'),
          ),
        ],
      ),
    );
  }
}

class _AuditoriaReceiptDialog extends StatefulWidget {
  const _AuditoriaReceiptDialog({
    required this.compraInicial,
    required this.transactionService,
  });

  final PurchaseTransactionResult compraInicial;
  final TransactionService transactionService;

  @override
  State<_AuditoriaReceiptDialog> createState() => _AuditoriaReceiptDialogState();
}

class _AuditoriaReceiptDialogState extends State<_AuditoriaReceiptDialog> {
  late PurchaseTransactionResult _detalle;
  bool _verificando = false;
  String? _aviso;
  String? _error;

  @override
  void initState() {
    super.initState();
    _detalle = widget.compraInicial;
  }

  Future<void> _verificar() async {
    setState(() {
      _verificando = true;
      _aviso = null;
      _error = null;
    });
    try {
      final actualizado = await widget.transactionService.consultarDetallePorUpc(_detalle.upc);
      if (!mounted) return;
      setState(() {
        _detalle = actualizado;
        _aviso = 'Comprobante verificado en el servidor.';
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'No fue posible verificar el comprobante.');
    } finally {
      if (mounted) {
        setState(() => _verificando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Detalle de Compra Exitosa',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _verificando ? null : _verificar,
                icon: const Icon(Icons.refresh),
                label: Text(_verificando ? 'Verificando...' : 'Verificar en servidor por UPC'),
              ),
              if (_aviso != null) ...[
                const SizedBox(height: 8),
                Text(_aviso!, style: const TextStyle(color: Color(0xFF065F46))),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Color(0xFF991B1B))),
              ],
              const SizedBox(height: 12),
              PurchaseResultReceiptCard(
                resultado: _detalle,
                onNuevaOperacion: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExecutiveClientEditScreen extends StatefulWidget {
  const _ExecutiveClientEditScreen({
    required this.cliente,
    required this.clienteService,
  });

  final ClientePerfil cliente;
  final ClienteService clienteService;

  @override
  State<_ExecutiveClientEditScreen> createState() => _ExecutiveClientEditScreenState();
}

class _ExecutiveClientEditScreenState extends State<_ExecutiveClientEditScreen> {
  late final TextEditingController _primerNombreCtrl;
  late final TextEditingController _segundoNombreCtrl;
  late final TextEditingController _apellidoPaternoCtrl;
  late final TextEditingController _apellidoMaternoCtrl;
  late final TextEditingController _fechaNacCtrl;
  late final TextEditingController _sexoCtrl;
  late final TextEditingController _nacionalidadCtrl;
  late final TextEditingController _estadoCivilCtrl;
  late final TextEditingController _correoCtrl;
  late final TextEditingController _telefonoMovilCtrl;
  late final TextEditingController _telefonoAltCtrl;
  late final TextEditingController _ocupacionCtrl;
  late final TextEditingController _empresaCtrl;
  late final TextEditingController _ingresoCtrl;
  late final TextEditingController _calleCtrl;
  late final TextEditingController _numExtCtrl;
  late final TextEditingController _numIntCtrl;
  late final TextEditingController _coloniaCtrl;
  late final TextEditingController _municipioCtrl;
  late final TextEditingController _estadoCtrl;
  late final TextEditingController _cpCtrl;
  late final TextEditingController _paisCtrl;

  bool _guardando = false;
  String? _error;
  Map<String, String> _erroresCampos = const {};

  void _limpiarErrorCampo(String clave) {
    if (_erroresCampos.containsKey(clave)) {
      final copia = Map<String, String>.from(_erroresCampos);
      copia.remove(clave);
      setState(() => _erroresCampos = copia);
    }
  }

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;
    _primerNombreCtrl = TextEditingController(text: c.primerNombre);
    _segundoNombreCtrl = TextEditingController(text: c.segundoNombre);
    _apellidoPaternoCtrl = TextEditingController(text: c.apellidoPaterno);
    _apellidoMaternoCtrl = TextEditingController(text: c.apellidoMaterno);
    _fechaNacCtrl = TextEditingController(text: c.fechaNacimiento);
    _sexoCtrl = TextEditingController(text: c.sexo);
    _nacionalidadCtrl = TextEditingController(text: c.nacionalidad);
    _estadoCivilCtrl = TextEditingController(text: c.estadoCivil);
    _correoCtrl = TextEditingController(text: c.correo);
    _telefonoMovilCtrl = TextEditingController(text: c.telefonoMovil);
    _telefonoAltCtrl = TextEditingController(text: c.telefonoAlternativo);
    _ocupacionCtrl = TextEditingController(text: c.ocupacion);
    _empresaCtrl = TextEditingController(text: c.empresa);
    _ingresoCtrl = TextEditingController(text: c.ingresoMensual);
    _calleCtrl = TextEditingController(text: c.domicilio.calle);
    _numExtCtrl = TextEditingController(text: c.domicilio.numeroExterior);
    _numIntCtrl = TextEditingController(text: c.domicilio.numeroInterior);
    _coloniaCtrl = TextEditingController(text: c.domicilio.colonia);
    _municipioCtrl = TextEditingController(text: c.domicilio.municipio);
    _estadoCtrl = TextEditingController(text: c.domicilio.estado);
    _cpCtrl = TextEditingController(text: c.domicilio.codigoPostal);
    _paisCtrl = TextEditingController(text: c.domicilio.pais);
  }

  @override
  void dispose() {
    _primerNombreCtrl.dispose();
    _segundoNombreCtrl.dispose();
    _apellidoPaternoCtrl.dispose();
    _apellidoMaternoCtrl.dispose();
    _fechaNacCtrl.dispose();
    _sexoCtrl.dispose();
    _nacionalidadCtrl.dispose();
    _estadoCivilCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoMovilCtrl.dispose();
    _telefonoAltCtrl.dispose();
    _ocupacionCtrl.dispose();
    _empresaCtrl.dispose();
    _ingresoCtrl.dispose();
    _calleCtrl.dispose();
    _numExtCtrl.dispose();
    _numIntCtrl.dispose();
    _coloniaCtrl.dispose();
    _municipioCtrl.dispose();
    _estadoCtrl.dispose();
    _cpCtrl.dispose();
    _paisCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final perfilEditado = ClientePerfil(
      id: widget.cliente.id,
      primerNombre: _primerNombreCtrl.text,
      segundoNombre: _segundoNombreCtrl.text,
      apellidoPaterno: _apellidoPaternoCtrl.text,
      apellidoMaterno: _apellidoMaternoCtrl.text,
      fechaNacimiento: _fechaNacCtrl.text,
      curp: widget.cliente.curp,
      rfc: widget.cliente.rfc,
      sexo: _sexoCtrl.text,
      nacionalidad: _nacionalidadCtrl.text,
      estadoCivil: _estadoCivilCtrl.text,
      correo: _correoCtrl.text,
      telefonoMovil: _telefonoMovilCtrl.text,
      telefonoAlternativo: _telefonoAltCtrl.text,
      ocupacion: _ocupacionCtrl.text,
      empresa: _empresaCtrl.text,
      ingresoMensual: _ingresoCtrl.text,
      activo: widget.cliente.activo,
      domicilio: DomicilioPerfil(
        calle: _calleCtrl.text,
        numeroExterior: _numExtCtrl.text,
        numeroInterior: _numIntCtrl.text,
        colonia: _coloniaCtrl.text,
        municipio: _municipioCtrl.text,
        estado: _estadoCtrl.text,
        codigoPostal: _cpCtrl.text,
        pais: _paisCtrl.text,
      ),
    );

    final errores = ClienteValidacion.validarCamposBase(perfilEditado);
    if (errores.isNotEmpty) {
      setState(() {
        _erroresCampos = errores;
        _error = errores.values.first;
      });
      return;
    }
    if (_erroresCampos.isNotEmpty) {
      setState(() => _erroresCampos = const {});
    }

    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      final actualizado = await widget.clienteService.actualizarPerfil(
        widget.cliente.id,
        perfilEditado,
      );
      if (!mounted) return;
      Navigator.of(context).pop(actualizado);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'No fue posible actualizar los datos del cliente.');
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  Widget _campo(
    TextEditingController ctrl,
    String etiqueta, {
    TextInputType? tipo,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
    String? helperText,
    TextCapitalization textCapitalization = TextCapitalization.none,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        keyboardType: tipo,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: etiqueta,
          errorText: errorText,
          helperText: helperText,
          errorMaxLines: 2,
          counterText: maxLength != null ? '' : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Cliente #${widget.cliente.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('CURP: ${widget.cliente.curp}')),
                    Chip(label: Text('RFC: ${widget.cliente.rfc}')),
                    Chip(label: Text(widget.cliente.activo ? 'Activo' : 'Inactivo')),
                  ],
                ),
                const SizedBox(height: 12),
                if (_error != null) ...[
                  _MensajeBanner(
                    mensaje: _error!,
                    esError: true,
                    onCerrar: () => setState(() => _error = null),
                  ),
                  const SizedBox(height: 12),
                ],
                ResponsiveFormGrid(
                  runSpacing: 2,
                  children: [
                    _campo(
                      _primerNombreCtrl,
                      'Primer nombre *',
                      maxLength: 50,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [ValidacionFormatters.soloLetras],
                      helperText: 'Mín. 2 letras (solo letras)',
                      errorText: _erroresCampos['primerNombre'],
                      onChanged: (_) => _limpiarErrorCampo('primerNombre'),
                    ),
                    _campo(
                      _segundoNombreCtrl,
                      'Segundo nombre',
                      maxLength: 50,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [ValidacionFormatters.soloLetras],
                      helperText: 'Opcional (mín. 2 letras si aplica)',
                      errorText: _erroresCampos['segundoNombre'],
                      onChanged: (_) => _limpiarErrorCampo('segundoNombre'),
                    ),
                    _campo(
                      _apellidoPaternoCtrl,
                      'Apellido paterno *',
                      maxLength: 50,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [ValidacionFormatters.soloLetras],
                      helperText: 'Mín. 2 letras (solo letras)',
                      errorText: _erroresCampos['apellidoPaterno'],
                      onChanged: (_) => _limpiarErrorCampo('apellidoPaterno'),
                    ),
                    _campo(
                      _apellidoMaternoCtrl,
                      'Apellido materno *',
                      maxLength: 50,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [ValidacionFormatters.soloLetras],
                      helperText: 'Mín. 2 letras (solo letras)',
                      errorText: _erroresCampos['apellidoMaterno'],
                      onChanged: (_) => _limpiarErrorCampo('apellidoMaterno'),
                    ),
                    _campo(
                      _correoCtrl,
                      'Correo electrónico *',
                      tipo: TextInputType.emailAddress,
                      maxLength: 100,
                      inputFormatters: [ValidacionFormatters.sinEspacios],
                      helperText: 'Sin espacios (6 a 100 caracteres)',
                      errorText: _erroresCampos['correo'],
                      onChanged: (_) => _limpiarErrorCampo('correo'),
                    ),
                    _campo(
                      _telefonoMovilCtrl,
                      'Teléfono móvil *',
                      tipo: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [ValidacionFormatters.soloDigitos],
                      helperText: '10 dígitos numéricos sin espacios',
                      errorText: _erroresCampos['telefonoMovil'],
                      onChanged: (_) => _limpiarErrorCampo('telefonoMovil'),
                    ),
                    _campo(
                      _telefonoAltCtrl,
                      'Teléfono alternativo',
                      tipo: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [ValidacionFormatters.soloDigitos],
                      helperText: 'Opcional (10 dígitos distintos al móvil)',
                      errorText: _erroresCampos['telefonoAlternativo'],
                      onChanged: (_) => _limpiarErrorCampo('telefonoAlternativo'),
                    ),
                    _campo(
                      _fechaNacCtrl,
                      'Fecha de nacimiento (AAAA-MM-DD) *',
                      tipo: TextInputType.datetime,
                      maxLength: 10,
                      inputFormatters: [ValidacionFormatters.fechaIso],
                      helperText: 'Edad válida de 18 a 120 años',
                      errorText: _erroresCampos['fechaNacimiento'],
                      onChanged: (_) => _limpiarErrorCampo('fechaNacimiento'),
                    ),
                    _campo(
                      _sexoCtrl,
                      'Sexo *',
                      maxLength: 20,
                      inputFormatters: [ValidacionFormatters.soloLetras],
                      errorText: _erroresCampos['sexo'],
                      onChanged: (_) => _limpiarErrorCampo('sexo'),
                    ),
                    _campo(
                      _nacionalidadCtrl,
                      'Nacionalidad *',
                      maxLength: 40,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [ValidacionFormatters.soloLetras],
                      helperText: 'Mín. 3 letras',
                      errorText: _erroresCampos['nacionalidad'],
                      onChanged: (_) => _limpiarErrorCampo('nacionalidad'),
                    ),
                    _campo(
                      _estadoCivilCtrl,
                      'Estado civil *',
                      maxLength: 30,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [ValidacionFormatters.soloLetras],
                      helperText: 'Mín. 3 letras',
                      errorText: _erroresCampos['estadoCivil'],
                      onChanged: (_) => _limpiarErrorCampo('estadoCivil'),
                    ),
                    _campo(
                      _ocupacionCtrl,
                      'Ocupación *',
                      maxLength: 80,
                      textCapitalization: TextCapitalization.sentences,
                      inputFormatters: [ValidacionFormatters.ocupacion],
                      helperText: 'Mín. 3 caracteres sin números',
                      errorText: _erroresCampos['ocupacion'],
                      onChanged: (_) => _limpiarErrorCampo('ocupacion'),
                    ),
                    _campo(
                      _empresaCtrl,
                      'Empresa *',
                      maxLength: 100,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [ValidacionFormatters.empresa],
                      helperText: 'Mín. 2 caracteres',
                      errorText: _erroresCampos['empresa'],
                      onChanged: (_) => _limpiarErrorCampo('empresa'),
                    ),
                    _campo(
                      _ingresoCtrl,
                      'Ingreso mensual (MXN) *',
                      tipo: const TextInputType.numberWithOptions(decimal: true),
                      maxLength: 11,
                      inputFormatters: [ValidacionFormatters.decimal],
                      helperText: 'Mayor a 0 y máx. 2 decimales',
                      errorText: _erroresCampos['ingresoMensual'],
                      onChanged: (_) => _limpiarErrorCampo('ingresoMensual'),
                    ),
                  ],
                ),
                const Divider(height: 24),
                ResponsiveFormGrid(
                  runSpacing: 2,
                  children: [
                    _campo(
                      _calleCtrl,
                      'Calle *',
                      maxLength: 100,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [ValidacionFormatters.calle],
                      helperText: 'Mín. 3 caracteres',
                      errorText: _erroresCampos['domicilio.calle'],
                      onChanged: (_) => _limpiarErrorCampo('domicilio.calle'),
                    ),
                    _campo(
                      _numExtCtrl,
                      'Número exterior *',
                      maxLength: 20,
                      inputFormatters: [ValidacionFormatters.numeroDomicilio],
                      helperText: '1 a 20 caracteres sin espacios',
                      errorText: _erroresCampos['domicilio.numeroExterior'],
                      onChanged: (_) => _limpiarErrorCampo('domicilio.numeroExterior'),
                    ),
                    _campo(
                      _numIntCtrl,
                      'Número interior',
                      maxLength: 20,
                      inputFormatters: [ValidacionFormatters.numeroDomicilio],
                      helperText: 'Opcional, sin espacios',
                      errorText: _erroresCampos['domicilio.numeroInterior'],
                      onChanged: (_) => _limpiarErrorCampo('domicilio.numeroInterior'),
                    ),
                    _campo(
                      _coloniaCtrl,
                      'Colonia *',
                      maxLength: 80,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [ValidacionFormatters.colonia],
                      helperText: 'Mín. 3 caracteres',
                      errorText: _erroresCampos['domicilio.colonia'],
                      onChanged: (_) => _limpiarErrorCampo('domicilio.colonia'),
                    ),
                    _campo(
                      _municipioCtrl,
                      'Municipio *',
                      maxLength: 80,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [ValidacionFormatters.lugar],
                      helperText: 'Mín. 3 letras',
                      errorText: _erroresCampos['domicilio.municipio'],
                      onChanged: (_) => _limpiarErrorCampo('domicilio.municipio'),
                    ),
                    _campo(
                      _estadoCtrl,
                      'Estado *',
                      maxLength: 60,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [ValidacionFormatters.lugar],
                      helperText: 'Mín. 2 letras',
                      errorText: _erroresCampos['domicilio.estado'],
                      onChanged: (_) => _limpiarErrorCampo('domicilio.estado'),
                    ),
                    _campo(
                      _cpCtrl,
                      'Código postal *',
                      tipo: TextInputType.number,
                      maxLength: 5,
                      inputFormatters: [ValidacionFormatters.soloDigitos],
                      helperText: '5 dígitos exactos',
                      errorText: _erroresCampos['domicilio.codigoPostal'],
                      onChanged: (_) => _limpiarErrorCampo('domicilio.codigoPostal'),
                    ),
                    _campo(
                      _paisCtrl,
                      'País *',
                      maxLength: 50,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [ValidacionFormatters.soloLetras],
                      helperText: 'Mín. 3 letras',
                      errorText: _erroresCampos['domicilio.pais'],
                      onChanged: (_) => _limpiarErrorCampo('domicilio.pais'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _guardando ? null : _guardar,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(_guardando ? 'Guardando...' : 'Guardar Cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
