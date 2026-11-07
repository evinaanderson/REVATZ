import 'dart:io';

import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/google_error_message.dart';
import '../../../user/data/datasources/google_auth_datasource.dart';

class BackupNotFoundException implements Exception {
  const BackupNotFoundException();
}

/// Convertit les erreurs techniques (Drive, réseau, fichiers) en [Failure].
Failure mapBackupError(Object e) {
  if (e is Failure) return e;
  if (e is AuthRequiredException) {
    return const AuthFailure('Connexion Google requise (onglet Profil)');
  }
  if (e is BackupNotFoundException) {
    return const NotFoundFailure('Aucune sauvegarde trouvée sur Google Drive');
  }
  if (e is drive.DetailedApiRequestError) {
    if (e.status == 401) {
      return const AuthFailure('Session Google expirée : reconnectez-vous');
    }
    if (e.status == 403) {
      final reasons = e.errors.map((x) => x.reason).toList();
      if (reasons.contains('storageQuotaExceeded')) return const StorageFullFailure();
      if (reasons.contains('accessNotConfigured') ||
          '${e.message}'.contains('has not been used')) {
        return const AuthFailure(
            'L\'API Google Drive n\'est pas activée dans Google Cloud (voir README)');
      }
      return const AuthFailure(
          'Accès Drive refusé : vérifiez le scope drive.file et l\'écran de consentement');
    }
    return UnknownFailure(e.message ?? 'Erreur Google Drive (${e.status})');
  }
  if (e is SocketException || e is http.ClientException) {
    return const NetworkFailure();
  }
  if (e is PlatformException) return mapGoogleSignInError(e);
  if (e is FileSystemException) {
    return FileFailure('Erreur de fichier : ${e.osError?.message ?? e.message}');
  }
  if (e is FormatException) {
    return const FileFailure('Fichier invalide : sermon.json est absent ou corrompu');
  }
  return UnknownFailure(e.toString());
}
