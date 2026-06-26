import 'package:firebase_auth/firebase_auth.dart' as firebase;

import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/access_profile_repository.dart';
import '../../domain/repositories/active_context_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/device_registration_repository.dart';
import '../datasources/access_remote_data_source.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required firebase.FirebaseAuth firebaseAuth,
    required AccessProfileRepository accessProfileRepository,
    required ActiveContextRepository activeContextRepository,
    required DeviceRegistrationRepository deviceRegistrationRepository,
  }) : _firebaseAuth = firebaseAuth,
       _accessProfileRepository = accessProfileRepository,
       _activeContextRepository = activeContextRepository,
       _deviceRegistrationRepository = deviceRegistrationRepository;

  final firebase.FirebaseAuth _firebaseAuth;
  final AccessProfileRepository _accessProfileRepository;
  final ActiveContextRepository _activeContextRepository;
  final DeviceRegistrationRepository _deviceRegistrationRepository;

  AuthSession? _currentSession;

  @override
  Stream<AuthSession?> authStateChanges() {
    return _firebaseAuth.userChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        _currentSession = null;
        return null;
      }
      try {
        final session = await _resolve(firebaseUser, forceRefresh: false);
        _currentSession = session;
        await _deviceRegistrationRepository.register(session);
        return session;
      } catch (_) {
        _currentSession = null;
        await _firebaseAuth.signOut();
        rethrow;
      }
    });
  }

  @override
  Future<AuthSession> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException(
          'Firebase did not return an authenticated user.',
          code: 'missing-user',
        );
      }
      final session = await _resolve(firebaseUser, forceRefresh: true);
      _currentSession = session;
      await _deviceRegistrationRepository.register(session);
      return session;
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthException(
        _messageForFirebaseCode(error.code),
        code: error.code,
      );
    } on AccessProfileRejectedException catch (error) {
      await _firebaseAuth.signOut();
      throw AuthException(
        'This account is not authorized to use JCE POS.',
        code: error.reason,
      );
    } on StateError catch (error) {
      await _firebaseAuth.signOut();
      throw AuthException(
        error.message.toString(),
        code: 'no-active-assignment',
      );
    } on AuthException {
      await _firebaseAuth.signOut();
      rethrow;
    }
  }

  @override
  Future<AuthSession> selectActiveBranch({
    required String organizationId,
    required String branchId,
  }) async {
    final current = _currentSession;
    if (current == null) {
      throw const AuthException('Authentication is required.');
    }
    final updated = current.switchTo(
      organizationId: organizationId,
      branchId: branchId,
    );
    await _activeContextRepository.save(updated);
    _currentSession = updated;
    return updated;
  }

  @override
  Future<AuthSession> refreshAccess() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      throw const AuthException('Authentication is required.');
    }
    final session = await _resolve(firebaseUser, forceRefresh: true);
    _currentSession = session;
    return session;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthException(
        _messageForFirebaseCode(error.code),
        code: error.code,
      );
    }
  }

  @override
  Future<void> signOut() async {
    _currentSession = null;
    await _firebaseAuth.signOut();
  }

  Future<AuthSession> _resolve(
    firebase.User firebaseUser, {
    required bool forceRefresh,
  }) async {
    final email = firebaseUser.email?.trim();
    if (email == null || email.isEmpty) {
      throw const AuthException(
        'The Firebase account does not have an email address.',
        code: 'missing-email',
      );
    }
    final profile = await _accessProfileRepository.loadProfile(
      firebaseUid: firebaseUser.uid,
      email: email,
      forceRefresh: forceRefresh,
    );
    if (profile == null) {
      throw const AuthException(
        'No JCE POS application profile is assigned to this account.',
        code: 'profile-not-found',
      );
    }
    return _activeContextRepository.restore(profile);
  }

  String _messageForFirebaseCode(String code) {
    return switch (code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'Email or password is incorrect.',
      'user-disabled' => 'This Firebase account has been disabled.',
      'too-many-requests' =>
        'Too many attempts were made. Please wait before trying again.',
      'network-request-failed' =>
        'The network is unavailable. Connect once to authenticate this device.',
      'invalid-email' => 'Enter a valid email address.',
      _ => 'Authentication could not be completed.',
    };
  }
}
