import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  static FirebaseMessaging? _firebaseMessaging;

  static Future<void> init() async {
    try {
      // Initialize Firebase messaging if available
      _firebaseMessaging = FirebaseMessaging.instance;
      
      // Request permissions
      await _requestPermissions();
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Initialize Firebase messaging
      await _initializeFirebaseMessaging();
    } catch (e) {
      print('NotificationService init error: $e');
      // Continue without Firebase if it's not available
    }
  }

  static Future<void> _requestPermissions() async {
    try {
      if (_firebaseMessaging != null) {
        // Request FCM permissions
        NotificationSettings settings = await _firebaseMessaging!.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        print('Notification permission: ${settings.authorizationStatus}');
      }
    } catch (e) {
      print('Permission request error: $e');
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    try {
      const AndroidInitializationSettings androidSettings = 
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const DarwinInitializationSettings iosSettings = 
          DarwinInitializationSettings(
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true,
          );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
    } catch (e) {
      print('Local notifications init error: $e');
    }
  }

  static Future<void> _initializeFirebaseMessaging() async {
    try {
      if (_firebaseMessaging != null) {
        // Get FCM token
        String? token = await _firebaseMessaging!.getToken();
        print('FCM Token: $token');

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

        // Handle notification opened app
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpenedApp);
      }
    } catch (e) {
      print('Firebase messaging init error: $e');
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle local notification tap
    print('Local notification tapped: ${response.payload}');
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // Show local notification when app is in foreground
    await showLocalNotification(
      title: message.notification?.title ?? 'New Message',
      body: message.notification?.body ?? 'You have a new message',
      payload: message.data.toString(),
    );
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Handle background message
    print('Background message: ${message.messageId}');
  }

  static void _handleNotificationOpenedApp(RemoteMessage message) {
    // Handle notification that opened app
    print('Notification opened app: ${message.messageId}');
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = 
          AndroidNotificationDetails(
            'gig_marketplace_channel',
            'Gig Marketplace',
            channelDescription: 'Notifications for Gig Marketplace app',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: false,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(id, title, body, details, payload: payload);
    } catch (e) {
      print('Show notification error: $e');
    }
  }

  static Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging?.getToken();
    } catch (e) {
      print('Get FCM token error: $e');
      return null;
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging?.subscribeToTopic(topic);
    } catch (e) {
      print('Subscribe to topic error: $e');
    }
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging?.unsubscribeFromTopic(topic);
    } catch (e) {
      print('Unsubscribe from topic error: $e');
    }
  }
}