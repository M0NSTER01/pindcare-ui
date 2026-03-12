import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  PermissionService._();
  static final PermissionService instance = PermissionService._();

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    if (status.isGranted) return true;
    // Try media-specific for Android 13+
    final photos = await Permission.photos.request();
    return photos.isGranted;
  }

  Future<Map<Permission, bool>> requestAllVideoCallPermissions() async {
    final results = <Permission, bool>{};
    
    final camera = await Permission.camera.request();
    results[Permission.camera] = camera.isGranted;
    
    final mic = await Permission.microphone.request();
    results[Permission.microphone] = mic.isGranted;
    
    return results;
  }

  Future<PermissionStatus> checkAndRequestPermission(Permission permission) async {
    var status = await permission.status;
    if (status.isDenied) {
      status = await permission.request();
    }
    return status;
  }

  Future<bool> isPermissionGranted(Permission permission) async {
    return await permission.isGranted;
  }

  Future<bool> isPermissionPermanentlyDenied(Permission permission) async {
    return await permission.isPermanentlyDenied;
  }

  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
}
