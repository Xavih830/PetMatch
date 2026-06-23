class UserEntity {
  final String id;
  final String name;
  final String email;
  final String role; // 'adoptante', 'coordinador', 'voluntario', 'admin'
  final String password;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.password,
  });
}
