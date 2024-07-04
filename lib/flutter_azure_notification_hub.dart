import 'flutter_azure_notification_hub_platform_interface.dart';

class FlutterAzureNotificationHub {
  static final _instance = FlutterAzureNotificationHub();

  static get instance => _instance;

  Future<void> start() {
    return FlutterAzureNotificationHubPlatform.instance.start();
  }
}
