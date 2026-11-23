import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/storage/secure_session_storage.dart';
import '../models/cliente_models.dart';
import '../services/cliente_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    this.clienteService,
    super.key,
  });

  static const routeName = '/register';

  final ClienteService? clienteService;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final ClienteService _clienteService;

  bool _isPasswordObscured = true;
  bool _cargando = false;
  String? _errorMensaje;
  RegistroClienteResultado? _registroExitoso;

  final _primerNombreCtrl = TextEditingController();
  final _segundoNombreCtrl = TextEditingController();
  final _apellidoPaternoCtrl = TextEditingController();
  final _apellidoMaternoCtrl = TextEditingController();
  final _curpCtrl = TextEditingController();
  final _rfcCtrl = TextEditingController();
  final _fechaNacCtrl = TextEditingController();
  String _sexoSeleccionado = 'MASCULINO';
  String _estadoCivilSeleccionado = 'Soltero';
  final _nacionalidadCtrl = TextEditingController(text: 'Mexicana');
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
  final _paisCtrl = TextEditingController(text: 'México');

  final _passwordCtrl = TextEditingController();
  final _confirmarPasswordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _clienteService = widget.clienteService ??
        ClienteService(
          apiClient: ApiClient(sessionStorage: SecureSessionStorage()),
        );
  }

  @override
  void dispose() {
    _primerNombreCtrl.dispose();
    _segundoNombreCtrl.dispose();
    _apellidoPaternoCtrl.dispose();
    _apellidoMaternoCtrl.dispose();
    _curpCtrl.dispose();
    _rfcCtrl.dispose();
    _fechaNacCtrl.dispose();
    _nacionalidadCtrl.dispose();
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
    _passwordCtrl.dispose();
    _confirmarPasswordCtrl.dispose();
    super.dispose();
  }

  ClientePerfil _construirPerfil() {
    return ClientePerfil(
      id: 0,
      primerNombre: _primerNombreCtrl.text,
      segundoNombre: _segundoNombreCtrl.text,
      apellidoPaterno: _apellidoPaternoCtrl.text,
      apellidoMaterno: _apellidoMaternoCtrl.text,
      fechaNacimiento: _fechaNacCtrl.text,
      curp: _curpCtrl.text,
      rfc: _rfcCtrl.text,
      sexo: _sexoSeleccionado,
      nacionalidad: _nacionalidadCtrl.text,
      estadoCivil: _estadoCivilSeleccionado,
      correo: _correoCtrl.text,
      telefonoMovil: _telefonoMovilCtrl.text,
      telefonoAlternativo: _telefonoAltCtrl.text,
      ocupacion: _ocupacionCtrl.text,
      empresa: _empresaCtrl.text,
      ingresoMensual: _ingresoCtrl.text,
      activo: true,
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

  Future<void> _registrarCuenta() async {
    final perfil = _construirPerfil();
    final err = ClienteValidacion.validarRegistro(
      perfil,
      password: _passwordCtrl.text,
      confirmarPassword: _confirmarPasswordCtrl.text,
    );
    if (err != null) {
      setState(() => _errorMensaje = err);
      return;
    }

    setState(() {
      _cargando = true;
      _errorMensaje = null;
    });

    try {
      final resultado = await _clienteService.registrarCliente(
        RegistroClienteSolicitud(
          perfil: perfil,
          password: _passwordCtrl.text,
        ),
      );
      if (!mounted) return;
      setState(() {
        _registroExitoso = resultado;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMensaje = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMensaje = 'No fue posible completar el registro del cliente.');
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Widget _campo(
    String etiqueta,
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: etiqueta,
        hintText: hint,
        counterText: '',
        suffixIcon: suffixIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_registroExitoso != null) {
      final res = _registroExitoso!;
      return Scaffold(
        appBar: AppBar(title: const Text('Cuenta Registrada'), centerTitle: true),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0xFFD9E2E7)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 64,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '¡Cuenta Registrada!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tu perfil y cuenta bancaria digital se crearon correctamente.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F8FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD9E2E7)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Correo:'),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      res.correo,
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Número de cuenta:'),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      res.numeroCuenta,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(res),
                          child: const Text('Ir a Iniciar Sesión'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta en GestoPago'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.person_add_alt_1_outlined,
                    size: 56,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Registro de Nuevo Cliente',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Completa tus datos personales, fiscales y domicilio para abrir tu cuenta.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
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
                            'Datos Personales e Identificación',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 14),
                          _campo('Primer nombre *', _primerNombreCtrl),
                          const SizedBox(height: 12),
                          _campo('Segundo nombre', _segundoNombreCtrl),
                          const SizedBox(height: 12),
                          _campo('Apellido paterno *', _apellidoPaternoCtrl),
                          const SizedBox(height: 12),
                          _campo('Apellido materno *', _apellidoMaternoCtrl),
                          const SizedBox(height: 12),
                          _campo(
                            'CURP (18 caracteres) *',
                            _curpCtrl,
                            maxLength: 18,
                            textCapitalization: TextCapitalization.characters,
                          ),
                          const SizedBox(height: 12),
                          _campo(
                            'RFC (12-13 caracteres) *',
                            _rfcCtrl,
                            maxLength: 13,
                            textCapitalization: TextCapitalization.characters,
                          ),
                          const SizedBox(height: 12),
                          _campo(
                            'Fecha de nacimiento (AAAA-MM-DD) *',
                            _fechaNacCtrl,
                            hint: '2000-01-15',
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _sexoSeleccionado,
                            decoration: const InputDecoration(labelText: 'Sexo *'),
                            items: const [
                              DropdownMenuItem(value: 'MASCULINO', child: Text('MASCULINO')),
                              DropdownMenuItem(value: 'FEMENINO', child: Text('FEMENINO')),
                              DropdownMenuItem(value: 'OTRO', child: Text('OTRO')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _sexoSeleccionado = val);
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _estadoCivilSeleccionado,
                            decoration: const InputDecoration(labelText: 'Estado civil *'),
                            items: const [
                              DropdownMenuItem(value: 'Soltero', child: Text('Soltero')),
                              DropdownMenuItem(value: 'Soltera', child: Text('Soltera')),
                              DropdownMenuItem(value: 'Casado', child: Text('Casado')),
                              DropdownMenuItem(value: 'Casada', child: Text('Casada')),
                              DropdownMenuItem(value: 'Divorciado', child: Text('Divorciado')),
                              DropdownMenuItem(value: 'Viudo', child: Text('Viudo')),
                              DropdownMenuItem(value: 'Union libre', child: Text('Unión libre')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _estadoCivilSeleccionado = val);
                            },
                          ),
                          const SizedBox(height: 12),
                          _campo('Nacionalidad *', _nacionalidadCtrl),
                          const SizedBox(height: 12),
                          _campo(
                            'Correo electrónico *',
                            _correoCtrl,
                            hint: 'correo@ejemplo.com',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          _campo(
                            'Teléfono móvil (10 dígitos) *',
                            _telefonoMovilCtrl,
                            maxLength: 10,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          _campo(
                            'Teléfono alternativo',
                            _telefonoAltCtrl,
                            maxLength: 10,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          _campo('Ocupación *', _ocupacionCtrl),
                          const SizedBox(height: 12),
                          _campo('Empresa *', _empresaCtrl),
                          const SizedBox(height: 12),
                          _campo(
                            'Ingreso mensual (MXN) *',
                            _ingresoCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                          const Divider(height: 28),
                          Text(
                            'Domicilio',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 14),
                          _campo('Calle *', _calleCtrl),
                          const SizedBox(height: 12),
                          _campo('Número exterior *', _numExtCtrl),
                          const SizedBox(height: 12),
                          _campo('Número interior', _numIntCtrl),
                          const SizedBox(height: 12),
                          _campo('Colonia *', _coloniaCtrl),
                          const SizedBox(height: 12),
                          _campo('Municipio / Alcaldía *', _municipioCtrl),
                          const SizedBox(height: 12),
                          _campo('Estado *', _estadoCtrl),
                          const SizedBox(height: 12),
                          _campo(
                            'Código postal (5 dígitos) *',
                            _cpCtrl,
                            maxLength: 5,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          _campo('País *', _paisCtrl),
                          const Divider(height: 28),
                          Text(
                            'Contraseña de Acceso',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 14),
                          _campo(
                            'Contraseña *',
                            _passwordCtrl,
                            obscureText: _isPasswordObscured,
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _isPasswordObscured = !_isPasswordObscured),
                              icon: Icon(
                                _isPasswordObscured
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _campo(
                            'Confirmar contraseña *',
                            _confirmarPasswordCtrl,
                            obscureText: _isPasswordObscured,
                          ),
                          if (_errorMensaje != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _errorMensaje!,
                                style: TextStyle(color: colorScheme.onErrorContainer),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _cargando ? null : _registrarCuenta,
                            icon: _cargando
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.person_add_outlined),
                            label: Text(_cargando ? 'Creando cuenta...' : 'Registrar Cuenta'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Ya tengo una cuenta. Volver al Login'),
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
