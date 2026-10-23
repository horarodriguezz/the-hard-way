import 'package:flutter_test/flutter_test.dart';
import 'package:the_hard_way/domain/domain.dart';

import '../helpers/json_matchers.dart';

void main() {
  const layout = NodeLayout(
    nodeId: 'node-1',
    position: Position(x: 10, y: 20),
    collapsed: true,
  );

  group('NodeLayout', () {
    test('collapsed es false por defecto', () {
      const layout = NodeLayout(
        nodeId: 'node-1',
        position: Position(x: 0, y: 0),
      );

      expect(layout.collapsed, isFalse);
    });

    test('serializa con la posición anidada', () {
      expect(layout.toJson(), {
        'node_id': 'node-1',
        'collapsed': true,
        'position': {'x': 10.0, 'y': 20.0},
      });
      expect(layout.toJson(), hasSnakeCaseKeys);
    });

    test('sobrevive la ida y vuelta por JSON', () {
      expect(NodeLayout.fromJson(layout.toJson()), layout);
    });

    test('collapsed faltante se lee como false', () {
      final json = layout.toJson()..remove('collapsed');

      expect(NodeLayout.fromJson(json).collapsed, isFalse);
    });

    test('dos instancias con los mismos datos son iguales', () {
      // ignore: prefer_const_constructors
      final other = NodeLayout(
        nodeId: 'node-1',
        // ignore: prefer_const_constructors
        position: Position(x: 10, y: 20),
        collapsed: true,
      );

      expect(identical(other, layout), isFalse);
      expect(other, layout);
      expect(other.hashCode, layout.hashCode);
    });

    test('distinta posición o collapsed implica layouts distintos', () {
      expect(
        const NodeLayout(
          nodeId: 'node-1',
          position: Position(x: 10, y: 21),
          collapsed: true,
        ),
        isNot(layout),
      );
      expect(
        const NodeLayout(nodeId: 'node-1', position: Position(x: 10, y: 20)),
        isNot(layout),
      );
    });
  });
}
