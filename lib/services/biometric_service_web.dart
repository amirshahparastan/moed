/// Chrome preview does not perform real biometric authentication.
class BiometricService {
  Future<bool> supported() async => false;
  Future<bool> authenticate() async => true;
}
