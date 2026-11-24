import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/network/api_client.dart';
import '../core/storage/secure_session_storage.dart';
import '../models/cliente_models.dart';
import '../services/cliente_service.dart';
import '../utils/input_formatters.dart';
import '../widgets/responsive_form_grid.dart';

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
    final errores = ClienteValidacion.validarCamposRegistro(
      perfil,
      password: _passwordCtrl.text,
      confirmarPassword: _confirmarPasswordCtrl.text,
    );
    if (errores.isNotEmpty) {
      setState(() {
        _erroresCampos = errores;
        _errorMensaje = errores.values.first;
      });
      return;
    }
    if (_erroresCampos.isNotEmpty) {
      setState(() => _erroresCampos = const {});
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
    String? helperText,
    String? errorText,
    TextInputType? keyboardType,
    bool obscureText = false,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Widget? suffixIcon,
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
        hintText: hint,
        helperText: helperText,
        errorText: errorText,
        errorMaxLines: 2,
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
              constraints: const BoxConstraints(maxWidth: 860),
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
                          ResponsiveFormGrid(
                            children: [
                              _campo(
                                'Primer nombre *',
                                _primerNombreCtrl,
                                maxLength: 50,
                                textCapitalization: TextCapitalization.words,
                                inputFormatters: [ValidacionFormatters.soloLetras],
                                helperText: 'Mín. 3 letras (solo letras)',
                                errorText: _erroresCampos['primerNombre'],
                                onChanged: (_) => _limpiarErrorCampo('primerNombre'),
                              ),
                              _campo(
                                'Segundo nombre',
                                _segundoNombreCtrl,
                                maxLength: 50,
                                textCapitalization: TextCapitalization.words,
                                inputFormatters: [ValidacionFormatters.soloLetras],
                                helperText: 'Opcional (mín. 3 letras si aplica)',
                                errorText: _erroresCampos['segundoNombre'],
                                onChanged: (_) => _limpiarErrorCampo('segundoNombre'),
                              ),
                              _campo(
                                'Apellido paterno *',
                                _apellidoPaternoCtrl,
                                maxLength: 50,
                                textCapitalization: TextCapitalization.words,
                                inputFormatters: [ValidacionFormatters.soloLetras],
                                helperText: 'Mín. 3 letras (solo letras)',
                                errorText: _erroresCampos['apellidoPaterno'],
                                onChanged: (_) => _limpiarErrorCampo('apellidoPaterno'),
                              ),
                              _campo(
                                'Apellido materno *',
                                _apellidoMaternoCtrl,
                                maxLength: 50,
                                textCapitalization: TextCapitalization.words,
                                inputFormatters: [ValidacionFormatters.soloLetras],
                                helperText: 'Mín. 3 letras (solo letras)',
                                errorText: _erroresCampos['apellidoMaterno'],
                                onChanged: (_) => _limpiarErrorCampo('apellidoMaterno'),
                              ),
                              _campo(
                                'CURP (18 caracteres) *',
                                _curpCtrl,
                                maxLength: 18,
                                textCapitalization: TextCapitalization.characters,
                                inputFormatters: [ValidacionFormatters.curp],
                                helperText: '18 caracteres alfanuméricos sin espacios',
                                errorText: _erroresCampos['curp'],
                                onChanged: (_) => _limpiarErrorCampo('curp'),
                              ),
                              _campo(
                                'RFC (12-13 caracteres) *',
                                _rfcCtrl,
                                maxLength: 13,
                                textCapitalization: TextCapitalization.characters,
                                inputFormatters: [ValidacionFormatters.rfc],
                                helperText: '12 o 13 caracteres sin espacios',
                                errorText: _erroresCampos['rfc'],
                                onChanged: (_) => _limpiarErrorCampo('rfc'),
                              ),
                              _campo(
                                'Fecha de nacimiento (AAAA-MM-DD) *',
                                _fechaNacCtrl,
                                hint: '2000-01-15',
                                keyboardType: TextInputType.datetime,
                                maxLength: 10,
                                inputFormatters: [ValidacionFormatters.fechaIso],
                                helperText: 'Edad válida de 18 a 120 años',
                                errorText: _erroresCampos['fechaNacimiento'],
                                onChanged: (_) => _limpiarErrorCampo('fechaNacimiento'),
                              ),
                              DropdownButtonFormField<String>(
                                initialValue: _sexoSeleccionado,
                                decoration: InputDecoration(
                                  labelText: 'Sexo *',
                                  errorText: _erroresCampos['sexo'],
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'MASCULINO', child: Text('MASCULINO')),
                                  DropdownMenuItem(value: 'FEMENINO', child: Text('FEMENINO')),
                                  DropdownMenuItem(value: 'OTRO', child: Text('OTRO')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _sexoSeleccionado = val);
                                    _limpiarErrorCampo('sexo');
                                  }
                                },
                              ),
                              DropdownButtonFormField<String>(
                                initialValue: _estadoCivilSeleccionado,
                                decoration: InputDecoration(
                                  labelText: 'Estado civil *',
                                  errorText: _erroresCampos['estadoCivil'],
                                ),
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
                                  if (val != null) {
                                    setState(() => _estadoCivilSeleccionado = val);
                                    _limpiarErrorCampo('estadoCivil');
                                  }
                                },
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
                                'Correo electrónico *',
                                _correoCtrl,
                                hint: 'correo@ejemplo.com',
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
                                maxLength: 10,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [ValidacionFormatters.soloDigitos],
                                helperText: '10 dígitos numéricos sin espacios',
                                errorText: _erroresCampos['telefonoMovil'],
                                onChanged: (_) => _limpiarErrorCampo('telefonoMovil'),
                              ),
                              _campo(
                                'Teléfono alternativo',
                                _telefonoAltCtrl,
                                maxLength: 10,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [ValidacionFormatters.soloDigitos],
                                helperText: 'Opcional (10 dígitos distintos al móvil)',
                                errorText: _erroresCampos['telefonoAlternativo'],
                                onChanged: (_) => _limpiarErrorCampo('telefonoAlternativo'),
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
                                maxLength: 11,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [ValidacionFormatters.decimal],
                                helperText: 'Mayor a 0 y máx. 2 decimales',
                                errorText: _erroresCampos['ingresoMensual'],
                                onChanged: (_) => _limpiarErrorCampo('ingresoMensual'),
                              ),
                            ],
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
                                maxLength: 5,
                                keyboardType: TextInputType.number,
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
                          const Divider(height: 28),
                          Text(
                            'Contraseña de Acceso',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 14),
                          ResponsiveFormGrid(
                            children: [
                              _campo(
                                'Contraseña *',
                                _passwordCtrl,
                                obscureText: _isPasswordObscured,
                                maxLength: 12,
                                inputFormatters: [ValidacionFormatters.sinEspacios],
                                helperText: '8 a 12 caracteres sin espacios, mayúscula, minúscula, número y símbolo',
                                errorText: _erroresCampos['password'],
                                onChanged: (_) => _limpiarErrorCampo('password'),
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
                              _campo(
                                'Confirmar contraseña *',
                                _confirmarPasswordCtrl,
                                obscureText: _isPasswordObscured,
                                maxLength: 12,
                                inputFormatters: [ValidacionFormatters.sinEspacios],
                                errorText: _erroresCampos['confirmarPassword'],
                                onChanged: (_) => _limpiarErrorCampo('confirmarPassword'),
                              ),
                            ],
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
