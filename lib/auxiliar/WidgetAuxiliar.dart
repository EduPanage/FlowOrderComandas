import 'package:flutter/material.dart';
import '../models/Mesa.dart';
import '../auxiliar/Cores.dart'; 
import '../view/TelaGerenciarMesa.dart'; 

// Função auxiliar para definir a cor do card (movida de TelaHome.dart)
Color _getMesaColor(String status) {
  switch (status) {
    case 'Ocupada':
    case 'Em Uso': 
      return Cores.primaryRed.withOpacity(0.5);
    case 'Reservada':
      return Cores.lightRed.withOpacity(0.5);
    case 'Livre':
    default:
      return Cores.cardBlack;
  }
}

/// Widget para exibir o Card de Mesa na TelaHome (movido de TelaHome.dart)
Widget buildMesaCard(BuildContext context, Mesa mesa) {
  final statusColor = _getMesaColor(mesa.status);

  return InkWell(
    onTap: () {
      // Navega para a tela de gerenciamento
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TelaGerenciarMesa(mesa: mesa),
        ),
      );
    },
    child: Card(
      color: statusColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Cores.borderGray, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.table_bar, color: Cores.textWhite, size: 40),
          const SizedBox(height: 8),
          Text(
            mesa.nome,
            style: TextStyle(
              color: Cores.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Cores.backgroundBlack.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              mesa.status,
              style: TextStyle(
                color: Cores.textWhite,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Widget para o campo de input de login (movido de Tela_Login.dart)
Widget buildInputField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
  Widget? suffixIcon,
  String? Function(String?)? validator,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[850],
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Cores.primaryRed.withOpacity(0.3), width: 1),
      boxShadow: [
        BoxShadow(
          color: Cores.primaryRed.withOpacity(0.1),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Cores.textWhite),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Cores.textGray),
        prefixIcon: Icon(icon, color: Cores.primaryRed),
        suffixIcon: suffixIcon,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    ),
  );
}