# Aplicación Móvil Flutter — Ecosistema de Comercio Digital GestoPago

Aplicación móvil desarrollada en **Flutter y Dart**, conectada a la API REST del backend Spring Boot y los servicios transaccionales de GestoPago.

## Repositorios del Ecosistema (Unidad II)

| Componente | Tecnología | Repositorio |
| :--- | :--- | :--- |
| **Backend API REST** | Spring Boot 3 + Java 17 + PostgreSQL + Redis | [AppHasaniGestoPagos](https://github.com/RonaldoChavez76/AppHasaniGestoPagos) |
| **Aplicación Móvil** | Flutter & Dart | [gestopago-mobile-flutter](https://github.com/RonaldoChavez76/gestopago-mobile-flutter) |
| **Aplicación Web (PWA)** | React + TypeScript + Vite | [gestopago-web-react](https://github.com/RonaldoChavez76/gestopago-web-react) |

## Funcionalidades Principales

- **Autenticación compartida y 2FA:** Inicio de sesión con código OTP de 6 dígitos validado en servidor.
- **Control de Sesión Única Activa:** Detección de sesiones simultáneas (`WEB` vs `MOVIL`, código `409 Conflict`) con opción de cerrar la sesión previa e invalidación en tiempo real (`401 Unauthorized`).
- **Catálogo Dinámico de Productos:** Consulta en tiempo real de productos GestoPago clasificados por categorías (*Recargas Telefónicas*, *Pago de Servicios*, *Entretenimiento y Pines*).
- **Módulo de Compras:** Flujo con confirmación previa obligatoria, soporte de 2FA y diferenciación visual de estados (`EXITOSA`, `RECHAZADA`, `PENDIENTE`, `ERROR_COMUNICACION`).
- **Historial de Compras Exitosas:** Consulta sincronizada entre móvil y web mostrando exclusivamente transacciones exitosas y verificación por `UPC`.

## Requisitos

- Flutter SDK (`^3.13.2` compatible con Dart)
- Emulador Android / Dispositivo físico o navegador

## Ejecución y Pruebas

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```
