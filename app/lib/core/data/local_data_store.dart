import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/matching/domain/entities/pet_entity.dart';
import '../../features/matching/domain/entities/foundation_entity.dart';
import '../../features/adoption/domain/entities/adoption_request_entity.dart';
import '../../features/volunteer/domain/entities/campaign_entity.dart';
import '../../features/volunteer/domain/entities/volunteer_record_entity.dart';
import '../../features/reports/domain/entities/report_entity.dart';
import '../../features/chat/domain/entities/message_entity.dart';

class LocalDataStore {
  final SharedPreferences _prefs;

  LocalDataStore(this._prefs) {
    _loadFromPrefs();
  }

  // Listas en memoria
  late List<UserEntity> users;
  late List<PetEntity> pets;
  late List<FoundationEntity> foundations;
  late List<CampaignEntity> campaigns;
  late List<AdoptionRequestEntity> adoptionRequests;
  late List<VolunteerRecordEntity> volunteerRecords;
  late List<ReportEntity> reports;
  late Map<String, List<MessageEntity>> chatRooms;
  double commissionRate = 8.0; // %
  String senderEmail = 'notificaciones@petmatch.ec';

  void _loadFromPrefs() {
    // 1. Usuarios quemados (Estático)
    users = [
      const UserEntity(
        id: 'u1',
        name: 'Valentina Torres',
        email: 'valentina@petmatch.ec',
        role: 'adoptante',
        password: 'petmatch123',
      ),
      const UserEntity(
        id: 'u2',
        name: 'Roberto Alcívar',
        email: 'roberto@huellitas.ec',
        role: 'coordinador',
        password: 'petmatch123',
      ),
      const UserEntity(
        id: 'u3',
        name: 'Sebastián Vera',
        email: 'sebastian@petmatch.ec',
        role: 'voluntario',
        password: 'petmatch123',
      ),
      const UserEntity(
        id: 'u4',
        name: 'Administrador',
        email: 'admin@petmatch.ec',
        role: 'admin',
        password: 'admin2026',
      ),
    ];

    // Cargar usuarios registrados de SharedPreferences
    final customUsersStr = _prefs.getString('store_custom_users');
    if (customUsersStr != null) {
      try {
        final List decoded = json.decode(customUsersStr);
        final customUsers = decoded.map((e) => UserEntity(
          id: e['id'],
          name: e['name'],
          email: e['email'],
          role: e['role'],
          password: e['password'],
        )).toList();
        users.addAll(customUsers);
      } catch (_) {}
    }

    // 2. Fundaciones
    final fStr = _prefs.getString('store_foundations');
    if (fStr != null) {
      final List decoded = json.decode(fStr);
      foundations = decoded.map((e) => FoundationEntity(
        id: e['id'],
        name: e['name'],
        description: e['description'],
        location: e['location'],
        rating: e['rating'].toDouble(),
        verified: e['verified'],
      )).toList();
    } else {
      foundations = [
        const FoundationEntity(
          id: 'f1',
          name: 'Huellitas de Amor',
          description: 'Rescatamos, rehabilitamos y buscamos hogares llenos de amor para animales de la calle en Guayaquil.',
          location: 'Guayaquil Norte (Urdesa)',
          rating: 4.8,
          verified: true,
        ),
        const FoundationEntity(
          id: 'f2',
          name: 'Fundación Rescate GYE',
          description: 'Dedicados a salvar vidas de animales en estado de vulnerabilidad extrema en la urbe.',
          location: 'Guayaquil Centro',
          rating: 4.6,
          verified: false, // Pendiente de verificar por admin
        ),
        const FoundationEntity(
          id: 'f3',
          name: 'Patitas del Salado',
          description: 'Cuidamos y rehabilitamos perros y gatos de las zonas aledañas al Estero Salado.',
          location: 'Guayaquil Sur',
          rating: 4.2,
          verified: true,
        ),
      ];
      _saveFoundations();
    }

    // 3. Mascotas (15 en total)
    final pStr = _prefs.getString('store_pets');
    if (pStr != null) {
      final List decoded = json.decode(pStr);
      pets = decoded.map((e) => PetEntity(
        id: e['id'],
        name: e['name'],
        species: e['species'],
        breed: e['breed'],
        age: e['age'],
        gender: e['gender'],
        weight: e['weight'].toDouble(),
        temperament: e['temperament'],
        healthStatus: e['healthStatus'],
        vaccines: List<String>.from(e['vaccines']),
        images: List<String>.from(e['images']),
        aptaParaNinos: e['aptaParaNinos'],
        foundationId: e['foundationId'],
      )).toList();
    } else {
      pets = [
        const PetEntity(
          id: 'p1',
          name: 'Max',
          species: 'perro',
          breed: 'Golden Retriever',
          age: 2,
          gender: 'macho',
          weight: 28.0,
          temperament: 'Juguetón, dócil, enérgico',
          healthStatus: 'Excelente, vacunas al día',
          vaccines: ['Antirrábica', 'Quíntuple', 'Desparasitación'],
          images: ['assets/images/max.png'],
          aptaParaNinos: true,
          foundationId: 'f1',
        ),
        const PetEntity(
          id: 'p2',
          name: 'Luna',
          species: 'gato',
          breed: 'Siamés',
          age: 1,
          gender: 'hembra',
          weight: 3.5,
          temperament: 'Cariñosa, tranquila, tímida',
          healthStatus: 'Saludable, esterilizada',
          vaccines: ['Triple Felina', 'Desparasitación'],
          images: ['assets/images/luna.png'],
          aptaParaNinos: true,
          foundationId: 'f1',
        ),
        const PetEntity(
          id: 'p3',
          name: 'Rocky',
          species: 'perro',
          breed: 'Mestizo',
          age: 4,
          gender: 'macho',
          weight: 15.0,
          temperament: 'Protector, muy inteligente, activo',
          healthStatus: 'Rehabilitado de fractura en pata trasera',
          vaccines: ['Antirrábica', 'Desparasitación'],
          images: ['assets/images/rocky.png'],
          aptaParaNinos: false,
          foundationId: 'f1',
        ),
        const PetEntity(
          id: 'p4',
          name: 'Mimi',
          species: 'gato',
          breed: 'Común Europeo',
          age: 3,
          gender: 'hembra',
          weight: 4.2,
          temperament: 'Independiente, curiosa, juguetona',
          healthStatus: 'Chequeo general excelente',
          vaccines: ['Triple Felina', 'Rabia'],
          images: ['assets/images/mimi.png'],
          aptaParaNinos: true,
          foundationId: 'f2',
        ),
        const PetEntity(
          id: 'p5',
          name: 'Toby',
          species: 'perro',
          breed: 'Poodle',
          age: 5,
          gender: 'macho',
          weight: 6.0,
          temperament: 'Cariñoso, hogareño, ladra a desconocidos',
          healthStatus: 'Alergia alimentaria controlada',
          vaccines: ['Antirrábica', 'Quíntuple', 'Desparasitación'],
          images: ['assets/images/toby.png'],
          aptaParaNinos: true,
          foundationId: 'f1',
        ),
        // Adicionales para completar las 15 mascotas requeridas
        const PetEntity(
          id: 'p6',
          name: 'Bella',
          species: 'perro',
          breed: 'Labrador Mestizo',
          age: 1,
          gender: 'hembra',
          weight: 22.0,
          temperament: 'Hiperactiva, amigable, necesita espacio',
          healthStatus: 'Sana, llena de energía',
          vaccines: ['Antirrábica', 'Quíntuple'],
          images: ['assets/images/bella.png'],
          aptaParaNinos: true,
          foundationId: 'f1',
        ),
        const PetEntity(
          id: 'p7',
          name: 'Simba',
          species: 'gato',
          breed: 'Persa Mestizo',
          age: 2,
          gender: 'macho',
          weight: 5.0,
          temperament: 'Perezoso, dócil, le gusta dormir',
          healthStatus: 'Sano',
          vaccines: ['Triple Felina'],
          images: ['assets/images/simba.png'],
          aptaParaNinos: true,
          foundationId: 'f3',
        ),
        const PetEntity(
          id: 'p8',
          name: 'Coco',
          species: 'perro',
          breed: 'Chihuahua',
          age: 3,
          gender: 'macho',
          weight: 3.0,
          temperament: 'Ruidoso, apegado a su dueño, nervioso',
          healthStatus: 'Sano',
          vaccines: ['Antirrábica', 'Desparasitación'],
          images: ['assets/images/coco.png'],
          aptaParaNinos: false,
          foundationId: 'f2',
        ),
        const PetEntity(
          id: 'p9',
          name: 'Nala',
          species: 'perro',
          breed: 'Pastor Alemán Mix',
          age: 2,
          gender: 'hembra',
          weight: 26.0,
          temperament: 'Leal, protectora, requiere entrenamiento',
          healthStatus: 'Sana, desparasitada',
          vaccines: ['Antirrábica', 'Quíntuple'],
          images: ['assets/images/nala.png'],
          aptaParaNinos: true,
          foundationId: 'f3',
        ),
        const PetEntity(
          id: 'p10',
          name: 'Bambi',
          species: 'perro',
          breed: 'Mestizo Pequeño',
          age: 1,
          gender: 'hembra',
          weight: 8.0,
          temperament: 'Tímida, asustadiza, dulce',
          healthStatus: 'Sana, esterilizada',
          vaccines: ['Antirrábica', 'Desparasitación'],
          images: ['assets/images/bambi.png'],
          aptaParaNinos: true,
          foundationId: 'f1',
        ),
        const PetEntity(
          id: 'p11',
          name: 'Zeus',
          species: 'perro',
          breed: 'Rottweiler Mix',
          age: 4,
          gender: 'macho',
          weight: 35.0,
          temperament: 'Serio, calmado, guardián',
          healthStatus: 'Tratamiento de displasia leve',
          vaccines: ['Antirrábica', 'Quíntuple'],
          images: ['assets/images/zeus.png'],
          aptaParaNinos: false,
          foundationId: 'f2',
        ),
        const PetEntity(
          id: 'p12',
          name: 'Garfield',
          species: 'gato',
          breed: 'Tabby Naranja',
          age: 4,
          gender: 'macho',
          weight: 6.2,
          temperament: 'Glotón, amigable, cariñoso',
          healthStatus: 'Sano',
          vaccines: ['Triple Felina', 'Desparasitación'],
          images: ['assets/images/garfield.png'],
          aptaParaNinos: true,
          foundationId: 'f1',
        ),
        const PetEntity(
          id: 'p13',
          name: 'Mia',
          species: 'gato',
          breed: 'Angora Mix',
          age: 1,
          gender: 'hembra',
          weight: 2.8,
          temperament: 'Asustadiza, juguetona en confianza',
          healthStatus: 'Sana',
          vaccines: ['Triple Felina'],
          images: ['assets/images/mia.png'],
          aptaParaNinos: true,
          foundationId: 'f3',
        ),
        const PetEntity(
          id: 'p14',
          name: 'Bruno',
          species: 'perro',
          breed: 'Boxer Mestizo',
          age: 3,
          gender: 'macho',
          weight: 24.0,
          temperament: 'Activo, torpe, cariñoso',
          healthStatus: 'Sano',
          vaccines: ['Antirrábica', 'Quíntuple'],
          images: ['assets/images/bruno.png'],
          aptaParaNinos: true,
          foundationId: 'f1',
        ),
        const PetEntity(
          id: 'p15',
          name: 'Kira',
          species: 'perro',
          breed: 'Husky Mix',
          age: 2,
          gender: 'hembra',
          weight: 20.0,
          temperament: 'Independiente, aulladora, enérgica',
          healthStatus: 'Sana, vacunas completas',
          vaccines: ['Antirrábica', 'Quíntuple', 'Traqueobronquitis'],
          images: ['assets/images/kira.png'],
          aptaParaNinos: false,
          foundationId: 'f1',
        ),
      ];
      _savePets();
    }

    // 4. Campañas de voluntariado
    final cStr = _prefs.getString('store_campaigns');
    if (cStr != null) {
      final List decoded = json.decode(cStr);
      campaigns = decoded.map((e) => CampaignEntity(
        id: e['id'],
        title: e['title'],
        description: e['description'],
        type: e['type'],
        date: DateTime.parse(e['date']),
        location: e['location'],
        capacity: e['capacity'],
        enrolledVolunteersCount: e['enrolledVolunteersCount'],
        skillsRequired: List<String>.from(e['skillsRequired']),
        foundationId: e['foundationId'],
      )).toList();
    } else {
      campaigns = [
        CampaignEntity(
          id: 'c1',
          title: 'Campaña de Baño y Aseo Urdesa',
          description: 'Ayúdanos a bañar y peinar a más de 20 perritos rescatados para su feria de adopción.',
          type: 'baño',
          date: DateTime.now().add(const Duration(days: 2)),
          location: 'Parque de Urdesa, Guayaquil',
          capacity: 10,
          enrolledVolunteersCount: 4,
          skillsRequired: const ['Paciencia', 'Manejo de perros grandes'],
          foundationId: 'f1',
        ),
        CampaignEntity(
          id: 'c2',
          title: 'Feria de Adopción Responsable',
          description: 'Estaremos en el Malecón 2000 promoviendo la adopción de nuestros rescatados. Necesitamos apoyo guiando al público.',
          type: 'adopción',
          date: DateTime.now().add(const Duration(days: 5)),
          location: 'Malecón 2000, Guayaquil',
          capacity: 15,
          enrolledVolunteersCount: 8,
          skillsRequired: const ['Atención al público', 'Facilidad de palabra'],
          foundationId: 'f1',
        ),
        CampaignEntity(
          id: 'c3',
          title: 'Jornada de Alimentación y Limpieza',
          description: 'Apoyo en la limpieza del refugio temporal y distribución de raciones alimentarias para gatos.',
          type: 'alimentación',
          date: DateTime.now().add(const Duration(days: 7)),
          location: 'Refugio Centro, Guayaquil',
          capacity: 8,
          enrolledVolunteersCount: 2,
          skillsRequired: const ['Limpieza', 'Amor por los gatos'],
          foundationId: 'f2',
        ),
      ];
      _saveCampaigns();
    }

    // 5. Historial de voluntario (Sebastián Vera)
    final vStr = _prefs.getString('store_volunteer_records');
    if (vStr != null) {
      final List decoded = json.decode(vStr);
      volunteerRecords = decoded.map((e) => VolunteerRecordEntity(
        id: e['id'],
        userId: e['userId'],
        name: e['name'],
        campaignsCompleted: e['campaignsCompleted'],
        hoursAccumulated: e['hoursAccumulated'],
        badges: List<String>.from(e['badges']),
        skills: List<String>.from(e['skills']),
        availability: e['availability'],
        area: e['area'],
      )).toList();
    } else {
      volunteerRecords = [
        const VolunteerRecordEntity(
          id: 'v1',
          userId: 'u3', // sebastian@petmatch.ec
          name: 'Sebastián Vera',
          campaignsCompleted: 3,
          hoursAccumulated: 12,
          badges: ['Primer Apoyo', 'Amigo Fiel'],
          skills: ['Paseo de perros', 'Atención básica'],
          availability: 'Sábados por la mañana',
          area: 'Guayaquil Norte',
        )
      ];
      _saveVolunteerRecords();
    }

    // 6. Solicitudes de Adopción (Valentina Torres)
    final reqStr = _prefs.getString('store_requests');
    if (reqStr != null) {
      final List decoded = json.decode(reqStr);
      adoptionRequests = decoded.map((e) => AdoptionRequestEntity(
        id: e['id'],
        petId: e['petId'],
        petName: e['petName'],
        petImage: e['petImage'],
        applicantId: e['applicantId'],
        applicantName: e['applicantName'],
        applicantProfileSummary: e['applicantProfileSummary'],
        status: e['status'],
        date: DateTime.parse(e['date']),
      )).toList();
    } else {
      // Valentina tiene una solicitud en curso con Max
      adoptionRequests = [
        AdoptionRequestEntity(
          id: 'r1',
          petId: 'p1', // Max
          petName: 'Max',
          petImage: 'assets/images/max.png',
          applicantId: 'u1', // Valentina
          applicantName: 'Valentina Torres',
          applicantProfileSummary: 'Vivienda: Departamento amplio. Horas fuera: 4 hrs. Niños: Sí. Actividad: Moderada.',
          status: 'pendiente',
          date: DateTime.now().subtract(const Duration(days: 1)),
        )
      ];
      _saveRequests();
    }

    // 7. Denuncias Anónimas
    final repStr = _prefs.getString('store_reports');
    if (repStr != null) {
      final List decoded = json.decode(repStr);
      reports = decoded.map((e) => ReportEntity(
        id: e['id'],
        type: e['type'],
        description: e['description'],
        area: e['area'],
        date: DateTime.parse(e['date']),
        status: e['status'],
      )).toList();
    } else {
      reports = [
        ReportEntity(
          id: 'rep1',
          type: 'abandono',
          description: 'Cachorro abandonado en una caja de cartón cerca del puente.',
          area: 'Samanes, Guayaquil Norte',
          date: DateTime.now().subtract(const Duration(hours: 5)),
          status: 'recibido',
        ),
      ];
      _saveReports();
    }

    // 8. Mensajería de Chats
    final chatStr = _prefs.getString('store_chats');
    if (chatStr != null) {
      final Map decoded = json.decode(chatStr);
      chatRooms = decoded.map((key, value) {
        final List list = value;
        return MapEntry(
          key as String,
          list.map((m) => MessageEntity.fromMap(m)).toList(),
        );
      });
    } else {
      // Chat inicial quemado entre Valentina y Roberto sobre Max
      chatRooms = {
        'p1_u1': [
          MessageEntity(
            senderId: 'u1',
            senderName: 'Valentina Torres',
            content: 'Hola, estoy muy interesada en adoptar a Max. He completado el cuestionario de compatibilidad.',
            timestamp: DateTime.now().subtract(const Duration(hours: 12)),
          ),
          MessageEntity(
            senderId: 'u2',
            senderName: 'Roberto Alcívar',
            content: 'Hola Valentina. Qué gusto saludarte. Veo que tienes un 95% de compatibilidad. Estaremos revisando tu solicitud hoy por la tarde.',
            timestamp: DateTime.now().subtract(const Duration(hours: 10)),
          ),
        ]
      };
      _saveChats();
    }

    // 9. Configuración del sistema
    commissionRate = _prefs.getDouble('store_commission_rate') ?? 8.0;
    senderEmail = _prefs.getString('store_sender_email') ?? 'notificaciones@petmatch.ec';
  }

