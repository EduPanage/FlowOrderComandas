import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:floworder/view/TelaPedidos.dart'; // Importe a tela de login
import 'package:floworder/view/Tela_Login.dart'; // Importe a tela de pedidos

// Definindo as cores do tema para replicar a estética fornecida.
class Cores {
  static const Color backgroundBlack = Color(0xFF1C1C1C);
  static const Color primaryRed = Color(0xFFE53935);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF9E9E9E);
  static const Color cardColor = Color(0xFF2E2E2E);
  static const Color buttonColor = Color(0xFFFDD835); // Amarelo
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowOrder - Garçom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Cores.backgroundBlack,
        colorScheme: const ColorScheme.dark(
          primary: Cores.primaryRed,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Cores.textWhite),
          bodyMedium: TextStyle(color: Cores.textWhite),
          titleLarge: TextStyle(color: Cores.textWhite),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Cores.backgroundBlack,
          foregroundColor: Cores.textWhite,
        ),
      ),
      initialRoute: '/', // Define a tela de login como a tela inicial
      routes: {
        '/': (context) => Tela_Login(),
        /*
        '/mesas': (context) => MesasScreen(),*/
        '/pedidos': (context) => TelaPedidos(), // Rota para a tela de pedidos
      },
    );
  }
}
