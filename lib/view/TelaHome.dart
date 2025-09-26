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
  Stream<List<Mesa>>? _mesasStream;

  @override
  void initState() {
    super.initState();
    // Inicializa o Stream para carregar as mesas em tempo real
    try {
      _mesasStream = _mesaController.listarMesasTempoReal();
    } catch (e) {
      // Em caso de erro (ex: usuário não logado), tratamos no builder
      _mesasStream = null;
      print("Erro ao iniciar stream de mesas: $e");
    }
  }

  // Função de navegação que usa a rota nomeada
  void _abrirCriarPedido(BuildContext context, Mesa mesa) {
    // Navega para a rota '/criarPedido' passando a mesa como argumento
    Navigator.of(context).pushNamed('/criarPedido', arguments: mesa);
  }

  @override
  Widget build(BuildContext context) {
    // Removemos o Row e o BarraLateral, pois o Garçom usa apenas a listagem.
    return Scaffold(
      backgroundColor: Cores.backgroundBlack,
      appBar: AppBar(
        title: const Text(
          'Selecione a Mesa',
          style: TextStyle(color: Cores.textWhite, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Cores.backgroundBlack,
        elevation: 0,
        automaticallyImplyLeading: false, // Garçom não volta do Home
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: StreamBuilder<List<Mesa>>(
            stream: _mesasStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                // Se houver um erro (ex: regras de segurança, ou 'nenhum gerente logado')
                return Center(
                  child: Text(
                    'Erro ao carregar mesas: ${snapshot.error.toString()}',
                    style: const TextStyle(
                      color: Cores.primaryRed,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Cores.primaryRed),
                );
              }

              final mesas = snapshot.data ?? [];

              if (mesas.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhuma mesa cadastrada. Fale com o gerente.',
                    style: TextStyle(color: Cores.textGray, fontSize: 18),
                  ),
                );
              }

              // Conteúdo principal: Grid de Mesas
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200, // Tamanho máximo de cada item
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
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
      ),
    );
  }

  // Construção do Card de Mesa (adaptado do antigo TelaMesas.dart)
  Widget _buildMesaCard(BuildContext context, Mesa mesa) {
    Color cardColor;
    Color iconColor;
    String statusText;

    // Lógica para determinar o estilo com base no status
    switch (mesa.status) {
      case 'Ocupada':
        cardColor = Cores.primaryRed.withOpacity(0.2);
        iconColor = Cores.primaryRed;
        statusText = 'Ocupada';
        break;
      case 'Livre':
      default:
        cardColor = Cores.cardBlack;
        iconColor = Cores.textGray;
        statusText = 'Livre';
        break;
    }

    return InkWell(
      onTap: () => _abrirCriarPedido(context, mesa),
      child: Card(
        color: cardColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: iconColor, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.table_bar, color: iconColor, size: 48),
              const SizedBox(height: 8),
              Text(
                mesa.nome,
                style: const TextStyle(
                  color: Cores.textWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                statusText,
                style: TextStyle(
                  color: iconColor,
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
