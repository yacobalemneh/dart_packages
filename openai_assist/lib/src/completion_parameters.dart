class CompletionParameters {
  final double? temperature;
  final int? maxTokens;
  final double? frequencyPenalty;

 CompletionParameters({
    this.temperature = 0.7,
    this.maxTokens = 100,
    this.frequencyPenalty = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'max_tokens': maxTokens,
      'frequency_penalty': frequencyPenalty,
    }..removeWhere((_, value) => value == null);
  }
}
