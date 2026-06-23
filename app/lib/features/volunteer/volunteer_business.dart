import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/data/local_data_store.dart';
import '../../core/providers/core_providers.dart';
import '../../core/services/notification_service.dart';
import 'domain/entities/campaign_entity.dart';
import 'domain/entities/volunteer_record_entity.dart';

// Interfaces del Dominio
abstract class VolunteerRepository {
  Future<List<CampaignEntity>> getCampaigns();
  Future<VolunteerRecordEntity?> getRecord(String userId);
  Future<void> enrollInCampaign(String campaignId, String userId, List<String> skills);
  Future<void> updateProfile({
    required String userId,
    required List<String> skills,
    required String availability,
    required String area,
  });
}

// Implementación Data
class VolunteerRepositoryImpl implements VolunteerRepository {
  final LocalDataStore _store;
  VolunteerRepositoryImpl(this._store);

  @override
  Future<List<CampaignEntity>> getCampaigns() async => _store.campaigns;

  @override
  Future<VolunteerRecordEntity?> getRecord(String userId) async {
    try {
      return _store.volunteerRecords.firstWhere((r) => r.userId == userId);
    } catch (_) {
      // Crear uno por defecto si no existe
      final newRec = VolunteerRecordEntity(
        id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        name: 'Voluntario',
        campaignsCompleted: 0,
        hoursAccumulated: 0,
        badges: const [],
        skills: const [],
        availability: 'No definida',
        area: 'Guayaquil',
      );
      _store.volunteerRecords.add(newRec);
      return newRec;
    }
  }

  @override
  Future<void> enrollInCampaign(String campaignId, String userId, List<String> skills) async {
    _store.enrollInCampaign(campaignId, userId, skills);
  }

  @override
  Future<void> updateProfile({
    required String userId,
    required List<String> skills,
    required String availability,
    required String area,
  }) async {
    _store.updateVolunteerProfile(
      userId: userId,
      skills: skills,
      availability: availability,
      area: area,
    );
  }
}

// Riverpod Repositorio
final volunteerRepositoryProvider = Provider<VolunteerRepository>((ref) {
  return VolunteerRepositoryImpl(ref.watch(localDataStoreProvider));
});

// State Notifier para Voluntariado
class VolunteerState {
  final List<CampaignEntity> campaigns;
  final VolunteerRecordEntity? record;
  final bool isLoading;

  VolunteerState({
    required this.campaigns,
    this.record,
    this.isLoading = false,
  });

  VolunteerState copyWith({
    List<CampaignEntity>? campaigns,
    VolunteerRecordEntity? record,
    bool? isLoading,
  }) {
    return VolunteerState(
      campaigns: campaigns ?? this.campaigns,
      record: record ?? this.record,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class VolunteerNotifier extends StateNotifier<VolunteerState> {
  final VolunteerRepository _repository;
  final NotificationService _notificationService;
  final LocalDataStore _store;
  final String userId;

  VolunteerNotifier(this._repository, this._notificationService, this._store, this.userId)
      : super(VolunteerState(campaigns: [])) {
    loadVolunteerData();
  }

  Future<void> loadVolunteerData() async {
    state = state.copyWith(isLoading: true);
    final camps = await _repository.getCampaigns();
    final rec = await _repository.getRecord(userId);
    state = VolunteerState(campaigns: camps, record: rec, isLoading: false);
  }

  Future<void> enroll(String campaignId, List<String> skills) async {
    state = state.copyWith(isLoading: true);
    
    // Obtener datos de la campaña antes de inscribir
    final campaign = _store.campaigns.firstWhere((c) => c.id == campaignId);
    
    await _repository.enrollInCampaign(campaignId, userId, skills);
    
    // RNF06/RF21: Programar notificación de recordatorio 24 horas antes
    final reminderDate = campaign.date.subtract(const Duration(days: 1));
    await _notificationService.scheduleNotification(
      id: campaign.hashCode + userId.hashCode,
      title: 'Mañana es tu voluntariado',
      body: 'Recuerda asistir a la campaña "${campaign.title}" en "${campaign.location}" mañana.',
      scheduledDate: reminderDate,
    );

    // Cargar datos actualizados para ver si se obtuvo una insignia
    final oldRecord = state.record;
    await loadVolunteerData();
    final newRecord = state.record;

    // Comparar insignias
    if (oldRecord != null && newRecord != null) {
      if (newRecord.badges.length > oldRecord.badges.length) {
        final newBadge = newRecord.badges.last;
        // Notificación inmediata de logro
        await _notificationService.showNotification(
          id: newBadge.hashCode,
          title: '¡Nueva Insignia Obtenida!',
          body: 'Felicidades Sebastián, has desbloqueado la insignia "$newBadge" por tu dedicación.',
        );
      }
    }
  }

  Future<void> updateProfile({
    required List<String> skills,
    required String availability,
    required String area,
  }) async {
    state = state.copyWith(isLoading: true);
    await _repository.updateProfile(
      userId: userId,
      skills: skills,
      availability: availability,
      area: area,
    );
    await loadVolunteerData();
  }

  // Generación de Certificado PDF utilizando paquete pdf
  Future<Uint8List> generateCertificate() async {
    final pdf = pw.Document();
    
    final rec = state.record ?? const VolunteerRecordEntity(
      id: '',
      userId: '',
      name: 'Sebastián Vera',
      campaignsCompleted: 3,
      hoursAccumulated: 12,
      badges: [],
      skills: [],
      availability: '',
      area: '',
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(30),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.orange, width: 4),
              color: PdfColors.white,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // Encabezado
                pw.Column(
                  children: [
                    pw.Text(
                      'CERTIFICADO DE VOLUNTARIADO',
                      style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: PdfColors.orange),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Otorgado por PetMatch Ecuador',
                      style: const pw.TextStyle(fontSize: 16, color: PdfColors.grey),
                    ),
                  ],
                ),
                
                // Cuerpo
                pw.Column(
                  children: [
                    pw.Text(
                      'Agradecemos sinceramente el apoyo y esfuerzo de:',
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                    pw.SizedBox(height: 15),
                    pw.Text(
                      rec.name,
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                      child: pw.Text(
                        'Por haber completado con éxito un total de ${rec.campaignsCompleted} campañas oficiales de ayuda social y haber acumulado ${rec.hoursAccumulated} horas de voluntariado dedicadas al baño, paseo y rescate de animales desamparados en la ciudad de Guayaquil.',
                        style: const pw.TextStyle(fontSize: 12, height: 1.5),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
                
                // Firmas y pie de página
                pw.Column(
                  children: [
                    pw.Container(
                      width: 150,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          top: pw.BorderSide(color: PdfColors.grey, width: 1),
                        ),
                      ),
                      padding: const pw.EdgeInsets.only(top: 5),
                      child: pw.Text(
                        'Coordinación PetMatch',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'Fecha de emisión: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}

final volunteerProvider = StateNotifierProvider.family<VolunteerNotifier, VolunteerState, String>((ref, userId) {
  final repo = ref.watch(volunteerRepositoryProvider);
  final notification = ref.watch(notificationServiceProvider);
  final store = ref.watch(localDataStoreProvider);
  return VolunteerNotifier(repo, notification, store, userId);
});
