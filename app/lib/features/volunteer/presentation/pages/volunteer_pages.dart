import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/campaign_entity.dart';
import '../../domain/entities/volunteer_record_entity.dart';
import '../../volunteer_business.dart';

// S40: Explorar campañas
class ExploreCampaignsScreen extends ConsumerWidget {
  const ExploreCampaignsScreen({super.key});

  void _showNotificationsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final notifications = [
          {
            'title': '¡Inscripción Exitosa!',
            'desc': 'Te has registrado correctamente para la campaña de paseo en Samanes.',
            'time': 'Hace 2 min',
            'read': false,
          },
          {
            'title': 'Recordatorio de Actividad',
            'desc': 'Tu voluntariado de baño de cachorros inicia mañana a las 09:00 AM.',
            'time': 'Hace 1 hora',
            'read': false,
          },
          {
            'title': 'Certificado Disponible',
            'desc': 'Ya puedes descargar tu certificado de participación por acumular 12 horas.',
            'time': 'Hace 1 día',
            'read': true,
          },
          {
            'title': 'Nueva Campaña Publicada',
            'desc': 'Fundación Huellitas de Amor publicó una nueva feria de adopción en Urdesa.',
            'time': 'Hace 2 días',
            'read': true,
          }
        ];

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Notificaciones', style: AppTextStyles.h2),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    final isRead = notif['read'] as bool;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: isRead ? Colors.grey.shade200 : AppColors.secondary.withOpacity(0.15),
                        child: Icon(
                          isRead ? Icons.notifications_none : Icons.notifications_active,
                          color: isRead ? Colors.grey : AppColors.secondary,
                        ),
                      ),
                      title: Text(
                        notif['title'] as String,
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(notif['desc'] as String, style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(notif['time'] as String, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider).user?.id ?? 'u3';
    final volState = ref.watch(volunteerProvider(userId));
    final campaigns = volState.campaigns;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Voluntariado', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () => _showNotificationsDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go(AppRoutes.login);
            },
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) context.push(AppRoutes.volunteerProfile);
          else if (index == 2) context.push(AppRoutes.volunteerHistory);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Campañas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.stars), label: 'Historial'),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner de Racha / Gamificación
          _buildRachaBanner(volState.record),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text('Campañas Activas en Guayaquil', style: AppTextStyles.h2),
          ),
          
          Expanded(
            child: volState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : campaigns.isEmpty
                    ? const Center(child: Text('No hay campañas de voluntariado programadas.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: campaigns.length,
                        itemBuilder: (context, index) {
                          final camp = campaigns[index];
                          return Card(
                            color: AppColors.surface,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.volunteer_activism, color: AppColors.secondary),
                              ),
                              title: Text(camp.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Sector: ${camp.location}\nFecha: ${camp.date.day}/${camp.date.month}/${camp.date.year}\nCupos libres: ${camp.capacity - camp.enrolledVolunteersCount}'),
                              isThreeLine: true,
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push(AppRoutes.campaignDetail.replaceAll(':id', camp.id)),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildRachaBanner(VolunteerRecordEntity? rec) {
    final completed = rec?.campaignsCompleted ?? 0;
    return Container(
      color: Colors.amber.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orange, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Racha de Voluntariado',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange),
                ),
                Text(
                  'Has completado $completed campañas. ¡Sigue apoyando para desbloquear insignias!',
                  style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// S41: Detalle de campaña
class CampaignDetailScreen extends ConsumerStatefulWidget {
  final String campaignId;
  const CampaignDetailScreen({super.key, required this.campaignId});

  @override
  ConsumerState<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends ConsumerState<CampaignDetailScreen> {
  final List<String> _selectedSkills = [];
  bool _isEnrolled = false;

  void _enroll(CampaignEntity camp, String userId) async {
    await ref.read(volunteerProvider(userId).notifier).enroll(camp.id, _selectedSkills);
    setState(() => _isEnrolled = true);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Inscrito con éxito! Recordatorio de 24h configurado.'), backgroundColor: AppColors.success),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authProvider).user?.id ?? 'u3';
    final store = ref.watch(localDataStoreProvider);
    
    CampaignEntity? camp;
    try {
      camp = store.campaigns.firstWhere((c) => c.id == widget.campaignId);
    } catch (_) {}

    if (camp == null) {
      return const Scaffold(body: Center(child: Text('Campaña no encontrada')));
    }

    final availableSkills = camp.skillsRequired;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Detalle de Campaña'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Text(camp.type.toUpperCase(), style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 10)),
            ),
            const SizedBox(height: 8),
            Text(camp.title, style: AppTextStyles.h1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(camp.location, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.date_range, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text('${camp.date.day}/${camp.date.month}/${camp.date.year}', style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
            const Divider(height: 30),

            const Text('Descripción de la Actividad', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(camp.description, style: const TextStyle(height: 1.5, color: AppColors.textPrimary)),
            const SizedBox(height: 24),

            const Text('Habilidades requeridas (Toca para seleccionar cuál aportarás)', style: AppTextStyles.h3),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: availableSkills.map((skill) {
                final isSelected = _selectedSkills.contains(skill);
                return FilterChip(
                  label: Text(skill),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedSkills.add(skill);
                      } else {
                        _selectedSkills.remove(skill);
                      }
                    });
                  },
                  selectedColor: AppColors.secondary.withOpacity(0.2),
                  checkmarkColor: AppColors.secondary,
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isEnrolled ? null : () => _enroll(camp!, userId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(_isEnrolled ? '¡Ya Inscrito!' : 'Inscribirse en Campaña', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// S42: Mi perfil de voluntario
class VolunteerProfileScreen extends ConsumerStatefulWidget {
  const VolunteerProfileScreen({super.key});

  @override
  ConsumerState<VolunteerProfileScreen> createState() => _VolunteerProfileScreenState();
}

class _VolunteerProfileScreenState extends ConsumerState<VolunteerProfileScreen> {
  final _skills = ['Paseo de perros', 'Alimentación felina', 'Baño y peluquería', 'Atención al público'];
  final List<String> _selectedSkills = [];

  String _availability = 'Sábados por la mañana';
  String _area = 'Guayaquil Norte';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(authProvider).user?.id ?? 'u3';
      final rec = ref.read(volunteerProvider(userId)).record;
      if (rec != null) {
        setState(() {
          _selectedSkills.addAll(rec.skills);
          _availability = rec.availability;
          _area = rec.area;
        });
      }
    });
  }

  void _save() async {
    final userId = ref.read(authProvider).user?.id ?? 'u3';
    await ref.read(volunteerProvider(userId).notifier).updateProfile(
      skills: _selectedSkills,
      availability: _availability,
      area: _area,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil de voluntario guardado con éxito'), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authProvider).user?.id ?? 'u3';
    final volState = ref.watch(volunteerProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Mi Perfil de Voluntario'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) context.replace(AppRoutes.voluntarioHome);
          else if (index == 2) context.replace(AppRoutes.volunteerHistory);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Campañas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.stars), label: 'Historial'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Habilidades a Aportar', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _skills.map((skill) {
                final isSelected = _selectedSkills.contains(skill);
                return FilterChip(
                  label: Text(skill),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedSkills.add(skill);
                      } else {
                        _selectedSkills.remove(skill);
                      }
                    });
                  },
                  selectedColor: AppColors.secondary.withOpacity(0.2),
                  checkmarkColor: AppColors.secondary,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            const Text('Disponibilidad Semanal', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _availability,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'Sábados por la mañana', child: Text('Sábados por la mañana')),
                DropdownMenuItem(value: 'Domingos', child: Text('Domingos')),
                DropdownMenuItem(value: 'Fines de semana completos', child: Text('Fines de semana completos')),
                DropdownMenuItem(value: 'Entre semana (Nocturno)', child: Text('Entre semana (Nocturno)')),
              ],
              onChanged: (val) => setState(() => _availability = val!),
            ),
            const SizedBox(height: 24),

            const Text('Zona Geográfica (Residencia)', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _area,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'Guayaquil Norte', child: Text('Guayaquil Norte')),
                DropdownMenuItem(value: 'Guayaquil Centro', child: Text('Guayaquil Centro')),
                DropdownMenuItem(value: 'Guayaquil Sur', child: Text('Guayaquil Sur')),
                DropdownMenuItem(value: 'Samborondón / Vía a la Costa', child: Text('Samborondón / Vía a la Costa')),
              ],
              onChanged: (val) => setState(() => _area = val!),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: volState.isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Guardar Configuración', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// S43: Mi historial (logros + certificado trigger)
class VolunteerHistoryScreen extends ConsumerWidget {
  const VolunteerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider).user?.id ?? 'u3';
    final volState = ref.watch(volunteerProvider(userId));
    final rec = volState.record;

    final badges = rec?.badges ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Mis Logros y Actividad'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) context.replace(AppRoutes.voluntarioHome);
          else if (index == 1) context.replace(AppRoutes.volunteerProfile);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Campañas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.stars), label: 'Historial'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mi Desempeño', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            Card(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('Campañas', '${rec?.campaignsCompleted ?? 0}'),
                    Container(width: 1, height: 40, color: Colors.grey.shade300),
                    _buildStatCol('Horas', '${rec?.hoursAccumulated ?? 0}h'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Insignias Desbloqueadas', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            badges.isEmpty
                ? const Text('¡Participa en campañas para ganar insignias!')
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: badges.length,
                    itemBuilder: (context, index) {
                      final badge = badges[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber, width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.military_tech, color: Colors.amber, size: 36),
                            const SizedBox(height: 4),
                            Text(
                              badge,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 35),

            // Certificado Descargar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push(AppRoutes.volunteerCertificate);
                },
                icon: const Icon(Icons.file_present),
                label: const Text('Descargar Certificado de Voluntariado', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCol(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.subtitle),
      ],
    );
  }
}

// S44: Certificado PDF Vista Previa y Descarga
class VolunteerCertificateScreen extends ConsumerWidget {
  const VolunteerCertificateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider).user?.id ?? 'u3';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Certificado de Voluntariado'),
      ),
      body: PdfPreview(
        build: (format) => ref.read(volunteerProvider(userId).notifier).generateCertificate(),
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        canChangeOrientation: false,
        pdfFileName: 'certificado_voluntariado_petmatch.pdf',
      ),
    );
  }
}
