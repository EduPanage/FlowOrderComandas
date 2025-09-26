import 'package:flutter/material.dart';
import 'package:floworder/controller/PedidoController.dart';
import 'package:floworder/models/Pedido.dart';
import 'package:floworder/models/ItemCardapio.dart';
import '../auxiliar/Cores.dart';
import 'BarraLateral.dart';

class TelaPedidos extends StatefulWidget {
  @override
  State<TelaPedidos> createState() => _TelaPedidosState();
}

class _TelaPedidosState extends State<TelaPedidos> {
  final PedidoController _pedidoController = PedidoController();
  Stream<List<Pedido>>? _pedidosStream;

  @override
  void initState() {
    super.initState();
    _pedidosStream = _pedidoController.listarPedidosTempoReal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.backgroundBlack,
      body: Row(
        children: [
          BarraLateral(currentRoute: '/pedidos'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pedidos',
                    style: TextStyle(
                      color: Cores.textWhite,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(child: _buildPedidosArea()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPedidosArea() {
    return StreamBuilder<List<Pedido>>(
      stream: _pedidosStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}', style: TextStyle(color: Cores.textWhite)));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Nenhum pedido encontrado.', style: TextStyle(color: Cores.textGray)));
        }

        final pedidos = snapshot.data!;

        return ListView.builder(
          itemCount: pedidos.length,
          itemBuilder: (context, index) {
            return _buildPedidoCard(pedidos[index]);
          },
        );
      },
    );
  }

  Widget _buildPedidoCard(Pedido pedido) {
    return Card(
      color: Cores.cardBlack,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Cores.borderGray, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mesa ${pedido.nomeMesa ?? 'N/A'}',
                  style: TextStyle(
                    color: Cores.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(pedido.statusAtual),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Horário: ${_formatarHorario(pedido.horario?.toDate() ?? DateTime.now())}',
              style: TextStyle(
                color: Cores.textGray,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            if (pedido.itens?.isNotEmpty == true)
              ...pedido.itens!.map((item) => _buildItemCardapio(item)).toList(),
            
            if (pedido.observacoes?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              Text(
                'Observações:',
                style: TextStyle(
                  color: Cores.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                pedido.observacoes!,
                style: TextStyle(color: Cores.textGray),
              ),
            ],
            
            const SizedBox(height: 16),
            _buildStatusActions(pedido),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCardapio(ItemCardapio item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${item.nome}',
              style: TextStyle(color: Cores.textWhite),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            'R\$ ${item.preco?.toStringAsFixed(2)}',
            style: TextStyle(color: Cores.textWhite),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    Color color = Cores.textGray;
    switch (status) {
      case 'Aberto':
        color = Colors.blue;
        break;
      case 'Em Preparo':
        color = Colors.orange;
        break;
      case 'Pronto':
        color = Colors.green;
        break;
      case 'Entregue':
        color = Colors.green.shade800;
        break;
      case 'Cancelado':
        color = Colors.red;
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(status ?? 'Desconhecido', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatusActions(Pedido pedido) {
    final opcoes = ['Aberto', 'Em Preparo', 'Pronto', 'Entregue', 'Cancelado'];

    return Wrap(
      spacing: 8,
      children: opcoes.map((status) {
        final selected = pedido.statusAtual == status;
        return ChoiceChip(
          label: Text(status),
          selected: selected,
          selectedColor: Cores.primaryRed,
          onSelected: (value) async {
            if (!selected) {
              final sucesso = await _pedidoController.mudarStatusPedido(pedido.uid!, status);
              if (sucesso) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Status atualizado para $status"),
                    backgroundColor: Colors.green,
                  ),
                );
                setState(() {});
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Erro ao atualizar status"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        );
      }).toList(),
    );
  }

  String _formatarHorario(DateTime horario) {
    return '${horario.hour.toString().padLeft(2, '0')}:${horario.minute.toString().padLeft(2, '0')}';
  }
}
