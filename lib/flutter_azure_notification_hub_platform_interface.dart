import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_azure_notification_hub_method_channel.dart';

abstract class FlutterAzureNotificationHubPlatform extends PlatformInterface {
  /// Constructs a FlutterAzureNotificationHubPlatform.
  FlutterAzureNotificationHubPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterAzureNotificationHubPlatform _instance = MethodChannelFlutterAzureNotificationHub();

  /// The default instance of [FlutterAzureNotificationHubPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterAzureNotificationHub].
  static FlutterAzureNotificationHubPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterAzureNotificationHubPlatform] when
  /// they register themselves.
  static set instance(FlutterAzureNotificationHubPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
