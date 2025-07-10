import 'package:basic_flutter/login/sign_in.dart';
import 'package:basic_flutter/main.dart';
import 'package:basic_flutter/viewmodel/auth_viewmodel.dart';
import 'package:basic_flutter/viewmodel/membership_viewmodel.dart';
import 'package:basic_flutter/viewmodel/pay_viewmodel.dart';
import 'package:basic_flutter/viewmodel/person_viewmodel.dart';
import 'package:basic_flutter/viewmodel/promos_viewmodel.dart';
import 'package:basic_flutter/viewmodel/user_viewmodel.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

final authVM = AuthViewmodel();

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    _getFCMToken();
    _setupForegroundMessageListener(); // Aquí llamas a la función
  }

  void _setupForegroundMessageListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensaje recibido en primer plano: ${message.notification?.title}');

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }

  Future<void> _requestNotificationPermission() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permiso concedido para notificaciones');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('Permiso provisional para notificaciones');
    } else {
      print('Permiso denegado para notificaciones');
    }
  }

  Future<void> _getFCMToken() async {
    _fcmToken = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $_fcmToken');
    // Guarda el token si lo necesitas
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewmodel()),
        ChangeNotifierProvider(create: (_) => UserViewmodel()),
        ChangeNotifierProvider(create: (_) => PersonasViewModel()),
        ChangeNotifierProvider(create: (_) => MembershipViewmodel()),
        ChangeNotifierProvider(create: (_) => PromotionViewModel()),
        ChangeNotifierProvider(create: (_) => PayViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FitnestX',
        themeMode: ThemeMode.system,
        theme: ThemeData(
          colorScheme: ColorScheme.light(
            primary: Colors.lightBlue.shade300,
            secondary: Colors.lightBlue.shade300,
            surface: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.lightBlue.shade400,
            foregroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: Colors.lightBlue.shade100,
            iconTheme: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return IconThemeData(color: Colors.lightBlue.shade700);
              }
              return const IconThemeData(color: Colors.grey);
            }),
            labelTextStyle: MaterialStateProperty.all(
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 3,
            shadowColor: Colors.grey.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.lightBlue.shade700,
            foregroundColor: Colors.white,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.dark(
            primary: Colors.blueGrey.shade300,
            secondary: Colors.lightBlueAccent.shade100,
            surface: const Color(0xFF1E1E1E),
          ),
          scaffoldBackgroundColor: const Color(0xFF121212),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blueGrey.shade900,
            foregroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: const Color(0xFF1E1E1E),
            indicatorColor: Colors.blueGrey.shade900,
            iconTheme: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return IconThemeData(color: Colors.lightBlueAccent.shade100);
              }
              return const IconThemeData(color: Colors.grey);
            }),
            labelTextStyle: MaterialStateProperty.all(
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF1E1E1E),
            elevation: 3,
            shadowColor: Colors.black.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.lightBlueAccent.shade100,
            foregroundColor: Colors.black,
          ),
          useMaterial3: true,
        ),
        builder: (context, child) {
          final brightness = MediaQuery.platformBrightnessOf(context);
          final isDark = brightness == Brightness.dark;

          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor:
                  isDark ? const Color(0xFF1E1E1E) : Colors.white,
              systemNavigationBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
            ),
          );

          return child!;
        },
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', ''),
        ],
        home: StreamBuilder<Widget>(
          stream: authVM.userScreenStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              return snapshot.data!;
            }
            return const SignIn();
          },
        ),
      ),
    );
  }
}
