import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/data/local_data_store.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../reports/reports_business.dart';
import '../../admin_business.dart';

// S50: Dashboard admin
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(localDataStoreProvider);
    final reportsState = ref.watch(reportsProvider);

    final pendingF = store.foundations.where((f) => !f.verified).toList();
    final reports = reportsState.reports;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Panel de Administración', style: TextStyle(fontWeight: FontWeight.bold)),
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
            const Text('Panel de Control Global', style: AppTextStyles.h1),
            const SizedBox(height: 6),
            const Text('Supervisión de fundaciones, reportes comunitarios y tasas.', style: AppTextStyles.subtitle),
            const SizedBox(height: 30),

            // Tarjetas de estado
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    'Verificaciones',
                    '${pendingF.length} pendientes',
                    Icons.verified_user_outlined,
                    AppColors.secondary,
                    AppRoutes.verifyFoundations,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    'Ajustes del Sistema',
                    'Tasas y Correos',
                    Icons.settings_suggest,
                    AppColors.primary,
                    AppRoutes.systemConfig,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Denuncias recibidas
            const Text('Denuncias de Maltrato o Abandono Recibidas', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            reports.isEmpty
                ? const Text('No hay denuncias registradas en el sistema.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      Color typeColor = Colors.orange;
                      if (report.type == 'maltrato') typeColor = Colors.red;
                      else if (report.type == 'accidente') typeColor = Colors.amber;

                      return Card(
                        color: AppColors.surface,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: Icon(Icons.warning, color: typeColor),
                          title: Text('Caso: ${report.type.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Sector: ${report.area}\nDetalle: ${report.description}\nFecha: ${report.date.day}/${report.date.month}/${report.date.year}'),
                          isThreeLine: true,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                            child: Text(report.status.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String val, IconData icon, Color color, String route) {
    return Card(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 2),
              Text(val, style: AppTextStyles.subtitle),
            ],
          ),
        ),
      ),
    );
  }
}

// S51: Verificación de fundaciones
class VerifyFoundationsScreen extends ConsumerWidget {
  const VerifyFoundationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(localDataStoreProvider);
    final adminState = ref.watch(adminProvider);
    
    // Obtener fundaciones no verificadas
    final pendingF = store.foundations.where((f) => !f.verified).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Verificación de Fundaciones'),
      ),
      body: adminState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : pendingF.isEmpty
              ? const Center(child: Text('No hay fundaciones esperando verificación.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pendingF.length,
                  itemBuilder: (context, index) {
                    final f = pendingF[index];
                    return Card(
                      color: AppColors.surface,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(f.name, style: AppTextStyles.h3),
                            const SizedBox(height: 4),
                            Text('Sector: ${f.location}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 8),
                            Text(f.description, style: const TextStyle(fontSize: 13, height: 1.4)),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    await ref.read(adminProvider.notifier).verifyFoundation(f.id, true);
                                    // Forzar redibujado local en la sesión activa
                                    ref.invalidate(localDataStoreProvider);
                                    
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Fundación Aprobada y Verificada'), backgroundColor: AppColors.success),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                                  child: const Text('Aprobar e Insertar Insignia'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () {
                                    // Rechazar
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Registro rechazado'), backgroundColor: AppColors.error),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                                  child: const Text('Rechazar'),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// S52: Configuración del sistema
class SystemConfigScreen extends ConsumerStatefulWidget {
  const SystemConfigScreen({super.key});

  @override
  ConsumerState<SystemConfigScreen> createState() => _SystemConfigScreenState();
}

class _SystemConfigScreenState extends ConsumerState<SystemConfigScreen> {
  final _emailController = TextEditingController();
  final _commissionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(adminProvider).settings;
      setState(() {
        _emailController.text = settings.senderEmail;
        _commissionController.text = settings.commissionRate.toString();
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _commissionController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final rate = double.parse(_commissionController.text.trim());

      await ref.read(adminProvider.notifier).updateSettings(rate, email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuración guardada en SharedPreferences'), backgroundColor: AppColors.success),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Configuración del Sistema'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Parámetros de Configuración', style: AppTextStyles.h2),
              const SizedBox(height: 6),
              const Text('Estos valores se persisten localmente en SharedPreferences.', style: AppTextStyles.subtitle),
              const SizedBox(height: 30),

              // Correo Remitente
              const Text('Correo Institucional Remitente', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.mail),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 24),

              // Porcentaje de Comisión
              const Text('Comisión sobre Donaciones (%)', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              TextFormField(
                controller: _commissionController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.percent),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 40),

              // Botón Guardar
              ElevatedButton(
                onPressed: adminState.isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: adminState.isLoading
                    ? const CircularProgressIndicator(color: AppColors.surface)
                    : const Text('Guardar Ajustes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
