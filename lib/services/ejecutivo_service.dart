import '../core/network/api_client.dart';
import '../models/ejecutivo_models.dart';

class EjecutivoService {
  const EjecutivoService({required this.apiClient});

  final ApiClient apiClient;

  Future<PageResponse<ClienteResumenEjecutivo>> buscarClientes(
    FiltroBusquedaClientes filtros,
  ) async {
    final response = await apiClient.postJson(
      '/clientes/busqueda',
      body: filtros.toRequestJson(),
    );
    final data = response['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return PageResponse.fromJson(data, ClienteResumenEjecutivo.fromJson);
  }

  Future<PageResponse<CuentaResumenEjecutivo>> buscarCuentas(
    FiltroBusquedaCuentas filtros,
  ) async {
    final response = await apiClient.postJson(
      '/cuentas/busqueda',
      body: filtros.toRequestJson(),
    );
    final data = response['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return PageResponse.fromJson(data, CuentaResumenEjecutivo.fromJson);
  }

  Future<UsuarioResumenEjecutivo> consultarUsuarioPorId(int usuarioId) async {
    final response = await apiClient.postJson(
      '/usuarios/consulta',
      body: {'usuarioId': usuarioId},
    );
    final data = response['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return UsuarioResumenEjecutivo.fromJson(data);
  }
}
