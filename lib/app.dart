import 'package:basic_flutter/login/sign_in.dart';
import 'package:basic_flutter/main.dart';
import 'package:basic_flutter/services/api_services.dart';
import 'package:basic_flutter/services/gimnasio_services.dart';
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
  Future<void>? _precacheFuture;
  String? _fcmToken;
  bool _tokenEnviado = false;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    _setupForegroundMessageListener();

    FirebaseMessaging.instance.subscribeToTopic('general').then((_) {
      print('Suscrito al topic general');
    });

    _getFCMToken(); // Esta llamada ya es suficiente, no hace falta repetirla
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheFuture = _precacheImages();
  }

  Future<void> _getFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print('FCM Token: $token');
        await _sendToken(token);
      }
    } catch (e) {
      print('Error obteniendo o enviando token FCM: $e');
    }
  }

  Future<void> _sendToken(String token) async {
    try {
      bool success = await apiService.enviarTokenFCM(token);
      if (success) {
        print('Token enviado al backend correctamente');
      } else {
        print('Error al enviar el token al backend');
      }
    } catch (e) {
      print('Error enviando token al backend: $e');
    }
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

  Future<void> _precacheImages() async {
    await Future.wait([
      precacheImage(const AssetImage('assets/images/fondo1.webp'), context),
      precacheImage(const AssetImage('assets/images/fondo2.jpg'), context),
      precacheImage(const AssetImage('assets/images/fondo3.jpg'), context),
      precacheImage(const AssetImage('assets/images/fondo4.jpg'), context),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _precacheFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // Mostrar loader mientras se precargan imágenes
          return const Center(child: CircularProgressIndicator());
        }
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthViewmodel()),
            ChangeNotifierProvider(create: (_) => UserViewmodel()),
            ChangeNotifierProvider(create: (_) => PersonasViewModel()),
            ChangeNotifierProvider(create: (_) => MembershipViewmodel()),
            ChangeNotifierProvider(
              create: (_) => PromotionViewModel(GimnasioService()),
            ),
            ChangeNotifierProvider(create: (_) => PayViewModel()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'FitnestX',
            themeMode: ThemeMode.system,
            theme: ThemeData(
              colorScheme: ColorScheme.light(
                primary: Color(
                    0xFF1976D2), // Azul más profesional, ni pastel ni chillón
                secondary:
                    Color(0xFF64B5F6), // Azul claro pero con buen contraste
                surface: Colors.white,
              ),
              scaffoldBackgroundColor: const Color(
                  0xFFF0F2F5), // Gris muy suave, más cálido que blanco puro
              appBarTheme: AppBarTheme(
                backgroundColor: Color(0xFF1565C0), // Azul oscuro más elegante
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
                indicatorColor: Color(
                    0xFFBBDEFB), // Azul claro para indicador, sutil pero visible
                iconTheme: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return IconThemeData(color: Color(0xFF1976D2));
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
                backgroundColor: Color(0xFF1976D2),
                foregroundColor: Colors.white,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.dark(
                primary: Color(
                    0xFF455A64), // Azul grisáceo profundo, serio y profesional
                secondary:
                    Color(0xFF90CAF9), // Azul claro, sin ser pastel suave
                surface: const Color(
                    0xFF26292C), // Gris oscuro neutro, con calidez ligera
              ),
              scaffoldBackgroundColor:
                  const Color(0xFF121212), // Muy oscuro neutro, clásico
              appBarTheme: AppBarTheme(
                backgroundColor: const Color(0xFF263238), // Gris azulado oscuro
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
                backgroundColor: const Color(0xFF26292C),
                indicatorColor: Color(0xFF90CAF9)
                    .withOpacity(0.3), // Azul claro con opacidad
                iconTheme: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return IconThemeData(color: Color(0xFF90CAF9));
                  }
                  return const IconThemeData(color: Colors.grey);
                }),
                labelTextStyle: MaterialStateProperty.all(
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              cardTheme: CardThemeData(
                color: const Color(0xFF26292C),
                elevation: 3,
                shadowColor: Colors.black.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: Color(0xFF90CAF9),
                foregroundColor: Colors.black87,
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
      },
    );
  }
}
