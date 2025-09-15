import 'package:flutter/material.dart';
import '../firebase/UsuarioFirebase.dart';

class TelaLogin extends StatefulWidget {
  @override
  _TelaLoginState createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _carregando = false;

  void _login() async {
    setState(() => _carregando = true);

    /*try {
      await UsuarioFirebase().login(
        _emailController.text,
        _senhaController.text,
      );
      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro no login: $e")),
      );
    }
    */
    setState(() => _carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login do Garçom")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: _senhaController, decoration: InputDecoration(labelText: "Senha"), obscureText: true),
            SizedBox(height: 20),
            _carregando
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _login,
              child: Text("Entrar"),
            ),
          ],
        ),
      ),
    );
  }
}