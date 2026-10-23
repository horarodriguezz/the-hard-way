import 'package:flutter_test/flutter_test.dart';

final _snakeCase = RegExp(r'^[a-z][a-z0-9]*(_[a-z0-9]+)*$');

/// Verifica que todas las claves de un JSON, incluidas las de mapas anidados
/// y las de mapas dentro de listas, estén en snake_case.
const Matcher hasSnakeCaseKeys = _HasSnakeCaseKeys();

class _HasSnakeCaseKeys extends Matcher {
  const _HasSnakeCaseKeys();

  @override
  bool matches(Object? item, Map<Object?, Object?> matchState) {
    final invalid = _invalidKeyPaths(item, '');
    matchState['invalid'] = invalid;
    return invalid.isEmpty;
  }

  @override
  Description describe(Description description) =>
      description.add('un JSON con todas sus claves en snake_case');

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map<Object?, Object?> matchState,
    bool verbose,
  ) {
    final invalid = matchState['invalid'] as List<String>;
    return mismatchDescription.add(
      'tiene claves inválidas: ${invalid.join(', ')}',
    );
  }

  static List<String> _invalidKeyPaths(Object? value, String path) {
    return switch (value) {
      Map() => [
        for (final MapEntry(:key, value: child) in value.entries) ...[
          if (key is! String || !_snakeCase.hasMatch(key)) '$path$key',
          ..._invalidKeyPaths(child, '$path$key.'),
        ],
      ],
      List() => [
        for (final (index, child) in value.indexed)
          ..._invalidKeyPaths(child, '$path[$index].'),
      ],
      _ => const [],
    };
  }
}
