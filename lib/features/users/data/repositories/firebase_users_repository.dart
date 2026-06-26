import '../../../../shared/models/app_user.dart';
import '../../../../shared/models/business_context.dart';
import '../../domain/repositories/users_repository.dart';

class FirebaseUsersRepository implements UsersRepository {
  const FirebaseUsersRepository();

  @override
  Stream<List<AppUser>> watchUsers({required BusinessContext context}) {
    return const Stream<List<AppUser>>.empty();
  }
}
