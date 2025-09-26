import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart'; // Importa o núcleo do Firebase
import 'firebase_options.dart';
import 'view/Tela_Login.dart';
import 'view/TelaHome.dart';
import 'view/TelaPedidos.dart';
import 'view/TelaMesas.dart';
import 'view/TelaCardapio.dart';

// O ponto de entrada principal do aplicativo.
void main() async {
  // Garante que o Flutter e o Firebase estão prontos antes de iniciar
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
      title: 'FlowOrder',
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
        '/home': (context) => TelaHome(),
        '/pedidos': (context) => TelaPedidos(),
        '/mesas': (context) => MesasScreen(),
        '/cardapio': (context) => TelaCardapio(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => Tela_Login());
          case '/home':
            return MaterialPageRoute(builder: (context) => TelaHome());
          case '/pedidos':
            return MaterialPageRoute(builder: (context) => TelaPedidos());
          case '/mesas':
            return MaterialPageRoute(builder: (context) => MesasScreen());
          case '/cardapio':
            return MaterialPageRoute(builder: (context) => TelaCardapio());
          default:
            return null;
        }
      },
    );
  }
}
