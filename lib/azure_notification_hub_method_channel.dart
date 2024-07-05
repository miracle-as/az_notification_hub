import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'azure_notification_hub_platform_interface.dart';

@pragma('vm:entry-point')
void _messagingCallbackDispatcher() {
  // Initialize state necessary for MethodChannels.
  WidgetsFlutterBinding.ensureInitialized();

  const MethodChannel bgChannel = MethodChannel('plugins.flutter.io/azure_notification_hub_background');

  // This is where we handle background events from the native portion of the plugin.
  bgChannel.setMethodCallHandler((MethodCall call) async {
    if (call.method == 'AzRemoteMessageBackgroundWorker.onMessage') {
      final CallbackHandle handle = CallbackHandle.fromRawHandle(call.arguments['userCallbackHandle']);

      // PluginUtilities.getCallbackFromHandle performs a lookup based on the
      // callback handle and returns a tear-off of the original callback.
      final closure = PluginUtilities.getCallbackFromHandle(handle)! as BackgroundMessageHandler;

      try {
        await closure(Map<String, dynamic>.from(call.arguments['message']));
      } catch (e) {
        // ignore: avoid_print
        print('FANH: An error occurred in your background messaging handler:');
        // ignore: avoid_print
        print(e);
      }
    } else {
      throw UnimplementedError('${call.method} has not been implemented');
    }
  });

  // Once we've finished initializing, let the native portion of the plugin
  // know that it can start scheduling alarms.
  bgChannel.invokeMethod<void>('AzRemoteMessageBackgroundWorker.initialized');
}

/// An implementation of [AzureNotificationHubPlatform] that uses method channels.
class MethodChannelAzureNotificationHub extends AzureNotificationHubPlatform {
  static bool _bgHandlerInitialized = false;

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('plugins.flutter.io/azure_notification_hub');

  MethodChannelAzureNotificationHub() {
    methodChannel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'AzNotificationHub.onMessage':
          AzureNotificationHubPlatform.onMessage.add(Map<String, dynamic>.from(call.arguments));
          break;
        case 'AzNotificationHub.onMessageOpenedApp':
          AzureNotificationHubPlatform.onMessageOpenedApp.add(Map<String, dynamic>.from(call.arguments));
          break;
        default:
          throw UnimplementedError('${call.method} has not been implemented');
      }
    });
  }

  @override
  Future<void> registerBackgroundMessageHandler(BackgroundMessageHandler handler) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    if (!_bgHandlerInitialized) {
      _bgHandlerInitialized = true;
      final CallbackHandle bgHandle = PluginUtilities.getCallbackHandle(_messagingCallbackDispatcher)!;
      final CallbackHandle userHandle = PluginUtilities.getCallbackHandle(handler)!;
      await methodChannel.invokeMethod(
        'AzNotificationHub.startBackgroundIsolate',
        {
          'pluginCallbackHandle': bgHandle.toRawHandle(),
          'userCallbackHandle': userHandle.toRawHandle(),
        },
      );
    }
  }

  @override
  Future<void> start() {
    return methodChannel.invokeMethod<void>('AzNotificationHub.start');
  }

  @override
  Future<void> addTags(List<String> tags) {
    return methodChannel.invokeMethod<void>('AzNotificationHub.addTags', {'tags': tags});
  }

  @override
  Future<List<String>> getTags() async {
    final tags = await methodChannel.invokeListMethod<String>('AzNotificationHub.getTags');

    return tags ?? [];
  }

  @override
  Future<void> removeTags(List<String> tags) {
    return methodChannel.invokeMethod<void>('AzNotificationHub.removeTags', {'tags': tags});
  }

  @override
  Future<void> setTemplate(String body) {
    return methodChannel.invokeMethod<void>('AzNotificationHub.setTemplate', {'body': body});
  }

  @override
  Future<void> removeTemplate() {
    return methodChannel.invokeMethod<void>('AzNotificationHub.removeTemplate');
  }
}
