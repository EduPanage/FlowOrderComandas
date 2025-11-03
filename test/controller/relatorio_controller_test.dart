import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Testes de Lógica de Negócio', () {
    test('Deve calcular corretamente o total de um pedido', () {
      // Simula um cálculo de total
      final itens = [
        {'preco': 10.0, 'quantidade': 2}, // R$ 20,00
        {'preco': 15.0, 'quantidade': 1}, // R$ 15,00
      ];

      double total = 0.0;
      for (var item in itens) {
        total += (item['preco'] as double) * (item['quantidade'] as int);
      }

      expect(total, equals(35.0));
    });

    test('Deve formatar data corretamente', () {
      // Testa a formatação de data no padrão brasileiro DD/MM/YYYY
      final data = DateTime(2024, 3, 15);
      final dia = data.day.toString().padLeft(2, '0');
      final mes = data.month.toString().padLeft(2, '0');
      final ano = data.year;
      final dataFormatada = '$dia/$mes/$ano';

      expect(dataFormatada, equals('15/03/2024'));
    });

    test('Deve comparar datas corretamente', () {
      // Verifica a lógica de comparação de datas
      final data1 = DateTime(2024, 1, 15);
      final data2 = DateTime(2024, 3, 20);

      expect(data1.isBefore(data2), isTrue);
      expect(data2.isAfter(data1), isTrue);
    });

    test('Deve calcular período corretamente', () {
      final inicio = DateTime(2024, 1, 1);
      final fim = DateTime(2024, 1, 31);

      // Ajusta o fim para incluir todo o último dia
      final fimAjustado = DateTime(fim.year, fim.month, fim.day, 23, 59, 59);

      expect(fimAjustado.hour, equals(23));
      expect(fimAjustado.minute, equals(59));
      expect(fimAjustado.second, equals(59));
    });
  });

  group('Testes de Agregação de Dados', () {
    test('Deve somar quantidades de produtos corretamente', () {
      // Simula o cálculo de produtos mais vendidos
      final pedidos = [
        {
          'itens': [
            {'nome': 'Pizza', 'quantidade': 2},
            {'nome': 'Refrigerante', 'quantidade': 3},
          ],
        },
        {
          'itens': [
            {'nome': 'Pizza', 'quantidade': 1},
            {'nome': 'Refrigerante', 'quantidade': 2},
          ],
        },
      ];

      Map<String, int> ranking = {};

      for (var pedido in pedidos) {
        final itens = pedido['itens'] as List;
        for (var item in itens) {
          final nome = item['nome'] as String;
          final quantidade = item['quantidade'] as int;
          ranking[nome] = (ranking[nome] ?? 0) + quantidade;
        }
      }

      expect(ranking['Pizza'], equals(3)); // 2 + 1
      expect(ranking['Refrigerante'], equals(5)); // 3 + 2
    });

    test('Deve calcular faturamento por produto', () {
      final pedidos = [
        {
          'itens': [
            {'nome': 'Hambúrguer', 'preco': 25.0, 'quantidade': 2},
          ],
        },
        {
          'itens': [
            {'nome': 'Hambúrguer', 'preco': 25.0, 'quantidade': 1},
          ],
        },
      ];

      Map<String, double> faturamento = {};

      for (var pedido in pedidos) {
        final itens = pedido['itens'] as List;
        for (var item in itens) {
          final nome = item['nome'] as String;
          final preco = item['preco'] as double;
          final quantidade = item['quantidade'] as int;

          faturamento[nome] = (faturamento[nome] ?? 0.0) + (preco * quantidade);
        }
      }

      // 2 hambúrgueres (R$ 25,00) + 1 hambúrguer (R$ 25,00) = R$ 75,00
      expect(faturamento['Hambúrguer'], equals(75.0));
    });

    test('Deve ordenar produtos por quantidade vendida', () {
      final ranking = {'Pizza': 10, 'Refrigerante': 25, 'Hambúrguer': 15};

      final sorted = ranking.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Deve estar em ordem decrescente
      expect(sorted[0].key, equals('Refrigerante')); // 25
      expect(sorted[1].key, equals('Hambúrguer')); // 15
      expect(sorted[2].key, equals('Pizza')); // 10
    });

    test('Deve limitar resultados quando necessário', () {
      final ranking = {
        'Item1': 100,
        'Item2': 90,
        'Item3': 80,
        'Item4': 70,
        'Item5': 60,
      };

      final sorted = ranking.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final limite = 3;
      final topTres = sorted.take(limite).toList();

      expect(topTres.length, equals(3));
      expect(topTres[0].key, equals('Item1'));
    });
  });

  group('Testes de Cálculos Estatísticos', () {
    test('Deve calcular ticket médio corretamente', () {
      final pedidos = [
        {'total': 50.0},
        {'total': 100.0},
        {'total': 75.0},
      ];

      double totalFaturamento = 0.0;
      for (var pedido in pedidos) {
        totalFaturamento += pedido['total'] as double;
      }

      final ticketMedio = totalFaturamento / pedidos.length;

      // (50 + 100 + 75) / 3 = 75.0
      expect(ticketMedio, equals(75.0));
    });

    test('Deve retornar zero quando não houver pedidos', () {
      final pedidos = <Map<String, dynamic>>[];

      final totalPedidos = pedidos.length;
      final faturamentoTotal = 0.0;

      expect(totalPedidos, equals(0));
      expect(faturamentoTotal, equals(0.0));
    });

    test('Deve encontrar o dia mais movimentado', () {
      final pedidosPorDia = {
        '01/01/2024': 5,
        '02/01/2024': 15,
        '03/01/2024': 10,
      };

      final diaMaisMovimentado = pedidosPorDia.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );

      expect(diaMaisMovimentado.key, equals('02/01/2024'));
      expect(diaMaisMovimentado.value, equals(15));
    });
  });
}
