import 'awesome_bubble_platform_interface.dart';

class AwesomeBubble {
  AwesomeBubble._();

  static AwesomeBubble I = AwesomeBubble._();

  Future<String?> getPlatformVersion() {
    return AwesomeBubblePlatform.instance.getPlatformVersion();
  }

  Future<bool?> initService({
    required double screenHeight,
    String? notificationIcon,
    String? chatHeadIcon,
    String? notificationTitle,

    /// For android 13, the notification icon appear inside the circle in notification center
    /// this prop allow you to change the color of this circle
    int? notificationCircleHexColor,
    String? notificationBody,
  }) {
    return AwesomeBubblePlatform.instance.initService(
      screenHeight: screenHeight,
      chatHeadIcon: chatHeadIcon,
      notificationIcon: notificationIcon,
      notificationTitle: notificationTitle,
      notificationCircleHexColor: notificationCircleHexColor,
      notificationBody: notificationBody,
    );
  }

  Future<bool?> startService({
    String? notificationTitle,
  }) {
    return AwesomeBubblePlatform.instance
        .startService(notificationTitle: notificationTitle);
  }

  Future<bool?> stopService() {
    return AwesomeBubblePlatform.instance.stopService();
  }

  Future<bool?> checkPermission() {
    return AwesomeBubblePlatform.instance.checkPermission();
  }

  Future<bool?> askPermission() {
    return AwesomeBubblePlatform.instance.askPermission();
  }

  Future<bool?> clearServiceNotification() {
    return AwesomeBubblePlatform.instance.clearServiceNotification();
  }
}