  // Guardados en SharedPreferences
  void _saveFoundations() {
    final list = foundations.map((e) => {
      'id': e.id,
      'name': e.name,
      'description': e.description,
      'location': e.location,
      'rating': e.rating,
      'verified': e.verified,
    }).toList();
    _prefs.setString('store_foundations', json.encode(list));
  }

  void _savePets() {
    final list = pets.map((e) => {
      'id': e.id,
      'name': e.name,
      'species': e.species,
      'breed': e.breed,
      'age': e.age,
      'gender': e.gender,
      'weight': e.weight,
      'temperament': e.temperament,
      'healthStatus': e.healthStatus,
      'vaccines': e.vaccines,
      'images': e.images,
      'aptaParaNinos': e.aptaParaNinos,
      'foundationId': e.foundationId,
    }).toList();
    _prefs.setString('store_pets', json.encode(list));
  }

  void _saveCampaigns() {
    final list = campaigns.map((e) => {
      'id': e.id,
      'title': e.title,
      'description': e.description,
      'type': e.type,
      'date': e.date.toIso8601String(),
      'location': e.location,
      'capacity': e.capacity,
      'enrolledVolunteersCount': e.enrolledVolunteersCount,
      'skillsRequired': e.skillsRequired,
      'foundationId': e.foundationId,
    }).toList();
    _prefs.setString('store_campaigns', json.encode(list));
  }

