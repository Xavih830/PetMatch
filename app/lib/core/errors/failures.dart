abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
