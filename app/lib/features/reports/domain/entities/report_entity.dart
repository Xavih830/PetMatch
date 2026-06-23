class ReportEntity {
  final String id;
  final String type; // 'maltrato', 'abandono', 'accidente'
  final String description;
  final String area; // zona de Guayaquil
  final DateTime date;
  final String status; // 'recibido', 'en_investigacion', 'resuelto'

  const ReportEntity({
    required this.id,
    required this.type,
    required this.description,
    required this.area,
    required this.date,
    required this.status,
  });

  ReportEntity copyWith({
    String? id,
    String? type,
    String? description,
    String? area,
    DateTime? date,
    String? status,
  }) {
    return ReportEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
      area: area ?? this.area,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}
