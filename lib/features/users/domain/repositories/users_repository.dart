import '../../../../shared/models/app_user.dart';

abstract interface class UsersRepository {
  Stream<List<AppUser>> watchUsers({String? branchId});
}
