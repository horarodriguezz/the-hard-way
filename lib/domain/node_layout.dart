import 'package:the_hard_way/core/json.dart';
import 'package:the_hard_way/domain/position.dart';

class NodeLayout {
  final String nodeId;
  final bool collapsed;
  final Position position;

  const NodeLayout({
    required this.nodeId,
    required this.position,
    this.collapsed = false,
  });

  Json toJson() {
    return {
      'node_id': nodeId,
      'collapsed': collapsed,
      'position': position.toJson(),
    };
  }

  factory NodeLayout.fromJson(Json json) {
    final String nodeId = json['nodeId'] as String;
    final bool collapsed = json['collapsed'] as bool? ?? false;
    final Position position = Position.fromJson(json['position'] as Json);

    return NodeLayout(nodeId: nodeId, position: position, collapsed: collapsed);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NodeLayout &&
            nodeId == other.nodeId &&
            collapsed == other.collapsed &&
            position == other.position;
  }

  @override
  int get hashCode => Object.hash(nodeId, collapsed, position);
}
