import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'awesome_bubble_platform_interface.dart';

/// An implementation of [BubblePlatform] that uses method channels.
class MethodChannelAwesomeBubble extends AwesomeBubblePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('bubble');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool?> initService({
    required double screenHeight,
    String? chatHeadIcon,
    String? notificationIcon,
    String? notificationTitle,
    int? notificationCircleHexColor,
    String? notificationBody,
  }) async {
    final enabled = await methodChannel.invokeMethod<bool>('initService', {
      'screenHeight': screenHeight,
      'chatHeadIcon': chatHeadIcon,
      'notificationIcon': notificationIcon,
      'notificationTitle': notificationTitle,
      'notificationCircleHexColor': notificationCircleHexColor,
      'notificationBody': notificationBody,
    });
    return enabled;
  }

  @override
  Future<bool?> startService({
    String? notificationTitle,
  }) async {
    final enabled = await methodChannel.invokeMethod<bool>('startService', {
      'notificationTitle': notificationTitle,
    });
    return enabled;
  }

  @override
  Future<bool?> stopService() async {
    final isDone = await methodChannel.invokeMethod<bool>('stopService');
    return isDone;
  }

  @override
  Future<bool?> checkPermission() async {
    final checkIsDone =
        await methodChannel.invokeMethod<bool>('checkPermission');
    return checkIsDone;
  }

  @override
  Future<bool?> askPermission() async {
    final askIsDone = await methodChannel.invokeMethod<bool>('askPermission');
    return askIsDone;
  }

  @override
  Future<bool?> clearServiceNotification() async {
    final isDone =
        await methodChannel.invokeMethod<bool>('clearServiceNotification');
    return isDone;
  }
}
