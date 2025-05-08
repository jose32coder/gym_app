import 'package:basic_flutter/layouts/navigation_menu.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MobileMend',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.lightBlue.shade700,
          secondary: Colors.lightBlue.shade300,
          background: const Color(0xFFF5F5F5),
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
        cardTheme: CardTheme(
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
          background: const Color(0xFF121212),
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
        cardTheme: CardTheme(
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


      home: const NavigationMenu(),
    );
  }
}
