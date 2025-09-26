// lib/view/TelaHome.dart

import 'package:floworder/auxiliar/Cores.dart';
import 'package:floworder/controller/MesaController.dart';
import 'package:floworder/models/Mesa.dart';
import 'package:flutter/material.dart';
import 'TelaGerenciarMesa.dart'; 

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  final MesaController _mesaController = MesaController();

  // Função para determinar a cor do card com base no status da mesa
  Color _getMesaColor(String status) {
    switch (status) {
      case 'Ocupada':
      case 'Em Uso': 
        return Cores.primaryRed.withOpacity(0.5);
      case 'Reservada':
        return Cores.lightRed.withOpacity(0.5);
      case 'Livre':
      default:
        return Cores.cardBlack;
    }
  }

  // Card de mesa simplificado para a TelaHome
  Widget _buildMesaCard(BuildContext context, Mesa mesa) {
    final statusColor = _getMesaColor(mesa.status);

    return InkWell(
      onTap: () {
        // Navega para a nova tela de gerenciamento da mesa
        Navigator.push(
          context,
          MaterialPageRoute(
            // Passa a mesa para a próxima tela
            builder: (context) => TelaGerenciarMesa(mesa: mesa), 
          ),
        );
      },
      child: Card(
        color: statusColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Cores.borderGray, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.table_bar, color: Cores.textWhite, size: 40),
            const SizedBox(height: 8),
            Text(
              mesa.nome,
              style: TextStyle(
                color: Cores.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Cores.backgroundBlack.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                mesa.status,
                style: TextStyle(
                  color: Cores.textWhite,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.backgroundBlack,
      appBar: AppBar(
        // Removendo a BarraLateral e usando um AppBar simples para o título
        title: const Text(
          'Visão Geral do Estabelecimento - FlowOrder',
          style: TextStyle(
            color: Cores.textWhite,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false, // Remove a seta de voltar se for a rota principal
        backgroundColor: Cores.cardBlack, // Fundo do AppBar
        actions: [
          // Exemplo de botão de Logout (opcional)
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Cores.primaryRed),
            onPressed: () {
              // TODO: Implementar a lógica de Logout aqui
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ação de Logout (Para ser implementada)!')));
            },
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status das Mesas:',
              style: TextStyle(
                color: Cores.textGray,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: StreamBuilder<List<Mesa>>(
                stream: _mesaController.listarMesasTempoReal(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: Cores.primaryRed));
                  }

                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Erro ao carregar mesas: ${snapshot.error}',
                            style: TextStyle(color: Cores.primaryRed)));
                  }

                  final mesas = snapshot.data ?? [];

                  if (mesas.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma mesa cadastrada.',
                          style: TextStyle(color: Cores.textGray)),
                    );
                  }

                  // Layout de Grid para as Mesas
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5, // Número de colunas
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0, // Cards quadrados
                    ),
                    itemCount: mesas.length,
                    itemBuilder: (context, index) {
                      return _buildMesaCard(context, mesas[index]);
                    },
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