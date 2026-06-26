import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/device_registration_repository.dart';

class DemoDeviceRegistrationRepository implements DeviceRegistrationRepository {
  const DemoDeviceRegistrationRepository();

  @override
  Future<String> deviceId() async => 'demo-device';

  @override
  Future<void> register(AuthSession session) async {}
}
