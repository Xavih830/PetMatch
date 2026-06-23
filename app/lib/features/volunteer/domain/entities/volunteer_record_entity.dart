class VolunteerRecordEntity {
  final String id;
  final String userId;
  final String name;
  final int campaignsCompleted;
  final int hoursAccumulated;
  final List<String> badges; // insignias obtenidas
  final List<String> skills; // habilidades seleccionadas
  final String availability; // disponibilidad semanal
  final String area; // zona geográfica

  const VolunteerRecordEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.campaignsCompleted,
    required this.hoursAccumulated,
    required this.badges,
    required this.skills,
    required this.availability,
    required this.area,
  });

  VolunteerRecordEntity copyWith({
    String? id,
    String? userId,
    String? name,
    int? campaignsCompleted,
    int? hoursAccumulated,
    List<String>? badges,
    List<String>? skills,
    String? availability,
    String? area,
  }) {
    return VolunteerRecordEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      campaignsCompleted: campaignsCompleted ?? this.campaignsCompleted,
      hoursAccumulated: hoursAccumulated ?? this.hoursAccumulated,
      badges: badges ?? this.badges,
      skills: skills ?? this.skills,
      availability: availability ?? this.availability,
      area: area ?? this.area,
    );
  }
}
