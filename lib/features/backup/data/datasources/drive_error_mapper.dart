import 'dart:io';

import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import '../../../../core/errors/failures.dart';
import '../../../user/data/datasources/google_auth_datasource.dart';

class BackupNotFoundException implements Exception {
  const BackupNotFoundException();
}

/// Convertit les erreurs techniques (Drive, réseau, fichiers) en [Failure].
Failure mapBackupError(Object e) {
  if (e is Failure) return e;
  if (e is AuthRequiredException) return const AuthFailure();
  if (e is BackupNotFoundException) {
    return const NotFoundFailure('Aucune sauvegarde trouvée sur Google Drive');
  }
  if (e is drive.DetailedApiRequestError) {
    if (e.status == 401) return const AuthFailure();
    if (e.status == 403) {
      final quota = e.errors.any((x) => x.reason == 'storageQuotaExceeded');
      return quota
          ? const StorageFullFailure()
          : const AuthFailure('Autorisation Google Drive refusée');
    }
    return UnknownFailure(e.message ?? 'Erreur Google Drive');
  }
  if (e is SocketException || e is http.ClientException) {
    return const NetworkFailure();
  }
  if (e is PlatformException) {
    return e.code == 'network_error'
        ? const NetworkFailure()
        : AuthFailure(e.message ?? 'Erreur d\'authentification');
  }
  if (e is FileSystemException) return const FileFailure();
  if (e is FormatException) return const FileFailure('Sauvegarde invalide ou corrompue');
  return UnknownFailure(e.toString());
}
