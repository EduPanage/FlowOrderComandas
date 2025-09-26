import 'package:flutter/material.dart';
import 'package:floworder/auxiliar/Cores.dart';

class TelaCardapio extends StatefulWidget {
  const TelaCardapio({super.key});

  @override
  State<TelaCardapio> createState() => _TelaCardapioState();
}

class _TelaCardapioState extends State<TelaCardapio> {
  // Mock data for demonstration
  final List<Map<String, dynamic>> _cardapios = [
    {
      'nome': 'Burgers & Sandwiches',
      'descricao': 'Juicy burgers and classic sandwiches.',
      'ativo': true,
      'uid': '1',
    },
    {
      'nome': 'Pizzas',
      'descricao': 'Hand-tossed pizzas with fresh toppings.',
      'ativo': true,
      'uid': '2',
    },
    {
      'nome': 'Drinks & Beverages',
      'descricao': 'Refreshing sodas, juices, and more.',
      'ativo': false,
      'uid': '3',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.backgroundBlack,
      appBar: AppBar(
        title: const Text('Gerenciar Cardápios', style: TextStyle(color: Cores.textWhite)),
        backgroundColor: Cores.backgroundBlack,
        iconTheme: const IconThemeData(color: Cores.textWhite),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: Cores.textWhite),
              label: const Text('Adicionar Novo Cardápio', style: TextStyle(color: Cores.textWhite)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Cores.primaryRed,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _cardapios.length,
                itemBuilder: (context, index) {
                  final cardapio = _cardapios[index];
                  return Card(
                    color: Cores.cardBlack,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(cardapio['nome'], style: TextStyle(color: Cores.textWhite)),
                      subtitle: Text(cardapio['descricao'], style: TextStyle(color: Cores.textGray)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Cores.lightRed),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Cores.primaryRed),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
