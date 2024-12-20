import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/document_manager.dart';

class DocumentUploadButton extends StatelessWidget {
  final String clientId;
  final VoidCallback? onUploadComplete;
  final DocumentManager documentManager = DocumentManager();

  DocumentUploadButton({
    super.key,
    required this.clientId,
    this.onUploadComplete,
  });

  Future<void> _uploadDocument(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'xlsx', 'xls', 'doc', 'docx'],
      );

      if (result != null) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        final file = File(result.files.single.path!);
        final success = await documentManager.uploadClientDocument(clientId, file);

        // Hide loading indicator
        Navigator.pop(context);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
          onUploadComplete?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload document'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Hide loading indicator if visible
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading document: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _uploadDocument(context),
      icon: const Icon(Icons.upload_file),
      label: const Text('Upload Document'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
} 