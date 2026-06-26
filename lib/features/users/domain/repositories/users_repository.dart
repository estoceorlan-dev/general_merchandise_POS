import '../../../../shared/models/app_user.dart';
import '../../../../shared/models/business_context.dart';

abstract interface class UsersRepository {
  Stream<List<AppUser>> watchUsers({required BusinessContext context});
}
