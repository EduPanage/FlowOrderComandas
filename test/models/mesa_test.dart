import 'package:flutter_test/flutter_test.dart';
import 'package:floworder/models/Mesa.dart';

void main() {
  group('Testes do Modelo Mesa', () {
    
    test('Deve criar mesa com todos os dados', () {
      final mesa = Mesa(
        uid: 'mesa001',
        numero: 10,
        nome: 'Mesa VIP',
      );

      expect(mesa.uid, equals('mesa001'));
      expect(mesa.numero, equals(10));
      expect(mesa.nome, equals('Mesa VIP'));
    });

    test('Deve criar mesa com nome vazio por padrão', () {
      final mesa = Mesa(numero: 5);

      expect(mesa.numero, equals(5));
      expect(mesa.nome, equals(''));
      expect(mesa.uid, isNull);
    });

    test('Deve converter mesa para Map corretamente', () {
      final mesa = Mesa(
        uid: 'mesa123',
        numero: 8,
        nome: 'Mesa Varanda',
      );

      final map = mesa.toMap();

      expect(map['uid'], equals('mesa123'));
      expect(map['numero'], equals(8));
      expect(map['nome'], equals('Mesa Varanda'));
    });

    test('Deve criar mesa a partir de Map', () {
      final map = {
        'numero': 15,
        'nome': 'Mesa Externa',
      };

      final mesa = Mesa.fromMap(map, 'docId123');

      expect(mesa.uid, equals('docId123'));
      expect(mesa.numero, equals(15));
      expect(mesa.nome, equals('Mesa Externa'));
    });

    test('Deve criar cópia da mesa com novos valores', () {
      final mesaOriginal = Mesa(
        uid: 'mesa001',
        numero: 3,
        nome: 'Mesa 3',
      );

      final mesaCopia = mesaOriginal.copyWith(
        nome: 'Mesa Premium',
        numero: 30,
      );

      // Verifica que os valores foram alterados
      expect(mesaCopia.nome, equals('Mesa Premium'));
      expect(mesaCopia.numero, equals(30));
      
      // Verifica que o uid permaneceu igual
      expect(mesaCopia.uid, equals('mesa001'));
    });

    test('Deve manter valores originais quando copyWith não recebe parâmetros', () {
      final mesaOriginal = Mesa(
        uid: 'mesa999',
        numero: 7,
        nome: 'Mesa Garden',
      );

      final mesaCopia = mesaOriginal.copyWith();

      expect(mesaCopia.uid, equals(mesaOriginal.uid));
      expect(mesaCopia.numero, equals(mesaOriginal.numero));
      expect(mesaCopia.nome, equals(mesaOriginal.nome));
    });

    test('Deve lidar com número zero de mesa', () {
      // Teste de caso extremo: mesa com número zero
      final mesa = Mesa(numero: 0, nome: 'Mesa Reserva');

      expect(mesa.numero, equals(0));
      expect(mesa.nome, equals('Mesa Reserva'));
    });
  });
}