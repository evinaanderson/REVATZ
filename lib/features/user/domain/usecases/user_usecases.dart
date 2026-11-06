import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class SignInWithGoogle implements UseCase<User, NoParams> {
  final UserRepository _repository;
  SignInWithGoogle(this._repository);

  @override
  Future<Result<User>> call(NoParams params) => _repository.signInWithGoogle();
}

class SignOut implements UseCase<void, NoParams> {
  final UserRepository _repository;
  SignOut(this._repository);

  @override
  Future<Result<void>> call(NoParams params) => _repository.signOut();
}

class GetCurrentUser implements UseCase<User?, NoParams> {
  final UserRepository _repository;
  GetCurrentUser(this._repository);

  @override
  Future<Result<User?>> call(NoParams params) => _repository.getCurrentUser();
}
