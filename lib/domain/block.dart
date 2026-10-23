import 'package:the_hard_way/core/list_equals.dart';
import 'package:the_hard_way/core/json.dart';

/// Bloque de contenido dentro de un [Node].
class Block {
  final String id;
  final String nodeId;
  final int order;
  final List<String> conceptIds;
  final BlockData data;

  const Block({
    required this.id,
    required this.nodeId,
    required this.order,
    required this.data,
    this.conceptIds = const [],
  });

  bool get blocksProgress => data.blocksProgress;

  Json toJson() => {
    'id': id,
    'node_id': nodeId,
    'order': order,
    'concept_ids': conceptIds,
    'data': data.toJson(),
  };

  factory Block.fromJson(Json json) {
    final conceptIds = json['concept_ids'];
    return Block(
      id: json['id'] as String,
      nodeId: json['node_id'] as String,
      order: json['order'] as int,
      conceptIds: conceptIds is List
          ? conceptIds.map((e) => e as String).toList()
          : const [],
      data: BlockData.fromJson(json['data'] as Json),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Block &&
          id == other.id &&
          nodeId == other.nodeId &&
          order == other.order &&
          listEquals(conceptIds, other.conceptIds) &&
          data == other.data;

  @override
  int get hashCode =>
      Object.hash(id, nodeId, order, Object.hashAll(conceptIds), data);
}

/// Contenido tipado de un bloque. El discriminador JSON es `type`.
sealed class BlockData {
  const BlockData();

  bool get blocksProgress => switch (this) {
    PredictionData() || CheckData() => true,
    _ => false,
  };

  Json toJson();

  static BlockData fromJson(Json json) {
    final type = json['type'] as String;
    return switch (type) {
      'explanation' => ExplanationData.fromJson(json),
      'user_message' => UserMessageData.fromJson(json),
      'code' => CodeData.fromJson(json),
      'diagram' => DiagramData.fromJson(json),
      'reference' => ReferenceData.fromJson(json),
      'prediction' => PredictionData.fromJson(json),
      'check' => CheckData.fromJson(json),
      _ => throw FormatException('Unknown block data type: $type'),
    };
  }
}

final class ExplanationData extends BlockData {
  final String markdown;

  const ExplanationData({required this.markdown});

  @override
  Json toJson() => {'type': 'explanation', 'markdown': markdown};

  factory ExplanationData.fromJson(Json json) =>
      ExplanationData(markdown: json['markdown'] as String);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExplanationData && markdown == other.markdown;

  @override
  int get hashCode => markdown.hashCode;
}

final class UserMessageData extends BlockData {
  final String markdown;

  const UserMessageData({required this.markdown});

  @override
  Json toJson() => {'type': 'user_message', 'markdown': markdown};

  factory UserMessageData.fromJson(Json json) =>
      UserMessageData(markdown: json['markdown'] as String);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMessageData && markdown == other.markdown;

  @override
  int get hashCode => markdown.hashCode;
}

final class CodeData extends BlockData {
  final String language;
  final String source;
  final bool runnable;

  const CodeData({
    required this.language,
    required this.source,
    this.runnable = false,
  });

  @override
  Json toJson() => {
    'type': 'code',
    'language': language,
    'source': source,
    'runnable': runnable,
  };

  factory CodeData.fromJson(Json json) => CodeData(
    language: json['language'] as String,
    source: json['source'] as String,
    runnable: json['runnable'] as bool? ?? false,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeData &&
          language == other.language &&
          source == other.source &&
          runnable == other.runnable;

  @override
  int get hashCode => Object.hash(language, source, runnable);
}

/// JSON de grafo propio (nodos y aristas); ver docs/stack.md.
final class DiagramData extends BlockData {
  final String source;

  const DiagramData({required this.source});

  @override
  Json toJson() => {'type': 'diagram', 'source': source};

  factory DiagramData.fromJson(Json json) =>
      DiagramData(source: json['source'] as String);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DiagramData && source == other.source;

  @override
  int get hashCode => source.hashCode;
}

final class ReferenceData extends BlockData {
  final String title;
  final String url;
  final String? excerpt;

  const ReferenceData({required this.title, required this.url, this.excerpt});

  @override
  Json toJson() => {
    'type': 'reference',
    'title': title,
    'url': url,
    if (excerpt != null) 'excerpt': excerpt,
  };

  factory ReferenceData.fromJson(Json json) => ReferenceData(
    title: json['title'] as String,
    url: json['url'] as String,
    excerpt: json['excerpt'] as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReferenceData &&
          title == other.title &&
          url == other.url &&
          excerpt == other.excerpt;

  @override
  int get hashCode => Object.hash(title, url, excerpt);
}

final class PredictionData extends BlockData {
  final String question;

  const PredictionData({required this.question});

  @override
  Json toJson() => {'type': 'prediction', 'question': question};

  factory PredictionData.fromJson(Json json) =>
      PredictionData(question: json['question'] as String);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionData && question == other.question;

  @override
  int get hashCode => question.hashCode;
}

final class CheckData extends BlockData {
  final CheckQuestion question;

  const CheckData({required this.question});

  @override
  Json toJson() => {'type': 'check', ...question.toJson()};

  factory CheckData.fromJson(Json json) =>
      CheckData(question: CheckQuestion.fromJson(json));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckData && question == other.question;

  @override
  int get hashCode => question.hashCode;
}

/// Pregunta de evaluación; estados inválidos (p. ej. opción múltiple sin opciones)
/// no son representables.
sealed class CheckQuestion {
  const CheckQuestion();

  String get prompt;

  Json toJson();

  static CheckQuestion fromJson(Json json) {
    final kind = json['kind'] as String;
    return switch (kind) {
      'free_text' => FreeTextCheck.fromJson(json),
      'multiple_choice' => MultipleChoiceCheck.fromJson(json),
      'code' => CodeCheck.fromJson(json),
      'find_bug' => FindBugCheck.fromJson(json),
      _ => throw FormatException('Unknown check kind: $kind'),
    };
  }
}

final class FreeTextCheck extends CheckQuestion {
  @override
  final String prompt;
  final String rubric;

  const FreeTextCheck({required this.prompt, required this.rubric});

  @override
  Json toJson() => {'kind': 'free_text', 'question': prompt, 'rubric': rubric};

  factory FreeTextCheck.fromJson(Json json) => FreeTextCheck(
    prompt: json['question'] as String,
    rubric: json['rubric'] as String,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FreeTextCheck &&
          prompt == other.prompt &&
          rubric == other.rubric;

  @override
  int get hashCode => Object.hash(prompt, rubric);
}

final class MultipleChoiceCheck extends CheckQuestion {
  @override
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String? rubric;

  MultipleChoiceCheck({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.rubric,
  }) : assert(options.isNotEmpty),
       assert(correctIndex >= 0 && correctIndex < options.length);

  @override
  Json toJson() => {
    'kind': 'multiple_choice',
    'question': prompt,
    'options': options,
    'correct_index': correctIndex,
    if (rubric != null) 'rubric': rubric,
  };

  factory MultipleChoiceCheck.fromJson(Json json) {
    final options = (json['options'] as List).map((e) => e as String).toList();
    return MultipleChoiceCheck(
      prompt: json['question'] as String,
      options: options,
      correctIndex: json['correct_index'] as int,
      rubric: json['rubric'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultipleChoiceCheck &&
          prompt == other.prompt &&
          listEquals(options, other.options) &&
          correctIndex == other.correctIndex &&
          rubric == other.rubric;

  @override
  int get hashCode =>
      Object.hash(prompt, Object.hashAll(options), correctIndex, rubric);
}

final class CodeCheck extends CheckQuestion {
  @override
  final String prompt;
  final String rubric;

  const CodeCheck({required this.prompt, required this.rubric});

  @override
  Json toJson() => {'kind': 'code', 'question': prompt, 'rubric': rubric};

  factory CodeCheck.fromJson(Json json) => CodeCheck(
    prompt: json['question'] as String,
    rubric: json['rubric'] as String,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeCheck && prompt == other.prompt && rubric == other.rubric;

  @override
  int get hashCode => Object.hash(prompt, rubric);
}

final class FindBugCheck extends CheckQuestion {
  @override
  final String prompt;
  final String rubric;

  const FindBugCheck({required this.prompt, required this.rubric});

  @override
  Json toJson() => {'kind': 'find_bug', 'question': prompt, 'rubric': rubric};

  factory FindBugCheck.fromJson(Json json) => FindBugCheck(
    prompt: json['question'] as String,
    rubric: json['rubric'] as String,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FindBugCheck && prompt == other.prompt && rubric == other.rubric;

  @override
  int get hashCode => Object.hash(prompt, rubric);
}
