import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/network/api_client.dart';
import '../models/cliente_models.dart';
import '../services/cliente_service.dart';
import '../state/session_controller.dart';
import '../utils/input_formatters.dart';
import '../widgets/bbva_client_card.dart';
import '../widgets/responsive_form_grid.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    required this.sessionController,
    this.clienteService,
    super.key,
  });

  final SessionController sessionController;
  final ClienteService? clienteService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ClienteService _clienteService;

  bool _cargandoPerfil = true;
  String? _errorCarga;
  ClientePerfil? _perfil;

  bool _guardandoPerfil = false;
  String? _errorPerfil;
  String? _exitoPerfil;

  bool _guardandoPassword = false;
  String? _errorPassword;
  String? _exitoPassword;
  Map<String, String> _erroresCampos = const {};

  void _limpiarErrorCampo(String clave) {
    if (_erroresCampos.containsKey(clave)) {
      final copia = Map<String, String>.from(_erroresCampos);
      copia.remove(clave);
      setState(() => _erroresCampos = copia);
    }
  }

  final _primerNombreCtrl = TextEditingController();
  final _segundoNombreCtrl = TextEditingController();
  final _apellidoPaternoCtrl = TextEditingController();
  final _apellidoMaternoCtrl = TextEditingController();
  final _fechaNacCtrl = TextEditingController();
  final _sexoCtrl = TextEditingController();
  final _nacionalidadCtrl = TextEditingController();
  final _estadoCivilCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoMovilCtrl = TextEditingController();
  final _telefonoAltCtrl = TextEditingController();
  final _ocupacionCtrl = TextEditingController();
  final _empresaCtrl = TextEditingController();
  final _ingresoCtrl = TextEditingController();

  final _calleCtrl = TextEditingController();
  final _numExtCtrl = TextEditingController();
  final _numIntCtrl = TextEditingController();
  final _coloniaCtrl = TextEditingController();
  final _municipioCtrl = TextEditingController();
  final _estadoCtrl = TextEditingController();
  final _cpCtrl = TextEditingController();
  final _paisCtrl = TextEditingController();

  final _passwordActualCtrl = TextEditingController();
  final _passwordNuevaCtrl = TextEditingController();
  final _confirmarPasswordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _clienteService =
        widget.clienteService ?? ClienteService(apiClient: widget.sessionController.apiClient);
    _cargarPerfil();
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
    _passwordActualCtrl.dispose();
    _passwordNuevaCtrl.dispose();
    _confirmarPasswordCtrl.dispose();
    super.dispose();
  }

  void _aplicarPerfilAControllers(ClientePerfil perfil) {
    _primerNombreCtrl.text = perfil.primerNombre;
    _segundoNombreCtrl.text = perfil.segundoNombre;
    _apellidoPaternoCtrl.text = perfil.apellidoPaterno;
    _apellidoMaternoCtrl.text = perfil.apellidoMaterno;
    _fechaNacCtrl.text = perfil.fechaNacimiento;
    _sexoCtrl.text = perfil.sexo;
    _nacionalidadCtrl.text = perfil.nacionalidad;
    _estadoCivilCtrl.text = perfil.estadoCivil;
    _correoCtrl.text = perfil.correo;
    _telefonoMovilCtrl.text = perfil.telefonoMovil;
    _telefonoAltCtrl.text = perfil.telefonoAlternativo;
    _ocupacionCtrl.text = perfil.ocupacion;
    _empresaCtrl.text = perfil.empresa;
    _ingresoCtrl.text = perfil.ingresoMensual;
    _calleCtrl.text = perfil.domicilio.calle;
    _numExtCtrl.text = perfil.domicilio.numeroExterior;
    _numIntCtrl.text = perfil.domicilio.numeroInterior;
    _coloniaCtrl.text = perfil.domicilio.colonia;
    _municipioCtrl.text = perfil.domicilio.municipio;
    _estadoCtrl.text = perfil.domicilio.estado;
    _cpCtrl.text = perfil.domicilio.codigoPostal;
    _paisCtrl.text = perfil.domicilio.pais;
  }

  ClientePerfil _construirPerfilDesdeControllers(ClientePerfil base) {
    return ClientePerfil(
      id: base.id,
      primerNombre: _primerNombreCtrl.text,
      segundoNombre: _segundoNombreCtrl.text,
      apellidoPaterno: _apellidoPaternoCtrl.text,
      apellidoMaterno: _apellidoMaternoCtrl.text,
      fechaNacimiento: _fechaNacCtrl.text,
      curp: base.curp,
      rfc: base.rfc,
      sexo: _sexoCtrl.text,
      nacionalidad: _nacionalidadCtrl.text,
      estadoCivil: _estadoCivilCtrl.text,
      correo: _correoCtrl.text,
      telefonoMovil: _telefonoMovilCtrl.text,
      telefonoAlternativo: _telefonoAltCtrl.text,
      ocupacion: _ocupacionCtrl.text,
      empresa: _empresaCtrl.text,
      ingresoMensual: _ingresoCtrl.text,
      activo: base.activo,
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
  }

  Future<void> _cargarPerfil() async {
    setState(() {
      _cargandoPerfil = true;
      _errorCarga = null;
    });

    try {
      var clienteId = widget.sessionController.sesionActual?.clienteId;
      if (clienteId == null) {
        await widget.sessionController.verificarVigenciaSesion();
        clienteId = widget.sessionController.sesionActual?.clienteId;
      }
      if (clienteId == null) {
        if (!mounted) return;
        setState(() {
          _errorCarga =
              'No se identificó tu identificador de cliente. Cierra sesión e inicia nuevamente.';
        });
        return;
      }
      final datos = await _clienteService.consultarPerfil(clienteId);
      if (!mounted) return;
      _aplicarPerfilAControllers(datos);
      setState(() {
        _perfil = datos;
      });
    } on ApiException catch (e) {
      if (e.statusCode == 401) return;
      if (!mounted) return;
      setState(() {
        _errorCarga = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorCarga = 'No fue posible consultar tu perfil de cliente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _cargandoPerfil = false;
        });
      }
    }
  }

  Future<void> _guardarPerfil() async {
    final base = _perfil;
    if (base == null) return;

    final candidato = _construirPerfilDesdeControllers(base);
    final errores = ClienteValidacion.validarCamposBase(candidato);
    if (errores.isNotEmpty) {
      setState(() {
        _erroresCampos = errores;
        _errorPerfil = errores.values.first;
        _exitoPerfil = null;
      });
      return;
    }
    if (_erroresCampos.isNotEmpty) {
      setState(() => _erroresCampos = const {});
    }

    setState(() {
      _guardandoPerfil = true;
      _errorPerfil = null;
      _exitoPerfil = null;
    });

    try {
      final actualizado = await _clienteService.actualizarPerfil(base.id, candidato);
      if (!mounted) return;
      _aplicarPerfilAControllers(actualizado);
      widget.sessionController.actualizarPerfilLocal(
        nombreCliente: actualizado.nombreCompleto,
        correo: actualizado.correo,
      );
      setState(() {
        _perfil = actualizado;
        _exitoPerfil = 'Los datos de tu cuenta y domicilio fueron actualizados correctamente.';
      });
    } on ApiException catch (e) {
      if (e.statusCode == 401) return;
      if (!mounted) return;
      setState(() {
        _errorPerfil = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorPerfil = 'No fue posible actualizar los datos del cliente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _guardandoPerfil = false;
        });
      }
    }
  }

  Future<void> _cambiarPassword() async {
    setState(() {
      _errorPassword = null;
      _exitoPassword = null;
    });

    final actual = _passwordActualCtrl.text;
    final nueva = _passwordNuevaCtrl.text;
    final confirmar = _confirmarPasswordCtrl.text;

    if (actual.trim().isEmpty) {
      setState(() => _errorPassword = 'Ingresa tu contraseña actual.');
      return;
    }
    final errNueva = ClienteValidacion.validarPassword(nueva);
    if (errNueva != null) {
      setState(() => _errorPassword = errNueva);
      return;
    }
    if (nueva == actual) {
      setState(
        () => _errorPassword =
            'La nueva contraseña debe ser diferente a tu contraseña actual.',
      );
      return;
    }
    if (nueva != confirmar) {
      setState(() => _errorPassword = 'Las contraseñas nuevas no coinciden.');
      return;
    }

    setState(() => _guardandoPassword = true);

    try {
      var usuarioId = widget.sessionController.sesionActual?.usuarioId;
      if (usuarioId == null) {
        await widget.sessionController.verificarVigenciaSesion();
        usuarioId = widget.sessionController.sesionActual?.usuarioId;
      }
      if (usuarioId == null) {
        if (!mounted) return;
        setState(() {
          _errorPassword =
              'No se identificó tu usuario. Cierra sesión e inicia nuevamente para sincronizar.';
        });
        return;
      }

      final mensaje = await _clienteService.cambiarPassword(
        usuarioId: usuarioId,
        passwordActual: actual,
        passwordNueva: nueva,
      );
      if (!mounted) return;
      _passwordActualCtrl.clear();
      _passwordNuevaCtrl.clear();
      _confirmarPasswordCtrl.clear();
      setState(() {
        _exitoPassword = mensaje;
      });
    } on ApiException catch (e) {
      if (e.statusCode == 401) return;
      if (!mounted) return;
      setState(() => _errorPassword = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorPassword = 'No fue posible actualizar la contraseña.');
    } finally {
      if (mounted) {
        setState(() => _guardandoPassword = false);
      }
    }
  }

  Future<void> _abrirModalBaja() async {
    final base = _perfil;
    final clienteId = base?.id ?? widget.sessionController.sesionActual?.clienteId;
    if (clienteId == null) return;

    var confirmTexto = '';
    var procesandoDialogo = false;
    String? errorDialogo;

    final confirmado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final habilitado =
                confirmTexto.trim().toUpperCase() == 'BAJA' && !procesandoDialogo;

            return AlertDialog(
              title: const Text('Confirmar Baja Lógica de Cuenta'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Al confirmar, tu perfil, usuario y cuentas bancarias quedarán inactivos y se cerrarán todas tus sesiones activas.',
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Escribe BAJA para confirmar',
                      hintText: 'BAJA',
                    ),
                    onChanged: (valor) => setDialogState(() => confirmTexto = valor),
                  ),
                  if (errorDialogo != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorDialogo!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      procesandoDialogo ? null : () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
                  onPressed: habilitado
                      ? () async {
                          setDialogState(() {
                            procesandoDialogo = true;
                            errorDialogo = null;
                          });
                          try {
                            await _clienteService.darDeBaja(clienteId);
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop(true);
                            }
                          } on ApiException catch (e) {
                            setDialogState(() {
                              procesandoDialogo = false;
                              errorDialogo = e.message;
                            });
                          } catch (_) {
                            setDialogState(() {
                              procesandoDialogo = false;
                              errorDialogo = 'Error al procesar la baja lógica.';
                            });
                          }
                        }
                      : null,
                  child: const Text('Confirmar baja definitiva'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmado == true && mounted) {
      widget.sessionController.cerrarSesionTrasBaja();
      Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.routeName, (_) => false);
    }
  }

  Widget _campo(
    String etiqueta,
    TextEditingController controller, {
    TextInputType? keyboardType,
    bool obscureText = false,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? helperText,
    String? errorText,
    TextCapitalization textCapitalization = TextCapitalization.none,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: etiqueta,
        helperText: helperText,
        errorText: errorText,
        errorMaxLines: 2,
        counterText: '',
      ),
    );
  }

  Widget _bannerMensaje(String mensaje, {required bool esError}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: esError ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: esError ? Colors.red.shade200 : Colors.green.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            esError ? Icons.error_outline : Icons.check_circle_outline,
            color: esError ? Colors.red.shade700 : Colors.green.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(
                color: esError ? Colors.red.shade900 : Colors.green.shade900,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_cargandoPerfil) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorCarga != null || _perfil == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 12),
              Text(
                _errorCarga ?? 'No se pudo cargar tu perfil.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _cargarPerfil,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar consulta'),
              ),
            ],
          ),
        ),
      );
    }

    final perfil = _perfil!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: Color(0xFFD9E2E7)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'Mi Perfil y Administración de Cuenta',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BbvaClientCard(
                nombreTitular: perfil.nombreCompleto,
                correo: perfil.correo,
                plataforma: widget.sessionController.sesionActual?.plataforma ?? 'MOVIL',
                numeroCuenta: widget.sessionController.sesionActual?.numeroCuenta,
                saldoCuenta: widget.sessionController.sesionActual?.saldoCuenta,
                esEjecutivo: widget.sessionController.sesionActual?.esEjecutivo ?? false,
                cuentaActiva: perfil.activo,
                curp: perfil.curp,
                rfc: perfil.rfc,
                clienteId: perfil.id,
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: Color(0xFFD9E2E7)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Datos Personales y Domicilio',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 14),
                      ResponsiveFormGrid(
                        children: [
                          _campo(
                            'Primer nombre *',
                            _primerNombreCtrl,
                            maxLength: 50,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [ValidacionFormatters.soloLetras],
                            helperText: 'Mín. 2 letras (solo letras)',
                            errorText: _erroresCampos['primerNombre'],
                            onChanged: (_) => _limpiarErrorCampo('primerNombre'),
                          ),
                          _campo(
                            'Segundo nombre',
                            _segundoNombreCtrl,
                            maxLength: 50,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [ValidacionFormatters.soloLetras],
                            helperText: 'Opcional (mín. 2 letras si aplica)',
                            errorText: _erroresCampos['segundoNombre'],
                            onChanged: (_) => _limpiarErrorCampo('segundoNombre'),
                          ),
                          _campo(
                            'Apellido paterno *',
                            _apellidoPaternoCtrl,
                            maxLength: 50,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [ValidacionFormatters.soloLetras],
                            helperText: 'Mín. 2 letras (solo letras)',
                            errorText: _erroresCampos['apellidoPaterno'],
                            onChanged: (_) => _limpiarErrorCampo('apellidoPaterno'),
                          ),
                          _campo(
                            'Apellido materno *',
                            _apellidoMaternoCtrl,
                            maxLength: 50,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [ValidacionFormatters.soloLetras],
                            helperText: 'Mín. 2 letras (solo letras)',
                            errorText: _erroresCampos['apellidoMaterno'],
                            onChanged: (_) => _limpiarErrorCampo('apellidoMaterno'),
                          ),
                          _campo(
                            'Correo electrónico *',
                            _correoCtrl,
                            keyboardType: TextInputType.emailAddress,
                            maxLength: 100,
                            inputFormatters: [ValidacionFormatters.sinEspacios],
                            helperText: 'Sin espacios (6 a 100 caracteres)',
                            errorText: _erroresCampos['correo'],
                            onChanged: (_) => _limpiarErrorCampo('correo'),
                          ),
                          _campo(
                            'Teléfono móvil (10 dígitos) *',
                            _telefonoMovilCtrl,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            inputFormatters: [ValidacionFormatters.soloDigitos],
                            helperText: '10 dígitos numéricos sin espacios',
                            errorText: _erroresCampos['telefonoMovil'],
                            onChanged: (_) => _limpiarErrorCampo('telefonoMovil'),
                          ),
                          _campo(
                            'Teléfono alternativo',
                            _telefonoAltCtrl,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            inputFormatters: [ValidacionFormatters.soloDigitos],
                            helperText: 'Opcional (10 dígitos distintos al móvil)',
                            errorText: _erroresCampos['telefonoAlternativo'],
                            onChanged: (_) => _limpiarErrorCampo('telefonoAlternativo'),
                          ),
                          _campo(
                            'Fecha de nacimiento (AAAA-MM-DD) *',
                            _fechaNacCtrl,
                            keyboardType: TextInputType.datetime,
                            maxLength: 10,
                            inputFormatters: [ValidacionFormatters.fechaIso],
                            helperText: 'Edad válida de 18 a 120 años',
                            errorText: _erroresCampos['fechaNacimiento'],
                            onChanged: (_) => _limpiarErrorCampo('fechaNacimiento'),
                          ),
                          _campo(
                            'Sexo *',
                            _sexoCtrl,
                            maxLength: 20,
                            inputFormatters: [ValidacionFormatters.soloLetras],
                            errorText: _erroresCampos['sexo'],
                            onChanged: (_) => _limpiarErrorCampo('sexo'),
                          ),
                          _campo(
                            'Estado civil *',
                            _estadoCivilCtrl,
                            maxLength: 30,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [ValidacionFormatters.soloLetras],
                            helperText: 'Mín. 3 letras',
                            errorText: _erroresCampos['estadoCivil'],
                            onChanged: (_) => _limpiarErrorCampo('estadoCivil'),
                          ),
                          _campo(
                            'Nacionalidad *',
                            _nacionalidadCtrl,
                            maxLength: 40,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [ValidacionFormatters.soloLetras],
                            helperText: 'Mín. 3 letras',
                            errorText: _erroresCampos['nacionalidad'],
                            onChanged: (_) => _limpiarErrorCampo('nacionalidad'),
                          ),
                          _campo(
                            'Ocupación *',
                            _ocupacionCtrl,
                            maxLength: 80,
                            textCapitalization: TextCapitalization.sentences,
                            inputFormatters: [ValidacionFormatters.ocupacion],
                            helperText: 'Mín. 3 caracteres sin números',
                            errorText: _erroresCampos['ocupacion'],
                            onChanged: (_) => _limpiarErrorCampo('ocupacion'),
                          ),
                          _campo(
                            'Empresa *',
                            _empresaCtrl,
                            maxLength: 100,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [ValidacionFormatters.empresa],
                            helperText: 'Mín. 2 caracteres',
                            errorText: _erroresCampos['empresa'],
                            onChanged: (_) => _limpiarErrorCampo('empresa'),
                          ),
                          _campo(
                            'Ingreso mensual (MXN) *',
                            _ingresoCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            maxLength: 11,
                            inputFormatters: [ValidacionFormatters.decimal],
                            helperText: 'Mayor a 0 y máx. 2 decimales',
                            errorText: _erroresCampos['ingresoMensual'],
                            onChanged: (_) => _limpiarErrorCampo('ingresoMensual'),
                          ),
                        ],
                      ),
                      const Divider(height: 28),
                      ResponsiveFormGrid(
                        children: [
                          _campo(
                            'Calle *',
                            _calleCtrl,
                            maxLength: 100,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [ValidacionFormatters.calle],
                            helperText: 'Mín. 3 caracteres',
                            errorText: _erroresCampos['domicilio.calle'],
                            onChanged: (_) => _limpiarErrorCampo('domicilio.calle'),
                          ),
                          _campo(
                            'Número exterior *',
                            _numExtCtrl,
                            maxLength: 20,
                            inputFormatters: [ValidacionFormatters.numeroDomicilio],
                            helperText: '1 a 20 caracteres sin espacios',
                            errorText: _erroresCampos['domicilio.numeroExterior'],
                            onChanged: (_) => _limpiarErrorCampo('domicilio.numeroExterior'),
                          ),
                          _campo(
                            'Número interior',
                            _numIntCtrl,
                            maxLength: 20,
                            inputFormatters: [ValidacionFormatters.numeroDomicilio],
                            helperText: 'Opcional, sin espacios',
                            errorText: _erroresCampos['domicilio.numeroInterior'],
                            onChanged: (_) => _limpiarErrorCampo('domicilio.numeroInterior'),
                          ),
                          _campo(
                            'Colonia *',
                            _coloniaCtrl,
                            maxLength: 80,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [ValidacionFormatters.colonia],
                            helperText: 'Mín. 3 caracteres',
                            errorText: _erroresCampos['domicilio.colonia'],
                            onChanged: (_) => _limpiarErrorCampo('domicilio.colonia'),
                          ),
                          _campo(
                            'Municipio / Alcaldía *',
                            _municipioCtrl,
                            maxLength: 80,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [ValidacionFormatters.lugar],
                            helperText: 'Mín. 3 letras',
                            errorText: _erroresCampos['domicilio.municipio'],
                            onChanged: (_) => _limpiarErrorCampo('domicilio.municipio'),
                          ),
                          _campo(
                            'Estado *',
                            _estadoCtrl,
                            maxLength: 60,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [ValidacionFormatters.lugar],
                            helperText: 'Mín. 2 letras',
                            errorText: _erroresCampos['domicilio.estado'],
                            onChanged: (_) => _limpiarErrorCampo('domicilio.estado'),
                          ),
                          _campo(
                            'Código postal (5 dígitos) *',
                            _cpCtrl,
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            inputFormatters: [ValidacionFormatters.soloDigitos],
                            helperText: '5 dígitos exactos',
                            errorText: _erroresCampos['domicilio.codigoPostal'],
                            onChanged: (_) => _limpiarErrorCampo('domicilio.codigoPostal'),
                          ),
                          _campo(
                            'País *',
                            _paisCtrl,
                            maxLength: 50,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [ValidacionFormatters.soloLetras],
                            helperText: 'Mín. 3 letras',
                            errorText: _erroresCampos['domicilio.pais'],
                            onChanged: (_) => _limpiarErrorCampo('domicilio.pais'),
                          ),
                        ],
                      ),
                      if (_errorPerfil != null) ...[
                        const SizedBox(height: 14),
                        _bannerMensaje(_errorPerfil!, esError: true),
                      ],
                      if (_exitoPerfil != null) ...[
                        const SizedBox(height: 14),
                        _bannerMensaje(_exitoPerfil!, esError: false),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _guardandoPerfil ? null : _guardarPerfil,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(
                          _guardandoPerfil ? 'Guardando cambios...' : 'Guardar Cambios de Perfil',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: Color(0xFFD9E2E7)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Cambiar Contraseña',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 14),
                      _campo(
                        'Contraseña actual *',
                        _passwordActualCtrl,
                        obscureText: true,
                        maxLength: 72,
                        inputFormatters: [ValidacionFormatters.sinEspacios],
                      ),
                      const SizedBox(height: 12),
                      _campo(
                        'Nueva contraseña *',
                        _passwordNuevaCtrl,
                        obscureText: true,
                        maxLength: 72,
                        inputFormatters: [ValidacionFormatters.sinEspacios],
                        helperText: '8 a 72 caracteres sin espacios (mayúscula, minúscula, número y símbolo)',
                      ),
                      const SizedBox(height: 12),
                      _campo(
                        'Confirmar nueva contraseña *',
                        _confirmarPasswordCtrl,
                        obscureText: true,
                        maxLength: 72,
                        inputFormatters: [ValidacionFormatters.sinEspacios],
                      ),
                      if (_errorPassword != null) ...[
                        const SizedBox(height: 14),
                        _bannerMensaje(_errorPassword!, esError: true),
                      ],
                      if (_exitoPassword != null) ...[
                        const SizedBox(height: 14),
                        _bannerMensaje(_exitoPassword!, esError: false),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _guardandoPassword ? null : _cambiarPassword,
                        icon: const Icon(Icons.key_outlined),
                        label: Text(
                          _guardandoPassword ? 'Actualizando...' : 'Actualizar Contraseña',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: Colors.red.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Dar de Baja Cuenta',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'La baja lógica inactiva tu usuario, tus cuentas bancarias y cierra todas tus sesiones activas en Web y Móvil.',
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(color: Colors.red.shade300),
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _abrirModalBaja,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Dar de baja mi cuenta'),
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
