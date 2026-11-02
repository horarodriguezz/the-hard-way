import 'package:flutter_test/flutter_test.dart';
import 'package:the_hard_way/domain/domain.dart';

import '../helpers/json_matchers.dart';

void main() {
  final createdAt = DateTime.utc(2026, 10, 23, 2, 17);

  PredictionResponse prediction() => PredictionResponse(
    id: 'response-1',
    blockId: 'block-1',
    answer: 'Creo que imprime 2',
    createdAt: createdAt,
  );

  CheckResponse check({String? feedback = 'Falta mencionar el fanout'}) =>
      CheckResponse(
        id: 'response-1',
        blockId: 'block-1',
        answer: 'Porque reduce las lecturas',
        createdAt: createdAt,
        grade: Grade.partial,
        feedback: feedback,
      );

  group('PredictionResponse', () {
    test('serializa sin grade ni feedback', () {
      expect(prediction().toJson(), {
        'kind': 'prediction',
        'id': 'response-1',
        'block_id': 'block-1',
        'answer': 'Creo que imprime 2',
        'created_at': '2026-10-23T02:17:00.000Z',
      });
      expect(prediction().toJson(), hasSnakeCaseKeys);
    });

    test('sobrevive la ida y vuelta por JSON', () {
      final response = prediction();
      final decoded = BlockResponse.fromJson(response.toJson());

      expect(decoded, isA<PredictionResponse>());
      expect(decoded, response);
    });
  });

  group('CheckResponse', () {
    test('serializa la nota como string y omite feedback nulo', () {
      final json = check(feedback: null).toJson();

      expect(json['grade'], 'partial');
      expect(json.containsKey('feedback'), isFalse);
      expect(json, hasSnakeCaseKeys);
    });

    test('sobrevive la ida y vuelta por JSON con feedback', () {
      final response = check();
      final decoded = BlockResponse.fromJson(response.toJson());

      expect(decoded, isA<CheckResponse>());
      expect(decoded, response);
    });

    test('feedback faltante se lee como null', () {
      final json = check().toJson()..remove('feedback');

      expect((BlockResponse.fromJson(json) as CheckResponse).feedback, isNull);
    });

    test('distinta nota implica respuestas distintas', () {
      final other = CheckResponse(
        id: 'response-1',
        blockId: 'block-1',
        answer: 'Porque reduce las lecturas',
        createdAt: createdAt,
        grade: Grade.correct,
        feedback: 'Falta mencionar el fanout',
      );

      expect(other, isNot(check()));
    });
  });

  group('BlockResponse', () {
    test('una prediction y un check con los mismos campos no son iguales', () {
      final graded = CheckResponse(
        id: 'response-1',
        blockId: 'block-1',
        answer: 'Creo que imprime 2',
        createdAt: createdAt,
        grade: Grade.incorrect,
      );

      expect(prediction(), isNot(graded));
      expect(graded, isNot(prediction()));
    });

    test('fromJson rechaza un kind desconocido', () {
      final json = {...prediction().toJson(), 'kind': 'comment'};

      expect(() => BlockResponse.fromJson(json), throwsFormatException);
    });

    test('fromJson rechaza un JSON sin kind', () {
      final json = prediction().toJson()..remove('kind');

      expect(() => BlockResponse.fromJson(json), throwsFormatException);
    });

    test('fromJson rechaza una nota desconocida', () {
      final json = check().toJson()..['grade'] = 'corect';

      expect(() => BlockResponse.fromJson(json), throwsFormatException);
    });
  });
}
