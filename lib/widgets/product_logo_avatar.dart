import 'package:flutter/material.dart';

import '../models/product_models.dart';

class ProductLogoAvatar extends StatelessWidget {
  const ProductLogoAvatar({
    required this.producto,
    this.size = 44,
    super.key,
  });

  final CatalogProduct producto;
  final double size;

  @override
  Widget build(BuildContext context) {
    final visual = _VisualProductoStyle.paraProducto(producto, Theme.of(context).colorScheme);
    final url = producto.logoUrl;

    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: visual.colorFondo,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(
        visual.icono,
        color: visual.colorIcono,
        size: size * 0.54,
      ),
    );

    if (url == null || url.isEmpty) {
      return fallback;
    }

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9E2E7)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => fallback,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return fallback;
          },
        ),
      ),
    );
  }
}

class _VisualProductoStyle {
  const _VisualProductoStyle({
    required this.icono,
    required this.colorFondo,
    required this.colorIcono,
  });

  final IconData icono;
  final Color colorFondo;
  final Color colorIcono;

  static _VisualProductoStyle paraProducto(CatalogProduct producto, ColorScheme scheme) {
    final upper = '${producto.nombre} ${producto.servicio}'.toUpperCase();
    if (producto.categoria == 'Recargas Telefónicas') {
      return _VisualProductoStyle(
        icono: Icons.phone_android_rounded,
        colorFondo: scheme.primaryContainer,
        colorIcono: scheme.onPrimaryContainer,
      );
    }
    if (producto.categoria == 'Entretenimiento y Pines') {
      return _VisualProductoStyle(
        icono: Icons.card_giftcard_rounded,
        colorFondo: scheme.tertiaryContainer,
        colorIcono: scheme.onTertiaryContainer,
      );
    }
    if (upper.contains('CFE') || upper.contains('LUZ')) {
      return _VisualProductoStyle(
        icono: Icons.bolt_rounded,
        colorFondo: Colors.amber.withValues(alpha: 0.2),
        colorIcono: Colors.amber.shade900,
      );
    }
    if (upper.contains('TELMEX') || upper.contains('IZZI') || upper.contains('TOTALPLAY')) {
      return _VisualProductoStyle(
        icono: Icons.router_rounded,
        colorFondo: scheme.secondaryContainer,
        colorIcono: scheme.onSecondaryContainer,
      );
    }
    return _VisualProductoStyle(
      icono: Icons.receipt_long_rounded,
      colorFondo: scheme.secondaryContainer,
      colorIcono: scheme.onSecondaryContainer,
    );
  }
}
