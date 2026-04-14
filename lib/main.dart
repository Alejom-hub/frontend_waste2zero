import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Fuerza orientación vertical
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const Waste2ZeroApp());
}

class Waste2ZeroApp extends StatelessWidget {
  const Waste2ZeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waste2Zero',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
        ),
        fontFamily: 'Nunito',
        scaffoldBackgroundColor: AppColors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textDark,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
