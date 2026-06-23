class FoundationEntity {
  final String id;
  final String name;
  final String description;
  final String location;
  final double rating;
  final bool verified;

  const FoundationEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.rating,
    required this.verified,
  });

  FoundationEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
    double? rating,
    bool? verified,
  }) {
    return FoundationEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      verified: verified ?? this.verified,
    );
  }
}
