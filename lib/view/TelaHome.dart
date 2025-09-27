// lib/view/TelaHome.dart

import 'package:floworder/auxiliar/Cores.dart';
import 'package:floworder/controller/MesaController.dart';
import 'package:floworder/models/Mesa.dart';
import 'package:flutter/material.dart';
import 'TelaGerenciarMesa.dart';
import '../firebase/LoginFirebase.dart';
import '../auxiliar/WidgetAuxiliar.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  final MesaController _mesaController = MesaController();
  final LoginFirebase _loginFirebase = LoginFirebase();
  String _filtroStatus = 'Todos'; // Variável de estado para o filtro

  // Função para construir o Chip de filtro
  Widget _buildFilterChip(String status) {
    final bool isSelected = _filtroStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(status),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _filtroStatus = status;
            });
          }
        },
        selectedColor: Cores.primaryRed,
        backgroundColor: Cores.cardBlack,
        labelStyle: TextStyle(
          color: isSelected ? Cores.textWhite : Cores.textGray,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Cores.primaryRed : Cores.borderGray,
          ),
        ),
      ),
    );
  }

  // Widget para exibir o sumário e os filtros
  Widget _buildSummaryAndFilters(List<Mesa> mesas) {
    final int totalMesas = mesas.length;
    final int mesasOcupadas = mesas
        .where((m) => m.status == 'Ocupada' || m.status == 'Em Uso')
        .length;
    final int mesasLivres = mesas.where((m) => m.status == 'Livre').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sumário Rápido
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mesas Ocupadas: $mesasOcupadas',
              style: TextStyle(
                color: Cores.primaryRed,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Mesas Livres: $mesasLivres',
              style: TextStyle(
                color: Colors.green,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Total: $totalMesas',
              style: TextStyle(color: Cores.textWhite, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Chips de Filtro de Status
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildFilterChip('Todos'),
              _buildFilterChip('Livre'),
              _buildFilterChip('Ocupada'),
              _buildFilterChip('Reservada'),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.backgroundBlack,
      appBar: AppBar(
        title: const Text(
          'Visão Geral de Mesas',
          style: TextStyle(
            color: Cores.textWhite,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Cores.cardBlack,
        actions: [
          // Botão de Logout
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Cores.primaryRed),
            onPressed: () async {
              try {
                await _loginFirebase.logout();

                Navigator.pushReplacementNamed(context, '/');

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sessão encerrada com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao fazer logout: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: StreamBuilder<List<Mesa>>(
          stream: _mesaController.listarMesasTempoReal(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Cores.primaryRed),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erro ao carregar mesas: ${snapshot.error}',
                  style: TextStyle(color: Cores.primaryRed),
                ),
              );
            }

            final mesas = snapshot.data ?? [];

            // Aplica o filtro
            final mesasFiltradas = mesas.where((mesa) {
              if (_filtroStatus == 'Todos') return true;
              if (_filtroStatus == 'Ocupada')
                return mesa.status == 'Ocupada' || mesa.status == 'Em Uso';
              return mesa.status == _filtroStatus;
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Adiciona o sumário e filtros
                _buildSummaryAndFilters(mesas),

                Expanded(
                  child: mesasFiltradas.isEmpty
                      ? Center(
                          child: Text(
                            'Nenhuma mesa encontrada com o status "$_filtroStatus".',
                            style: const TextStyle(color: Cores.textGray),
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5, // Número de colunas
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.0, // Cards quadrados
                              ),
                          itemCount: mesasFiltradas.length,
                          itemBuilder: (context, index) {
                            // Usa o widget do arquivo auxiliar
                            return buildMesaCard(
                              context,
                              mesasFiltradas[index],
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
