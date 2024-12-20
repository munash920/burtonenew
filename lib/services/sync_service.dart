import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Database> _getDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'app_data.db');
    return openDatabase(path);
  }

  Future<void> syncToCloud() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final db = await _getDatabase();
    final localData = await db.query('data');

    // Create a batch write operation
    final batch = _firestore.batch();
    final syncRef = _firestore.collection('users').doc(userId).collection('sync_data');

    // Upload each local record to Firestore
    for (var record in localData) {
      final docRef = syncRef.doc(record['id'].toString());
      batch.set(docRef, {
        'content': record['content'],
        'lastSync': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<void> syncFromCloud() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final db = await _getDatabase();
    final syncRef = _firestore.collection('users').doc(userId).collection('sync_data');
    
    // Get all cloud data
    final cloudData = await syncRef.get();

    // Begin transaction
    await db.transaction((txn) async {
      // Update local database with cloud data
      for (var doc in cloudData.docs) {
        await txn.insert(
          'data',
          {
            'id': int.parse(doc.id),
            'content': doc.data()['content'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> fullSync() async {
    try {
      await syncToCloud();
      await syncFromCloud();
    } catch (e) {
      throw Exception('Sync failed: ${e.toString()}');
    }
  }
}
