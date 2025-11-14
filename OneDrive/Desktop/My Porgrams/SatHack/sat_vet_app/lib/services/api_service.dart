import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sat_vet_app/models/farm_model.dart';
import 'package:sat_vet_app/models/animal_model.dart';
import 'package:sat_vet_app/models/notification_model.dart';

class ApiService {
  final String _baseUrl = "http://127.0.0.1:8000/api/v1";
  String? _token;

  // --- MOCK DATA ---
  final List<Farm> _mockFarms = [
    Farm(id: 'f1', name: 'Ramesh Farm', owner: 'Ramesh Kumar', compliance: 98),
    Farm(id: 'f2', name: 'Sita Farm', owner: 'Sita Devi', compliance: 85),
    Farm(id: 'f3', name: 'Gopal Dairy', owner: 'Gopal Singh', compliance: 92),
  ];

  final List<Farm> _mockRequests = [
    Farm(
      id: 'f5',
      name: 'New Farmer',
      owner: 'K. Patel',
      compliance: 0,
      isPending: true,
    ),
    Farm(
      id: 'f6',
      name: 'Gopal Dairy',
      owner: 'Gopal Singh',
      compliance: 0,
      isPending: true,
    ),
    Farm(
      id: 'f7',
      name: 'Punjab Feeders',
      owner: 'A. Singh',
      compliance: 0,
      isPending: true,
    ),
  ];

  final AnimalDetail _mockAnimalDetail = AnimalDetail(
    id: 'a1',
    tag: '#102-B',
    species: 'Holstein Cattle',
    age: '3 years',
    status: 'ACTIVE',
    withdrawalEnd: '2025-11-24',
    history: [
      Treatment(
        id: 't1',
        drugName: 'Penicillin',
        date: '2025-11-12',
        dosage: '10ml',
        vetName: 'Dr. Priya Sharma',
      ),
      Treatment(
        id: 't2',
        drugName: 'Ivermectin',
        date: '2025-10-20',
        dosage: '5ml',
        vetName: 'Dr. Priya Sharma',
      ),
    ],
  );

  // Helper extension to "copy" the mock object
  AnimalDetail _copyMockAnimal(String id, String tag) {
    return AnimalDetail(
      id: id,
      tag: tag,
      species: _mockAnimalDetail.species,
      age: _mockAnimalDetail.age,
      status: 'CLEAR',
      withdrawalEnd: '',
      history: [],
    );
  }

  // A mock list of animals for a farm
  late final List<AnimalDetail> _mockAnimalList = [
    _copyMockAnimal('a1', '#102-B (Holstein)'),
    _copyMockAnimal('a2', '#105-A (Sahiwal)'),
    _copyMockAnimal('a3', 'Flock-B (Poultry)'),
    _copyMockAnimal('a4', '#201-C (Gir)'),
  ];

  final List<AppNotification> _mockNotifications = [
    AppNotification(
      id: 'n1',
      title: 'New Farm Request',
      body: 'Ramesh Dairy Farm wants to link with you.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      icon: FontAwesomeIcons.userPlus,
      iconColor: Colors.blue.shade700,
    ),
    AppNotification(
      id: 'n2',
      title: 'Compliance Alert',
      body: 'Sita Farm compliance has dropped to 85%.',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      icon: FontAwesomeIcons.shieldHalved,
      iconColor: Colors.orange.shade800,
    ),
  ];
  // --- END MOCK DATA ---

  // ... (Auth and other Vet functions are unchanged) ...
  Future<bool> login(String email, String password) async {
    /* ... */
    return true;
  }

  Future<List<Farm>> getLinkedFarms() async {
    /* ... */
    return _mockFarms;
  }

  Future<List<Farm>> getPendingRequests() async {
    /* ... */
    return _mockRequests;
  }

  Future<bool> approveFarm(String farmId) async {
    /* ... */
    return true;
  }

  Future<bool> denyFarm(String farmId) async {
    /* ... */
    return true;
  }

  Future<bool> createPrescription(
    String animalId,
    String drugId,
    String dosage,
  ) async {
    /* ... */
    return true;
  }

  Future<AnimalDetail> getAnimalDetails(String animalId) async {
    /* ... */
    return _mockAnimalDetail;
  }

  Future<List<AppNotification>> getNotifications() async {
    /* ... */
    return _mockNotifications;
  }

  // --- THIS IS THE NEW FUNCTION ---
  Future<List<AnimalDetail>> getAnimalsForFarm(String farmId) async {
    print('API: GET /vet/farm/$farmId/animals');
    // TODO: Call real API
    await Future.delayed(const Duration(milliseconds: 400));
    // Return the mock animal list
    return _mockAnimalList;
  }
}
