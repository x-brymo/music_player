import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestAudioPermissions() async {
  var status = await Permission.microphone.status;

  if (!status.isGranted) {
    await Permission.microphone.request();
  }

  var storageStatus = await Permission.storage.status;

  if (!storageStatus.isGranted) {
    await Permission.storage.request();
  }
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2628637393.
  var notificationStatus = await Permission.notification.status;

  if (!notificationStatus.isGranted) {
    await Permission.notification.request();
  }
  var bluetoothStatus = await Permission.bluetooth.status;

  if (!bluetoothStatus.isGranted) {
    await Permission.bluetooth.request();
  }
  var audioStatus = await Permission.audio.status;

  if (!audioStatus.isGranted) {
    await Permission.audio.request();
  }

  
}

Future<bool> checkPermissionFor(Permission name) async {
  if (name == Permission.camera) {
    if (await Permission.camera.status.isDenied) {
      await Permission.camera.request();
    } else if (await Permission.camera.isPermanentlyDenied) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await openAppSettings();
      } else {
        await Permission.camera.request();
      }
    }
    return await Permission.camera.isGranted ||
        await Permission.photos.status.isLimited;
  } else if (name == Permission.photos) {
    if (await Permission.photos.status.isDenied) { // <<--- this returns "true"
      try {
        final PermissionStatus p = await Permission.photos.request();
        debugPrint('permission denied afteerr::  ${p.name}'); // << -- PermissionStatus with `name` argument "denied".
      } catch (e) {
        debugPrint('errr :: $e');
      }
    } else if (defaultTargetPlatform == TargetPlatform.android &&
        await Permission.photos.isPermanentlyDenied) {
      await openAppSettings();
    } else if (await Permission.photos.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for
      // this app. The only way to change the permission's status now is to let
      // the user manually enables it in the system settings.
      openAppSettings();
    }

    return await Permission.photos.status.isGranted ||
        await Permission.photos.status.isLimited;
  } else {
    return false;
  }
}