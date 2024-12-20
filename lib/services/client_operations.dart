import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/client.dart';

class ClientOperations {
  static Future<void> createClient(Client client) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final clientData = client.toMap();
    clientData['userId'] = userId;
    clientData['createdAt'] = FieldValue.serverTimestamp();

    await FirebaseFirestore.instance.collection('clients').add(clientData);
  }

  static Future<void> updateClient(String id, Map<String, dynamic> data) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    data['userId'] = userId;
    await FirebaseFirestore.instance.collection('clients').doc(id).update(data);
  }

  static Future<List<Client>> getClients() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final snapshot = await FirebaseFirestore.instance
        .collection('clients')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => Client.fromFirestore(doc)).toList();
  }

  static Future<Client?> getClient(String id) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc = await FirebaseFirestore.instance.collection('clients').doc(id).get();
    if (!doc.exists) return null;

    final client = Client.fromFirestore(doc);
    if (client.userId != userId) throw Exception('Access denied');

    return client;
  }

  static Future<void> deleteClient(String id) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc = await FirebaseFirestore.instance.collection('clients').doc(id).get();
    if (!doc.exists) throw Exception('Client not found');

    final client = Client.fromFirestore(doc);
    if (client.userId != userId) throw Exception('Access denied');

    await FirebaseFirestore.instance.collection('clients').doc(id).delete();
  }
} 