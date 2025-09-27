import 'package:flutter/material.dart';
import 'package:floworder/auxiliar/Cores.dart';
import 'package:floworder/models/Mesa.dart';
import '../controller/PedidoController.dart';
import '../models/Pedido.dart';
import '../models/ItemPedido.dart';
import 'TelaCriarPedido.dart';

class TelaGerenciarMesa extends StatefulWidget {
  final Mesa mesa;

  const TelaGerenciarMesa({required this.mesa, super.key});

  @override
  State<TelaGerenciarMesa> createState() => _TelaGerenciarMesaState();
}

class _TelaGerenciarMesaState extends State<TelaGerenciarMesa>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final PedidoController _pedidoController = PedidoController();

  @override
  void initState() {
    super.initState();
    // Inicializa o TabController para 2 abas
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- WIDGET AUXILIAR: Item de Pedido (para exibição) ---
  Widget _buildItemPedido(ItemPedido item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quantidade
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text(
              '${item.quantidade}x',
              style: const TextStyle(
                color: Cores.primaryRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Nome do Item
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nome,
                  style: const TextStyle(color: Cores.textWhite, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.observacoes != null && item.observacoes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      'Obs: ${item.observacoes}',
                      style: TextStyle(
                        color: Cores.textGray,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Preço Total do Item
          Text(
            'R\$ ${(item.preco * item.quantidade).toStringAsFixed(2)}',
            style: const TextStyle(
              color: Cores.textWhite,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET AUXILIAR: Card do Pedido (para exibição) ---
  Widget _buildPedidoCard(Pedido pedido) {
    // Cor do status
    Color getStatusColor(String status) {
      switch (status) {
        case 'Pronto':
          return Colors.green;
        case 'Preparando':
          return Colors.yellow.shade700;
        case 'Pendente':
        case 'Aberto':
          return Colors.blue.shade300;
        default:
          return Cores.textGray;
      }
    }

    return Card(
      color: Cores.cardBlack,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do Pedido
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido #${pedido.uid?.substring(0, 6) ?? 'N/A'}',
                  style: const TextStyle(
                    color: Cores.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor(pedido.statusAtual).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: getStatusColor(pedido.statusAtual),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    pedido.statusAtual,
                    style: TextStyle(
                      color: getStatusColor(pedido.statusAtual),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Cores.borderGray, height: 15),

            // Itens do Pedido
            ...pedido.itens.map((item) => _buildItemPedido(item)).toList(),

            const Divider(color: Cores.borderGray, height: 15),

            // Total do Pedido
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL DO PEDIDO:',
                  style: TextStyle(
                    color: Cores.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'R\$ ${pedido.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Cores.primaryRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget para a primeira aba: Comanda Atual
  Widget _buildComandaAtualView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título e Status da Mesa
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Comanda Mesa ${widget.mesa.numero}:',
                style: TextStyle(
                  color: Cores.textWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: widget.mesa.status == 'Livre'
                      ? Colors.green.withOpacity(0.5)
                      : Cores.primaryRed.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.mesa.status,
                  style: TextStyle(
                    color: Cores.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Cores.borderGray, height: 32),

          // Área para StreamBuilder dos Pedidos
          Expanded(
            child: StreamBuilder<List<Pedido>>(
              stream: _pedidoController.listarPedidosTempoRealPorMesa(
                widget.mesa.uid,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Cores.primaryRed),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro: ${snapshot.error}',
                      style: const TextStyle(color: Cores.textGray),
                    ),
                  );
                }

                final List<Pedido> pedidosAtivos = snapshot.data ?? [];

                if (pedidosAtivos.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum pedido ativo no momento.\nCrie um novo pedido na aba ao lado.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Cores.textGray.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                // Calcula o total da comanda apenas com os pedidos ativos
                double totalComanda = pedidosAtivos.fold(
                  0.0,
                  (sum, pedido) => sum + pedido.total,
                );

                return Column(
                  children: [
                    // Resumo Total da Comanda
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL DA COMANDA:',
                            style: TextStyle(
                              color: Cores.textWhite,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'R\$ ${totalComanda.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Lista de Pedidos
                    Expanded(
                      child: ListView.builder(
                        itemCount: pedidosAtivos.length,
                        itemBuilder: (context, index) {
                          return _buildPedidoCard(pedidosAtivos[index]);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Rodapé: Botão para Fechar Comanda/Liberar Mesa
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Lógica para processar o pagamento e depois liberar a mesa
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Comanda Fechada! (A implementar lógica de pagamento e liberação de mesa)',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.payment, color: Cores.textWhite),
            label: const Text(
              'Fechar Comanda / Liberar Mesa',
              style: TextStyle(fontSize: 16, color: Cores.textWhite),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Cor de sucesso para fechar
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.backgroundBlack,
      appBar: AppBar(
        title: Text(
          'Mesa ${widget.mesa.numero}: ${widget.mesa.nome}',
          style: TextStyle(color: Cores.textWhite),
        ),
        backgroundColor: Cores.cardBlack,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Cores.textWhite),
            onPressed: () {
              // TODO: Lógica para imprimir a comanda parcial
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Comanda parcial impressa! (TO IMPLEMENT)'),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
        // TabBar na parte inferior do AppBar
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Cores.primaryRed,
          labelColor: Cores.primaryRed,
          unselectedLabelColor: Cores.textGray,
          tabs: const [
            Tab(text: 'Comanda Atual', icon: Icon(Icons.receipt)),
            Tab(text: 'Novo Pedido', icon: Icon(Icons.add_shopping_cart)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ABA 1: Comanda Atual
          _buildComandaAtualView(),

          // ABA 2: Novo Pedido (usando o widget TelaCriarPedido)
          TelaCriarPedido(mesa: widget.mesa, tabController: _tabController),
        ],
      ),
    );
  }
}
