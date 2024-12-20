import 'package:cloud_firestore/cloud_firestore.dart';

enum ClientActivityStatus {
  active,
  semiActive,
  inactive
}

class Director {
  final String name;
  final String email;
  final String phone;

  Director({
    required this.name,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  factory Director.fromMap(Map<String, dynamic> map) {
    return Director(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}

class Service {
  final String name;
  final String description;

  Service({
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }
}

class Client {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String companyName;
  final String registrationNumber;
  final List<Director> directors;
  final List<Service> services;
  final Map<String, dynamic> platforms;
  final DateTime createdAt;
  final DateTime? lastContact;
  final String notes;
  final double expectedRevenue;
  final double actualRevenue;
  final DateTime? taxDueDate;
  ClientActivityStatus _activityStatus;

  ClientActivityStatus get activityStatus => _activityStatus;
  set activityStatus(ClientActivityStatus status) {
    _activityStatus = status;
  }

  String get directorName => directors.isNotEmpty ? directors.first.name : '';

  Client({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.companyName,
    required this.registrationNumber,
    required this.directors,
    required this.services,
    required this.platforms,
    required this.createdAt,
    this.lastContact,
    this.notes = '',
    this.expectedRevenue = 0.0,
    this.actualRevenue = 0.0,
    this.taxDueDate,
    ClientActivityStatus activityStatus = ClientActivityStatus.active,
  }) : _activityStatus = activityStatus;

  factory Client.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    List<Director> directors = [];
    if (data['directors'] != null && data['directors'] is List) {
      directors = (data['directors'] as List)
          .where((d) => d is Map<String, dynamic>)
          .map((d) => Director.fromMap(d as Map<String, dynamic>))
          .toList();
    }

    List<Service> services = [];
    if (data['services'] != null && data['services'] is List) {
      services = (data['services'] as List)
          .where((s) => s is Map<String, dynamic>)
          .map((s) => Service.fromMap(s as Map<String, dynamic>))
          .toList();
    }

    ClientActivityStatus status = ClientActivityStatus.active;
    if (data['activityStatus'] != null) {
      switch (data['activityStatus']) {
        case 'active':
          status = ClientActivityStatus.active;
          break;
        case 'semiActive':
          status = ClientActivityStatus.semiActive;
          break;
        case 'inactive':
          status = ClientActivityStatus.inactive;
          break;
      }
    }
    
    return Client(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      companyName: data['companyName'] ?? '',
      registrationNumber: data['registrationNumber'] ?? '',
      directors: directors,
      services: services,
      platforms: data['platforms'] is Map ? data['platforms'] as Map<String, dynamic> : {},
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastContact: data['lastContact'] != null 
          ? (data['lastContact'] as Timestamp).toDate()
          : null,
      notes: data['notes'] ?? '',
      expectedRevenue: (data['expectedRevenue'] ?? 0.0).toDouble(),
      actualRevenue: (data['actualRevenue'] ?? 0.0).toDouble(),
      taxDueDate: data['taxDueDate'] != null 
          ? (data['taxDueDate'] as Timestamp).toDate()
          : null,
      activityStatus: status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'companyName': companyName,
      'registrationNumber': registrationNumber,
      'directors': directors.map((d) => d.toMap()).toList(),
      'services': services.map((s) => s.toMap()).toList(),
      'platforms': platforms,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastContact': lastContact != null ? Timestamp.fromDate(lastContact!) : null,
      'notes': notes,
      'expectedRevenue': expectedRevenue,
      'actualRevenue': actualRevenue,
      'taxDueDate': taxDueDate != null ? Timestamp.fromDate(taxDueDate!) : null,
      'activityStatus': activityStatus.toString().split('.').last,
    };
  }
} 