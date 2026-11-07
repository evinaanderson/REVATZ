import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class AuthRequiredException implements Exception {
  const AuthRequiredException();
}

/// Connexion Google + client authentifié pour l'API Drive.
/// Le scope `drive.file` limite l'accès aux fichiers créés par l'app.
class GoogleAuthDataSource {
  final GoogleSignIn _googleSignIn;

  GoogleAuthDataSource([GoogleSignIn? googleSignIn])
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(scopes: [drive.DriveApi.driveFileScope]);

  Future<GoogleSignInAccount?> signIn() => _googleSignIn.signIn();

  Future<GoogleSignInAccount?> currentAccount() async =>
      _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();

  Future<void> signOut() => _googleSignIn.signOut();

  Future<drive.DriveApi> getDriveApi() async {
    final account = await currentAccount() ?? await _googleSignIn.signIn();
    if (account == null) throw const AuthRequiredException();
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) throw const AuthRequiredException();
    return drive.DriveApi(client);
  }
}
