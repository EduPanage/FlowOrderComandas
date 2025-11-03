import 'package:flutter_test/flutter_test.dart';
import 'package:floworder/models/Pedido.dart';
import 'package:floworder/models/Mesa.dart';
import 'package:floworder/models/ItemCardapio.dart';

void main() {
  group('Testes do Modelo Pedido', () {
    // Variáveis auxiliares que serão reutilizadas nos testes
    late Mesa mesaTeste;
    late List<ItemCardapio> itensTeste;

    // Configuração inicial executada antes de cada teste
    setUp(() {
      mesaTeste = Mesa(uid: '1', numero: 5, nome: 'Mesa 5');
      
      itensTeste = [
        ItemCardapio(
          uid: '1',
          nome: 'Refrigerante',
          preco: 5.00,
          categoria: 'Bebida',
          quantidade: 2,
        ),
        ItemCardapio(
          uid: '2',
          nome: 'Hambúrguer',
          preco: 25.00,
          categoria: 'Lanche',
          quantidade: 1,
        ),
      ];
    });

    test('Deve calcular o total do pedido corretamente', () {
      // Arrange: Preparação dos dados
      final pedido = Pedido(
        horario: DateTime.now(),
        mesa: mesaTeste,
        itens: itensTeste,
        statusAtual: 'Aberto',
      );

      // Act: Execução da ação
      final total = pedido.calcularTotal();

      // Assert: Verificação do resultado
      // 2 refrigerantes (R$ 5,00 cada) + 1 hambúrguer (R$ 25,00) = R$ 35,00
      expect(total, equals(35.00));
    });

    test('Deve criar pedido com status inicial correto', () {
      final pedido = Pedido(
        horario: DateTime.now(),
        mesa: mesaTeste,
        itens: itensTeste,
        statusAtual: 'Aberto',
      );

      expect(pedido.statusAtual, equals('Aberto'));
      expect(pedido.pago, isFalse);
    });

    test('Deve retornar total zero quando não houver itens', () {
      final pedido = Pedido(
        horario: DateTime.now(),
        mesa: mesaTeste,
        itens: [], // Lista vazia
        statusAtual: 'Aberto',
      );

      expect(pedido.calcularTotal(), equals(0.0));
    });

    test('Deve converter pedido para Map corretamente', () {
      final agora = DateTime.now();
      final pedido = Pedido(
        uid: 'pedido123',
        horario: agora,
        mesa: mesaTeste,
        itens: itensTeste,
        statusAtual: 'Em Preparo',
        observacao: 'Sem cebola',
        pago: false,
      );

      final map = pedido.toMap();

      expect(map['uid'], equals('pedido123'));
      expect(map['statusAtual'], equals('Em Preparo'));
      expect(map['observacao'], equals('Sem cebola'));
      expect(map['pago'], isFalse);
      expect(map['itens'], isA<List>());
      expect(map['itens'].length, equals(2));
    });

    test('Deve criar cópia do pedido com novos valores', () {
      final pedidoOriginal = Pedido(
        uid: 'pedido123',
        horario: DateTime.now(),
        mesa: mesaTeste,
        itens: itensTeste,
        statusAtual: 'Aberto',
      );

      final pedidoCopia = pedidoOriginal.copyWith(
        statusAtual: 'Pronto',
        pago: true,
      );

      // Verifica que os valores foram alterados
      expect(pedidoCopia.statusAtual, equals('Pronto'));
      expect(pedidoCopia.pago, isTrue);
      
      // Verifica que os outros valores permaneceram iguais
      expect(pedidoCopia.uid, equals(pedidoOriginal.uid));
      expect(pedidoCopia.itens.length, equals(pedidoOriginal.itens.length));
    });

    test('Deve calcular total com múltiplas quantidades', () {
      final itensVariados = [
        ItemCardapio(
          nome: 'Pizza',
          preco: 40.00,
          categoria: 'Prato',
          quantidade: 3,
        ),
        ItemCardapio(
          nome: 'Suco',
          preco: 8.00,
          categoria: 'Bebida',
          quantidade: 5,
        ),
      ];

      final pedido = Pedido(
        horario: DateTime.now(),
        mesa: mesaTeste,
        itens: itensVariados,
        statusAtual: 'Aberto',
      );

      // 3 pizzas (R$ 40,00) + 5 sucos (R$ 8,00) = R$ 120,00 + R$ 40,00 = R$ 160,00
      expect(pedido.calcularTotal(), equals(160.00));
    });
  });
}