import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<PermissionStatus> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        // Android 13+
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
          Permission.videos,
        ].request();
        
        if (statuses[Permission.photos] == PermissionStatus.granted &&
            statuses[Permission.videos] == PermissionStatus.granted) {
          return PermissionStatus.granted;
        } else if (statuses[Permission.photos] == PermissionStatus.permanentlyDenied ||
                   statuses[Permission.videos] == PermissionStatus.permanentlyDenied) {
          return PermissionStatus.permanentlyDenied;
        }
        return PermissionStatus.denied;
      } else {
        // Android 12 and below
        return await Permission.storage.request();
      }
    } else if (Platform.isIOS) {
      return await Permission.photos.request();
    }
    return PermissionStatus.denied;
  }

  static Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        return await Permission.photos.isGranted && await Permission.videos.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    } else if (Platform.isIOS) {
      return await Permission.photos.isGranted;
    }
    return false;
  }
}
