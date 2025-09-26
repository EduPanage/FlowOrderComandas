import 'package:flutter/material.dart';
import '../auxiliar/Cores.dart';
import '../models/Mesa.dart';
import '../controller/CardapioController.dart'; 
import '../controller/PedidoController.dart';
import '../models/ItemCardapio.dart';
import '../models/Pedido.dart';

class TelaCriarPedido extends StatefulWidget {
  final Mesa mesa;

  // A mesa é obrigatória para esta tela
  const TelaCriarPedido({required this.mesa, super.key});

  @override
  State<TelaCriarPedido> createState() => _TelaCriarPedidoState();
}

class _TelaCriarPedidoState extends State<TelaCriarPedido> {

  final List<Map<String, dynamic>> _mockItensCardapio = [
    {'nome': 'Cheeseburger Clássico', 'preco': 25.00, 'uid': '1'},
    {'nome': 'Batata Frita Grande', 'preco': 15.00, 'uid': '2'},
    {'nome': 'Coca-Cola (Lata)', 'preco': 6.00, 'uid': '3'},
    {'nome': 'Pizza Margherita', 'preco': 45.00, 'uid': '4'},
    {'nome': 'Água Mineral', 'preco': 4.00, 'uid': '5'},
  ];

  // Lista de itens que o garçom adicionou ao pedido atual
  List<Map<String, dynamic>> _itensPedido = [];
  
  // Função de exemplo para adicionar um item ao pedido
  void _adicionarItem(Map<String, dynamic> item) {
    setState(() {
      _itensPedido.add(item);
    });
  }

  // Função de exemplo para remover um item
  void _removerItem(int index) {
    setState(() {
      _itensPedido.removeAt(index);
    });
  }
  
  // Função para calcular o total do pedido
  double get _totalPedido {
    return _itensPedido.fold(0.0, (sum, item) => sum + item['preco']);
  }

  // Lógica de salvar o pedido (substitua pela sua chamada ao PedidoController)
  void _salvarPedido() {
    if (_itensPedido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione itens ao pedido antes de salvar!')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pedido para Mesa ${widget.mesa.numero} salvo. Total: R\$ ${_totalPedido.toStringAsFixed(2)}'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Volta para a tela de seleção de mesas
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.backgroundBlack,
      appBar: AppBar(
        title: Text('Novo Pedido - Mesa ${widget.mesa.numero}',
            style: TextStyle(color: Cores.textWhite)),
        backgroundColor: Cores.cardBlack,
        elevation: 4,
      ),
      body: Row(
        children: [
          // COLUNA ESQUERDA: LISTA DE PRODUTOS (Cardápio)
          Expanded(
            flex: 2,
            child: Container(
              color: Cores.backgroundBlack,
              child: _buildCardapioLista(),
            ),
          ),
          
          // COLUNA DIREITA: PEDIDO ATUAL
          Expanded(
            flex: 1,
            child: Container(
              color: Cores.cardBlack, // Cor de fundo do painel do pedido
              child: _buildPedidoPainel(),
            ),
          ),
        ],
      ),
    );
  }
  
  // =========================================================================
  // Cardápio
  // =========================================================================

  Widget _buildCardapioLista() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockItensCardapio.length,
      itemBuilder: (context, index) {
        final item = _mockItensCardapio[index];
        return Card(
          color: Cores.backgroundBlack,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item['nome'], style: TextStyle(color: Cores.textWhite, fontWeight: FontWeight.bold)),
            subtitle: Text('R\$ ${item['preco'].toStringAsFixed(2)}', style: TextStyle(color: Cores.textGray)),
            trailing: IconButton(
              icon: Icon(Icons.add_circle, color: Cores.primaryRed, size: 30),
              onPressed: () => _adicionarItem(item),
            ),
            // Adicione uma linha divisória para melhor visualização
            shape: Border(bottom: BorderSide(color: Cores.borderGray.withOpacity(0.5))),
          ),
        );
      },
    );
  }

  // =========================================================================
  // Painel do Pedido
  // =========================================================================

  Widget _buildPedidoPainel() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Itens do Pedido',
            style: TextStyle(color: Cores.textWhite, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: _itensPedido.isEmpty
              ? Center(child: Text('Nenhum item adicionado.', style: TextStyle(color: Cores.textGray)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _itensPedido.length,
                  itemBuilder: (context, index) {
                    final item = _itensPedido[index];
                    return ListTile(
                      title: Text(item['nome'], style: TextStyle(color: Cores.textWhite)),
                      subtitle: Text('R\$ ${item['preco'].toStringAsFixed(2)}', style: TextStyle(color: Cores.textGray)),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle_outline, color: Cores.lightRed),
                        onPressed: () => _removerItem(index),
                      ),
                      dense: true,
                    );
                  },
                ),
        ),
        
        // Área do Total e Botão Salvar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Cores.borderGray)),
            color: Cores.cardBlack,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total:', style: TextStyle(color: Cores.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('R\$ ${_totalPedido.toStringAsFixed(2)}', style: TextStyle(color: Cores.primaryRed, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _salvarPedido,
                icon: const Icon(Icons.send),
                label: const Text('Enviar Pedido'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Cores.primaryRed,
                  foregroundColor: Cores.textWhite,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}