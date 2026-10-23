import 'package:the_hard_way/domain/generation.dart';

sealed class Node {
  final String id;
  final String threadId;
  final int order;
  final DateTime createdAt;

  Node({
    required this.id,
    required this.threadId,
    required this.order,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'thread_id': threadId,
      'order': order,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Node.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as String?;

    return switch (role) {
      'user' => UserNode.fromJson(json),
      'agent' => AgentNode.fromJson(json),
      _ => throw FormatException('Unknown Node role: $role'),
    };
  }
}

final class UserNode extends Node {
  UserNode({
    required super.id,
    required super.threadId,
    required super.order,
    required super.createdAt,
  });

  @override
  Map<String, dynamic> toJson() {
    return {'role': 'user', ...super.toJson()};
  }

  factory UserNode.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final threadId = json['thread_id'] as String;
    final order = json['order'] as int;
    final createdAt = DateTime.parse(json['created_at'] as String);

    return UserNode(
      id: id,
      threadId: threadId,
      order: order,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UserNode &&
            id == other.id &&
            threadId == other.threadId &&
            order == other.order &&
            createdAt == other.createdAt;
  }

  @override
  int get hashCode => Object.hash(id, threadId, order, createdAt);
}

final class AgentNode extends Node {
  final GenerationMetaData generation;

  AgentNode({
    required super.id,
    required super.threadId,
    required super.order,
    required super.createdAt,
    required this.generation,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'role': 'agent',
      'generation': generation.toJson(),
      ...super.toJson(),
    };
  }

  factory AgentNode.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final threadId = json['thread_id'] as String;
    final order = json['order'] as int;
    final createdAt = DateTime.parse(json['created_at'] as String);
    final generation = GenerationMetaData.fromJson(
      json['generation'] as Map<String, dynamic>,
    );

    return AgentNode(
      id: id,
      threadId: threadId,
      order: order,
      createdAt: createdAt,
      generation: generation,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AgentNode &&
            id == other.id &&
            threadId == other.threadId &&
            order == other.order &&
            createdAt == other.createdAt &&
            generation == other.generation;
  }

  @override
  int get hashCode => Object.hash(id, threadId, order, createdAt, generation);
}
