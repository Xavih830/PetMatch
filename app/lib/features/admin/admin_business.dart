import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/local_data_store.dart';
import '../../core/providers/core_providers.dart';

// Modelo de configuración
class SystemSettings {
  final double commissionRate;
  final String senderEmail;

  const SystemSettings({
    required this.commissionRate,
    required this.senderEmail,
  });
}

// State Notifier para configuraciones y acciones administrativas
class AdminState {
  final SystemSettings settings;
  final bool isLoading;

  AdminState({
    required this.settings,
    this.isLoading = false,
  });

  AdminState copyWith({
    SystemSettings? settings,
    bool? isLoading,
  }) {
    return AdminState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  final LocalDataStore _store;

  AdminNotifier(this._store)
      : super(AdminState(
          settings: SystemSettings(
            commissionRate: _store.commissionRate,
            senderEmail: _store.senderEmail,
          ),
        ));

  Future<void> updateSettings(double rate, String email) async {
    state = state.copyWith(isLoading: true);
    _store.updateSystemSettings(rate, email);
    state = AdminState(
      settings: SystemSettings(commissionRate: rate, senderEmail: email),
      isLoading: false,
    );
  }

  Future<void> verifyFoundation(String foundationId, bool verified) async {
    state = state.copyWith(isLoading: true);
    // Encontrar fundacion y actualizar
    try {
      final f = _store.foundations.firstWhere((element) => element.id == foundationId);
      final updated = f.copyWith(verified: verified);
      _store.updateFoundation(updated);
    } catch (_) {}
    state = state.copyWith(isLoading: false);
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final store = ref.watch(localDataStoreProvider);
  return AdminNotifier(store);
});
