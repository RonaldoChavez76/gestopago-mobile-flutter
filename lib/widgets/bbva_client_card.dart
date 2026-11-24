import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BbvaClientCard extends StatefulWidget {
  const BbvaClientCard({
    required this.nombreTitular,
    required this.correo,
    required this.plataforma,
    this.numeroCuenta,
    this.saldoCuenta,
    this.esEjecutivo = false,
    this.cuentaActiva = true,
    this.curp,
    this.rfc,
    this.clienteId,
    super.key,
  });

  final String nombreTitular;
  final String correo;
  final String plataforma;
  final String? numeroCuenta;
  final double? saldoCuenta;
  final bool esEjecutivo;
  final bool cuentaActiva;
  final String? curp;
  final String? rfc;
  final int? clienteId;

  @override
  State<BbvaClientCard> createState() => _BbvaClientCardState();
}

class _BbvaClientCardState extends State<BbvaClientCard> {
  bool _mostrarSaldo = true;
  bool _ocultarCuenta = false;
  bool _copiado = false;

  String _formatearCuenta(String raw) {
    final limpia = raw.replaceAll(RegExp(r'\s+'), '');
    if (limpia.isEmpty) {
      return '•••• •••• •••• ••••';
    }
    if (_ocultarCuenta) {
      final ultimos = limpia.length >= 4 ? limpia.substring(limpia.length - 4) : limpia;
      return '•••• •••• •••• $ultimos';
    }
    final grupos = <String>[];
    for (var i = 0; i < limpia.length; i += 4) {
      final fin = (i + 4 <= limpia.length) ? i + 4 : limpia.length;
      grupos.add(limpia.substring(i, fin));
    }
    return grupos.join(' ');
  }

  Future<void> _copiarCuenta(String cuenta) async {
    await Clipboard.setData(ClipboardData(text: cuenta));
    if (!mounted) return;
    setState(() => _copiado = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Número de cuenta copiado al portapapeles.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copiado = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cuentaRaw = widget.numeroCuenta ?? '4229215075268914';
    final saldoTexto = widget.saldoCuenta != null
        ? '\$${widget.saldoCuenta!.toStringAsFixed(2)} MXN'
        : 'Sincronizando...';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF072146),
            Color(0xFF004481),
            Color(0xFF1464A5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF072146).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -40,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2DCCCD).withValues(alpha: 0.14),
                ),
              ),
            ),
            Positioned(
              bottom: -65,
              left: 40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: Color(0xFF2DCCCD),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BANCA DIGITAL GESTOPAGO',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.4,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFBAE6FD),
                              ),
                            ),
                            Text(
                              'Cuenta Digital Débito',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.contactless_rounded,
                        color: Color(0xFF2DCCCD),
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '2FA Verificado • ${widget.plataforma}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF072146),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                        decoration: BoxDecoration(
                          color: widget.esEjecutivo
                              ? const Color(0xFFFDE68A)
                              : Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Rol: ${widget.esEjecutivo ? 'EJECUTIVO' : 'CLIENTE'}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: widget.esEjecutivo
                                ? const Color(0xFF78350F)
                                : Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                        decoration: BoxDecoration(
                          color: widget.cuentaActiva
                              ? const Color(0xFF10B981).withValues(alpha: 0.25)
                              : const Color(0xFFEF4444).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.cuentaActiva ? 'Cuenta Activa' : 'Cuenta Inactiva',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Text(
                        'Saldo Disponible',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFBAE6FD),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => setState(() => _mostrarSaldo = !_mostrarSaldo),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _mostrarSaldo
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 15,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _mostrarSaldo ? 'Ocultar saldo' : 'Mostrar saldo',
                                style: const TextStyle(fontSize: 11, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _mostrarSaldo ? saldoTexto : '\$ •••••• MXN',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFF3D57A), Color(0xFFD1A438)],
                                ),
                              ),
                              child: const Icon(
                                Icons.memory_rounded,
                                size: 16,
                                color: Color(0xFF6B4F0F),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _formatearCuenta(cuentaRaw),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                              onPressed: () => setState(() => _ocultarCuenta = !_ocultarCuenta),
                              icon: Icon(
                                _ocultarCuenta
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 15,
                              ),
                              label: Text(_ocultarCuenta ? 'Ver número' : 'Ocultar número'),
                            ),
                            FilledButton.tonalIcon(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF2DCCCD).withValues(alpha: 0.25),
                                foregroundColor: const Color(0xFFA5F3FC),
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                              onPressed: () => _copiarCuenta(cuentaRaw),
                              icon: Icon(
                                _copiado ? Icons.check_rounded : Icons.copy_rounded,
                                size: 15,
                              ),
                              label: Text(_copiado ? 'Copiado' : 'Copiar cuenta'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'TITULAR DE LA CUENTA',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFBAE6FD),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.nombreTitular,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.correo,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                  if (widget.clienteId != null || widget.curp != null || widget.rfc != null) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (widget.clienteId != null)
                          _BadgeFiscal(texto: 'Cliente #${widget.clienteId}'),
                        if (widget.curp != null && widget.curp!.isNotEmpty)
                          _BadgeFiscal(texto: 'CURP: ${widget.curp}'),
                        if (widget.rfc != null && widget.rfc!.isNotEmpty)
                          _BadgeFiscal(texto: 'RFC: ${widget.rfc}'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeFiscal extends StatelessWidget {
  const _BadgeFiscal({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
