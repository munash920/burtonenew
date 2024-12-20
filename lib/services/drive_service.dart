import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class DriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive.file',
      'https://www.googleapis.com/auth/drive.appdata',
    ],
  );

  // Upload file to Google Drive
  Future<Map<String, String>?> uploadFile(File file, String mimeType) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final auth = await account.authentication;
      final client = GoogleAuthClient(auth.accessToken!);
      final driveApi = drive.DriveApi(client);

      // Create file metadata
      final driveFile = drive.File()
        ..name = path.basename(file.path)
        ..mimeType = mimeType;

      // Upload file
      final response = await driveApi.files.create(
        driveFile,
        uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
        $fields: 'id,webViewLink',
      );

      // Set file permissions to anyone with link can view
      await driveApi.permissions.create(
        drive.Permission()
          ..role = 'reader'
          ..type = 'anyone',
        response.id!,
      );

      return {
        'id': response.id!,
        'url': response.webViewLink!,
      };
    } catch (e) {
      print('Error uploading to Drive: $e');
      return null;
    }
  }

  // Delete file from Google Drive
  Future<bool> deleteFile(String fileId) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return false;

      final auth = await account.authentication;
      final client = GoogleAuthClient(auth.accessToken!);
      final driveApi = drive.DriveApi(client);

      await driveApi.files.delete(fileId);
      return true;
    } catch (e) {
      print('Error deleting from Drive: $e');
      return false;
    }
  }
}

class GoogleAuthClient extends http.BaseClient {
  final String _accessToken;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _client.send(request);
  }
} 