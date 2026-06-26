import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/data/local_data_store.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../../volunteer/domain/entities/volunteer_record_entity.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final store = ref.watch(localDataStoreProvider);
  return AuthRepositoryImpl(store);
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final sessionService = ref.watch(sessionServiceProvider);
  return LoginUseCase(repository, sessionService);
});

final checkSessionUseCaseProvider = Provider<CheckSessionUseCase>((ref) {
  final sessionService = ref.watch(sessionServiceProvider);
  return CheckSessionUseCase(sessionService);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final sessionService = ref.watch(sessionServiceProvider);
  return LogoutUseCase(sessionService);
});

class AuthState {
  final bool isAuthenticated;
  final UserEntity? user;
  final String? errorMessage;
  final bool isLoading;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    UserEntity? user,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final CheckSessionUseCase _checkSessionUseCase;
  final LogoutUseCase _logoutUseCase;
  final SessionService _sessionService;
  final LocalDataStore _store;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required CheckSessionUseCase checkSessionUseCase,
    required LogoutUseCase logoutUseCase,
    required SessionService sessionService,
    required LocalDataStore store,
  })  : _loginUseCase = loginUseCase,
        _checkSessionUseCase = checkSessionUseCase,
        _logoutUseCase = logoutUseCase,
        _sessionService = sessionService,
        _store = store,
        super(AuthState()) {
    checkCurrentSession();
  }

  void checkCurrentSession() {
    final isLoggedIn = _checkSessionUseCase.call();
    if (isLoggedIn) {
      final userId = _sessionService.getUserId();
      if (userId != null) {
        try {
          final user = _store.users.firstWhere((u) => u.id == userId);
          state = AuthState(isAuthenticated: true, user: user);
          return;
        } catch (_) {}
      }
    }
    state = AuthState(isAuthenticated: false);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final user = await _loginUseCase.call(email, password);
    if (user != null) {
      state = AuthState(isAuthenticated: true, user: user);
      return true;
    } else {
      state = AuthState(
        isAuthenticated: false,
        errorMessage: 'Credenciales incorrectas. Pruebe petmatch123.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _logoutUseCase.call();
    state = AuthState(isAuthenticated: false);
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final newUser = UserEntity(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        password: password,
        role: role,
      );
      _store.addUser(newUser);
      
      // Si el rol es voluntario, crear un registro de voluntario vacío
      if (role == 'voluntario') {
        _store.volunteerRecords.add(VolunteerRecordEntity(
          id: 'v_${DateTime.now().millisecondsSinceEpoch}',
          userId: newUser.id,
          name: newUser.name,
          campaignsCompleted: 0,
          hoursAccumulated: 0,
          badges: const [],
          skills: const [],
          availability: 'No definida',
          area: 'Guayaquil',
        ));
        // Guardar records
        final list = _store.volunteerRecords.map((e) => {
          'id': e.id,
          'userId': e.userId,
          'name': e.name,
          'campaignsCompleted': e.campaignsCompleted,
          'hoursAccumulated': e.hoursAccumulated,
          'badges': e.badges,
          'skills': e.skills,
          'availability': e.availability,
          'area': e.area,
        }).toList();
        await _sessionService.saveSession(userId: newUser.id, userName: newUser.name, userRole: newUser.role);
      }
      
      // Autologin
      await _sessionService.saveSession(
        userId: newUser.id,
        userName: newUser.name,
        userRole: newUser.role,
      );
      
      state = AuthState(isAuthenticated: true, user: newUser);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Error al crear cuenta: $e');
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final checkSessionUseCase = ref.watch(checkSessionUseCaseProvider);
  final logoutUseCase = ref.watch(logoutUseCaseProvider);
  final sessionService = ref.watch(sessionServiceProvider);
  final store = ref.watch(localDataStoreProvider);
  return AuthNotifier(
    loginUseCase: loginUseCase,
    checkSessionUseCase: checkSessionUseCase,
    logoutUseCase: logoutUseCase,
    sessionService: sessionService,
    store: store,
  );
});
