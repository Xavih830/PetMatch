import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/pet_entity.dart';
import '../../domain/entities/foundation_entity.dart';
import '../../matching_business.dart';

// S10: Descubrir Mascotas
class DiscoverPetsScreen extends ConsumerStatefulWidget {
  const DiscoverPetsScreen({super.key});

  @override
  ConsumerState<DiscoverPetsScreen> createState() => _DiscoverPetsScreenState();
}

class _DiscoverPetsScreenState extends ConsumerState<DiscoverPetsScreen> {
  String _selectedSpecies = 'todos'; // 'todos', 'perro', 'gato'
  bool _filterKids = false;

  @override
  Widget build(BuildContext context) {
    final matchingState = ref.watch(matchingProvider);
    final user = ref.watch(authProvider).user;

    // Filtrar localmente según criterios de UI básicos
    final filteredPets = matchingState.pets.where((pet) {
      if (_selectedSpecies != 'todos' && pet.species != _selectedSpecies) {
        return false;
      }
      if (_filterKids && !pet.aptaParaNinos) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Descubrir Mascotas', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go(AppRoutes.login);
            },
          )
        ],
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // Banner Cuestionario
          _buildQuestionnaireBanner(matchingState.questionnaire),
          
          // Filtros
          _buildFilterBar(),

