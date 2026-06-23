class PetEntity {
  final String id;
  final String name;
  final String species; // 'perro', 'gato'
  final String breed;
  final int age; // en años o meses
  final String gender; // 'macho', 'hembra'
  final double weight; // kg
  final String temperament; // ej: 'juguetón, cariñoso'
  final String healthStatus;
  final List<String> vaccines;
  final List<String> images;
  final bool aptaParaNinos;
  final String foundationId;
  final int? matchingScore; // Calculado de forma dinámica

  const PetEntity({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.gender,
    required this.weight,
    required this.temperament,
    required this.healthStatus,
    required this.vaccines,
    required this.images,
    required this.aptaParaNinos,
    required this.foundationId,
    this.matchingScore,
  });

  PetEntity copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    int? age,
    String? gender,
    double? weight,
    String? temperament,
    String? healthStatus,
    List<String>? vaccines,
    List<String>? images,
    bool? aptaParaNinos,
    String? foundationId,
    int? matchingScore,
  }) {
    return PetEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      temperament: temperament ?? this.temperament,
      healthStatus: healthStatus ?? this.healthStatus,
      vaccines: vaccines ?? this.vaccines,
      images: images ?? this.images,
      aptaParaNinos: aptaParaNinos ?? this.aptaParaNinos,
      foundationId: foundationId ?? this.foundationId,
      matchingScore: matchingScore ?? this.matchingScore,
    );
  }
}
