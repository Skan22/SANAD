import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/conversation_screen.dart';
import 'services/conversation_provider.dart';
import 'theme/app_theme.dart';

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
        theme: AppTheme.dark(),
        home: const ConversationScreen(),
      ),
    );
  }
}
