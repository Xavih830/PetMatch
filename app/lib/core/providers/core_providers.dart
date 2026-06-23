import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/session_service.dart';
import '../services/notification_service.dart';
import '../data/local_data_store.dart';

// Proveedor de SharedPreferences (se sobreescribirá en main.dart tras inicializarse)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences no ha sido inicializado en main.dart');
});

// Proveedor de SessionService
final sessionServiceProvider = Provider<SessionService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SessionService(prefs);
});

// Proveedor de NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Proveedor de LocalDataStore
final localDataStoreProvider = Provider<LocalDataStore>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalDataStore(prefs);
});
