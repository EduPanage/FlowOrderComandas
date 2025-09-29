// lib/view/TelaGarcom.dart
import 'package:flutter/material.dart';
import '../controller/PedidoController.dart';
import '../controller/MesaController.dart';
import '../controller/CardapioController.dart';
import '../firebase/LoginFirebase.dart';
import '../models/Pedido.dart';
import '../models/Mesa.dart';
import '../models/Cardapio.dart';
import '../models/ItemCardapio.dart';
import '../auxiliar/Cores.dart';

class TelaGarcom extends StatefulWidget {
  @override
  State<TelaGarcom> createState() => _TelaGarcomState();
}

class _TelaGarcomState extends State<TelaGarcom> {
  final PedidoController _pedidoController = PedidoController();
  Stream<List<Pedido>>? _streamPedidos;

  @override
  void initState() {
    super.initState();
    _carregarPedidos();
  }

  Future<void> _logout(BuildContext context) async {
    // Mostra um dialog de confirmação
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: Text(
            'Confirmar Logout',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Deseja realmente sair do sistema?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[400],
              ),
              child: Text('Sair'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      try {
        LoginFirebase loginFirebase = LoginFirebase();
        String resultado = await loginFirebase.logout();

        if (resultado == 'Logout realizado com sucesso') {
          // Navega para tela de login e remove todas as rotas anteriores
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
                (route) => false,
          );

          // Mostra mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout realizado com sucesso!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Mostra mensagem de erro
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao fazer logout: $resultado'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _carregarPedidos() async {
    try {
      final stream = await _pedidoController.listarPedidosTempoReal();
      print("Stream pedidos obtido: $stream");
      setState(() => _streamPedidos = stream);
    } catch (e, st) {
      print("Erro ao carregar stream de pedidos: $e\n$st");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.backgroundBlack,
      appBar: AppBar(
        backgroundColor: Cores.primaryRed,
        title: Text("Pedidos", style: TextStyle(color: Colors.white)),
        elevation: 0,
        actions: [
      // Botão de logout
      IconButton(
      icon: Icon(
      Icons.logout,
        color: Colors.white,
      ),
      onPressed: () => _logout(context),
      tooltip: 'Sair do sistema',
      )]
      ),
      body: _streamPedidos == null
          ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Cores.primaryRed),
          ))
          : StreamBuilder<List<Pedido>>(
        stream: _streamPedidos,
        builder: (context, snapshot) {
          print("Snapshot: state=${snapshot.connectionState}, hasError=${snapshot.hasError}");
          if (snapshot.hasError) {
            return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 48),
                    SizedBox(height: 16),
                    Text('Erro: ${snapshot.error}',
                        style: TextStyle(color: Colors.red, fontSize: 16)),
                  ],
                ));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Cores.primaryRed),
                ));
          }
          final pedidos = snapshot.data ?? [];
          if (pedidos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu,
                      size: 80, color: Cores.textGray),
                  SizedBox(height: 16),
                  Text("Nenhum pedido encontrado",
                      style: TextStyle(color: Cores.textGray, fontSize: 18)),
                  SizedBox(height: 8),
                  Text("Toque no + para criar um novo pedido",
                      style: TextStyle(color: Cores.textGray, fontSize: 14)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _carregarPedidos,
            color: Cores.primaryRed,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: pedidos.length,
              itemBuilder: (context, i) => _buildPedidoCard(pedidos[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Cores.primaryRed,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("Novo Pedido", style: TextStyle(color: Colors.white)),
        onPressed: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showAdicionarPedidoDialog();
          });
        },
      ),
    );
  }

  Widget _buildPedidoCard(Pedido pedido) {
    final total = pedido.calcularTotal();

    return Card(
      color: Cores.cardBlack,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Cores.borderGray.withOpacity(0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _abrirDetalhesPedido(pedido),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header do card
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Cores.primaryRed,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "Mesa ${pedido.mesa.numero}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Spacer(),
                  _buildStatusChip(pedido.statusAtual),
                ],
              ),
              SizedBox(height: 12),

              // Informações principais
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "R\$ ${total.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: Cores.primaryRed,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "${pedido.itens.length} ${pedido.itens.length == 1 ? 'item' : 'itens'}",
                          style: TextStyle(color: Cores.textGray, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${pedido.horario.hour.toString().padLeft(2,'0')}:${pedido.horario.minute.toString().padLeft(2,'0')}",
                        style: TextStyle(
                          color: Cores.textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "${pedido.horario.day.toString().padLeft(2,'0')}/${pedido.horario.month.toString().padLeft(2,'0')}",
                        style: TextStyle(color: Cores.textGray, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              // Observação do pedido (se houver)
              if (pedido.observacao != null && pedido.observacao!.isNotEmpty) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Cores.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Cores.primaryRed.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.note, color: Cores.primaryRed, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pedido.observacao!,
                          style: TextStyle(
                            color: Cores.textWhite,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Botões de ação (somente para pedidos em aberto)
              if (pedido.statusAtual == "Aberto") ...[
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.cancel_outlined, size: 18, color: Colors.red),
                        label: Text("Cancelar", style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _cancelarPedido(pedido),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.visibility, size: 18, color: Colors.white),
                        label: Text("Ver Detalhes", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Cores.primaryRed,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _abrirDetalhesPedido(pedido),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    switch (status) {
      case 'Em Preparo':
        color = Colors.orange;
        icon = Icons.restaurant;
        break;
      case 'Pronto':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'Aberto':
        color = Colors.blue;
        icon = Icons.receipt;
        break;
      case 'Entregue':
        color = Colors.purple;
        icon = Icons.done_all;
        break;
      default:
        color = Cores.textGray;
        icon = Icons.help_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _abrirDetalhesPedido(Pedido pedido) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Cores.cardBlack,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Cores.textGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Cores.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.restaurant_menu, color: Cores.primaryRed),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mesa ${pedido.mesa.numero}",
                          style: TextStyle(
                            color: Cores.textWhite,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Status: ${pedido.statusAtual}",
                          style: TextStyle(color: Cores.textGray, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(pedido.statusAtual),
                ],
              ),
            ),

            Divider(color: Cores.borderGray, height: 1),

            // Lista de itens
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  Text(
                    "Itens do Pedido",
                    style: TextStyle(
                      color: Cores.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  ...pedido.itens.map((item) => Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Cores.borderGray.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Cores.borderGray.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Cores.primaryRed,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${item.quantidade}x",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.nome,
                                style: TextStyle(
                                  color: Cores.textWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              "R\$ ${(item.preco * item.quantidade).toStringAsFixed(2)}",
                              style: TextStyle(
                                color: Cores.primaryRed,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (item.observacao != null && item.observacao!.isNotEmpty) ...[
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.note, color: Cores.textGray, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.observacao!,
                                  style: TextStyle(
                                    color: Cores.textGray,
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  )),

                  SizedBox(height: 16),

                  // Total
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Cores.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Cores.primaryRed.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total do Pedido:",
                          style: TextStyle(
                            color: Cores.textWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "R\$ ${pedido.calcularTotal().toStringAsFixed(2)}",
                          style: TextStyle(
                            color: Cores.primaryRed,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Botão de ação baseado no status
                  if (pedido.statusAtual == "Pronto")
                    ElevatedButton(
                      onPressed: () async {
                        await _pedidoController.atualizarStatusPedido(pedido.uid!, "Entregue");
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Pedido marcado como entregue!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Marcar como Entregue",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdicionarPedidoDialog() {
    showDialog(
      context: context,
      builder: (_) => AdicionarPedidoDialogMobile(),
    );
  }

  Future<void> _cancelarPedido(Pedido pedido) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Cores.cardBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text("Cancelar Pedido", style: TextStyle(color: Cores.textWhite)),
          ],
        ),
        content: Text(
          "Tem certeza que deseja cancelar o pedido da Mesa ${pedido.mesa.numero}?",
          style: TextStyle(color: Cores.textGray),
        ),
        actions: [
          TextButton(
            child: Text("Não", style: TextStyle(color: Cores.textGray)),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: Text("Sim, Cancelar"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final sucesso = await _pedidoController.excluirPedido(pedido as String);
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("Pedido cancelado com sucesso!"),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text("Erro ao cancelar pedido. Tente novamente."),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// ===================================
/// DIÁLOGO PARA ADICIONAR PEDIDO (MOBILE)
/// ===================================
class AdicionarPedidoDialogMobile extends StatefulWidget {
  @override
  State<AdicionarPedidoDialogMobile> createState() => _AdicionarPedidoDialogMobileState();
}

class _AdicionarPedidoDialogMobileState extends State<AdicionarPedidoDialogMobile> {
  final PedidoController _pedidoController = PedidoController();
  final MesaController _mesaController = MesaController();
  final CardapioController _cardapioController = CardapioController();
  final PageController _pageController = PageController();

  Mesa? mesaSelecionada;
  List<Mesa> mesas = [];
  List<Cardapio> cardapio = [];
  List<ItemCardapio> itensSelecionados = [];
  final obsController = TextEditingController();
  bool carregando = true;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    obsController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    final m = await _mesaController.buscarMesas();
    final c = await _cardapioController.buscarCardapios();
    setState(() {
      mesas = m;
      cardapio = c.where((i) => i.ativo).toList();
      carregando = false;
    });
  }

  void _customizarItem(Cardapio item) {
    showDialog(
      context: context,
      builder: (_) => CustomizarItemDialogMobile(
        item: item,
        onConfirm: (novoItem) {
          setState(() => itensSelecionados.add(novoItem));
        },
      ),
    );
  }

  void _removerItem(int index) {
    setState(() => itensSelecionados.removeAt(index));
  }

  double get _totalPedido {
    return itensSelecionados.fold(0.0, (sum, item) => sum + (item.preco * item.quantidade));
  }

  Future<void> _salvar() async {
    if (mesaSelecionada == null || itensSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecione uma mesa e pelo menos um item'),
          backgroundColor: Cores.primaryRed,
        ),
      );
      return;
    }

    final pedido = Pedido(
      horario: DateTime.now(),
      mesa: mesaSelecionada!,
      itens: itensSelecionados,
      statusAtual: "Aberto",
      observacao: obsController.text,
    );

    await _pedidoController.cadastrarPedido(pedido);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text("Pedido criado com sucesso!"),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Cores.cardBlack,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Cores.primaryRed,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.add_shopping_cart, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Novo Pedido",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Page Indicator
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPageIndicator(0, "Mesa"),
                  Container(width: 40, height: 2, color: Cores.borderGray),
                  _buildPageIndicator(1, "Itens"),
                  Container(width: 40, height: 2, color: Cores.borderGray),
                  _buildPageIndicator(2, "Resumo"),
                ],
              ),
            ),

            // Content
            Expanded(
              child: carregando
                  ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Cores.primaryRed),
                ),
              )
                  : PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => currentPage = page),
                children: [
                  _buildMesaPage(),
                  _buildItensPage(),
                  _buildResumoPage(),
                ],
              ),
            ),

            // Footer
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  if (currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        ),
                        child: Text("Voltar", style: TextStyle(color: Cores.textWhite)),
                      ),
                    ),
                  if (currentPage > 0) SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: currentPage == 2 ? _salvar : () {
                        if (currentPage == 0 && mesaSelecionada == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Selecione uma mesa")),
                          );
                          return;
                        }
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Cores.primaryRed,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        currentPage == 2 ? "Salvar Pedido" : "Próximo",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int page, String label) {
    final isActive = currentPage == page;
    final isPassed = currentPage > page;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Cores.primaryRed : (isPassed ? Colors.green : Cores.borderGray),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPassed ? Icons.check : (isActive ? Icons.circle : Icons.radio_button_unchecked),
            color: Colors.white,
            size: 16,
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMesaPage() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Selecione a Mesa",
            style: TextStyle(
              color: Cores.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: mesas.length,
              itemBuilder: (context, index) {
                final mesa = mesas[index];
                final selected = mesaSelecionada?.uid == mesa.uid;

                return GestureDetector(
                  onTap: () => setState(() => mesaSelecionada = mesa),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: selected ? Cores.primaryRed : Cores.cardBlack,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? Cores.primaryRed : Cores.borderGray,
                        width: 2,
                      ),
                      boxShadow: selected ? [
                        BoxShadow(
                          color: Cores.primaryRed.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ] : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.table_restaurant,
                          color: selected ? Colors.white : Cores.primaryRed,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Mesa ${mesa.numero}",
                          style: TextStyle(
                            color: selected ? Colors.white : Cores.textWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (mesa.nome.isNotEmpty)
                          Text(
                            mesa.nome,
                            style: TextStyle(
                              color: selected ? Colors.white.withOpacity(0.8) : Cores.textGray,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItensPage() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Cardápio",
            style: TextStyle(
              color: Cores.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: cardapio.length,
              itemBuilder: (context, index) {
                final item = cardapio[index];
                return Card(
                  color: Cores.cardBlack,
                  margin: EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Cores.borderGray.withOpacity(0.3)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Cores.primaryRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.restaurant,
                            color: Cores.primaryRed,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.nome,
                                style: TextStyle(
                                  color: Cores.textWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Cores.primaryRed.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.categoria,
                                      style: TextStyle(
                                        color: Cores.primaryRed,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "R\$ ${item.preco.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: Cores.textGray,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: Cores.primaryRed, size: 32),
                          onPressed: () => _customizarItem(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Itens selecionados (preview)
          if (itensSelecionados.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: Cores.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Cores.primaryRed.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.shopping_cart, color: Cores.primaryRed, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "${itensSelecionados.length} ${itensSelecionados.length == 1 ? 'item' : 'itens'} selecionados",
                    style: TextStyle(color: Cores.textWhite, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Text(
                    "R\$ ${_totalPedido.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: Cores.primaryRed,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResumoPage() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Resumo do Pedido",
            style: TextStyle(
              color: Cores.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),

          // Informações da mesa
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Cores.cardBlack,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Cores.borderGray.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.table_restaurant, color: Cores.primaryRed),
                SizedBox(width: 12),
                Text(
                  "Mesa ${mesaSelecionada?.numero ?? ''}",
                  style: TextStyle(
                    color: Cores.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Lista de itens
          Text(
            "Itens do Pedido",
            style: TextStyle(
              color: Cores.textWhite,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),

          Expanded(
            child: itensSelecionados.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Cores.textGray),
                  SizedBox(height: 16),
                  Text(
                    "Nenhum item selecionado",
                    style: TextStyle(color: Cores.textGray, fontSize: 16),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: itensSelecionados.length,
              itemBuilder: (context, index) {
                final item = itensSelecionados[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Cores.cardBlack,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Cores.borderGray.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Cores.primaryRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${item.quantidade}x",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.nome,
                              style: TextStyle(
                                color: Cores.textWhite,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (item.observacao?.isNotEmpty == true)
                              Text(
                                item.observacao!,
                                style: TextStyle(
                                  color: Cores.textGray,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "R\$ ${(item.preco * item.quantidade).toStringAsFixed(2)}",
                            style: TextStyle(
                              color: Cores.primaryRed,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _removerItem(index),
                            child: Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Observação
          SizedBox(height: 16),
          TextField(
            controller: obsController,
            maxLines: 2,
            style: TextStyle(color: Cores.textWhite),
            decoration: InputDecoration(
              hintText: "Observação do pedido...",
              hintStyle: TextStyle(color: Cores.textGray),
              filled: true,
              fillColor: Cores.cardBlack,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Cores.borderGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Cores.borderGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Cores.primaryRed),
              ),
            ),
          ),

          SizedBox(height: 16),

          // Total
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Cores.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Cores.primaryRed.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total do Pedido:",
                  style: TextStyle(
                    color: Cores.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "R\$ ${_totalPedido.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Cores.primaryRed,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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

/// ===================================
/// DIÁLOGO PARA CUSTOMIZAR ITEM (MOBILE)
/// ===================================
class CustomizarItemDialogMobile extends StatefulWidget {
  final Cardapio item;
  final Function(ItemCardapio) onConfirm;

  CustomizarItemDialogMobile({required this.item, required this.onConfirm});

  @override
  State<CustomizarItemDialogMobile> createState() => _CustomizarItemDialogMobileState();
}

class _CustomizarItemDialogMobileState extends State<CustomizarItemDialogMobile> {
  final observacaoController = TextEditingController();
  final precoController = TextEditingController();
  int quantidade = 1;
  bool usarPrecoCustomizado = false;

  @override
  void initState() {
    super.initState();
    precoController.text = widget.item.preco.toStringAsFixed(2);
  }

  @override
  void dispose() {
    observacaoController.dispose();
    precoController.dispose();
    super.dispose();
  }

  double get _precoTotal {
    final precoUnitario = usarPrecoCustomizado
        ? (double.tryParse(precoController.text) ?? widget.item.preco)
        : widget.item.preco;
    return precoUnitario * quantidade;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Cores.cardBlack,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Cores.primaryRed,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit_note, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Customizar Item",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.item.nome,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Info
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Cores.borderGray.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Cores.borderGray.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Cores.primaryRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.restaurant, color: Cores.primaryRed),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.item.nome,
                                  style: TextStyle(
                                    color: Cores.textWhite,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  widget.item.categoria,
                                  style: TextStyle(color: Cores.textGray, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "R\$ ${widget.item.preco.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: Cores.primaryRed,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Quantidade
                    Text(
                      "Quantidade",
                      style: TextStyle(
                        color: Cores.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle, color: quantidade > 1 ? Cores.primaryRed : Cores.textGray),
                          onPressed: quantidade > 1 ? () => setState(() => quantidade--) : null,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Cores.cardBlack,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Cores.borderGray),
                          ),
                          child: Text(
                            "$quantidade",
                            style: TextStyle(
                              color: Cores.textWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: Cores.primaryRed),
                          onPressed: () => setState(() => quantidade++),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Preço Customizado
                    Row(
                      children: [
                        Checkbox(
                          value: usarPrecoCustomizado,
                          onChanged: (v) => setState(() => usarPrecoCustomizado = v!),
                          activeColor: Cores.primaryRed,
                        ),
                        Text(
                          "Usar preço customizado",
                          style: TextStyle(color: Cores.textWhite, fontSize: 14),
                        ),
                      ],
                    ),

                    if (usarPrecoCustomizado) ...[
                      SizedBox(height: 8),
                      TextField(
                        controller: precoController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: Cores.textWhite),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: "Preço customizado (R\$)",
                          labelStyle: TextStyle(color: Cores.textGray),
                          filled: true,
                          fillColor: Cores.cardBlack,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Cores.borderGray),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Cores.primaryRed),
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: 20),

                    // Observações
                    Text(
                      "Observações",
                      style: TextStyle(
                        color: Cores.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: observacaoController,
                      maxLines: 3,
                      style: TextStyle(color: Cores.textWhite),
                      decoration: InputDecoration(
                        hintText: "Ex: sem cebola, extra queijo, ponto da carne...",
                        hintStyle: TextStyle(color: Cores.textGray),
                        filled: true,
                        fillColor: Cores.cardBlack,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Cores.borderGray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Cores.primaryRed),
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Total
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Cores.primaryRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Cores.primaryRed.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total do item:",
                            style: TextStyle(
                              color: Cores.textWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "R\$ ${_precoTotal.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: Cores.primaryRed,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancelar", style: TextStyle(color: Cores.textGray)),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final preco = usarPrecoCustomizado
                            ? double.tryParse(precoController.text) ?? widget.item.preco
                            : widget.item.preco;
                        final novoItem = ItemCardapio(
                          uid: widget.item.uid,
                          nome: widget.item.nome,
                          preco: preco,
                          categoria: widget.item.categoria,
                          observacao: observacaoController.text,
                          quantidade: quantidade,
                        );
                        widget.onConfirm(novoItem);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Cores.primaryRed,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "Adicionar",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}