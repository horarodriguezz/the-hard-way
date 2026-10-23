import 'package:the_hard_way/core/json.dart';

class Position {
  final double x;
  final double y;

  const Position({required this.x, required this.y});

  Json toJson() {
    return {'x': x, 'y': y};
  }

  factory Position.fromJson(Json json) {
    final x = (json['x'] as num).toDouble();
    final y = (json['y'] as num).toDouble();

    return Position(x: x, y: y);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Position && x == other.x && y == other.y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}
