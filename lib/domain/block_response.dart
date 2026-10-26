import 'package:the_hard_way/core/json.dart';

enum BlockResponseGrade { correct, partial, incorrect }

class BlockResponse {
  final String id;
  final String blockId;
  final String answer;
  BlockResponseGrade? grade;
  String? feedback;
  final DateTime createdAt;

  BlockResponse({
    required this.id,
    required this.blockId,
    required this.answer,
    this.grade,
    this.feedback,
    required this.createdAt,
  });

  Json toJson() {
    return {
      'id': id,
      'block_id': blockId,
      'answer': answer,
      'grade': grade,
      'feedback': feedback,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BlockResponse.fromJson(Json json) {
    final id = json['id'] as String;
    final blockId = json['block_id'] as String;
    final answer = json['answer'] as String;
    final grade = json['grade'] as String?;
    final feedback = json['feedback'] as String?;
    final createdAt = DateTime.parse(json['created_at'] as String);

    return BlockResponse(
      id: id,
      blockId: blockId,
      answer: answer,
      createdAt: createdAt,
    );
  }
}
