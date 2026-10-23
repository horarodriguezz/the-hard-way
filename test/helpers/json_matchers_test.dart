import 'package:flutter_test/flutter_test.dart';

import 'json_matchers.dart';

void main() {
  group('hasSnakeCaseKeys', () {
    test('acepta claves snake_case, anidadas y dentro de listas', () {
      expect({
        'id': 1,
        'node_id': 'n',
        'tokens_in2': 3,
        'position': {'x': 1, 'y': 2},
        'items': [
          {'concept_ids': <String>[]},
        ],
      }, hasSnakeCaseKeys);
    });

    test('rechaza camelCase en el primer nivel', () {
      expect({'nodeId': 'n'}, isNot(hasSnakeCaseKeys));
    });

    test('rechaza camelCase en un mapa anidado', () {
      expect({
        'generation': {'promptVersion': 'v1'},
      }, isNot(hasSnakeCaseKeys));
    });

    test('rechaza camelCase dentro de una lista', () {
      expect({
        'items': [
          {'conceptIds': <String>[]},
        ],
      }, isNot(hasSnakeCaseKeys));
    });

    test('rechaza mayúsculas, guiones y guiones bajos sobrantes', () {
      for (final key in ['Id', 'node-id', '_id', 'node__id', 'node_', '1d']) {
        expect({key: 0}, isNot(hasSnakeCaseKeys), reason: key);
      }
    });
  });
}
