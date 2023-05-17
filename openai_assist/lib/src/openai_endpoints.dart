class OpenAiEndpoint {
  static const chatCompletions = '/v1/chat/completions';
  static const completions = '/v1/completions';


  static String completionsForModel(String model) {
    return completions.replaceAll('{}', model);
  }
}


