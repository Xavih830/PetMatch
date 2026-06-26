import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/data/local_data_store.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../matching/domain/entities/pet_entity.dart';
import '../../../matching/matching_business.dart';
import '../../../adoption/adoption_business.dart';
import '../../../adoption/domain/entities/adoption_request_entity.dart';
import '../../../volunteer/volunteer_business.dart';
import '../../../volunteer/domain/entities/campaign_entity.dart';

// S30: Dashboard de fundación
class FoundationDashboardScreen extends ConsumerWidget {
  const FoundationDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(localDataStoreProvider);
    final user = ref.watch(authProvider).user;

    // Métricas locales
    final myPets = store.pets.where((p) => p.foundationId == 'f1').toList();
    final pendingReqs = store.adoptionRequests.where((r) => r.status == 'pendiente').toList();
    final activeCamps = store.campaigns.where((c) => c.foundationId == 'f1').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Panel de Coordinación', style: TextStyle(fontWeight: FontWeight.bold)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenido, ${user?.name}', style: AppTextStyles.h1),
            const SizedBox(height: 6),
            Text('Refugio: Huellitas de Amor', style: AppTextStyles.subtitle),
            const SizedBox(height: 30),

            // Cuadrícula de Métricas
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.3,
              children: [
                _buildMetricCard(context, 'Mascotas', '${myPets.length}', Icons.pets, AppColors.primary, AppRoutes.petManagement),
                _buildMetricCard(context, 'Pendientes', '${pendingReqs.length}', Icons.pending_actions, AppColors.warning, AppRoutes.receivedRequests),
                _buildMetricCard(context, 'Campañas', '${activeCamps.length}', Icons.event, AppColors.secondary, AppRoutes.campaignManagement),
                _buildMetricCard(context, 'Analíticas', 'Donaciones', Icons.bar_chart, Colors.teal, AppRoutes.analytics),
              ],
            ),
            const SizedBox(height: 30),
            
            // Acciones Rápidas
            const Text('Acciones Rápidas', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Card(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.add_circle, color: AppColors.primary),
                title: const Text('Registrar nuevo animal rescatado'),
                subtitle: const Text('Agrega fotos, raza, edad e historial médico'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.petManagement),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.add_alert, color: AppColors.secondary),
                title: const Text('Programar nueva campaña de voluntariado'),
                subtitle: const Text('Define cupo máximo y habilidades deseadas'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.campaignManagement),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color color, String route) {
    return Card(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 28),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(title, style: AppTextStyles.subtitle),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// S31: Gestión de animales (lista + agregar)
class PetManagementScreen extends ConsumerStatefulWidget {
  const PetManagementScreen({super.key});

  @override
  ConsumerState<PetManagementScreen> createState() => _PetManagementScreenState();
}

class _PetManagementScreenState extends ConsumerState<PetManagementScreen> {
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _temperamentController = TextEditingController();
  final _healthController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedSpecies = 'perro';
  String _selectedGender = 'macho';
  bool _aptaParaNinos = true;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _temperamentController.dispose();
    _healthController.dispose();
    super.dispose();
  }

  void _addPet() async {
    if (_formKey.currentState?.validate() ?? false) {
      final newPet = PetEntity(
        id: 'p_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        species: _selectedSpecies,
        breed: _breedController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        gender: _selectedGender,
        weight: double.parse(_weightController.text.trim()),
        temperament: _temperamentController.text.trim(),
        healthStatus: _healthController.text.trim(),
        vaccines: const ['Desparasitación'],
        images: const [],
        aptaParaNinos: _aptaParaNinos,
        foundationId: 'f1',
      );

      // Guardar en repositorio
      await ref.read(petRepositoryProvider).addPet(newPet);
      ref.read(matchingProvider.notifier).loadMascotas(); // Recargar test matching

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mascota registrada con éxito'), backgroundColor: AppColors.success),
        );
        // Reset form
        _nameController.clear();
        _breedController.clear();
        _ageController.clear();
        _weightController.clear();
        _temperamentController.clear();
        _healthController.clear();
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(localDataStoreProvider);
    final myPets = store.pets.where((p) => p.foundationId == 'f1').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Gestión de Mascotas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Listado de mascotas actuales
            const Text('Mascotas Registradas', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Container(
              height: 150,
              child: myPets.isEmpty
                  ? const Center(child: Text('No hay mascotas registradas.'))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: myPets.length,
                      itemBuilder: (context, index) {
                        final pet = myPets[index];
                        return Card(
                          color: AppColors.surface,
                          margin: const EdgeInsets.only(right: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: InkWell(
                            onTap: () => _showPetDetailSheet(context, pet),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 140,
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: pet.species == 'perro' ? Colors.orange.shade100 : Colors.teal.shade100,
                                    child: Icon(
                                      Icons.pets,
                                      color: pet.species == 'perro' ? AppColors.primary : AppColors.secondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(pet.breed, style: AppTextStyles.subtitle, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 30),

            // Formulario Agregar Mascota
            const Text('Registrar Nuevo Animal', style: AppTextStyles.h2),
            const SizedBox(height: 15),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedSpecies,
                          decoration: const InputDecoration(labelText: 'Especie', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'perro', child: Text('Perro')),
                            DropdownMenuItem(value: 'gato', child: Text('Gato')),
                          ],
                          onChanged: (val) => setState(() => _selectedSpecies = val!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: const InputDecoration(labelText: 'Género', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'macho', child: Text('Macho')),
                            DropdownMenuItem(value: 'hembra', child: Text('Hembra')),
                          ],
                          onChanged: (val) => setState(() => _selectedGender = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _breedController,
                    decoration: const InputDecoration(labelText: 'Raza / Cruce', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ageController,
                          decoration: const InputDecoration(labelText: 'Edad (Años)', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          decoration: const InputDecoration(labelText: 'Peso (kg)', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _temperamentController,
                    decoration: const InputDecoration(labelText: 'Temperamento (Separar por comas)', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _healthController,
                    decoration: const InputDecoration(labelText: 'Estado de Salud / Ficha Médica', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Apta para convivir con niños'),
                    value: _aptaParaNinos,
                    onChanged: (val) => setState(() => _aptaParaNinos = val),
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addPet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Registrar Mascota', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showPetDetailSheet(BuildContext context, PetEntity pet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
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
                      Text(
                        'Ficha de Animal',
                        style: AppTextStyles.h2.copyWith(fontSize: 22),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: pet.species == 'perro' ? Colors.orange.shade100 : Colors.teal.shade100,
                      child: Icon(
                        Icons.pets,
                        size: 50,
                        color: pet.species == 'perro' ? AppColors.primary : AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      pet.name,
                      style: AppTextStyles.h1.copyWith(fontSize: 22, color: AppColors.textPrimary),
                    ),
                  ),
                  Center(
                    child: Text(
                      '${pet.breed} • ${pet.gender == 'macho' ? 'Macho' : 'Hembra'}',
                      style: AppTextStyles.subtitle,
                    ),
                  ),
                  const Divider(height: 32),
                  const Text('Detalles Generales', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickInfo(Icons.calendar_today, 'Edad', '${pet.age} años'),
                      _buildQuickInfo(Icons.monitor_weight, 'Peso', '${pet.weight} kg'),
                      _buildQuickInfo(Icons.child_care, 'Niños', pet.aptaParaNinos ? 'Apta' : 'No apta'),
                    ],
                  ),
                  const SizedBox(height: 24),
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
                  const Divider(height: 32),
                  // HISTORIAL MÉDICO
                  Row(
                    children: [
                      const Icon(Icons.healing, color: AppColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Historial Médico',
                        style: AppTextStyles.h2.copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estado de salud general: ${pet.healthStatus}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const Divider(height: 20),
                          const Text(
                            'Registro de Vacunas y Desparasitaciones:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          ...pet.vaccines.map((v) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                                const SizedBox(width: 8),
                                Text(v, style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          )),
                          const Divider(height: 20),
                          const Text(
                            'Consultas Veterinarias Recientes:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          _buildMedicalEvent('20/05/2026', 'Chequeo General', 'Paciente sano, peso ideal, pelaje brillante.'),
                          _buildMedicalEvent('15/04/2026', 'Vacunación Anual', 'Refuerzo de quíntuple y antirrábica aplicado sin efectos adversos.'),
                          _buildMedicalEvent('10/03/2026', 'Desparasitación', 'Tratamiento oral completado.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickInfo(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMedicalEvent(String date, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text(description, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// S32: Solicitudes recibidas
class ReceivedRequestsScreen extends ConsumerWidget {
  const ReceivedRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adoptionsState = ref.watch(adoptionProvider);
    // Solicitudes recibidas por la fundacion f1 (dueña de p1)
    final reqs = adoptionsState.requests.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Solicitudes Recibidas'),
      ),
      body: adoptionsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : reqs.isEmpty
              ? const Center(child: Text('No hay solicitudes pendientes.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reqs.length,
                  itemBuilder: (context, index) {
                    final req = reqs[index];
                    return _buildRequestCard(context, ref, req);
                  },
                ),
    );
  }

  Widget _buildRequestCard(BuildContext context, WidgetRef ref, AdoptionRequestEntity req) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mascota: ${req.petName}', style: AppTextStyles.h3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text(req.status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Adoptante: ${req.applicantName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(req.applicantProfileSummary, style: AppTextStyles.subtitle),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Chat con adoptante
                    context.push(AppRoutes.chat.replaceAll(':petId', req.petId).replaceAll(':userId', req.applicantId));
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(color: AppColors.secondary),
                  ),
                ),
                if (req.status == 'pendiente')
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          ref.read(adoptionProvider.notifier).updateStatus(req.id, 'aprobada');
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                        child: const Text('Aceptar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(adoptionProvider.notifier).updateStatus(req.id, 'rechazada');
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                        child: const Text('Rechazar'),
                      ),
                    ],
                  )
              ],
            )
          ],
        ),
      ),
    );
  }
}

// S33: Analíticas con fl_chart
class FoundationAnalyticsScreen extends StatelessWidget {
  const FoundationAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Analíticas de la Fundación'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Donaciones del Primer Semestre', style: AppTextStyles.h2),
            const SizedBox(height: 4),
            const Text('Recaudaciones mensuales en dólares USD', style: AppTextStyles.subtitle),
            const SizedBox(height: 30),
            
            // Gráfica de Barras con fl_chart
            Container(
              height: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        interval: 100,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '\$${value.toInt()}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          const months = {
                            1: 'Ene',
                            2: 'Feb',
                            3: 'Mar',
                            4: 'Abr',
                            5: 'May',
                            6: 'Jun',
                          };
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              months[value.toInt()] ?? '',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: [
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 150, color: AppColors.primary, width: 14)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 280, color: AppColors.secondary, width: 14)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 340, color: AppColors.primary, width: 14)]),
                    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 220, color: AppColors.secondary, width: 14)]),
                    BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 450, color: AppColors.primary, width: 14)]),
                    BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 380, color: AppColors.secondary, width: 14)]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 35),

            // Sectores de abandono
            const Text('Zonas con Mayor Índice de Abandono', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            Card(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _AbandonZoneRow('Guasmo (Sur GYE)', 'Índice: Crítico', Colors.red),
                    Divider(),
                    _AbandonZoneRow('Samanes (Norte GYE)', 'Índice: Alto', Colors.orange),
                    Divider(),
                    _AbandonZoneRow('Suburbio (Oeste GYE)', 'Índice: Alto', Colors.orange),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _AbandonZoneRow extends StatelessWidget {
  final String title;
  final String desc;
  final Color color;
  const _AbandonZoneRow(this.title, this.desc, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(desc, style: const TextStyle(fontSize: 12)),
          ],
        )
      ],
    );
  }
}

