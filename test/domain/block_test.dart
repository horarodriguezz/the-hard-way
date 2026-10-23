import 'package:flutter_test/flutter_test.dart';
import 'package:the_hard_way/domain/domain.dart';

void main() {
  Block blockWith(BlockData data) => Block(
    id: 'block-1',
    nodeId: 'node-1',
    order: 0,
    conceptIds: const ['b-tree', 'page'],
    data: data,
  );

  final variants = <String, BlockData>{
    'explanation': const ExplanationData(markdown: '# Hola'),
    'user_message': const UserMessageData(markdown: '¿Por qué?'),
    'code': const CodeData(language: 'dart', source: 'void main() {}'),
    'diagram': const DiagramData(source: '{"nodes": []}'),
    'reference': const ReferenceData(
      title: 'SQLite',
      url: 'https://sqlite.org',
      excerpt: 'B-tree pages',
    ),
    'prediction': const PredictionData(question: '¿Qué imprime?'),
    'check free_text': const CheckData(
      question: FreeTextCheck(prompt: 'Explicá', rubric: 'Menciona X'),
    ),
    'check multiple_choice': CheckData(
      question: MultipleChoiceCheck(
        prompt: 'Elegí',
        options: const ['a', 'b'],
        correctIndex: 1,
      ),
    ),
    'check code': const CheckData(
      question: CodeCheck(prompt: 'Implementá', rubric: 'Compila'),
    ),
    'check find_bug': const CheckData(
      question: FindBugCheck(prompt: 'Encontrá el bug', rubric: 'Off by one'),
    ),
  };

  group('Block', () {
    for (final MapEntry(key: name, value: data) in variants.entries) {
      test('$name sobrevive la ida y vuelta por JSON', () {
        final block = blockWith(data);

        expect(Block.fromJson(block.toJson()), block);
      });
    }

    test('dos bloques con los mismos datos son iguales', () {
      final a = blockWith(const ExplanationData(markdown: 'x'));
      final b = blockWith(const ExplanationData(markdown: 'x'));

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('conceptIds faltante se lee como lista vacía', () {
      final json = blockWith(const ExplanationData(markdown: 'x')).toJson()
        ..remove('concept_ids');

      expect(Block.fromJson(json).conceptIds, isEmpty);
    });

    test('solo prediction y check frenan el progreso', () {
      for (final MapEntry(key: name, value: data) in variants.entries) {
        final expected = data is PredictionData || data is CheckData;

        expect(blockWith(data).blocksProgress, expected, reason: name);
      }
    });
  });

  group('BlockData.fromJson', () {
    test('rechaza un type desconocido', () {
      expect(
        () => BlockData.fromJson({'type': 'video'}),
        throwsFormatException,
      );
    });

    test('rechaza un kind de check desconocido', () {
      expect(
        () => BlockData.fromJson({
          'type': 'check',
          'kind': 'essay',
          'question': '?',
        }),
        throwsFormatException,
      );
    });
  });
}
