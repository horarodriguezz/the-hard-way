import 'package:the_hard_way/core/json.dart';

final class GenerationMetaData {
  final String model;
  final String promptVersion;
  final int tokensIn;
  final int tokensOut;

  const GenerationMetaData({
    required this.model,
    required this.promptVersion,
    required this.tokensIn,
    required this.tokensOut,
  });

  Json toJson() {
    return {
      'model': model,
      'prompt_version': promptVersion,
      'tokens_in': tokensIn,
      'tokens_out': tokensOut,
    };
  }

  factory GenerationMetaData.fromJson(Json json) {
    return GenerationMetaData(
      model: json['model'] as String,
      promptVersion: json['prompt_version'] as String,
      tokensIn: json['tokens_in'] as int,
      tokensOut: json['tokens_out'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is GenerationMetaData &&
            model == other.model &&
            promptVersion == other.promptVersion &&
            tokensIn == other.tokensIn &&
            tokensOut == other.tokensOut;
  }

  @override
  int get hashCode => Object.hash(model, promptVersion, tokensIn, tokensOut);
}
