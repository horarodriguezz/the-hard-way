import 'package:flutter_test/flutter_test.dart';
import 'package:the_hard_way/domain/domain.dart';

import '../helpers/json_matchers.dart';

void main() {
  final createdAt = DateTime.utc(2026, 10, 23, 2, 17);

  const generation = GenerationMetaData(
    model: 'claude',
    promptVersion: 'lesson-v1',
    tokensIn: 120,
    tokensOut: 480,
  );

  UserNode userNode() => UserNode(
    id: 'node-1',
    threadId: 'thread-1',
    order: 0,
    createdAt: createdAt,
  );

  AgentNode agentNode() => AgentNode(
    id: 'node-1',
    threadId: 'thread-1',
    order: 0,
    createdAt: createdAt,
    generation: generation,
  );

  group('UserNode', () {
    test('serializa con role user', () {
      expect(userNode().toJson(), {
        'role': 'user',
        'id': 'node-1',
        'thread_id': 'thread-1',
        'order': 0,
        'created_at': '2026-10-23T02:17:00.000Z',
      });
      expect(userNode().toJson(), hasSnakeCaseKeys);
    });

    test('sobrevive la ida y vuelta por JSON', () {
      final node = userNode();
      final decoded = Node.fromJson(node.toJson());

      expect(decoded, isA<UserNode>());
      expect(decoded, node);
    });

    test('dos instancias con los mismos datos son iguales', () {
      expect(userNode(), userNode());
      expect(userNode().hashCode, userNode().hashCode);
    });
  });

  group('AgentNode', () {
    test('serializa con role agent y generation', () {
      final json = agentNode().toJson();

      expect(json['role'], 'agent');
      expect(json['generation'], generation.toJson());
      expect(json, hasSnakeCaseKeys);
    });

    test('sobrevive la ida y vuelta por JSON', () {
      final node = agentNode();
      final decoded = Node.fromJson(node.toJson());

      expect(decoded, isA<AgentNode>());
      expect(decoded, node);
    });

    test('distinta generation implica nodos distintos', () {
      final other = AgentNode(
        id: 'node-1',
        threadId: 'thread-1',
        order: 0,
        createdAt: createdAt,
        generation: const GenerationMetaData(
          model: 'otro',
          promptVersion: 'lesson-v1',
          tokensIn: 120,
          tokensOut: 480,
        ),
      );

      expect(other, isNot(agentNode()));
    });
  });

  group('Node', () {
    test('un UserNode y un AgentNode con los mismos campos no son iguales', () {
      expect(userNode(), isNot(agentNode()));
      expect(agentNode(), isNot(userNode()));
    });

    test('fromJson rechaza un role desconocido', () {
      final json = {...userNode().toJson(), 'role': 'system'};

      expect(() => Node.fromJson(json), throwsFormatException);
    });

    test('fromJson rechaza un JSON sin role', () {
      final json = userNode().toJson()..remove('role');

      expect(() => Node.fromJson(json), throwsFormatException);
    });
  });
}
