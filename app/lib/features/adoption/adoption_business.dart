import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/local_data_store.dart';
import '../../core/providers/core_providers.dart';
import '../../core/services/notification_service.dart';
import '../chat/domain/entities/message_entity.dart';
import 'domain/entities/adoption_request_entity.dart';

// Interfaces del Dominio
abstract class AdoptionRepository {
  Future<List<AdoptionRequestEntity>> getRequests();
  Future<void> addRequest(AdoptionRequestEntity req);
  Future<void> updateRequestStatus(String id, String status);
}

abstract class ChatRepository {
  Future<List<MessageEntity>> getMessages(String petId, String userId);
  Future<void> sendMessage(String petId, String userId, MessageEntity msg);
}

// Capa de Implementación (Data)
class AdoptionRepositoryImpl implements AdoptionRepository {
  final LocalDataStore _store;
  AdoptionRepositoryImpl(this._store);

  @override
  Future<List<AdoptionRequestEntity>> getRequests() async => _store.adoptionRequests;

  @override
  Future<void> addRequest(AdoptionRequestEntity req) async => _store.addAdoptionRequest(req);

  @override
  Future<void> updateRequestStatus(String id, String status) async => _store.updateAdoptionRequest(id, status);
}

class ChatRepositoryImpl implements ChatRepository {
  final LocalDataStore _store;
  ChatRepositoryImpl(this._store);

  @override
  Future<List<MessageEntity>> getMessages(String petId, String userId) async {
    final key = '${petId}_$userId';
    return _store.chatRooms[key] ?? [];
  }

  @override
  Future<void> sendMessage(String petId, String userId, MessageEntity msg) async {
    _store.addMessage(petId, userId, msg);
  }
}

// Riverpod Repositorios
final adoptionRepositoryProvider = Provider<AdoptionRepository>((ref) {
  return AdoptionRepositoryImpl(ref.watch(localDataStoreProvider));
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(localDataStoreProvider));
});

// Modelo de Guía de Adopción Responsable (Estático)
class AdoptionGuide {
  final String title;
  final String description;
  final String duration;
  final String category;

  const AdoptionGuide({
    required this.title,
    required this.description,
    required this.duration,
    required this.category,
  });
}

// Listado de Guías quemadas
final adoptionGuides = [
  const AdoptionGuide(
    title: 'Preparando el Hogar',
    description: 'Asegura cables sueltos, quita plantas tóxicas y delimita las zonas seguras antes de que llegue tu mascota.',
    duration: 'Lectura de 3 min',
    category: 'Preparación',
  ),
  const AdoptionGuide(
    title: 'Los Primeros 3 Días',
    description: 'Deja que el animal explore su nuevo espacio a su ritmo. No lo abrumes, la paciencia es la clave.',
    duration: 'Lectura de 5 min',
    category: 'Adaptación',
  ),
  const AdoptionGuide(
    title: 'Socialización Básica',
    description: 'Aprende a introducir a tu mascota a otros animales y humanos de forma progresiva y con refuerzo positivo.',
    duration: 'Lectura de 4 min',
    category: 'Comportamiento',
  ),
  const AdoptionGuide(
    title: 'Nutrición y Salud',
    description: 'Tipos de porciones según la edad y desparasitación. Qué alimentos nunca debes darle a tu perro o gato.',
    duration: 'Lectura de 6 min',
    category: 'Salud',
  ),
];

// Modelo para el Calendario de Alertas de Cuidado
class CareAlert {
  final String title;
  final String description;
  final DateTime date;
  final bool isCompleted;

  const CareAlert({
    required this.title,
    required this.description,
    required this.date,
    required this.isCompleted,
  });
}

// State Notifier para Adopciones y Alertas
class AdoptionState {
  final List<AdoptionRequestEntity> requests;
  final List<CareAlert> careAlerts;
  final bool isLoading;

  AdoptionState({
    required this.requests,
    required this.careAlerts,
    this.isLoading = false,
  });

