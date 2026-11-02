import 'package:the_hard_way/core/json.dart';

enum Grade {
  correct,
  partial,
  incorrect;

  static Grade fromName(String value) =>
      Grade.values.asNameMap()[value] ??
      (throw FormatException('Unknown grade: $value'));
}

/// Respuesta terminada a un bloque `prediction` o `check`.
///
/// Un `check` corregido por la IA no entra acá hasta que llega la nota: mientras
/// tanto la respuesta vive en la UI.
sealed class BlockResponse {
  final String id;
  final String blockId;
  final String answer;
  final DateTime createdAt;

  BlockResponse({
    required this.id,
    required this.blockId,
    required this.answer,
    required this.createdAt,
  });

  Json toJson() {
    return {
      'id': id,
      'block_id': blockId,
      'answer': answer,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BlockResponse.fromJson(Json json) {
    final kind = json['kind'] as String?;

    return switch (kind) {
      'prediction' => PredictionResponse.fromJson(json),
      'check' => CheckResponse.fromJson(json),
      _ => throw FormatException('Unknown BlockResponse kind: $kind'),
    };
  }
}

final class PredictionResponse extends BlockResponse {
  PredictionResponse({
    required super.id,
    required super.blockId,
    required super.answer,
    required super.createdAt,
  });

  @override
  Json toJson() => {'kind': 'prediction', ...super.toJson()};

  factory PredictionResponse.fromJson(Json json) {
    return PredictionResponse(
      id: json['id'] as String,
      blockId: json['block_id'] as String,
      answer: json['answer'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PredictionResponse &&
            id == other.id &&
            blockId == other.blockId &&
            answer == other.answer &&
            createdAt == other.createdAt;
  }

  @override
  int get hashCode => Object.hash(id, blockId, answer, createdAt);
}

final class CheckResponse extends BlockResponse {
  final Grade grade;
  final String? feedback;

  CheckResponse({
    required super.id,
    required super.blockId,
    required super.answer,
    required super.createdAt,
    required this.grade,
    this.feedback,
  });

  @override
  Json toJson() => {
    'kind': 'check',
    ...super.toJson(),
    'grade': grade.name,
    if (feedback != null) 'feedback': feedback,
  };

  factory CheckResponse.fromJson(Json json) {
    return CheckResponse(
      id: json['id'] as String,
      blockId: json['block_id'] as String,
      answer: json['answer'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      grade: Grade.fromName(json['grade'] as String),
      feedback: json['feedback'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CheckResponse &&
            id == other.id &&
            blockId == other.blockId &&
            answer == other.answer &&
            createdAt == other.createdAt &&
            grade == other.grade &&
            feedback == other.feedback;
  }

  @override
  int get hashCode =>
      Object.hash(id, blockId, answer, createdAt, grade, feedback);
}
