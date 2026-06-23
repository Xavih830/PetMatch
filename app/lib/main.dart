import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/providers/core_providers.dart';
import 'core/services/notification_service.dart';

void main() async {
  // Asegurar inicialización de bindings nativos de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Instanciar e inicializar el Servicio de Notificaciones Locales
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    ProviderScope(
      overrides: [
        // Inyectar la instancia concreta de SharedPreferences en el proveedor global
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        
        // Inyectar el servicio de notificaciones inicializado
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const PetMatchApp(),
    ),
  );
}
