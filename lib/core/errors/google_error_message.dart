import 'package:flutter/services.dart';

import 'failures.dart';

/// Transforme les erreurs de Google Sign-In (codes ApiException) en messages
/// lisibles qui indiquent quoi corriger.
Failure mapGoogleSignInError(Object e) {
  if (e is PlatformException) {
    final text = '${e.code} ${e.message ?? ''} ${e.details ?? ''}';
    bool has(String code) => RegExp('ApiException: $code\\b').hasMatch(text);

    if (e.code == 'network_error' || has('7')) return const NetworkFailure();
    if (has('10')) {
      return const AuthFailure(
          'Configuration Google invalide (code 10) : vérifiez le SHA-1 et le '
          'nom du package dans Google Cloud (voir README).');
    }
    if (has('12500')) {
      return const AuthFailure(
          'Connexion impossible (code 12500) : complétez l\'écran de '
          'consentement OAuth et ajoutez votre compte comme testeur.');
    }
    if (has('12501') || e.code == 'sign_in_canceled') {
      return const AuthFailure('Connexion annulée');
    }
    if (has('12502')) return const AuthFailure('Une connexion est déjà en cours');
    return AuthFailure('Connexion Google impossible : ${e.message ?? e.code}');
  }
  return UnknownFailure(e.toString());
}
