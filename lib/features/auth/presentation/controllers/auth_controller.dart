import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_session.dart';
import '../providers/auth_providers.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);

class AuthController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() {
    final repository = ref.watch(authRepositoryProvider);
    final initial = Completer<AuthSession?>();
    final subscription = repository.authStateChanges().listen(
      (session) {
        if (initial.isCompleted) {
          state = AsyncData(session);
        } else {
          initial.complete(session);
        }
      },
      onError: (Object error, [StackTrace? stackTrace]) {
        final resolvedStackTrace = stackTrace ?? StackTrace.current;
        if (initial.isCompleted) {
          state = AsyncError(error, resolvedStackTrace);
        } else {
          initial.completeError(error, resolvedStackTrace);
        }
      },
    );
    ref.onDispose(subscription.cancel);
    return initial.future;
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      final session = await ref
          .read(signInUseCaseProvider)
          .call(email: email, password: password);
      state = AsyncData(session);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    final session = state.asData?.value;
    await ref.read(signOutUseCaseProvider).call(session);
    state = const AsyncData(null);
  }

  Future<void> selectActiveBranch({
    required String organizationId,
    required String branchId,
  }) async {
    final previous = state.asData?.value;
    if (previous == null) {
      return;
    }
    state = AsyncData(
      await ref
          .read(selectActiveBranchUseCaseProvider)
          .call(
            previous: previous,
            organizationId: organizationId,
            branchId: branchId,
          ),
    );
  }

  Future<void> refreshAccess() async {
    final previous = state.asData?.value;
    if (previous == null) {
      return;
    }
    try {
      state = AsyncData(
        await ref.read(refreshAccessUseCaseProvider).call(previous),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> sendPasswordResetEmail(String email) {
    return ref.read(sendPasswordResetUseCaseProvider).call(email);
  }
}
