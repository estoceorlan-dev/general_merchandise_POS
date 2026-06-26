import '../repositories/admin_bootstrap_repository.dart';

class CreateTemporaryAdminAccountUseCase {
  const CreateTemporaryAdminAccountUseCase(this._repository);

  final AdminBootstrapRepository _repository;

  Future<AdminBootstrapResult> call() {
    return _repository.createTemporaryAdminAccount();
  }
}
