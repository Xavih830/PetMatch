import '../../../../core/services/session_service.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;
  final SessionService _sessionService;

  LoginUseCase(this._repository, this._sessionService);

  Future<UserEntity?> call(String email, String password) async {
    final user = await _repository.login(email, password);
    if (user != null) {
      await _sessionService.saveSession(
        userId: user.id,
        userName: user.name,
        userRole: user.role,
      );
    }
    return user;
  }
}

class CheckSessionUseCase {
  final SessionService _sessionService;

  CheckSessionUseCase(this._sessionService);

  bool call() {
    return _sessionService.isLoggedIn();
  }
}

class LogoutUseCase {
  final SessionService _sessionService;

  LogoutUseCase(this._sessionService);

  Future<void> call() async {
    await _sessionService.clearSession();
  }
}
