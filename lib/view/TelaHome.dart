import 'package:flutter/material.dart';
import '../auxiliar/Cores.dart';
import '../controller/MesaController.dart';
import '../models/Mesa.dart';
import 'TelaCriarPedido.dart'; 

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  final MesaController _mesaController = MesaController();
  final TextEditingController _searchController = TextEditingController();
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    // Lógica de filtro para a busca
    _searchController.addListener(() {
      setState(() {
        _filtro = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Novo método de navegação: abre a tela de criação de pedido para a Mesa
  void _abrirCriacaoPedido(Mesa mesa) {
    // Navega para a nova tela, passando a Mesa como argumento
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaCriarPedido(mesa: mesa),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.backgroundBlack,
      appBar: AppBar(
        title: Text('Selecione a Mesa', style: TextStyle(color: Cores.textWhite)),
        backgroundColor: Cores.backgroundBlack,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Cores.textWhite),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Cores.textWhite),
              decoration: InputDecoration(
                labelText: 'Buscar Mesa',
                labelStyle: TextStyle(color: Cores.textGray),
                prefixIcon: Icon(Icons.search, color: Cores.textGray),
                filled: true,
                fillColor: Cores.cardBlack,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Cores.borderGray),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Cores.borderGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Cores.primaryRed, width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Mesa>>(
              stream: _mesaController.listarMesasTempoReal(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Cores.primaryRed));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}', style: TextStyle(color: Cores.primaryRed)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Nenhuma mesa cadastrada.', style: TextStyle(color: Cores.textGray)));
                }

                final mesas = snapshot.data!
                    .where((mesa) => mesa.nome.toLowerCase().contains(_filtro.toLowerCase()))
                    .toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 colunas para focar no tablet/desktop
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: mesas.length,
                  itemBuilder: (context, index) {
                    final mesa = mesas[index];
                    return _buildMesaCard(context, mesa);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Card simplificado para o garçom
  Widget _buildMesaCard(BuildContext context, Mesa mesa) {
    Color statusColor;
    switch (mesa.status) {
      case 'Ocupada':
        statusColor = Cores.primaryRed;
        break;
      case 'Reservada':
        statusColor = Colors.orange;
        break;
      case 'Livre':
      default:
        statusColor = Colors.green;
        break;
    }

    return InkWell(
      onTap: () => _abrirCriacaoPedido(mesa),
      child: Card(
        color: Cores.cardBlack,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: statusColor, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.table_chart, color: statusColor, size: 48),
              const SizedBox(height: 8),
              Text(
                mesa.nome,
                style: TextStyle(
                  color: Cores.textWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                mesa.status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}