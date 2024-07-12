import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'azure_notification_hub_method_channel.dart';

typedef BackgroundMessageHandler = Future<void> Function(Map<String, dynamic> message);

abstract class AzureNotificationHubPlatform extends PlatformInterface {
  /// Constructs a AzureNotificationHubPlatform.
  AzureNotificationHubPlatform() : super(token: _token);

  static final Object _token = Object();

  static AzureNotificationHubPlatform _instance = MethodChannelAzureNotificationHub();

  /// The default instance of [AzureNotificationHubPlatform] to use.
  ///
  /// Defaults to [MethodChannelAzureNotificationHub].
  static AzureNotificationHubPlatform get instance => _instance;

  static final StreamController<Map<String, dynamic>> onMessage = StreamController<Map<String, dynamic>>.broadcast();

  static final StreamController<Map<String, dynamic>> onMessageOpenedApp =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AzureNotificationHubPlatform] when
  /// they register themselves.
  static set instance(AzureNotificationHubPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> registerBackgroundMessageHandler(BackgroundMessageHandler handler) {
    throw UnimplementedError('registerBackgroundMessageHandler() has not been implemented.');
  }

  Future<void> start() {
    throw UnimplementedError('start() has not been implemented.');
  }

  Future<bool> addTags(List<String> tags) {
    throw UnimplementedError('addTags() has not been implemented.');
  }

  Future<List<String>> getTags() {
    throw UnimplementedError('getTags() has not been implemented.');
  }

  Future<bool> removeTags(List<String> tags) {
    throw UnimplementedError('removeTags() has not been implemented.');
  }

  Future<bool> setTemplate(String body) {
    throw UnimplementedError('setTemplate() has not been implemented.');
  }

  Future<bool> removeTemplate() {
    throw UnimplementedError('removeTemplate() has not been implemented.');
  }
}
