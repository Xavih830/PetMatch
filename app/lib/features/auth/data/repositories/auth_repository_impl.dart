import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/data/local_data_store.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalDataStore _store;

  AuthRepositoryImpl(this._store);

  @override
  Future<UserEntity?> login(String email, String password) async {
    // Buscar en la lista de usuarios del store
    try {
      final user = _store.users.firstWhere(
        (u) => u.email == email && u.password == password,
      );
      return user;
    } catch (_) {
      return null;
    }
  }
}
