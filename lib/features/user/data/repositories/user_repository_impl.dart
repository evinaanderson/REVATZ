import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/google_auth_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final GoogleAuthDataSource _auth;
  UserRepositoryImpl(this._auth);

  User _toUser(GoogleSignInAccount a) => User(
        id: a.id,
        name: a.displayName ?? a.email,
        email: a.email,
        photoUrl: a.photoUrl,
        createdAt: DateTime.now(),
      );

  Failure _map(Object e) {
    if (e is PlatformException) {
      if (e.code == 'network_error') return const NetworkFailure();
      return AuthFailure(e.message ?? 'Connexion Google impossible');
    }
    return UnknownFailure(e.toString());
  }

  @override
  Future<Result<User>> signInWithGoogle() async {
    try {
      final account = await _auth.signIn();
      if (account == null) return const Err(AuthFailure('Connexion annulée'));
      return Success(_toUser(account));
    } catch (e) {
      return Err(_map(e));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Success(null);
    } catch (e) {
      return Err(_map(e));
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final account = await _auth.currentAccount();
      return Success(account == null ? null : _toUser(account));
    } catch (e) {
      return Err(_map(e));
    }
  }
}
