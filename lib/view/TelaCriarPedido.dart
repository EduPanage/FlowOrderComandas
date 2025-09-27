import 'package:flutter/material.dart';
import '../auxiliar/Cores.dart';
import '../models/Mesa.dart';
import '../controller/CardapioController.dart';
import '../controller/PedidoController.dart';
import '../models/ItemCardapio.dart';
import '../models/ItemPedido.dart';
import '../models/Pedido.dart';

class TelaCriarPedido extends StatefulWidget {
  final Mesa mesa;
  final TabController tabController;

  const TelaCriarPedido({
    required this.mesa,
    required this.tabController,
    super.key,
  });

  @override
  State<TelaCriarPedido> createState() => _TelaCriarPedidoState();
}

class _TelaCriarPedidoState extends State<TelaCriarPedido> {
  final CardapioController _cardapioController = CardapioController();
  final PedidoController _pedidoController = PedidoController();

  // Lista de itens que o garçom adicionou ao pedido atual (uid do item e quantidade)
  Map<String, int> _itensNoCarrinho = {};
  String _filtroBusca = '';
  final TextEditingController _searchController = TextEditingController();

  void _atualizarQuantidade(ItemCardapio item, {bool isIncrement = true}) {
    setState(() {
      final String uid = item.uid;

      if (isIncrement) {
        _itensNoCarrinho.update(
          uid,
          (quantidade) => quantidade + 1,
          ifAbsent: () => 1,
        );
      } else {
        if (_itensNoCarrinho.containsKey(uid) && _itensNoCarrinho[uid]! > 1) {
          _itensNoCarrinho.update(uid, (quantidade) => quantidade - 1);
        } else {
          _itensNoCarrinho.remove(uid);
        }
      }
    });
  }

  // Retorna a quantidade atual do item no carrinho
  int _getQuantidade(String uid) {
    return _itensNoCarrinho[uid] ?? 0;
  }

  // Calcula o total do pedido em tempo real
  double get _totalPedido {
    // Cálculo simplificado: usaremos o cálculo no _salvarPedido com o Cardapio completo
    return 0.0;
  }

  // Salva o pedido no Firestore
  Future<void> _salvarPedido(List<ItemCardapio> cardapioCompleto) async {
    if (_itensNoCarrinho.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um item ao pedido!')),
      );
      return;
    }

