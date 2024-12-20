import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'drive_service.dart';

class DocumentManager {
  final DriveService _driveService = DriveService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> uploadClientDocument(String clientId, File file) async {
    try {
      // Get mime type
      final mimeType = _getMimeType(file.path);
      
      // Upload to Drive
      final driveResult = await _driveService.uploadFile(file, mimeType);
      if (driveResult == null) return false;

      // Add reference to Firestore
      await _firestore.collection('clients').doc(clientId).update({
        'documents': FieldValue.arrayUnion([{
          'name': path.basename(file.path),
          'type': _getFileType(file.path),
          'driveFileId': driveResult['id'],
          'driveFileUrl': driveResult['url'],
          'uploadedAt': FieldValue.serverTimestamp(),
        }])
      });

      return true;
    } catch (e) {
      print('Error uploading document: $e');
      return false;
    }
  }

  Future<bool> deleteClientDocument(String clientId, Map<String, dynamic> document) async {
    try {
      // Delete from Drive
      final success = await _driveService.deleteFile(document['driveFileId']);
      if (!success) return false;

      // Remove reference from Firestore
      await _firestore.collection('clients').doc(clientId).update({
        'documents': FieldValue.arrayRemove([document])
      });

      return true;
    } catch (e) {
      print('Error deleting document: $e');
      return false;
    }
  }

  String _getMimeType(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    switch (ext) {
      case '.pdf':
        return 'application/pdf';
      case '.xlsx':
      case '.xls':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case '.doc':
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  String _getFileType(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    switch (ext) {
      case '.pdf':
        return 'pdf';
      case '.xlsx':
      case '.xls':
        return 'excel';
      case '.doc':
      case '.docx':
        return 'word';
      default:
        return 'other';
    }
  }
} 