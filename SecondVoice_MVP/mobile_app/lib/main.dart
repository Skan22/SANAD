import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/conversation_screen.dart';
import 'services/conversation_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SecondVoiceApp());
}

class SecondVoiceApp extends StatelessWidget {
  const SecondVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConversationProvider(),
      child: MaterialApp(
        title: 'Second Voice',
        debugShowCheckedModeBanner: false,
        theme: _buildDarkTheme(),
        home: const ConversationScreen(),
      ),
    );
  }

  /// Build high-contrast dark theme for accessibility
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0D1117),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00D4FF),      // Neon Blue
        secondary: Color(0xFFFF6B35),    // Sunset Orange
        surface: Color(0xFF161B22),
        onSurface: Colors.white,
        error: Color(0xFFFF6B6B),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF161B22),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: Color(0xFF00D4FF),
        thumbColor: Color(0xFF00D4FF),
        overlayColor: Color(0x2900D4FF),
      ),
    );
  }
}
