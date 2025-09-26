import 'package:flutter/material.dart';
import '../auxiliar/Cores.dart';

class BarraLateral extends StatelessWidget {
  final String currentRoute;

  const BarraLateral({Key? key, required this.currentRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Cores.cardBlack,
      child: Column(
        children: [
          // Área do logo no topo
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Image.asset('logo/Icone_FlowOrder.png', height: 60),
          ),
          const Divider(color: Cores.borderGray, thickness: 1),
          // Itens de navegação
          _buildMenuItem(context, 'Inicio', Icons.dashboard, '/home'),
          _buildMenuItem(
            context,
            'Cardápio',
            Icons.restaurant_menu,
            '/cardapio',
          ),
          _buildMenuItem(context, 'Pedidos', Icons.list_alt, '/pedidos'),
          _buildMenuItem(context, 'Mesas', Icons.table_chart, '/mesas'),

          const Spacer(),
          // Botão de sair
          _buildExitButton(context),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    bool isSelected = currentRoute == route;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? Cores.primaryRed.withOpacity(0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Cores.primaryRed : Cores.textGray,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Cores.textWhite : Cores.textGray,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
      ),
    );
  }

  Widget _buildExitButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Cores.primaryRed.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: const Icon(Icons.exit_to_app, color: Cores.primaryRed),
        title: const Text(
          'Sair',
          style: TextStyle(color: Cores.textWhite, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          // TODO: Implementar a lógica de logout.
          // Navigator.pushReplacementNamed(context, '/login');
        },
      ),
    );
  }
}
