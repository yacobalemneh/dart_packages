enum OpenAiModel {
  chatGptTurbo,
  chatGpt,
  gpt4,
  gpt3,
  textDavinci,
  whisper1,
  whisper2,
  whisper3,
}

extension OpenAiModelExtension on OpenAiModel {
  String get value {
    switch (this) {
      case OpenAiModel.chatGptTurbo:
        return 'gpt-3.5-turbo';
      case OpenAiModel.chatGpt:
        return 'gpt-3.5-turbo';
      case OpenAiModel.gpt4:
        return 'gpt-4';
      case OpenAiModel.gpt3:
        return 'text-davinci-003';
      case OpenAiModel.textDavinci:
        return 'text-davinci';
      case OpenAiModel.whisper1:
        return 'whisper-1';
      case OpenAiModel.whisper2:
        return 'whisper-2';
      case OpenAiModel.whisper3:
        return 'whisper-3';
      default:
        throw Exception('Invalid model');
    }
  }

}

class OpenAiModelUtils {
  static Set<OpenAiModel> get chatCompletionModels => {
        OpenAiModel.chatGptTurbo,
        OpenAiModel.chatGpt,
        OpenAiModel.gpt4,
  };

  static Set<OpenAiModel> get completionModels => {
        OpenAiModel.gpt4,
        OpenAiModel.gpt3,
        OpenAiModel.textDavinci,
  };

  static Set<OpenAiModel> get speechToTextModels => {
        OpenAiModel.whisper1,
        OpenAiModel.whisper2,
        OpenAiModel.whisper3,
  };
}