  AdoptionState copyWith({
    List<AdoptionRequestEntity>? requests,
    List<CareAlert>? careAlerts,
    bool? isLoading,
  }) {
    return AdoptionState(
      requests: requests ?? this.requests,
      careAlerts: careAlerts ?? this.careAlerts,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AdoptionNotifier extends StateNotifier<AdoptionState> {
  final AdoptionRepository _repository;
  final LocalDataStore _store;
  final NotificationService _notificationService;

  AdoptionNotifier(this._repository, this._store, this._notificationService)
      : super(AdoptionState(requests: [], careAlerts: [])) {
    loadAdoptions();
  }

  Future<void> loadAdoptions() async {
    state = state.copyWith(isLoading: true);
    final reqs = await _repository.getRequests();
    
    // Generar el calendario de alertas para adopciones aprobadas/completadas
    final List<CareAlert> alerts = [];
    for (final req in reqs) {
      if (req.status == 'aprobada' || req.status == 'completada') {
        // Encontrar especie del animal
        String species = 'perro';
        try {
          final pet = _store.pets.firstWhere((p) => p.id == req.petId);
          species = pet.species;
        } catch (_) {}

        if (species == 'perro') {
          alerts.add(CareAlert(
            title: 'Vacuna Antirrábica de ${req.petName}',
            description: 'Refuerzo anual obligatorio contra la rabia.',
            date: req.date.add(const Duration(days: 7)),
            isCompleted: false,
          ));
          alerts.add(CareAlert(
            title: 'Vacuna Quíntuple de ${req.petName}',
            description: 'Protección integral contra distemper, parvovirus, hepatitis y parainfluenza.',
            date: req.date.add(const Duration(days: 14)),
            isCompleted: false,
          ));
          alerts.add(CareAlert(
            title: 'Desparasitación Trimestral de ${req.petName}',
            description: 'Control de parásitos internos para mantener su salud digestiva.',
            date: req.date.add(const Duration(days: 30)),
            isCompleted: false,
          ));
        } else {
          // Gato
          alerts.add(CareAlert(
            title: 'Vacuna Triple Felina de ${req.petName}',
            description: 'Protege contra panleucopenia, rinotraqueitis y calicivirus felino.',
            date: req.date.add(const Duration(days: 7)),
            isCompleted: false,
          ));
          alerts.add(CareAlert(
            title: 'Desparasitación Interna de ${req.petName}',
            description: 'Pastilla o pipeta recomendada por el veterinario.',
            date: req.date.add(const Duration(days: 20)),
            isCompleted: false,
          ));
        }
        alerts.add(CareAlert(
          title: 'Chequeo Preventivo General',
          description: 'Control veterinario de peso, oídos, dientes y corazón.',
          date: req.date.add(const Duration(days: 60)),
          isCompleted: false,
        ));
      }
    }
    
    state = AdoptionState(requests: reqs, careAlerts: alerts, isLoading: false);
  }

  Future<void> submitAdoptionRequest({
    required String petId,
    required String petName,
    required String petImage,
    required String applicantId,
    required String applicantName,
    required String summary,
  }) async {
    state = state.copyWith(isLoading: true);
    
    final newRequest = AdoptionRequestEntity(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      petId: petId,
      petName: petName,
      petImage: petImage,
      applicantId: applicantId,
      applicantName: applicantName,
      applicantProfileSummary: summary,
      status: 'pendiente',
      date: DateTime.now(),
    );

    await _repository.addRequest(newRequest);
    
    // RNF06/RF21: Programar recordatorio de adopción pendiente a las 48 horas
    await _notificationService.scheduleNotification(
      id: newRequest.hashCode,
      title: 'Seguimiento de Adopción',
      body: 'Han pasado 48 horas desde tu solicitud de ${newRequest.petName}. Abre el chat para consultar con la fundación.',
      scheduledDate: DateTime.now().add(const Duration(hours: 48)),
    );

    await loadAdoptions();
  }

  Future<void> updateStatus(String reqId, String status) async {
    state = state.copyWith(isLoading: true);
    await _repository.updateRequestStatus(reqId, status);
    
    // RNF06/RF21: Si el coordinador aprueba o rechaza, disparar notificación inmediata al adoptante
    final req = _store.adoptionRequests.firstWhere((r) => r.id == reqId);
    
    if (status == 'aprobada') {
      await _notificationService.showNotification(
        id: req.hashCode,
        title: '¡Felicidades!',
        body: 'Tu solicitud para adoptar a ${req.petName} fue aprobada por la fundación.',
      );

      // Programar también las alertas de cuidado automáticamente en el dispositivo
      final targetDate1 = DateTime.now().add(const Duration(days: 7));
      await _notificationService.scheduleNotification(
        id: req.hashCode + 1,
        title: 'Recordatorio de vacuna para ${req.petName}',
        body: 'Esta semana toca la vacuna correspondiente para tu nueva mascota ${req.petName}.',
        scheduledDate: targetDate1,
      );
    } else if (status == 'rechazada') {
      await _notificationService.showNotification(
        id: req.hashCode,
        title: 'Actualización de Solicitud',
        body: 'Tu solicitud para adoptar a ${req.petName} fue rechazada. Te invitamos a aplicar para otra mascota.',
      );
    }

    await loadAdoptions();
  }
}

final adoptionProvider = StateNotifierProvider<AdoptionNotifier, AdoptionState>((ref) {
  final repo = ref.watch(adoptionRepositoryProvider);
  final store = ref.watch(localDataStoreProvider);
  final notification = ref.watch(notificationServiceProvider);
  return AdoptionNotifier(repo, store, notification);
});

// Chat State Manager
class ChatState {
  final List<MessageEntity> messages;
  final bool isLoading;

  ChatState({
    required this.messages,
    this.isLoading = false,
  });
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _chatRepository;
  final String petId;
  final String userId;

  ChatNotifier(this._chatRepository, {required this.petId, required this.userId})
      : super(ChatState(messages: [])) {
    loadMessages();
  }

  Future<void> loadMessages() async {
    state = ChatState(messages: state.messages, isLoading: true);
    final msgs = await _chatRepository.getMessages(petId, userId);
    state = ChatState(messages: msgs, isLoading: false);
  }

  Future<void> sendMessage(String senderId, String senderName, String text) async {
    final msg = MessageEntity(
      senderId: senderId,
      senderName: senderName,
      content: text,
      timestamp: DateTime.now(),
    );
    await _chatRepository.sendMessage(petId, userId, msg);
    await loadMessages();
  }
}

final chatProvider = StateNotifierProvider.family<ChatNotifier, ChatState, String>((ref, roomParams) {
  // roomParams en formato "petId_userId"
  final parts = roomParams.split('_');
  final petId = parts[0];
  final userId = parts[1];
  final repo = ref.watch(chatRepositoryProvider);
  return ChatNotifier(repo, petId: petId, userId: userId);
});
