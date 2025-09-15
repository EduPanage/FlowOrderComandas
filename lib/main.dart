import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Views que o garçom realmente usa
import 'package:floworder/view/TelaLogin.dart';
import 'package:floworder/view/TelaCardapio.dart';
import 'package:floworder/view/TelaMesa.dart';
import 'package:floworder/view/TelaPedido.dart';
import 'package:floworder/view/TelaHomeGarcom.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/telalogin', // começa pelo login do garçom
      routes: {
        '/telalogin': (context) => TelaLogin(),
        '/home': (context) => TelaHomeGarcom(),          // home do garçom
        /*'/cardapio': (context) => TelaCardapio(),  // visualizar cardápio
        '/mesas': (context) => TelaMesa(),         // escolher mesa
        '/pedidos': (context) => TelaPedido(),    // acompanhar pedidos*/
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
