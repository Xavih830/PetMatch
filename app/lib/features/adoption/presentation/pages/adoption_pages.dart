import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../matching/matching_business.dart';
import '../../../matching/domain/entities/pet_entity.dart';
import '../../../chat/domain/entities/message_entity.dart';
import '../../domain/entities/adoption_request_entity.dart';
import '../../adoption_business.dart';

// S15: Solicitud de adopción
class AdoptionRequestScreen extends ConsumerStatefulWidget {
  final String petId;
  const AdoptionRequestScreen({super.key, required this.petId});

  @override
  ConsumerState<AdoptionRequestScreen> createState() => _AdoptionRequestScreenState();
}

class _AdoptionRequestScreenState extends ConsumerState<AdoptionRequestScreen> {
  final _motivationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _motivationController.dispose();
    super.dispose();
  }

  void _submit(PetEntity pet, String userId, String userName) async {
    if (_formKey.currentState?.validate() ?? false) {
      final summary = 'Motivo: ${_motivationController.text.trim()}';
      
      await ref.read(adoptionProvider.notifier).submitAdoptionRequest(
        petId: pet.id,
        petName: pet.name,
        petImage: pet.images.isNotEmpty ? pet.images.first : '',
        applicantId: userId,
        applicantName: userName,
        summary: summary,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud registrada con éxito. Recordatorio programado.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(AppRoutes.myAdoptions);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchingState = ref.watch(matchingProvider);
    final user = ref.watch(authProvider).user;
    
    PetEntity? pet;
    try {
      pet = matchingState.pets.firstWhere((p) => p.id == widget.petId);
    } catch (_) {}

    if (pet == null) {
      return const Scaffold(body: Center(child: Text('Mascota no encontrada')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Solicitud de Adopción'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado mascota
              Card(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: pet.species == 'perro' ? Colors.orange.shade100 : Colors.teal.shade100,
                        child: Icon(
                          Icons.pets,
                          color: pet.species == 'perro' ? AppColors.primary : AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vas a solicitar la adopción de:', style: AppTextStyles.subtitle),
                          Text(pet.name, style: AppTextStyles.h2),
                          Text('${pet.breed} • ${pet.age} ${pet.age == 1 ? 'año' : 'años'}', style: const TextStyle(fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Datos del Adoptante
              const Text('Datos del Solicitante', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Card(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildApplicantRow('Nombre:', user?.name ?? ''),
                      const Divider(height: 16),
                      _buildApplicantRow('Correo:', user?.email ?? ''),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Formulario de motivación
              const Text('Motivación para la Adopción', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              TextFormField(
                controller: _motivationController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: '¿Por qué deseas adoptar a esta mascota?',
                  hintText: 'Cuéntanos sobre tu espacio, tiempo disponible y experiencia...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 10) {
                    return 'Por favor describe tus razones (mínimo 10 caracteres)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 35),

              // Botón Confirmar
              ElevatedButton(
                onPressed: () => _submit(pet!, user?.id ?? 'u1', user?.name ?? 'Adoptante'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Enviar Solicitud', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApplicantRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// S16: Chat interno
class InternalChatScreen extends ConsumerStatefulWidget {
  final String petId;
  final String userId;
  const InternalChatScreen({super.key, required this.petId, required this.userId});

  @override
  ConsumerState<InternalChatScreen> createState() => _InternalChatScreenState();
}

class _InternalChatScreenState extends ConsumerState<InternalChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(String senderId, String senderName) async {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _messageController.clear();
      final roomKey = '${widget.petId}_${widget.userId}';
      
      await ref.read(chatProvider(roomKey).notifier).sendMessage(
        senderId,
        senderName,
        text,
      );

      // Scroll al final
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).user;
    final roomKey = '${widget.petId}_${widget.userId}';
    final chatState = ref.watch(chatProvider(roomKey));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Conversación'),
      ),
      body: Column(
        children: [
          // Historial de mensajes
          Expanded(
            child: chatState.isLoading && chatState.messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : chatState.messages.isEmpty
                    ? const Center(child: Text('No hay mensajes previos. Inicia la conversación.'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: chatState.messages.length,
                        itemBuilder: (context, index) {
                          final msg = chatState.messages[index];
                          final isMe = msg.senderId == currentUser?.id;
                          return _buildMessageBubble(msg, isMe);
                        },
                      ),
          ),

          // Barra de entrada de texto
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surface,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primary),
                    onPressed: () => _send(currentUser?.id ?? 'u1', currentUser?.name ?? 'Usuario'),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageEntity msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                msg.senderName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.secondary),
              ),
            const SizedBox(height: 2),
            Text(
              msg.content,
              style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// S17: Mis adopciones
class MyAdoptionsScreen extends ConsumerWidget {
  const MyAdoptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adoptionsState = ref.watch(adoptionProvider);
    final currentUser = ref.watch(authProvider).user;
    
    // Filtrar solicitudes hechas por el usuario adoptante
    final myReqs = adoptionsState.requests.where((r) => r.applicantId == currentUser?.id).toList();

    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go(AppRoutes.adoptanteHome);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          title: const Text('Mis Adopciones'),
          leading: Navigator.canPop(context)
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go(AppRoutes.adoptanteHome),
                ),
        ),
        body: adoptionsState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : myReqs.isEmpty
                ? const Center(child: Text('Aún no has solicitado ninguna adopción.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: myReqs.length,
                    itemBuilder: (context, index) {
                      final req = myReqs[index];
                      return _buildAdoptionCard(context, req, currentUser?.id ?? '');
                    },
                  ),
      ),
    );
  }

  Widget _buildAdoptionCard(BuildContext context, AdoptionRequestEntity req, String userId) {
    Color statusColor = AppColors.warning;
    if (req.status == 'aprobada' || req.status == 'completada') statusColor = AppColors.success;
    else if (req.status == 'rechazada') statusColor = AppColors.error;

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.background,
                  child: const Icon(Icons.pets, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(req.petName, style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          req.status.toUpperCase(),
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Ir al chat
                    context.push(AppRoutes.chat.replaceAll(':petId', req.petId).replaceAll(':userId', userId));
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(color: AppColors.secondary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                if (req.status == 'aprobada' || req.status == 'completada')
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push(AppRoutes.careAlerts);
                    },
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('Recordatorios'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// S18: Alertas de cuidado
class CareAlertsScreen extends ConsumerWidget {
  const CareAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adoptionsState = ref.watch(adoptionProvider);
    final alerts = adoptionsState.careAlerts;

    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go(AppRoutes.adoptanteHome);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          title: const Text('Recordatorios de Cuidado'),
          leading: Navigator.canPop(context)
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go(AppRoutes.adoptanteHome),
                ),
        ),
        body: adoptionsState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : alerts.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'No tienes recordatorios activos. Estos se generan automáticamente cuando aprueban una de tus solicitudes de adopción.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Calendario de Vacunación y Control', style: AppTextStyles.h2),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: alerts.length,
                          itemBuilder: (context, index) {
                            final alert = alerts[index];
                            return Card(
                              color: AppColors.surface,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                leading: const Icon(Icons.event_note, color: AppColors.primary),
                                title: Text(alert.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${alert.description}\nFecha sugerida: ${alert.date.day}/${alert.date.month}/${alert.date.year}', style: const TextStyle(fontSize: 12)),
                                isThreeLine: true,
                                trailing: Icon(
                                  alert.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: alert.isCompleted ? AppColors.success : Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

// S19: Guías de adopción
class GuidesScreen extends StatelessWidget {
  const GuidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Guías de Adopción'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: adoptionGuides.length,
        itemBuilder: (context, index) {
          final guide = adoptionGuides[index];
          return Card(
            color: AppColors.surface,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          guide.category.toUpperCase(),
                          style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 9),
                        ),
                      ),
                      Text(guide.duration, style: AppTextStyles.subtitle),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(guide.title, style: AppTextStyles.h3),
                  const SizedBox(height: 6),
                  Text(
                    guide.description,
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
