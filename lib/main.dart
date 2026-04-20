import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'app.dart';
import 'models/event.dart';
import 'models/birthday.dart';
import 'providers/event_provider.dart';
import 'services/notification_service.dart';
import 'services/local_storage_service.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final localStorageService = LocalStorageService();
  final notificationService = NotificationService();

  try {
    // Use bundled fonts on mobile/desktop, but allow web to fetch fonts
    // so startup does not depend on Flutter's asset manifest being ready.
    GoogleFonts.config.allowRuntimeFetching = kIsWeb;

    // Register Hive Adapters
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(EventAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(BirthdayAdapter());

    await localStorageService.init();
    await notificationService.init();
    await notificationService.cancelAllNotifications();

    for (final event in localStorageService.getAllEvents()) {
      await notificationService.scheduleEventNotification(event);
    }

    for (final birthday in localStorageService.getAllBirthdays()) {
      await notificationService.scheduleBirthdayNotification(birthday);
    }
  } catch (e) {
    debugPrint("Initialization error: $e");
  }

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(localStorageService),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const PlannerApp(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}
