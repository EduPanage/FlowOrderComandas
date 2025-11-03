import 'package:flutter_test/flutter_test.dart';
import 'package:floworder/auxiliar/Validador.dart';

void main() {
  group('Testes do Validador de Email', () {
    late Validador validador;

    setUp(() {
      validador = Validador();
    });

    test('Deve validar email correto', () {
      expect(validador.validarEmail('usuario@exemplo.com'), isTrue);
      expect(validador.validarEmail('teste.nome@dominio.com.br'), isTrue);
      expect(validador.validarEmail('admin@floworder.app'), isTrue);
    });

    test('Deve rejeitar email sem @', () {
      expect(validador.validarEmail('usuarioexemplo.com'), isFalse);
      expect(validador.validarEmail('teste.dominio.com'), isFalse);
    });

    test('Deve rejeitar email sem domínio', () {
      expect(validador.validarEmail('usuario@'), isFalse);
      expect(validador.validarEmail('teste@.com'), isFalse);
    });

    test('Deve rejeitar email vazio ou inválido', () {
      expect(validador.validarEmail(''), isFalse);
      expect(validador.validarEmail('@exemplo.com'), isFalse);
      expect(validador.validarEmail('usuario@'), isFalse);
    });

    test('Deve rejeitar email com espaços', () {
      expect(validador.validarEmail('usuario @exemplo.com'), isFalse);
      expect(validador.validarEmail('usuario@ exemplo.com'), isFalse);
    });
  });

  group('Testes do Validador de Senha', () {
    late Validador validador;

    setUp(() {
      validador = Validador();
    });

    test('Deve validar senha com 6 ou mais caracteres', () {
      expect(validador.validarSenha('123456'), isTrue);
      expect(validador.validarSenha('senhaForte123'), isTrue);
      expect(validador.validarSenha('@bC123'), isTrue);
    });

    test('Deve rejeitar senha com menos de 6 caracteres', () {
      expect(validador.validarSenha('12345'), isFalse);
      expect(validador.validarSenha('abc'), isFalse);
      expect(validador.validarSenha(''), isFalse);
    });

    test('Deve aceitar senha exatamente com 6 caracteres', () {
      // Teste de limite: exatamente 6 caracteres deve ser válido
      expect(validador.validarSenha('abcdef'), isTrue);
      expect(validador.validarSenha('123456'), isTrue);
    });
  });
}
