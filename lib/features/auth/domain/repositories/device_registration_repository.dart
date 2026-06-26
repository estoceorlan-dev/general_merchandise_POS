import '../entities/auth_session.dart';

abstract interface class DeviceRegistrationRepository {
  Future<String> deviceId();
  Future<void> register(AuthSession session);
}