  void _saveVolunteerRecords() {
    final list = volunteerRecords.map((e) => {
      'id': e.id,
      'userId': e.userId,
      'name': e.name,
      'campaignsCompleted': e.campaignsCompleted,
      'hoursAccumulated': e.hoursAccumulated,
      'badges': e.badges,
      'skills': e.skills,
      'availability': e.availability,
      'area': e.area,
    }).toList();
    _prefs.setString('store_volunteer_records', json.encode(list));
  }

  void _saveRequests() {
    final list = adoptionRequests.map((e) => {
      'id': e.id,
      'petId': e.petId,
      'petName': e.petName,
      'petImage': e.petImage,
      'applicantId': e.applicantId,
      'applicantName': e.applicantName,
      'applicantProfileSummary': e.applicantProfileSummary,
      'status': e.status,
      'date': e.date.toIso8601String(),
    }).toList();
    _prefs.setString('store_requests', json.encode(list));
  }

  void _saveReports() {
    final list = reports.map((e) => {
      'id': e.id,
      'type': e.type,
      'description': e.description,
      'area': e.area,
      'date': e.date.toIso8601String(),
      'status': e.status,
    }).toList();
    _prefs.setString('store_reports', json.encode(list));
  }

  void _saveChats() {
    final map = chatRooms.map((key, value) {
      return MapEntry(
        key,
        value.map((m) => m.toMap()).toList(),
      );
    });
    _prefs.setString('store_chats', json.encode(map));
  }

