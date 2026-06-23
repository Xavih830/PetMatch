class AdoptionRequestEntity {
  final String id;
  final String petId;
  final String petName;
  final String petImage;
  final String applicantId;
  final String applicantName;
  final String applicantProfileSummary; // del cuestionario
  final String status; // 'pendiente', 'aprobada', 'rechazada'
  final DateTime date;

  const AdoptionRequestEntity({
    required this.id,
    required this.petId,
    required this.petName,
    required this.petImage,
    required this.applicantId,
    required this.applicantName,
    required this.applicantProfileSummary,
    required this.status,
    required this.date,
  });

  AdoptionRequestEntity copyWith({
    String? id,
    String? petId,
    String? petName,
    String? petImage,
    String? applicantId,
    String? applicantName,
    String? applicantProfileSummary,
    String? status,
    DateTime? date,
  }) {
    return AdoptionRequestEntity(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      petImage: petImage ?? this.petImage,
      applicantId: applicantId ?? this.applicantId,
      applicantName: applicantName ?? this.applicantName,
      applicantProfileSummary: applicantProfileSummary ?? this.applicantProfileSummary,
      status: status ?? this.status,
      date: date ?? this.date,
    );
  }
}
