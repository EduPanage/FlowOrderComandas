// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:floworder/firebase_options.dart';
import 'package:floworder/auxiliar/Cores.dart';
import 'package:floworder/view/Tela_Login.dart';
import 'package:floworder/view/TelaMesas.dart';
import 'package:floworder/view/TelaPedidos.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowOrder',
      theme: ThemeData(
        scaffoldBackgroundColor: Cores.backgroundBlack,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const TelaLogin(),
        '/mesas': (context) => const TelaMesas(),
        '/pedidos': (context) => const TelaPedidos(),
        // Adicione outras rotas conforme necessário, como a tela de cadastro
      },
      debugShowCheckedModeBanner: false,
    );
  }
}