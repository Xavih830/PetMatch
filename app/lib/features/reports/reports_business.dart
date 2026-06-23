import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/local_data_store.dart';
import '../../core/providers/core_providers.dart';
import 'domain/entities/report_entity.dart';

// Interfaz del Dominio
abstract class ReportsRepository {
  Future<List<ReportEntity>> getReports();
  Future<void> addReport(ReportEntity report);
}

// Capa Data
class ReportsRepositoryImpl implements ReportsRepository {
  final LocalDataStore _store;
  ReportsRepositoryImpl(this._store);

  @override
  Future<List<ReportEntity>> getReports() async => _store.reports;

  @override
  Future<void> addReport(ReportEntity report) async => _store.addReport(report);
}

// Riverpod Repositorio
final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepositoryImpl(ref.watch(localDataStoreProvider));
});

// State Notifier para Denuncias
class ReportsState {
  final List<ReportEntity> reports;
  final bool isLoading;

  ReportsState({
    required this.reports,
    this.isLoading = false,
  });
}

class ReportsNotifier extends StateNotifier<ReportsState> {
  final ReportsRepository _repository;

  ReportsNotifier(this._repository) : super(ReportsState(reports: [])) {
    loadReports();
  }

  Future<void> loadReports() async {
    state = ReportsState(reports: state.reports, isLoading: true);
    final list = await _repository.getReports();
    state = ReportsState(reports: list, isLoading: false);
  }

  Future<void> createReport({
    required String type,
    required String description,
    required String area,
  }) async {
    state = ReportsState(reports: state.reports, isLoading: true);
    final report = ReportEntity(
      id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      description: description,
      area: area,
      date: DateTime.now(),
      status: 'recibido',
    );
    await _repository.addReport(report);
    await loadReports();
  }
}

final reportsProvider = StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  final repo = ref.watch(reportsRepositoryProvider);
  return ReportsNotifier(repo);
});
