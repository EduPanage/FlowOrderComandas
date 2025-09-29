import 'package:floworder/view/TelaGarcom.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'view/Tela_Login.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const FlowOrderGarcomApp();
  }
}

class Cores {
  static const Color backgroundBlack = Color(0xFF1C1C1C);
  static const Color primaryRed = Color(0xFFE53935);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF9E9E9E);
}

class FlowOrderGarcomApp extends StatelessWidget {
  const FlowOrderGarcomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlowOrder - Garçom',
      theme: ThemeData(
        scaffoldBackgroundColor: Cores.backgroundBlack,
        colorScheme: const ColorScheme.dark(
          primary: Cores.primaryRed,
          background: Cores.backgroundBlack,
          onBackground: Cores.textWhite,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Tela_Login(),
        '/home': (context) => TelaGarcom(),
      },

    );
  }
}
