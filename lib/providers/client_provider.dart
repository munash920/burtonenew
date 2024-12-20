import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/firebase_service.dart';

class ClientProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  bool _isLoading = false;
  String? _error;
  List<Client> _clients = [];

  ClientProvider(this._firebaseService);

  List<Client> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadClients() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _clients = await _firebaseService.getClients();
    } catch (e) {
      _error = e.toString();
      print('Error loading clients: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createClient(Client client) async {
    try {
      await _firebaseService.createClient(client);
      await loadClients();
    } catch (e) {
      print('Error creating client: $e');
      rethrow;
    }
  }

  Future<void> updateClient(String id, Map<String, dynamic> data) async {
    try {
      await _firebaseService.updateClient(id, data);
      await loadClients();
    } catch (e) {
      print('Error updating client: $e');
      rethrow;
    }
  }

  Future<void> deleteClient(String id) async {
    try {
      await _firebaseService.deleteClient(id);
      await loadClients();
    } catch (e) {
      print('Error deleting client: $e');
      rethrow;
    }
  }

  Future<void> updateClientStatus(Client client, ClientActivityStatus newStatus) async {
    final index = _clients.indexWhere((c) => c.id == client.id);
    if (index != -1) {
      _clients[index].activityStatus = newStatus;
      await _firebaseService.updateClient(client.id, {'activityStatus': newStatus.name});
      notifyListeners();
    }
  }

  Future<void> updateClientStatusAndNotify(Client client, ClientActivityStatus newStatus) async {
    final index = _clients.indexWhere((c) => c.id == client.id);
    if (index != -1) {
      _clients[index].activityStatus = newStatus;
      await _firebaseService.updateClient(client.id, {'activityStatus': newStatus.name});
      notifyListeners();
    }
  }

  void addClients(List<Client> clients) {
    _clients.addAll(clients);
    notifyListeners();
  }
}