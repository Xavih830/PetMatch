class CampaignEntity {
  final String id;
  final String title;
  final String description;
  final String type; // 'alimentación', 'baño', 'paseo', 'adopción'
  final DateTime date;
  final String location;
  final int capacity;
  final int enrolledVolunteersCount;
  final List<String> skillsRequired;
  final String foundationId;

  const CampaignEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.date,
    required this.location,
    required this.capacity,
    required this.enrolledVolunteersCount,
    required this.skillsRequired,
    required this.foundationId,
  });

  CampaignEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    DateTime? date,
    String? location,
    int? capacity,
    int? enrolledVolunteersCount,
    List<String>? skillsRequired,
    String? foundationId,
  }) {
    return CampaignEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      date: date ?? this.date,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      enrolledVolunteersCount: enrolledVolunteersCount ?? this.enrolledVolunteersCount,
      skillsRequired: skillsRequired ?? this.skillsRequired,
      foundationId: foundationId ?? this.foundationId,
    );
  }
}
