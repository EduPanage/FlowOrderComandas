// Imports necessários para o aplicativo Flutter.
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart'; // Importa o núcleo do Firebase

// Se você tiver um arquivo de opções do Firebase, importe-o aqui.
// import 'firebase_options.dart';

// O ponto de entrada principal do aplicativo.
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Garante que o Flutter e o Firebase estão prontos antes de iniciar
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const FlowOrderGarcomApp();
  }
}

// Definindo as cores do tema para replicar a estética fornecida.
// O arquivo original 'Cores.dart' não foi incluído, então as cores são definidas aqui.
class Cores {
  static const Color backgroundBlack = Color(0xFF1C1C1C);
  static const Color primaryRed = Color(0xFFE53935);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF9E9E9E);
  static const Color cardColor = Color(0xFF2E2E2E);
  static const Color buttonColor = Color(0xFFFDD835); // Amarelo
}

class FlowOrderGarcomApp extends StatelessWidget {
  const FlowOrderGarcomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlowOrder - Garçom',
      theme: ThemeData(
        scaffoldBackgroundColor: Cores.backgroundBlack,
        appBarTheme: const AppBarTheme(
          backgroundColor: Cores.backgroundBlack,
          foregroundColor: Cores.textWhite,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Cores.textWhite),
          bodyMedium: TextStyle(color: Cores.textWhite),
          titleMedium: TextStyle(color: Cores.textWhite),
          titleSmall: TextStyle(color: Cores.textGray),
        ),
        // Estilo global dos botões para combinar com o design.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Cores.primaryRed,
            foregroundColor: Cores.textWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      // A primeira tela que será mostrada.
      home: LoginScreen(),
    );
  }
}

// ===========================================
// TELA DE LOGIN
// ===========================================
class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login(BuildContext context) {
    // Simulando um login bem-sucedido.
    // **Ajuste aqui para a sua lógica de autenticação com o Firebase.**
    // Por exemplo, usando 'firebase_auth':
    // try {
    //   await FirebaseAuth.instance.signInWithEmailAndPassword(
    //     email: _usernameController.text,
    //     password: _passwordController.text,
    //   );
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MesasScreen()));
    // } catch (e) {
    //   // Tratar erros de login
    // }

    // Simplesmente navega para a próxima tela para demonstração.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MesasScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Entrar',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Cores.textWhite,
                ),
              ),
              const SizedBox(height: 30),
              // Campo de texto para o login.
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Cores.textWhite),
                decoration: InputDecoration(
                  labelText: 'Usuário',
                  labelStyle: const TextStyle(color: Cores.textGray),
                  filled: true,
                  fillColor: Cores.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Campo de texto para a senha.
              TextField(
                controller: _passwordController,
                style: const TextStyle(color: Cores.textWhite),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: const TextStyle(color: Cores.textGray),
                  filled: true,
                  fillColor: Cores.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Botão de login.
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _login(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Entrar', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================
// TELA DE MESAS
// ===========================================
class MesasScreen extends StatelessWidget {
  MesasScreen({super.key});

  // Dados de mesas simulados.
  // **Substitua por sua lógica de carregamento de dados do Firebase.**
  // Ex: FirebaseFirestore.instance.collection('mesas').snapshots()
  final List<String> mesas = List.generate(20, (index) => 'Mesa ${index + 1}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mesas'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: mesas.length,
          itemBuilder: (context, index) {
            final mesa = mesas[index];
            return Card(
              color: Cores.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PedidoScreen(mesa: mesa),
                    ),
                  );
                },
                child: Center(
                  child: Text(
                    mesa,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Cores.textWhite,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ===========================================
// TELA DE PEDIDO
// ===========================================
class PedidoScreen extends StatefulWidget {
  final String mesa;

  const PedidoScreen({super.key, required this.mesa});

  @override
  State<PedidoScreen> createState() => _PedidoScreenState();
}

class _PedidoScreenState extends State<PedidoScreen> {
  // Dados de cardápio simulados.
  // **Substitua por sua lógica de carregamento de dados do Firebase.**
  final List<Map<String, dynamic>> _cardapio = [
    {'nome': 'Cerveja Lager', 'preco': 15.00},
    {'nome': 'Coca-Cola', 'preco': 8.00},
    {'nome': 'Pizza de Calabresa', 'preco': 50.00},
    {'nome': 'Hamburguer Clássico', 'preco': 35.00},
    {'nome': 'Batata Frita', 'preco': 20.00},
    {'nome': 'Salada Caesar', 'preco': 25.00},
    {'nome': 'Tiramisù', 'preco': 22.00},
    {'nome': 'Espetinho de Carne', 'preco': 18.00},
    {'nome': 'Suco de Laranja', 'preco': 10.00},
    {'nome': 'Caipirinha', 'preco': 25.00},
  ];

  // Map para armazenar os itens selecionados.
  final Map<String, int> _selecionados = {};
  final Map<String, String> _observacoes = {};

  void _enviarPedido() async {
    // URL da sua API. Se for local, use o IP do seu computador ou 'localhost'.
    const url = 'http://10.0.2.2:5000/api/pedido';
    // O IP 10.0.2.2 é o alias para 'localhost' no emulador do Android.

    // Construindo o objeto do pedido.
    final pedidoData = {
      'mesa': widget.mesa,
      'itens': _selecionados.keys.map((item) {
        return {
          'produto': item,
          'quantidade': _selecionados[item],
          'observacao': _observacoes[item] ?? '',
        };
      }).toList(),
      'status': 'Aberto',
      'horario': DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(pedidoData),
      );

      if (response.statusCode == 200) {
        // Pedido enviado com sucesso.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pedido enviado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        // Retorna para a tela de mesas.
        Navigator.pop(context);
      } else {
        // Erro no envio do pedido.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao enviar pedido: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Erro de conexão.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro de conexão: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pedido - ${widget.mesa}'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _cardapio.length,
                itemBuilder: (context, index) {
                  final item = _cardapio[index];
                  final quantidade = _selecionados[item['nome']] ?? 0;
                  return Card(
                    color: Cores.cardColor,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['nome'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Cores.textWhite,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'R\$ ${item['preco'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Cores.textGray,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Botões para controlar a quantidade.
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove_circle,
                                      color: quantidade > 0
                                          ? Cores.primaryRed
                                          : Cores.textGray,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (quantidade > 0) {
                                          _selecionados[item['nome']] =
                                              quantidade - 1;
                                          if (_selecionados[item['nome']] ==
                                              0) {
                                            _selecionados.remove(item['nome']);
                                            _observacoes.remove(item['nome']);
                                          }
                                        }
                                      });
                                    },
                                  ),
                                  Text(
                                    '$quantidade',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle,
                                      color: Cores.buttonColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _selecionados[item['nome']] =
                                            quantidade + 1;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Campo para observações.
                          TextField(
                            onChanged: (text) {
                              _observacoes[item['nome']] = text;
                            },
                            style: const TextStyle(color: Cores.textWhite),
                            decoration: InputDecoration(
                              hintText: 'Observações...',
                              hintStyle: const TextStyle(color: Cores.textGray),
                              filled: true,
                              fillColor: Cores.backgroundBlack,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selecionados.isNotEmpty ? _enviarPedido : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _selecionados.isNotEmpty
                      ? Cores.primaryRed
                      : Cores.textGray,
                ),
                child: const Text(
                  'Enviar Pedido',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
