import '../../../../core/result/result.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Result<User>> signInWithGoogle();
  Future<Result<void>> signOut();
  Future<Result<User?>> getCurrentUser();
}
