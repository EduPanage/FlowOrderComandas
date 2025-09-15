import 'package:flutter/material.dart';

class TelaHomeGarcom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Menu do Garçom")),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16),
        children: [
          _menuButton(context, "Cardápio", Icons.restaurant_menu, "/cardapio"),
          _menuButton(context, "Mesas", Icons.table_bar, "/mesas"),
          _menuButton(context, "Pedidos", Icons.receipt_long, "/pedidos"),
          _menuButton(context, "Sair", Icons.logout, "/telalogin"),
        ],
      ),
    );
  }

  Widget _menuButton(BuildContext context, String titulo, IconData icone, String rota) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, rota),
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 50, color: Colors.red),
            SizedBox(height: 10),
            Text(titulo, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}