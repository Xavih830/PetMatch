import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../reports_business.dart';

// S20: Denuncia anónima
class AnonymousReportScreen extends ConsumerStatefulWidget {
  const AnonymousReportScreen({super.key});

  @override
  ConsumerState<AnonymousReportScreen> createState() => _AnonymousReportScreenState();
}

class _AnonymousReportScreenState extends ConsumerState<AnonymousReportScreen> {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedType = 'abandono'; // 'maltrato', 'abandono', 'accidente'
  String _selectedArea = 'Alborada'; // Zonas de Gye

  final List<String> _incidentTypes = ['abandono', 'maltrato', 'accidente'];
  final List<String> _gyeAreas = [
    'Alborada',
    'Samanes',
    'Urdesa',
    'Ceibos',
    'Guasmo',
    'Sauces',
    'Centro GYE',
    'Vía a la Costa'
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(reportsProvider.notifier).createReport(
        type: _selectedType,
        description: _descriptionController.text.trim(),
        area: _selectedArea,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Denuncia anónima registrada con éxito. Agradecemos tu apoyo comunitario.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(AppRoutes.adoptanteHome);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportsState = ref.watch(reportsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Denuncia Anónima'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.security, size: 50, color: AppColors.primary),
              const SizedBox(height: 12),
              const Text(
                'Reporta Maltrato o Abandono',
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu identidad estará completamente protegida. La información se enviará al administrador del sistema y a las fundaciones autorizadas de la zona.',
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Tipo de incidente
              const Text('Tipo de Incidente', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                items: _incidentTypes.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 20),

              // Zona Geográfica
              const Text('Sector de Guayaquil', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedArea,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                items: _gyeAreas.map((a) {
                  return DropdownMenuItem(
                    value: a,
                    child: Text(a),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedArea = val!),
              ),
              const SizedBox(height: 20),

              // Descripción
              const Text('Descripción de los Hechos', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Por favor, detalla la situación...',
                  hintText: 'Ej: perrito en abandono amarrado en terraza de casa de color verde...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 15) {
                    return 'Describe los hechos en detalle (mínimo 15 caracteres)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 35),

              // Botón Enviar
              ElevatedButton(
                onPressed: reportsState.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: reportsState.isLoading
                    ? const CircularProgressIndicator(color: AppColors.surface)
                    : const Text('Enviar Reporte Seguro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