    try {
      // 1. Criar a lista de ItemPedido a partir do Carrinho e do Cardápio Completo
      List<ItemPedido> itensParaPedido = [];
      double totalCalculado = 0.0;

      for (var entry in _itensNoCarrinho.entries) {
        final String itemUid = entry.key;
        final int quantidade = entry.value;

        // Encontra o ItemCardapio original para pegar nome e preço corretos
        final itemCardapio = cardapioCompleto.firstWhere(
          (item) => item.uid == itemUid,
          orElse: () =>
              throw Exception('Item do cardápio não encontrado: $itemUid'),
        );

        // Chamada correta: uid agora é um parâmetro obrigatório em ItemPedido
        final itemPedido = ItemPedido(
          uid: itemCardapio.uid,
          nome: itemCardapio.nome,
          preco: itemCardapio.preco,
          quantidade: quantidade,
          observacoes: '', // Implementação futura de observações
        );

        itensParaPedido.add(itemPedido);
        totalCalculado += itemPedido.preco * itemPedido.quantidade;
      }

      // 2. Criar o objeto Pedido
      final novoPedido = Pedido(
        mesaUid: widget.mesa.uid,
        nomeMesa: widget.mesa.nome,
        total:
            totalCalculado, // Usamos o total calculado para evitar erros de ponto flutuante
        itens: itensParaPedido,
      );

      // 3. Enviar o pedido para o Controller
      await _pedidoController.cadastrarPedido(novoPedido);

      // Sucesso
      setState(() {
        _itensNoCarrinho.clear(); // Limpa o carrinho
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pedido enviado com sucesso para a mesa ${widget.mesa.numero}!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // *** Mudar para a aba de Comanda Atual (index 0) ***
      widget.tabController.animateTo(0);
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Cores.primaryRed,
        ),
      );
    }
  }

  // Card que mostra um item do cardápio e os botões de + / -
  Widget _buildItemCardapio(ItemCardapio item) {
    final quantidade = _getQuantidade(item.uid);
    final bool estaNoCarrinho = quantidade > 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Cores.cardBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: estaNoCarrinho ? Cores.primaryRed : Cores.borderGray,
          width: estaNoCarrinho ? 2.0 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Informações do Item
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nome,
                    style: const TextStyle(
                      color: Cores.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${item.preco.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Botões de Quantidade
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botão de Diminuir
                IconButton(
                  icon: Icon(
                    Icons.remove_circle,
                    color: quantidade > 0 ? Cores.primaryRed : Cores.textGray,
                  ),
                  onPressed: quantidade > 0
                      ? () => _atualizarQuantidade(item, isIncrement: false)
                      : null,
                ),

                // Contador de Quantidade
                Container(
                  width: 30,
                  alignment: Alignment.center,
                  child: Text(
                    '$quantidade',
                    style: const TextStyle(
                      color: Cores.textWhite,
                      fontSize: 18,
                    ),
                  ),
                ),

                // Botão de Aumentar
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () =>
                      _atualizarQuantidade(item, isIncrement: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Campo de Busca
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _filtroBusca = value.toLowerCase();
              });
            },
            style: const TextStyle(color: Cores.textWhite),
            decoration: InputDecoration(
              hintText: 'Buscar item no cardápio...',
              hintStyle: TextStyle(color: Cores.textGray),
              prefixIcon: const Icon(Icons.search, color: Cores.primaryRed),
              filled: true,
              fillColor: Cores.cardBlack,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Lista de Itens do Cardápio em Tempo Real
        Expanded(
          child: StreamBuilder<List<ItemCardapio>>(
            stream: _cardapioController.listarItensCardapioTempoReal(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Cores.primaryRed),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro ao carregar cardápio: ${snapshot.error}',
                    style: const TextStyle(color: Cores.primaryRed),
                  ),
                );
              }

              final cardapioCompleto = snapshot.data ?? [];

              // Filtra a lista com base na busca
              final listaFiltrada = cardapioCompleto.where((item) {
                return item.nome.toLowerCase().contains(_filtroBusca);
              }).toList();

              if (listaFiltrada.isEmpty) {
                return Center(
                  child: Text(
                    cardapioCompleto.isEmpty
                        ? 'Nenhum item ativo no cardápio.'
                        : 'Nenhum item encontrado para "$_filtroBusca".',
                    style: TextStyle(color: Cores.textGray),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: listaFiltrada.length,
                itemBuilder: (context, index) {
                  return _buildItemCardapio(listaFiltrada[index]);
                },
              );
            },
          ),
        ),

        // Área do Total e Botão Salvar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Cores.borderGray)),
            color: Cores.cardBlack,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Itens no Carrinho:',
                    style: TextStyle(
                      color: Cores.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_itensNoCarrinho.values.fold(0, (sum, current) => sum + current)} itens',
                    style: const TextStyle(
                      color: Cores.primaryRed,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // StreamBuilder para garantir que tenhamos a lista de itens atualizada para o salvamento
              StreamBuilder<List<ItemCardapio>>(
                stream: _cardapioController.listarItensCardapioTempoReal(),
                builder: (context, snapshot) {
                  final cardapioCompleto = snapshot.data ?? [];

                  return ElevatedButton.icon(
                    onPressed: _itensNoCarrinho.isNotEmpty
                        ? () =>
                              _salvarPedido(
                                cardapioCompleto,
                              ) // Passa o cardápio completo para calcular preço na hora
                        : null,
                    icon: const Icon(Icons.send),
                    label: const Text('Enviar Pedido'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Cores.primaryRed,
                      foregroundColor: Cores.textWhite,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
