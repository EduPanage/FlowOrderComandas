import 'package:flutter/material.dart';
import 'package:floworder/auxiliar/Cores.dart';

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
          _buildLogo(),
          const SizedBox(height: 32),
          _buildMenuItem(
            context,
            icon: Icons.home,
            label: 'Home',
            route: '/home',
          ),
          _buildMenuItem(
            context,
            icon: Icons.menu_book,
            label: 'Cardápio',
            route: '/cardapio',
          ),
          _buildMenuItem(
            context,
            icon: Icons.table_bar,
            label: 'Mesas',
            route: '/mesas',
          ),
          _buildMenuItem(
            context,
            icon: Icons.assignment,
            label: 'Pedidos',
            route: '/pedidos',
          ),
          const Spacer(),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            label: 'Sair',
            route: '/',
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        color: Cores.backgroundBlack,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Center(
        child: Image.asset(
          'logo/Icone_FlowOrder.png',
          height: 80,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    VoidCallback? onTap,
  }) {
    final bool isSelected = currentRoute == route;
    return InkWell(
      onTap: onTap ?? () => Navigator.pushReplacementNamed(context, route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Cores.primaryRed.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Cores.primaryRed, width: 2) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: Cores.textWhite),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: Cores.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