  // Métodos de Modificación (Mutaciones)
  void addPet(PetEntity pet) {
    pets.add(pet);
    _savePets();
  }

  void updatePet(PetEntity pet) {
    final index = pets.indexWhere((element) => element.id == pet.id);
    if (index != -index) {
      pets[index] = pet;
      _savePets();
    }
  }

  void updateFoundation(FoundationEntity f) {
    final index = foundations.indexWhere((element) => element.id == f.id);
    if (index != -1) {
      foundations[index] = f;
      _saveFoundations();
    }
  }

  void addAdoptionRequest(AdoptionRequestEntity req) {
    adoptionRequests.add(req);
    _saveRequests();
  }

  void updateAdoptionRequest(String id, String status) {
    final index = adoptionRequests.indexWhere((element) => element.id == id);
    if (index != -1) {
      adoptionRequests[index] = adoptionRequests[index].copyWith(status: status);
      _saveRequests();
    }
  }

  void enrollInCampaign(String campaignId, String volunteerId, List<String> skills) {
    final cIndex = campaigns.indexWhere((element) => element.id == campaignId);
    if (cIndex != -1) {
      final campaign = campaigns[cIndex];
      campaigns[cIndex] = campaign.copyWith(
        enrolledVolunteersCount: campaign.enrolledVolunteersCount + 1,
      );
      _saveCampaigns();
    }

    final vIndex = volunteerRecords.indexWhere((element) => element.userId == volunteerId);
    if (vIndex != -1) {
      final rec = volunteerRecords[vIndex];
      // Añadir racha e insignias si cruza un umbral
      final newCampaignCount = rec.campaignsCompleted + 1;
      final newHours = rec.hoursAccumulated + 4; // 4h por campaña
      final List<String> badges = List.from(rec.badges);
      
      if (newCampaignCount == 4 && !badges.contains('Héroe Local')) {
        badges.add('Héroe Local');
      }

      volunteerRecords[vIndex] = rec.copyWith(
        campaignsCompleted: newCampaignCount,
        hoursAccumulated: newHours,
        badges: badges,
      );
      _saveVolunteerRecords();
    }
  }

