import 'package:flutter_test/flutter_test.dart';
import 'package:the_hard_way/domain/domain.dart';

import '../helpers/json_matchers.dart';

void main() {
  const generation = GenerationMetaData(
    model: 'claude',
    promptVersion: 'lesson-v1',
    tokensIn: 120,
    tokensOut: 480,
  );

  group('GenerationMetaData', () {
    test('serializa con claves snake_case', () {
      expect(generation.toJson(), {
        'model': 'claude',
        'prompt_version': 'lesson-v1',
        'tokens_in': 120,
        'tokens_out': 480,
      });
      expect(generation.toJson(), hasSnakeCaseKeys);
    });

    test('sobrevive la ida y vuelta por JSON', () {
      expect(GenerationMetaData.fromJson(generation.toJson()), generation);
    });

    test('dos instancias con los mismos datos son iguales', () {
      // Sin `const`: dos `const` iguales son el mismo objeto y el test no
      // probaría el `==`.
      // ignore: prefer_const_constructors
      final other = GenerationMetaData(
        model: 'claude',
        promptVersion: 'lesson-v1',
        tokensIn: 120,
        tokensOut: 480,
      );

      expect(identical(other, generation), isFalse);
      expect(other, generation);
      expect(other.hashCode, generation.hashCode);
    });

    test('instancias con datos distintos no son iguales', () {
      const other = GenerationMetaData(
        model: 'claude',
        promptVersion: 'lesson-v1',
        tokensIn: 120,
        tokensOut: 481,
      );

      expect(other, isNot(generation));
    });
  });
}
