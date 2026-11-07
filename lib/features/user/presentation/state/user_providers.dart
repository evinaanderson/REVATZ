import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/user_usecases.dart';

class CurrentUserNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final result = await sl<GetCurrentUser>()(const NoParams());
    return result.valueOrNull; // en cas d'échec : considéré comme déconnecté
  }

  /// Retourne un message d'erreur, ou null si la connexion a réussi.
  Future<String?> signIn() async {
    final result = await sl<SignInWithGoogle>()(const NoParams());
    return result.when<String?>(
      success: (user) {
        state = AsyncData(user);
        return null;
      },
      failure: (f) => f.message,
    );
  }

  Future<void> signOut() async {
    await sl<SignOut>()(const NoParams());
    state = const AsyncData(null);
  }
}

final currentUserProvider =
    AsyncNotifierProvider<CurrentUserNotifier, User?>(CurrentUserNotifier.new);
