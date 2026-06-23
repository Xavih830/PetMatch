import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/local_data_store.dart';
import '../../core/providers/core_providers.dart';
import 'domain/entities/pet_entity.dart';
import 'domain/entities/foundation_entity.dart';

// Interfaces del Dominio
abstract class PetRepository {
  Future<List<PetEntity>> getPets();
  Future<void> addPet(PetEntity pet);
  Future<void> updatePet(PetEntity pet);
}

abstract class FoundationRepository {
  Future<List<FoundationEntity>> getFoundations();
  Future<void> updateFoundation(FoundationEntity foundation);
}

// Implementación de la Capa Data
class PetRepositoryImpl implements PetRepository {
  final LocalDataStore _store;
  PetRepositoryImpl(this._store);

  @override
  Future<List<PetEntity>> getPets() async => _store.pets;

  @override
  Future<void> addPet(PetEntity pet) async => _store.addPet(pet);

  @override
  Future<void> updatePet(PetEntity pet) async => _store.updatePet(pet);
}

class FoundationRepositoryImpl implements FoundationRepository {
  final LocalDataStore _store;
  FoundationRepositoryImpl(this._store);

  @override
  Future<List<FoundationEntity>> getFoundations() async => _store.foundations;

  @override
  Future<void> updateFoundation(FoundationEntity f) async => _store.updateFoundation(f);
}

// Riverpod Repositorios
final petRepositoryProvider = Provider<PetRepository>((ref) {
  return PetRepositoryImpl(ref.watch(localDataStoreProvider));
});

final foundationRepositoryProvider = Provider<FoundationRepository>((ref) {
  return FoundationRepositoryImpl(ref.watch(localDataStoreProvider));
});

// Modelo del Cuestionario de Matching
class MatchingQuestionnaire {
  final int hoursAway; // Horas fuera de casa
  final String housingType; // 'departamento', 'casa'
  final bool hasKids;
  final String activityLevel; // 'bajo', 'moderado', 'alto'

  const MatchingQuestionnaire({
    required this.hoursAway,
    required this.housingType,
    required this.hasKids,
    required this.activityLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'hoursAway': hoursAway,
      'housingType': housingType,
      'hasKids': hasKids,
      'activityLevel': activityLevel,
    };
  }

  factory MatchingQuestionnaire.fromMap(Map<String, dynamic> map) {
    return MatchingQuestionnaire(
      hoursAway: map['hoursAway'] ?? 4,
      housingType: map['housingType'] ?? 'departamento',
      hasKids: map['hasKids'] ?? false,
      activityLevel: map['activityLevel'] ?? 'moderado',
    );
  }
}

// Casos de Uso del Dominio
class CalculateMatchingScoreUseCase {
  int calculate(PetEntity pet, MatchingQuestionnaire q) {
    int score = 85; // Base score

    // Regla 1: Niños y aptitud del animal
    if (q.hasKids && !pet.aptaParaNinos) {
      score -= 35;
    } else if (q.hasKids && pet.aptaParaNinos) {
      score += 10;
    }

    // Regla 2: Vivienda y especie/tamaño
    if (q.housingType == 'departamento') {
      if (pet.species == 'gato') {
        score += 10;
      } else if (pet.weight > 20.0) {
        score -= 25; // Perro grande en departamento
      } else {
        score += 5; // Perro pequeño en departamento
      }
    } else {
      // Casa con patio
      if (pet.weight > 20.0) {
        score += 15;
      }
    }

    // Regla 3: Tiempo fuera de casa y especie
    if (q.hoursAway > 8) {
      if (pet.species == 'perro') {
        score -= 20; // Los perros requieren más atención
      } else {
        score += 5; // Los gatos toleran más soledad
      }
    } else if (q.hoursAway < 4) {
      score += 10;
    }

    // Regla 4: Nivel de actividad y temperamento/raza
    if (q.activityLevel == 'alto') {
      if (pet.temperament.toLowerCase().contains('enérgico') || pet.temperament.toLowerCase().contains('activo')) {
        score += 15;
      } else {
        score -= 5;
      }
    } else if (q.activityLevel == 'bajo') {
      if (pet.temperament.toLowerCase().contains('tranquilo') || pet.temperament.toLowerCase().contains('perezoso')) {
        score += 15;
      } else if (pet.temperament.toLowerCase().contains('enérgico') || pet.temperament.toLowerCase().contains('activo')) {
        score -= 20; // Incompatibilidad de energía
      }
    }

    // Limitar entre 0 y 100
    if (score > 100) return 100;
    if (score < 0) return 0;
    return score;
  }
}

// State Notifier para gestionar la lista de mascotas y el cuestionario
class MatchingState {
  final List<PetEntity> pets;
  final MatchingQuestionnaire? questionnaire;
  final bool isLoading;

  MatchingState({
    required this.pets,
    this.questionnaire,
    this.isLoading = false,
  });

  MatchingState copyWith({
    List<PetEntity>? pets,
    MatchingQuestionnaire? questionnaire,
    bool? isLoading,
  }) {
    return MatchingState(
      pets: pets ?? this.pets,
      questionnaire: questionnaire ?? this.questionnaire,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MatchingNotifier extends StateNotifier<MatchingState> {
  final PetRepository _petRepository;
  final Ref _ref;

  MatchingNotifier(this._petRepository, this._ref)
      : super(MatchingState(pets: [])) {
    loadMascotas();
  }

  Future<void> loadMascotas() async {
    state = state.copyWith(isLoading: true);
    
    // Cargar cuestionario si existe en SharedPreferences
    final prefs = _ref.read(sharedPreferencesProvider);
    final qStr = prefs.getString('matching_questionnaire');
    MatchingQuestionnaire? questionnaire;
    if (qStr != null) {
      questionnaire = MatchingQuestionnaire.fromMap(json.decode(qStr));
    }

    final rawPets = await _petRepository.getPets();
    
    if (questionnaire != null) {
      // Calcular score dinámico
      final calculator = CalculateMatchingScoreUseCase();
      final scoredPets = rawPets.map((pet) {
        final score = calculator.calculate(pet, questionnaire!);
        return pet.copyWith(matchingScore: score);
      }).toList();
      
      // Ordenar por score descendente
      scoredPets.sort((a, b) => (b.matchingScore ?? 0).compareTo(a.matchingScore ?? 0));
      
      state = MatchingState(pets: scoredPets, questionnaire: questionnaire, isLoading: false);
    } else {
      // Si no hay cuestionario, retornar sin score
      state = MatchingState(pets: rawPets, questionnaire: null, isLoading: false);
    }
  }

  Future<void> saveQuestionnaire(MatchingQuestionnaire q) async {
    state = state.copyWith(isLoading: true);
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.setString('matching_questionnaire', json.encode(q.toMap()));
    await loadMascotas();
  }

  Future<void> clearQuestionnaire() async {
    state = state.copyWith(isLoading: true);
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.remove('matching_questionnaire');
    await loadMascotas();
  }
}

final matchingProvider = StateNotifierProvider<MatchingNotifier, MatchingState>((ref) {
  final repo = ref.watch(petRepositoryProvider);
  return MatchingNotifier(repo, ref);
});