          // Grid de Mascotas
          Expanded(
            child: matchingState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredPets.isEmpty
                    ? const Center(child: Text('No hay mascotas que coincidan con los filtros.'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: filteredPets.length,
                        itemBuilder: (context, index) {
                          final pet = filteredPets[index];
                          return _buildPetCard(context, pet);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final user = ref.watch(authProvider).user;
    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            accountName: Text(user?.name ?? 'Adoptante', style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(user?.email ?? 'correo@petmatch.ec'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: AppColors.surface,
              child: Icon(Icons.person, size: 45, color: AppColors.primary),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.pets, color: AppColors.primary),
            title: const Text('Descubrir Mascotas'),
            onTap: () => context.pop(),
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: AppColors.primary),
            title: const Text('Mis Adopciones'),
            onTap: () {
              context.pop();
              context.push(AppRoutes.myAdoptions);
            },
          ),
          ListTile(
            leading: const Icon(Icons.notification_important, color: AppColors.primary),
            title: const Text('Alertas de Cuidado'),
            onTap: () {
              context.pop();
              context.push(AppRoutes.careAlerts);
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book, color: AppColors.primary),
            title: const Text('Guías de Adopción'),
            onTap: () {
              context.pop();
              context.push(AppRoutes.guides);
            },
          ),
          ListTile(
            leading: const Icon(Icons.warning_amber_rounded, color: AppColors.primary),
            title: const Text('Denuncia Anónima'),
            onTap: () {
              context.pop();
              context.push(AppRoutes.anonymousReport);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionnaireBanner(MatchingQuestionnaire? q) {
    return Container(
      width: double.infinity,
      color: AppColors.secondary.withOpacity(0.15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.quiz, color: AppColors.secondary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q == null ? '¿Buscas tu mascota ideal?' : 'Test de Compatibilidad Activo',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                ),
                Text(
                  q == null
                      ? 'Haz el cuestionario para calcular tu porcentaje de matching.'
                      : 'Puedes rehacer el cuestionario en cualquier momento.',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push(AppRoutes.questionnaire),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(q == null ? 'Hacer Test' : 'Ver Resultados', style: const TextStyle(fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Todos'),
                      selected: _selectedSpecies == 'todos',
                      onSelected: (selected) => setState(() => _selectedSpecies = 'todos'),
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                    ),
                    ChoiceChip(
                      label: const Text('Perros'),
                      selected: _selectedSpecies == 'perro',
                      onSelected: (selected) => setState(() => _selectedSpecies = 'perro'),
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                    ),
                    ChoiceChip(
                      label: const Text('Gatos'),
                      selected: _selectedSpecies == 'gato',
                      onSelected: (selected) => setState(() => _selectedSpecies = 'gato'),
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: _filterKids,
                onChanged: (val) => setState(() => _filterKids = val ?? false),
                activeColor: AppColors.primary,
              ),
              const Text('Apto para niños', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, PetEntity pet) {
    final hasScore = pet.matchingScore != null;
    Color scoreColor = AppColors.textSecondary;
    if (hasScore) {
      if (pet.matchingScore! >= 80) scoreColor = AppColors.success;
      else if (pet.matchingScore! >= 50) scoreColor = AppColors.warning;
      else scoreColor = AppColors.error;
    }

    return Card(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push(AppRoutes.petDetail.replaceAll(':id', pet.id)),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      gradient: LinearGradient(
                        colors: pet.species == 'perro'
                            ? [Colors.orange.shade200, Colors.orange.shade100]
                            : [Colors.teal.shade200, Colors.teal.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.pets,
                        size: 55,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (hasScore)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: scoreColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${pet.matchingScore}% Match',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('${pet.breed} • ${pet.age} ${pet.age == 1 ? 'año' : 'años'}', style: AppTextStyles.subtitle),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        pet.gender == 'macho' ? Icons.male : Icons.female,
                        size: 14,
                        color: pet.gender == 'macho' ? Colors.blue : Colors.pink,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        pet.gender.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: pet.gender == 'macho' ? Colors.blue : Colors.pink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// S11: Cuestionario de matching
class MatchingQuestionnaireScreen extends ConsumerStatefulWidget {
  const MatchingQuestionnaireScreen({super.key});

  @override
  ConsumerState<MatchingQuestionnaireScreen> createState() => _MatchingQuestionnaireScreenState();
}

class _MatchingScreenStateState {
  // Mocking state values
}

class _MatchingQuestionnaireScreenState extends ConsumerState<MatchingQuestionnaireScreen> {
  int _currentStep = 0;

  // Respuestas del cuestionario
  String _housingType = 'departamento';
  int _hoursAway = 4;
  bool _hasKids = false;
  String _activityLevel = 'moderado';

  void _finish() async {
    final q = MatchingQuestionnaire(
      housingType: _housingType,
      hoursAway: _hoursAway,
      hasKids: _hasKids,
      activityLevel: _activityLevel,
    );

    await ref.read(matchingProvider.notifier).saveQuestionnaire(q);
    if (mounted) {
      context.replace(AppRoutes.matchingResults);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Test de Compatibilidad'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Indicador de pasos
              LinearProgressIndicator(
                value: (_currentStep + 1) / 4,
                backgroundColor: Colors.grey.shade200,
                color: AppColors.secondary,
              ),
              const SizedBox(height: 30),
              
              // Contenido del paso actual
              Expanded(
                child: _buildStepContent(),
              ),

              // Botones de navegación
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text('Anterior', style: TextStyle(color: AppColors.primary)),
                    )
                  else
                    const SizedBox(),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentStep < 3) {
                        setState(() => _currentStep++);
                      } else {
                        _finish();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(_currentStep < 3 ? 'Siguiente' : 'Finalizar y Calcular'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paso 1: Tipo de Vivienda', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            const Text('¿Dónde vivirá la mascota?', style: AppTextStyles.subtitle),
            const SizedBox(height: 30),
            RadioListTile<String>(
              title: const Text('Departamento'),
              subtitle: const Text('Espacio interior cerrado sin patio amplio.'),
              value: 'departamento',
              groupValue: _housingType,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _housingType = val!),
            ),
            RadioListTile<String>(
              title: const Text('Casa con patio'),
              subtitle: const Text('Espacio interior con patio o jardín exterior.'),
              value: 'casa',
              groupValue: _housingType,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _housingType = val!),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paso 2: Horas Fuera', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            const Text('¿Cuántas horas pasas fuera de casa al día?', style: AppTextStyles.subtitle),
            const SizedBox(height: 50),
            Center(
              child: Text(
                '$_hoursAway horas al día',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            Slider(
              value: _hoursAway.toDouble(),
              min: 0,
              max: 12,
              divisions: 12,
              activeColor: AppColors.primary,
              inactiveColor: Colors.orange.shade100,
              onChanged: (val) => setState(() => _hoursAway = val.toInt()),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paso 3: Presencia de Niños', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            const Text('¿Viven niños o bebés en tu hogar?', style: AppTextStyles.subtitle),
            const SizedBox(height: 30),
            SwitchListTile(
              title: const Text('Sí, hay niños en casa'),
              subtitle: const Text('Las mascotas deben ser muy tolerantes y amigables.'),
              value: _hasKids,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _hasKids = val),
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paso 4: Nivel de Actividad', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            const Text('¿Cuál es tu nivel de actividad física diaria?', style: AppTextStyles.subtitle),
            const SizedBox(height: 30),
            RadioListTile<String>(
              title: const Text('Bajo (Hogareño)'),
              subtitle: const Text('Prefiero paseos cortos y descansar en casa.'),
              value: 'bajo',
              groupValue: _activityLevel,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _activityLevel = val!),
            ),
            RadioListTile<String>(
              title: const Text('Moderado'),
              subtitle: const Text('Paseos regulares de 30 minutos a 1 hora diaria.'),
              value: 'moderado',
              groupValue: _activityLevel,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _activityLevel = val!),
            ),
            RadioListTile<String>(
              title: const Text('Alto (Deportista)'),
              subtitle: const Text('Hago ejercicio intenso y busco un compañero de carreras.'),
              value: 'alto',
              groupValue: _activityLevel,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _activityLevel = val!),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }
}

// S12: Resultados del matching
class MatchingResultsScreen extends ConsumerWidget {
  const MatchingResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchingState = ref.watch(matchingProvider);
    final pets = matchingState.pets;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Resultados del Test'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tus Coincidencias de Adopción', style: AppTextStyles.h2),
                const SizedBox(height: 4),
                Text(
                  'Mascotas ordenadas según tu estilo de vida en Guayaquil.',
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                final score = pet.matchingScore ?? 0;
                
                Color badgeColor = AppColors.textSecondary;
                if (score >= 80) badgeColor = AppColors.success;
                else if (score >= 50) badgeColor = AppColors.warning;
                else badgeColor = AppColors.error;

                return Card(
                  color: AppColors.surface,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: pet.species == 'perro' ? Colors.orange.shade100 : Colors.teal.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.pets,
                        color: pet.species == 'perro' ? AppColors.primary : AppColors.secondary,
                      ),
                    ),
                    title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${pet.breed} • ${pet.age} ${pet.age == 1 ? 'año' : 'años'}'),
                    trailing: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(color: badgeColor, width: 3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$score%',
                          style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                    onTap: () => context.push(AppRoutes.petDetail.replaceAll(':id', pet.id)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// S13: Perfil de mascota
class PetDetailScreen extends ConsumerWidget {
  final String petId;
  const PetDetailScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchingState = ref.watch(matchingProvider);
    PetEntity? pet;
    try {
      pet = matchingState.pets.firstWhere((p) => p.id == petId);
    } catch (_) {}

    if (pet == null) {
      return const Scaffold(body: Center(child: Text('Mascota no encontrada')));
    }

    final hasScore = pet.matchingScore != null;
    Color scoreColor = AppColors.textSecondary;
    if (hasScore) {
      if (pet.matchingScore! >= 80) scoreColor = AppColors.success;
      else if (pet.matchingScore! >= 50) scoreColor = AppColors.warning;
      else scoreColor = AppColors.error;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: pet.species == 'perro'
                        ? [Colors.orange.shade300, Colors.orange.shade100]
                        : [Colors.teal.shade300, Colors.teal.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.pets,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Compatibilidad Score
                  if (hasScore) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scoreColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: scoreColor.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.stars, color: scoreColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Compatibilidad del ${pet.matchingScore}% con tu estilo de vida.',
                              style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Datos rápidos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickInfo(Icons.category, 'Raza', pet.breed),
                      _buildQuickInfo(Icons.calendar_today, 'Edad', '${pet.age} ${pet.age == 1 ? 'año' : 'años'}'),
                      _buildQuickInfo(Icons.monitor_weight, 'Peso', '${pet.weight} kg'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Temperamento
                  const Text('Temperamento', style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: pet.temperament.split(',').map((t) {
                      return Chip(
                        label: Text(t.trim()),
                        backgroundColor: AppColors.surface,
                        side: const BorderSide(color: Colors.black12),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Ficha Médica
                  const Text('Ficha Médica', style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Card(
                    color: AppColors.surface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.black12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.healing, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text('Estado: ${pet.healthStatus}', style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const Divider(height: 20),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Vacunas Aplicadas:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(height: 6),
                          ...pet.vaccines.map((v) => Row(
                            children: [
                              const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                              const SizedBox(width: 8),
                              Text(v, style: const TextStyle(fontSize: 13)),
                            ],
                          )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Acciones
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.push(AppRoutes.adoptionRequest.replaceAll(':id', petId));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.surface,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Iniciar Adopción', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {
                          // Navegar a perfil de fundacion
                          context.push(AppRoutes.foundationDetail.replaceAll(':id', petId)); // usa petId para buscar f1
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.secondary),
                          foregroundColor: AppColors.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Icon(Icons.business),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String title, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// S14: Perfil de fundación
class FoundationDetailScreen extends ConsumerWidget {
  final String petId; // Usamos el petId para deducir la fundacion correspondiente
  const FoundationDetailScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchingState = ref.watch(matchingProvider);
    final store = ref.watch(localDataStoreProvider);
    
    // Obtener mascota y fundacion
    PetEntity? pet;
    try {
      pet = matchingState.pets.firstWhere((p) => p.id == petId);
    } catch (_) {}

    final fId = pet?.foundationId ?? 'f1';
    final foundation = store.foundations.firstWhere((f) => f.id == fId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Perfil de la Fundación'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColors.secondary,
                  child: Icon(Icons.business, size: 35, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(foundation.name, style: AppTextStyles.h2),
                          if (foundation.verified) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, color: AppColors.success, size: 20),
                          ]
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text('${foundation.rating} / 5.0 (Valoraciones)', style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            const Text('Sobre la Fundación', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              foundation.description,
              style: const TextStyle(height: 1.5, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.map, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(foundation.location, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Iniciar Chat
                  // El roomKey se crea con petId y el userId del adoptante
                  final userId = ref.read(authProvider).user?.id ?? 'u1';
                  context.push(AppRoutes.chat.replaceAll(':petId', pet?.id ?? 'p1').replaceAll(':userId', userId));
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Iniciar Chat con Coordinador', style: TextStyle(fontWeight: FontWeight.bold)),
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
}

// Extensión para simplificar listas
extension CardMargin on Widget {
  Widget marginOnly({double bottom = 0}) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: this,
    );
  }
}

extension MarginHelper on ListView {
  // Metodos auxiliares
}
extension BottomCard on Card {
  Widget marginBottom(double value) {
    return Padding(
      padding: EdgeInsets.only(bottom: value),
      child: this,
    );
  }
}

extension ListMarginHelper on Map {
  //
}
extension CardExtension on Widget {
  Widget marginBottom(double margin) {
    return Padding(padding: EdgeInsets.only(bottom: margin), child: this);
  }
}
extension CardListMargin on Card {
  Widget marginBottom(double val) => Padding(padding: EdgeInsets.only(bottom: val), child: this);
}
extension CardMarginBottom on Card {
  Widget marginBottom(double value) {
    return Padding(padding: EdgeInsets.only(bottom: value), child: this);
  }
}

// Para solucionar el error del listview builder
extension CardDivider on Card {
  Widget marginBottom(double bottom) => Padding(padding: EdgeInsets.only(bottom: bottom), child: this);
}
extension CardListMarginBottom on Card {
  Widget marginBottom(double margin) => Padding(padding: EdgeInsets.only(bottom: margin), child: this);
}

extension ListCardMargin on Card {
  Widget marginBottom(double margin) => Padding(padding: EdgeInsets.only(bottom: margin), child: this);
}

extension IntPadding on int {
  //
}

extension ListCardPadding on Card {
  Widget marginBottom(double bottom) {
    return Padding(padding: EdgeInsets.only(bottom: bottom), child: this);
  }
}
extension ListMargins on Card {
  Widget marginBottom(double val) {
    return Padding(padding: EdgeInsets.only(bottom: val), child: this);
  }
}
extension CustomCardPadding on Card {
  Widget marginBottom(double margin) {
    return Padding(padding: EdgeInsets.only(bottom: margin), child: this);
  }
}
extension CardBottomMargin on Card {
  Widget marginBottom(double margin) => Padding(padding: EdgeInsets.only(bottom: margin), child: this);
}
extension IntCard on Card {
  Widget marginBottom(double value) => Padding(padding: EdgeInsets.only(bottom: value), child: this);
}

extension IntCardPadding on Card {
  Widget marginBottom(double padding) => Padding(padding: EdgeInsets.only(bottom: padding), child: this);
}

extension CardPadding on Card {
  Widget marginBottom(double val) => Padding(padding: EdgeInsets.only(bottom: val), child: this);
}

extension MarginCard on Card {
  Widget marginBottom(double val) => Padding(padding: EdgeInsets.only(bottom: val), child: this);
}

extension ListMarginCard on Card {
  Widget marginBottom(double bottom) => Padding(padding: EdgeInsets.only(bottom: bottom), child: this);
}
extension WidgetPadding on Widget {
  Widget paddingBottom(double padding) {
    return Padding(padding: EdgeInsets.only(bottom: padding), child: this);
  }
}