// S34: Gestión de campañas (lista + creación)
class CampaignManagementScreen extends ConsumerStatefulWidget {
  const CampaignManagementScreen({super.key});

  @override
  ConsumerState<CampaignManagementScreen> createState() => _CampaignManagementScreenState();
}

class _CampaignManagementScreenState extends ConsumerState<CampaignManagementScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedType = 'baño'; // 'alimentación', 'baño', 'paseo', 'adopción'

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _addCampaign() {
    if (_formKey.currentState?.validate() ?? false) {
      final store = ref.read(localDataStoreProvider);
      final newCamp = CampaignEntity(
        id: 'c_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        type: _selectedType,
        date: DateTime.now().add(const Duration(days: 3)),
        location: _locationController.text.trim(),
        capacity: int.parse(_capacityController.text.trim()),
        enrolledVolunteersCount: 0,
        skillsRequired: const ['Paciencia', 'Amor por los animales'],
        foundationId: 'f1',
      );

      store.campaigns.add(newCamp);
      // Forzar recarga de voluntariado
      ref.read(volunteerProvider('u3').notifier).loadVolunteerData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Campaña creada con éxito'), backgroundColor: AppColors.success),
      );

      _titleController.clear();
      _descController.clear();
      _locationController.clear();
      _capacityController.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(localDataStoreProvider);
    final myCamps = store.campaigns.where((c) => c.foundationId == 'f1').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Gestión de Campañas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Campañas Publicadas', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            ...myCamps.map((camp) => Card(
              color: AppColors.surface,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                title: Text(camp.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${camp.location} • Cupo: ${camp.enrolledVolunteersCount} / ${camp.capacity}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, color: AppColors.secondary),
                      tooltip: 'Vista Previa',
                      onPressed: () => _showCampaignPreviewSheet(context, camp),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => context.push(AppRoutes.campaignVolunteers.replaceAll(':id', camp.id)),
              ),
            )),
            const SizedBox(height: 30),

            const Text('Crear Nueva Campaña', style: AppTextStyles.h2),
            const SizedBox(height: 15),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Título de la Campaña', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(labelText: 'Tipo de Actividad', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'baño', child: Text('Baño')),
                      DropdownMenuItem(value: 'paseo', child: Text('Paseo')),
                      DropdownMenuItem(value: 'alimentación', child: Text('Alimentación')),
                      DropdownMenuItem(value: 'adopción', child: Text('Feria de Adopción')),
                    ],
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Ubicación / Lugar', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _capacityController,
                    decoration: const InputDecoration(labelText: 'Capacidad de Voluntarios (Cupo)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Descripción de Actividades', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              final dummyCamp = CampaignEntity(
                                id: 'dummy',
                                title: _titleController.text.trim(),
                                description: _descController.text.trim(),
                                type: _selectedType,
                                date: DateTime.now().add(const Duration(days: 3)),
                                location: _locationController.text.trim(),
                                capacity: int.parse(_capacityController.text.trim()),
                                enrolledVolunteersCount: 0,
                                skillsRequired: const ['Paciencia', 'Amor por los animales'],
                                foundationId: 'f1',
                              );
                              _showCampaignPreviewSheet(context, dummyCamp);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.secondary),
                            foregroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Vista Previa', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _addCampaign,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.surface,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Publicar', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCampaignPreviewSheet(BuildContext context, CampaignEntity camp) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
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
                      const Text(
                        'Vista Previa Publicada (Móvil)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.secondary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: Text(camp.type.toUpperCase(), style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                  const SizedBox(height: 8),
                  Text(camp.title, style: AppTextStyles.h1.copyWith(fontSize: 24)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.textSecondary, size: 18),
                      const SizedBox(width: 6),
                      Text(camp.location, style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.date_range, color: AppColors.textSecondary, size: 18),
                      const SizedBox(width: 6),
                      Text('${camp.date.day}/${camp.date.month}/${camp.date.year}', style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people_outline, color: AppColors.textSecondary, size: 18),
                      const SizedBox(width: 6),
                      Text('Cupos: ${camp.enrolledVolunteersCount} / ${camp.capacity} inscritos', style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                  const Divider(height: 30),
                  const Text('Descripción de la Actividad', style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Text(camp.description, style: const TextStyle(height: 1.5, color: AppColors.textPrimary)),
                  const SizedBox(height: 24),
                  const Text('Habilidades Requeridas', style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: camp.skillsRequired.map((skill) {
                      return Chip(
                        label: Text(skill),
                        backgroundColor: AppColors.surface,
                        side: const BorderSide(color: Colors.black12),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Inscribirse en Campaña (Vista Voluntario)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// S35: Voluntarios inscritos
class CampaignVolunteersScreen extends ConsumerWidget {
  final String campaignId;
  const CampaignVolunteersScreen({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(localDataStoreProvider);
    CampaignEntity? camp;
    try {
      camp = store.campaigns.firstWhere((c) => c.id == campaignId);
    } catch (_) {}

    // Simular voluntarios inscritos en esta campaña (Sebastián Vera si está inscrito)
    // Para simplificar, si hay registrados, mostrar a Sebastián y otro voluntario de prueba
    final mockVolunteers = [
      {
        'name': 'Sebastián Vera',
        'skills': 'Paseo de perros, Atención básica',
        'availability': 'Sábados por la mañana',
        'hours': '12 horas apoyadas'
      },
      {
        'name': 'Anggie Nicole Sandoval',
        'skills': 'Redes sociales, Logística',
        'availability': 'Fines de semana',
        'hours': '8 horas apoyadas'
      }
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Voluntarios Inscritos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(camp?.title ?? 'Campaña', style: AppTextStyles.h2),
            const SizedBox(height: 4),
            Text('Lugar: ${camp?.location ?? ""}', style: AppTextStyles.subtitle),
            const SizedBox(height: 24),
            const Text('Lista de Roster:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: mockVolunteers.length,
                itemBuilder: (context, index) {
                  final vol = mockVolunteers[index];
                  return Card(
                    color: AppColors.surface,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(vol['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Habilidades: ${vol['skills']!}\nDisponibilidad: ${vol['availability']!}'),
                      isThreeLine: true,
                      trailing: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                        child: Text(vol['hours']!, style: const TextStyle(color: AppColors.secondary, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
