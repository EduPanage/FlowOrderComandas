// lib/view/TelaGerenciarMesa.dart

import 'package:flutter/material.dart';
import 'package:floworder/auxiliar/Cores.dart';
import 'package:floworder/models/Mesa.dart';
import 'package:floworder/models/ItemCardapio.dart';
import 'package:floworder/controller/CardapioController.dart';
// Importaremos o PedidoController aqui quando for o momento de salvar o pedido.

class TelaGerenciarMesa extends StatefulWidget {
  final Mesa mesa;

  const TelaGerenciarMesa({required this.mesa, super.key});

  @override
  State<TelaGerenciarMesa> createState() => _TelaGerenciarMesaState();
}

class _TelaGerenciarMesaState extends State<TelaGerenciarMesa> {
  final CardapioController _cardapioController = CardapioController();
  
  // Lista para armazenar o NOVO pedido (itens que o garçom está selecionando AGORA)
  List<ItemCardapio> _itensSelecionados = [];

  @override
  void initState() {
    super.initState();
    // TODO: Adicionar lógica para buscar o Pedido ATUAL da mesa (se houver)
  }

  // Função para adicionar/remover item do carrinho (pedido em construção)
  void _toggleItemSelection(ItemCardapio item, {bool isIncrement = true}) {
    setState(() {
      final index = _itensSelecionados.indexWhere((i) => i.uid == item.uid);
      
      if (index != -1) {
        // Item já está na lista
        if (isIncrement) {
          _itensSelecionados[index].quantidade++;
        } else {
          _itensSelecionados[index].quantidade--;
          // Remove se a quantidade zerar
          if (_itensSelecionados[index].quantidade <= 0) {
            _itensSelecionados.removeAt(index);
          }
        }
      } else if (isIncrement) {
        // Adiciona um novo item (com quantidade 1)
        // É importante clonar o objeto para que as mudanças de 'quantidade' não afetem a lista de itens do cardápio
        _itensSelecionados.add(
          ItemCardapio(
            uid: item.uid,
            nome: item.nome,
            categoria: item.categoria,
            descricao: item.descricao,
            preco: item.preco,
            quantidade: 1, // Começa com 1
          ),
        );
      }
    });
  }

  // Calcula o total do pedido em construção
  double _calcularTotal() {
    return _itensSelecionados.fold(0.0, (sum, item) => sum + (item.preco * item.quantidade));
  }

  // Card que exibe um item do cardápio
  Widget _buildItemCard(ItemCardapio item) {
    final itemNaSelecao = _itensSelecionados.firstWhere(
      (i) => i.uid == item.uid,
      orElse: () => ItemCardapio(uid: '', nome: '', categoria: '', descricao: '', preco: 0.0, quantidade: 0),
    );
    final quantidadeAtual = itemNaSelecao.quantidade;

    return Card(
      color: Cores.cardBlack,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: quantidadeAtual > 0 ? Cores.lightRed : Cores.borderGray, width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          item.nome,
          style: const TextStyle(color: Cores.textWhite, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              item.descricao,
              style: const TextStyle(color: Cores.textGray, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              'R\$ ${item.preco.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Cores.primaryRed,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (quantidadeAtual > 0)
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Cores.textGray),
                onPressed: () => _toggleItemSelection(item, isIncrement: false),
              ),
            if (quantidadeAtual > 0)
              Container(
                alignment: Alignment.center,
                width: 30,
                child: Text(
                  '$quantidadeAtual',
                  style: const TextStyle(color: Cores.textWhite, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Cores.lightRed),
              onPressed: () => _toggleItemSelection(item),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final totalPedido = _calcularTotal();
    final mesa = widget.mesa;
    
    return Scaffold(
      backgroundColor: Cores.backgroundBlack,
      appBar: AppBar(
        title: Text(
          'Mesa ${mesa.numero} - ${mesa.nome} (${mesa.status})',
          style: const TextStyle(color: Cores.textWhite, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Cores.cardBlack,
        iconTheme: const IconThemeData(color: Cores.textWhite),
        actions: [
          // Ação de fechar conta ou liberar mesa
          TextButton.icon(
            onPressed: mesa.status == 'Livre' ? null : () {
              // TODO: Implementar lógica de fechar conta / liberar mesa
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ação "Fechar Conta / Liberar Mesa" (Para ser implementada)!')));
            },
            icon: Icon(Icons.check_circle_outline, color: mesa.status == 'Livre' ? Cores.textGray : Cores.lightRed),
            label: Text(
              'Fechar Conta / Liberar Mesa',
              style: TextStyle(color: mesa.status == 'Livre' ? Cores.textGray : Cores.lightRed, fontSize: 16),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Row(
        children: [
          // 1. Área do Cardápio (Itens para selecionar)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cardápio Ativo',
                    style: TextStyle(
                      color: Cores.textWhite,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Divider(color: Cores.borderGray),
                  
                  // StreamBuilder para listar os itens do Cardápio
                  Expanded(
                    child: StreamBuilder<List<ItemCardapio>>(
                      stream: _cardapioController.listarItensAtivosTempoReal(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Cores.primaryRed));
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Erro ao carregar cardápio: ${snapshot.error}',
                                  style: const TextStyle(color: Cores.primaryRed)));
                        }

                        final itens = snapshot.data ?? [];

                        if (itens.isEmpty) {
                          return const Center(
                            child: Text('Nenhum item ativo no cardápio.',
                                style: TextStyle(color: Cores.textGray)),
                          );
                        }

                        return ListView.builder(
                          itemCount: itens.length,
                          itemBuilder: (context, index) {
                            return _buildItemCard(itens[index]);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Área do Pedido (Itens selecionados)
          Expanded(
            flex: 1,
            child: Container(
              color: Cores.cardBlack,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pedido em Montagem',
                    style: TextStyle(
                      color: Cores.textWhite,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Divider(color: Cores.borderGray),

                  // Lista de itens a serem adicionados
                  Expanded(
                    child: _itensSelecionados.isEmpty
                        ? const Center(
                            child: Text(
                              'Selecione itens no cardápio para montar o pedido.',
                              style: TextStyle(color: Cores.textGray),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _itensSelecionados.length,
                            itemBuilder: (context, index) {
                              final item = _itensSelecionados[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.quantidade}x ${item.nome}',
                                        style: const TextStyle(color: Cores.textWhite),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      'R\$ ${(item.preco * item.quantidade).toStringAsFixed(2)}',
                                      style: const TextStyle(color: Cores.textWhite, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  // Área do total e botão de Enviar Pedido
                  Container(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal:',
                              style: TextStyle(color: Cores.textWhite, fontSize: 20),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(color: Cores.textWhite, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'R\$ ${totalPedido.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Cores.primaryRed,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: totalPedido > 0
                              ? () {
                                  // TODO: Lógica para enviar o pedido
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Pedido de R\$ ${totalPedido.toStringAsFixed(2)} para a mesa ${mesa.numero} enviado (Para ser implementado)!')));
                                }
                              : null, // Desabilita o botão se o total for 0
                          icon: const Icon(Icons.send, color: Cores.textWhite),
                          label: const Text(
                            'Enviar Pedido',
                            style: TextStyle(fontSize: 18, color: Cores.textWhite),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Cores.primaryRed,
                            disabledBackgroundColor: Cores.textGray.withOpacity(0.3),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}