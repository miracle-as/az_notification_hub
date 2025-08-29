# AI Coding Instructions for Azure Notification Hub Flutter Plugin

## Project Overview

This is a Flutter plugin (`az_notification_hub`) that bridges Azure Notification Hubs to Flutter apps for cross-platform push notifications. The plugin uses method channels to communicate between Dart and platform-specific code (Android Kotlin, iOS Swift).

## Architecture Patterns

### Core Plugin Structure

- **Main API**: `AzureNotificationHub` singleton in `lib/az_notification_hub.dart` - the public interface
- **Platform Interface**: `AzureNotificationHubPlatform` in `lib/az_notification_hub_platform_interface.dart` - abstract base class
- **Method Channel Implementation**: `MethodChannelAzureNotificationHub` in `lib/az_notification_hub_method_channel.dart` - concrete platform bridge

### Method Channel Communication

The plugin uses Flutter's method channels with the identifier `plugins.flutter.io/azure_notification_hub`:

- **From Dart to Native**: Method calls like `AzNotificationHub.start`, `AzNotificationHub.addTags`
- **From Native to Dart**: Callbacks like `AzNotificationHub.onMessage`, `AzNotificationHub.onMessageOpenedApp`

### Background Message Handling

Android requires a separate isolate for background message processing:

- Background handler must be a top-level function decorated with `@pragma('vm:entry-point')`
- Uses `_messagingCallbackDispatcher()` in method channel implementation
- iOS handles background messages directly in the main isolate

### Platform-Specific Implementations

#### Android (`android/src/main/kotlin/`)

- **Main Plugin**: `AzureNotificationHubPlugin.kt` - implements FlutterPlugin, MethodCallHandler, ActivityAware
- **Background Worker**: `AzRemoteMessageBackgroundWorker.kt` - handles isolate-based background processing
- **LiveData**: `AzRemoteMessageLiveData.kt` - observes foreground messages
- **Extensions**: `RemoteMessageExtensions.kt` - converts Firebase RemoteMessage to Map

#### iOS (`ios/Classes/`)

- **Main Plugin**: `AzureNotificationHubPlugin.swift` - implements FlutterPlugin, MSNotificationHubDelegate
- Uses Azure's `WindowsAzureMessaging` SDK directly
- Handles notification state tracking with completion handlers

## Key Configuration Requirements

### Android Setup Dependencies

1. Firebase project with `google-services.json` in `android/app/`
2. Google Services plugin in `android/settings.gradle` and `android/app/build.gradle`
3. Azure configuration in `AndroidManifest.xml`:
   ```xml
   <meta-data android:name="NotificationHubName" android:value="..." />
   <meta-data android:name="NotificationHubConnectionString" android:value="Endpoint=sb://..." />
   ```

### iOS Setup Dependencies

1. Azure configuration in `Info.plist`:
   ```xml
   <key>NotificationHubName</key>
   <key>NotificationHubConnectionString</key>
   ```
2. Push Notifications capability in Xcode
3. AppDelegate configuration for UNUserNotificationCenter

## Template System

- Uses single template named `DEFAULT_TEMPLATE_NAME = "FANH DEFAULT TEMPLATE"`
- Platform-specific template bodies defined in example app's `_platformTemplates` map
- Templates use Azure's expression language with `\$(variable)` syntax

## Stream-Based Event Handling

- **Foreground Messages**: `onMessage` stream via static StreamController
- **App Opened Messages**: `onMessageOpenedApp` stream with initial message support
- Both use broadcast streams allowing multiple listeners

## Development Patterns

### Adding New Features

1. Add method to `AzureNotificationHubPlatform` abstract class
2. Implement in `MethodChannelAzureNotificationHub`
3. Add platform-specific implementations in Android/iOS
4. Update public API in `AzureNotificationHub` class

### Testing with Example App

- Example app in `example/` directory demonstrates all plugin features
- Shows proper initialization sequence: `registerBackgroundMessageHandler()` → `start()`
- Demonstrates tag management UI and template setup

### Common Method Channel Methods

- `AzNotificationHub.start` - Initialize hub connection
- `AzNotificationHub.addTags/removeTags/clearTags/getTags` - Tag management
- `AzNotificationHub.setTemplate/removeTemplate` - Template management
- `AzNotificationHub.startBackgroundIsolate` - Android background setup
- `AzNotificationHub.getInitialMessage` - Android cold start message retrieval

## Dependencies

- **Flutter**: `permission_handler` for notification permissions
- **Android**: Microsoft Azure Notification Hubs SDK, Firebase Cloud Messaging
- **iOS**: WindowsAzureMessaging framework

## Critical Initialization Order

```dart
WidgetsFlutterBinding.ensureInitialized();
AzureNotificationHub.instance.registerBackgroundMessageHandler(handler);
await AzureNotificationHub.instance.start();
```