  void updateVolunteerProfile({
    required String userId,
    required List<String> skills,
    required String availability,
    required String area,
  }) {
    final index = volunteerRecords.indexWhere((element) => element.userId == userId);
    if (index != -1) {
      volunteerRecords[index] = volunteerRecords[index].copyWith(
        skills: skills,
        availability: availability,
        area: area,
      );
      _saveVolunteerRecords();
    }
  }

  void addReport(ReportEntity rep) {
    reports.add(rep);
    _saveReports();
  }

  void addMessage(String petId, String userId, MessageEntity msg) {
    final key = '${petId}_$userId';
    if (!chatRooms.containsKey(key)) {
      chatRooms[key] = [];
    }
    chatRooms[key]!.add(msg);
    _saveChats();
  }

  void updateSystemSettings(double rate, String email) {
    commissionRate = rate;
    senderEmail = email;
    _prefs.setDouble('store_commission_rate', rate);
    _prefs.setString('store_sender_email', email);
  }

  void addUser(UserEntity user) {
    // Evitar duplicados en memoria
    if (!users.any((u) => u.email == user.email)) {
      users.add(user);
    }
    
    // Guardar en SharedPreferences
    final customUsersStr = _prefs.getString('store_custom_users');
    List customList = [];
    if (customUsersStr != null) {
      try {
        customList = json.decode(customUsersStr);
      } catch (_) {}
    }
    
    // Evitar guardar duplicado por correo
    if (!customList.any((u) => u['email'] == user.email)) {
      customList.add({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'role': user.role,
        'password': user.password,
      });
      _prefs.setString('store_custom_users', json.encode(customList));
    }
  }
}
