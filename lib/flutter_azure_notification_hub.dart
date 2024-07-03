
import 'flutter_azure_notification_hub_platform_interface.dart';

class FlutterAzureNotificationHub {
  Future<String?> getPlatformVersion() {
    return FlutterAzureNotificationHubPlatform.instance.getPlatformVersion();
  }
}
