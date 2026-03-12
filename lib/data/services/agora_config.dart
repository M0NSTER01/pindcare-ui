class AgoraConfig {
  AgoraConfig._();

  static const String appId = 'YOUR_AGORA_APP_ID';
  static const String token = ''; // fetch from backend in production

  /// Generate channel name from appointment ID
  static String channelName(String appointmentId) => 'consultation_$appointmentId';
}
