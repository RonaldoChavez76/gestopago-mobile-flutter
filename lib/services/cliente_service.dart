import '../core/network/api_client.dart';
import '../models/cliente_models.dart';

class ClienteService {
  const ClienteService({required this.apiClient});

  final ApiClient apiClient;

  Future<RegistroClienteResultado> registrarCliente(RegistroClienteSolicitud solicitud) async {
    final response = await apiClient.postJson(
      '/clientes',
      requiereAuth: false,
      body: solicitud.toRequestJson(),
    );
    final data = response['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return RegistroClienteResultado.fromJson(data);
  }

  Future<ClientePerfil> consultarPerfil(int clienteId) async {
    final response = await apiClient.postJson(
      '/clientes/consulta',
      body: {'clienteId': clienteId},
    );
    final data = response['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return ClientePerfil.fromJson(data);
  }

  Future<ClientePerfil> actualizarPerfil(int clienteId, ClientePerfil perfil) async {
    final response = await apiClient.putJson(
      '/clientes/actualizar',
      body: {
        'clienteId': clienteId,
        'datos': perfil.toActualizarRequestJson(),
      },
    );
    final data = response['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return ClientePerfil.fromJson(data);
  }

  Future<String> cambiarPassword({
    required int usuarioId,
    required String passwordActual,
    required String passwordNueva,
  }) async {
    final response = await apiClient.putJson(
      '/usuarios/password',
      body: {
        'usuarioId': usuarioId,
        'cambio': {
          'passwordActual': passwordActual,
          'passwordNueva': passwordNueva,
        },
      },
    );
    return (response['message'] ?? 'Contraseña actualizada correctamente.').toString();
  }

  Future<String> darDeBaja(int clienteId) async {
    final response = await apiClient.deleteJson(
      '/clientes/baja',
      body: {'clienteId': clienteId},
    );
    return (response['message'] ?? 'Cliente dado de baja lógicamente.').toString();
  }

  Future<String> reactivarCliente(int clienteId) async {
    final response = await apiClient.putJson(
      '/clientes/reactivar',
      body: {'clienteId': clienteId},
    );
    return (response['message'] ?? 'Cliente reactivado correctamente.').toString();
  }
}
