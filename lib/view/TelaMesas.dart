import 'package:flutter/material.dart';
import 'package:floworder/controller/MesaController.dart';
import 'package:floworder/models/Mesa.dart';
import 'package:floworder/view/TelaPedidos.dart';
import '../auxiliar/Cores.dart';
import 'BarraLateral.dart';

class TelaMesas extends StatefulWidget {
  const TelaMesas({Key? key}) : super(key: key);

  @override
  State<TelaMesas> createState() => _TelaMesasState();
}

class _TelaMesasState extends State<TelaMesas> {
  final MesaController _mesaController = MesaController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.backgroundBlack,
      body: Row(
        children: [
          const Barralateral(currentRoute: '/mesas'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mesas',
                    style: TextStyle(
                      color: Cores.textWhite,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _buildMesasGrid(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMesasGrid() {
    return StreamBuilder<List<Mesa>>(
      stream: _mesaController.streamMesas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Cores.primaryRed),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Erro ao carregar mesas: ${snapshot.error}",
              style: TextStyle(color: Cores.textGray),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.table_bar, size: 80, color: Cores.textGray),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma mesa encontrada',
                  style: TextStyle(color: Cores.textGray, fontSize: 18),
                ),
              ],
            ),
          );
        }

        final mesas = snapshot.data!;
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: mesas.length,
          itemBuilder: (context, index) {
            final mesa = mesas[index];
            return _buildMesaCard(mesa);
          },
        );
      },
    );
  }

  Widget _buildMesaCard(Mesa mesa) {
    return InkWell(
      onTap: () {
        // Redireciona para a TelaPedidos sem passar o parâmetro mesa
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TelaPedidos()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Cores.cardBlack,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Cores.borderGray),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Mesa ${mesa.numero}',
              style: TextStyle(
                color: Cores.textWhite,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mesa.nome,
              style: TextStyle(color: Cores.textGray),
            ),
          ],
        ),
      ),
    );
  }
}