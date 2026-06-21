import '../../../../shared/models/app_user.dart';
import '../../domain/repositories/users_repository.dart';

class FirebaseUsersRepository implements UsersRepository {
  const FirebaseUsersRepository();

  @override
  Stream<List<AppUser>> watchUsers({String? branchId}) {
    return const Stream<List<AppUser>>.empty();
  }
}
