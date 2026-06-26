import '../entities/auth_session.dart';
import '../repositories/auth_audit_repository.dart';
import '../repositories/auth_repository.dart';

class SelectActiveBranchUseCase {
  const SelectActiveBranchUseCase({
    required AuthRepository authRepository,
    required AuthAuditRepository auditRepository,
  }) : _authRepository = authRepository,
       _auditRepository = auditRepository;

  final AuthRepository _authRepository;
  final AuthAuditRepository _auditRepository;

  Future<AuthSession> call({
    required AuthSession previous,
    required String organizationId,
    required String branchId,
  }) async {
    final current = await _authRepository.selectActiveBranch(
      organizationId: organizationId,
      branchId: branchId,
    );
    if (previous.activeOrganizationId != current.activeOrganizationId ||
        previous.activeBranchId != current.activeBranchId) {
      await _auditRepository.recordBranchSwitch(
        previous: previous,
        current: current,
      );
    }
    return current;
  }
}
