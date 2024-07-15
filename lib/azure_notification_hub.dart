import 'package:permission_handler/permission_handler.dart';

import 'azure_notification_hub_platform_interface.dart';

class AzureNotificationHub {
  static final _instance = AzureNotificationHub();

  static AzureNotificationHub get instance => _instance;

  Stream<Map<String, dynamic>> get onMessage => AzureNotificationHubPlatform.onMessage.stream;

  Stream<Map<String, dynamic>> get onMessageOpenedApp => AzureNotificationHubPlatform.onMessageOpenedApp.stream;

  Future<void> registerBackgroundMessageHandler(BackgroundMessageHandler handler) {
    return AzureNotificationHubPlatform.instance.registerBackgroundMessageHandler(handler);
  }

  Future<void> start() async {
    await Permission.notification.request();

    return await AzureNotificationHubPlatform.instance.start();
  }

  Future<bool> addTags(List<String> tags) {
    return AzureNotificationHubPlatform.instance.addTags(tags);
  }

  Future<List<String>> getTags() {
    return AzureNotificationHubPlatform.instance.getTags();
  }

  Future<bool> removeTags(List<String> tags) {
    return AzureNotificationHubPlatform.instance.removeTags(tags);
  }

  Future<void> clearTags() {
    return AzureNotificationHubPlatform.instance.clearTags();
  }

  Future<bool> setTemplate(String body) {
    return AzureNotificationHubPlatform.instance.setTemplate(body);
  }

  Future<bool> removeTemplate() {
    return AzureNotificationHubPlatform.instance.removeTemplate();
  }
}
