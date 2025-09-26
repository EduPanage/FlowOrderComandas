import 'package:flutter/material.dart';
import '../auxiliar/Cores.dart';
import '../controller/MesaController.dart';
import '../models/Mesa.dart';
import 'TelaPedidos.dart'; // Mantido como TelaPedidos.dart

class MesasScreen extends StatefulWidget {
  @override
  _MesasScreenState createState() => _MesasScreenState();
}

class _MesasScreenState extends State<MesasScreen> {
  final MesaController _mesaController = MesaController();
  final TextEditingController _searchController = TextEditingController();
  String _filtro = '';

  @override
  void initState() {
    super.initState();
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

  void _abrirPedido(BuildContext context, Mesa mesa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // CORREÇÃO 1: 'PedidoScreen' alterado para 'TelaPedidos'
        builder: (context) => TelaPedidos(mesa: mesa),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usa a cor de fundo preta da classe Cores
      backgroundColor: Cores.backgroundBlack,
      appBar: AppBar(
        title: Text('Mesas', style: TextStyle(color: Cores.textWhite)),
        // Usa a cor de fundo preta da classe Cores
        backgroundColor: Cores.backgroundBlack,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Cores.textWhite),
            onPressed: () {
            },
          ),
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
                // Usa a cor de fundo do card
                fillColor: Cores.cardBlack,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  // Usa a cor da borda
                  borderSide: BorderSide(color: Cores.borderGray),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  // Usa a cor da borda
                  borderSide: BorderSide(color: Cores.borderGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  // Usa a cor vermelha principal para o foco
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
                  return Center(
                    // Usa a cor de texto branca
                    child: CircularProgressIndicator(color: Cores.textWhite),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro: ${snapshot.error}',
                      style: TextStyle(color: Cores.primaryRed),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhuma mesa encontrada.',
                      style: TextStyle(color: Cores.textGray),
                    ),
                  );
                }

                final mesas = snapshot.data!
                    .where((mesa) => mesa.nome
                        .toLowerCase()
                        .contains(_filtro.toLowerCase()))
                    .toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    childAspectRatio: 0.8,
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

  Widget _buildMesaCard(BuildContext context, Mesa mesa) {
    return InkWell(
      onTap: () => _abrirPedido(context, mesa),
      child: Card(
        // Usa a cor de fundo do card
        color: Cores.cardBlack,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Cores.primaryRed.withOpacity(0.5), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Usa a cor vermelha principal para o ícone
              Icon(Icons.table_chart, color: Cores.primaryRed, size: 48),
              SizedBox(height: 8),
              Text(
                mesa.nome,
                style: TextStyle(
                  // Usa a cor de texto branca
                  color: Cores.textWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                'Número: ${mesa.numero}',
                style: TextStyle(
                  // Usa a cor de texto cinza
                  color: Cores.textGray,
                  fontSize: 14,
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