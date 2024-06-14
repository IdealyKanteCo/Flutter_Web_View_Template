import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  
  Future<void> handlePermission() async {
    if (await Permission.location.isDenied) {
      Permission.location.request();
    } else if (await Permission.location.isPermanentlyDenied) {
      openAppSettings();
    } else if (await Permission.location.isGranted) {
      getCurrentLocation();
    } else {
      requestLocationPermission();
    }
  }

  Future<void> requestLocationPermission() async {
    if (await Permission.location.request().isGranted) {
      getCurrentLocation();
    }
  }

  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print('Current location: $position');
  }
}