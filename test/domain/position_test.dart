import 'package:flutter_test/flutter_test.dart';
import 'package:the_hard_way/domain/domain.dart';

import '../helpers/json_matchers.dart';

void main() {
  const position = Position(x: 12.5, y: -40);

  group('Position', () {
    test('serializa x e y como números', () {
      expect(position.toJson(), {'x': 12.5, 'y': -40.0});
      expect(position.toJson(), hasSnakeCaseKeys);
    });

    test('sobrevive la ida y vuelta por JSON', () {
      expect(Position.fromJson(position.toJson()), position);
    });

    test('acepta enteros en el JSON', () {
      final decoded = Position.fromJson({'x': 100, 'y': 0});

      expect(decoded.x, isA<double>());
      expect(decoded, const Position(x: 100, y: 0));
    });

    test('dos instancias con los mismos datos son iguales', () {
      // ignore: prefer_const_constructors
      final other = Position(x: 12.5, y: -40);

      expect(identical(other, position), isFalse);
      expect(other, position);
      expect(other.hashCode, position.hashCode);
    });

    test('instancias con datos distintos no son iguales', () {
      expect(const Position(x: 12.5, y: -41), isNot(position));
    });
  });
}
