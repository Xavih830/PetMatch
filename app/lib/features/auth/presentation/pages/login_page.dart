import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)),
    );

    _controller.forward();

    // Redirección tras 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _redirect();
      }
    });
  }

  void _redirect() {
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated && authState.user != null) {
      final role = authState.user!.role;
      if (role == 'adoptante') {
        context.go(AppRoutes.adoptanteHome);
      } else if (role == 'coordinador') {
        context.go(AppRoutes.coordinadorHome);
      } else if (role == 'voluntario') {
        context.go(AppRoutes.voluntarioHome);
      } else if (role == 'admin') {
        context.go(AppRoutes.adminHome);
      }
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Isotipo animado: Pata con corazón en el centro
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.pets,
                        size: 70,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 25),
            // Logotipo: Nombre "PetMatch" con fundido
            FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pet',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.surface,
                      fontSize: 36,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'Match',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.secondary,
                      fontSize: 36,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Adopción Responsable Inteligente',
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.surface.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final success = await ref.read(authProvider.notifier).login(email, password);
      if (success && mounted) {
        final authState = ref.read(authProvider);
        if (authState.user != null) {
          final role = authState.user!.role;
          if (role == 'adoptante') {
            context.go(AppRoutes.adoptanteHome);
          } else if (role == 'coordinador') {
            context.go(AppRoutes.coordinadorHome);
          } else if (role == 'voluntario') {
            context.go(AppRoutes.voluntarioHome);
          } else if (role == 'admin') {
            context.go(AppRoutes.adminHome);
          }
        }
      } else if (mounted) {
        final error = ref.read(authProvider).errorMessage ?? 'Error de autenticación';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Permite al usuario hacer clic rápido para demostración
  void _quickFill(String email, String pass) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = pass;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.pets_rounded,
                    size: 60,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Pet', style: AppTextStyles.h1.copyWith(fontSize: 32)),
                      Text('Match', style: AppTextStyles.h1.copyWith(fontSize: 32, color: AppColors.secondary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ingresa para conectar con tu compañero ideal',
                    style: AppTextStyles.subtitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 35),
                  
                  // Campo Email
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Correo Electrónico',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu correo';
                      }
                      if (!value.contains('@')) {
                        return 'Ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Campo Password
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu contraseña';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Botón Login
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                    ),
                    child: authState.isLoading
                        ? const CircularProgressIndicator(color: AppColors.surface)
                        : Text('Iniciar Sesión', style: AppTextStyles.button.copyWith(fontSize: 16)),
                  ),
                  const SizedBox(height: 30),
                  
                  // Cuentas Rápidas de Prueba (Demo credentials)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cuentas Demo (Toca para rellenar):',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ActionChip(
                              label: const Text('Valentina (Adoptante)'),
                              onPressed: () => _quickFill('valentina@petmatch.ec', 'petmatch123'),
                              backgroundColor: AppColors.background,
                            ),
                            ActionChip(
                              label: const Text('Roberto (Fundación)'),
                              onPressed: () => _quickFill('roberto@huellitas.ec', 'petmatch123'),
                              backgroundColor: AppColors.background,
                            ),
                            ActionChip(
                              label: const Text('Sebastián (Voluntario)'),
                              onPressed: () => _quickFill('sebastian@petmatch.ec', 'petmatch123'),
                              backgroundColor: AppColors.background,
                            ),
                            ActionChip(
                              label: const Text('Admin (Administrador)'),
                              onPressed: () => _quickFill('admin@petmatch.ec', 'admin2026'),
                              backgroundColor: AppColors.background,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿No tienes cuenta? ', style: TextStyle(color: AppColors.textSecondary)),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.register),
                        child: const Text(
                          'Regístrate aquí',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
