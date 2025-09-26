import 'package:floworder/auxiliar/Cores.dart';
import 'package:flutter/material.dart';
import 'BarraLateral.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.backgroundBlack,
      body: Row(
        children: [
          BarraLateral(currentRoute: '/home'),
          Expanded(
            child: Stack(
              children: [
                // Imagem centralizada no fundo
                Center(
                  child: Opacity(
                    opacity: 1, // deixa mais suave
                    child: Image.asset(
                      'logo/Icone_FlowOrder.png',
                      fit: BoxFit.contain,
                      width:
                          MediaQuery.of(context).size.width *
                          0.4, // 40% da largura
                    ),
                  ),
                ),

                const SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
