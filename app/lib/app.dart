import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'core/constants/app_text_styles.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/matching/presentation/pages/adoptante_pages.dart';
import 'features/adoption/presentation/pages/adoption_pages.dart';
import 'features/reports/presentation/pages/reports_pages.dart';
import 'features/foundation/presentation/pages/foundation_pages.dart';
import 'features/volunteer/presentation/pages/volunteer_pages.dart';
import 'features/admin/presentation/pages/admin_pages.dart';

final _routerProvider = Provider<GoRouter>((ref) {
  // Escuchar cambios de autenticación
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;
      final isSplashing = state.matchedLocation == AppRoutes.splash;
      final isRegistering = state.matchedLocation == AppRoutes.register;

      // Si no ha iniciado sesión y no está en login/splash/register, forzar login
      if (!isLoggedIn) {
        if (!isLoggingIn && !isSplashing && !isRegistering) return AppRoutes.login;
        return null;
      }

      // Si ya inició sesión y está en login o splash, redireccionar a su home por rol
      if (isLoggingIn || isSplashing) {
        final role = authState.user?.role;
        if (role == 'adoptante') return AppRoutes.adoptanteHome;
        if (role == 'coordinador') return AppRoutes.coordinadorHome;
        if (role == 'voluntario') return AppRoutes.voluntarioHome;
        if (role == 'admin') return AppRoutes.adminHome;
      }

      // Evitar que accedan a rutas de otros roles (Autorización)
      final currentLoc = state.matchedLocation;
      final role = authState.user?.role;
      if (role == 'adoptante' && (currentLoc.startsWith('/coordinador') || currentLoc.startsWith('/admin'))) {
        return AppRoutes.adoptanteHome;
      }
      if (role == 'coordinador' && (currentLoc.startsWith('/adoptante') || currentLoc.startsWith('/voluntario') || currentLoc.startsWith('/admin'))) {
        return AppRoutes.coordinadorHome;
      }
      if (role == 'voluntario' && (currentLoc.startsWith('/adoptante') || currentLoc.startsWith('/coordinador') || currentLoc.startsWith('/admin'))) {
        return AppRoutes.voluntarioHome;
      }
      if (role == 'admin' && (currentLoc.startsWith('/adoptante') || currentLoc.startsWith('/coordinador') || currentLoc.startsWith('/voluntario'))) {
        return AppRoutes.adminHome;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Adoptante
      GoRoute(
        path: AppRoutes.adoptanteHome,
        builder: (context, state) => const DiscoverPetsScreen(),
      ),
      GoRoute(
        path: AppRoutes.questionnaire,
        builder: (context, state) => const MatchingQuestionnaireScreen(),
      ),
      GoRoute(
        path: AppRoutes.matchingResults,
        builder: (context, state) => const MatchingResultsScreen(),
      ),
      GoRoute(
        path: AppRoutes.petDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PetDetailScreen(petId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.foundationDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return FoundationDetailScreen(petId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.adoptionRequest,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AdoptionRequestScreen(petId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) {
          final petId = state.pathParameters['petId'] ?? '';
          final userId = state.pathParameters['userId'] ?? '';
          return InternalChatScreen(petId: petId, userId: userId);
        },
      ),
      GoRoute(
        path: AppRoutes.myAdoptions,
        builder: (context, state) => const MyAdoptionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.careAlerts,
        builder: (context, state) => const CareAlertsScreen(),
      ),
      GoRoute(
        path: AppRoutes.guides,
        builder: (context, state) => const GuidesScreen(),
      ),
      GoRoute(
        path: AppRoutes.anonymousReport,
        builder: (context, state) => const AnonymousReportScreen(),
      ),

      // Coordinador
      GoRoute(
        path: AppRoutes.coordinadorHome,
        builder: (context, state) => const FoundationDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.petManagement,
        builder: (context, state) => const PetManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.receivedRequests,
        builder: (context, state) => const ReceivedRequestsScreen(),
      ),
      GoRoute(
        path: AppRoutes.analytics,
        builder: (context, state) => const FoundationAnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.campaignManagement,
        builder: (context, state) => const CampaignManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.campaignVolunteers,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CampaignVolunteersScreen(campaignId: id);
        },
      ),

      // Voluntario
      GoRoute(
        path: AppRoutes.voluntarioHome,
        builder: (context, state) => const ExploreCampaignsScreen(),
      ),
      GoRoute(
        path: AppRoutes.campaignDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CampaignDetailScreen(campaignId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.volunteerProfile,
        builder: (context, state) => const VolunteerProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.volunteerHistory,
        builder: (context, state) => const VolunteerHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.volunteerCertificate,
        builder: (context, state) => const VolunteerCertificateScreen(),
      ),

      // Admin
      GoRoute(
        path: AppRoutes.adminHome,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyFoundations,
        builder: (context, state) => const VerifyFoundationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.systemConfig,
        builder: (context, state) => const SystemConfigScreen(),
      ),
    ],
  );
});

class PetMatchApp extends ConsumerWidget {
  const PetMatchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);

    return MaterialApp.router(
      title: 'PetMatch',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: AppTextStyles.fontFamily,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          background: AppColors.background,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
