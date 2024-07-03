import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_azure_notification_hub/flutter_azure_notification_hub.dart';
import 'package:flutter_azure_notification_hub/flutter_azure_notification_hub_platform_interface.dart';
import 'package:flutter_azure_notification_hub/flutter_azure_notification_hub_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterAzureNotificationHubPlatform
    with MockPlatformInterfaceMixin
    implements FlutterAzureNotificationHubPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterAzureNotificationHubPlatform initialPlatform = FlutterAzureNotificationHubPlatform.instance;

  test('$MethodChannelFlutterAzureNotificationHub is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterAzureNotificationHub>());
  });

  test('getPlatformVersion', () async {
    FlutterAzureNotificationHub flutterAzureNotificationHubPlugin = FlutterAzureNotificationHub();
    MockFlutterAzureNotificationHubPlatform fakePlatform = MockFlutterAzureNotificationHubPlatform();
    FlutterAzureNotificationHubPlatform.instance = fakePlatform;

    expect(await flutterAzureNotificationHubPlugin.getPlatformVersion(), '42');
  });
}
