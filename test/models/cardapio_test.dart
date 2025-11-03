import 'package:flutter_test/flutter_test.dart';
import 'package:floworder/models/Cardapio.dart';

void main() {
  group('Testes do Modelo Cardápio', () {
    
    test('Deve criar item do cardápio com valores padrão', () {
      final item = Cardapio(
        nome: 'Pizza Margherita',
        descricao: 'Pizza com molho de tomate, mussarela e manjericão',
        preco: 45.00,
      );

      expect(item.nome, equals('Pizza Margherita'));
      expect(item.preco, equals(45.00));
      expect(item.ativo, isTrue); // Valor padrão
      expect(item.categoria, equals('Outros')); // Categoria padrão
      expect(item.uid, equals(''));
    });

    test('Deve criar item com todos os campos preenchidos', () {
      final item = Cardapio(
        uid: 'item001',
        nome: 'Suco Natural',
        descricao: 'Suco de laranja natural',
        preco: 8.50,
        ativo: true,
        categoria: 'Bebida',
        observacao: 'Servido gelado',
      );

      expect(item.uid, equals('item001'));
      expect(item.nome, equals('Suco Natural'));
      expect(item.categoria, equals('Bebida'));
      expect(item.observacao, equals('Servido gelado'));
    });

    test('Deve converter item para Map corretamente', () {
      final item = Cardapio(
        nome: 'Espaguete à Carbonara',
        descricao: 'Massa com molho carbonara',
        preco: 38.00,
        categoria: 'Prato',
        ativo: true,
      );

      final map = item.toMap();

      expect(map['nome'], equals('Espaguete à Carbonara'));
      expect(map['descricao'], equals('Massa com molho carbonara'));
      expect(map['preco'], equals(38.00));
      expect(map['categoria'], equals('Prato'));
      expect(map['ativo'], isTrue);
    });

    test('Deve criar item a partir de Map', () {
      final map = {
        'nome': 'Cerveja Artesanal',
        'descricao': 'Cerveja IPA 500ml',
        'preco': 15.00,
        'ativo': true,
        'categoria': 'Bebida',
        'observacao': null,
      };

      final item = Cardapio.fromMap(map, 'doc123');

      expect(item.uid, equals('doc123'));
      expect(item.nome, equals('Cerveja Artesanal'));
      expect(item.preco, equals(15.00));
      expect(item.categoria, equals('Bebida'));
    });

    test('Deve tratar valores ausentes no Map com valores padrão', () {
      // Teste importante: verifica se o sistema lida bem com dados incompletos
      final map = {
        'nome': 'Item Teste',
        'descricao': '',
        'preco': 0,
      };

      final item = Cardapio.fromMap(map, 'doc456');

      expect(item.uid, equals('doc456'));
      expect(item.nome, equals('Item Teste'));
      expect(item.descricao, equals(''));
      expect(item.preco, equals(0.0));
      expect(item.ativo, isTrue); // Valor padrão quando não especificado
      expect(item.categoria, equals('Outros')); // Valor padrão
    });

    test('Deve aceitar preço zero', () {
      // Alguns estabelecimentos podem ter itens cortesia (preço zero)
      final item = Cardapio(
        nome: 'Água',
        descricao: 'Água mineral',
        preco: 0.00,
      );

      expect(item.preco, equals(0.0));
    });

    test('Deve marcar item como inativo', () {
      final item = Cardapio(
        nome: 'Prato Sazonal',
        descricao: 'Disponível apenas no verão',
        preco: 50.00,
        ativo: false, // Item temporariamente indisponível
      );

      expect(item.ativo, isFalse);
    });

    test('Deve lidar com categorias diferentes', () {
      final categorias = ['Bebida', 'Prato', 'Lanche', 'Sobremesa', 'Outros'];

      for (var categoria in categorias) {
        final item = Cardapio(
          nome: 'Teste',
          descricao: 'Teste',
          preco: 10.00,
          categoria: categoria,
        );

        expect(item.categoria, equals(categoria));
      }
    });
  });
}