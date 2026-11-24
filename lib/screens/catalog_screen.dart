import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../models/product_models.dart';
import '../services/catalog_service.dart';
import '../state/session_controller.dart';
import '../widgets/product_logo_avatar.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({
    required this.sessionController,
    this.catalogService,
    this.onProductoSeleccionado,
    super.key,
  });

  final SessionController sessionController;
  final CatalogService? catalogService;
  final void Function(CatalogProduct producto)? onProductoSeleccionado;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  static const List<String> _categorias = [
    'Todos',
    'Recargas Telefónicas',
    'Pago de Servicios',
    'Entretenimiento y Pines',
  ];
  static const List<int> _tamanosPagina = [12, 24, 36];

  late final CatalogService _service;
  final _busquedaController = TextEditingController();
  final _scrollController = ScrollController();

  List<CatalogProduct> _productos = const [];
  String _categoriaSeleccionada = 'Todos';
  String _filtroBusqueda = '';
  int _paginaActual = 1;
  int _tamanoPagina = 12;
  bool _vistaCuadricula = true;
  bool _cargando = true;
  String? _errorMensaje;

  @override
  void initState() {
    super.initState();
    _service = widget.catalogService ?? CatalogService(apiClient: widget.sessionController.apiClient);
    _cargarCatalogo();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _cargarCatalogo() async {
    setState(() {
      _cargando = true;
      _errorMensaje = null;
    });

    try {
      final lista = await _service.obtenerCatalogoProductos();
      if (!mounted) return;
      setState(() {
        _productos = lista;
        _paginaActual = 1;
        _cargando = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMensaje = e.message;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMensaje = 'No fue posible cargar el catálogo de productos GestoPago.';
        _cargando = false;
      });
    }
  }

  List<CatalogProduct> get _productosFiltrados {
    return _productos.where((prod) {
      final coincideCategoria =
          _categoriaSeleccionada == 'Todos' || prod.categoria == _categoriaSeleccionada;
      if (!coincideCategoria) return false;
      if (_filtroBusqueda.isEmpty) return true;
      final q = _filtroBusqueda.toLowerCase();
      return prod.nombre.toLowerCase().contains(q) ||
          prod.servicio.toLowerCase().contains(q) ||
          prod.idProducto.toString().contains(q) ||
          prod.categoria.toLowerCase().contains(q);
    }).toList();
  }

  void _cambiarPagina(int nuevaPagina, int totalPaginas) {
    final acotada = nuevaPagina.clamp(1, totalPaginas);
    setState(() => _paginaActual = acotada);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
  }

  void _mostrarDetalleProducto(CatalogProduct producto) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      ProductLogoAvatar(producto: producto, size: 54),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              producto.nombre,
                              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${producto.servicio} • ${producto.categoria}',
                              style: TextStyle(color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Precio / Importe:'),
                            Text(
                              producto.precio > 0
                                  ? '\$${producto.precio.toStringAsFixed(2)} MXN'
                                  : 'Monto variable de recibo',
                              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('ID Producto: #${producto.idProducto}'),
                            Text('ID Servicio: #${producto.idServicio}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Tipo de operación: ${producto.esRecarga ? "Recarga Tiempo Aire" : "Pago de Servicio"}',
                              ),
                            ),
                            Chip(
                              label: Text(
                                producto.disponible ? 'Disponible' : 'No disponible',
                                style: const TextStyle(fontSize: 12),
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Descripción del producto',
                    style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    producto.descripcion,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: !producto.disponible
                        ? null
                        : () {
                            Navigator.pop(ctx);
                            if (widget.onProductoSeleccionado != null) {
                              widget.onProductoSeleccionado!(producto);
                            }
                          },
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Seleccionar para Compra'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filtrados = _productosFiltrados;
    final totalPaginas =
        filtrados.isEmpty ? 1 : (filtrados.length / _tamanoPagina).ceil();
    final paginaSegura = _paginaActual.clamp(1, totalPaginas);
    final indiceInicio = (paginaSegura - 1) * _tamanoPagina;
    final indiceFin = (indiceInicio + _tamanoPagina).clamp(0, filtrados.length);
    final productosPagina = filtrados.isEmpty
        ? const <CatalogProduct>[]
        : filtrados.sublist(indiceInicio, indiceFin);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _busquedaController,
                  onChanged: (val) => setState(() {
                    _filtroBusqueda = val.trim();
                    _paginaActual = 1;
                  }),
                  decoration: InputDecoration(
                    hintText: 'Buscar producto, marca o ID...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _filtroBusqueda.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _busquedaController.clear();
                              setState(() {
                                _filtroBusqueda = '';
                                _paginaActual = 1;
                              });
                            },
                            icon: const Icon(Icons.clear_rounded),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Actualizar catálogo desde GestoPago',
                onPressed: _cargando ? null : _cargarCatalogo,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 46,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _categorias.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categorias[index];
              final seleccionada = cat == _categoriaSeleccionada;
              return ChoiceChip(
                label: Text(cat),
                selected: seleccionada,
                onSelected: (_) => setState(() {
                  _categoriaSeleccionada = cat;
                  _paginaActual = 1;
                }),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                filtrados.isEmpty
                    ? 'Mostrando 0 productos disponibles'
                    : 'Mostrando ${filtrados.length} productos (${indiceInicio + 1}-$indiceFin)',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                runSpacing: 4,
                children: [
                  DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isDense: true,
                      value: _tamanoPagina,
                      items: _tamanosPagina
                          .map(
                            (tam) => DropdownMenuItem(
                              value: tam,
                              child: Text(
                                '$tam / pág',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (nuevo) {
                        if (nuevo != null) {
                          setState(() {
                            _tamanoPagina = nuevo;
                            _paginaActual = 1;
                          });
                        }
                      },
                    ),
                  ),
                  IconButton(
                    tooltip: 'Vista en cuadrícula (2 columnas)',
                    isSelected: _vistaCuadricula,
                    color: _vistaCuadricula ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    onPressed: () => setState(() => _vistaCuadricula = true),
                    icon: const Icon(Icons.grid_view_rounded, size: 20),
                  ),
                  IconButton(
                    tooltip: 'Vista en lista amplia',
                    isSelected: !_vistaCuadricula,
                    color: !_vistaCuadricula ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    onPressed: () => setState(() => _vistaCuadricula = false),
                    icon: const Icon(Icons.view_agenda_outlined, size: 20),
                  ),
                  if (_categoriaSeleccionada != 'Todos' || _filtroBusqueda.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        _busquedaController.clear();
                        setState(() {
                          _categoriaSeleccionada = 'Todos';
                          _filtroBusqueda = '';
                          _paginaActual = 1;
                        });
                      },
                      child: const Text('Limpiar'),
                    ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _construirContenido(productosPagina, colorScheme),
        ),
        if (!_cargando && _errorMensaje == null && filtrados.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        onPressed: paginaSegura > 1
                            ? () => _cambiarPagina(paginaSegura - 1, totalPaginas)
                            : null,
                        icon: const Icon(Icons.chevron_left_rounded, size: 18),
                        label: const Text('Anterior'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  flex: 4,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Página $paginaSegura de $totalPaginas',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        onPressed: paginaSegura < totalPaginas
                            ? () => _cambiarPagina(paginaSegura + 1, totalPaginas)
                            : null,
                        icon: const Icon(Icons.chevron_right_rounded, size: 18),
                        label: const Text('Siguiente'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _construirContenido(List<CatalogProduct> productosPagina, ColorScheme colorScheme) {
    if (_cargando) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text('Consultando catálogo oficial de GestoPago...'),
          ],
        ),
      );
    }

    if (_errorMensaje != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 56, color: colorScheme.error),
              const SizedBox(height: 12),
              Text(
                _errorMensaje!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _cargarCatalogo,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar consulta'),
              ),
            ],
          ),
        ),
      );
    }

    if (productosPagina.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 56, color: colorScheme.outline),
              const SizedBox(height: 12),
              const Text(
                'No se encontraron productos que coincidan con tu búsqueda.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = !_vistaCuadricula
            ? 1
            : width >= 1120
                ? 4
                : width >= 720
                    ? 3
                    : 2;

        return RefreshIndicator(
          onRefresh: _cargarCatalogo,
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: crossAxisCount == 1 ? 222 : 254,
            ),
            itemCount: productosPagina.length,
            itemBuilder: (context, index) {
              final prod = productosPagina[index];
              return _TarjetaProductoCatalogo(
                producto: prod,
                compacta: crossAxisCount > 1,
                onVerDetalle: () => _mostrarDetalleProducto(prod),
                onComprar: () {
                  if (widget.onProductoSeleccionado != null) {
                    widget.onProductoSeleccionado!(prod);
                  } else {
                    _mostrarDetalleProducto(prod);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _TarjetaProductoCatalogo extends StatelessWidget {
  const _TarjetaProductoCatalogo({
    required this.producto,
    required this.compacta,
    required this.onVerDetalle,
    required this.onComprar,
  });

  final CatalogProduct producto;
  final bool compacta;
  final VoidCallback onVerDetalle;
  final VoidCallback onComprar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onVerDetalle,
        child: Padding(
          padding: EdgeInsets.all(compacta ? 12 : 16),
          child: compacta
              ? _construirContenidoCompacto(context, colorScheme)
              : _construirContenidoAmplio(context, colorScheme),
        ),
      ),
    );
  }

  Widget _construirEstadoBadge(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: producto.disponible
            ? Colors.green.withValues(alpha: 0.14)
            : colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        producto.disponible ? 'Activo' : 'Inactivo',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: producto.disponible ? Colors.green.shade800 : colorScheme.onErrorContainer,
        ),
      ),
    );
  }

  Widget _construirContenidoCompacto(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductLogoAvatar(producto: producto, size: 40),
            _construirEstadoBadge(colorScheme),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          producto.nombre,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          producto.servicio,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
        ),
        const Spacer(),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            producto.precio > 0
                ? '\$${producto.precio.toStringAsFixed(2)} MXN'
                : 'Monto abierto',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Prod #${producto.idProducto} • Serv #${producto.idServicio}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.outline,
                  fontSize: 10.5,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                ),
                onPressed: onVerDetalle,
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Detalle', style: TextStyle(fontSize: 12)),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                ),
                onPressed: producto.disponible ? onComprar : null,
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Comprar', style: TextStyle(fontSize: 12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _construirContenidoAmplio(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductLogoAvatar(producto: producto, size: 46),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    producto.servicio,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            _construirEstadoBadge(colorScheme),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Text(
            producto.descripcion,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        const Divider(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  producto.precio > 0
                      ? '\$${producto.precio.toStringAsFixed(2)} MXN'
                      : 'Monto abierto',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Prod #${producto.idProducto} • Serv #${producto.idServicio}',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.outline,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                onPressed: onVerDetalle,
                icon: const Icon(Icons.info_outline_rounded, size: 16),
                label: const Text('Detalle'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                onPressed: producto.disponible ? onComprar : null,
                icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 16),
                label: const Text('Comprar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
